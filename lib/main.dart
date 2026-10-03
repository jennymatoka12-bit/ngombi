import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'models/tv_channel.dart';
import 'theme/ngombi_colors.dart';
import 'theme/ngombi_theme.dart';
import 'widgets/channel_logo.dart';
import 'widgets/ngombi_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) MediaKit.ensureInitialized();
  String bouquet = '';
  try { bouquet = await rootBundle.loadString('assets/tvradiozap.txt'); } catch (_) {}
  final app = await NgombiState.create(parseEnigma2Bouquet(bouquet));
  runApp(NgombiApp(state: app));
}

class RadioChannel {
  final String name, url, category;
  const RadioChannel({required this.name, required this.url, required this.category});
}
const radios = <RadioChannel>[
  RadioChannel(name:'RFI Afrique',url:'https://www.rfi.fr/fr/en-direct-radio',category:'Afrique'),
  RadioChannel(name:'Africa Radio',url:'https://www.africaradio.com/',category:'Afrique'),
  RadioChannel(name:'BBC Afrique',url:'https://www.bbc.com/afrique',category:'Information'),
  RadioChannel(name:'Urban FM',url:'https://www.urbanfm.net/',category:'Musique'),
  RadioChannel(name:'Skyrock',url:'https://skyrock.fm/',category:'Musique'),
  RadioChannel(name:'Trace FM',url:'https://trace.fm/',category:'Musique'),
  RadioChannel(name:'NRJ',url:'https://www.nrj.fr/',category:'Musique'),
  RadioChannel(name:'Nostalgie',url:'https://www.nostalgie.fr/',category:'Musique'),
  RadioChannel(name:'France Info',url:'https://www.franceinfo.fr/en-direct/radio',category:'Information'),
  RadioChannel(name:'RMC',url:'https://rmc.bfmtv.com/',category:'Information'),
  RadioChannel(name:'RTL',url:'https://www.rtl.fr/',category:'Information'),
  RadioChannel(name:'Europe 1',url:'https://www.europe1.fr/',category:'Information'),
];

class NgombiState extends ChangeNotifier {
  final List<TvChannel> channels;
  final SharedPreferences prefs;
  final Set<String> favorites;
  final List<String> history;
  NgombiState._(this.channels,this.prefs,this.favorites,this.history);
  static Future<NgombiState> create(List<TvChannel> c) async {
    final p=await SharedPreferences.getInstance();
    return NgombiState._(c,p,{...p.getStringList('favorites')??const[]},[...p.getStringList('history')??const[]]);
  }
  bool isFav(TvChannel c)=>favorites.contains(c.id);
  List<TvChannel> get favs=>channels.where((c)=>favorites.contains(c.id)).toList();
  List<TvChannel> get recent=>history.map((id){for(final c in channels){if(c.id==id)return c;}return null;}).whereType<TvChannel>().toList();
  Future<void> toggle(TvChannel c) async {
    if(!favorites.add(c.id)) favorites.remove(c.id);
    await prefs.setStringList('favorites',favorites.toList()); notifyListeners();
  }
  Future<void> seen(TvChannel c) async {
    history.remove(c.id); history.insert(0,c.id);
    if(history.length>30)history.removeRange(30,history.length);
    await prefs.setStringList('history',history); notifyListeners();
  }
  Future<void> clearHistory() async { history.clear(); await prefs.remove('history'); notifyListeners(); }
}

class NgombiApp extends StatelessWidget {
  final NgombiState state;
  const NgombiApp({super.key,required this.state});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,title:'NGOMBI',theme:NgombiTheme.dark(),home:Shell(state:state));
}

