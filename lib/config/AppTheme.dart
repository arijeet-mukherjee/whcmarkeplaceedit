import 'package:flutter/material.dart';

import 'AppConfig.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark = ThemeData.dark().copyWith(
    primaryColor: kPrimaryColor,
    indicatorColor: kPrimaryColor,
    buttonColor: kPrimaryColor,
    accentColor: kPrimaryColor,
    primaryColorLight: kPrimaryColor,
    dividerColor: Colors.black54,
    cardColor: ThemeData.dark().scaffoldBackgroundColor,
    buttonTheme: darkButtonTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: ThemeData.dark().scaffoldBackgroundColor,
    backgroundColor: Colors.black45,
    appBarTheme: darkAppBarTheme(),
    textTheme: darkTextTheme(),
  );

  static ThemeData light = ThemeData.light().copyWith(
    primaryColor: kPrimaryColor,
    indicatorColor: kPrimaryColor,
    buttonColor: kPrimaryColor,
    accentColor: kPrimaryColor,
    primaryColorLight: kPrimaryColor,
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade200,
    buttonTheme: lightButtonTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.grey.shade100,
    appBarTheme: lightAppBarTheme(),
    textTheme: lightTextTheme(),
  );
}

ButtonThemeData lightButtonTheme() {
  return ButtonThemeData(buttonColor: kPrimaryColor);
}

ButtonThemeData darkButtonTheme() {
  return ButtonThemeData(buttonColor: kPrimaryColor);
}

AppBarTheme lightAppBarTheme() {
  return AppBarTheme(
    brightness: Brightness.light,
    color: Colors.white,
    elevation: 0.5,
    centerTitle: true,
  );
}

AppBarTheme darkAppBarTheme() {
  return AppBarTheme(
    brightness: Brightness.dark,
    color: ThemeData.dark().scaffoldBackgroundColor,
    elevation: 0.5,
    centerTitle: true,
  );
}

TextTheme lightTextTheme() {
  return ThemeData.light().textTheme.copyWith(
        headline1: TextStyle(color: Colors.black54),
      );
}

TextTheme darkTextTheme() {
  return ThemeData.dark().textTheme.copyWith(
        headline1: TextStyle(color: Colors.white),
      );
}
