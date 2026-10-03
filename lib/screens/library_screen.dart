import 'package:flutter/material.dart';

import '../models/tv_channel.dart';
import '../screens/stream_player_screen.dart';
import '../services/ngombi_store.dart';

class LibraryScreen extends StatelessWidget {
  final List<TvChannel> tvChannels;

  const LibraryScreen({
    super.key,
    required this.tvChannels,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NgombiStore.instance,
      builder: (context, _) {
        final favorites =
            NgombiStore.instance.favoriteTvChannels(tvChannels);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Ma bibliothèque'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.star_rounded), text: 'Favoris'),
                  Tab(icon: Icon(Icons.history_rounded), text: 'Historique'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _FavoritesTab(channels: favorites),
                _HistoryTab(tvChannels: tvChannels),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  final List<TvChannel> channels;

  const _FavoritesTab({required this.channels});

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) {
      return const _EmptyLibrary(
        icon: Icons.star_border_rounded,
        title: 'Aucun favori',
        message: 'Ajoute tes chaînes préférées avec l’étoile.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: channels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x22FF8A00),
              child: Icon(Icons.tv_rounded, color: Color(0xFFFFA21A),
              ),
            ),
            title: Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(channel.category),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StreamPlayerScreen(channel: channel),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<TvChannel> tvChannels;

  const _HistoryTab({required this.tvChannels});

  @override
  Widget build(BuildContext context) {
    final history = NgombiStore.instance.history;

    if (history.isEmpty) {
      return const _EmptyLibrary(
        icon: Icons.history_rounded,
        title: 'Historique vide',
        message: 'Les chaînes que tu regardes apparaîtront ici.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = history[index];
        TvChannel? channel;
        for (final candidate in tvChannels) {
          if (candidate.url == entry.url) {
            channel = candidate;
            break;
          }
        }

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0x22FF8A00),
              child: Icon(
                entry.isRadio ? Icons.radio_rounded : Icons.tv_rounded,
                color: const Color(0xFFFFA21A),
              ),
            ),
            title: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              entry.isRadio ? 'Radio' : (channel?.category ?? 'TV'),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: channel == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StreamPlayerScreen(channel: channel!),
                      ),
                    ),
          ),
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyLibrary({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
