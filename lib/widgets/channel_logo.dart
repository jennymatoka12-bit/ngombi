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

    // ==========================================================
    // CHAÎNES FRANÇAISES — TNT / GRANDES CHAÎNES
    // ==========================================================

    if (_is(normalized, [
      'tf1',
    ])) {
      return 'assets/logos/tf1.png';
    }

    if (_is(normalized, [
      'france 2',
    ])) {
      return 'assets/logos/france2.png';
    }

    if (_is(normalized, [
      'france 3',
    ])) {
      return 'assets/logos/france3.png';
    }

    if (_is(normalized, [
      'france 4',
    ])) {
      return 'assets/logos/france4.png';
    }

    if (_is(normalized, [
      'france 5',
    ])) {
      return 'assets/logos/france5.png';
    }

    if (_is(normalized, [
      'm6',
    ])) {
      return 'assets/logos/m6.png';
    }

    if (_is(normalized, [
      'arte',
    ])) {
      return 'assets/logos/arte.png';
    }

    if (_is(normalized, [
      'w9',
    ])) {
      return 'assets/logos/w9.png';
    }

    if (_is(normalized, [
      'tmc',
    ])) {
      return 'assets/logos/tmc.png';
    }

    if (_is(normalized, [
      'tfx',
    ])) {
      return 'assets/logos/tfx.png';
    }

    if (_is(normalized, [
      'gulli',
    ])) {
      return 'assets/logos/gulli.png';
    }

    if (_is(normalized, [
      'tf1 series films',
    ])) {
      return 'assets/logos/tf1seriesfilms.png';
    }

    if (_is(normalized, [
      '6ter',
    ])) {
      return 'assets/logos/6ter.png';
    }

    if (_is(normalized, [
      'novo19',
    ])) {
      return 'assets/logos/novo19.png';
    }

    // ==========================================================
    // INFORMATION
    // ==========================================================

    if (_is(normalized, [
      'bfm tv',
      'bfmtv',
    ])) {
      return 'assets/logos/bfmtv.png';
    }

    if (_is(normalized, [
      'cnews',
    ])) {
      return 'assets/logos/cnews.png';
    }

    if (_is(normalized, [
      'lci',
    ])) {
      return 'assets/logos/lci.png';
    }

    if (_is(normalized, [
      'france info',
      'franceinfo',
    ])) {
      return 'assets/logos/franceinfo.png';
    }

    if (_is(normalized, [
      'france 24',
    ])) {
      return 'assets/logos/france24.png';
    }

    if (_is(normalized, [
      'francophonie24',
    ])) {
      return 'assets/logos/francophonie24.png';
    }

    if (_is(normalized, [
      'tech&co',
      'tech co',
    ])) {
      return 'assets/logos/techandco.png';
    }

    if (_is(normalized, [
      'le figaro tv',
    ])) {
      return 'assets/logos/lefigarotv.png';
    }

    if (_is(normalized, [
      'brut',
    ])) {
      return 'assets/logos/brut.png';
    }

    if (_is(normalized, [
      'bfm grands reportages',
    ])) {
      return 'assets/logos/bfmgrandsreportages.png';
    }

    if (_is(normalized, [
      'bfm business',
    ])) {
      return 'assets/logos/bfmbusiness.png';
    }

    if (_is(normalized, [
      'bfm2',
    ])) {
      return 'assets/logos/bfm2.png';
    }

    if (_is(normalized, [
      'le monde en 24 h',
    ])) {
      return 'assets/logos/lemonde24h.png';
    }

    if (_is(normalized, [
      'rmc talk info',
    ])) {
      return 'assets/logos/rmctalkinfo.png';
    }

    if (_is(normalized, [
      'tv5monde info',
    ])) {
      return 'assets/logos/tv5mondeinfo.png';
    }

    // ==========================================================
    // RMC
    // ==========================================================

    if (_is(normalized, [
      'rmc story',
    ])) {
      return 'assets/logos/rmcstory.png';
    }

    if (_is(normalized, [
      'rmc decouverte',
    ])) {
      return 'assets/logos/rmcdecouverte.png';
    }

    if (_is(normalized, [
      'rmc life',
    ])) {
      return 'assets/logos/rmclife.png';
    }

    if (_is(normalized, [
      'rmc mystere',
    ])) {
      return 'assets/logos/rmcmystere.png';
    }

    if (_is(normalized, [
      'rmc mecanic',
    ])) {
      return 'assets/logos/rmcmecanic.png';
    }

    if (_is(normalized, [
      'rmc wow',
    ])) {
      return 'assets/logos/rmcwow.png';
    }

    // ==========================================================
    // CANAL+
    // ==========================================================

    if (_is(normalized, [
      'canal+',
      'canal plus',
    ])) {
      return 'assets/logos/canalplus.png';
    }

    if (_is(normalized, [
      'cstar',
    ])) {
      return 'assets/logos/cstar.png';
    }

    // ==========================================================
    // TV5MONDE
    // ==========================================================

    if (_is(normalized, [
      'tv5monde europe',
    ])) {
      return 'assets/logos/tv5monde.png';
    }

    if (_is(normalized, [
      'tv5monde fbs',
    ])) {
      return 'assets/logos/tv5monde.png';
    }

    if (_is(normalized, [
      'tv5monde chefs',
    ])) {
      return 'assets/logos/tv5monde.png';
    }

    // ==========================================================
    // SPORT
    // ==========================================================

    if (_is(normalized, [
      'red bull',
    ])) {
      return 'assets/logos/redbull.png';
    }

    if (_is(normalized, [
      'sport en france',
    ])) {
      return 'assets/logos/sportenfrance.png';
    }

    if (_is(normalized, [
      'mgg esport',
    ])) {
      return 'assets/logos/mgg.png';
    }

    if (_is(normalized, [
      'l equipe',
    ])) {
      return 'assets/logos/lequipe.png';
    }

    // ==========================================================
    // CINÉMA / FILMS
    // ==========================================================

    if (_is(normalized, [
      'tf1 series films',
    ])) {
      return 'assets/logos/tf1seriesfilms.png';
    }

    if (_is(normalized, [
      'brefcinema',
    ])) {
      return 'assets/logos/brefcinema.png';
    }

    if (_is(normalized, [
      'noovo cinema',
    ])) {
      return 'assets/logos/noovocinema.png';
    }

    if (_is(normalized, [
      '100 cinema',
    ])) {
      return 'assets/logos/100cinema.png';
    }

    if (_is(normalized, [
      'action totale',
    ])) {
      return 'assets/logos/actiontotale.png';
    }

    if (_is(normalized, [
      'allocine',
    ])) {
      return 'assets/logos/allocine.png';
    }

    if (_is(normalized, [
      'box office action',
      'box office drama',
      'box office thrillers',
    ])) {
      return 'assets/logos/boxoffice.png';
    }

    if (_is(normalized, [
      'cine nanar',
      'cine sci-fi',
      'cine western',
      'cinegay',
    ])) {
      return 'assets/logos/cine.png';
    }

    if (_is(normalized, [
      'emotion l',
    ])) {
      return 'assets/logos/emotionl.png';
    }

    if (_is(normalized, [
      'lg 1 film',
    ])) {
      return 'assets/logos/lg1film.png';
    }

    if (_is(normalized, [
      'moviesphere',
    ])) {
      return 'assets/logos/moviesphere.png';
    }

    if (_is(normalized, [
      'mytime movie network',
    ])) {
      return 'assets/logos/mytime.png';
    }

    if (_is(normalized, [
      'plu.tv french collection',
    ])) {
      return 'assets/logos/plutv.png';
    }

    if (normalized.startsWith('rakuten tv ')) {
      return 'assets/logos/rakutentv.png';
    }

    if (_is(normalized, [
      'sci-fi',
    ])) {
      return 'assets/logos/rakutentv.png';
    }

    if (_is(normalized, [
      'screamin',
    ])) {
      return 'assets/logos/screamin.png';
    }

    if (_is(normalized, [
      'shark tv',
    ])) {
      return 'assets/logos/sharktv.png';
    }

    if (normalized.startsWith('sony one hits')) {
      return 'assets/logos/sonyone.png';
    }

    if (_is(normalized, [
      'top action',
    ])) {
      return 'assets/logos/topaction.png';
    }

    if (_is(normalized, [
      'trailers',
    ])) {
      return 'assets/logos/trailers.png';
    }

    if (_is(normalized, [
      '100 comedy',
    ])) {
      return 'assets/logos/100comedy.png';
    }

    // ==========================================================
    // JEUNESSE
    // ==========================================================

    if (_is(normalized, [
      '100 kidz',
    ])) {
      return 'assets/logos/100kidz.png';
    }

    if (_is(normalized, [
      'adn',
    ])) {
      return 'assets/logos/adn.png';
    }

    if (_is(normalized, [
      'caillou',
    ])) {
      return 'assets/logos/caillou.png';
    }

    if (_is(normalized, [
      'cartoonito',
    ])) {
      return 'assets/logos/cartoonito.png';
    }

    if (_is(normalized, [
      'les schtroumpfs',
    ])) {
      return 'assets/logos/schtroumpfs.png';
    }

    if (_is(normalized, [
      'plu.tv retro toons',
    ])) {
      return 'assets/logos/plutv.png';
    }

    if (_is(normalized, [
      'rakuten tv famille',
    ])) {
      return 'assets/logos/rakutentv.png';
    }

    if (_is(normalized, [
      'supertoons',
    ])) {
      return 'assets/logos/supertoons.png';
    }

    if (_is(normalized, [
      'wasabi',
    ])) {
      return 'assets/logos/wasabi.png';
    }

    if (_is(normalized, [
      'mr. bean',
      'mr bean',
    ])) {
      return 'assets/logos/mrbean.png';
    }

    // ==========================================================
    // DOCUMENTAIRE / DÉCOUVERTE
    // ==========================================================

    if (_is(normalized, [
      'bbc earth',
    ])) {
      return 'assets/logos/bbcearth.png';
    }

    if (_is(normalized, [
      'arte invitation au voyage',
    ])) {
      return 'assets/logos/arte.png';
    }

    if (_is(normalized, [
      'ina 70',
    ])) {
      return 'assets/logos/ina.png';
    }

    if (_is(normalized, [
      'ina ardivision',
    ])) {
      return 'assets/logos/ina.png';
    }

    if (_is(normalized, [
      'la maison france 5',
    ])) {
      return 'assets/logos/france5.png';
    }

    if (_is(normalized, [
      'mieux',
    ])) {
      return 'assets/logos/mieux.png';
    }

    if (_is(normalized, [
      'rustica',
    ])) {
      return 'assets/logos/rustica.png';
    }

    if (_is(normalized, [
      'systeme d',
    ])) {
      return 'assets/logos/systemed.png';
    }

    if (_is(normalized, [
      'les secrets de nos regions',
    ])) {
      return 'assets/logos/lessecretsdenosregions.png';
    }

    // ==========================================================
    // AFRIQUE
    // ==========================================================

    if (_is(normalized, [
      'gabon premiere',
      'gabon 1ere',
    ])) {
      return 'assets/logos/gabon1ere.png';
    }

    if (_is(normalized, [
      'gabon 24',
    ])) {
      return 'assets/logos/gabon24.png';
    }

    if (_is(normalized, [
      'africa 24',
    ])) {
      return 'assets/logos/africa24.png';
    }

    if (_is(normalized, [
      'africa 24 english',
    ])) {
      return 'assets/logos/africa24.png';
    }

    if (_is(normalized, [
      'africa 24 sport',
    ])) {
      return 'assets/logos/africa24.png';
    }

    if (_is(normalized, [
      'africanews english',
    ])) {
      return 'assets/logos/africanews.png';
    }

    if (_is(normalized, [
      'africanews francais',
    ])) {
      return 'assets/logos/africanews.png';
    }

    if (_is(normalized, [
      'crtv',
    ])) {
      return 'assets/logos/crtv.png';
    }

    if (_is(normalized, [
      'nci',
    ])) {
      return 'assets/logos/nci.png';
    }

    if (_is(normalized, [
      '2stv',
    ])) {
      return 'assets/logos/2stv.png';
    }

    if (_is(normalized, [
      'canal 2 international',
    ])) {
      return 'assets/logos/canal2international.png';
    }

    // ==========================================================
    // SUISSE / BELGIQUE / MONACO / INTERNATIONAL
    // ==========================================================

    if (_is(normalized, [
      'bx1',
      'bx1 bruxelles be',
    ])) {
      return 'assets/logos/bx1.png';
    }

    if (_is(normalized, [
      'tv monaco mc',
    ])) {
      return 'assets/logos/tvmonaco.png';
    }

    if (normalized.startsWith('carac')) {
      return 'assets/logos/carac.png';
    }

    if (_is(normalized, [
      'leman bleu ch',
      'leman bleu',
    ])) {
      return 'assets/logos/lemanbleu.png';
    }

    if (_is(normalized, [
      'rts info',
    ])) {
      return 'assets/logos/rtsinfo.png';
    }

    if (_is(normalized, [
      'ici rdi ca',
      'ici rdi',
    ])) {
      return 'assets/logos/ici-rdi.png';
    }

    if (_is(normalized, [
      'tv5monde europe',
      'tv5monde fbs',
      'tv5monde chefs',
      'tv5monde info',
    ])) {
      return 'assets/logos/tv5monde.png';
    }

    // ==========================================================
    // CHAÎNES LOCALES
    // ==========================================================

    if (_is(normalized, [
      '7a limoges',
    ])) {
      return 'assets/logos/7alimoges.png';
    }

    if (_is(normalized, [
      'alpe d huez',
    ])) {
      return 'assets/logos/alpedhuez.png';
    }

    if (_is(normalized, [
      'angers tele',
    ])) {
      return 'assets/logos/angers.png';
    }

    if (_is(normalized, [
      'astv',
    ])) {
      return 'assets/logos/astv.png';
    }

    if (_is(normalized, [
      'bordo tv',
    ])) {
      return 'assets/logos/bordotv.png';
    }

    if (_is(normalized, [
      'brionnais tv',
    ])) {
      return 'assets/logos/brionnais.png';
    }

    if (_is(normalized, [
      'cannes lerins tv',
    ])) {
      return 'assets/logos/canneslerins.png';
    }

    if (_is(normalized, [
      'dcm tv 91',
    ])) {
      return 'assets/logos/dcmtv.png';
    }

    if (_is(normalized, [
      'iltv henin-carvin',
    ])) {
      return 'assets/logos/iltv.png';
    }

    if (_is(normalized, [
      'lyon capitale tv',
    ])) {
      return 'assets/logos/lyoncapitale.png';
    }

    if (_is(normalized, [
      'maurienne tv',
    ])) {
      return 'assets/logos/maurienne.png';
    }

    if (_is(normalized, [
      'mosaik cristal',
    ])) {
      return 'assets/logos/mosaik.png';
    }

    if (_is(normalized, [
      'na tv 33',
    ])) {
      return 'assets/logos/natv.png';
    }

    if (_is(normalized, [
      'ptv 52+55',
    ])) {
      return 'assets/logos/ptv.png';
    }

    if (_is(normalized, [
      'tv3v 67',
    ])) {
      return 'assets/logos/tv3v.png';
    }

    if (_is(normalized, [
      'tv7 colmar',
    ])) {
      return 'assets/logos/tv7.png';
    }

    if (_is(normalized, [
      'tvpi 40+64',
    ])) {
      return 'assets/logos/tvpi.png';
    }

    // ==========================================================
    // AUTRES / DIVERTISSEMENT
    // ==========================================================

    if (_is(normalized, [
      'novo19',
    ])) {
      return 'assets/logos/novo19.png';
    }

    if (_is(normalized, [
      'show!',
      'show',
    ])) {
      return 'assets/logos/show.png';
    }

    if (_is(normalized, [
      '750g',
    ])) {
      return 'assets/logos/750g.png';
    }

    if (_is(normalized, [
      'drive tv',
    ])) {
      return 'assets/logos/drivetv.png';
    }

    if (_is(normalized, [
      'lg 1',
    ])) {
      return 'assets/logos/lg1.png';
    }

    if (_is(normalized, [
      'lg 1+1',
    ])) {
      return 'assets/logos/lg1plus1.png';
    }

    if (_is(normalized, [
      '100 comedy',
    ])) {
      return 'assets/logos/100comedy.png';
    }

    if (_is(normalized, [
      'mdl',
    ])) {
      return 'assets/logos/mdl.png';
    }

    if (_is(normalized, [
      'emotion',
    ])) {
      return 'assets/logos/emotion.png';
    }

    if (_is(normalized, [
      'generation tv',
    ])) {
      return 'assets/logos/generationtv.png';
    }

    return null;
  }

  bool _is(
    String value,
    List<String> candidates,
  ) {
    return candidates.contains(value);
  }

  String _normalize(String value) {
    var result = value.toLowerCase().trim();

    // Correction du mojibake présent dans le bouquet
    // Exemple : "DÃ©couverte" → "Découverte"
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
        .replaceAll('Ã§', 'ç')
        .replaceAll('Ã¯', 'ï');

    // Normalisation pour les noms de fichiers / comparaisons.
    result = result
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

    return result;
  }
}
