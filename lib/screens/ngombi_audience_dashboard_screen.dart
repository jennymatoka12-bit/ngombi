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
  Map<String, dynamic> _annual = {};
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  int _selectedYear = DateTime.now().year;

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

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
      final client = Supabase.instance.client;
      final results = await Future.wait([
        client.rpc('ngombi_audience_stats'),
        client.rpc('ngombi_audience_annual_stats', params: {'p_year': _selectedYear}),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = Map<String, dynamic>.from(results[0] as Map);
        _annual = Map<String, dynamic>.from(results[1] as Map);
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les statistiques. Vérifiez la connexion et les droits administrateur.';
      });
    }
  }

  int _number(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  double _hours(dynamic seconds) => _number(seconds) / 3600.0;

  double _megabytes(dynamic bytes) => _number(bytes) / 1000000.0;

  String _formatHours(dynamic seconds) => '${_hours(seconds).toStringAsFixed(1)} h';

  String _formatMo(dynamic bytes) => '${_megabytes(bytes).toStringAsFixed(1)} Mo';

  @override
  Widget build(BuildContext context) {
    final activity = Map<String, dynamic>.from((_stats['activity'] as Map?) ?? {});
    final history = (_stats['daily_history'] as List?) ?? const [];
    final sections = Map<String, dynamic>.from((_annual['by_section'] as Map?) ?? {});
    final monthly = (_annual['monthly'] as List?) ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audience NGOMBI'),
        actions: [
          IconButton(onPressed: _loadStats, icon: const Icon(Icons.refresh), tooltip: 'Actualiser'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.orangeAccent)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Rapport annuel', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      DropdownButton<int>(
                        value: _selectedYear,
                        items: [
                          for (var year = DateTime.now().year; year >= DateTime.now().year - 5; year--)
                            DropdownMenuItem(value: year, child: Text('$year')),
                        ],
                        onChanged: (year) {
                          if (year == null) return;
                          setState(() {
                            _selectedYear = year;
                            _loading = true;
                          });
                          _loadStats();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _metric('Installations distinctes', '${_number(_annual['unique_installations'])}', Icons.people_alt_outlined),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _metric('Temps actif cumulé', _formatHours(_annual['active_seconds']), Icons.schedule)),
                      const SizedBox(width: 8),
                      Expanded(child: _metric('Données consommées', _formatMo(_annual['data_bytes']), Icons.data_usage)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Répartition par rubrique · $_selectedYear', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final section in ['Radio', 'TV', 'Bouquet', 'Accueil'])
                    _annualSectionRow(section, sections[section] is Map
                        ? Map<String, dynamic>.from(sections[section] as Map)
                        : const {}),
                  const SizedBox(height: 22),
                  Text('Évolution mensuelle · $_selectedYear', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (monthly.isEmpty) const Text('Aucune donnée annuelle enregistrée pour cette période.'),
                  for (final item in monthly)
                    if (item is Map) _monthlyRow(Map<String, dynamic>.from(item)),
                  const SizedBox(height: 26),
                  Text('Installations actives', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _metric('En direct', '${_number(_stats['active_now'])}', Icons.wifi_tethering_rounded),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _metric('Aujourd’hui', '${_number(_stats['daily'])}', Icons.today)),
                      const SizedBox(width: 8),
                      Expanded(child: _metric('Cette semaine', '${_number(_stats['weekly'])}', Icons.date_range)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _metric('Ce mois-ci', '${_number(_stats['monthly'])}', Icons.calendar_month),
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
                        child: Row(
                          children: [
                            SizedBox(width: 100, child: Text('${item['day'] ?? ''}')),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  minHeight: 9,
                                  value: _number(item['users']) == 0
                                      ? 0
                                      : (_number(item['users']) / _maxHistory(history)).clamp(0.0, 1.0).toDouble(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(width: 28, child: Text('${_number(item['users'])}', textAlign: TextAlign.end)),
                          ],
                        ),
                      ),
                  const SizedBox(height: 16),
                  const Text(
                    'Les utilisateurs sont comptés comme des installations NGOMBI distinctes, pas comme des personnes physiques. '
                    'Le temps correspond à la durée d’utilisation active au premier plan. Les Mo correspondent au trafic réseau total '
                    'de l’application Android (réception + émission), tous échanges compris. Ces deux nouveaux compteurs commencent '
                    'à s’accumuler après l’installation de cette version ; aucune donnée passée ne peut être reconstituée.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _annualSectionRow(String label, Map<String, dynamic> values) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(child: Text('${_number(values['installations'])} installations', style: const TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(child: Text(_formatHours(values['active_seconds']), style: const TextStyle(color: Colors.white70, fontSize: 12))),
              Text(_formatMo(values['data_bytes']), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _monthlyRow(Map<String, dynamic> item) {
    final date = DateTime.tryParse('${item['month'] ?? ''}');
    final label = date == null ? '${item['month'] ?? ''}' : _months[date.month - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
            '${_number(item['installations'])} installations  ·  ${_formatHours(item['active_seconds'])}  ·  ${_formatMo(item['data_bytes'])}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Divider(height: 12),
        ],
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

  Widget _metric(String label, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFA21A), size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
        ],
      ),
    ),
  );

  Widget _activityRow(String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('$count événements', style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