class Shell extends StatefulWidget {
  final NgombiState state;
  const Shell({super.key,required this.state});
  @override State<Shell> createState()=>_ShellState();
}
class _ShellState extends State<Shell>{
  int index=0;
  void nav(int i)=>setState(()=>index=i);
  @override Widget build(BuildContext context){
    final pages=[
      Home(state:widget.state,nav:nav),TvPage(state:widget.state),const RadioPage(),
      FavoritesPage(state:widget.state),SettingsPage(state:widget.state)
    ];
    return AnimatedBuilder(
      animation:widget.state,
      builder:(_,__)=>LayoutBuilder(builder:(context,c){
        final wide=c.maxWidth>=900;
        return Scaffold(
          body:Row(children:[if(wide)SideBar(index:index,nav:nav),Expanded(child:IndexedStack(index:index,children:pages))]),
          bottomNavigationBar:wide?null:NavigationBar(
            selectedIndex:index.clamp(0,4),onDestinationSelected:nav,
            destinations:const[
              NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Accueil'),
              NavigationDestination(icon:Icon(Icons.tv_outlined),selectedIcon:Icon(Icons.tv),label:'TV'),
              NavigationDestination(icon:Icon(Icons.radio_outlined),selectedIcon:Icon(Icons.radio),label:'Radio'),
              NavigationDestination(icon:Icon(Icons.favorite_border),selectedIcon:Icon(Icons.favorite),label:'Favoris'),
              NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Réglages')
            ]));
      }));
  }
}

class SideBar extends StatelessWidget {
  final int index; final ValueChanged<int> nav;
  const SideBar({super.key,required this.index,required this.nav});
  @override Widget build(BuildContext context)=>Container(
    width:235,decoration:const BoxDecoration(color:NgombiColors.surface,border:Border(right:BorderSide(color:NgombiColors.border))),
    child:SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[
      const Align(alignment:Alignment.centerLeft,child:NgombiLogo.full(height:42)),const SizedBox(height:28),
      _item(0,Icons.home,'Accueil'),_item(1,Icons.tv,'Télévision'),_item(2,Icons.radio,'Radio'),_item(3,Icons.favorite,'Favoris'),
      const Spacer(),_item(4,Icons.settings,'Réglages'),const SizedBox(height:10),
      const Text('NGOMBI • TV & RADIO',style:TextStyle(color:NgombiColors.textMuted,fontSize:11))
    ]))));
  Widget _item(int i,IconData icon,String label)=>Padding(
    padding:const EdgeInsets.only(bottom:5),child:ListTile(
      onTap:()=>nav(i),selected:index==i,selectedTileColor:NgombiColors.orange.withValues(alpha:.14),
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
      leading:Icon(icon,color:index==i?NgombiColors.orange:NgombiColors.textSecondary),
      title:Text(label,style:TextStyle(fontWeight:index==i?FontWeight.w800:FontWeight.w600,color:index==i?Colors.white:NgombiColors.textSecondary))));
}

class Home extends StatelessWidget {
  final NgombiState state;
  final ValueChanged<int> nav;
  const Home({super.key, required this.state, required this.nav});

  Future<void> search(BuildContext context) async {
    final result = await showSearch<Pick?>(
      context: context,
      delegate: Search(state),
    );
    if (!context.mounted || result == null) return;
    if (result.tv != null) {
      state.seen(result.tv!);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlayerPage(state: state, channel: result.tv!),
      ));
    } else if (result.radio != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => WebPage(title: result.radio!.name, url: result.radio!.url),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recent = state.recent.take(8).toList();
    final live = state.channels.take(12).toList();
    final categories = state.channels
        .map((c) => c.category)
        .where((x) => x.isNotEmpty)
        .toSet()
        .take(8)
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour 👋', style: TextStyle(color: NgombiColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('Que voulez-vous regarder ?', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => search(context),
                    icon: const Icon(Icons.search_rounded, size: 28),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: HeroCard()),
          if (recent.isNotEmpty) ...[
            SliverToBoxAdapter(child: TitleRow(title: 'Reprendre', action: 'Historique', tap: () => nav(3))),
            SliverToBoxAdapter(child: CardsRow(state: state, channels: recent)),
          ],
          SliverToBoxAdapter(child: TitleRow(title: 'En direct', action: 'Tout voir', tap: () => nav(1))),
          SliverToBoxAdapter(child: CardsRow(state: state, channels: live)),
          const SliverToBoxAdapter(child: TitleRow(title: 'Explorer', action: null, tap: null)),
          SliverToBoxAdapter(child: Categories(categories)),
          SliverToBoxAdapter(child: TitleRow(title: 'Radios', action: 'Toutes', tap: () => nav(2))),
          SliverToBoxAdapter(child: RadioRow(items: radios)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});
  @override Widget build(BuildContext context)=>Container(
    margin:const EdgeInsets.fromLTRB(20,12,20,6),padding:const EdgeInsets.all(24),constraints:const BoxConstraints(minHeight:205),
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),
      gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color(0xFF2A1408),Color(0xFF14100C),Color(0xFF0D0D0D)]),
      border:Border.all(color:Color(0x33FF8A00))),
    child:Row(children:[
      const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
        NgombiLogo.full(height:40),SizedBox(height:18),Text('Le monde en direct.',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
        SizedBox(height:8),Text('TV, radio et chaînes africaines dans une seule application.',style:TextStyle(color:NgombiColors.textSecondary))])),
      if(MediaQuery.sizeOf(context).width>650)const Icon(Icons.live_tv_rounded,size:92,color:NgombiColors.orange)
    ]));
}

