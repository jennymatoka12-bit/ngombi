import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tv_channel.dart';
import '../main.dart';

class NgombiHistoryEntry {
  final String name;
  final String url;
  final bool isRadio;
  final DateTime openedAt;

  const NgombiHistoryEntry({
    required this.name,
    required this.url,
    required this.isRadio,
    required this.openedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'isRadio': isRadio,
        'openedAt': openedAt.toIso8601String(),
      };

  factory NgombiHistoryEntry.fromJson(Map<String, dynamic> json) {
    return NgombiHistoryEntry(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      isRadio: json['isRadio'] as bool? ?? false,
      openedAt: DateTime.tryParse(
            json['openedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class NgombiStore extends ChangeNotifier {
  static final NgombiStore instance = NgombiStore._();

  NgombiStore._();

  static const _favoritesKey = 'ngombi.favorites';
  static const _historyKey = 'ngombi.history';
  static const _externalLinksKey = 'ngombi.externalLinks';

  late SharedPreferencesWithCache _prefs;

  final Set<String> _favoriteKeys = <String>{};
  final List<NgombiHistoryEntry> _history = <NgombiHistoryEntry>[];

  bool _openExternalLinks = true;

  Set<String> get favoriteKeys => Set.unmodifiable(_favoriteKeys);
  List<NgombiHistoryEntry> get history => List.unmodifiable(_history);
  bool get openExternalLinks => _openExternalLinks;

  Future<void> init() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{
          _favoritesKey,
          _historyKey,
          _externalLinksKey,
        },
      ),
    );

    _favoriteKeys
      ..clear()
      ..addAll(_prefs.getStringList(_favoritesKey) ?? const <String>[]);

    final encodedHistory =
        _prefs.getStringList(_historyKey) ?? const <String>[];

    _history
      ..clear()
      ..addAll(encodedHistory.map((item) =>
          NgombiHistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>)));

    _openExternalLinks = _prefs.getBool(_externalLinksKey) ?? true;
  }

  String keyForTv(TvChannel channel) => 'tv:' + channel.url;

  bool isFavoriteTv(TvChannel channel) => _favoriteKeys.contains(keyForTv(channel));

  Future<void> toggleFavoriteTv(TvChannel channel) async {
    final key = keyForTv(channel);
    if (!_favoriteKeys.add(key)) {
      _favoriteKeys.remove(key);
    }
    await _prefs.setStringList(
      _favoritesKey,
      _favoriteKeys.toList(growable: false),
    );
    notifyListeners();
  }

  List<TvChannel> favoriteTvChannels(List<TvChannel> channels) =>
      channels.where(isFavoriteTv).toList(growable: false);

  Future<void> recordTv(TvChannel channel) => _record(
        NgombiHistoryEntry(
          name: channel.name,
          url: channel.url,
          isRadio: false,
          openedAt: DateTime.now(),
        ),
      );

  Future<void> recordRadio(MediaItem radio) => _record(
        NgombiHistoryEntry(
          name: radio.name,
          url: radio.url,
          isRadio: true,
          openedAt: DateTime.now(),
        ),
      );

  Future<void> _record(NgombiHistoryEntry entry) async {
    _history.removeWhere(
      (item) => item.url == entry.url && item.isRadio == entry.isRadio,
    );
    _history.insert(0, entry);

    if (_history.length > 30) {
      _history.removeRange(30, _history.length);
    }

    await _prefs.setStringList(
      _historyKey,
      _history.map((item) => jsonEncode(item.toJson())).toList(growable: false),
    );
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _prefs.remove(_historyKey);
    notifyListeners();
  }

  Future<void> setOpenExternalLinks(bool value) async {
    _openExternalLinks = value;
    await _prefs.setBool(_externalLinksKey, value);
    notifyListeners();
  }
}
