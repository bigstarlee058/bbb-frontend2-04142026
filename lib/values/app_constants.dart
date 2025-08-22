import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiStatus {
  static const int ok = 200;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int serverError = 500;
  static const int serverBusy = 503;
}

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
  // "https://bbb-backend-0df15cf8d1d2.herokuapp.com";

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

const String sessionExpired =
    "Your session has expired. Please log in again to continue.";
const String wrongPassword =
    'Login Failed. Please check your password and, if needed, click "Forgot Password" below.';
const String emailPasswordWrong =
    'Login Failed. Please check your email and password, if needed, click "Forgot Password" below';
const String somethingWentWrong =
    "Something went wrong. Please check your connection and try again.";
const String serverError =
    "Internal server error. Please try again in a moment.";
const String serverBusy = "Server is busy. Please try again in a moment.";
const String unexpectedError =
    "An unexpected error occurred. Please try again.";

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('getUserProfileToken');
  // String? authToken = prefs.getString('authToken');
  return authToken ?? "";
}

Future<String> getUserAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('authToken');
  return authToken ?? "";
}
