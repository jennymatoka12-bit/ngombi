import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/tv_channel.dart';

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

class _StreamPlayerScreenState
    extends State<StreamPlayerScreen> {
  static const MethodChannel _nativePlayer =
      MethodChannel('ngombi/player');

  VideoPlayerController? _controller;
  WebViewController? _webController;

  Player? _windowsPlayer;
  VideoController? _windowsVideoController;
  StreamSubscription<String>? _windowsErrorSubscription;

  bool _initialized = false;
  bool _webLoading = true;
  String? _errorMessage;

  bool get _isWindows =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows;

  bool get _isGabon24 {
    final name = widget.channel.name.toLowerCase();

    return name.contains('gabon 24') ||
        name.contains('gabon24');
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

  bool get _isOfficialWebPlayer {
    return _isGabon24 ||
        _isGabonPremiere ||
        _isCRTV ||
        _isNCI ||
        _is2STV;
  }

  String get _officialWebUrl {
    if (_isGabon24) {
      return 'https://gabon24.tv/direct';
    }

    if (_isGabonPremiere) {
      return 'https://gabontelevisions.ga/';
    }

    if (_isCRTV) {
      return 'https://www.crtv.cm/live/crtv';
    }

    if (_isNCI) {
      return 'https://www.nci.ci/';
    }

    if (_is2STV) {
      return 'https://www.2stv.net/';
    }

    return widget.channel.url;
  }

  @override
  void initState() {
    super.initState();

    if (_isOfficialWebPlayer) {
      if (_isWindows) {
        _webLoading = false;
      } else {
        _initializeOfficialWebPlayer();
      }
      return;
    }

    if (_isWindows) {
      _initializeWindowsPlayer();
      return;
    }

    if (widget.channel.type == StreamType.dash) {
      _openNativeDashPlayer();
    } else {
      _initializeFlutterPlayer();
    }
  }

  void _initializeOfficialWebPlayer() {
    try {
      late final WebViewController controller;

      controller = WebViewController()
        ..setJavaScriptMode(
          JavaScriptMode.unrestricted,
        )
        ..setBackgroundColor(
          Colors.black,
        )
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
                      var videos = document.querySelectorAll('video');

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
                } catch (_) {
                  // Le site reste utilisable avec une interaction utilisateur.
                }
              }
            },
            onWebResourceError: (
              WebResourceError error,
            ) {
              if (!mounted) return;

              if (error.isForMainFrame == true) {
                setState(() {
                  _webLoading = false;
                  _errorMessage = error.description;
                });
              }
            },
            onNavigationRequest: (
              NavigationRequest request,
            ) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(
          Uri.parse(_officialWebUrl),
        );

      _webController = controller;
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _webLoading = false;
      });
    }
  }

  Future<void> _openOfficialWebsiteOnWindows() async {
    final uri = Uri.parse(_officialWebUrl);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      setState(() {
        _errorMessage =
            'Impossible d’ouvrir le lecteur officiel dans le navigateur.';
      });
    }
  }

  Future<void> _openNativeDashPlayer() async {
    try {
      await _nativePlayer.invokeMethod(
        'playDash',
        {
          'url': widget.channel.url,
          'userAgent':
              widget.channel.headers['User-Agent'] ??
                  'Mozilla/5.0',
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PlatformException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<String> _resolveWindowsStreamUrl() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..autoUncompress = false;

    try {
      var uri = Uri.parse(widget.channel.url);

      for (var attempt = 0; attempt < 5; attempt++) {
        final request = await client.getUrl(uri);
        request.followRedirects = false;

        widget.channel.headers.forEach((key, value) {
          request.headers.set(key, value);
        });

        if (!request.headers.value(HttpHeaders.acceptHeader).isNotEmpty) {
          request.headers.set(
            HttpHeaders.acceptHeader,
            'application/vnd.apple.mpegurl, application/x-mpegURL, */*',
          );
        }

        final response = await request.close();
        final status = response.statusCode;

        if (status >= 300 && status < 400) {
          final location = response.headers.value(HttpHeaders.locationHeader);

          if (location == null || location.isEmpty) {
            throw HttpException(
              'Redirection HLS reçue sans adresse de destination.',
              uri: uri,
            );
          }

          uri = uri.resolve(location);
          await response.drain<void>();
          continue;
        }

        if (status >= 200 && status < 300) {
          await response.drain<void>();
          return uri.toString();
        }

        await response.drain<void>();
        throw HttpException(
          'Le serveur HLS a répondu HTTP $status.',
          uri: uri,
        );
      }

      throw TimeoutException(
        'Trop de redirections lors de la résolution du flux HLS.',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _initializeWindowsPlayer() async {
    try {
      final resolvedUrl = await _resolveWindowsStreamUrl();

      if (!mounted) return;

      final player = Player();
      final videoController = VideoController(player);

      _windowsPlayer = player;
      _windowsVideoController = videoController;

      _windowsErrorSubscription =
          player.stream.error.listen((message) {
        if (!mounted || message.trim().isEmpty) {
          return;
        }

        setState(() {
          _errorMessage = message;
        });
      });

      await player
          .open(
            Media(
              resolvedUrl,
              httpHeaders: widget.channel.headers,
            ),
            play: true,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Délai de connexion au flux dépassé.',
              );
            },
          );

      if (!mounted) {
        await player.dispose();
        return;
      }

      setState(() {
        _initialized = true;
        _errorMessage = null;
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
      final playerController =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: widget.channel.headers,
      );

      _controller = playerController;

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
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _windowsErrorSubscription?.cancel();
    _windowsPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.channel.name,
        ),
        actions: [
          if (_isOfficialWebPlayer &&
              !_isWindows &&
              _webController != null)
            IconButton(
              tooltip: 'Actualiser',
              icon: const Icon(
                Icons.refresh,
              ),
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
          : Center(
              child: _buildPlayer(),
            ),
    );
  }

  Widget _buildOfficialWebPlayer() {
    if (_isWindows) {
      return _buildWindowsOfficialLink();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_webController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _webController!,
        ),
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
      ],
    );
  }

  Widget _buildWindowsOfficialLink() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.open_in_browser_rounded,
              size: 64,
              color: Color(0xFFFFA21A),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cette chaîne utilise son lecteur web officiel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sous Windows, NGOMBI ouvre ce lecteur dans le navigateur afin d’éviter un écran blanc ou noir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _openOfficialWebsiteOnWindows,
              icon: const Icon(
                Icons.open_in_new_rounded,
              ),
              label: const Text(
                'Ouvrir le direct officiel',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_errorMessage != null) {
      return _buildError();
    }

    if (!_initialized) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Connexion au flux…',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_isWindows) {
      final windowsController =
          _windowsVideoController;

      if (windowsController == null) {
        return _buildErrorWithMessage(
          'Le lecteur Windows n’a pas pu être initialisé.',
        );
      }

      return SafeArea(
        child: SizedBox.expand(
          child: Video(
            controller: windowsController,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    final controller = _controller;

    if (controller == null) {
      return _buildErrorWithMessage(
        'Le lecteur vidéo n’a pas pu être initialisé.',
      );
    }

    final aspectRatio =
        controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9;

    return SafeArea(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(
              controller,
            ),
          ),
          const SizedBox(height: 12),
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          IconButton(
            color: Colors.white,
            iconSize: 40,
            icon: Icon(
              controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
            ),
            onPressed: () {
              setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              });
            },
          ),
          Text(
            '${widget.channel.category} • '
            '${_streamTypeLabel(widget.channel.type)}',
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWithMessage(
    String message,
  ) {
    _errorMessage = message;
    return _buildError();
  }

  Widget _buildError() {
    final message =
        _errorMessage ??
            'Une erreur inconnue est survenue.';

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
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
              label: const Text(
                'Retour',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _streamTypeLabel(
    StreamType type,
  ) {
    switch (type) {
      case StreamType.hls:
        return 'HLS';

      case StreamType.dash:
        return 'DASH';

      case StreamType.unknown:
        return 'Flux';
    }
  }
}
