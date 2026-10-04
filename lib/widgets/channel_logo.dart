import 'package:flutter/material.dart';

import '../models/tv_channel.dart';

class ChannelLogo extends StatelessWidget {
  final TvChannel channel;
  final double size;
  final BorderRadius? borderRadius;

  const ChannelLogo({
    super.key,
    required this.channel,
    this.size = 64,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.18);
    final logoPath = _logoPath(channel.name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: radius,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath == null
          ? _fallback()
          : Image.asset(
              logoPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _fallback(),
            ),
    );
  }

  Widget _fallback() => const Center(
        child: Icon(
          Icons.tv_rounded,
          size: 34,
          color: Color(0xFFFFA21A),
        ),
      );

  String? _logoPath(String name) {
    final n = _normalize(name);

    // Logos nommés explicitement dans assets/logos/.
    const exact = <String, String>{
      'tf1': 'assets/logos/tf1.png',
      'm6': 'assets/logos/m6.png',
      'arte': 'assets/logos/arte.png',
      'gulli': 'assets/logos/Gulli.png',
      'cnews': 'assets/logos/cnews.png',
      'france info': 'assets/logos/Franceinfo.png',
      'franceinfo': 'assets/logos/Franceinfo.png',
      'france 24': 'assets/logos/france24.png',
      'africa 24': 'assets/logos/africa24.png',
      'africa 24 english': 'assets/logos/africa24.png',
      'africa 24 sport': 'assets/logos/africa24.png',
      'brut': 'assets/logos/Brut.png',
      'bfm2': 'assets/logos/BFM2.png',
      'bfm tv': 'assets/logos/bfmtv.png',
      'bfmtv': 'assets/logos/bfmtv.png',
      'ina 70': 'assets/logos/INA 70.png',
      'ina ardivision': 'assets/logos/INA 70.png',
      'gabon premiere': 'assets/logos/gabon1ere.png',
      'gabon 1ere': 'assets/logos/gabon1ere.png',
      'gabon 24': 'assets/logos/gabon24.png',
      'crtv': 'assets/logos/crtv.png',
      'nci': 'assets/logos/nci.png',
      '2stv': 'assets/logos/2stv.png',
      'cannes lerins tv': 'assets/logos/cannes l�rins tv.png',
    };

    final direct = exact[n];
    if (direct != null) return direct;

    // Logos spécialisés : on réutilise le logo de la marque lorsque le
    // bouquet contient une déclinaison pour laquelle aucun fichier dédié
    // n'existe encore.
    if (n == 'tf1 series films') return exact['tf1'];
    if (n.startsWith('bfm ')) return exact['bfm tv'];
    if (n.startsWith('france 24')) return exact['france 24'];
    if (n.startsWith('africa 24')) return exact['africa 24'];
    if (n.startsWith('gabon 1ere')) return exact['gabon 1ere'];
    if (n.startsWith('gabon 24')) return exact['gabon 24'];
    if (n.startsWith('ina ')) return exact['ina 70'];
    if (n.startsWith('gulli')) return exact['gulli'];
    if (n.startsWith('cnews')) return exact['cnews'];

    return null;
  }

  String _normalize(String value) {
    var result = value.toLowerCase().trim();

    // Répare les noms UTF-8 mal décodés provenant du bouquet Enigma2.
    const mojibake = <String, String>{
      'Ã©': 'é',
      'Ã¨': 'è',
      'Ãª': 'ê',
      'Ã«': 'ë',
      'Ã ': 'à',
      'Ã¢': 'â',
      'Ã®': 'î',
      'Ã¯': 'ï',
      'Ã´': 'ô',
      'Ã¹': 'ù',
      'Ã»': 'û',
      'Ã§': 'ç',
    };

    mojibake.forEach((from, to) {
      result = result.replaceAll(from, to);
    });

    return result
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
