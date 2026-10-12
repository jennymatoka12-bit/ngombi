import 'package:flutter/material.dart';

import '../models/ngombi_ad.dart';
import '../services/ngombi_ad_server_repository.dart';
import 'ngombi_ad_manager_screen.dart';
import 'ngombi_audience_dashboard_screen.dart';

class NgombiAdminHubScreen extends StatelessWidget {
  final List<NgombiAd> ads;

  const NgombiAdminHubScreen({super.key, required this.ads});

  @override
  Widget build(BuildContext context) {
    final repository = NgombiAdServerRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Administration NGOMBI')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.admin_panel_settings_rounded, size: 58, color: Color(0xFFFFA21A)),
          const SizedBox(height: 10),
          const Text('Espace administrateur', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 22),
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign_rounded, color: Color(0xFFFFA21A), size: 32),
              title: const Text('Gestion publicitaire'),
              subtitle: const Text('Créer et gérer les campagnes NGOMBI'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => NgombiAdManagerScreen(ads: ads, remoteSave: repository.saveAds),
              )),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.query_stats_rounded, color: Color(0xFFFFA21A), size: 32),
              title: const Text('Suivi d’audience'),
              subtitle: const Text('Actifs en direct, historique et activité Radio/TV/Bouquet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NgombiAudienceDashboardScreen(),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
