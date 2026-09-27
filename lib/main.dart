import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import 'models/tv_channel.dart';
import 'screens/stream_player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bouquet = await rootBundle.loadString(
    'assets/tvradiozap.txt',
  );

  final tvChannels = parseEnigma2Bouquet(bouquet);

  runApp(
    NgombiApp(
      tvChannels: tvChannels,
    ),
  );
}

class NgombiApp extends StatelessWidget {
  final List<TvChannel> tvChannels;

  const NgombiApp({
    super.key,
    required this.tvChannels,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGOMBI - TV & Radio Direct',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      ),
      home: const MainTabScreen(),
    );
  }
}

// ============================================================
// MODÈLE DES CHAÎNES
// ============================================================

class MediaItem {
  final String name;
  final String description;
  final String url;
  final IconData icon;

  const MediaItem({
    required this.name,
    required this.description,
    required this.url,
    required this.icon,
  });
}

// ============================================================
// CHAÎNES TV
// ============================================================

const List<MediaItem> tvChannels = [
  MediaItem(
    name: 'Gabon Télévision',
    description: 'Télévision nationale du Gabon',
    url: 'https://www.gabontelevision.ga/',
    icon: Icons.tv,
  ),
  MediaItem(
    name: 'France 24',
    description: 'Actualités internationales en direct',
    url: 'https://www.france24.com/fr/direct',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'Africanews',
    description: 'Actualités africaines',
    url: 'https://www.africanews.com/live/',
    icon: Icons.language,
  ),
  MediaItem(
    name: 'TVRadioZap',
    description: 'Télévision et radio en direct',
    url: 'https://www.tvradiozap.com/',
    icon: Icons.play_circle_fill,
  ),
];

// ============================================================
// RADIOS
// ============================================================

const List<MediaItem> radioChannels = [
  MediaItem(
    name: 'RFI Afrique',
    description: 'Radio France Internationale - Afrique',
    url: 'https://www.rfi.fr/fr/en-direct-radio',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'Africa Radio',
    description: 'La radio africaine',
    url: 'https://www.africaradio.com/',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'Radio Gabon',
    description: 'Radio nationale du Gabon',
    url: 'https://www.radiogabon.ga/',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'Urban FM',
    description: 'Radio urbaine',
    url: 'https://urbanfm-gabon.com/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'BBC Afrique',
    description: 'BBC en français',
    url: 'https://www.bbc.com/afrique',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'Skyrock',
    description: 'La radio rap et R&B',
    url: 'https://www.skyrock.fm/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'Trace FM',
    description: 'Musique urbaine',
    url: 'https://trace.fm/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'NRJ',
    description: 'Hit Music Only',
    url: 'https://www.nrj.fr/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'Nostalgie',
    description: 'Les plus grands tubes',
    url: 'https://www.nostalgie.fr/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'RFI Monde',
    description: 'RFI en direct',
    url: 'https://www.rfi.fr/fr/en-direct-radio',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'France Info',
    description: 'Actualités en continu',
    url: 'https://www.franceinfo.fr/en-direct/radio',
    icon: Icons.newspaper,
  ),
  MediaItem(
    name: 'RMC',
    description: 'Radio et information',
    url: 'https://rmc.bfmtv.com/',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'RTL',
    description: 'Radio RTL',
    url: 'https://www.rtl.fr/direct',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'Europe 1',
    description: 'Europe 1 en direct',
    url: 'https://www.europe1.fr/directs',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'TVRadioZap',
    description: 'Télévision et radio en direct',
    url: 'https://www.tvradiozap.com/',
    icon: Icons.play_circle_fill,
  ),
];

// ============================================================
// ÉCRAN PRINCIPAL
// ============================================================

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.play_circle_fill,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text(
              'NGOMBI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          MediaListScreen(
            title: 'TV en direct',
            items: tvChannels,
            isTv: true,
          ),
          MediaListScreen(
            title: 'Radio en direct',
            items: radioChannels,
            isTv: false,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tv_outlined),
            selectedIcon: Icon(Icons.tv),
            label: 'TV',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio),
            label: 'Radio',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LISTE TV / RADIO
// ============================================================

class MediaListScreen extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final bool isTv;

  const MediaListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.isTv,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 27,
                      child: Icon(item.icon),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(item.description),
                    ),
                    trailing: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WebPlayerScreen(
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
      ),
    );
  }
}

// ============================================================
// LECTEUR WEB
// ============================================================
class MediaListScreen extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final bool isTv;
  final List<TvChannel> tvChannels;

  const MediaListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.isTv,
    this.tvChannels = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Pour la télévision, on utilise maintenant le bouquet local.
    if (isTv && tvChannels.isNotEmpty) {
      return _buildTvList(context);
    }

    // La radio conserve pour l'instant son fonctionnement actuel.
    return _buildMediaList(context);
  }

  Widget _buildTvList(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverList.builder(
              itemCount: tvChannels.length,
              itemBuilder: (context, index) {
                final channel = tvChannels[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 27,
                      child: Text(
                        channel.name.isNotEmpty
                            ? channel.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      channel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        '${channel.category} • ${_streamTypeLabel(channel.type)}',
                      ),
                    ),
                    trailing: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StreamPlayerScreen(
                            channel: channel,
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
      ),
    );
  }

  Widget _buildMediaList(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 27,
                      child: Icon(item.icon),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(item.description),
                    ),
                    trailing: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WebPlayerScreen(
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
      ),
    );
  }

  String _streamTypeLabel(StreamType type) {
    switch (type) {
      case StreamType.hls:
        return 'HLS';
      case StreamType.dash:
        return 'DASH';
      case StreamType.unknown:
        return 'Flux';
    }
  }
}
