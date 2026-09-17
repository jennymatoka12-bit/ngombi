import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const NgombiApp());
}

class NgombiApp extends StatelessWidget {
  const NgombiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGOMBI TV & Radio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NGOMBI Direct', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE50914),
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.tv), text: 'TV Direct'),
              Tab(icon: Icon(Icons.radio), text: 'Radio Direct'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TvRadioZapViewer(url: 'https://tvradiozap.eu/live/x/vlc/d/tvzeu.m3u'),
            TvRadioZapViewer(url: 'https://tvradiozap.eu/'),
          ],
        ),
      ),
    );
  }
}

class TvRadioZapViewer extends StatefulWidget {
  final String url;
  const TvRadioZapViewer({super.key, required this.url});

  @override
  State<TvRadioZapViewer> createState() => _TvRadioZapViewerState();
}

class _TvRadioZapViewerState extends State<TvRadioZapViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            // Injection CSS pour masquer l'entête, le tableau d'affichage et garder uniquement la zone vidéo
            _controller.runJavaScript('''
              var style = document.createElement('style');
              style.innerHTML = 'header, footer, nav, .top-bar, #header, #footer { display: none !important; } body { background-color: #121212 !important; color: white !important; }';
              document.head.appendChild(style);
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFE50914)),
          ),
      ],
    );
  }
}
