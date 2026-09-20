import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NgombiApp());
}

// ==========================================
// MODÈLE DE DONNÉES ENRICHI
// ==========================================
class MediaItem {
  final String id;
  final String name;
  final String url;
  final String? lowQualityUrl; // Mode Économie de données
  final String category;
  final IconData icon;
  final bool isAudioStream;
  final String description;

  MediaItem({
    required this.id,
    required this.name,
    required this.url,
    this.lowQualityUrl,
    required this.category,
    required this.icon,
    this.isAudioStream = false,
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
    url: 'https://www.youtube.com/embed/live_stream?channel=UC7K23_V1HkY0Y_K0vN69A5g',
    category: 'Gabon',
    icon: Icons.tv,
    description: 'Chaîne officielle de télévision nationale du Gabon',
  ),
  MediaItem(
    id: 'france24_fr',
    name: 'France 24 Direct',
    url: 'https://www.youtube.com/embed/R9U_sR88Rz8?autoplay=1',
    category: 'Information',
    icon: Icons.language,
    description: 'L\'information internationale 24h/24 en français',
  ),
  MediaItem(
    id: 'africanews',
    name: 'Africanews Direct',
    url: 'https://www.youtube.com/embed/gCNeDWCI010?autoplay=1',
    category: 'Information',
    icon: Icons.public,
    description: 'Toute l\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'tv_radio_zap_tv',
    name: 'TVRadioZap (Portail TV)',
    url: 'https://tvradiozap.eu/',
    category: 'Generaliste',
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
    url: 'https://live02.rfi.fr/rfiafrique-96k.mp3',
    lowQualityUrl: 'https://live02.rfi.fr/rfiafrique-64k.mp3',
    category: 'Information',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'L\'actualité du continent africain en direct',
  ),
  MediaItem(
    id: 'africa_radio',
    name: 'Africa Radio',
    url: 'https://africaradio.ice.infomaniak.ch/africaradio-128.mp3',
    category: 'Musique & Culture',
    icon: Icons.graphic_eq,
    isAudioStream: true,
    description: 'Musiques d\'Afrique, talk-shows et informations',
  ),
  MediaItem(
    id: 'radio_gabon',
    name: 'Radio Gabon (RTG)',
    url: 'https://stream.zeno.fm/f3wvbb1v28quv',
    category: 'Gabon',
    icon: Icons.cell_tower,
    isAudioStream: true,
    description: 'Chaîne radio nationale du Gabon',
  ),
  MediaItem(
    id: 'urban_fm',
    name: 'Urban FM 104.5 (Gabon)',
    url: 'https://stream.zeno.fm/48u158a1v28qu',
    category: 'Gabon',
    icon: Icons.headset,
    isAudioStream: true,
    description: 'La 1ère radio urbaine de Libreville',
  ),
  MediaItem(
    id: 'bbc_afrique',
    name: 'BBC Afrique Radio',
    url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
    category: 'Information',
    icon: Icons.newspaper,
    isAudioStream: true,
    description: 'Journaux et analyses BBC en français',
  ),
  MediaItem(
    id: 'trace_fm',
    name: 'Trace FM Afrique',
    url: 'https://trace.ice.infomaniak.ch/trace-128.mp3',
    category: 'Musique',
    icon: Icons.music_note,
    isAudioStream: true,
    description: 'Les meilleurs hits urbains et Afrobeats',
  ),
  MediaItem(
    id: 'skyrock',
    name: 'Skyrock FM',
    url: 'https://icecast.skyrock.net/s/natio_mp3_128k',
    category: 'Musique',
    icon: Icons.speaker_group,
    isAudioStream: true,
    description: 'Premier sur le Rap et les Musiques Urbaines',
  ),
  MediaItem(
    id: 'nrj',
    name: 'NRJ Hit Music Only',
    url: 'https://cdn.nrjaudio.fm/audio/1/fr/30001/mp3_128.mp3',
    category: 'Musique',
    icon: Icons.library_music,
    isAudioStream: true,
    description: 'Hit Music Only - Les plus grands hits du moment',
  ),
  MediaItem(
    id: 'nostalgie',
    name: 'Nostalgie',
    url: 'https://cdn.nrjaudio.fm/audio/1/fr/30601/mp3_128.mp3',
    category: 'Musique',
    icon: Icons.album,
    isAudioStream: true,
    description: 'Les plus grandes chansons des années 80, 90 et 2000',
  ),
  MediaItem(
    id: 'cherie_fm',
    name: 'Chérie FM',
    url: 'https://cdn.nrjaudio.fm/audio/1/fr/30201/mp3_128.mp3',
    category: 'Musique',
    icon: Icons.favorite,
    isAudioStream: true,
    description: 'La plus belle musique et les plus beaux hits',
  ),
  MediaItem(
    id: 'rfm',
    name: 'RFM',
    url: 'https://rfm.ice.infomaniak.ch/rfm-128.mp3',
    category: 'Musique',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'Le meilleur de la musique Pop Rock',
  ),
  MediaItem(
    id: 'fun_radio',
    name: 'Fun Radio',
    url: 'https://icecast.rtl.fr/fun-1-44-128?listen=webcmedia',
    category: 'Musique',
    icon: Icons.headphones,
    isAudioStream: true,
    description: 'Le son Dance Electro & Party',
  ),
  MediaItem(
    id: 'rtl2',
    name: 'RTL2',
    url: 'https://icecast.rtl.fr/rtl2-1-44-128?listen=webcmedia',
    category: 'Musique',
    icon: Icons.queue_music,
    isAudioStream: true,
    description: 'Le son Pop-Rock',
  ),
  MediaItem(
    id: 'mouv',
    name: 'Mouv\'',
    url: 'https://icecast.radiofrance.fr/mouv-midfi.mp3',
    category: 'Musique',
    icon: Icons.graphic_eq,
    isAudioStream: true,
    description: 'Rap, Hip-Hop et cultures urbaines',
  ),
  MediaItem(
    id: 'rfi_monde',
    name: 'RFI Monde',
    url: 'https://live02.rfi.fr/rfimonde-96k.mp3',
    category: 'Information',
    icon: Icons.public,
    isAudioStream: true,
    description: 'Journal international en continu',
  ),
  MediaItem(
    id: 'rmc',
    name: 'RMC Info Talk Sport',
    url: 'https://audio.bfmtv.com/rmc_mp3',
    category: 'Talk & Sport',
    icon: Icons.mic,
    isAudioStream: true,
    description: 'Actualité, débats et retransmissions sportives',
  ),
  MediaItem(
    id: 'france_info',
    name: 'France Info',
    url: 'https://icecast.radiofrance.fr/franceinfo-midfi.mp3',
    category: 'Information',
    icon: Icons.info_outline,
    isAudioStream: true,
    description: 'L\'information en continu 24h/24',
  ),
  MediaItem(
    id: 'rtl',
    name: 'RTL',
    url: 'https://icecast.rtl.fr/rtl-1-44-128?listen=webcmedia',
    category: 'Generaliste',
    icon: Icons.radio,
    isAudioStream: true,
    description: 'Chroniqueurs, journaux et divertissement',
  ),
  MediaItem(
    id: 'europe1',
    name: 'Europe 1',
    url: 'https://stream.europe1.fr/europe1.mp3',
    category: 'Generaliste',
    icon: Icons.podcasts,
    isAudioStream: true,
    description: 'Émissions d\'actualité, culture et politique',
  ),
];

// ==========================================
// GESTIONNAIRE D'ÉTAT AUDIO CENTRALISÉ (SINGLETON)
// ==========================================
class NgombiAudioHandler extends ChangeNotifier {
  static final NgombiAudioHandler _instance = NgombiAudioHandler._internal();
  factory NgombiAudioHandler() => _instance;

