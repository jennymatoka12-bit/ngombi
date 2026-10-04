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
    final radius =
        borderRadius ?? BorderRadius.circular(size * 0.18);
    final logoPath = _logoPath(channel.name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
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

  Widget _fallback() {
    return const Center(
      child: Icon(
        Icons.tv_rounded,
        size: 34,
        color: Color(0xFFFFA21A),
      ),
    );
  }

  String? _logoPath(String name) {
    final normalized = _normalize(name);

    const logos = <String, String>{
      'tf1': 'assets/logos/tf1.png',
      'm6': 'assets/logos/m6.png',
      'arte': 'assets/logos/arte.png',
      'gulli': 'assets/logos/Gulli.png',
      'cnews': 'assets/logos/cnews.png',
      'france info': 'assets/logos/Franceinfo.png',
      'franceinfo': 'assets/logos/Franceinfo.png',
      'france 24': 'assets/logos/france24.png',
      'brut': 'assets/logos/Brut.png',
      'bfm2': 'assets/logos/BFM2.png',
      'bfm tv': 'assets/logos/bfmtv.png',
      'bfmtv': 'assets/logos/bfmtv.png',
      'ina 70': 'assets/logos/INA 70.png',
      'ina ardivision': 'assets/logos/INA 70.png',
      'africa 24': 'assets/logos/africa24.png',
      'africa 24 english': 'assets/logos/africa24.png',
      'africa 24 sport': 'assets/logos/africa24.png',
      'gabon premiere': 'assets/logos/gabon1ere.png',
      'gabon 1ere': 'assets/logos/gabon1ere.png',
      'gabon 24': 'assets/logos/gabon24.png',
      'crtv': 'assets/logos/crtv.png',
      'nci': 'assets/logos/nci.png',
      '2stv': 'assets/logos/2stv.png',
      // Le nom du fichier actuellement présent dans le dépôt est conservé
      // tel quel afin de ne pas modifier l'image fournie.
      'cannes lerins tv': 'assets/logos/cannes l�rins tv.png',
    };

    // TF1 Séries Films utilise actuellement le logo TF1 lorsqu'il n'existe
    // pas de fichier TF1 Séries Films dédié dans assets/logos.
    if (normalized == 'tf1 series films') {
      return logos['tf1'];
    }

    return logos[normalized];
  }

  String _normalize(String value) {
    var result = value.toLowerCase().trim();

    // Répare les noms mal encodés provenant du bouquet Enigma2.
    result = result
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã¨', 'è')
        .replaceAll('Ãª', 'ê')
        .replaceAll('Ã«', 'ë')
        .replaceAll('Ã ', 'à')
        .replaceAll('Ã¢', 'â')
        .replaceAll('Ã®', 'î')
        .replaceAll('Ã¯', 'ï')
        .replaceAll('Ã´', 'ô')
        .replaceAll('Ã¹', 'ù')
        .replaceAll('Ã»', 'û')
        .replaceAll('Ã§', 'ç');

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
        .replaceAll('ç', 'c');
  }
}
