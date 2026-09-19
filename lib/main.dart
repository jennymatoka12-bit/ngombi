import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  final String? youtubeVideoId; // ID direct pour YouTube
  final String category;
  final IconData icon;
  final bool isRadio;
  final String description;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    this.youtubeVideoId,
    required this.category,
    required this.icon,
    this.isRadio = false,
    this.description = '',
  });
}

// ==========================================
// LISTE TÉLÉVISION (Avec identifiants YouTube corrigés)
// ==========================================
final List<MediaItem> tvChannels = [
  MediaItem(
    id: 'gabon_tv',
    name: 'Gabon Télévision',
    url: 'https://www.youtube.com/watch?v=live',
    youtubeVideoId: 'gCNeDWCI010', // Id de remplacement si le live direct varie
    category: 'Gabon - Chaîne Nationale',
    icon: Icons.tv,
    description: 'Chaîne officielle de télévision nationale du Gabon',
  ),
  MediaItem(
    id: 'france24_fr',
    name: 'France 24 Direct',
    url: 'https://www.youtube.com/watch?v=R9U_sR88Rz8',
    youtubeVideoId: 'R9U_sR88Rz8', // ID officiel du direct France 24
    category: 'Information Internationale',
    icon: Icons.language,
    description: 'L\'information internationale 24h/24 en français',
  ),
  MediaItem(
    id: 'africanews',
    name: 'Africanews Direct',
    url: 'https://www.youtube.com/watch?v=gCNeDWCI010',
    youtubeVideoId: 'gCNeDWCI010', // ID officiel du direct Africanews
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
// LISTE RADIOS
// ==========================================
final List<MediaItem> radioChannels = [
  MediaItem(
    id: 'rfi_afrique',
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/podcasts/direct-afrique',
    category: 'Afrique - Information & Débats',
    icon: Icons.radio,
    isRadio: true,
    description: 'L\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'africa_radio',
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Afrique - Musique & Culture',
    icon: Icons.graphic_eq,
    isRadio: true,
    description: 'Musiques d\'Afrique, talk-shows et informations',
  ),
  MediaItem(
    id: 'urban_fm',
    name: 'Urban FM 104.5 (Gabon)',
    url: 'https://www.urbanfm.ga/',
    category: 'Gabon - Musique & Jeunesse',
    icon: Icons.headset,
    isRadio: true,
    description: 'La 1ère radio urbaine de Libreville',
  ),
  MediaItem(
    id: 'bbc_afrique',
    name: 'BBC Afrique Radio',
    url: 'https://www.bbc.com/afrique',
    category: 'Afrique - Info & Décryptage',
    icon: Icons.newspaper,
    isRadio: true,
    description: 'Journaux et analyses BBC en français',
  ),
  MediaItem(
    id: 'skyrock',
    name: 'Skyrock FM',
    url: 'https://skyrock.fm/',
    category: 'Musique - Rap & Urban',
    icon: Icons.speaker_group,
    isRadio: true,
    description: 'Premier sur le Rap et les Musiques Urbaines',
  ),
  MediaItem(
    id: 'trace_fm',
    name: 'Trace FM Afrique',
    url: 'https://www.radio.fr/s/tracefm',
    category: 'Musique - Afro & Urban Hits',
    icon: Icons.music_note,
    isRadio: true,
    description: 'Les meilleurs hits urbains et Afrobeats',
  ),
  MediaItem(
    id: 'tv_radio_zap_radio',
    name: 'TVRadioZap (Portail Radios)',
    url: 'https://tvradiozap.eu/',
    category: 'Bouquet Radios Globale',
    icon: Icons.cell_tower,
    isRadio: true,
    description: 'Accès au bouquet complet de stations radios',
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
          MediaListView(items: tvChannels, isRadioTab: false),
          MediaListView(items: radioChannels, isRadioTab: true),
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
  final bool isRadioTab;

  const MediaListView({
    super.key,
    required this.items,
    required this.isRadioTab,
  });

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
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaPlayerRouter(item: item),
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

// ROUTEUR : CHOISIT ENTRE LE LECTEUR YOUTUBE ET LE WEBVIEW CLASSIQUE
class MediaPlayerRouter extends StatelessWidget {
  final MediaItem item;

  const MediaPlayerRouter({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.youtubeVideoId != null) {
      return YoutubePlayerScreen(item: item);
    } else {
      return WebPlayerScreen(item: item);
    }
  }
}

// LECTEUR DÉDIÉ YOUTUBE (Corrige l'Erreur 153)
class YoutubePlayerScreen extends StatefulWidget {
  final MediaItem item;

  const YoutubePlayerScreen({super.key, required this.item});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.item.youtubeVideoId!,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
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
        ],
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}

// LECTEUR WEBVIEW POUR LES AUTRES SITES (Non-YouTube)
class WebPlayerScreen extends StatefulWidget {
  final MediaItem item;

  const WebPlayerScreen({super.key, required this.item});

  @override
  State<WebPlayerScreen> createState() => _WebPlayerScreenState();
}

class _WebPlayerScreenState extends State<WebPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
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
          if (_hasError)
            Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Impossible de charger le flux'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                      onPressed: () async {
                        final Uri uri = Uri.parse(widget.item.url);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: const Text('Ouvrir dans le navigateur', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
