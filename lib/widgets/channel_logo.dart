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
      child: logoPath != null
          ? Image.asset(
              logoPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _fallback();
              },
            )
          : _fallback(),
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
      'france 2': 'assets/logos/france2.png',
      'france 3': 'assets/logos/france3.png',
      'france 4': 'assets/logos/france4.png',
      'france 5': 'assets/logos/france5.png',
      'm6': 'assets/logos/m6.png',
      'bfmtv': 'assets/logos/bfmtv.png',
      'cnews': 'assets/logos/cnews.png',
      'lci': 'assets/logos/lci.png',
      'france 24': 'assets/logos/france24.png',
      'franceinfo': 'assets/logos/franceinfo.png',
      'gabon 24': 'assets/logos/gabon24.png',
      'gabon premiere': 'assets/logos/gabon1ere.png',
      'crtv': 'assets/logos/crtv.png',
      'nci': 'assets/logos/nci.png',
      '2stv': 'assets/logos/2stv.png',
      'canal 2 international': 'assets/logos/canal2international.png',
      'rti 1': 'assets/logos/rti1.png',
      'rti 2': 'assets/logos/rti2.png',
      'life tv': 'assets/logos/lifetv.png',
      'tfm': 'assets/logos/tfm.png',
      'walfadjri tv': 'assets/logos/walfadjri.png',
      'walf tv': 'assets/logos/walfadjri.png',
      'rts 1': 'assets/logos/rts1.png',
      'rts 2': 'assets/logos/rts2.png',
    };

    return logos[normalized];
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
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
        .replaceAll('û', 'u');
  }
}
