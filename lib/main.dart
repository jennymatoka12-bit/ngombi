import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Model pour les Médias
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

  // Base de données des chaînes TV & Radio
  final List<MediaItem> _mediaList = [
    // TV
    MediaItem(
      id: 'tv_1',
      title: 'Gabon Télévision',
      category: 'Gabon',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=live_gabon_tv',
      youtubeVideoId: 'd9N-J6I8L0g', // ID YouTube du direct
      logoUrl: 'https://via.placeholder.com/150?text=Gabon+TV',
    ),
    MediaItem(
      id: 'tv_2',
      title: 'France 24',
      category: 'Infos',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=live_f24',
      youtubeVideoId: 'gCNeDWCI0vo',
      logoUrl: 'https://via.placeholder.com/150?text=France+24',
    ),
    MediaItem(
      id: 'tv_3',
      title: 'Africanews',
      category: 'Infos',
      type: 'TV',
      url: 'https://www.youtube.com/watch?v=live_africanews',
      youtubeVideoId: 's_8R-3Z_Ibc',
      logoUrl: 'https://via.placeholder.com/150?text=Africanews',
    ),
    
    // RADIOS
    MediaItem(
      id: 'radio_1',
      title: 'Radio Gabon',
      category: 'Gabon',
      type: 'RADIO',
      url: 'http://stream.zeno.fm/f32b8429948h', // Exemple de flux HTTP
      logoUrl: 'https://via.placeholder.com/150?text=Radio+Gabon',
    ),
    MediaItem(
      id: 'radio_2',
      title: 'Urban FM Gabon',
      category: 'Musique',
      type: 'RADIO',
      url: 'https://stream.zeno.fm/v77u2v45e5quv',
      logoUrl: 'https://via.placeholder.com/150?text=Urban+FM',
    ),
    MediaItem(
      id: 'radio_3',
      title: 'RFI Afrique',
      category: 'Infos',
      type: 'RADIO',
      url: 'https://rfiafrique96k.ice.infomaniak.ch/rfiafrique-96k.mp3',
      logoUrl: 'https://via.placeholder.com/150?text=RFI+Afrique',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();

    // Écoute des états du lecteur audio
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

  // Chargement et Sauvegarde des Favoris
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

  // Gestion de la lecture Radio
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
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.tv), text: "TÉLÉVISION"),
            Tab(icon: Icon(Icons.radio), text: "RADIO"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche et catégories
          _buildSearchAndFilterBar(),
          
          // Contenu principal (Listes)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaGrid('TV'),
                _buildMediaGrid('RADIO'),
              ],
            ),
          ),
          
          // Mini-Lecteur Audio Flottant
          if (_currentRadio != null) _buildMiniPlayer(),
        ],
      ),
    );
  }

  // Barre de Filtre & Recherche
  Widget _buildSearchAndFilterBar() {
    final categories = ["Toutes", "Gabon", "Infos", "Musique"];

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Rechercher une chaîne...',
              prefixIcon: const Icon(Icons.search, color: Colors.amber),
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
                    selectedColor: Colors.amber,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
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

  // Grille / Liste des Médias
  Widget _buildMediaGrid(String type) {
    var filteredList = _mediaList.where((item) {
      final matchesType = item.type == type;
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "Toutes" || item.category == _selectedCategory;
      return matchesType && matchesSearch && matchesCategory;
    }).toList();

    // Tri pour placer les favoris en premier
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
              backgroundColor: Colors.amber.shade800,
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
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Regarder'),
                    onPressed: () => _openTvPlayer(item),
                  )
                else
                  IconButton(
                    icon: Icon(
                      isSelectedRadio && _isPlayingRadio ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.amber,
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

  // Mini-Lecteur Audio Flottant
  Widget _buildMiniPlayer() {
    return Container(
      color: const Color(0xFF2C2C2C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.radio, color: Colors.amber),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
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

  // Ouverture du lecteur TV YouTube
  void _openTvPlayer(MediaItem item) {
    if (item.youtubeVideoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvPlayerScreen(item: item),
        ),
      );
    } else {
      // Fallback Lien Web
      _launchExternalUrl(item.url);
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Page du lecteur vidéo YouTube natif (Affiche la vidéo sans erreurs 153/150)
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
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.amber,
            onReady: () {},
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
                  label: const Text("Ouvrir dans l'application YouTube (Secours)"),
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
