import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Color(0xff9A354E),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  cardColor: AppColors.greyColor,
  canvasColor: Colors.white,
  dividerColor: Colors.black12,
  hoverColor: Colors.transparent,
  // colorScheme: ColorScheme.light(
  //   brightness: Brightness.light,
  //   surface: Color(0xff9A354E),
  // ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xff9A354E),
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Color(0xff9A354E),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  cardColor: Colors.grey[900],
  canvasColor: Colors.grey[800],
  dividerColor: Colors.grey.shade900,
  hoverColor: Colors.transparent,
  // colorScheme: ColorScheme.dark(
  //   brightness: Brightness.dark,
  //   surface: Color(0xff9A354E),
  // ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xff9A354E),
    brightness: Brightness.dark,
  ),
);
