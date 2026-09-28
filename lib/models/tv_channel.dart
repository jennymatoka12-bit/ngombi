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
  final Map<String, String> headers;

  const TvChannel({
    required this.name,
    required this.url,
    required this.type,
    required this.category,
    this.logo,
    this.headers = const {},
  });
}

List<TvChannel> parseEnigma2Bouquet(String content) {
  final channels = <TvChannel>[];

  String? pendingUserAgent;

  for (final line in content.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();

    // User-Agent associé au service suivant.
    if (trimmed.startsWith('#EXTVLCOPT:http-user-agent=')) {
      pendingUserAgent = trimmed
          .substring('#EXTVLCOPT:http-user-agent='.length)
          .trim();

      continue;
    }

    if (!trimmed.startsWith('#SERVICE ')) {
      continue;
    }

    final service = trimmed.substring('#SERVICE '.length);

    /*
     * Une ligne Enigma2 ressemble à :
     *
     * #SERVICE 4097:0:1:...:URL:Nom
     *
     * Le problème est que l'URL elle-même peut contenir
     * plusieurs ':' comme dans :
     *
     * https://exemple.com/stream.m3u8
     *
     * On conserve donc les 10 premiers champs puis
     * on reconstruit le reste.
     */
    final parts = service.split(':');

    if (parts.length < 11) {
      pendingUserAgent = null;
      continue;
    }

    /*
     * Les champs 0 à 9 correspondent à la partie technique
     * de la référence Enigma2.
     *
     * Tout ce qui suit contient :
     *
     * URL:Nom de chaîne
     *
     * On utilise le dernier ':' comme séparateur entre
     * l'URL et le nom.
     */
    final rawUrlAndName = parts.sublist(10).join(':');

    final separatorIndex = rawUrlAndName.lastIndexOf(':');

    if (separatorIndex <= 0 ||
        separatorIndex >= rawUrlAndName.length - 1) {
      pendingUserAgent = null;
      continue;
    }

    final rawUrl = rawUrlAndName
        .substring(0, separatorIndex)
        .trim();

    final name = repairMojibake(
      rawUrlAndName
          .substring(separatorIndex + 1)
          .trim(),
    );

    if (rawUrl.isEmpty || name.isEmpty) {
      pendingUserAgent = null;
      continue;
    }

    final url = cleanStreamUrl(rawUrl);

    if (url.isEmpty) {
      pendingUserAgent = null;
      continue;
    }

    /*
     * On ignore les services qui ne correspondent pas
     * réellement à une URL exploitable.
     */
    final lowerUrl = url.toLowerCase();

    if (!lowerUrl.startsWith('http://') &&
        !lowerUrl.startsWith('https://')) {
      pendingUserAgent = null;
      continue;
    }

    final headers = <String, String>{};

    /*
     * Si le bouquet fournit un User-Agent spécifique,
     * on le conserve.
     *
     * Sinon, les flux TVRadioZap reçoivent un User-Agent
     * navigateur standard.
     */
    if (pendingUserAgent != null &&
        pendingUserAgent!.isNotEmpty) {
      headers['User-Agent'] = pendingUserAgent!;
    } else if (lowerUrl.contains('tvradiozap.eu')) {
      headers['User-Agent'] = 'Mozilla/5.0';
    }

    channels.add(
      TvChannel(
        name: name,
        url: url,
        type: detectStreamType(url),
        category: detectCategory(name),
        headers: headers,
      ),
    );

    pendingUserAgent = null;
  }

  return channels;
}

String cleanStreamUrl(String rawUrl) {
  var url = rawUrl.trim();

  /*
   * Certaines listes Enigma2 contiennent des URL
   * partiellement encodées :
   *
   * https%3a//...
   * https%3A%2F%2F...
   *
   * On tente donc de décoder les caractères percent-encodés.
   */
  try {
    url = Uri.decodeFull(url);
  } catch (_) {
    // Si le décodage échoue, on conserve l'URL originale.
  }

  /*
   * Nettoyage éventuel d'un fragment situé après l'URL.
   */
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
