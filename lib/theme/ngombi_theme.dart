import 'package:flutter/material.dart';
import 'ngombi_colors.dart';

class NgombiTheme {
  NgombiTheme._();
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor:NgombiColors.orange,brightness:Brightness.dark).copyWith(
      primary:NgombiColors.orange,secondary:NgombiColors.gold,surface:NgombiColors.surface,error:NgombiColors.error);
    return ThemeData(
      useMaterial3:true,brightness:Brightness.dark,scaffoldBackgroundColor:NgombiColors.background,colorScheme:scheme,
      cardTheme:CardThemeData(
        color:NgombiColors.card,elevation:0,margin:EdgeInsets.zero,
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:NgombiColors.border))),
      appBarTheme:const AppBarTheme(backgroundColor:NgombiColors.background,foregroundColor:NgombiColors.textPrimary,elevation:0),
      navigationBarTheme:NavigationBarThemeData(
        backgroundColor:NgombiColors.surface,indicatorColor:NgombiColors.orange.withOpacity(.18),
        labelTextStyle:const WidgetStatePropertyAll(TextStyle(fontWeight:FontWeight.w700,fontSize:11))),
      inputDecorationTheme:InputDecorationTheme(
        filled:true,fillColor:NgombiColors.card,
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:NgombiColors.border)),
        enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:NgombiColors.border)),
        focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:NgombiColors.orange,width:1.5))),
      filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(
        backgroundColor:NgombiColors.orange,foregroundColor:Colors.black,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))))
    );
  }
}