class TitleRow extends StatelessWidget {
  final String title; final String? action; final VoidCallback? tap;
  const TitleRow({super.key,required this.title,required this.action,required this.tap});
  @override Widget build(BuildContext context)=>Padding(
    padding:const EdgeInsets.fromLTRB(20,24,20,12),
    child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800))),
      if(action!=null)TextButton(onPressed:tap,child:Text(action!))]));
}

class CardsRow extends StatelessWidget {
  final NgombiState state; final List<TvChannel> channels;
  const CardsRow({super.key,required this.state,required this.channels});
  @override Widget build(BuildContext context){
    final w=MediaQuery.sizeOf(context).width,cw=w>=1200?220.0:w>=700?190.0:158.0;
    return SizedBox(height:205,child:ListView.separated(
      padding:const EdgeInsets.symmetric(horizontal:20),scrollDirection:Axis.horizontal,itemCount:channels.length,
      separatorBuilder:(_,__)=>const SizedBox(width:12),
      itemBuilder:(_,i)=>ChannelCard(state:state,channel:channels[i],width:cw)));
  }
}

class ChannelCard extends StatelessWidget {
  final NgombiState state; final TvChannel channel; final double width;
  const ChannelCard({super.key,required this.state,required this.channel,required this.width});
  @override Widget build(BuildContext context)=>SizedBox(width:width,child:Card(child:InkWell(
    borderRadius:BorderRadius.circular(18),
    onTap:(){state.seen(channel);Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerPage(state:state,channel:channel)));},
    child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:Stack(children:[Center(child:ChannelLogo(channel:channel,size:width>180?90:74)),
        Positioned(right:0,top:0,child:Icon(state.isFav(channel)?Icons.favorite:Icons.favorite_border,size:18,color:state.isFav(channel)?NgombiColors.orange:NgombiColors.textMuted))])),
      const SizedBox(height:10),Text(channel.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w800)),
      const SizedBox(height:4),Text(channel.category,style:const TextStyle(color:NgombiColors.textSecondary,fontSize:11))
    ])))));
}

class Categories extends StatelessWidget {
  final List<String> items; const Categories(this.items,{super.key});
  @override Widget build(BuildContext context)=>SizedBox(height:92,child:ListView.separated(
    padding:const EdgeInsets.symmetric(horizontal:20),scrollDirection:Axis.horizontal,itemCount:items.length,
    separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i){
      final x=items[i],icon=switch(x){'Sport'=>Icons.sports_soccer,'Cinéma'=>Icons.movie,'Information'=>Icons.newspaper,'Musique'=>Icons.music_note,'Afrique'=>Icons.public,'Jeunesse'=>Icons.child_care,_=>Icons.explore};
      return Container(width:112,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:NgombiColors.card,borderRadius:BorderRadius.circular(16),border:Border.all(color:NgombiColors.border)),
        child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:NgombiColors.orange),const SizedBox(height:7),Text(x,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))]));
    }));
}

