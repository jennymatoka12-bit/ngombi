import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NgombiApp());
}

class NgombiApp extends StatelessWidget {
  const NgombiApp({super.key});

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

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;

            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;

            setState(() {
              isLoading = false;
              hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> openExternalBrowser() async {
    final uri = Uri.parse(widget.url);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’ouvrir cette page dans le navigateur.',
          ),
        ),
      );
    }
  }

  Future<void> reloadPage() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    await controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: reloadPage,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Ouvrir dans le navigateur',
            onPressed: openExternalBrowser,
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
            ),
          if (hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Impossible de charger cette page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vérifie ta connexion Internet ou ouvre la page dans le navigateur.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: reloadPage,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: openExternalBrowser,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Navigateur'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
