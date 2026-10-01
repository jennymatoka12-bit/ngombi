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

  bool get _isOfficialGabonWebPlayer {
    return _isGabon24 || _isGabonPremiere;
  }

  String get _officialWebUrl {
    if (_isGabon24) {
      return 'https://gabon24.tv/direct';
    }

    return 'https://gabontelevisions.ga/';
  }

  @override
  void initState() {
    super.initState();

    if (_isOfficialGabonWebPlayer) {
      _initializeOfficialGabonPlayer();
      return;
    }

    if (widget.channel.type == StreamType.dash) {
      _openNativeDashPlayer();
    } else {
      _initializeFlutterPlayer();
    }
  }

  // ============================================================
  // GABON 24 / GABON PREMIÈRE — LECTEUR OFFICIEL
  // ============================================================

  void _initializeOfficialGabonPlayer() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(
          JavaScriptMode.unrestricted,
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
            onPageFinished: (String url) {
              if (!mounted) return;

              setState(() {
                _webLoading = false;
              });
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
          ),
        )
        ..loadRequest(
          Uri.parse(_officialWebUrl),
        );

      _webController = controller;
    } catch (error) {
      _errorMessage = error.toString();
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
      final controller =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
        httpHeaders: widget.channel.headers,
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _initialized = true;
      });

      await controller.play();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
          if (_isOfficialGabonWebPlayer &&
              _webController != null)
            IconButton(
              tooltip: 'Actualiser',
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed: () {
                _webController?.reload();
              },
            ),
        ],
      ),
      body: _isOfficialGabonWebPlayer
          ? _buildOfficialGabonPlayer()
          : Center(
              child: _buildPlayer(),
            ),
    );
  }

  // ============================================================
  // WEBVIEW GABON
  // ============================================================

  Widget _buildOfficialGabonPlayer() {
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

    return SafeArea(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio:
                controller.value.aspectRatio > 0
                    ? controller.value.aspectRatio
                    : 16 / 9,
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
  // ERREUR
  // ============================================================

  Widget _buildError() {
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
              _errorMessage!,
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
