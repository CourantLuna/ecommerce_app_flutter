import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/src/themes/button_theme.dart';
import 'package:ecommerce_app/src/themes/checkbox_themedata.dart';
import 'package:ecommerce_app/src/themes/input_decoration_theme.dart';
import 'package:ecommerce_app/src/themes/theme_data.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: IconThemeData(color: blackColor),
      textTheme: TextTheme(bodyMedium: TextStyle(color: blackColor40)),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme, 
      scrollbarTheme: scrollbarThemeData,
      
    );
  }
}
