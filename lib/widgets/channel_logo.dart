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

    // Logos historiques déjà nommés dans assets/logos/.
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

    // Nouveaux logos fournis dans le dépôt. Les noms de fichiers numériques
    // sont volontairement associés ici aux noms réels du bouquet : cela
    // évite toute dépendance à une convention de nommage des fichiers.
    const uploaded = <String, String>{
      '6ter': 'assets/logos/1000400966.jpg',
      '2stv': 'assets/logos/1000400964.png',
      '7a limoges': 'assets/logos/1000400968.png',
      'africanews english': 'assets/logos/1000400973.png',
      'africanews francais': 'assets/logos/1000400973.png',
      'africanews français': 'assets/logos/1000400973.png',
      'alpe d huez': 'assets/logos/1000400974.png',
      'angers tele': 'assets/logos/1000400975.png',
      'angers télé': 'assets/logos/1000400975.png',
      'astv': 'assets/logos/1000400978.jpg',
      'bfm business': 'assets/logos/1000400979.jpg',
      'bfm grands reportages': 'assets/logos/1000400981.jpg',
      'brefcinema': 'assets/logos/1000400985.jpg',
      'bref cinéma': 'assets/logos/1000400985.jpg',
      'brionnais tv': 'assets/logos/1000400986.jpg',
      'canal 2 international': 'assets/logos/1000400988.jpg',
      'le monde en 24 h': 'assets/logos/1000401001.jpg',
      'mgg esport': 'assets/logos/1000401005.png',
      'noovo cinema': 'assets/logos/1000401008.jpg',
      'noovo cinéma': 'assets/logos/1000401008.jpg',
      'rakuten tv comedies': 'assets/logos/1000401009.jpg',
      'rakuten tv comédies': 'assets/logos/1000401009.jpg',
      'rakuten tv thrillers': 'assets/logos/1000401010.jpg',
      'rakuten tv top films': 'assets/logos/1000401013.jpg',
      'rakuten tv action': 'assets/logos/1000401015.jpg',
      'red bull': 'assets/logos/1000401016.jpg',
      'rmc decouverte': 'assets/logos/1000401017.jpg',
      'rmc découverte': 'assets/logos/1000401017.jpg',
      'rmc life': 'assets/logos/1000401018.png',
      'rmc mecanic': 'assets/logos/1000401019.jpg',
      'rmc mecànic': 'assets/logos/1000401019.jpg',
      'rmc mystere': 'assets/logos/1000401020.jpg',
      'rmc mystère': 'assets/logos/1000401020.jpg',
      'rmc story': 'assets/logos/1000401021.jpg',
      'rmc talk info': 'assets/logos/1000401022.png',
      'rmc talk info sport': 'assets/logos/1000401022.png',
      'rmc wow': 'assets/logos/1000401023.jpg',
      'tech co': 'assets/logos/1000401025.jpg',
      'tech&co': 'assets/logos/1000401025.jpg',
      'tf1 series films': 'assets/logos/1000401026.jpg',
      'tf1 séries films': 'assets/logos/1000401026.jpg',
      'tmc': 'assets/logos/1000401030.jpg',
      'tv5monde europe': 'assets/logos/1000401031.png',
      'tv5monde fbs': 'assets/logos/1000401031.png',
      'w9': 'assets/logos/1000401032.jpg',
    };

    final uploadedLogo = uploaded[n];
    if (uploadedLogo != null) return uploadedLogo;

    // Logos spécialisés : on réutilise le logo de la marque lorsque le
    // bouquet contient une déclinaison sans fichier dédié.
    if (n == 'tf1 series films') return 'assets/logos/1000401026.jpg';
    if (n.startsWith('bfm ') && n != 'bfm business' && n != 'bfm grands reportages') {
      return exact['bfm tv'];
    }
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
        .replaceAll('&', ' ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
