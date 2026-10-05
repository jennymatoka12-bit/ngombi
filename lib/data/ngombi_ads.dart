import '../models/ngombi_ad.dart';

/// Catalogue publicitaire local de démonstration.
///
/// Pour ajouter une publicité, il suffit d'ajouter un NgombiAd ici.
/// Les durées prises en charge sont libres, avec 5/15/20/30 secondes
/// recommandées pour les campagnes NGOMBI.
const List<NgombiAd> ngombiAds = [
  NgombiAd(
    id: 'demo-image-5',
    title: 'Publicité test — 5 secondes',
    type: NgombiAdType.image,
    media: 'https://placehold.co/1200x500/181818/FF8A00.png?text=NGOMBI+PUBLICITE+5s',
    duration: Duration(seconds: 5),
    clickUrl: 'https://www.rfi.fr/fr/',
    priority: 40,
  ),
  NgombiAd(
    id: 'demo-image-15',
    title: 'Publicité test — 15 secondes',
    type: NgombiAdType.image,
    media: 'https://placehold.co/1200x500/241010/FFB52E.png?text=NGOMBI+PUBLICITE+15s',
    duration: Duration(seconds: 15),
    clickUrl: 'https://www.africaradio.com/',
    priority: 30,
  ),
  NgombiAd(
    id: 'demo-video-20',
    title: 'Publicité vidéo test — 20 secondes',
    type: NgombiAdType.video,
    media:
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    duration: Duration(seconds: 20),
    clickUrl: 'https://www.bbc.com/afrique',
    priority: 20,
  ),
  NgombiAd(
    id: 'demo-image-30',
    title: 'Publicité test — 30 secondes',
    type: NgombiAdType.image,
    media: 'https://placehold.co/1200x500/111111/FFFFFF.png?text=ESPACE+ANNONCEUR+NGOMBI+30s',
    duration: Duration(seconds: 30),
    clickUrl: 'https://tvradiozap.eu/',
    priority: 10,
  ),
];
