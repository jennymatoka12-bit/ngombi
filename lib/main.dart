import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181818),
          elevation: 4,
          shadowColor: Colors.black54,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF181818),
          selectedItemColor: Color(0xFFE50914),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class MediaItem {
  final String id;
  final String name;
  final String url;
  final String category;
  final IconData icon;
  final bool isAudioStream;
  final String description;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.icon,
    this.isAudioStream = false,
    this.description = '',
  });
}

// ==========================================
// LISTE TÉLÉVISION (STRICTEMENT INTACTE)
// ==========================================
final List<MediaItem> tvChannels = [
  MediaItem(
    id: 'gabon_tv',
    name: 'Gabon Télévision',
    url: 'https://www.youtube.com/embed/live_stream?channel=UC7K23_V1HkY0Y_K0vN69A5g',
    category: 'Gabon - Chaîne Nationale',
    icon: Icons.tv,
    description: 'Chaîne officielle de télévision nationale du Gabon',
  ),
  MediaItem(
    id: 'france24_fr',
    name: 'France 24 Direct',
    url: 'https://www.youtube.com/embed/R9U_sR88Rz8?autoplay=1',
    category: 'Information Internationale',
    icon: Icons.language,
    description: 'L\'information internationale 24h/24 en français',
  ),
  MediaItem(
    id: 'africanews',
    name: 'Africanews Direct',
    url: 'https://www.youtube.com/embed/gCNeDWCI010?autoplay=1',
    category: 'Information Afrique',
    icon: Icons.public,
    description: 'Toute l\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'tv_radio_zap_tv',
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Bouquet TV Francophone',
    icon: Icons.live_tv,
    description: 'Portail global des chaînes TV francophones',
  ),
];

