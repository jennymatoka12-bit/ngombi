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
  final String webUrl;
  Channel({required this.name, required this.webUrl});
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

// Liste des chaînes TV avec leurs pages de direct officielles/compatibles
final List<Channel> tvChannels = [
  Channel(name: 'TF1 Direct', webUrl: 'https://www.tf1.fr/tf1/direct'),
  Channel(name: 'France 2 Direct', webUrl: 'https://www.france.tv/france-2/direct.html'),
  Channel(name: 'France 3 Direct', webUrl: 'https://www.france.tv/france-3/direct.html'),
  Channel(name: 'Arte Direct', webUrl: 'https://www.arte.tv/fr/direct/'),
  Channel(name: 'M6 Direct', webUrl: 'https://www.6play.fr/m6/direct'),
  Channel(name: 'BFM TV Direct', webUrl: 'https://www.bfmtv.com/en-direct/'),
  Channel(name: 'CNews Direct', webUrl: 'https://www.cnews.fr/le-direct'),
  Channel(name: 'France Info Direct', webUrl: 'https://www.francetvinfo.fr/en-direct/tv.html'),
  Channel(name: 'TV5Monde Direct', webUrl: 'https://live.tv5monde.com/html5/index.html'),
  Channel(name: '24h Gabon / Télé Gabon', webUrl: 'https://www.youtube.com/results?search_query=tele+gabon+direct'),
];

// Liste des radios avec leurs pages de direct web
final List<Channel> radioChannels = [
  Channel(name: 'RFI Monde', webUrl: 'https://www.rfi.fr/fr/en-direct'),
  Channel(name: 'Africa Radio', webUrl: 'https://www.africaradio.com/'),
  Channel(name: 'France Inter', webUrl: 'https://www.radiofrance.fr/franceinter/direct'),
  Channel(name: 'NRJ', webUrl: 'https://www.nrj.fr/live'),
  Channel(name: 'Skyrock', webUrl: 'https://skyrock.fm/live'),
  Channel(name: 'RMC', webUrl: 'https://rmc.bfmtv.com/mediaplayer/radio/'),
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
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPlayerScreen(title: channel.name, url: channel.webUrl),
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
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
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
