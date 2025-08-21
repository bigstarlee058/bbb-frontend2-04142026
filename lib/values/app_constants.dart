import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  AppConstants._();

  static final navigationKey = GlobalKey<NavigatorState>();

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+",
  );

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$#!%*?&_])[A-Za-z\d@#$!%*?&_].{7,}$',
  );

  /// ED'S LOCAL SERVER
  // static const String serverUrl = "http://localhost:5004";

  /// ED'S DEVELOPMENT SERVER
  static const String serverUrl =
      "https://bbbdevelopmentserver-0bb2f4e7627b.herokuapp.com";

  /// PRODUCTION SERVER
  // static const String serverUrl =
  //     "https://bbb-backend-0df15cf8d1d2.herokuapp.com";

  static const String STATE_NOT_STARTED = "not_started";
  static const String STATE_STARTED = "started";
  static const String STATE_SKIPPED = "skipped";
  static const String STATE_FINISHED = "finished";

  ///database table name;
  static const String weeksSplit3 = "WeeksSplit3";
  static const String weeksSplit4 = "WeeksSplit4";
  static const String weeksSplit5 = "WeeksSplit5";
  static const String daysTable = "Days";
  static const String warmupsTable = "Warmups";
  static const String exercisesTable = "Exercises";
  static const String extraTable = "Extra";
}

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('getUserProfileToken');
  return authToken ?? "";
}

Future<String> getUserAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('authToken');
  return authToken ?? "";
}