class RadioRow extends StatelessWidget {
  final List<RadioChannel> items; const RadioRow({super.key,required this.items});
  @override Widget build(BuildContext context)=>SizedBox(height:118,child:ListView.separated(
    padding:const EdgeInsets.symmetric(horizontal:20),scrollDirection:Axis.horizontal,itemCount:items.length,
    separatorBuilder:(_,__)=>const SizedBox(width:12),
    itemBuilder:(_,i)=>SizedBox(width:180,child:Card(child:ListTile(
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>WebPage(title:items[i].name,url:items[i].url))),
      leading:const CircleAvatar(backgroundColor:NgombiColors.orange,child:Icon(Icons.radio,color:Colors.black)),
      title:Text(items[i].name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w800)))))));
}

class TvPage extends StatefulWidget {
  final NgombiState state; const TvPage({super.key,required this.state});
  @override State<TvPage> createState()=>_TvPageState();
}
class _TvPageState extends State<TvPage>{
  String cat='Toutes',q='';
  @override Widget build(BuildContext context){
    final cats=['Toutes',...widget.state.channels.map((c)=>c.category).toSet()];
    final list=widget.state.channels.where((c)=>(cat=='Toutes'||c.category==cat)&&(q.isEmpty||c.name.toLowerCase().contains(q.toLowerCase()))).toList();
    return SafeArea(child:Column(children:[
      const Padding(padding:EdgeInsets.fromLTRB(20,18,20,10),child:Align(alignment:Alignment.centerLeft,child:Text('Télévision',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:20),child:TextField(onChanged:(v)=>setState(()=>q=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Rechercher une chaîne'))),
      const SizedBox(height:10),
      SizedBox(height:40,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:20),scrollDirection:Axis.horizontal,itemCount:cats.length,
        separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>ChoiceChip(label:Text(cats[i]),selected:cat==cats[i],onSelected:(_)=>setState(()=>cat=cats[i])))),
      Expanded(child:LayoutBuilder(builder:(_,c){
        final n=c.maxWidth>=1400?6:c.maxWidth>=1050?5:c.maxWidth>=750?4:c.maxWidth>=520?3:2;
        return GridView.builder(padding:const EdgeInsets.all(20),gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:n,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:.88),
          itemCount:list.length,itemBuilder:(_,i)=>ChannelCard(state:widget.state,channel:list[i],width:180));
      }))
    ]));
  }
}

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});
  @override State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final list = radios.where((r) => r.name.toLowerCase().contains(q.toLowerCase())).toList();
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Radio', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher une radio'),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => ListTile(
                tileColor: NgombiColors.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const CircleAvatar(
                  backgroundColor: NgombiColors.orange,
                  child: Icon(Icons.radio, color: Colors.black),
                ),
                title: Text(list[i].name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(list[i].category),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WebPage(title: list[i].name, url: list[i].url)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final NgombiState state; const FavoritesPage({super.key,required this.state});
  @override Widget build(BuildContext context)=>SafeArea(child:state.favs.isEmpty
    ?const Empty(icon:Icons.favorite_border,title:'Aucun favori',message:'Ajoutez vos chaînes préférées pour les retrouver ici.')
    :GridView.builder(padding:const EdgeInsets.fromLTRB(20,18,20,20),gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:240,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:.88),itemCount:state.favs.length,itemBuilder:(_,i)=>ChannelCard(state:state,channel:state.favs[i],width:180)));
}

