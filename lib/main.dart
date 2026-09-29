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

class NgombiWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
class NgombiHero extends StatelessWidget {
  const NgombiHero({super.key});

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
          color: Color(0x33FF7043),
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
}class HomeScreen extends StatelessWidget {
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

    final radioCount =
        radioChannels.length > 6 ? 6 : radioChannels.length;

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
                itemCount: radioCount,
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
            color: const Color(0x33FF9D1A),
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
          color: const Color(0xFFFF8A00).withOpacity(0.16),
        ),
        child: Center(
          child: Text(
            channel.name.isNotEmpty
                ? channel.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFFFFA31A),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
  ) {
    IconData icon;

    switch (category) {
      case 'Afrique':
        icon = Icons.public;
        break;
      case 'France':
        icon = Icons.location_city;
        break;
      case 'Information':
        icon = Icons.newspaper;
        break;
      case 'Sport':
        icon = Icons.sports_soccer;
        break;
      case 'Cinéma':
        icon = Icons.movie;
        break;
      case 'Musique':
        icon = Icons.music_note;
        break;
      case 'Jeunesse':
        icon = Icons.child_care;
        break;
      default:
        icon = Icons.language;
    }

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x22181818),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFA31A),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioCard(
    BuildContext context,
    MediaItem radio,
  ) {
    return SizedBox(
      width: 190,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A00).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.radio,
                    color: Color(0xFFFFA31A),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    radio.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}class MediaListScreen extends StatefulWidget {
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
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  String selectedCategory = 'Toutes';

  @override
  Widget build(BuildContext context) {
    if (widget.isTv && widget.tvChannels.isNotEmpty) {
      return _buildTvList(context);
    }

    if (widget.isTv) {
      return _buildEmptyTv(context);
    }

    return _buildRadioList(context);
  }

  Widget _buildTvList(BuildContext context) {
    final categories = <String>{
      'Toutes',
      ...widget.tvChannels.map(
        (channel) => channel.category,
      ),
    }.toList();

    final filteredChannels = selectedCategory == 'Toutes'
        ? widget.tvChannels
        : widget.tvChannels
            .where(
              (channel) => channel.category == selectedCategory,
            )
            .toList();

    return SafeArea(
      child: CustomScrollView(
    slivers: [
  const SliverToBoxAdapter(
      child: NgombiHero(),
  ),

  SliverToBoxAdapter(
    child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                16,
                8,
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
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
                    selected: selectedCategory == category,
                    selectedColor: const Color(0xFFFF8A00),
                    labelStyle: TextStyle(
                      color: selectedCategory == category
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                16,
                4,
              ),
              child: Text(
                '${filteredChannels.length} chaîne(s)',
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              24,
            ),
            sliver: SliverList.builder(
              itemCount: filteredChannels.length,
              itemBuilder: (context, index) {
                final channel = filteredChannels[index];

                return _buildTvCard(
                  context,
                  channel,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvCard(
    BuildContext context,
    TvChannel channel,
  ) {
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
          backgroundColor: const Color(0xFF242424),
          child: channel.logo != null
              ? ClipOval(
                  child: Image.network(
                    channel.logo!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _channelInitial(channel);
                    },
                  ),
                )
              : _channelInitial(channel),
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
            '${channel.category} • '
            '${_streamTypeLabel(channel.type)}',
          ),
        ),
        trailing: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8A00).withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFFFFA31A),
          ),
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
  }

  Widget _channelInitial(TvChannel channel) {
    return Text(
      channel.name.isNotEmpty
          ? channel.name[0].toUpperCase()
          : '?',
      style: const TextStyle(
        color: Color(0xFFFFA31A),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget _buildEmptyTv(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tv_off,
              size: 64,
              color: Color(0xFFFF8A00),
            ),
            SizedBox(height: 16),
            Text(
              'Aucune chaîne TV détectée.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Vérifie le fichier assets/tvradiozap.txt.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioList(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                16,
                8,
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              24,
            ),
            sliver: SliverList.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];

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
                      backgroundColor: const Color(0xFF242424),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFFFFA31A),
                      ),
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
                      color: Color(0xFFFFA31A),
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

class WebPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebPlayerScreen> createState() => _WebPlayerScreenState();
}

class _WebPlayerScreenState extends State<WebPlayerScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint(
              'WebView error: ${error.description}',
            );
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
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
