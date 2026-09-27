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
    return MaterialApp(
      title: 'NGOMBI - TV & Radio Direct',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
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
        children: [
          MediaListScreen(
            title: 'TV en direct',
            items: const [],
            isTv: true,
            tvChannels: widget.tvChannels,
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

class MediaListScreen extends StatefulWidget {
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                8,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
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
                16,
                4,
                16,
                4,
              ),
              child: Text(
                '${filteredChannels.length} chaîne(s)',
                style: TextStyle(
                  color: Colors.grey.shade400,
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
  }

  Widget _channelInitial(TvChannel channel) {
    return Text(
      channel.name.isNotEmpty
          ? channel.name[0].toUpperCase()
          : '?',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
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
                16,
                18,
                16,
                8,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
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
