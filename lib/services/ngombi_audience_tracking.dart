import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal, pseudonymous audience telemetry. No hardware identifiers are read.
class NgombiAudienceTracking with WidgetsBindingObserver {
  NgombiAudienceTracking._();
  static final NgombiAudienceTracking instance = NgombiAudienceTracking._();

  Timer? _timer;
  String? _installationId;
  String _section = 'Accueil';
  bool _started = false;

  Future<void> start(String section) async {
    _section = _validSection(section);
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addObserver(this);
      _installationId = await _getInstallationId();
    }
    await _sendHeartbeat();
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) => _sendHeartbeat());
  }

  void setSection(String section) {
    _section = _validSection(section);
    if (_started) unawaited(_sendHeartbeat());
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

  Future<void> _sendHeartbeat() async {
    try {
      final id = _installationId;
      // The heartbeat RPC accepts only an installation UUID and a whitelisted section.
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
      unawaited(_sendHeartbeat());
      _timer ??= Timer.periodic(const Duration(minutes: 1), (_) => _sendHeartbeat());
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }
}
