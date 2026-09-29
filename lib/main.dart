import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

const List<MediaItem> radioChannels = [
  MediaItem(
    name: 'RFI Afrique',
    description: 'Radio France Internationale - Afrique',
    url: 'https://www.rfi.fr/fr/en-direct-afrique',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'Africa Radio',
    description: 'Radio africaine',
    url: 'https://www.africaradio.com/',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'Radio Gabon',
    description: 'Radio nationale du Gabon',
    url: 'https://radiogabon.ga/',
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
    description: 'BBC Afrique',
    url: 'https://www.bbc.com/afrique',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'Skyrock',
    description: 'Skyrock',
    url: 'https://skyrock.fm/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'Trace FM',
    description: 'Trace FM',
    url: 'https://trace.fm/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'NRJ',
    description: 'NRJ',
    url: 'https://www.nrj.fr/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'Nostalgie',
    description: 'Nostalgie',
    url: 'https://www.nostalgie.fr/',
    icon: Icons.music_note,
  ),
  MediaItem(
    name: 'RFI Monde',
    description: 'Radio France Internationale',
    url: 'https://www.rfi.fr/fr/en-direct',
    icon: Icons.public,
  ),
  MediaItem(
    name: 'France Info',
    description: 'Actualités France Info',
    url: 'https://www.franceinfo.fr/en-direct/radio',
    icon: Icons.newspaper,
  ),
  MediaItem(
    name: 'RMC',
    description: 'RMC',
    url: 'https://rmc.bfmtv.com/',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'RTL',
    description: 'RTL',
    url: 'https://www.rtl.fr/direct',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'Europe 1',
    description: 'Europe 1',
    url: 'https://www.europe1.fr/directs',
    icon: Icons.radio,
  ),
  MediaItem(
    name: 'TVRadioZap',
    description: 'TV & Radio Direct',
    url: 'https://tvradiozap.eu/',
    icon: Icons.live_tv,
  ),
];

class NgombiApp extends StatelessWidget {
  final List<TvChannel> tvChannels;

  const NgombiApp({
    super.key,
    required this.tvChannels,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);
    const gold = Color(0xFFFFB52E);
    const background = Color(0xFF080808);

    return MaterialApp(
      title: 'NGOMBI - TV & Radio Direct',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
        ).copyWith(
          primary: orange,
          secondary: gold,
          surface: const Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF111111),
          indicatorColor: orange.withValues(alpha: 0.22),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF151515),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: MainTabScreen(
        tvChannels: tvChannels,
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  final List<TvChannel> tvChannels;

  const MainTabScreen({
    super.key,
    required this.tvChannels,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        tvChannels: widget.tvChannels,
        radioChannels: radioChannels,
        onOpenTv: () {
          setState(() {
            currentIndex = 1;
          });
        },
        onOpenRadio: () {
          setState(() {
            currentIndex = 2;
          });
        },
      ),
      MediaListScreen(
        title: 'Télévision',
        items: const [],
        isTv: true,
        tvChannels: widget.tvChannels,
      ),
      const MediaListScreen(
        title: 'Radio',
        items: radioChannels,
        isTv: false,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.tv_outlined),
            selectedIcon: Icon(Icons.tv_rounded),
            label: 'TV',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio_rounded),
            label: 'Radio',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<TvChannel> tvChannels;
  final List<MediaItem> radioChannels;
  final VoidCallback onOpenTv;
  final VoidCallback onOpenRadio;

  const HomeScreen({
    super.key,
    required this.tvChannels,
    required this.radioChannels,
    required this.onOpenTv,
    required this.onOpenRadio,
  });

  @override
  Widget build(BuildContext context) {
    final popularChannels = tvChannels.take(6).toList();

    final categories = <String>[
      'Afrique',
      'France',
      'Information',
      'Sport',
      'Cinéma',
      'Musique',
      'Jeunesse',
      'International',
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          SliverToBoxAdapter(
            child: _buildHero(context),
          ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(
              context,
              title: 'En direct',
              action: 'Voir tout',
              onTap: onOpenTv,
            ),
          ),

          if (popularChannels.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: popularChannels.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 12);
                  },
                  itemBuilder: (context, index) {
                    return _buildChannelCard(
                      context,
                      popularChannels[index],
                    );
                  },
                ),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(
              context,
              title: 'Catégories',
              action: null,
              onTap: null,
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 105,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 10);
                },
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index],
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(
              context,
              title: 'Radio',
              action: 'Voir tout',
              onTap: onOpenRadio,
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: radioChannels.length.clamp(0, 6),
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final radio = radioChannels[index];

                  return _buildRadioCard(
                    context,
                    radio,
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        10,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF8A00),
                  Color(0xFFFFB52E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NGOMBI',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'TV & RADIO',
                  style: TextStyle(
                    color: Color(0xFFFFA31A),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        8,
      ),
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF321900),
              Color(0xFF17100A),
              Color(0xFF0E0E0E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Color(0x33FF9D1A),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x22FF9D1A),
                    width: 25,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'EN DIRECT',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Le monde en direct',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Regardez la télévision et écoutez la radio.',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  FilledButton.icon(
                    onPressed: onOpenTv,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                    ),
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    label: const Text(
                      'Regarder maintenant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required String? action,
    required VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        22,
        16,
        12,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (action != null && onTap != null)
            TextButton(
              onPressed: onTap,
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: Color(0xFFFFA31A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context,
    TvChannel channel,
  ) {
    return SizedBox(
      width: 155,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StreamPlayerScreen(
                  channel: channel,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF202020),
                  child: channel.logo != null
                      ? Image.network(
                          channel.logo!,
                          fit: BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return _channelPlaceholder(channel);
                          },
                        )
                      : _channelPlaceholder(channel),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 7,
                          color: Color(0xFFFF8A00),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'EN DIRECT',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _channelPlaceholder(TvChannel channel) {
    return Center(
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF8A00).withValues(
            alpha: 0.16,
          ),
        ),
        child: Center(
          child: 
