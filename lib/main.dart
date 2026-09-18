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
// LISTE COMPLÈTE TÉLÉVISION
// ==========================================
final List<MediaItem> tvChannels = [
  MediaItem(
    id: 'gabon_tv',
    name: 'Gabon Télévision',
    url: 'https://m.youtube.com/results?search_query=gabon+television+en+direct',
    category: 'Gabon - Chaîne Nationale',
    icon: Icons.tv,
    description: 'Actualités, direct et programmes officiels du Gabon',
  ),
  MediaItem(
    id: 'tv_radio_zap_tv',
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Bouquet Généraliste',
    icon: Icons.live_tv,
    description: 'Accès direct au portail des chaînes francophones',
  ),
  MediaItem(
    id: 'tf1',
    name: 'TF1 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste France',
    icon: Icons.play_circle_fill,
    description: 'Grands événements, infos et divertissements',
  ),
  MediaItem(
    id: 'france2',
    name: 'France 2 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste France',
    icon: Icons.play_circle_fill,
    description: 'Chaine publique d\'information et culture',
  ),
  MediaItem(
    id: 'm6',
    name: 'M6 (via TVRadioZap)',
    url: 'https://tvradiozap.eu/',
    category: 'Divertissement',
    icon: Icons.play_circle_fill,
    description: 'Séries, magazines et divertissements',
  ),
];

// ==========================================
// LISTE COMPLÈTE RADIOS (CHARTE & STATIONS)
// ==========================================
final List<MediaItem> radioChannels = [
  MediaItem(
    id: 'rfi_afrique',
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/en-direct',
    category: 'Information & Débats',
    icon: Icons.radio,
    isRadio: true,
    description: 'L\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'rfi_monde',
    name: 'RFI Monde',
    url: 'https://www.rfi.fr/fr/en-direct',
    category: 'Information Internationale',
    icon: Icons.public,
    isRadio: true,
    description: 'Le journal international en continu',
  ),
  MediaItem(
    id: 'africa_radio',
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Musique & Culture',
    icon: Icons.graphic_eq,
    isRadio: true,
    description: 'Musique africaine, talk-shows et infos',
  ),
  MediaItem(
    id: 'tv_radio_zap_radio',
    name: 'TVRadioZap (Portail Radios)',
    url: 'https://tvradiozap.eu/',
    category: 'Bouquet Radios',
    icon: Icons.cell_tower,
    isRadio: true,
    description: 'Portail complet de stations radios francophones',
  ),
  MediaItem(
    id: 'urban_fm',
    name: 'Urban FM (Gabon)',
    url: 'https://tvradiozap.eu/',
    category: 'Gabon - Musique & Jeunesse',
    icon: Icons.headset,
    isRadio: true,
    description: 'La première radio urbaine du Gabon',
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
                      'Chargement de NGOMBI Direct...',
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
