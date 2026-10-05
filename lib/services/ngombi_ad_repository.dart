import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/ngombi_ads.dart';
import '../models/ngombi_ad.dart';

class NgombiAdRepository {
  static const _storageKey = 'ngombi_ads_v1';

  Future<List<NgombiAd>> loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      final defaults = List<NgombiAd>.from(ngombiAds);
      await saveAds(defaults);
      return defaults;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Catalogue invalide');
      return decoded.whereType<Map>().map((item) => NgombiAd.fromJson(
        Map<String, dynamic>.from(item),
      )).toList();
    } catch (_) {
      final defaults = List<NgombiAd>.from(ngombiAds);
      await saveAds(defaults);
      return defaults;
    }
  }

  Future<void> saveAds(List<NgombiAd> ads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(ads.map((ad) => ad.toJson()).toList()));
  }

  Future<void> resetToDemo() async => saveAds(List<NgombiAd>.from(ngombiAds));
}
