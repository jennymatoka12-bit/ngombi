import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'widgets/ngombi_logo.dart';

import 'models/tv_channel.dart';
import 'screens/stream_player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        cardTheme: CardTheme(
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
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF7043),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7043)
                                .withOpacity(0.30),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'NGOMBI',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
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

          SliverToBoxAdapter(
            child: _buildSectionTitle(
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF8A00),
                  Color(0xFFFFB52E),
                ],
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.black,
              size: 28,
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
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
            ),
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
                  child: const Center(
                    child: Icon(
                      Icons.tv_rounded,
                      size: 42,
                      color: Color(0xFFFFA21A),
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
                    const Center(
                      child: Icon(
                        Icons.tv_rounded,
                        size: 48,
                        color: Color(0xFFFFA21A),
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
                          borderRadius:
                              BorderRadius.circular(20),
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
  late final WebViewController controller;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                loading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
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
