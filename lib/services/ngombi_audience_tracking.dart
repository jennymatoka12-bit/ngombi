import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pseudonymous audience and usage telemetry. No hardware identifiers are read.
class NgombiAudienceTracking with WidgetsBindingObserver {
  NgombiAudienceTracking._();
  static final NgombiAudienceTracking instance = NgombiAudienceTracking._();

  static const MethodChannel _usageChannel = MethodChannel('ngombi/usage');
  Timer? _timer;
  String? _installationId;
  String _section = 'Accueil';
  bool _started = false;
  bool _foreground = false;
  DateTime? _lastUsageSampleAt;
  int? _lastRxBytes;
  int? _lastTxBytes;
  bool _sampleInProgress = false;

  Future<void> start(String section) async {
    _section = _validSection(section);
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addObserver(this);
      _installationId = await _getInstallationId();
      await _loadNetworkBaseline();
    }
    _foreground = true;
    _lastUsageSampleAt ??= DateTime.now();
    await _sendHeartbeat();
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_flushUsage());
      unawaited(_sendHeartbeat());
    });
  }

  void setSection(String section) {
    final nextSection = _validSection(section);
    if (_started && nextSection != _section) {
      unawaited(_changeSection(nextSection));
    } else {
      _section = nextSection;
      if (_started) unawaited(_sendHeartbeat());
    }
  }

  Future<void> _changeSection(String nextSection) async {
    await _flushUsage();
    _section = nextSection;
    await _sendHeartbeat();
  }

  String _validSection(String value) =>
      const ['Accueil', 'Radio', 'TV', 'Bouquet'].contains(value) ? value : 'Accueil';

  Future<String> _getInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('ngombi_audience_installation_id');
    if (id == null || id.isEmpty) {
      final random = Random.secure();
      String hex(int n) => n.toRadixString(16).padLeft(2, '0');
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      final raw = bytes.map(hex).join();
      id = '${raw.substring(0, 8)}-${raw.substring(8, 12)}-${raw.substring(12, 16)}-${raw.substring(16, 20)}-${raw.substring(20)}';
      await prefs.setString('ngombi_audience_installation_id', id);
    }
    return id;
  }

  Future<void> _loadNetworkBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    final counters = await _readNetworkBytes();
    if (counters == null) return;
    final savedRx = prefs.getInt('ngombi_usage_rx_bytes');
    final savedTx = prefs.getInt('ngombi_usage_tx_bytes');
    _lastRxBytes = savedRx != null && counters.rx >= savedRx ? savedRx : counters.rx;
    _lastTxBytes = savedTx != null && counters.tx >= savedTx ? savedTx : counters.tx;
    await prefs.setInt('ngombi_usage_rx_bytes', _lastRxBytes!);
    await prefs.setInt('ngombi_usage_tx_bytes', _lastTxBytes!);
  }

  Future<({int rx, int tx})?> _readNetworkBytes() async {
    try {
      final result = await _usageChannel.invokeMapMethod<String, dynamic>('getAppNetworkBytes');
      final rx = result?['rxBytes'];
      final tx = result?['txBytes'];
      if (rx is num && tx is num && rx >= 0 && tx >= 0) {
        return (rx: rx.toInt(), tx: tx.toInt());
      }
    } catch (_) {
      // Unsupported platforms or unavailable OS counters are intentionally ignored.
    }
    return null;
  }

  Future<void> _flushUsage() async {
    if (!_started || !_foreground || _sampleInProgress) return;
    final id = _installationId;
    final now = DateTime.now();
    final previous = _lastUsageSampleAt ?? now;
    final seconds = now.difference(previous).inSeconds.clamp(0, 300).toInt();
    _lastUsageSampleAt = now;
    if (id == null) return;

    _sampleInProgress = true;
    try {
      var dataBytes = 0;
      final counters = await _readNetworkBytes();
      if (counters != null) {
        if (_lastRxBytes != null && _lastTxBytes != null &&
            counters.rx >= _lastRxBytes! && counters.tx >= _lastTxBytes!) {
          dataBytes = (counters.rx - _lastRxBytes!) + (counters.tx - _lastTxBytes!);
        }
        _lastRxBytes = counters.rx;
        _lastTxBytes = counters.tx;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('ngombi_usage_rx_bytes', counters.rx);
        await prefs.setInt('ngombi_usage_tx_bytes', counters.tx);
      }

      if (seconds == 0 && dataBytes == 0) return;
      await Supabase.instance.client.rpc('ngombi_usage_record', params: {
        'p_installation_id': id,
        'p_section': _section,
        'p_active_seconds': seconds,
        'p_data_bytes': dataBytes,
      });
    } catch (_) {
      // Telemetry failures must never interrupt playback or app startup.
    } finally {
      _sampleInProgress = false;
    }
  }

  Future<void> _sendHeartbeat() async {
    try {
      final id = _installationId;
      if (id == null) return;
      await Supabase.instance.client.rpc('ngombi_audience_heartbeat', params: {
        'p_installation_id': id,
        'p_section': _section,
      });
    } catch (_) {
      // Analytics must never block playback or app startup.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _lastUsageSampleAt = DateTime.now();
      unawaited(_loadNetworkBaseline());
      unawaited(_sendHeartbeat());
      _timer ??= Timer.periodic(const Duration(minutes: 1), (_) {
        unawaited(_flushUsage());
        unawaited(_sendHeartbeat());
      });
    } else {
      // Flush the final foreground interval before pausing telemetry.
      unawaited(_flushUsage());
      _foreground = false;
      _lastUsageSampleAt = null;
      _timer?.cancel();
      _timer = null;
    }
  }

  void dispose() {
    unawaited(_flushUsage());
    _foreground = false;
    _timer?.cancel();
    _timer = null;
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }
}
