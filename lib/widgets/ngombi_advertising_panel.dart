import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../models/ngombi_ad.dart';
import 'ngombi_logo.dart';

class NgombiAdvertisingPanel extends StatefulWidget {
  final List<NgombiAd> ads;
  final double height;
  final bool isActive;

  const NgombiAdvertisingPanel({
    super.key,
    this.ads = const [],
    this.height = 190,
    this.isActive = true,
  });

  @override
  State<NgombiAdvertisingPanel> createState() =>
      _NgombiAdvertisingPanelState();
}

class _NgombiAdvertisingPanelState extends State<NgombiAdvertisingPanel>
    with WidgetsBindingObserver {
  int _index = 0;
  Timer? _timer;
  VideoPlayerController? _videoController;
  int _mediaGeneration = 0;
  bool _isAdvancing = false;
  bool _wasPlayingBeforeLifecycle = false;

  List<NgombiAd> get _activeAds {
    final items = widget.ads.where((ad) => ad.isScheduledActive).toList();
    items.sort((a, b) => b.priority.compareTo(a.priority));
    return items;
  }

  NgombiAd? get _currentAd {
    final ads = _activeAds;
    if (ads.isEmpty) return null;
    if (_index >= ads.length) _index = 0;
    return ads[_index];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareCurrentAd();
  }

  @override
  void didUpdateWidget(covariant NgombiAdvertisingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads) {
      _index = 0;
      if (widget.isActive) {
        _prepareCurrentAd();
      }
    }

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _resumePlayback();
      } else {
        _pausePlayback();
      }
    }
  }

  void _pausePlayback() {
    _timer?.cancel();
    _timer = null;
    final controller = _videoController;
    _wasPlayingBeforeLifecycle = controller?.value.isPlaying ?? false;
    controller?.pause();
  }

  void _resumePlayback() {
    if (!mounted || !widget.isActive) return;

    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      controller.play();
      return;
    }

    _prepareCurrentAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _wasPlayingBeforeLifecycle = _videoController?.value.isPlaying ?? false;
      _pausePlayback();
      return;
    }

    if (state == AppLifecycleState.resumed && widget.isActive) {
      // Keep the same controller/texture whenever possible. Recreating a
      // controller on every lifecycle transition can leave Android rendering
      // the first frame while the audio track continues.
      if (_videoController != null &&
          _videoController!.value.isInitialized) {
        if (_wasPlayingBeforeLifecycle) {
          _videoController!.play();
        }
      } else {
        _prepareCurrentAd();
      }
    }
  }

  Future<void> _prepareCurrentAd() async {
    if (!mounted || !widget.isActive) return;

    _timer?.cancel();
    _timer = null;
    final generation = ++_mediaGeneration;

    final ad = _currentAd;
    if (ad == null) {
      setState(() {});
      return;
    }

    if (ad.type == NgombiAdType.video) {
      final controller = ad.isRemoteMedia
          ? VideoPlayerController.networkUrl(Uri.parse(ad.media))
          : VideoPlayerController.asset(ad.media);

      try {
        // Important: initialize the next controller before destroying the
        // current one. This avoids rapid texture reuse on Android, which can
        // produce the exact "audio advances / video is frozen" symptom.
        await controller.initialize();
        await controller.setLooping(false);

        if (!mounted || !widget.isActive || generation != _mediaGeneration) {
          await controller.dispose();
          return;
        }

        final previousController = _videoController;
        _videoController = controller;

        controller.addListener(() {
          if (!mounted || generation != _mediaGeneration) return;
          final value = controller.value;

          if (value.hasError) {
            _advance();
            return;
          }

          if (value.isInitialized &&
              value.position >= value.duration &&
              !value.isPlaying) {
            _advance();
          }
        });

        setState(() {});

        await controller.play();
        _wasPlayingBeforeLifecycle = true;

        // Only dispose the previous player after the new texture is mounted
        // and playback has started.
        if (previousController != null && previousController != controller) {
          await previousController.pause();
          await previousController.dispose();
        }
      } catch (_) {
        await controller.dispose();
        if (generation == _mediaGeneration && mounted) {
          _advance();
        }
      }
      return;
    }

    final previousController = _videoController;
    _videoController = null;
    if (previousController != null) {
      await previousController.pause();
      await previousController.dispose();
    }

    if (!mounted || !widget.isActive || generation != _mediaGeneration) {
      return;
    }

    setState(() {});
    _timer = Timer(ad.duration, () {
      if (generation == _mediaGeneration && widget.isActive) {
        _advance();
      }
    });
  }

  void _advance() {
    if (!mounted || !widget.isActive || _isAdvancing) return;
    final ads = _activeAds;
    if (ads.isEmpty) return;

    _isAdvancing = true;
    _timer?.cancel();
    _timer = null;

    setState(() {
      _index = (_index + 1) % ads.length;
    });

    _prepareCurrentAd().whenComplete(() {
      _isAdvancing = false;
    });
  }

  Future<void> _openAd() async {
    final ad = _currentAd;
    if (ad == null || ad.clickUrl.trim().isEmpty) return;

    final uri = Uri.tryParse(ad.clickUrl.trim());
    if (uri == null) return;

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir le site de l’annonceur.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _mediaGeneration++;
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = _activeAds;
    final ad = _currentAd;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0x33FF8A00),
        ),
      ),
      child: ad == null
          ? _fallback()
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openAd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _media(ad),
                  const Positioned(
                    top: 10,
                    left: 12,
                    child: _AdBadge(),
                  ),
                  if (ads.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: _Indicators(
                        count: ads.length,
                        current: _index,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _media(NgombiAd ad) {
    if (ad.type == NgombiAdType.video) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return _loadingBackground();
      }

      // Keep the video texture mounted as a stable widget.
      // Rebuilding VideoPlayer on every decoder notification can cause
      // Android to keep displaying the first texture frame while audio
      // continues to advance. The controller itself updates the texture.
      final aspectRatio =
          controller.value.aspectRatio > 0
              ? controller.value.aspectRatio
              : 16 / 9;

      return Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    }

    return Container(
      color: const Color(0xFF111111),
      alignment: Alignment.center,
      child: Image.network(
        ad.media,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _loadingBackground();
      },
        errorBuilder: (_, __, ___) => _fallback(),
      ),
    );
  }

  Widget _loadingBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF241010),
            Color(0xFF111111),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _fallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF241010), Color(0xFF111111)],
            ),
          ),
        ),
        Positioned(
          left: 6,
          bottom: 20,
          child: Transform.flip(
            flipX: true,
            child: CustomPaint(
              size: const Size(105, 78),
              painter: _NgombiWavePainter(),
            ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 20,
          child: CustomPaint(
            size: const Size(105, 78),
            painter: _NgombiWavePainter(),
          ),
        ),
        const Center(child: NgombiLogo.full(height: 42)),
        const Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Text(
            'Le monde en direct • TV & Radio',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'PUBLICITÉ',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Indicators extends StatelessWidget {
  final int count;
  final int current;

  const _Indicators({
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == current ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == current ? const Color(0xFFFFA21A) : Colors.white38,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _NgombiWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x66FF7043);

    for (int i = 0; i < 7; i++) {
      final path = Path();
      final y = 35.0 + (i * 22);

      path.moveTo(10, y);
      path.cubicTo(
        size.width * 0.25,
        y - 25,
        size.width * 0.35,
        y + 25,
        size.width * 0.55,
        y,
      );
      path.cubicTo(
        size.width * 0.72,
        y - 22,
        size.width * 0.82,
        y + 22,
        size.width,
        y,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
