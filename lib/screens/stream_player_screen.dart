import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vlc_player/vlc_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/tv_channel.dart';
import '../services/epg_service.dart';

class StreamPlayerScreen extends StatefulWidget {
  final TvChannel channel;

  const StreamPlayerScreen({
    super.key,
    required this.channel,
  });

  @override
  State<StreamPlayerScreen> createState() =>
      _StreamPlayerScreenState();
}

class _StreamPlayerScreenState extends State<StreamPlayerScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _nativePlayer =
      MethodChannel('ngombi/player');

  VideoPlayerController? _controller;
  VlcPlayerController? _vlcController;
  bool _useVlcFallback = false;
  WebViewController? _webController;
  Process? _windowsWebViewProcess;
  StreamSubscription<String>? _windowsWebViewStdout;
  StreamSubscription<String>? _windowsWebViewStderr;
  bool _windowsWebViewActive = false;
  bool _windowsWebViewFallbackStarted = false;

  bool _initialized = false;
  bool _webLoading = true;
  bool _showControls = true;
  bool _orientationInitialized = false;
  bool _initialLandscape = false;
  bool _isLandscape = false;
  bool _isFullscreen = false;
  String? _errorMessage;

  EpgProgram? _currentProgram;
  EpgProgram? _nextProgram;
  Timer? _hideControlsTimer;
  Timer? _epgRefreshTimer;
  Timer? _playbackWatchdogTimer;
  Duration _lastObservedPosition = Duration.zero;
  int _stalledPlaybackChecks = 0;

  bool get _isGabon24 {
    final name = widget.channel.name.toLowerCase();
    return name.contains('gabon 24') || name.contains('gabon24');
  }

  bool get _isGabonPremiere {
    final name = widget.channel.name.toLowerCase();
    return name.contains('gabon 1ere') ||
        name.contains('gabon 1ère') ||
        name.contains('gabon premiere') ||
        name.contains('gabon première');
  }

  bool get _isCRTV {
    final name = widget.channel.name.toLowerCase();
    return name == 'crtv' ||
        name.contains('crtv cameroun') ||
        name.contains('cameroon radio television') ||
        name.startsWith('crtv ');
  }

  bool get _isNCI {
    final name = widget.channel.name.toLowerCase();
    return name == 'nci' ||
        name.startsWith('nci ') ||
        name.contains('nci côte d’ivoire') ||
        name.contains("nci cote d'ivoire") ||
        name.contains('nouvelle chaîne ivoirienne');
  }

  bool get _is2STV {
    final name = widget.channel.name.toLowerCase();
    return name == '2stv' ||
        name.startsWith('2stv ') ||
        name.contains('2stv sénégal') ||
        name.contains('2stv senegal');
  }

  // Encrypted DASH streams can hang or crash the generic Windows decoder.
  // Until licensed DRM playback is integrated, fail safely and offer the
  // broadcaster portal rather than attempting native decoding.
  bool get _isWindowsProtectedDash =>
      Platform.isWindows &&
      widget.channel.url.toLowerCase().contains('cmaf_cenc00');

  bool get _isWindowsTvRadioZapHls {
    if (!Platform.isWindows || widget.channel.type != StreamType.hls) {
      return false;
    }
    final uri = Uri.tryParse(widget.channel.url);
    final host = uri?.host.toLowerCase() ?? '';
    return uri != null &&
        uri.scheme == 'https' &&
        (host == 'tvradiozap.eu' || host.endsWith('.tvradiozap.eu'));
  }

  bool get _isOfficialWebPlayer =>
      _isGabon24 ||
      _isGabonPremiere ||
      _isCRTV ||
      _isNCI ||
      _is2STV;

  String get _officialWebUrl {
    if (_isGabon24) return 'https://gabon24.tv/direct';
    if (_isGabonPremiere) return 'https://gabontelevisions.ga/';
    if (_isCRTV) return 'https://www.crtv.cm/live/crtv';
    if (_isNCI) return 'https://www.nci.ci/';
    return 'https://www.2stv.net/';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // A TV/video player must keep the display awake while this screen is
    // active. The native MethodChannel is retained for compatibility, while
    // wakelock_plus provides a reliable Flutter-side Android implementation.
    unawaited(_setKeepScreenOn(true));

    // Load the EPG independently from video initialization so the
    // current/next programme is ready as soon as the controls are opened.
    unawaited(_loadEpg());
    _epgRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_loadEpg()),
    );

    if (_isOfficialWebPlayer) {
      _initializeOfficialWebPlayer();
      return;
    }

    if (_isWindowsProtectedDash) {
      // Give LibVLC a chance to open the stream before falling back to the
      // broadcaster portal. VLC cannot bypass DRM, but can handle more DASH variants.
      _startVlcFallback();
      return;
    }

    if (_isWindowsTvRadioZapHls) {
      unawaited(_launchWindowsWebViewPlayer());
      return;
    }

    // On Windows, route HLS, DASH and direct media through the MediaKit-backed
    // video_player implementation. The old MethodChannel DASH path is Android-only.
    if (widget.channel.type == StreamType.dash && !Platform.isWindows) {
      _openNativeDashPlayer();
    } else {
      _initializeFlutterPlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_orientationInitialized) return;

    _orientationInitialized = true;
    _initialLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    _isLandscape = _initialLandscape;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_setKeepScreenOn(true));
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_setKeepScreenOn(false));
    }
  }

  Future<void> _toggleOrientation() async {
    final targetLandscape = !_isLandscape;
    final targetFullscreen = !_isFullscreen;

    try {
      if (Platform.isWindows) {
        // Windows desktop has no device orientation; use real borderless
        // fullscreen so the taskbar is hidden along with the title bar.
        await windowManager.setFullScreen(targetFullscreen);
      }
      await SystemChrome.setPreferredOrientations(
        targetLandscape
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ],
      );

      await SystemChrome.setEnabledSystemUIMode(
        targetLandscape
            ? SystemUiMode.immersiveSticky
            : SystemUiMode.edgeToEdge,
      );

      if (!mounted) return;

      setState(() {
        if (Platform.isWindows) {
          _isFullscreen = targetFullscreen;
          _isLandscape = true;
        } else {
          _isLandscape = targetLandscape;
        }
        _showControls = true;
      });

      _scheduleControlsHide();
    } catch (_) {}
  }

  Future<void> _restoreOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations(
        _initialLandscape
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ],
      );

      await SystemChrome.setEnabledSystemUIMode(
        _initialLandscape
            ? SystemUiMode.immersiveSticky
            : SystemUiMode.edgeToEdge,
      );
      if (Platform.isWindows) {
        await windowManager.setFullScreen(false);
      if (mounted) setState(() => _isFullscreen = false);
      }
    } catch (_) {}
  }

  void _toggleControls() {
    if (!mounted) return;

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      unawaited(_loadEpg());
      _scheduleControlsHide();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _scheduleControlsHide() {
    _hideControlsTimer?.cancel();

    _hideControlsTimer = Timer(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        setState(() {
          _showControls = false;
        });
      },
    );
  }

  Future<void> _loadEpg() async {
    try {
      final results = await Future.wait<EpgProgram?>([
        EpgService.current(widget.channel.name)
            .timeout(const Duration(seconds: 8)),
        EpgService.upcoming(widget.channel.name)
            .timeout(const Duration(seconds: 8)),
      ]);

      if (!mounted) return;

      setState(() {
        _currentProgram = results[0];
        _nextProgram = results[1];
      });
    } catch (_) {
      // Keep the last valid EPG data instead of clearing the programme
      // just because a single refresh request timed out.
    }
  }

  Future<void> _launchWindowsWebViewPlayer() async {
    final appDirectory = File(Platform.resolvedExecutable).parent;
    final playerDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}webview_player',
    );
    final playerExecutable = File(
      '${playerDirectory.path}${Platform.pathSeparator}ngombi_windows_tv_webview_poc.exe',
    );

    if (!await playerExecutable.exists()) {
      if (mounted) _initializeFlutterPlayer();
      return;
    }

    try {
      final process = await Process.start(
        playerExecutable.path,
        [widget.channel.url],
        workingDirectory: playerDirectory.path,
      );
      if (!mounted) {
        process.kill();
        return;
      }

      _windowsWebViewProcess = process;
      _windowsWebViewFallbackStarted = false;
      setState(() {
        _windowsWebViewActive = true;
        _errorMessage = null;
      });

      _windowsWebViewStdout = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('NGOMBI_WEBVIEW_FATAL:')) {
          _fallbackFromWindowsWebView(line);
        }
      });
      _windowsWebViewStderr = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[NGOMBI WebView2] $line'));

      unawaited(process.exitCode.then((exitCode) {
        if (!mounted || !identical(_windowsWebViewProcess, process)) return;
        if (exitCode != 0) {
          _fallbackFromWindowsWebView(
            'Le lecteur WebView2 s’est arrêté avec le code $exitCode.',
          );
          return;
        }

        _windowsWebViewProcess = null;
        _windowsWebViewActive = false;
        unawaited(_windowsWebViewStdout?.cancel());
        unawaited(_windowsWebViewStderr?.cancel());
        _windowsWebViewStdout = null;
        _windowsWebViewStderr = null;
        if (mounted) Navigator.of(context).maybePop();
      }));
    } catch (error) {
      if (!mounted) return;
      debugPrint('[NGOMBI WebView2] Impossible de lancer le lecteur : $error');
      _initializeFlutterPlayer();
    }
  }

  void _fallbackFromWindowsWebView(String reason) {
    if (!mounted || !_windowsWebViewActive || _windowsWebViewFallbackStarted) {
      return;
    }
    _windowsWebViewFallbackStarted = true;
    _windowsWebViewActive = false;

    final process = _windowsWebViewProcess;
    _windowsWebViewProcess = null;
    unawaited(_windowsWebViewStdout?.cancel());
    unawaited(_windowsWebViewStderr?.cancel());
    _windowsWebViewStdout = null;
    _windowsWebViewStderr = null;
    process?.kill();

    setState(() {
      _errorMessage = null;
    });
    debugPrint('[NGOMBI WebView2] Bascule vers MediaKit/VLC : $reason');
    unawaited(_initializeFlutterPlayer());
  }

  void _closeWindowsWebViewAndReturn() {
    final process = _windowsWebViewProcess;
    _windowsWebViewProcess = null;
    _windowsWebViewActive = false;
    unawaited(_windowsWebViewStdout?.cancel());
    unawaited(_windowsWebViewStderr?.cancel());
    _windowsWebViewStdout = null;
    _windowsWebViewStderr = null;
    process?.kill();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _initializeOfficialWebPlayer() {
    try {
      late final WebViewController controller;

      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) '
          'AppleWebKit/537.36 '
          '(KHTML, like Gecko) '
          'Chrome/120.0.0.0 '
          'Mobile Safari/537.36',
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (!mounted) return;

              setState(() {
                _webLoading = true;
                _errorMessage = null;
              });
            },
            onPageFinished: (String url) async {
              if (!mounted) return;

              setState(() {
                _webLoading = false;
              });

              if (_is2STV) {
                try {
                  await controller.runJavaScript(
                    '''
                    (function() {
                      var videos =
                          document.querySelectorAll('video');

                      videos.forEach(function(video) {
                        video.muted = false;

                        var promise = video.play();

                        if (promise !== undefined) {
                          promise.catch(function() {});
                        }
                      });
                    })();
                    ''',
                  );
                } catch (_) {}
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (!mounted) return;

              if (error.isForMainFrame == true) {
                setState(() {
                  _webLoading = false;
                  _errorMessage = error.description;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_officialWebUrl));

      _webController = controller;
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _webLoading = false;
      });
    }
  }

  Future<void> _openNativeDashPlayer() async {
    EpgProgram? program;

    try {
      program = await EpgService.current(widget.channel.name)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      program = null;
    }

    try {
      await _nativePlayer.invokeMethod(
        'playDash',
        {
          'url': widget.channel.url,
          'userAgent':
              widget.channel.headers['User-Agent'] ?? 'Mozilla/5.0',
          'channelName': widget.channel.name,
          'programTitle': program?.title,
          'programStartMs':
              program?.start.millisecondsSinceEpoch,
          'programEndMs':
              program?.end.millisecondsSinceEpoch,
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PlatformException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _initializeFlutterPlayer() async {
    final playerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.channel.url),
      httpHeaders: widget.channel.headers,
    );

    _controller = playerController;
    playerController.addListener(_onPlayerChanged);

    try {
      // A timed-out initialize() may still complete underneath the timeout.
      // Dispose the failed native player and detach it from the screen so a
      // later channel selection cannot inherit stale MediaKit resources.
      // Do not leave a channel spinning indefinitely in the primary engine.
      // If MediaKit has not initialized after 12 seconds, hand the same URL
      // and headers to VLC, which often supports additional stream variants.
      // This is a player switch, not a message telling the user to retry.
      await playerController.initialize().timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Le lecteur principal met trop de temps à ouvrir le flux ; tentative automatique avec VLC.',
        ),
      );

      if (!mounted || !identical(_controller, playerController)) {
        playerController.removeListener(_onPlayerChanged);
        await playerController.dispose();
        return;
      }

      setState(() {
        _initialized = true;
        _errorMessage = null;
      });

      // Keep playback initialization separate from cleanup/error handling:
      // a volume/play failure must not leave a half-initialized controller.
      await playerController.setVolume(1.0);
      await playerController.play();
      if (Platform.isWindows) {
        _lastObservedPosition = playerController.value.position;
        _stalledPlaybackChecks = 0;
        _playbackWatchdogTimer?.cancel();
        _playbackWatchdogTimer = Timer.periodic(
          const Duration(seconds: 8),
          (_) => _checkWindowsPlaybackHealth(playerController),
        );
      }
      _scheduleControlsHide();
      unawaited(_loadEpg());
    } catch (error) {
      playerController.removeListener(_onPlayerChanged);
      if (identical(_controller, playerController)) {
        _controller = null;
      }
      try {
        await playerController.dispose();
      } catch (_) {}

      if (!mounted) return;
      if (Platform.isWindows) {
        _startVlcFallback(errorMessage: error.toString());
      } else {
        setState(() {
          _initialized = false;
          _errorMessage = error.toString();
        });
      }
    }
  }

  void _checkWindowsPlaybackHealth(VideoPlayerController controller) {
    if (!Platform.isWindows ||
        !mounted ||
        _useVlcFallback ||
        !identical(_controller, controller)) {
      _playbackWatchdogTimer?.cancel();
      return;
    }

    final value = controller.value;
    if (!value.isInitialized) {
      return;
    }

    if (value.hasError) {
      _startVlcFallback(
        errorMessage: value.errorDescription ??
            'Le lecteur Windows a signalé une erreur de lecture.',
      );
      return;
    }

    if (!value.isPlaying) {
      _stalledPlaybackChecks++;
      if (_stalledPlaybackChecks >= 3) {
        _startVlcFallback(
          errorMessage:
              'Le flux ne démarre pas dans le lecteur Windows ; tentative avec VLC.',
        );
      }
      return;
    }

    final position = value.position;
    if (position > _lastObservedPosition) {
      _lastObservedPosition = position;
      _stalledPlaybackChecks = 0;
      return;
    }

    _stalledPlaybackChecks++;
    // A live stream should advance even when its duration is unknown. Three
    // consecutive checks with no position movement indicate that the primary
    // Windows backend has stalled; hand the same URL and headers to VLC.
    if (_stalledPlaybackChecks >= 3) {
      _startVlcFallback(
        errorMessage: 'Lecture Windows bloquée : bascule automatique vers VLC.',
      );
    }
  }

  void _startVlcFallback({String? errorMessage}) {
    if (!Platform.isWindows || !mounted) {
      if (mounted) {
        setState(() => _errorMessage = errorMessage ?? 'Impossible de démarrer le lecteur VLC.');
      }
      return;
    }

    try {
      _playbackWatchdogTimer?.cancel();
      final oldVideoController = _controller;
      _controller = null;
      if (oldVideoController != null) {
        oldVideoController.removeListener(_onPlayerChanged);
        unawaited(oldVideoController.dispose());
      }
      final oldController = _vlcController;
      final controller = VlcPlayerController(
        mediaSource: VlcMediaSource(
          uri: Uri.parse(widget.channel.url),
          httpHeaders: widget.channel.headers,
          mediaOptions: const <String>[':network-caching=1500'],
        ),
        autoPlay: true,
      );
      _vlcController = controller;
      oldController?.dispose();
      setState(() {
        _useVlcFallback = true;
        _initialized = false;
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Le lecteur principal a échoué et VLC n’a pas pu démarrer : $error';
      });
    }
  }

  void _onPlayerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _hasFiniteDuration {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return false;
    }

    final duration = controller.value.duration;
    return duration > Duration.zero &&
        duration != const Duration(days: 365);
  }

  String _formatDuration(Duration value) {
    final totalSeconds = value.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _setKeepScreenOn(bool enabled) async {
    // Android uses the existing native channel. On Windows, wakelock_plus
    // prevents the display/system from sleeping while a TV player is open.
    if (Platform.isWindows) {
      try {
        if (enabled) {
          await WakelockPlus.enable();
        } else {
          await WakelockPlus.disable();
        }
      } catch (_) {}
      return;
    }

    try {
      await _nativePlayer.invokeMethod(
        'setKeepScreenOn',
        {'enabled': enabled},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _epgRefreshTimer?.cancel();
    _playbackWatchdogTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setKeepScreenOn(false));
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    _vlcController?.dispose();
    _windowsWebViewProcess?.kill();
    unawaited(_windowsWebViewStdout?.cancel());
    unawaited(_windowsWebViewStderr?.cancel());
    unawaited(_restoreOrientation());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isLandscape
          ? null
          : AppBar(
              title: Text(widget.channel.name),
              actions: [
                IconButton(
                  tooltip: _isLandscape
                      ? 'Mode portrait'
                      : 'Mode paysage',
                  icon: Icon(
                    _isLandscape
                        ? Icons.stay_current_portrait_rounded
                        : Icons.stay_current_landscape_rounded,
                  ),
                  onPressed: _toggleOrientation,
                ),
                if (_isOfficialWebPlayer && _webController != null)
                  IconButton(
                    tooltip: 'Actualiser',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _webLoading = true;
                        _errorMessage = null;
                      });
                      _webController?.reload();
                    },
                  ),
              ],
            ),
      body: _isOfficialWebPlayer
          ? _buildOfficialWebPlayer()
          : _windowsWebViewActive
              ? _buildWindowsWebViewStatus()
              : Center(child: _buildPlayer()),
    );
  }

  Widget _buildWindowsWebViewStatus() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new_rounded, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Le lecteur WebView2 de ${widget.channel.name} est ouvert dans sa fenêtre.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _fallbackFromWindowsWebView(
                'Bascule demandée depuis NGOMBI.',
              ),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Utiliser le lecteur de secours'),
            ),
            TextButton(
              onPressed: _closeWindowsWebViewAndReturn,
              child: const Text('Fermer le lecteur et revenir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialWebPlayer() {
    if (_errorMessage != null) return _buildError();

    if (_webController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webController!),
        if (_webLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement du direct…',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isLandscape)
          Positioned(
            top: 12,
            right: 12,
            child: _overlayButton(
              icon: Platform.isWindows
                  ? (_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen)
                  : Icons.stay_current_portrait_rounded,
              tooltip: Platform.isWindows
                  ? (_isFullscreen ? 'Quitter le plein écran' : 'Plein écran')
                  : 'Mode portrait',
              onPressed: _toggleOrientation,
            ),
          ),
      ],
    );
  }

  Widget _buildPlayer() {
    if (_useVlcFallback && _vlcController != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          VlcPlayer(
            controller: _vlcController!,
            backgroundColor: Colors.black,
            fit: VlcVideoFit.contain,
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _overlayButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Retour',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.channel.name} • Lecteur VLC',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                _overlayButton(
                  icon: Platform.isWindows
                      ? (_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen)
                      : (_isLandscape
                          ? Icons.stay_current_portrait_rounded
                          : Icons.stay_current_landscape_rounded),
                  tooltip: Platform.isWindows
                      ? (_isFullscreen ? 'Quitter le plein écran' : 'Plein écran')
                      : (_isLandscape ? 'Mode portrait' : 'Mode paysage'),
                  onPressed: _toggleOrientation,
                ),
              ],
            ),
          ),
          ValueListenableBuilder<VlcPlayerValue>(
            valueListenable: _vlcController!,
            builder: (context, value, child) {
              if (!value.hasError) return const SizedBox.shrink();
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Text(
                    'VLC ne peut pas lire ce flux. Il peut être indisponible ou protégé par DRM.\\n${value.errorDescription ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }
    if (_errorMessage != null) return _buildError();

    if (!_initialized || _controller == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Connexion au flux…',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    final controller = _controller!;
    final aspectRatio = controller.value.aspectRatio > 0
        ? controller.value.aspectRatio
        : 16 / 9;

    final content = _isLandscape
        ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1920,
                height: 1080,
                child: VideoPlayer(controller),
              ),
            ),
          )
        : Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: VideoPlayer(controller),
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (_showControls) _buildControls(controller),
        ],
      ),
    );
  }

  Widget _buildControls(VideoPlayerController controller) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    final playing = controller.value.isPlaying;
    final hasProgram = _currentProgram != null;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.72),
                    Colors.transparent,
                    Colors.black.withOpacity(0.88),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              _overlayButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Retour',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      hasProgram
                          ? _currentProgram!.title
                          : 'EN DIRECT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _overlayButton(
                icon: Platform.isWindows
                    ? (_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen)
                    : (_isLandscape
                        ? Icons.stay_current_portrait_rounded
                        : Icons.stay_current_landscape_rounded),
                tooltip: Platform.isWindows
                    ? (_isFullscreen ? 'Quitter le plein écran' : 'Plein écran')
                    : (_isLandscape ? 'Mode portrait' : 'Mode paysage'),
                onPressed: _toggleOrientation,
              ),
            ],
          ),
        ),
        Center(
          child: IconButton(
            iconSize: _isLandscape ? 72 : 62,
            color: Colors.white,
            onPressed: () {
              if (playing) {
                controller.pause();
              } else {
                controller.play();
              }
              _scheduleControlsHide();
            },
            icon: Icon(
              playing
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasProgram) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentProgram!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: _currentProgram!.duration.inMilliseconds > 0
                        ? (_currentProgram!.elapsed.inMilliseconds /
                                _currentProgram!.duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : null,
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 6),
                if (_nextProgram != null)
                  Text(
                    'Ensuite : ${_nextProgram!.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                const SizedBox(height: 6),
              ],
              if (_hasFiniteDuration)
                Row(
                  children: [
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatDuration(position)} / '
                      '${_formatDuration(duration)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(
                      Icons.live_tv_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Direct • lecture en temps réel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overlayButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.62),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        color: Colors.white,
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildError() {
    final message =
        _errorMessage ?? 'Une erreur inconnue est survenue.';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de lire ce flux',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            if (_isWindowsProtectedDash) ...[
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://www.m6.fr/');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Ouvrir le portail officiel'),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