// ==========================================
// LISTE RADIOS (CORRIGÉE & ENRICHIE)
// ==========================================
final List<MediaItem> radioChannels = [
  MediaItem(
    id: 'rfi_afrique',
    name: 'RFI Afrique',
    url: 'https://stream.radiofrance.fr/rfiafrique/rfiafrique_hifi.m3u8',
    category: 'Afrique - Info & Débats',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'L\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'africa_radio',
    name: 'Africa Radio',
    url: 'https://africaradio.ice.infomaniak.ch/africaradio-128.mp3',
    category: 'Afrique - Musique & Culture',
    icon: Icons.graphic_eq,
    isAudioStream: true,
    description: 'Musiques d\'Afrique, talk-shows et informations',
  ),
  MediaItem(
    id: 'radio_gabon',
    name: 'Radio Gabon (RTG)',
    url: 'https://stream.zeno.fm/f3wvbb1v28quv',
    category: 'Gabon - Radio Nationale',
    icon: Icons.cell_tower,
    isAudioStream: true,
    description: 'Chaîne radio nationale du Gabon',
  ),
  MediaItem(
    id: 'urban_fm',
    name: 'Urban FM 104.5 (Gabon)',
    url: 'https://stream.zeno.fm/f3wvbb1v28quv',
    category: 'Gabon - Musique & Jeunesse',
    icon: Icons.headset,
    isAudioStream: true,
    description: 'La 1ère radio urbaine de Libreville',
  ),
  MediaItem(
    id: 'bbc_afrique',
    name: 'BBC Afrique Radio',
    url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
    category: 'Afrique - Info & Décryptage',
    icon: Icons.newspaper,
    isAudioStream: true,
    description: 'Journaux et analyses BBC en français',
  ),
  MediaItem(
    id: 'skyrock',
    name: 'Skyrock FM',
    url: 'https://icecast.skyrock.net/s/natio_mp3_128k',
    category: 'Musique - Rap & Urban',
    icon: Icons.speaker_group,
    isAudioStream: true,
    description: 'Premier sur le Rap et les Musiques Urbaines',
  ),
  MediaItem(
    id: 'trace_fm',
    name: 'Trace FM Afrique',
    url: 'https://trace.ice.infomaniak.ch/trace-128.mp3',
    category: 'Musique - Afro & Urban Hits',
    icon: Icons.music_note,
    isAudioStream: true,
    description: 'Les meilleurs hits urbains et Afrobeats',
  ),
  MediaItem(
    id: 'nrj',
    name: 'NRJ Hit Music Only',
    url: 'https://audio.nrj.fr/listen/nrj/mp3-128',
    category: 'Musique - Hits Pop',
    icon: Icons.library_music,
    isAudioStream: true,
    description: 'Hit Music Only - Les plus grands hits du moment',
  ),
  MediaItem(
    id: 'nostalgie',
    name: 'Nostalgie',
    url: 'https://audio.nostalgie.fr/listen/nostalgie/mp3-128',
    category: 'Musique - Retro & Classiques',
    icon: Icons.album,
    isAudioStream: true,
    description: 'Les plus grandes chansons des années 80, 90 et 2000',
  ),
  MediaItem(
    id: 'cherie_fm',
    name: 'Chérie FM',
    url: 'https://audio.cheriefm.fr/listen/cherie_fm/mp3-128',
    category: 'Musique - Pop & Pop Rock',
    icon: Icons.favorite,
    isAudioStream: true,
    description: 'La plus belle musique et les plus beaux hits',
  ),
  MediaItem(
    id: 'rfm',
    name: 'RFM',
    url: 'https://rfm.ice.infomaniak.ch/rfm-128.mp3',
    category: 'Musique - Pop Rock & Disco',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'Le meilleur de la musique Pop Rock',
  ),
  MediaItem(
    id: 'fun_radio',
    name: 'Fun Radio',
    url: 'https://icecast.rtl.fr/fun-1-44-128?listen=webcmedia',
    category: 'Musique - Dance & Electro',
    icon: Icons.headphones,
    isAudioStream: true,
    description: 'Le son Dance Electro & Party',
  ),
  MediaItem(
    id: 'rmc',
    name: 'RMC Info Talk Sport',
    url: 'https://audio.bfmtv.com/rmc_mp3',
    category: 'Talk & Sports',
    icon: Icons.mic,
    isAudioStream: true,
    description: 'Actualité, débats et retransmissions sportives',
  ),
  MediaItem(
    id: 'rfi_monde',
    name: 'RFI Monde',
    url: 'https://stream.radiofrance.fr/rfimonde/rfimonde_hifi.m3u8',
    category: 'International - Information',
    icon: Icons.public,
    isAudioStream: true,
    description: 'Journal international en continu',
  ),
  MediaItem(
    id: 'france_info',
    name: 'France Info',
    url: 'https://icecast.radiofrance.fr/franceinfo-midfi.mp3',
    category: 'International - Info Continu',
    icon: Icons.info_outline,
    isAudioStream: true,
    description: 'L\'information en continu 24h/24',
  ),
  MediaItem(
    id: 'rtl',
    name: 'RTL',
    url: 'https://icecast.rtl.fr/rtl-1-44-128?listen=webcmedia',
    category: 'Généraliste & Magazines',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'Chroniqueurs, journaux et divertissement',
  ),
  MediaItem(
    id: 'europe1',
    name: 'Europe 1',
    url: 'https://stream.europe1.fr/europe1.mp3',
    category: 'Généraliste & Culture',
    icon: Icons.podcasts,
    isAudioStream: true,
    description: 'Émissions d\'actualité, culture et politique',
  ),
];

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NGOMBI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'TV & RADIO EN DIRECT',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFFE50914),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MediaListView(items: tvChannels),
          MediaListView(items: radioChannels),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_rounded),
            label: 'Télévision',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_rounded),
            label: 'Radios',
          ),
        ],
      ),
    );
  }
}

class MediaListView extends StatelessWidget {
  final List<MediaItem> items;

  const MediaListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (item.isAudioStream) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioPlayerScreen(item: item),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPlayerScreen(item: item),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE50914).withOpacity(0.8),
                          const Color(0xFF8B0000),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF4D4D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow_rounded, color: Color(0xFFE50914), size: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// LECTEUR AUDIO NATIF POUR LES RADIOS
class AudioPlayerScreen extends StatefulWidget {
  final MediaItem item;
  const AudioPlayerScreen({super.key, required this.item});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.item.url);
      _audioPlayer.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE50914), width: 3),
                ),
                child: Icon(widget.item.icon, size: 60, color: const Color(0xFFE50914)),
              ),
              const SizedBox(height: 24),
              Text(
                widget.item.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.category,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFFE50914))
              else if (_hasError)
                Column(
                  children: [
                    const Text('Erreur de lecture du flux direct', style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                        _initAudio();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              else
                IconButton(
                  iconSize: 72,
                  color: const Color(0xFFE50914),
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// LECTEUR WEBVIEW POUR LES TV ET PORTAILS
class WebPlayerScreen extends StatefulWidget {
  final MediaItem item;

  const WebPlayerScreen({super.key, required this.item});

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
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.item.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final Uri uri = Uri.parse(widget.item.url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            Container(
              color: const Color(0xFF121212),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            ),
        ],
      ),
    );
  }
}
