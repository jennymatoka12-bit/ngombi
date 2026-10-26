import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../main.dart' show WebPlayerScreen;

/// Uses native stream playback for known direct radio streams on Windows,
/// while leaving the existing Android WebView implementation unchanged.
class RadioPlatformScreen extends StatelessWidget {
  final String title;
  final String url;

  const RadioPlatformScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return WebPlayerScreen(title: title, url: url);
    }

    final normalizedTitle = title.toLowerCase();
    final directUrl = normalizedTitle.contains('skyrock')
        ? 'https://www.skyrock.fm/stream.php/mytuner_128mp3.mp3'
        : url;
    final uri = Uri.tryParse(directUrl);
    final isDirectStream = uri != null &&
        ((uri.host.toLowerCase() == 'studio.webradio.solutions' &&
                uri.path == '/stream') ||
            normalizedTitle.contains('skyrock'));

    if (isDirectStream) {
      return WindowsDirectRadioScreen(title: title, url: directUrl);
    }

    return WindowsWebsiteRadioScreen(title: title, url: url);
  }
}

class WindowsDirectRadioScreen extends StatefulWidget {
  final String title;
  final String url;

  const WindowsDirectRadioScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WindowsDirectRadioScreen> createState() =>
      _WindowsDirectRadioScreenState();
}

class _WindowsDirectRadioScreenState extends State<WindowsDirectRadioScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.addListener(_onChanged);
    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      await controller.setLooping(false);
      await controller.play();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _retry() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_onChanged);
      await old.dispose();
    }
    if (!mounted) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    await _initialize();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final playing = controller?.value.isPlaying ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radio_rounded, size: 88, color: Color(0xFFFFA21A)),
              const SizedBox(height: 18),
              Text(widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (_loading) const CircularProgressIndicator(),
              if (_error != null) ...[
                const Text('La lecture du flux radio a échoué.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
              if (!_loading && _error == null && controller != null &&
                  controller.value.isInitialized) ...[
                const Text('Flux audio connecté', style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 16),
                IconButton.filled(
                  iconSize: 42,
                  onPressed: () => playing ? controller.pause() : controller.play(),
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                Text(playing ? 'Lecture en cours' : 'Lecture en pause'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WindowsWebsiteRadioScreen extends StatelessWidget {
  final String title;
  final String url;

  const WindowsWebsiteRadioScreen({
    super.key,
    required this.title,
    required this.url,
  });

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir ce site dans le navigateur.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_in_browser_rounded,
                    size: 76, color: Color(0xFFFFA21A)),
                const SizedBox(height: 18),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text(
                  'Cette station utilise son propre portail web. Sur Windows, '
                  'ouvre-le dans le navigateur pour accéder à son lecteur intégré.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _openWebsite(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Ouvrir le portail dans le navigateur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
