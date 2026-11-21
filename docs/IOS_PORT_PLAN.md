# NGOMBI iOS — plan de portage initial

## Objectif

Préparer une version iOS indépendante de NGOMBI, sans modifier les branches Android ou Windows. Cette branche est créée depuis `main`.

## État de départ constaté

- Application Flutter existante.
- Dépendances repérées : `video_player`, `webview_flutter`, `url_launcher`, `shared_preferences`, `supabase_flutter`, `http` et `xml`.
- Les sources iOS natives (`ios/Runner`, `ios/Podfile`) ne sont pas présentes dans la branche au démarrage.
- Le lecteur TV contient un canal natif Flutter nommé `ngombi/player` pour le traitement DASH. Son implémentation doit être examinée avant toute adaptation iOS.
- La configuration Supabase est fournie par `lib/config/ngombi_supabase_config.dart`.

## Première étape : socle de compilation

Le workflow `.github/workflows/ios-simulator.yml` génère le squelette iOS Flutter manquant sur un runner macOS, récupère les dépendances et compile une application pour le simulateur iOS sans signature.

Le squelette généré pendant le workflow n'est pas encore enregistré dans Git. Cette première compilation sert à vérifier la compatibilité de base des plugins et du code Flutter avec iOS.

L'identifiant d'application généré par défaut (`com.ngombi.ngombi`) est provisoire et devra être confirmé avant la signature et la distribution.

## Limites connues à traiter

- HLS : `video_player` s'appuie sur AVPlayer sur iOS ; les flux doivent être testés individuellement.
- MPEG-DASH : ne pas supposer une prise en charge native par AVPlayer. Il faudra choisir et valider une solution iOS dédiée ou un repli compatible, sans modifier le comportement Android.
- WebView et portails : vérifier les restrictions iOS, la lecture automatique, les cookies et les politiques de contenu.
- Radio en arrière-plan : ajouter et tester la configuration audio iOS appropriée avant d'annoncer cette fonction comme disponible.
- Les MethodChannels Android doivent être isolés derrière des contrôles de plateforme et ne jamais être appelés sur iOS.

## Règles de travail

1. Toute modification iOS se fait sur `ios-testflight`.
2. Ne pas fusionner cette branche dans `main` pendant la phase d'expérimentation.
3. Ne pas modifier les lecteurs Android/Windows pour résoudre un problème exclusivement iOS.
4. Vérifier les dépendances et les capacités natives avant de remplacer un lecteur.
5. Une build simulateur non signée ne constitue pas une IPA installable sur un iPhone physique.

## Étapes suivantes

1. Exécuter le workflow de compilation simulateur.
2. Corriger uniquement les erreurs de compatibilité iOS démontrées par les logs.
3. Auditer les MethodChannels et les fonctions audio/vidéo natives.
4. Définir la stratégie HLS, DASH et lecture radio en arrière-plan.
5. Ajouter et versionner les fichiers iOS natifs, puis préparer la signature Apple et TestFlight lorsque le compte développeur sera disponible.
