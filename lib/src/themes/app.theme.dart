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

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(borderColor: Colors.white24),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Color(0xFF1E1E1E),
        filled: true,
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: Colors.white38),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: scrollbarThemeData,
      cardColor: const Color(0xFF1E1E1E),
    );
  }
}
