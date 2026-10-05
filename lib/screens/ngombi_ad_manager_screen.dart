import 'package:flutter/material.dart';

import '../models/ngombi_ad.dart';
import '../services/ngombi_ad_repository.dart';

class NgombiAdManagerScreen extends StatefulWidget {
  final List<NgombiAd> ads;
  const NgombiAdManagerScreen({super.key, required this.ads});
  @override
  State<NgombiAdManagerScreen> createState() => _NgombiAdManagerScreenState();
}

class _NgombiAdManagerScreenState extends State<NgombiAdManagerScreen> {
  final _repository = NgombiAdRepository();
  late List<NgombiAd> _ads;
  bool _saving = false;

  @override
  void initState() { super.initState(); _ads = List<NgombiAd>.from(widget.ads); }

  Future<void> _persist() async {
    setState(() => _saving = true);
    await _repository.saveAds(_ads);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _edit([NgombiAd? ad]) async {
    final result = await showDialog<NgombiAd>(context: context, builder: (_) => _AdEditorDialog(ad: ad));
    if (result == null || !mounted) return;
    setState(() {
      final index = _ads.indexWhere((item) => item.id == result.id);
      if (index >= 0) { _ads[index] = result; } else { _ads.add(result); }
      _ads.sort((a, b) => b.priority.compareTo(a.priority));
    });
    await _persist();
  }

  Future<void> _delete(NgombiAd ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la campagne ?'),
        content: Text('« ${ad.title} » sera retirée du catalogue local.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _ads.removeWhere((item) => item.id == ad.id));
    await _persist();
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le catalogue ?'),
        content: const Text('Les campagnes actuelles seront remplacées par les campagnes de démonstration.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Réinitialiser')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _repository.resetToDemo();
    final fresh = await _repository.loadAds();
    if (mounted) setState(() => _ads = fresh);
  }

  Future<bool> _closeManager() async {
    if (!mounted) return true;
    Navigator.of(context).pop(_ads);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final active = _ads.where((ad) => ad.active).length;
    final videos = _ads.where((ad) => ad.type == NgombiAdType.video).length;
    return WillPopScope(
      onWillPop: _closeManager,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire publicitaire'),
        actions: [IconButton(tooltip: 'Réinitialiser', onPressed: _saving ? null : _reset, icon: const Icon(Icons.restore_rounded))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle campagne'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _StatsHeader(total: _ads.length, active: active, videos: videos),
          const SizedBox(height: 16),
          if (_ads.isEmpty)
            const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Aucune campagne. Ajoutez votre première publicité.', textAlign: TextAlign.center)))
          else
            ..._ads.map((ad) => _AdManagerCard(
              ad: ad,
              onEdit: () => _edit(ad),
              onDelete: () => _delete(ad),
              onToggle: (value) async {
                setState(() {
                  final index = _ads.indexWhere((item) => item.id == ad.id);
                  if (index >= 0) _ads[index] = ad.copyWith(active: value);
                });
                await _persist();
              },
            )),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'V1 : les campagnes sont persistées sur cet appareil. La prochaine étape sera de connecter ce catalogue à un serveur NGOMBI pour administrer les campagnes à distance et centraliser les statistiques.',
                    style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int total, active, videos;
  const _StatsHeader({required this.total, required this.active, required this.videos});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _StatCard(label: 'Campagnes', value: '$total', icon: Icons.campaign_rounded)),
    const SizedBox(width: 8),
    Expanded(child: _StatCard(label: 'Actives', value: '$active', icon: Icons.play_circle_outline_rounded)),
    const SizedBox(width: 8),
    Expanded(child: _StatCard(label: 'Vidéos', value: '$videos', icon: Icons.videocam_outlined)),
  ]);
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    child: Column(children: [
      Icon(icon, color: const Color(0xFFFFA21A), size: 20),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ]),
  ));
}

