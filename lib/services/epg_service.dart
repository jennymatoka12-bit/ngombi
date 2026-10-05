import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class EpgProgram {
  final String title;
  final DateTime start;
  final DateTime end;

  const EpgProgram({
    required this.title,
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  Duration get elapsed {
    final value = DateTime.now().toUtc().difference(start);
    if (value.isNegative) return Duration.zero;
    if (value > duration) return duration;
    return value;
  }
}

class EpgService {
  EpgService._();

  static const String _guideUrl =
      'https://iptv-epg.org/files/epg-fr.xml';

  static Future<XmlDocument?>? _documentFuture;

  static final Map<String, String> _aliases = {
    'tf1': 'TF1.fr',
    'm6': 'M6.fr',
    '6ter': '6ter.fr',
    'w9': 'W9.fr',
    'tmc': 'TMC.fr',
    'tfx': 'TFX.fr',
    'gulli': 'Gulli.fr',
    'cnews': 'CNews.fr',
    'bfm tv': 'BFMTV.fr',
    'bfmtv': 'BFMTV.fr',
    'franceinfo': 'Franceinfo.fr',
    'france info': 'Franceinfo.fr',
    'france 24': 'France24.fr',
    'arte': 'Arte.fr',
    'tf1 séries films': 'TF1SeriesFilms.fr',
    'tf1 series films': 'TF1SeriesFilms.fr',
    'rmc découverte': 'RMCDecouverte.fr',
    'rmc decouverte': 'RMCDecouverte.fr',
    'rmc story': 'RMCStory.fr',
    'rmc life': 'RMCLife.fr',
    'brut': 'Brut.fr',
  };

  static String _normalize(String value) {
    var text = value.toLowerCase().trim();

    const replacements = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ÿ': 'y',
      'ç': 'c',
      'œ': 'oe',
    };

    replacements.forEach((from, to) {
      text = text.replaceAll(from, to);
    });

    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? _channelId(String name) {
    final normalized = _normalize(name);
    final exact = _aliases[normalized];
    if (exact != null) return exact;

    for (final entry in _aliases.entries) {
      if (normalized.contains(entry.key) ||
          entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    return null;
  }

  static Future<XmlDocument?> _loadDocument() {
    return _documentFuture ??= _fetchDocument();
  }

  static Future<XmlDocument?> _fetchDocument() async {
    try {
      final response = await http
          .get(Uri.parse(_guideUrl))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;
      return XmlDocument.parse(response.body);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseXmltvDate(String value) {
    final match = RegExp(
      r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(?:\s*([+-])(\d{2})(\d{2}))?',
    ).firstMatch(value.trim());

    if (match == null) return null;

    var utc = DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );

    final sign = match.group(7);
    final hours = int.tryParse(match.group(8) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(9) ?? '') ?? 0;

    if (sign != null) {
      final offset = Duration(hours: hours, minutes: minutes);
      utc = sign == '+'
          ? utc.subtract(offset)
          : utc.add(offset);
    }

    return utc;
  }

  static Future<EpgProgram?> _find(
    String channelName, {
    required bool next,
  }) async {
    final channelId = _channelId(channelName);
    if (channelId == null) return null;

    final document = await _loadDocument();
    if (document == null) return null;

    final now = DateTime.now().toUtc();
    EpgProgram? candidate;

    for (final node in document.findAllElements('programme')) {
      if (node.getAttribute('channel') != channelId) continue;

      final startRaw = node.getAttribute('start');
      final stopRaw = node.getAttribute('stop');
      final title = node.getElement('title')?.innerText.trim();

      if (startRaw == null ||
          stopRaw == null ||
          title == null ||
          title.isEmpty) {
        continue;
      }

      final start = _parseXmltvDate(startRaw);
      final end = _parseXmltvDate(stopRaw);

      if (start == null || end == null) continue;

      final matches = next
          ? start.isAfter(now)
          : !now.isBefore(start) && now.isBefore(end);

      if (!matches) continue;

      final program = EpgProgram(
        title: title,
        start: start,
        end: end,
      );

      if (!next || candidate == null || program.start.isBefore(candidate.start)) {
        candidate = program;
      }

      if (!next) return program;
    }

    return candidate;
  }

  static Future<EpgProgram?> current(String channelName) {
    return _find(channelName, next: false);
  }

  static Future<EpgProgram?> upcoming(String channelName) {
    return _find(channelName, next: true);
  }
}
