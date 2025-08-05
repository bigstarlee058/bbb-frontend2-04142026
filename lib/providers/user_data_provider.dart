import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  String userId = "";
  String userName = "";
  String userEmail = "";
  bool previousPage = false;
  var userData;

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  var user;

  Future<Map<String, dynamic>> fetchUserInfo(context) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/get_user');
    String? token = await getAuthToken();
    log('token====get_user======>>>>>$token');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': token ?? ""
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      getUserDataFromJson(jsonResponse);
      user = jsonResponse;
      notifyListeners();
      return jsonResponse;
    } else {
      _handleLogout(context);
      throw Exception('Failed to load user data');
    }
  }

  void _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onBoardingScreen,
      (Route<dynamic> route) {
        log("ROUTE NAME ${route.settings.name}");
        return route.settings.name == AppRoutes.onBoardingScreen;
      },
    );

    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  Future<void> addUserInfo(
      String? id, Map<String, dynamic> userDetails, File? imageFile) async {
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
        'AUTH_TOKEN': userIdToken!,
        'Accept': 'application/json',
      });
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        log('RESPONSE BODY==========>>>>>$responseBody');
        updateUserData();
      } else {
        debugPrint(
            'Failed to update user data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user info: $e');
    }
  }

  Future<void> updateUserInfo(
      String? id, Map<String, dynamic> userDetails, File? imageFile) async {
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
        'AUTH_TOKEN': userIdToken!,
        'Accept': 'application/json',
      });
      log('url==========>>>>>$url');

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        jsonDecode(responseBody);
        updateUserData();
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

  updateUserData() async {
    await fetchUserInfo(context);
    notifyListeners();
  }

  Future<void> loadUserInfo() async {
    try {
      await fetchUserInfo(context);
    } catch (e) {
      debugPrint("--------------Error loading user info: $e");
    }
  }
}
