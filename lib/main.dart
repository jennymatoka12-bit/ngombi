import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181818),
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Modèle pour les Médias
class MediaItem {
  final String id;
  final String title;
  final String category;
  final String type; // 'TV' ou 'RADIO'
  final String url;
  final String? youtubeVideoId;
  final String logoUrl;

  MediaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.url,
    this.youtubeVideoId,
    required this.logoUrl,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  MediaItem? _currentRadio;
  bool _isPlayingRadio = false;
  bool _isLoadingRadio = false;

  List<String> _favoriteIds = [];
  String _searchQuery = "";
  String _selectedCategory = "Toutes";

  // Catalogue enrichi de chaînes TV & Radio
  final List<MediaItem> _mediaList = [
    // --- TELEVISION ---
    MediaItem(
      id: 'tv_1',
      title: 'Gabon Télévision',
      category: 'Gabon',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=live_gabon_tv',
      youtubeVideoId: 'd9N-J6I8L0g',
      logoUrl: 'https://via.placeholder.com/150?text=Gabon+TV',
    ),
    MediaItem(
      id: 'tv_2',
      title: 'France 24',
      category: 'Infos',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=R9U_sR88Rz8',
      youtubeVideoId: 'R9U_sR88Rz8',
      logoUrl: 'https://via.placeholder.com/150?text=France+24',
    ),
    MediaItem(
      id: 'tv_3',
      title: 'Africanews',
      category: 'Infos',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=gCNeDWCI010',
      youtubeVideoId: 'gCNeDWCI010',
      logoUrl: 'https://via.placeholder.com/150?text=Africanews',
    ),
    MediaItem(
      id: 'tv_4',
      title: 'TVRadioZap (Bouquet Web)',
      category: 'Bouquet TV',
      type: 'TV',
      url: 'https://tvradiozap.eu/',
      youtubeVideoId: null,
      logoUrl: 'https://via.placeholder.com/150?text=TVRadioZap',
    ),

    // --- RADIOS ---
    MediaItem(
      id: 'radio_1',
      title: 'Radio Gabon (RTG)',
      category: 'Gabon',
      type: 'RADIO',
      url: 'https://stream.zeno.fm/f3wvbb1v28quv',
      logoUrl: 'https://via.placeholder.com/150?text=Radio+Gabon',
    ),
    MediaItem(
      id: 'radio_2',
      title: 'Urban FM 104.5',
      category: 'Gabon',
      type: 'RADIO',
      url: 'https://stream.zeno.fm/f3wvbb1v28quv',
      logoUrl: 'https://via.placeholder.com/150?text=Urban+FM',
    ),
    MediaItem(
      id: 'radio_3',
      title: 'RFI Afrique',
      category: 'Infos',
      type: 'RADIO',
      url: 'https://rfiafrique.ice.infomaniak.ch/rfiafrique-64.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=RFI+Afrique',
    ),
    MediaItem(
      id: 'radio_4',
      title: 'Africa Radio',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://africaradio.ice.infomaniak.ch/africaradio-128.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=Africa+Radio',
    ),
    MediaItem(
      id: 'radio_5',
      title: 'BBC Afrique',
      category: 'Infos',
      type: 'RADIO',
      url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      logoUrl: 'https://via.placeholder.com/150?text=BBC+Afrique',
    ),
    MediaItem(
      id: 'radio_6',
      title: 'Skyrock FM',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://icecast.skyrock.net/s/natio_mp3_128k',
      logoUrl: 'https://via.placeholder.com/150?text=Skyrock',
    ),
    MediaItem(
      id: 'radio_7',
      title: 'Trace FM',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://trace.ice.infomaniak.ch/trace-128.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=Trace+FM',
    ),
    MediaItem(
      id: 'radio_8',
      title: 'NRJ Hits',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://cdn.nrjaudio.fm/audio/1/fr/30001/mp3_128.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=NRJ',
    ),
    MediaItem(
      id: 'radio_9',
      title: 'Nostalgie',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://cdn.nrjaudio.fm/audio/1/fr/30601/mp3_128.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=Nostalgie',
    ),
    MediaItem(
      id: 'radio_10',
      title: 'France Info',
      category: 'Infos',
      type: 'RADIO',
      url: 'https://icecast.radiofrance.fr/franceinfo-midfi.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=France+Info',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingRadio = state.playing;
          _isLoadingRadio = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    await prefs.setStringList('favorites', _favoriteIds);
  }

  Future<void> _playRadio(MediaItem item) async {
    try {
      if (_currentRadio?.id == item.id && _isPlayingRadio) {
        await _audioPlayer.pause();
        return;
      }

      setState(() {
        _currentRadio = item;
      });

      await _audioPlayer.setUrl(item.url);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de lire le flux radio : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopRadio() {
    _audioPlayer.stop();
    setState(() {
      _currentRadio = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGOMBI Direct', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE50914),
          tabs: const [
            Tab(icon: Icon(Icons.tv), text: "TÉLÉVISION"),
            Tab(icon: Icon(Icons.radio), text: "RADIO"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaGrid('TV'),
                _buildMediaGrid('RADIO'),
              ],
            ),
          ),
          if (_currentRadio != null) _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final categories = ["Toutes", "Gabon", "Infos", "Musique", "Bouquet TV"];

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Rechercher une chaîne...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE50914),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFF2C2C2C),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(String type) {
    var filteredList = _mediaList.where((item) {
      final matchesType = item.type == type;
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "Toutes" || item.category == _selectedCategory;
      return matchesType && matchesSearch && matchesCategory;
    }).toList();

    filteredList.sort((a, b) {
      final aFav = _favoriteIds.contains(a.id) ? 0 : 1;
      final bFav = _favoriteIds.contains(b.id) ? 0 : 1;
      return aFav.compareTo(bFav);
    });

    if (filteredList.isEmpty) {
      return const Center(child: Text("Aucune chaîne trouvée."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final isFav = _favoriteIds.contains(item.id);
        final isSelectedRadio = _currentRadio?.id == item.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE50914),
              child: Text(
                item.title.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.category} • Direct'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(item.id),
                ),
                if (type == 'TV')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Regarder'),
                    onPressed: () => _openTvPlayer(item),
                  )
                else
                  IconButton(
                    icon: Icon(
                      isSelectedRadio && _isPlayingRadio ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: const Color(0xFFE50914),
                      size: 36,
                    ),
                    onPressed: () => _playRadio(item),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      color: const Color(0xFF2C2C2C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.radio, color: Color(0xFFE50914)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentRadio!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "En cours de lecture...",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (_isLoadingRadio)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
            )
          else
            IconButton(
              icon: Icon(_isPlayingRadio ? Icons.pause : Icons.play_arrow),
              onPressed: () => _playRadio(_currentRadio!),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _stopRadio,
          ),
        ],
      ),
    );
  }

  void _openTvPlayer(MediaItem item) {
    if (item.youtubeVideoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvPlayerScreen(item: item),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebTvPlayerScreen(item: item),
        ),
      );
    }
  }
}

// Lecteur Vidéo YouTube
class TvPlayerScreen extends StatefulWidget {
  final MediaItem item;

  const TvPlayerScreen({super.key, required this.item});

  @override
  State<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends State<TvPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.item.youtubeVideoId!,
      flags: const YoutubePlayerFlags(
        isLive: true,
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFE50914),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Catégorie : ${widget.item.category}'),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Ouvrir dans l'application YouTube"),
                  onPressed: () {
                    final url = 'https://www.youtube.com/watch?v=${widget.item.youtubeVideoId}';
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Lecteur Web pour les liens hors YouTube
class WebTvPlayerScreen extends StatefulWidget {
  final MediaItem item;

  const WebTvPlayerScreen({super.key, required this.item});

  @override
  State<WebTvPlayerScreen> createState() => _WebTvPlayerScreenState();
}

class _WebTvPlayerScreenState extends State<WebTvPlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.item.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
