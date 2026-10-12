import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NgombiAudienceDashboardScreen extends StatefulWidget {
  const NgombiAudienceDashboardScreen({super.key});

  @override
  State<NgombiAudienceDashboardScreen> createState() => _NgombiAudienceDashboardScreenState();
}

class _NgombiAudienceDashboardScreenState extends State<NgombiAudienceDashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadStats());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final response = await Supabase.instance.client.rpc('ngombi_audience_stats');
      if (!mounted) return;
      setState(() {
        _stats = Map<String, dynamic>.from(response as Map);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les statistiques. Vérifiez la connexion et les droits administrateur.';
      });
    }
  }

  int _number(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  @override
  Widget build(BuildContext context) {
    final activity = Map<String, dynamic>.from((_stats['activity'] as Map?) ?? {});
    final history = (_stats['daily_history'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audience NGOMBI'),
        actions: [IconButton(onPressed: _loadStats, icon: const Icon(Icons.refresh), tooltip: 'Actualiser')],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null) Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.orangeAccent)),
                  ),
                  Text('Installations actives', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _metric('En direct', _number(_stats['active_now']), Icons.wifi_tethering_rounded),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _metric('Aujourd’hui', _number(_stats['daily']), Icons.today)),
                    const SizedBox(width: 8),
                    Expanded(child: _metric('Cette semaine', _number(_stats['weekly']), Icons.date_range)),
                  ]),
                  const SizedBox(height: 8),
                  _metric('Ce mois-ci', _number(_stats['monthly']), Icons.calendar_month),
                  const SizedBox(height: 24),
                  Text('Activité par rubrique · 30 derniers jours', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  for (final section in ['Radio', 'TV', 'Bouquet', 'Accueil'])
                    _activityRow(section, _number(activity[section])),
                  const SizedBox(height: 24),
                  Text('Historique journalier · 14 jours', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  if (history.isEmpty) const Text('Les statistiques apparaîtront lorsque des installations auront été détectées.'),
                  for (final item in history)
                    if (item is Map)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [
                          SizedBox(width: 100, child: Text('${item['day'] ?? ''}')),
                          Expanded(child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              minHeight: 9,
                              value: _number(item['users']) == 0 ? 0 : (_number(item['users']) / _maxHistory(history)).clamp(0.0, 1.0).toDouble(),
                            ),
                          )),
                          const SizedBox(width: 10),
                          SizedBox(width: 28, child: Text('${_number(item['users'])}', textAlign: TextAlign.end)),
                        ]),
                      ),
                  const SizedBox(height: 16),
                  const Text('Les actifs en direct correspondent aux installations ayant envoyé un signal au cours des 3 dernières minutes. Une installation peut représenter plusieurs utilisateurs ou être utilisée par la même personne à plusieurs moments.'),
                ],
              ),
            ),
    );
  }

  int _maxHistory(List<dynamic> history) {
    var maxValue = 1;
    for (final item in history) {
      if (item is Map) {
        final value = _number(item['users']);
        if (value > maxValue) maxValue = value;
      }
    }
    return maxValue;
  }

  Widget _metric(String label, int value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFFFA21A), size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      ]),
    ),
  );

  Widget _activityRow(String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Expanded(child: Text(label)),
      Text('$count événements', style: const TextStyle(color: Colors.white70)),
    ]),
  );
}