  NgombiAudioHandler._internal() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering;
      notifyListeners();
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  MediaItem? _currentMedia;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _useLowDataMode = false;
  Timer? _sleepTimer;
  Duration? _remainingSleepTime;

  MediaItem? get currentMedia => _currentMedia;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get useLowDataMode => _useLowDataMode;
  Duration? get remainingSleepTime => _remainingSleepTime;

  Future<void> playMedia(MediaItem item) async {
    _currentMedia = item;
    notifyListeners();
    try {
      final streamUrl = (_useLowDataMode && item.lowQualityUrl != null) 
          ? item.lowQualityUrl! 
          : item.url;
      await _audioPlayer.setUrl(streamUrl);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Erreur de lecture : $e");
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void stop() {
    _audioPlayer.stop();
    _currentMedia = null;
    cancelSleepTimer();
    notifyListeners();
  }

  void toggleLowDataMode() {
    _useLowDataMode = !_useLowDataMode;
    if (_currentMedia != null) {
      playMedia(_currentMedia!);
    }
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _remainingSleepTime = Duration(minutes: minutes);
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSleepTime!.inSeconds <= 1) {
        stop();
        timer.cancel();
      } else {
        _remainingSleepTime = Duration(seconds: _remainingSleepTime!.inSeconds - 1);
        notifyListeners();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _remainingSleepTime = null;
    notifyListeners();
  }
}

// ==========================================
// APPLICATION PRINCIPALE
// ==========================================
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
          centerTitle: false,
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

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Toutes';
  final List<String> _favoriteIds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds.addAll(prefs.getStringList('favorites') ?? []);
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

  List<MediaItem> _filterItems(List<MediaItem> items) {
    return items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Toutes' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = NgombiAudioHandler();

    // Construction de la liste des catégories uniques
    final allItems = [...tvChannels, ...radioChannels];
    final categories = ['Toutes', ...{...allItems.map((e) => e.category)}];

    final favoriteItems = allItems.where((e) => _favoriteIds.contains(e.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
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
      body: Column(
        children: [
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une chaîne ou radio...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTRE PAR CATÉGORIES (Filtres défilants)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE50914),
                    backgroundColor: const Color(0xFF1E1E1E),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : 'Toutes';
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // CONTENU PRINCIPAL
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                MediaListView(
                  items: _filterItems(tvChannels),
                  favoriteIds: _favoriteIds,
                  onToggleFavorite: _toggleFavorite,
                ),
                MediaListView(
                  items: _filterItems(radioChannels),
                  favoriteIds: _favoriteIds,
                  onToggleFavorite: _toggleFavorite,
                ),
                MediaListView(
                  items: _filterItems(favoriteItems),
                  favoriteIds: _favoriteIds,
                  onToggleFavorite: _toggleFavorite,
                ),
              ],
            ),
          ),

          // MINI-PLAYER RADIO RÉMANENT (Style TNT Flash TV / Spotify)
          AnimatedBuilder(
            animation: audioHandler,
            builder: (context, _) {
              if (audioHandler.currentMedia == null) return const SizedBox.shrink();
              final current = audioHandler.currentMedia!;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPlayerScreen(item: current),
                    ),
                  );
                },
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF282828),
                    border: Border(top: BorderSide(color: Color(0xFFE50914), width: 2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(current.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              current.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              audioHandler.isBuffering
                                  ? 'Connexion au flux direct...'
                                  : 'En direct - ${current.category}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (audioHandler.isBuffering)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
                        )
                      else
            
