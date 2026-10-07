import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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
  WebViewController? _webController;

  bool _initialized = false;
  bool _webLoading = true;
  bool _showControls = true;
  bool _orientationInitialized = false;
  bool _initialLandscape = false;
  bool _isLandscape = false;
  String? _errorMessage;

  EpgProgram? _currentProgram;
  EpgProgram? _nextProgram;
  Timer? _hideControlsTimer;

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

    if (_isOfficialWebPlayer) {
      _initializeOfficialWebPlayer();
      return;
    }

    if (widget.channel.type == StreamType.dash) {
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

    try {
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
        _isLandscape = targetLandscape;
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
    } catch (_) {}
  }

  void _toggleControls() {
    if (!mounted) return;

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
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
    final program = await EpgService.current(widget.channel.name);
    final next = await EpgService.upcoming(widget.channel.name);

    if (!mounted) return;

    setState(() {
      _currentProgram = program;
      _nextProgram = next;
    });
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
    try {
      final playerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: widget.channel.headers,
      );

      _controller = playerController;
      playerController.addListener(_onPlayerChanged);

      await playerController.initialize();

      if (!mounted) {
        playerController.dispose();
        return;
      }

      setState(() {
        _initialized = true;
        _errorMessage = null;
      });

      await playerController.play();
      _scheduleControlsHide();
      unawaited(_loadEpg());
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
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
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setKeepScreenOn(false));
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
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
          : Center(child: _buildPlayer()),
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
              icon: Icons.stay_current_portrait_rounded,
              tooltip: 'Mode portrait',
              onPressed: _toggleOrientation,
            ),
          ),
      ],
    );
  }

  Widget _buildPlayer() {
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
                icon: _isLandscape
                    ? Icons.stay_current_portrait_rounded
                    : Icons.stay_current_landscape_rounded,
                tooltip: _isLandscape
                    ? 'Mode portrait'
                    : 'Mode paysage',
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
