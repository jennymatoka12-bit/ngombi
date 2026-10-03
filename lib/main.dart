import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'widgets/ngombi_logo.dart';

import 'models/tv_channel.dart';
import 'screens/stream_player_screen.dart';
import 'widgets/channel_logo.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ngombi_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    MediaKit.ensureInitialized();
  }

  await NgombiStore.instance.init();

  String bouquetContent = '';

  try {
    bouquetContent = await rootBundle.loadString(
      'assets/tvradiozap.txt',
    );
  } catch (_) {
    bouquetContent = '';
  }

  final tvChannels = parseEnigma2Bouquet(bouquetContent);

  runApp(
    NgombiApp(
      tvChannels: tvChannels,
    ),
  );
}

// -----------------------------------------------------------------------------
// RADIO
// -----------------------------------------------------------------------------

class MediaItem {
  final String name;
  final String url;
  final String category;
  final IconData icon;

  const MediaItem({
    required this.name,
    required this.url,
    required this.category,
    this.icon = Icons.radio_rounded,
  });
}

const List<MediaItem> radioChannels = [
  MediaItem(
    name: 'RFI Afrique',
    url: 'https://www.rfi.fr/fr/en-direct-radio',
    category: 'Afrique',
  ),
  MediaItem(
    name: 'Africa Radio',
    url: 'https://www.africaradio.com/',
    category: 'Afrique',
  ),
  MediaItem(
    name: 'Radio Gabon',
    url: 'https://www.facebook.com/RadioGabon/',
    category: 'Afrique',
  ),
  MediaItem(
    name: 'Urban FM',
    url: 'https://www.urbanfm.net/',
    category: 'Musique',
  ),
  MediaItem(
    name: 'BBC Afrique',
    url: 'https://www.bbc.com/afrique',
    category: 'Information',
  ),
  MediaItem(
    name: 'Skyrock',
    url: 'https://skyrock.fm/',
    category: 'Musique',
  ),
  MediaItem(
    name: 'Trace FM',
    url: 'https://trace.fm/',
    category: 'Musique',
  ),
  MediaItem(
    name: 'NRJ',
    url: 'https://www.nrj.fr/',
    category: 'Musique',
  ),
  MediaItem(
    name: 'Nostalgie',
    url: 'https://www.nostalgie.fr/',
    category: 'Musique',
  ),
  MediaItem(
    name: 'RFI Monde',
    url: 'https://www.rfi.fr/fr/en-direct-radio',
    category: 'International',
  ),
  MediaItem(
    name: 'France Info',
    url: 'https://www.franceinfo.fr/en-direct/radio',
    category: 'Information',
  ),
  MediaItem(
    name: 'RMC',
    url: 'https://rmc.bfmtv.com/',
    category: 'Information',
  ),
  MediaItem(
    name: 'RTL',
    url: 'https://www.rtl.fr/',
    category: 'Information',
  ),
  MediaItem(
    name: 'Europe 1',
    url: 'https://www.europe1.fr/',
    category: 'Information',
  ),
  MediaItem(
    name: 'TVRadioZap',
    url: 'https://tvradiozap.eu/',
    category: 'International',
  ),
];

// -----------------------------------------------------------------------------
// APPLICATION
// -----------------------------------------------------------------------------

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
      debugShowCheckedModeBanner: false,
      title: 'NGOMBI - TV & RADIO Direct',
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
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF111111),
          indicatorColor: orange.withOpacity(0.22),
          labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
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

