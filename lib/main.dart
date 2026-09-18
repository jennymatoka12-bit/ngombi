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
      title: 'NGOMBI Direct',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class MediaItem {
  final String name;
  final String url;
  final String category;
  final bool isRadio;

  MediaItem({
    required this.name,
    required this.url,
    required this.category,
    this.isRadio = false,
  });
}

// Liste Télévision
final List<MediaItem> tvChannels = [
  MediaItem(
    name: 'Gabon Télévision',
    url: 'https://www.youtube.com/@GabonTélévisionOfficiel',
    category: 'Gabon - Direct & Replay',
  ),
  MediaItem(
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Chaînes Françaises & Int.',
  ),
  MediaItem(
    name: 'TF1 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
  MediaItem(
    name: 'France 2 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
  MediaItem(
    name: 'M6 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
];

// Liste Radios (URLs corrigées avec lecteurs web fonctionnels)
final List<MediaItem> radioChannels = [
  MediaItem(
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/podcasts/direct-afrique',
    category: 'Information',
    isRadio: true,
  ),
  MediaItem(
    name: 'RFI Monde',
    url: 'https://www.rfi.fr/fr/podcasts/direct-monde',
    category: 'Information',
    isRadio: true,
  ),
  MediaItem(
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Musique & Infos',
    isRadio: true,
  ),
  MediaItem(
    name: 'TVRadioZap (Portail Radios)',
    url: 'https://tvradiozap.eu/',
    category: 'Radios en Direct',
    isRadio: true,
  ),
];

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NGOMBI TV & Radio', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE50914),
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.live_tv), text: 'Télévision'),
              Tab(icon: Icon(Icons.radio), text: 'Radios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaListView(items: tvChannels),
            MediaListView(items: radioChannels),
          ],
        ),
      ),
    );
  }
}

class MediaListView extends StatelessWidget {
  final List<MediaItem> items;
  const MediaListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
            child: Icon(
              item.isRadio ? Icons.radio : Icons.play_arrow_rounded,
              color: const Color(0xFFE50914),
            ),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPlayerScreen(title: item.name, url: item.url),
              ),
            );
          },
        );
      },
    );
  }
}

class WebPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebPlayerScreen({super.key, required this.title, required this.url});

  @override
  State<WebPlayerScreen> createState() => _WebPlayerScreenState();
}

class _WebPlayerScreenState extends State<WebPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
        ],
      ),
    );
  }
}
