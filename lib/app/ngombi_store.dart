import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NgombiHistoryEntry {
  final String id;
  final String name;
  final String url;
  final bool isRadio;
  final DateTime viewedAt;

  const NgombiHistoryEntry({
    required this.id,
    required this.name,
    required this.url,
    required this.isRadio,
    required this.viewedAt,
  });
}

class NgombiStore extends ChangeNotifier {
  static const _favoritesKey = 'ngombi.favorites';
  static const _historyKey = 'ngombi.history';
  static const _maxHistory = 30;

  final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  final Set<String> _favoriteIds = <String>{};
  final List<NgombiHistoryEntry> _history =
      <NgombiHistoryEntry>[];

  bool _ready = false;

  bool get ready => _ready;
  Set<String> get favoriteIds =>
      Set<String>.unmodifiable(_favoriteIds);
  List<NgombiHistoryEntry> get history =>
      List<NgombiHistoryEntry>.unmodifiable(_history);

  Future<void> load() async {
    final favorites =
        await _preferences.getStringList(_favoritesKey);
    final history =
        await _preferences.getStringList(_historyKey);

    _favoriteIds
      ..clear()
      ..addAll(favorites ?? const <String>[]);

    _history
      ..clear()
      ..addAll(
        (history ?? const <String>[])
            .map(_decodeHistory)
            .whereType<NgombiHistoryEntry>(),
      );

    _history.sort(
      (a, b) => b.viewedAt.compareTo(a.viewedAt),
    );

    _ready = true;
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }

    notifyListeners();
    await _saveFavorites();
  }

  Future<void> addHistory({
    required String id,
    required String name,
    required String url,
    required bool isRadio,
  }) async {
    _history.removeWhere((item) => item.id == id);

    _history.insert(
      0,
      NgombiHistoryEntry(
        id: id,
        name: name,
        url: url,
        isRadio: isRadio,
        viewedAt: DateTime.now(),
      ),
    );

    if (_history.length > _maxHistory) {
      _history.removeRange(
        _maxHistory,
        _history.length,
      );
    }

    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await _preferences.remove(_historyKey);
  }

  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    notifyListeners();
    await _preferences.remove(_favoritesKey);
  }

  Future<void> _saveFavorites() async {
    await _preferences.setStringList(
      _favoritesKey,
      _favoriteIds.toList(),
    );
  }

  Future<void> _saveHistory() async {
    await _preferences.setStringList(
      _historyKey,
      _history.map(_encodeHistory).toList(),
    );
  }

  static String _encodeHistory(
    NgombiHistoryEntry entry,
  ) {
    return [
      Uri.encodeComponent(entry.id),
      Uri.encodeComponent(entry.name),
      Uri.encodeComponent(entry.url),
      entry.isRadio ? '1' : '0',
      entry.viewedAt.toIso8601String(),
    ].join('|');
  }

  static NgombiHistoryEntry? _decodeHistory(
    String value,
  ) {
    final parts = value.split('|');

    if (parts.length != 5) {
      return null;
    }

    final viewedAt = DateTime.tryParse(parts[4]);

    if (viewedAt == null) {
      return null;
    }

    return NgombiHistoryEntry(
      id: Uri.decodeComponent(parts[0]),
      name: Uri.decodeComponent(parts[1]),
      url: Uri.decodeComponent(parts[2]),
      isRadio: parts[3] == '1',
      viewedAt: viewedAt,
    );
  }
}

class NgombiStoreScope extends InheritedNotifier<NgombiStore> {
  const NgombiStoreScope({
    super.key,
    required NgombiStore store,
    required super.child,
  }) : super(notifier: store);

  static NgombiStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<NgombiStoreScope>();

    assert(
      scope != null,
      'NgombiStoreScope is missing above this context.',
    );

    return scope!.notifier!;
  }

  static NgombiStore read(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<NgombiStoreScope>();

    assert(
      scope != null,
      'NgombiStoreScope is missing above this context.',
    );

    return scope!.notifier!;
  }
}