// -----------------------------------------------------------------------------
// NAVIGATION PRINCIPALE
// -----------------------------------------------------------------------------

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
      TvScreen(
        tvChannels: widget.tvChannels,
      ),
      const RadioScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktopLayout = constraints.maxWidth >= 900;

        if (desktopLayout) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.75,
                  leading: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: NgombiLogo.icon(height: 42),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Accueil'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tv_outlined),
                      selectedIcon: Icon(Icons.tv_rounded),
                      label: Text('TV'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.radio_outlined),
                      selectedIcon: Icon(Icons.radio_rounded),
                      label: Text('Radio'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.star_border_rounded),
                      selectedIcon: Icon(Icons.star_rounded),
                      label: Text('Bibliothèque'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          );
        }

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
              NavigationDestination(
                icon: Icon(Icons.star_border_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Bibliothèque',
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// HERO NGOMBI
// -----------------------------------------------------------------------------

class NgombiHero extends StatelessWidget {
  const NgombiHero({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF241010),
            Color(0xFF111111),
          ],
        ),
        border: Border.all(
          color: const Color(0x33FF7043),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -15,
            child: CustomPaint(
              size: const Size(210, 210),
              painter: NgombiWavePainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NgombiLogo.full(
                  height: 42,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Le monde en direct',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'TV & Radio, où que vous soyez.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NgombiWavePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x66FF7043);

    for (int i = 0; i < 7; i++) {
      final path = Path();
      final y = 35.0 + (i * 22);

      path.moveTo(10, y);

      path.cubicTo(
        size.width * 0.25,
        y - 25,
        size.width * 0.35,
        y + 25,
        size.width * 0.55,
        y,
      );

      path.cubicTo(
        size.width * 0.72,
        y - 22,
        size.width * 0.82,
        y + 22,
        size.width,
        y,
      );

      canvas.drawPath(
        path,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// -----------------------------------------------------------------------------
// ACCUEIL
// -----------------------------------------------------------------------------

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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          const SliverToBoxAdapter(
            child: NgombiHero(),
          ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(
              context,
              'En direct',
              'Voir les chaînes TV',
              onOpenTv,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildTvCarousel(context),
          ),

          SliverToBoxAdapter(            child: _buildSectionTitle(
              context,
              'Catégories',
              null,
              null,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildCategories(context),
          ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(
              context,
              'Radio',
              'Toutes les radios',
              onOpenRadio,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildRadioCarousel(context),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final result = await showSearch<NgombiSearchResult?>(
      context: context,
      delegate: NgombiSearchDelegate(
        tvChannels: tvChannels,
        radioChannels: radioChannels,
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    if (result.tvChannel != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StreamPlayerScreen(
            channel: result.tvChannel!,
          ),
        ),
      );
      return;
    }

    if (result.radioChannel != null) {
      final radio = result.radioChannel!;
      NgombiStore.instance.recordRadio(
        name: radio.name,
        url: radio.url,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WebPlayerScreen(
            title: radio.name,
            url: radio.url,
          ),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        4,
      ),
      child: Row(
        children: [
          const NgombiLogo.icon(
            height: 42,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NGOMBI',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'TV & RADIO Direct',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Rechercher',
            onPressed: () => _openSearch(context),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Paramètres',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String? action,
    VoidCallback? onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (action != null && onPressed != null)
            TextButton(
              onPressed: onPressed,
              child: Text(action),
            ),
        ],
      ),
    );
  }

  Widget _buildTvCarousel(BuildContext context) {
    if (tvChannels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Text(
          'Aucune chaîne TV disponible.',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    final visibleChannels = tvChannels.take(10).toList();

    return SizedBox(
      height: 155,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: visibleChannels.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final channel = visibleChannels[index];

          return _TvHomeCard(
            channel: channel,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StreamPlayerScreen(
                    channel: channel,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      (
        'Afrique',
        Icons.public_rounded,
      ),
      (
        'Sport',
        Icons.sports_soccer_rounded,
      ),
      (
        'Information',
        Icons.newspaper_rounded,
      ),
      (
        'Musique',
        Icons.music_note_rounded,
      ),
      (
        'Cinéma',
        Icons.movie_rounded,
      ),
      (
        'Jeunesse',
        Icons.child_care_rounded,
      ),
    ];

    return SizedBox(
      height: 94,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final item = categories[index];

          return Container(
            width: 105,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.$2,
                  color: const Color(0xFFFFA21A),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  item.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadioCarousel(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: radioChannels.take(8).length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final radio = radioChannels[index];

          return _RadioHomeCard(
            radio: radio,
            onTap: () {
              NgombiStore.instance.recordRadio(radio);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WebPlayerScreen(
                    title: radio.name,
                    url: radio.url,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARTE TV ACCUEIL
// -----------------------------------------------------------------------------

class _TvHomeCard extends StatelessWidget {
  final TvChannel channel;
  final VoidCallback onTap;

  const _TvHomeCard({
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF292929),
                        Color(0xFF171717),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ChannelLogo(
                      channel: channel,
                      size: 72,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                channel.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARTE RADIO ACCUEIL
// -----------------------------------------------------------------------------

class _RadioHomeCard extends StatelessWidget {
  final MediaItem radio;
  final VoidCallback onTap;

  const _RadioHomeCard({
    required this.radio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF8A00)
                    .withOpacity(0.14),
              ),
              child: const Icon(
                Icons.radio_rounded,
                color: Color(0xFFFFA21A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                    Text(
                    radio.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    radio.category,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
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
}

// -----------------------------------------------------------------------------
// TV
// -----------------------------------------------------------------------------

class TvScreen extends StatefulWidget {
  final List<TvChannel> tvChannels;

  const TvScreen({
    super.key,
    required this.tvChannels,
  });

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  String selectedCategory = 'Toutes';

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Toutes',
      ...widget.tvChannels
          .map((channel) => channel.category)
          .toSet(),
    ];

    final filteredChannels = selectedCategory == 'Toutes'
        ? widget.tvChannels
        : widget.tvChannels
            .where(
              (channel) =>
                  channel.category == selectedCategory,
            )
            .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: _PageHeader(
              title: 'Télévision',
              subtitle: 'Les chaînes TV en direct',
              icon: Icons.tv_rounded,
            ),
          ),

          const SliverToBoxAdapter(
            child: NgombiHero(),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return ChoiceChip(
                    label: Text(category),
                    selected:
                        selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          if (filteredChannels.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Aucune chaîne disponible.',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final channel =
                        filteredChannels[index];

                    return _TvGridCard(
                      channel: channel,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StreamPlayerScreen(
                              channel: channel,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredChannels.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisExtent: 205,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARTE TV GRILLE
// -----------------------------------------------------------------------------

class _TvGridCard extends StatelessWidget {
  final TvChannel channel;
  final VoidCallback onTap;

  const _TvGridCard({
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF242424),
                      Color(0xFF101010),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ChannelLogo(
                        channel: channel,
                        size: 80,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'DIRECT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                10,
                13,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${channel.category} • '
                    '${_streamTypeLabel(channel.type)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
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

// -----------------------------------------------------------------------------
// RADIO
// -----------------------------------------------------------------------------

class RadioScreen extends StatelessWidget {
  const RadioScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: _PageHeader(
              title: 'Radio',
              subtitle: 'Écoutez vos radios préférées',
              icon: Icons.radio_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final radio = radioChannels[index];

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _RadioListCard(
                      radio: radio,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                WebPlayerScreen(
                              title: radio.name,
                              url: radio.url,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: radioChannels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARTE RADIO
// -----------------------------------------------------------------------------

class _RadioListCard extends StatelessWidget {
  final MediaItem radio;
  final VoidCallback onTap;

  const _RadioListCard({
    required this.radio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8A00)
                      .withOpacity(0.14),
                ),
                child: Icon(
                  radio.icon,
                  color: const Color(0xFFFFA21A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      radio.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radio.category,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFFFFA21A),
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// EN-TÊTE DE PAGE
// -----------------------------------------------------------------------------

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        8,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A00)
                  .withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFA21A),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LECTEUR WEB RADIO
// -----------------------------------------------------------------------------

class WebPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebPlayerScreen> createState() =>
      _WebPlayerScreenState();
}

class _WebPlayerScreenState
    extends State<WebPlayerScreen> {
  WebViewController? controller;
  bool loading = true;
  String? errorMessage;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();

    NgombiStore.instance.recordRadio(
      name: widget.title,
      url: widget.url,
    );

    if (_isDesktop) {
      loading = false;
      return;
    }

    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      final webController = WebViewController()
        ..setJavaScriptMode(
          JavaScriptMode.unrestricted,
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() {
                loading = true;
                errorMessage = null;
              });
            },
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() {
                loading = false;
              });
            },
            onWebResourceError: (error) {
              if (!mounted ||
                  error.isForMainFrame != true) {
                return;
              }

              setState(() {
                loading = false;
                errorMessage = error.description;
              });
            },
          ),
        )
        ..loadRequest(
          Uri.parse(widget.url),
        );

      controller = webController;
    } catch (error) {
      errorMessage = error.toString();
      loading = false;
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      setState(() {
        errorMessage =
            'Impossible d’ouvrir ce lien dans le navigateur.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.open_in_browser_rounded,
                  size: 58,
                  color: Color(0xFFFFA21A),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cette radio utilise son lecteur web officiel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                  ),
                  label: const Text(
                    'Ouvrir le lecteur officiel',
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          if (controller != null)
            WebViewWidget(
              controller: controller!,
            )
          else
            Center(
              child: Text(
                errorMessage ??
                    'Impossible d’initialiser le lecteur web.',
                textAlign: TextAlign.center,
              ),
            ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RECHERCHE NGOMBI
// -----------------------------------------------------------------------------

class NgombiSearchResult {
  final TvChannel? tvChannel;
  final MediaItem? radioChannel;

  const NgombiSearchResult.tv(
    TvChannel channel,
  )   : tvChannel = channel,
        radioChannel = null;

  const NgombiSearchResult.radio(
    MediaItem channel,
  )   : tvChannel = null,
        radioChannel = channel;
}

class NgombiSearchDelegate
    extends SearchDelegate<NgombiSearchResult?> {
  final List<TvChannel> tvChannels;
  final List<MediaItem> radioChannels;

  NgombiSearchDelegate({
    required this.tvChannels,
    required this.radioChannels,
  }) : super(
          searchFieldLabel:
              'Rechercher une chaîne ou une radio',
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) {
      return [];
    }

    return [
      IconButton(
        tooltip: 'Effacer',
        onPressed: () {
          query = '';
        },
        icon: const Icon(
          Icons.clear_rounded,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(
        Icons.arrow_back_rounded,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 56,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              'Rechercher une chaîne ou une radio',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final matchingTv = tvChannels.where((channel) {
      final name = channel.name.toLowerCase();
      final category = channel.category.toLowerCase();

      return name.contains(search) ||
          category.contains(search);
    }).toList();

    final matchingRadio = radioChannels.where((radio) {
      final name = radio.name.toLowerCase();
      final category = radio.category.toLowerCase();

      return name.contains(search) ||
          category.contains(search);
    }).toList();

    final totalResults =
        matchingTv.length + matchingRadio.length;

    if (totalResults == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"$query"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      children: [
        if (matchingTv.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              8,
            ),
            child: Text(
              'TV',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          ...matchingTv.map(
            (channel) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x22FF8A00),
                  child: Icon(
                    Icons.tv_rounded,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  channel.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${channel.category} • '
                  '${_searchStreamTypeLabel(channel.type)}',
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  close(
                    context,
                    NgombiSearchResult.tv(channel),
                  );
                },
              );
            },
          ),
        ],

        if (matchingRadio.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: Text(
              'RADIO',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          ...matchingRadio.map(
            (radio) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Colors.orange.withOpacity(0.12),
                  child: Icon(
                    radio.icon,
                    color: Colors.orange,
                  ),
                ),
                title: Text(
                  radio.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  radio.category,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  close(
                    context,
                    NgombiSearchResult.radio(radio),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }

  static String _searchStreamTypeLabel(
    StreamType type,
  ) {
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
