import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ngombi_ad.dart';

class NgombiAdServerRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<NgombiAd>> loadPublicAds({
    List<NgombiAd> fallback = const [],
  }) async {
    try {
      final rows = await _client
          .from('ngombi_ad_campaigns')
          .select()
          .eq('active', true)
          .order('priority', ascending: false);

      return rows.map((row) => _fromRow(Map<String, dynamic>.from(row))).toList();
    } catch (_) {
      return List<NgombiAd>.from(fallback);
    }
  }

  Future<List<NgombiAd>> loadAdminAds() async {
    final rows = await _client
        .from('ngombi_ad_campaigns')
        .select()
        .order('priority', ascending: false);

    return rows.map((row) => _fromRow(Map<String, dynamic>.from(row))).toList();
  }

  Future<void> saveAds(List<NgombiAd> ads) async {
    final existing = await _client.from('ngombi_ad_campaigns').select('id');
    final keep = ads.map((e) => e.id).toSet();

    for (final row in existing) {
      final id = row['id']?.toString();
      if (id != null && !keep.contains(id)) {
        await _client.from('ngombi_ad_campaigns').delete().eq('id', id);
      }
    }

    for (final ad in ads) {
      await _client.from('ngombi_ad_campaigns').upsert(_toRow(ad));
    }
  }

  Map<String, dynamic> _toRow(NgombiAd ad) => {
        'id': ad.id,
        'title': ad.title,
        'type': ad.type.name,
        'media': ad.media,
        'duration_seconds': ad.duration.inSeconds,
        'click_url': ad.clickUrl,
        'active': ad.active,
        'priority': ad.priority,
        'starts_at': ad.startsAt?.toUtc().toIso8601String(),
        'ends_at': ad.endsAt?.toUtc().toIso8601String(),
      };

  NgombiAd _fromRow(Map<String, dynamic> row) => NgombiAd(
        id: row['id']?.toString() ?? '',
        title: row['title']?.toString() ?? '',
        type: row['type']?.toString() == 'video'
            ? NgombiAdType.video
            : NgombiAdType.image,
        media: row['media']?.toString() ?? '',
        duration: Duration(
          seconds: int.tryParse(row['duration_seconds']?.toString() ?? '') ?? 15,
        ),
        clickUrl: row['click_url']?.toString() ?? '',
        active: row['active'] == true,
        priority: int.tryParse(row['priority']?.toString() ?? '') ?? 0,
        startsAt: DateTime.tryParse(row['starts_at']?.toString() ?? ''),
        endsAt: DateTime.tryParse(row['ends_at']?.toString() ?? ''),
      );
}
