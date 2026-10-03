import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ngombi_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = NgombiStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Paramètres')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _SettingsSectionTitle('Lecture'),
            Card(
              child: SwitchListTile.adaptive(
                value: store.openExternalLinks,
                onChanged: store.setOpenExternalLinks,
                title: const Text('Liens web dans le navigateur'),
                subtitle: const Text(
                  'Utiliser le navigateur système pour les lecteurs officiels.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _SettingsSectionTitle('Données locales'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Effacer l’historique'),
                subtitle: Text(
                  store.history.length.toString() +
                      ' élément(s) enregistré(s)',
                ),
                onTap: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Effacer l’historique ?'),
                      content: const Text(
                        'Cette action supprime uniquement l’historique local de NGOMBI.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            await store.clearHistory();
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          child: const Text('Effacer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const _SettingsSectionTitle('À propos'),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('NGOMBI'),
                    subtitle: Text('TV & RADIO Direct'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.public_rounded),
                    title: const Text('Dépôt du projet'),
                    onTap: () => _openUrl(
                      context,
                      'https://github.com/jennymatoka12-bit/ngombi',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Version 1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