class SettingsPage extends StatelessWidget {
  final NgombiState state; const SettingsPage({super.key,required this.state});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Réglages',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:18),
    Card(child:Column(children:[
      ListTile(leading:const Icon(Icons.history),title:const Text('Historique'),subtitle:Text('${state.recent.length} chaîne(s)'),trailing:const Icon(Icons.delete_outline),
        onTap:()=>showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Effacer l’historique ?'),content:const Text('Les chaînes récentes seront supprimées.'),
          actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Annuler')),FilledButton(onPressed:(){state.clearHistory();Navigator.pop(context);},child:const Text('Effacer'))]))),
      const Divider(height:1),const ListTile(leading:Icon(Icons.palette_outlined),title:Text('Apparence'),subtitle:Text('Thème sombre NGOMBI')),
      const Divider(height:1),const ListTile(leading:Icon(Icons.info_outline),title:Text('NGOMBI'),subtitle:Text('TV & RADIO Direct • version 2.0.0'))
    ])),const SizedBox(height:18),const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('NGOMBI ne contourne aucun DRM et ne garantit pas la disponibilité des flux publiés par des tiers.',style:TextStyle(color:NgombiColors.textSecondary,height:1.45))))
  ]));
}

class Empty extends StatelessWidget {
  final IconData icon;final String title,message;
  const Empty({super.key,required this.icon,required this.title,required this.message});
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Icon(icon,size:58,color:NgombiColors.textMuted),const SizedBox(height:14),Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:7),
    Text(message,textAlign:TextAlign.center,style:const TextStyle(color:NgombiColors.textSecondary))])));
}

