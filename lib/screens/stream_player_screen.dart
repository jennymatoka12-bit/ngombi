import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _initialized = false;
  bool _webLoading = true;
  String? _errorMessage;

  // ============================================================
  // GABON 24
  // ============================================================

  bool get _isGabon24 {
    final name = widget.channel.name.toLowerCase();

    return name.contains('gabon 24') ||
        name.contains('gabon24');
  }

  // ============================================================
  // GABON PREMIÈRE
  // ============================================================

  bool get _isGabonPremiere {
    final name = widget.channel.name.toLowerCase();

    return name.contains('gabon 1ere') ||
        name.contains('gabon 1ère') ||
        name.contains('gabon premiere') ||
        name.contains('gabon première');
  }

  // ============================================================
  // CRTV
  // ============================================================

  bool get _isCRTV {
    final name = widget.channel.name.toLowerCase();

    return name == 'crtv' ||
        name.contains('crtv cameroun') ||
        name.contains('cameroon radio television') ||
        name.startsWith('crtv ');
  }

  // ============================================================
  // NCI
  // ============================================================

  bool get _isNCI {
    final name = widget.channel.name.toLowerCase();

    return name == 'nci' ||
        name.startsWith('nci ') ||
        name.contains('nci côte d’ivoire') ||
        name.contains("nci cote d'ivoire") ||
        name.contains('nouvelle chaîne ivoirienne');
  }

  // ============================================================
  // 2STV
  // ============================================================

  bool get _is2STV {
    final name = widget.channel.name.toLowerCase();

    return name == '2stv' ||
        name.startsWith('2stv ') ||
        name.contains('2stv sénégal') ||
        name.contains('2stv senegal');
  }

  // ============================================================
  // LECTEUR WEB OFFICIEL
  // ============================================================

  bool get _isOfficialWebPlayer {
    return _isGabon24 ||
        _isGabonPremiere ||
        _isCRTV ||
        _isNCI ||
        _is2STV;
  }

  // ============================================================
  // URL DU SITE OFFICIEL
  // ============================================================

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

    return 'https://www.2stv.net/';
  }

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

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

  // ============================================================
  // LECTEUR WEB OFFICIEL
  // ============================================================

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

              // --------------------------------------------------
              // Tentative de démarrage des lecteurs vidéo HTML5.
              //
              // Certains sites utilisent un élément <video>.
              // Cette commande ne contourne aucune protection :
              // elle demande simplement au navigateur de lancer
              // les lecteurs HTML5 déjà présents sur la page.
              // --------------------------------------------------

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
                } catch (_) {
                  // Certains lecteurs refusent le lancement
                  // automatique. Le site reste alors utilisable
                  // normalement avec une interaction utilisateur.
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
                  _errorMessage =
                      error.description;
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

  // ============================================================
  // DASH NATIF
  // ============================================================

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
        _errorMessage =
            error.toString();
      });
    }
  }

  // ============================================================
  // HLS / FLUX CLASSIQUE
  // ============================================================

  Future<void> _initializeFlutterPlayer() async {
    try {
      final playerController =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: widget.channel.headers,
      );

      _controller = playerController;

      // Sous Windows, certains serveurs HLS peuvent ne jamais terminer\n      // la phase d'initialisation. On évite de laisser l'écran bloqué\n      // indéfiniment ; Android conserve exactement son comportement actuel.\n      await playerController.initialize().timeout(\n        const Duration(seconds: 20),\n        onTimeout: () {\n          throw Exception(\n            'Délai de connexion au flux dépassé.',\n          );\n        },\n      );

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
        _errorMessage =
            error.toString();
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

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

  // ============================================================
  // WEBVIEW
  // ============================================================

  Widget _buildOfficialWebPlayer() {
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

  // ============================================================
  // LECTEUR CLASSIQUE
  // ============================================================

  Widget _buildPlayer() {
    if (_errorMessage != null) {
      return _buildError();
    }

    if (!_initialized ||
        _controller == null) {
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

    final controller = _controller!;

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
            padding:
                const EdgeInsets.symmetric(
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

  // ============================================================
  // MESSAGE D'ERREUR
  // ============================================================

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

  // ============================================================
  // TYPE DE FLUX
  // ============================================================

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
