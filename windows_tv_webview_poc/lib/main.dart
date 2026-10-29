import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter_windows/webview_flutter_windows.dart';

const _defaultStreamUrl =
    'https://tvradiozap.eu/tools/m3u-m3u8.php/para/tf1.m3u8';

void main() => runApp(const WindowsTvWebviewPocApp());

class WindowsTvWebviewPocApp extends StatelessWidget {
  const WindowsTvWebviewPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGOMBI Windows HLS test',
      theme: ThemeData.dark(useMaterial3: true),
      home: const WindowsTvWebviewPocScreen(),
    );
  }
}

class WindowsTvWebviewPocScreen extends StatefulWidget {
  const WindowsTvWebviewPocScreen({super.key});

  @override
  State<WindowsTvWebviewPocScreen> createState() =>
      _WindowsTvWebviewPocScreenState();
}

class _WindowsTvWebviewPocScreenState extends State<WindowsTvWebviewPocScreen> {
  final _urlController = TextEditingController(text: _defaultStreamUrl);
  WebviewController? _webController;
  StreamSubscription<dynamic>? _messageSubscription;
  StreamSubscription<dynamic>? _loadErrorSubscription;
  String _status = 'PrÃªt Ã  lancer le test.';
  bool _loading = false;
  bool _isPlaying = false;
  String? _error;

  Future<void> _startPlayback() async {
    final uri = Uri.tryParse(_urlController.text.trim());
    if (uri == null || uri.scheme != 'https' || !uri.path.toLowerCase().contains('.m3u8')) {
      setState(() => _error = 'Saisissez une URL HTTPS HLS se terminant par .m3u8.');
      return;
    }

    await _messageSubscription?.cancel();
    await _loadErrorSubscription?.cancel();
    await _webController?.dispose();

    final controller = WebviewController();
    _webController = controller;
    _messageSubscription = controller.webMessage.listen(_onWebMessage);
    _loadErrorSubscription = controller.onLoadError.listen((status) {
      if (!mounted) return;
      setState(() => _error = 'WebView2: $status');
    });

    setState(() {
      _loading = true;
      _isPlaying = false;
      _error = null;
      _status = 'Initialisation de WebView2â€¦';
    });

    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await controller.setDefaultContextMenusEnabled(false);
      await controller.setDevToolsEnabled(false);
      await controller.setZoomControlEnabled(false);
      await controller.loadStringContent(_playerHtml(uri.toString()));
      if (mounted) {
        setState(() {
          _loading = false;
          _status = 'WebView2 prÃªt; attente du fluxâ€¦';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().contains('environment_creation_failed')
            ? 'Runtime Microsoft Edge WebView2 introuvable.'
            : 'Impossible dâ€™initialiser le lecteur : $error';
      });
    }
  }

  void _onWebMessage(dynamic message) {
    Map<dynamic, dynamic>? event;
    if (message is Map) {
      event = message;
    } else if (message is String) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map) event = decoded;
      } catch (_) {}
    }
    if (event == null || !mounted) return;

    final type = event['type']?.toString();
    final messageText = event['message']?.toString();
    setState(() {
      _isPlaying = type == 'playing';
      if (messageText != null && messageText.isNotEmpty) {
        _status = messageText;
      }
      if (type == 'error') {
        _error = messageText ?? 'Erreur de lecture HLS.';
      }
    });
  }

  String _playerHtml(String streamUrl) {
    final jsUrl = jsonEncode(streamUrl);
    return '''
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { width:100%; height:100%; margin:0; background:#000; overflow:hidden; }
    video { width:100%; height:100%; object-fit:contain; background:#000; }
  </style>
  <script src="https://cdn.jsdelivr.net/npm/hls.js@1.5.18/dist/hls.min.js"
          onerror="notify('error', 'Impossible de charger HLS.js depuis le CDN.')"></script>
</head>
<body>
  <video id="video" controls autoplay playsinline></video>
  <script>
    const streamUrl = $jsUrl;
    const video = document.getElementById('video');
    function notify(type, message) {
      try { window.chrome.webview.postMessage({type, message}); } catch (_) {}
    }
    video.addEventListener('playing', () => notify('playing', 'Lecture active'));
    video.addEventListener('waiting', () => notify('status', 'Mise en mÃ©moire tamponâ€¦'));
    video.addEventListener('error', () => {
      const code = video.error ? video.error.code : 'inconnu';
      notify('error', 'Erreur vidÃ©o HTML5 (' + code + ').');
    });
    if (window.Hls && Hls.isSupported()) {
      const hls = new Hls({enableWorker: true, lowLatencyMode: false});
      hls.on(Hls.Events.ERROR, (_event, data) => {
        if (data && data.fatal) notify('error', 'Erreur HLS fatale : ' + data.details);
      });
      hls.on(Hls.Events.MEDIA_ATTACHED, () => hls.loadSource(streamUrl));
      hls.on(Hls.Events.MANIFEST_PARSED, () => {
        video.play().catch(() => notify('status', 'Appuyez sur Lecture pour dÃ©marrer le direct.'));
      });
      hls.attachMedia(video);
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = streamUrl;
      video.play().catch(() => notify('status', 'Appuyez sur Lecture pour dÃ©marrer le direct.'));
    } else {
      notify('error', 'HLS.js ou le dÃ©codage HLS natif est indisponible.');
    }
  </script>
</body>
</html>
''';
  }

  @override
  void dispose() {
    _urlController.dispose();
    unawaited(_messageSubscription?.cancel());
    unawaited(_loadErrorSubscription?.cancel());
    unawaited(_webController?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webController = _webController;
    return Scaffold(
      appBar: AppBar(title: const Text('NGOMBI â€” prototype HLS Windows')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Essai isolÃ© WebView2 + HLS.js. Ce prototype ne modifie pas le lecteur Android ni le lecteur principal.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL HLS de test',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _loading ? null : _startPlayback,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Lancer le test'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? _status,
              style: TextStyle(color: _error == null ? Colors.white70 : Colors.redAccent),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (webController?.value.isInitialized == true)
                      Webview(webController!)
                    else if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    if (_isPlaying)
                      const Positioned(
                        right: 12,
                        bottom: 12,
                        child: Chip(label: Text('Lecture active')),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

