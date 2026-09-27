import 'dart:convert';

enum StreamType {
  hls,
  dash,
  unknown,
}

class TvChannel {
  final String name;
  final String url;
  final StreamType type;
  final String category;
  final String? logo;

  const TvChannel({
    required this.name,
    required this.url,
    required this.type,
    required this.category,
    this.logo,
  });
}

List<TvChannel> parseEnigma2Bouquet(String content) {
  final channels = <TvChannel>[];

  for (final line in content.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();

    if (!trimmed.startsWith('#SERVICE ')) {
      continue;
    }

    final service = trimmed.substring('#SERVICE '.length);
    final parts = service.split(':');

    if (parts.length < 12) {
      continue;
    }

    final rawUrl = parts[10].trim();

    if (rawUrl.isEmpty) {
      continue;
    }

    final name = repairMojibake(
      parts.sublist(11).join(':').trim(),
    );

    if (name.isEmpty) {
      continue;
    }

    final url = cleanStreamUrl(rawUrl);

    if (url.isEmpty) {
      continue;
    }

    channels.add(
      TvChannel(
        name: name,
        url: url,
        type: detectStreamType(url),
        category: detectCategory(name),
      ),
    );
  }

  return channels;
}

String cleanStreamUrl(String rawUrl) {
  var url = rawUrl.trim();

  final lower = url.toLowerCase();

  if (lower.startsWith('https%3a//')) {
    url = 'https://${url.substring('https%3a//'.length)}';
  } else if (lower.startsWith('http%3a//')) {
    url = 'http://${url.substring('http%3a//'.length)}';
  }

  final hashIndex = url.indexOf('#');

  if (hashIndex >= 0) {
    url = url.substring(0, hashIndex);
  }

  return url.trim();
}

StreamType detectStreamType(String url) {
  final lower = url.toLowerCase();

  if (lower.contains('.m3u8')) {
    return StreamType.hls;
  }

  if (lower.contains('.mpd')) {
    return StreamType.dash;
  }

  return StreamType.unknown;
}

String detectCategory(String name) {
  final n = name.toLowerCase();

  if (RegExp(
    r'\bsport\b|red bull|mgg|100% sport',
  ).hasMatch(n)) {
    return 'Sport';
  }

  if (RegExp(
    r'ciné|cinema|film|movie|movies|action|drama|thriller|sci fi|science fiction|ciné nanar|cinegay',
  ).hasMatch(n)) {
    return 'Cinéma';
  }

  if (RegExp(
    r'kidz|kid |kids|cartoon|cartoonito|caillou|schtroump|toons|jeunesse|famille|wasabi',
  ).hasMatch(n)) {
    return 'Jeunesse';
  }

  if (RegExp(
    r'bfm|cnews|lci|france 24|franceinfo|france info|information|info |tech&co|le monde|francophonie24|brut',
  ).hasMatch(n)) {
    return 'Information';
  }

  if (RegExp(
    r'découverte|decouverte|earth|voyage|documentaire|histoire|science',
  ).hasMatch(n)) {
    return 'Documentaire';
  }

  if (RegExp(
    r'music|musique|trace|nrj hits|clubbing',
  ).hasMatch(n)) {
    return 'Musique';
  }

  if (RegExp(
    r'\(ch\)|\(ca\)|\(gb\)|\(be\)|\(mc\)|suisse|canada|belgique|monaco|royaume uni',
  ).hasMatch(n)) {
    return 'International';
  }

  if (RegExp(
    r'\(\d{2,3}\)|région|regional|alsace|aquitaine|bretagne|corse|normandie|occitanie|provence|lyon|marseille|toulouse|nantes|bordeaux|lille',
  ).hasMatch(n)) {
    return 'Régional';
  }

  if (RegExp(
    r'afrique|africa|gabon|sénégal|senegal|cameroun|cameroon|congo|ivoire|maroc|algerie|algérie|tunisie',
  ).hasMatch(n)) {
    return 'Afrique';
  }

  return 'France';
}

String repairMojibake(String value) {
  try {
    return utf8.decode(
      latin1.encode(value),
    );
  } catch (_) {
    return value;
  }
}
