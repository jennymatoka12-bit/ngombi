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
      home: const HomeScreen(),
    );
  }
}

class Channel {
  final String name;
  final String tvRadioZapUrl;
  final String category;

  Channel({
    required this.name,
    required this.tvRadioZapUrl,
    required this.category,
  });
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
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ChannelListView(channels: tvChannels),
            ChannelListView(channels: radioChannels),
          ],
        ),
      ),
    );
  }
}

// Liens directs TVRADIOZAP pour chaque chaîne
final List<Channel> tvChannels = [
  Channel(
    name: 'TF1',
    tvRadioZapUrl: 'https://tvradiozap.eu/tf1-en-direct.html',
    category: 'Généraliste',
  ),
  Channel(
    name: 'France 2',
    tvRadioZapUrl: 'https://tvradiozap.eu/france-2-en-direct.html',
    category: 'Généraliste',
  ),
  Channel(
    name: 'France 3',
    tvRadioZapUrl: 'https://tvradiozap.eu/france-3-en-direct.html',
    category: 'Généraliste',
  ),
  Channel(
    name: 'M6',
    tvRadioZapUrl: 'https://tvradiozap.eu/m6-en-direct.html',
    category: 'Généraliste',
  ),
  Channel(
    name: 'BFM TV',
    tvRadioZapUrl: 'https://tvradiozap.eu/bfm-tv-en-direct.html',
    category: 'Information',
  ),
  Channel(
    name: 'Arte',
    tvRadioZapUrl: 'https://tvradiozap.eu/arte-en-direct.html',
    category: 'Culture',
  ),
  Channel(
    name: 'France 24',
    tvRadioZapUrl: 'https://tvradiozap.eu/france-24-en-direct.html',
    category: 'Information',
  ),
  Channel(
    name: 'TV5 Monde',
    tvRadioZapUrl: 'https://tvradiozap.eu/tv5-monde-en-direct.html',
    category: 'International',
  ),
];

final List<Channel> radioChannels = [
  Channel(
    name: 'RFI Monde',
    tvRadioZapUrl: 'https://tvradiozap.eu/rfi-en-direct.html',
    category: 'Info/Radio',
  ),
  Channel(
    name: 'NRJ',
    tvRadioZapUrl: 'https://tvradiozap.eu/nrj-en-direct.html',
    category: 'Musique',
  ),
  Channel(
    name: 'France Inter',
    tvRadioZapUrl: 'https://tvradiozap.eu/france-inter-en-direct.html',
    category: 'Généraliste',
  ),
  Channel(
    name: 'Skyrock',
    tvRadioZapUrl: 'https://tvradiozap.eu/skyrock-en-direct.html',
    category: 'Musique',
  ),
];

class ChannelListView extends StatelessWidget {
  final List<Channel> channels;
  const ChannelListView({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: channels.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFFE50914),
            ),
          ),
          title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(channel.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TvRadioZapPlayerScreen(
                  title: channel.name,
                  url: channel.tvRadioZapUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TvRadioZapPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const TvRadioZapPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<TvRadioZapPlayerScreen> createState() => _TvRadioZapPlayerScreenState();
}

class _TvRadioZapPlayerScreenState extends State<TvRadioZapPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Injection JavaScript pour masquer les bannières, menus et publicités du site
            _controller.runJavaScript('''
              try {
                document.querySelector('header')?.style.setProperty('display', 'none', 'important');
                document.querySelector('footer')?.style.setProperty('display', 'none', 'important');
                document.querySelector('.sidebar')?.style.setProperty('display', 'none', 'important');
                document.querySelector('.ads')?.style.setProperty('display', 'none', 'important');
              } catch(e) {}
            ''');

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _controller.reload();
            },
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
