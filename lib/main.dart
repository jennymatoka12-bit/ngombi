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
  final bool isRadio;
  final String description;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.icon,
    this.isRadio = false,
    this.description = '',
  });
}

// ==========================================
// LISTE TÉLÉVISION
// ==========================================
final List<MediaItem> tvChannels = [
  MediaItem(
    id: 'gabon_tv',
    name: 'Gabon Télévision',
    url: 'https://www.youtube.com/@gabontelevisionofficiel3930/streams',
    category: 'Gabon - Chaîne Nationale',
    icon: Icons.tv,
    description: 'Chaine officielle de télévision nationale du Gabon en direct',
  ),
  MediaItem(
    id: 'tv_radio_zap_tv',
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Bouquet TV Francophone',
    icon: Icons.live_tv,
    description: 'Accès au bouquet complet des chaînes francophones',
  ),
  MediaItem(
    id: 'france24_fr',
    name: 'France 24 Direct',
    url: 'https://www.youtube.com/watch?v=R9U_sR88Rz8',
    category: 'Information Internationale',
    icon: Icons.language,
    description: 'L\'information internationale 24h/24 en français',
  ),
  MediaItem(
    id: 'africanews',
    name: 'Africanews Direct',
    url: 'https://www.youtube.com/watch?v=gCNeDWCI010',
    category: 'Information Afrique',
    icon: Icons.public,
    description: 'Toute l\'actualité du continent africain',
  ),
];

// ==========================================
// LISTE RADIOS COMPLÈTE (LIENS DIRECTS)
// ==========================================
final List<MediaItem> radioChannels = [
  MediaItem(
    id: 'rfi_afrique',
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/en-direct',
    category: 'Information & Débats',
    icon: Icons.radio,
    isRadio: true,
    description: 'Direct RFI Afrique - Actualités et magazines',
  ),
  MediaItem(
    id: 'rfi_monde',
    name: 'RFI Monde',
    url: 'https://www.rfi.fr/fr/en-direct',
    category: 'Information Internationale',
    icon: Icons.public,
    isRadio: true,
    description: 'Journal international de RFI en continu',
  ),
  MediaItem(
    id: 'africa_radio',
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Musique & Culture',
    icon: Icons.graphic_eq,
    isRadio: true,
    description: 'Musiques d\'Afrique, talk-shows et informations',
  ),
  MediaItem(
    id: 'radio_gabon',
    name: 'Radio Gabon (RTG)',
    url: 'https://www.youtube.com/@gabontelevisionofficiel3930/streams',
    category: 'Gabon - Radio Nationale',
    icon: Icons.cell_tower,
    isRadio: true,
    description: 'Radio Télévision Gabonaise en direct',
  ),
  MediaItem(
    id: 'urban_fm',
    name: 'Urban FM 104.5 (Gabon)',
    url: 'https://www.urbanfm.ga/',
    category: 'Gabon - Musique & Jeunesse',
    icon: Icons.headset,
    isRadio: true,
    description: 'La station urbaine référence de Libreville',
  ),
  MediaItem(
    id: 'bbc_afrique',
    name: 'BBC Afrique Radio',
    url: 'https://www.bbc.com/afrique',
    category: 'Information & Analyses',
    icon: Icons.newspaper,
    isRadio: true,
    description: 'Journaux et décryptages BBC en français',
  ),
  MediaItem(
    id: 'rmc_info',
    name: 'RMC Direct',
    url: 'https://rmc.bfmtv.com/mediaplayer/live-audio/',
    category: 'Talk & Sports',
    icon: Icons.sports_mic,
    isRadio: true,
    description: 'Info, débats et grands événements sportifs',
  ),
  MediaItem(
    id: 'rtl_france',
    name: 'RTL Direct',
    url: 'https://www.rtl.fr/direct',
    category: 'Généraliste & Infos',
    icon: Icons.radio,
    isRadio: true,
    description: 'Première radio généraliste de France',
  ),
  MediaItem(
    id: 'europe1',
    name: 'Europe 1 Direct',
    url: 'https://www.europe1.fr/direct',
    category: 'Information & Culture',
    icon: Icons.podcasts,
    isRadio: true,
    description: 'Émissions, culture et journal d\'actualité',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebPlayerScreen(item: item),
                ),
              );
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
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            _controller.runJavaScript('''
              try {
                document.querySelector('header')?.style.setProperty('display', 'none', 'important');
                document.querySelector('footer')?.style.setProperty('display', 'none', 'important');
              } catch(e) {}
            ''');
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE50914)),
                    SizedBox(height: 16),
                    Text(
                      'Chargement du direct...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
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
