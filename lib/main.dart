import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  final String url;
  Channel({required this.name, required this.url});
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
          physics: NeverScrollableScrollPhysics(),
          children: [
            ChannelListView(playlistUrl: 'https://tvradiozap.eu/live/x/vlc/d/tvzeu.m3u', isTv: true),
            ChannelListView(playlistUrl: 'https://tvradiozap.eu/live/x/vlc/d/tvzeu.m3u', isTv: false),
          ],
        ),
      ),
    );
  }
}

class ChannelListView extends StatefulWidget {
  final String playlistUrl;
  final bool isTv;
  const ChannelListView({super.key, required this.playlistUrl, required this.isTv});

  @override
  State<ChannelListView> createState() => _ChannelListViewState();
}

class _ChannelListViewState extends State<ChannelListView> {
  Future<List<Channel>> _fetchChannels() async {
    try {
      final response = await http.get(Uri.parse(widget.playlistUrl));
      if (response.statusCode != 200) return [];

      final List<Channel> channels = [];
      final lines = response.body.split('\n');
      String currentName = '';

      for (var line in lines) {
        line = line.trim();
        if (line.startsWith('#EXTINF:')) {
          final commaIndex = line.lastIndexOf(',');
          if (commaIndex != -1) {
            currentName = line.substring(commaIndex + 1).trim();
          }
        } else if (line.isNotEmpty && !line.startsWith('#')) {
          if (currentName.isNotEmpty) {
            channels.add(Channel(name: currentName, url: line));
          }
          currentName = '';
        }
      }
      return channels;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Channel>>(
      future: _fetchChannels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
        }

        final channels = snapshot.data ?? [];
        if (channels.isEmpty) {
          return WebPortalView(isTv: widget.isTv);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: channels.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final channel = channels[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
                child: Icon(
                  widget.isTv ? Icons.play_arrow_rounded : Icons.radio,
                  color: const Color(0xFFE50914),
                ),
              ),
              title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(title: channel.name, streamUrl: channel.url),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class WebPortalView extends StatefulWidget {
  final bool isTv;
  const WebPortalView({super.key, required this.isTv});

  @override
  State<WebPortalView> createState() => _WebPortalViewState();
}

class _WebPortalViewState extends State<WebPortalView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://tvradiozap.eu/'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class PlayerScreen extends StatefulWidget {
  final String title;
  final String streamUrl;

  const PlayerScreen({super.key, required this.title, required this.streamUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isStream = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final urlLower = widget.streamUrl.toLowerCase();
    _isStream = urlLower.contains('.m3u8') || urlLower.contains('.mpd') || urlLower.contains('.mp4');

    if (_isStream) {
      _initPlayer();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _initPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        isLive: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Impossible de charger ce flux de direct ($errorMessage).",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      );
    } catch (e) {
      _errorMessage = "Erreur d'initialisation du lecteur en direct.";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                  ),
                )
              : _isStream && _chewieController != null
                  ? Center(child: Chewie(controller: _chewieController!))
                  : WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(widget.streamUrl)),
                    ),
    );
  }
}
