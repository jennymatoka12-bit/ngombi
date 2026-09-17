import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NgombiApp());
}

class NgombiApp extends StatelessWidget {
  const NgombiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGOMBI TV & Radio',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.redAccent,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.tv, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'NGOMBI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Se connecter', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
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
          title: const Text('NGOMBI TV & Radio'),
          backgroundColor: const Color(0xFF1F1F1F),
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            tabs: [
              Tab(icon: Icon(Icons.live_tv), text: 'TV'),
              Tab(icon: Icon(Icons.radio), text: 'Radio'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMediaGrid(context, isTv: true),
            _buildMediaGrid(context, isTv: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, {required bool isTv}) {
    final List<Map<String, String>> items = isTv
        ? [
            {'title': 'Gabon 1ère', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC_EXAMPLE1'},
            {'title': 'Gabon 24', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC_EXAMPLE2'},
            {'title': 'TV+ Gabon', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC_EXAMPLE3'},
            {'title': 'Espace TV', 'url': 'https://www.youtube.com/embed/live_stream?channel=UC_EXAMPLE4'},
          ]
        : [
            {'title': 'Radio Gabon FM', 'url': 'https://www.radiogabon.ga'},
            {'title': 'Urban FM', 'url': 'https://www.urbanfm.ga'},
            {'title': 'RTG Chaine 1', 'url': 'https://www.rtg.ga'},
            {'title': 'Gabon Culture FM', 'url': 'https://www.gabonculture.ga'},
          ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: const Color(0xFF1F1F1F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(
                    title: item['title']!,
                    url: item['url']!,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTv ? Icons.play_circle_fill : Icons.radio_button_checked,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  item['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
