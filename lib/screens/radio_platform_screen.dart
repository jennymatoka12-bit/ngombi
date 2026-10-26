import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../main.dart' show WebPlayerScreen;

/// Keeps the existing WebView-based radio experience on Android, while using
/// a Windows-compatible audio player for direct streams. Websites that embed
/// their own player open in the user's default browser on Windows because the
/// mobile webview_flutter controller is not supported by the Windows runner.
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

    final uri = Uri.tryParse(url);
    final isDirectStream = uri != null &&
        uri.host.toLowerCase() == 'studio.webradio.solutions' &&
        uri.path == '/stream';

    if (isDirectStream) {
      return WindowsDirectRadioScreen(title: title, url: url);
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
      await controller.initialize();
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
                  onPressed: () => setState(() {
                    _error = null;
                    _loading = true;
                    _controller?.dispose();
                    _controller = null;
                    _initialize();
                  }),
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
        const SnackBar(content: Text('Impossible d’ouvrir cette radio dans le navigateur.')),
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
                  'Cette station diffuse depuis son propre site web. '
                  'Sur Windows, NGOMBI ouvre ce site dans le navigateur par défaut '
                  'pour éviter un écran blanc.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _openWebsite(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Ouvrir la radio dans le navigateur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
