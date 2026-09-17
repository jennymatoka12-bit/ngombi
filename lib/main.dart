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
              Tab(icon: Icon(Icons.tv), text: 'Chaînes TV'),
              Tab(icon: Icon(Icons.radio), text: 'Radios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(context, isTv: true),
            _buildGrid(context, isTv: false),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, {required bool isTv}) {
    final List<Map<String, String>> items = isTv
        ? [
            {'title': 'Gabon 24', 'sub': 'Information Direct', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC4S4M3m_xN0wO1xX10sV7pA'},
            {'title': 'Africanews FR', 'sub': 'Info Afrique 24/7', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC3O31k3q5FqjS3J59PzOqDA'},
            {'title': 'France 24', 'sub': 'Direct International', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC24e03xM893f1X-2a1M94gA'},
            {'title': 'TV5Monde', 'sub': 'Généraliste', 'url': 'https://www.youtube.com/embed/live_stream?channel=UCq_yF9mHq-sL710F5A_8rQg'},
          ]
        : [
            {'title': 'RFI Afrique', 'sub': 'Actualités & Culture', 'url': 'https://www.rfi.fr/fr/podcasts/'},
            {'title': 'Africa N°1 / Radio', 'sub': 'Musique & Info', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC3O31k3q5FqjS3J59PzOqDA'},
            {'title': 'Urban FM', 'sub': 'Hits & Jeunesse', 'url': 'https://www.youtube.com'},
            {'title': 'Gabon Culture', 'sub': 'Patrimoine', 'url': 'https://www.youtube.com'},
          ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(title: item['title']!, url: item['url']!),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
                    child: Icon(
                      isTv ? Icons.play_arrow_rounded : Icons.radio_outlined,
                      size: 32,
                      color: const Color(0xFFE50914),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['sub']!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
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
