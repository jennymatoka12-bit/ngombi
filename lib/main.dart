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
        scaffoldBackgroundColor: const Color(0xFF121212), // Noir Profond
        primaryColor: const Color(0xFFE50914), // Rouge Vibrant
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          surface: Color(0xFF1F1F1F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        tabBarTheme: const TabBarTheme(
          indicatorColor: Color(0xFFE50914),
          labelColor: Color(0xFFE50914),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

// Model pour les médias
class MediaItem {
  final String id;
  final String name;
  final String url;
  final String category;
  final bool isRadio;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    this.isRadio = false,
  });
}

// Base de données des chaînes TV
final List<MediaItem> tvChannels = [
  MediaItem(
    id: 'tv_1',
    name: 'Gabon Télévision',
    url: 'https://m.youtube.com/results?search_query=gabon+television+en+direct',
    category: 'Gabon - Direct & Replay',
  ),
  MediaItem(
    id: 'tv_2',
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Chaînes Françaises & Int.',
  ),
  MediaItem(
    id: 'tv_3',
    name: 'TF1 Direct',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
  MediaItem(
    id: 'tv_4',
    name: 'France 2 Direct',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
  MediaItem(
    id: 'tv_5',
    name: 'M6 Direct',
    url: 'https://tvradiozap.eu/',
    category: 'Généraliste',
  ),
];

// Base de données des Radios
final List<MediaItem> radioChannels = [
  MediaItem(
    id: 'radio_1',
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/podcasts/direct-afrique',
    category: 'Afrique - Info & Actualités',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_2',
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Afrique - Musique & Culture',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_3',
    name: 'BBC News Afrique',
    url: 'https://www.bbc.com/afrique',
    category: 'Afrique - Actualités',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_4',
    name: 'RFI Monde',
    url: 'https://www.rfi.fr/fr/podcasts/direct-monde',
    category: 'International - Information',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_5',
    name: 'France Info',
    url: 'https://www.francetvinfo.fr/en-direct/radio.html',
    category: 'International - Info Continu',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_6',
    name: 'France Inter',
    url: 'https://www.radiofrance.fr/franceinter/direct',
    category: 'International - Généraliste',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_7',
    name: 'Trace FM Afrique',
    url: 'https://www.radio.fr/s/tracefm',
    category: 'Musique - Afrobeats & Urban',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_8',
    name: 'NRJ International',
    url: 'https://www.nrj.fr/live',
    category: 'Musique - Hits Pop',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_9',
    name: 'Skyrock',
    url: 'https://skyrock.fm/',
    category: 'Musique - Rap & Urban',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_10',
    name: 'Nostalgie Afrique',
    url: 'https://www.radio.fr/s/nostalgie',
    category: 'Musique - Retro & Classiques',
    isRadio: true,
  ),
  MediaItem(
    id: 'radio_11',
    name: 'Portail Radio.fr (Monde)',
    url: 'https://www.radio.fr/',
    category: 'Recherche +60 000 Radios',
    isRadio: true,
  ),
];

// Écran Principal avec Onglets
class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo NGOMBI Stylisé
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'NGOMBI',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.live_tv), text: 'Télévision'),
              Tab(icon: Icon(Icons.radio), text: 'Radios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaTabWithSearch(items: tvChannels, isRadioTab: false),
            MediaTabWithSearch(items: radioChannels, isRadioTab: true),
          ],
        ),
      ),
    );
  }
}

// Vue Onglet avec Recherche Intégrée
class MediaTabWithSearch extends StatefulWidget {
  final List<MediaItem> items;
  final bool isRadioTab;

  const MediaTabWithSearch({
    super.key,
    required this.items,
    required this.isRadioTab,
  });

  @override
  State<MediaTabWithSearch> createState() => _MediaTabWithSearchState();
}

class _MediaTabWithSearchState extends State<MediaTabWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      final nameMatch = item.name.toLowerCase().contains(_searchQuery);
      final catMatch = item.category.toLowerCase().contains(_searchQuery);
      return nameMatch || catMatch;
    }).toList();

    return Column(
      children: [
        // Barre de recherche NGOMBI
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.isRadioTab
                  ? 'Rechercher une radio ou catégorie...'
                  : 'Rechercher une chaîne TV...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
              ),
            ),
          ),
        ),

        // Liste des médias
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.white24),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun résultat pour "$_searchQuery"',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.isRadio ? Icons.radio : Icons.play_arrow_rounded,
                            color: const Color(0xFFE50914),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.category,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 14,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebPlayerScreen(
                                title: item.name,
                                url: item.url,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Lecteur Web avec User-Agent Desktop
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
      ..setUserAgent(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
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
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
        ],
      ),
    );
  }
}