class Pick { final TvChannel? tv; final RadioChannel? radio; const Pick.tv(this.tv):radio=null; const Pick.radio(this.radio):tv=null; }
class Search extends SearchDelegate<Pick?> {
  final NgombiState state; Search(this.state):super(searchFieldLabel:'Rechercher TV ou radio');
  @override List<Widget>? buildActions(BuildContext c)=>[if(query.isNotEmpty)IconButton(onPressed:()=>query='',icon:const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext c)=>IconButton(onPressed:()=>close(c,null),icon:const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext c)=>body(c); @override Widget buildSuggestions(BuildContext c)=>body(c);
  Widget body(BuildContext c){
    final q=query.toLowerCase().trim();
    final tv=state.channels.where((x)=>q.isEmpty||x.name.toLowerCase().contains(q)||x.category.toLowerCase().contains(q)).take(30).toList();
    final r=radios.where((x)=>q.isEmpty||x.name.toLowerCase().contains(q)||x.category.toLowerCase().contains(q)).toList();
    return ListView(children:[
      if(tv.isNotEmpty)const ListTile(title:Text('Télévision',style:TextStyle(fontWeight:FontWeight.w800))),
      ...tv.map((x)=>ListTile(leading:ChannelLogo(channel:x,size:46),title:Text(x.name),subtitle:Text(x.category),onTap:()=>close(c,Pick.tv(x)))),
      if(r.isNotEmpty)const ListTile(title:Text('Radio',style:TextStyle(fontWeight:FontWeight.w800))),
      ...r.map((x)=>ListTile(leading:const CircleAvatar(backgroundColor:NgombiColors.orange,child:Icon(Icons.radio,color:Colors.black)),title:Text(x.name),subtitle:Text(x.category),onTap:()=>close(c,Pick.radio(x))))
    ]);
  }
}

class PlayerPage extends StatefulWidget {
  final NgombiState state; final TvChannel channel;
  const PlayerPage({super.key,required this.state,required this.channel});
  @override State<PlayerPage> createState()=>_PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage>{
  Player? player;VideoController? video;StreamSubscription<String>? errorSub;String? error;bool loading=true;bool opened=false;
  @override void initState(){super.initState();start();}
  Future<void> start()async{
    final official=officialUrl(widget.channel.name);
    if(official!=null){if(mounted)setState(()=>loading=false);return;}
    try{
      final p=Player();player=p;video=VideoController(p);
      errorSub=p.stream.error.listen((m){if(mounted&&m.isNotEmpty)setState((){loading=false;error=m;});});
      await p.open(Media(widget.channel.url,httpHeaders:widget.channel.headers),play:true).timeout(const Duration(seconds:25));
      if(!mounted){await p.dispose();return;}setState((){loading=false;opened=true;error=null;});
    }catch(e){if(mounted)setState((){loading=false;error='Impossible de lire ce flux.\n\n$e';});}
  }
  Future<void> retry()async{await disposePlayer();if(mounted)setState((){loading=true;error=null;opened=false;});await start();}
  Future<void> disposePlayer()async{await errorSub?.cancel();errorSub=null;final p=player;player=null;video=null;await p?.dispose();}
  @override void dispose(){unawaited(disposePlayer());super.dispose();}
  @override Widget build(BuildContext context){
    final official=officialUrl(widget.channel.name);
    if(official!=null)return WebPage(title:widget.channel.name,url:official,favoriteState:widget.state,channel:widget.channel);
    return Scaffold(backgroundColor:Colors.black,appBar:AppBar(title:Text(widget.channel.name),backgroundColor:Colors.black,actions:[
      IconButton(onPressed:()=>widget.state.toggle(widget.channel),icon:Icon(widget.state.isFav(widget.channel)?Icons.favorite:Icons.favorite_border,color:widget.state.isFav(widget.channel)?NgombiColors.orange:null))]),
      body:Column(children:[
        Expanded(child:loading?const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[CircularProgressIndicator(color:NgombiColors.orange),SizedBox(height:14),Text('Connexion au flux…',style:TextStyle(color:Colors.white70))]))
          :error!=null?ErrorPanel(message:error!,retry:retry):video!=null?Video(controller:video!,fit:BoxFit.contain):const SizedBox.shrink()),
        if(opened)Container(color:NgombiColors.surface,padding:const EdgeInsets.all(14),child:Row(children:[
          ChannelLogo(channel:widget.channel,size:44),const SizedBox(width:12),Expanded(child:Text(widget.channel.name,style:const TextStyle(fontWeight:FontWeight.w800))),
          Text(widget.channel.category,style:const TextStyle(color:NgombiColors.textSecondary))]))
      ]));
  }
}
class ErrorPanel extends StatelessWidget{
  final String message;final VoidCallback retry;const ErrorPanel({super.key,required this.message,required this.retry});
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.error_outline,size:58,color:NgombiColors.error),const SizedBox(height:16),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70)),
    const SizedBox(height:20),FilledButton.icon(onPressed:retry,icon:const Icon(Icons.refresh),label:const Text('Réessayer'))])));
}
String? officialUrl(String name){
  final n=name.toLowerCase();
  if(n=='tf1'||n.startsWith('tf1 '))return'https://www.tf1.fr/tf1/direct';
  if(n.contains('gabon 24'))return'https://gabon24.tv/direct';
  if(n.contains('gabon premiere')||n.contains('gabon première'))return'https://www.gabonpremiere.ga/';
  return null;
}
class WebPage extends StatefulWidget{
  final String title,url;final NgombiState? favoriteState;final TvChannel? channel;
  const WebPage({super.key,required this.title,required this.url,this.favoriteState,this.channel});
  @override State<WebPage> createState()=>_WebPageState();
}
class _WebPageState extends State<WebPage>{
  WebViewController? controller;bool external=false;
  @override
  void initState() {
    super.initState();
    final mobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (mobile) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (_) {
              if (mounted) setState(() => external = true);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } else {
      external = true;
    }
  }
  Future<void>open()async{final ok=await launchUrl(Uri.parse(widget.url),mode:LaunchMode.externalApplication);if(!ok&&mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible d’ouvrir le lecteur officiel.')));}
  @override
  Widget build(BuildContext context) {
    final body = external
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.open_in_browser, size: 64, color: NgombiColors.orange),
                  const SizedBox(height: 16),
                  Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text(
                    'Le lecteur officiel sera ouvert dans votre navigateur sur cette plateforme.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: NgombiColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: open,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ouvrir le lecteur'),
                  ),
                ],
              ),
            ),
          )
        : WebViewWidget(controller: controller!);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.favoriteState != null && widget.channel != null)
            IconButton(
              onPressed: () => widget.favoriteState!.toggle(widget.channel!),
              icon: Icon(widget.favoriteState!.isFav(widget.channel!) ? Icons.favorite : Icons.favorite_border),
            ),
        ],
      ),
      body: body,
    );
  }
}
