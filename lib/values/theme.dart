import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Color(0xff9A354E),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  cardColor: AppColors.greyColor,
  canvasColor: Colors.white,
  disabledColor: Color(0xFFF3F3F3),
  dividerColor: Colors.black12,
  hoverColor: Colors.transparent,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xff9A354E),
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Color(0xBB888888)),
    bodySmall: TextStyle(color: AppColors.appGreyColor),
    displayLarge: TextStyle(color: AppColors.greyColor1),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: Colors.black,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Color(0xff9A354E),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  disabledColor: Colors.grey[800],
  cardColor: Colors.grey[900],
  canvasColor: Colors.grey[800],
  dividerColor: Colors.grey.shade900,
  hoverColor: Colors.transparent,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xff9A354E),
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.grey.shade400),
    bodySmall: TextStyle(color: Colors.grey.shade300),
    displayLarge: TextStyle(color: Colors.grey[800]),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: Colors.white,
    ),
  ),
);
