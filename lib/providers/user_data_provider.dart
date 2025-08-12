import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  String userId = "";
  String userName = "";
  String userEmail = "";
  bool previousPage = false;
  var userData;

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('authToken') ?? "";
    return authToken;
  }

  var user;

  Future<Map<String, dynamic>> fetchUserInfo(BuildContext context,
      {bool isFromLogin = false}) async {
    final String url = '${AppConstants.serverUrl}/api/users/get_user';

    String token = await getAuthToken();
    final response = await http.get(
      Uri.parse(url),
      headers: {'AUTH_TOKEN': token},
    );

    switch (response.statusCode) {
      case 200:
        final jsonResponse = jsonDecode(response.body);
        getUserDataFromJson(jsonResponse);
        user = jsonResponse;
        notifyListeners();
        return jsonResponse;

      case 401:
        _handleLogout(context,
            "Your session has expired. Please log in again to continue.",
            isFromLogin: isFromLogin);
        throw Exception(
            "Unauthorized - Session expired: ${response.statusCode} :::::::::: ${response.body}");

      case 503:
        _handleLogout(context, "Server is busy. Please try again in a moment.",
            isFromLogin: isFromLogin);
        throw Exception(
            "Service Unavailable: ${response.statusCode} :::::::::: ${response.body}");

      default:
        _handleLogout(
            context, "An unexpected error occurred. Please try again.",
            isFromLogin: isFromLogin);
        throw Exception(
            "Unexpected Error: ${response.statusCode} :::::::::: ${response.body}");
    }
  }

  // Future<Map<String, dynamic>> fetchUserInfo(context) async {
  //   final Dio dio = Dio();
  //   final String url = '${AppConstants.serverUrl}/api/users/get_user';
  //
  //   try {
  //     String token = await getAuthToken();
  //     debugPrint('token====get_user======>>>>>$token');
  //
  //     final response = await dio.get(
  //       url,
  //       options: Options(
  //         headers: {'AUTH_TOKEN': token},
  //       ),
  //     );
  //
  //     debugPrint('response==========>>>>>${response.data}');
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = response.data;
  //       getUserDataFromJson(jsonResponse);
  //       user = jsonResponse;
  //       notifyListeners();
  //       return jsonResponse;
  //     } else {
  //       _handleLogout(context);
  //       throw Exception('Failed to load user data');
  //     }
  //   } on DioException catch (e) {
  //     debugPrint('Dio error: ${e.response?.data ?? e.message}');
  //     throw Exception('Failed to load user data: ${e.message}');
  //   } catch (e) {
  //     debugPrint('General error: $e');
  //     throw Exception('Failed to load user data');
  //   }
  // }

  void _handleLogout(BuildContext context, String msg,
      {bool isFromLogin = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();

    if (!isFromLogin) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
        (Route<dynamic> route) {
          log("ROUTE NAME ${route.settings.name}");
          return route.settings.name == AppRoutes.loginScreen;
        },
      );
    }

    // Navigator.pushNamed(context, AppRoutes.loginScreen);

    showBottomAlert(context, msg);
  }

  void showBottomAlert(BuildContext context, String msg) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: SafeArea(
          top: false,
          bottom: Platform.isAndroid ? true : false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  msg,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove the alert after 3 seconds
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }

  Future<void> addUserInfo(String? id, Map<String, dynamic> userDetails,
      File? imageFile, BuildContext context) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/$id');

    String? userIdToken = await getAuthToken();
    try {
      http.MultipartRequest request = http.MultipartRequest("PUT", url);
      request.fields['detail'] = jsonEncode(userDetails);
      request.fields['detail'] = jsonEncode(userDetails);
      request.fields['firstName'] = userDetails["firstName"];

      if (imageFile != null) {
        final stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: basename(imageFile.path),
        );
        request.files.add(multipartFile);
      } else {
        request.fields['image'] = '';
      }
      request.headers.addAll({
        'AUTH_TOKEN': userIdToken,
        'Accept': 'application/json',
      });
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        log('RESPONSE BODY==========>>>>>$responseBody');
        updateUserData(context);
      } else {
        debugPrint(
            'Failed to update user data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user info: $e');
    }
  }

  Future<void> updateUserInfo(String? id, Map<String, dynamic> userDetails,
      File? imageFile, BuildContext context) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/$id');

    String? userIdToken = await getAuthToken();

    try {
      http.MultipartRequest request = http.MultipartRequest("PUT", url);
      request.fields['detail'] = jsonEncode(userDetails);

      if (imageFile != null) {
        final stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image', // Field name for the image
          stream,
          length,
          filename: basename(imageFile.path),
        );
        request.files.add(multipartFile);
      } else {
        request.fields['image'] = '';
      }
      request.headers.addAll({
        'AUTH_TOKEN': userIdToken,
        'Accept': 'application/json',
      });
      log('url==========>>>>>$url');

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        jsonDecode(responseBody);
        updateUserData(context);
      } else {
        debugPrint(
            'Failed to update user data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user info: $e');
    }
  }

  Future<void> getUserDataFromJson(responseData) async {
    userId = responseData["_id"];
    userName = responseData["name"];
    userEmail = responseData["email"];
    userData = responseData;
    await preferences.putString(
        SharedPreference.role, (responseData["role"] ?? 0).toString());
    notifyListeners();
  }

  updateUserData(BuildContext context) async {
    await fetchUserInfo(context);
    notifyListeners();
  }

  Future<void> loadUserInfo(BuildContext context) async {
    try {
      await fetchUserInfo(context);
    } catch (e) {
      debugPrint("--------------Error loading user info: $e");
    }
  }
}
