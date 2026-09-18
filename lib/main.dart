import 'package:flutter/material.dart';
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
      home: const MainTabScreen(),
    );
  }
}

class Channel {
  final String name;
  final String streamUrl;
  final String category;
  final bool isRadio;

  Channel({
    required this.name,
    required this.streamUrl,
    required this.category,
    this.isRadio = false,
  });
}

// Flux vidéo et audio directs HLS / M3U8 (100% stables sans navigateur)
final List<Channel> tvChannels = [
  Channel(
    name: 'France 24 Français Direct',
    streamUrl: 'https://static.france24.com/live/F24_FR_LO_HLS/live_web-audio=100000-video=1500000.m3u8',
    category: 'Information',
  ),
  Channel(
    name: 'Euronews Français',
    streamUrl: 'https://euronews-euronews-french-1-fr.samsung.wurl.tv/manifest/playlist.m3u8',
    category: 'Information',
  ),
  Channel(
    name: 'TV5Monde Info',
    streamUrl: 'https://ott.tv5monde.com/Content/HLS/Live/channel(info)/index.m3u8',
    category: 'Information',
  ),
  Channel(
    name: 'Africanews Français',
    streamUrl: 'https://africanews-africanews-french-1-fr.samsung.wurl.tv/manifest/playlist.m3u8',
    category: 'Afrique',
  ),
];

final List<Channel> radioChannels = [
  Channel(
    name: 'RFI Afrique',
    streamUrl: 'https://live02.rfi.fr/rfiafrique-64.mp3',
    category: 'Information',
    isRadio: true,
  ),
  Channel(
    name: 'Africa Radio',
    streamUrl: 'https://africaradio.ice.infomaniak.ch/africaradio-128.mp3',
    category: 'Musique & Infos',
    isRadio: true,
  ),
  Channel(
    name: 'RFI Monde',
    streamUrl: 'https://live02.rfi.fr/rfimonde-64.mp3',
    category: 'Information',
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
          title: const Text('NGOMBI Direct', style: TextStyle(fontWeight: FontWeight.bold)),
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
            ChannelList(channels: tvChannels),
            ChannelList(channels: radioChannels),
          ],
        ),
      ),
    );
  }
}

class ChannelList extends StatelessWidget {
  final List<Channel> channels;
  const ChannelList({super.key, required this.channels});

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
            child: Icon(
              channel.isRadio ? Icons.radio : Icons.play_arrow_rounded,
              color: const Color(0xFFE50914),
            ),
          ),
          title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(channel.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFE50914), size: 28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NativePlayerScreen(channel: channel),
              ),
            );
          },
        );
      },
    );
  }
}

class NativePlayerScreen extends StatefulWidget {
  final Channel channel;

  const NativePlayerScreen({super.key, required this.channel});

  @override
  State<NativePlayerScreen> createState() => _NativePlayerScreenState();
}

class _NativePlayerScreenState extends State<NativePlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
      );

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        isLive: true,
        allowFullScreen: true,
        aspectRatio: widget.channel.isRadio ? 16 / 9 : _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Erreur de lecture du flux.\n$errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {});
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: Center(
        child: _hasError
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Impossible de charger ce flux en direct.\nVérifiez votre connexion internet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              )
            : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? widget.channel.isRadio
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.radio, size: 100, color: Color(0xFFE50914)),
                          const SizedBox(height: 20),
                          Text(
                            widget.channel.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(color: Color(0xFFE50914)),
                          const SizedBox(height: 10),
                          const Text('Diffusion radio en cours...'),
                        ],
                      )
                    : AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      )
                : const CircularProgressIndicator(color: Color(0xFFE50914)),
      ),
    );
  }
}
