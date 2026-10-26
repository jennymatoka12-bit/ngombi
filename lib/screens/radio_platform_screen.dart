import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../main.dart' show WebPlayerScreen;

/// Windows uses native audio playback for known streams and attempts to
/// discover public audio playlist URLs embedded in station websites. Android
/// keeps the existing WebView implementation.
class RadioPlatformScreen extends StatelessWidget {
  final String title;
  final String url;

  const RadioPlatformScreen({
    super.key,
    required this.title,
    required this.url,
  });

  static const _urbanStream = 'https://studio.webradio.solutions:7013/stream';
  static const _directStreams = <String, String>{
    'skyrock': 'https://icecast.skyrock.net/s/natio_mp3_128k',
    'urban fm': _urbanStream,
    'urban fm 104.5': _urbanStream,
    'rfi afrique': 'https://live02.rfi.fr/rfiafrique-64.mp3',
    'rfi monde': 'https://live02.rfi.fr/rfimonde-64.mp3',
    'nostalgie': 'https://streaming.nrjaudio.fm/oug7girb92oc?origine=fluxradios',
    'trace fm': 'https://stream.rcs.revma.com/nv1hu7644k0uv',
  };

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return WebPlayerScreen(title: title, url: url);
    }

    final normalizedTitle = title.toLowerCase().trim();
    String? mapped;
    for (final entry in _directStreams.entries) {
      if (normalizedTitle == entry.key ||
          (entry.key != 'urban fm' && normalizedTitle.startsWith('${entry.key} '))) {
        mapped = entry.value;
        break;
      }
    }

    final selectedUrl = mapped ?? url;
    if (mapped != null || _isLikelyDirectAudioUrl(selectedUrl)) {
      return WindowsDirectRadioScreen(
        title: title,
        url: selectedUrl,
        websiteUrl: url,
      );
    }
    return WindowsDirectRadioScreen(title: title, url: url, websiteUrl: url);
  }

  static bool _isLikelyDirectAudioUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('/stream') ||
        const ['.mp3', '.aac', '.m4a', '.ogg', '.opus', '.m3u8', '.pls', '.aacp']
            .any(path.endsWith);
  }
}

class WindowsDirectRadioScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? websiteUrl;

  const WindowsDirectRadioScreen({
    super.key,
    required this.title,
    required this.url,
    this.websiteUrl,
  });

  @override
  State<WindowsDirectRadioScreen> createState() => _WindowsDirectRadioScreenState();
}

class _WindowsDirectRadioScreenState extends State<WindowsDirectRadioScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _loading = true;
  bool _discovering = false;
  String? _activeUrl;

  @override
  void initState() {
    super.initState();
    _initialize(widget.url);
  }

  Future<void> _initialize(String url) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      _activeUrl = url;
      controller.addListener(_onChanged);
      await controller.initialize().timeout(const Duration(seconds: 18));
      await controller.setVolume(1.0);
      await controller.play();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (controller != null) {
        controller.removeListener(_onChanged);
        await controller.dispose();
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
      if (widget.websiteUrl != null && widget.websiteUrl != url) {
        await _discoverWebsiteStream();
      } else if (widget.websiteUrl != null) {
        await _discoverWebsiteStream();
      }
    }
  }

  Future<void> _discoverWebsiteStream() async {
    if (_discovering || widget.websiteUrl == null) return;
    final pageUri = Uri.tryParse(widget.websiteUrl!);
    if (pageUri == null) return;
    _discovering = true;
    try {
      final response = await http.get(pageUri, headers: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,*/*',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 400) return;
      final html = utf8.decode(response.bodyBytes, allowMalformed: true);
      final candidates = <String>[];
      final patterns = [
        RegExp(r'''(?:src|href|data-src)\s*=\s*["']([^"']+)["']''', caseSensitive: false),
        RegExp(r'''[\"'](https?:\\/\\/[^\"']+?(?:\\.mp3|\\.aac|\\.m4a|\\.m3u8|\\.pls|\\.aacp)(?:\\?[^\"']*)?)[\"']''', caseSensitive: false),
        RegExp(r'''https?://[^\s\"'<>]+?(?:\.mp3|\.aac|\.m4a|\.m3u8|\.pls|\.aacp)(?:\?[^\s\"'<>]*)?''', caseSensitive: false),
      ];
      for (final pattern in patterns) {
        for (final match in pattern.allMatches(html)) {
          var candidate = (match.group(1) ?? match.group(0) ?? '').replaceAll(r'\/', '/').replaceAll('&amp;', '&').trim();
          if (candidate.isEmpty) continue;
          if (candidate.startsWith('//')) candidate = '${pageUri.scheme}:$candidate';
          if (candidate.startsWith('/')) candidate = pageUri.resolve(candidate).toString();
          final uri = Uri.tryParse(candidate);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) continue;
          final path = uri.path.toLowerCase();
          if (const ['.mp3', '.aac', '.m4a', '.m3u8', '.pls', '.aacp'].any(path.endsWith) ||
              path.endsWith('/stream')) {
            if (!candidates.contains(candidate)) candidates.add(candidate);
          }
        }
      }
      for (final candidate in candidates.take(8)) {
        if (!mounted) return;
        final previous = _controller;
        _controller = null;
        if (previous != null) {
          previous.removeListener(_onChanged);
          await previous.dispose();
        }
        setState(() {
          _loading = true;
          _error = null;
        });
        await _initializeCandidate(candidate);
        if (_error == null) return;
      }
    } catch (_) {
      // Some stations build their players in JavaScript or protect streams.
    } finally {
      _discovering = false;
    }
  }

  Future<void> _initializeCandidate(String url) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      _activeUrl = url;
      controller.addListener(_onChanged);
      await controller.initialize().timeout(const Duration(seconds: 12));
      await controller.setVolume(1.0);
      await controller.play();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (controller != null) {
        controller.removeListener(_onChanged);
        await controller.dispose();
      }
      if (mounted) setState(() {
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
    await _initialize(widget.url);
  }

  Future<void> _openWebsite() async {
    final uri = Uri.tryParse(widget.websiteUrl ?? widget.url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
              Text(widget.title, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (_loading) const CircularProgressIndicator(),
              if (_error != null && !_loading) ...[
                const Text('Impossible de lire directement le flux audio.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('La station peut utiliser un lecteur protégé ou un flux non public.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  FilledButton.icon(onPressed: _retry, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
                  OutlinedButton.icon(onPressed: _openWebsite, icon: const Icon(Icons.open_in_new), label: const Text('Ouvrir le site')),
                ]),
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
