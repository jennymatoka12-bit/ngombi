import 'dart:convert';

enum StreamType { hls, dash, unknown }

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

  String get id => '${name.trim().toLowerCase()}|$url';
}

List<TvChannel> parseEnigma2Bouquet(String content) {
  final channels = <TvChannel>[];
  String? pendingUserAgent;
  for (final line in content.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#EXTVLCOPT:http-user-agent=')) {
      pendingUserAgent = trimmed.substring('#EXTVLCOPT:http-user-agent='.length).trim();
      continue;
    }
    if (!trimmed.startsWith('#SERVICE ')) continue;
    final parts = trimmed.substring('#SERVICE '.length).split(':');
    if (parts.length < 11) { pendingUserAgent = null; continue; }
    final raw = parts.sublist(10).join(':');
    final separator = raw.lastIndexOf(':');
    if (separator <= 0 || separator >= raw.length - 1) { pendingUserAgent = null; continue; }
    final url = cleanStreamUrl(raw.substring(0, separator));
    final name = repairMojibake(raw.substring(separator + 1).trim());
    if (url.isEmpty || name.isEmpty) { pendingUserAgent = null; continue; }
    final lower = url.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) { pendingUserAgent = null; continue; }
    final headers = <String,String>{};
    if (pendingUserAgent?.isNotEmpty == true) {
      headers['User-Agent'] = pendingUserAgent!;
    } else if (lower.contains('tvradiozap.eu')) {
      headers['User-Agent'] = 'Mozilla/5.0';
    }
    channels.add(TvChannel(name:name,url:url,type:detectStreamType(url),category:detectCategory(name),headers:headers));
    pendingUserAgent = null;
  }
  return channels;
}

String cleanStreamUrl(String raw) {
  var url = raw.trim();
  try { url = Uri.decodeFull(url); } catch (_) {}
  final hash = url.indexOf('#');
  if (hash >= 0) url = url.substring(0, hash);
  return url.trim();
}
StreamType detectStreamType(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('.m3u8')) return StreamType.hls;
  if (lower.contains('.mpd')) return StreamType.dash;
  return StreamType.unknown;
}
String detectCategory(String name) {
  final n = name.toLowerCase();
  if (RegExp(r'\bsport\b|red bull|mgg').hasMatch(n)) return 'Sport';
  if (RegExp(r'ciné|cinema|film|movie|action|drama|thriller|rakuten').hasMatch(n)) return 'Cinéma';
  if (RegExp(r'kidz|kid |kids|cartoon|cartoonito|schtroump|toons|jeunesse|famille|wasabi|gulli').hasMatch(n)) return 'Jeunesse';
  if (RegExp(r'bfm|cnews|lci|france 24|franceinfo|information|info |tech&co|le monde|brut').hasMatch(n)) return 'Information';
  if (RegExp(r'découverte|decouverte|earth|voyage|documentaire|histoire|science').hasMatch(n)) return 'Documentaire';
  if (RegExp(r'music|musique|trace|nrj|clubbing').hasMatch(n)) return 'Musique';
  if (RegExp(r'\(ch\)|\(ca\)|\(gb\)|\(be\)|\(mc\)|suisse|canada|belgique|monaco').hasMatch(n)) return 'International';
  if (RegExp(r'\(\d{2,3}\)|région|regional|alsace|aquitaine|bretagne|corse|normandie|occitanie|provence|lyon|marseille|toulouse|nantes|bordeaux|lille').hasMatch(n)) return 'Régional';
  if (RegExp(r'afrique|africa|gabon|sénégal|senegal|cameroun|cameroon|congo|ivoire|maroc|algerie|algérie|tunisie|2stv|canal 2|nci|crtv').hasMatch(n)) return 'Afrique';
  return 'France';
}
String repairMojibake(String value) {
  try { return utf8.decode(latin1.encode(value)); } catch (_) { return value; }
}
