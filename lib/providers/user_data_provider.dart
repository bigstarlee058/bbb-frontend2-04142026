import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/cupertino.dart';
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

  var user;

  bool _isAutoLoginInProgress = false;
  bool _hasTriedAutoLogin = false;

  Future<Map<String, dynamic>> fetchUserInfo(BuildContext context,
      {bool isFromLogin = false}) async {
    final String url = '${AppConstants.serverUrl}/api/users/get_user';

    // String token = await getAuthToken();
    String token = await getUserAuthToken();
    final response = await http.get(
      Uri.parse(url),
      headers: {'AUTH_TOKEN': token},
    );

    switch (response.statusCode) {
      case 200:
        final jsonResponse = jsonDecode(response.body);
        getUserDataFromJson(jsonResponse);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('getUserProfileToken', jsonResponse["token"]);
        user = jsonResponse;
        notifyListeners();
        return jsonResponse;
      case 401:
        if (!_hasTriedAutoLogin && !_isAutoLoginInProgress) {
          _hasTriedAutoLogin = true;
          _isAutoLoginInProgress = true;
          try {
            await _handleAutoLogin(context, isFromLogin);
          } finally {
            _isAutoLoginInProgress = false;
          }
        } else {
          _handleLogout(context,
              "Your session has expired. Please log in again to continue.",
              isFromLogin: isFromLogin);
        }

        return {"code": response.statusCode};
      case 503:
        _handleLogout(context, "Server is busy. Please try again in a moment.",
            isFromLogin: isFromLogin);
        return {"code": response.statusCode};
      case 500:
        _handleLogout(
            context, "Internal server error. Please try again in a moment.",
            isFromLogin: isFromLogin);
        return {"code": response.statusCode};
      default:
        _handleLogout(
            context, "An unexpected error occurred. Please try again.",
            isFromLogin: isFromLogin);
        return {"code": response.statusCode};
    }
  }

  Future<void> _handleAutoLogin(BuildContext context, bool isFromLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");

    if (email != null && password != null) {
      await signInUser(email, password, context, isFromLogin);
      _hasTriedAutoLogin = true;
      await fetchUserInfo(context, isFromLogin: isFromLogin);
    } else {
      _handleLogout(
          context, "Your session has expired. Please log in again to continue.",
          isFromLogin: isFromLogin);
    }
  }

  Future<void> signInUser(String emailAddress, String password,
      BuildContext context, bool isFromLogin) async {
    try {
      final wooUrl = Uri.parse(
          // 'https://bbbdev1.wpenginepowered.com/wp-json/jwt-auth/v1/token');
          'https://app.bootybybret.com/wp-json/jwt-auth/v1/token');

      final wooResponse = await http.post(
        wooUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': emailAddress, 'password': password},
      );

      if (wooResponse.statusCode == 200) {
        await _handleLoginSuccess(wooResponse);
        return;
      }

      if (wooResponse.statusCode == 403) {
        final wooData = jsonDecode(wooResponse.body);
        String code = wooData['code'].toString();

        if (code.contains("incorrect_password")) {
          _handleLogout(context,
              'Login Failed. Please check your password and, if needed, click "Forgot Password" below',
              isFromLogin: isFromLogin);
          return;
        }
        if (code.contains("invalid_email")) {
          await _tryMobileLogin(emailAddress, password, context, isFromLogin);
          return;
        }
      }

      _handleLogout(
          context, "Your session has expired. Please log in again to continue.",
          isFromLogin: isFromLogin);
    } catch (e) {
      _handleLogout(
          context, "Your session has expired. Please log in again to continue.",
          isFromLogin: isFromLogin);
    }
  }

  Future<void> _tryMobileLogin(String email, String password,
      BuildContext context, bool isFromLogin) async {
    final mobileUrl =
        Uri.parse('${AppConstants.serverUrl}/api/users/signin_mobile');

    final mobileResponse = await http.post(
      mobileUrl,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'email': email, 'password': password},
    );

    if (mobileResponse.statusCode == 200) {
      await _handleLoginSuccess(mobileResponse);
      return;
    }

    if (mobileResponse.statusCode == 403) {
      _handleLogout(
          context, "Your session has expired. Please log in again to continue.",
          isFromLogin: isFromLogin);
      return;
    }

    _handleLogout(
        context, "Your session has expired. Please log in again to continue.",
        isFromLogin: isFromLogin);
  }

  Future<void> _handleLoginSuccess(http.Response response) async {
    final data = jsonDecode(response.body);
    await _saveLoginState(true);

    final token = data['token'] ?? "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
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
    bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();
    await DatabaseHelper().clearAllTables();
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

    await prefs.setBool('hasSeenWelcome', hasSeenWelcome);
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
