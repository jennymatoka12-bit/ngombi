import 'package:flutter/material.dart';
import '../models/tv_channel.dart';
import '../theme/ngombi_colors.dart';

class ChannelLogo extends StatelessWidget {
  final TvChannel channel;
  final double size;
  const ChannelLogo({super.key,required this.channel,this.size=64});
  @override Widget build(BuildContext context) {
    final path=_path(channel.name);
    return Container(width:size,height:size,padding:const EdgeInsets.all(8),
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(size*.18),border:Border.all(color:NgombiColors.border)),
      child:path==null?_fallback():Image.asset(path,fit:BoxFit.contain,errorBuilder:(_,__,___)=>_fallback()));
  }
  Widget _fallback() {
    final letters=channel.name.trim().isEmpty?'TV':channel.name.trim().split(RegExp(r'\s+')).take(2).map((x)=>x[0]).join().toUpperCase();
    return Center(child:Text(letters,style:const TextStyle(color:Colors.black,fontWeight:FontWeight.w900,fontSize:18)));
  }
  String? _path(String name) {
    final n=name.toLowerCase().trim();
    const map={
      'tf1':'assets/logos/tf1.jpeg','m6':'assets/logos/m6.png','bfmtv':'assets/logos/bfmtv.webp','bfm tv':'assets/logos/bfmtv.webp',
      'cnews':'assets/logos/cnews.png','lci':'assets/logos/lci.jpeg','france 24':'assets/logos/france24.jpeg','franceinfo':'assets/logos/franceinfo.png',
      'france info':'assets/logos/franceinfo.png','gabon 24':'assets/logos/gabon24.png','gabon premiere':'assets/logos/gabonpremiere.jpeg','gabon première':'assets/logos/gabonpremière.jpeg',
      'africa 24':'assets/logos/africa24.png','africanews':'assets/logos/africanews.png','crtv':'assets/logos/crtv.png','nci':'assets/logos/nci.png','2stv':'assets/logos/2stv.png',
      'canal 2 international':'assets/logos/canal2international.jpg','arte':'assets/logos/arte.webp','gulli':'assets/logos/gulli.png','tmc':'assets/logos/tmc.jpeg','tfx':'assets/logos/tfx.webp','w9':'assets/logos/w9.jpeg','6ter':'assets/logos/6ter.jpeg',
      'bfm business':'assets/logos/bfmbusiness.jpeg','brut':'assets/logos/brut.png','red bull':'assets/logos/redbull.jpeg','sport en france':'assets/logos/sportenfrance.jpeg','mgg esport':'assets/logos/mggesport.png',
      'ina 70':'assets/logos/ina70.png','ina ardivision':'assets/logos/inaardivision.jpeg','tech&co':'assets/logos/techandco.jpeg','le figaro tv':'assets/logos/lefigarotv.jpeg','le monde en 24 h':'assets/logos/lemonde24h.jpeg',
      'tv5monde info':'assets/logos/tv5mondeinfo.png','rmc story':'assets/logos/rmcstory.jpeg','rmc découverte':'assets/logos/rmcdecouverte.jpeg','rmc decouverte':'assets/logos/rmcdecouverte.jpeg',
      'rmc life':'assets/logos/rmclife.png','rmc mystère':'assets/logos/rmcmystere.jpeg','rmc mystere':'assets/logos/rmcmystere.jpeg','rmc mécanic':'assets/logos/rmcmecanic.jpeg','rmc mecanic':'assets/logos/rmcmecanic.jpeg',
      'rmc wow':'assets/logos/rmcwow.jpeg','rmc talk info':'assets/logos/rmctalkinfo.png','brefcinéma':'assets/logos/brefcinema.jpeg','brefcinema':'assets/logos/brefcinema.jpeg',
      'noovo cinéma':'assets/logos/noovocinema.jpeg','rakuten tv':'assets/logos/rakutentv.png','rakuten tv action':'assets/logos/rakutenaction.jpeg','rakuten tv drame':'assets/logos/rakutendrame.webp',
      'rakuten tv thrillers':'assets/logos/rakutenthrillers.jpeg','rakuten tv top films':'assets/logos/rakutentopfilms.jpeg','rakuten tv comédies':'assets/logos/rakutencomedies.jpeg','rakuten tv comedies':'assets/logos/rakutencomedies.jpeg'
    };
    return map[n];
  }
}