class _AdManagerCard extends StatelessWidget {
  final NgombiAd ad;
  final VoidCallback onEdit, onDelete;
  final ValueChanged<bool> onToggle;
  const _AdManagerCard({required this.ad, required this.onEdit, required this.onDelete, required this.onToggle});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0x22FF8A00)),
          child: Icon(ad.type == NgombiAdType.video ? Icons.videocam_rounded : Icons.image_rounded, color: const Color(0xFFFFA21A))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${ad.duration.inSeconds}s • priorité ${ad.priority} • ${ad.type == NgombiAdType.video ? 'Vidéo' : 'Image'}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ])),
        Switch(value: ad.active, onChanged: onToggle),
        PopupMenuButton<String>(
          onSelected: (value) { if (value == 'edit') onEdit(); if (value == 'delete') onDelete(); },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ]),
    ),
  );
}

class _AdEditorDialog extends StatefulWidget {
  final NgombiAd? ad;
  const _AdEditorDialog({this.ad});
  @override
  State<_AdEditorDialog> createState() => _AdEditorDialogState();
}

class _AdEditorDialogState extends State<_AdEditorDialog> {
  late final TextEditingController _title, _media, _clickUrl, _duration, _priority;
  late NgombiAdType _type;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final ad = widget.ad;
    _title = TextEditingController(text: ad?.title ?? '');
    _media = TextEditingController(text: ad?.media ?? '');
    _clickUrl = TextEditingController(text: ad?.clickUrl ?? '');
    _duration = TextEditingController(text: '${ad?.duration.inSeconds ?? 15}');
    _priority = TextEditingController(text: '${ad?.priority ?? 0}');
    _type = ad?.type ?? NgombiAdType.image;
    _active = ad?.active ?? true;
  }

  @override
  void dispose() { _title.dispose(); _media.dispose(); _clickUrl.dispose(); _duration.dispose(); _priority.dispose(); super.dispose(); }

  void _submit() {
    final title = _title.text.trim(), media = _media.text.trim(), clickUrl = _clickUrl.text.trim();
    final duration = int.tryParse(_duration.text.trim()), priority = int.tryParse(_priority.text.trim());
    if (title.isEmpty || media.isEmpty || duration == null || duration <= 0 || priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vérifiez le titre, le média, la durée et la priorité.')));
      return;
    }
    Navigator.of(context).pop(NgombiAd(
      id: widget.ad?.id ?? 'ad-${DateTime.now().millisecondsSinceEpoch}',
      title: title, type: _type, media: media,
      duration: Duration(seconds: duration), clickUrl: clickUrl,
      active: _active, priority: priority,
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.ad == null ? 'Nouvelle campagne' : 'Modifier la campagne'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Nom de la campagne')),
      const SizedBox(height: 8),
      DropdownButtonFormField<NgombiAdType>(
        value: _type,
        decoration: const InputDecoration(labelText: 'Type'),
        items: const [
          DropdownMenuItem(value: NgombiAdType.image, child: Text('Image')),
          DropdownMenuItem(value: NgombiAdType.video, child: Text('Vidéo')),
        ],
        onChanged: (value) { if (value != null) setState(() => _type = value); },
      ),
      const SizedBox(height: 8),
      TextField(controller: _media, decoration: const InputDecoration(labelText: 'URL du média', hintText: 'https://...'), keyboardType: TextInputType.url),
      const SizedBox(height: 8),
      TextField(controller: _clickUrl, decoration: const InputDecoration(labelText: 'URL de destination', hintText: 'https://...'), keyboardType: TextInputType.url),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Durée (s)'), keyboardType: TextInputType.number)),
        const SizedBox(width: 12),
        Expanded(child: TextField(controller: _priority, decoration: const InputDecoration(labelText: 'Priorité'), keyboardType: TextInputType.number)),
      ]),
      const SizedBox(height: 6),
      SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Campagne active'), value: _active, onChanged: (value) => setState(() => _active = value)),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
      FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
    ],
  );
}
