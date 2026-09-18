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

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NGOMBI TV & Radio'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE50914),
            tabs: [
              Tab(icon: Icon(Icons.tv), text: 'Télévision'),
              Tab(icon: Icon(Icons.radio), text: 'Radios'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MediaList(items: tvChannels),
            MediaList(items: radioChannels),
          ],
        ),
      ),
    );
  }
}

class MediaItem {
  final String name;
  final String url;
  final String category;

  MediaItem({required this.name, required this.url, required this.category});
}

// Flux vidéo/audio directs et stables (Exemples de flux ouverts)
final List<MediaItem> tvChannels = [
  MediaItem(name: 'France 24', url: 'https://www.youtube.com/embed/g_04bH4aT1s', category: 'Information'),
  MediaItem(name: 'EURONEWS', url: 'https://www.youtube.com/embed/py_1aB0_z_8', category: 'Information'),
  MediaItem(name: 'TV5 Monde Afrique', url: 'https://afrique.tv5monde.com/df/direct-tv', category: 'Généraliste'),
  MediaItem(name: 'Africa 24', url: 'https://www.youtube.com/embed/live_stream?channel=UC8g9p1S3pT4j--81z1c5Xkg', category: 'Afrique'),
];

final List<MediaItem> radioChannels = [
  MediaItem(name: 'RFI Afrique', url: 'https://www.rfi.fr/fr/en-direct', category: 'Information'),
  MediaItem(name: 'Africa Radio', url: 'https://www.africaradio.com/', category: 'Musique'),
  MediaItem(name: 'Radio France Inter', url: 'https://www.radiofrance.fr/franceinter/direct', category: 'Généraliste'),
];

class MediaList extends StatelessWidget {
  final List<MediaItem> items;
  const MediaList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: const Icon(Icons.play_circle_fill, color: Color(0xFFE50914), size: 36),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.category, style: const TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(title: item.name, url: item.url),
              ),
            );
          },
        );
      },
    );
  }
}

class PlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PlayerScreen({super.key, required this.title, required this.url});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
