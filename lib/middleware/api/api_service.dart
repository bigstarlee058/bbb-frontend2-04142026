import 'dart:convert';
import 'dart:developer';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/main.dart';
import 'package:bbb/middleware/api/api_exception.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum APIType { aPost, aGet, aDelete, aPut }

class ApiService extends BaseService {
  Dio dio = Dio();

  Future<dynamic> getResponse(
      {required APIType apiType,
      required String url,
      Map<String, dynamic>? body}) async {
    String mainUrl = AppConstants.serverUrl + url;
    try {
      // return;
      String? userIdToken = await getAuthToken();
      log('userIdToken==========>>>>>$userIdToken');
      log('API===============:::::::::::::::===============>>>>>>>>>>>>>>>$mainUrl');
      Map<String, String> header = {'AUTH_TOKEN': userIdToken ?? ""};
      Response result = await _makeRequest(apiType, mainUrl, header, body);

      return returnResponse(result.statusCode ?? 500, result.data);
    } catch (e) {
      if (e is UnauthorisedException) {
        bool refreshed = await _refreshToken();
        if (refreshed) {
          String? newToken = await getAuthToken();
          Map<String, String> header = {'AUTH_TOKEN': newToken ?? ""};
          Response retryResult =
              await _makeRequest(apiType, mainUrl, header, body);
          return returnResponse(
              retryResult.statusCode ?? 500, retryResult.data);
        } else {
          _handleLogout("Your session has expired. Please log in to continue.",
              isFromLogin: false);
        }
      }
      log('Error => $mainUrl ERROR: $e');
      return null;
    }
  }

  Future<Response> _makeRequest(APIType apiType, String url,
      Map<String, String> header, Map<String, dynamic>? body) {
    switch (apiType) {
      case APIType.aGet:
        return dio.get(url, options: Options(headers: header), data: body);
      case APIType.aPost:
        return dio.post(url, data: body, options: Options(headers: header));
      case APIType.aPut:
        return dio.put(url, data: body, options: Options(headers: header));
      case APIType.aDelete:
        return dio.delete(url, options: Options(headers: header));
    }
  }

  returnResponse(int status, var result) {
    switch (status) {
      case 200:
        return result;
      case 400:
        throw BadRequestException('Bad Request');
      case 401:
        throw UnauthorisedException('Unauthorised user');
      case 404:
        throw ServerException('Page not found');
      case 500:
      default:
        throw FetchDataException('Internal Server Error');
    }
  }

  Future<bool> _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    String? password = prefs.getString("password");
    if (email == null || password == null) {
      _handleLogout("Your session has expired. Please log in to continue.",
          isFromLogin: false);
      return false;
    }
    try {
      await signInUser(email, password, false);
      return true;
    } catch (e) {
      _handleLogout("Your session has expired. Please log in to continue.",
          isFromLogin: false);
      return false;
    }
  }

  Future<void> signInUser(
    String emailAddress,
    String password,
    bool isFromLogin, {
    bool isFromRefresh = false,
  }) async {
    try {
      final wooUrl =
          Uri.parse('https://app.bootybybret.com/wp-json/jwt-auth/v1/token');
      final wooResponse = await http.post(
        wooUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': emailAddress, 'password': password},
      );

      if (wooResponse.statusCode == 200) {
        await _handleLoginSuccess(wooResponse,
            email: emailAddress, password: password);
        return;
      }

      if (wooResponse.statusCode == 403) {
        final wooData = jsonDecode(wooResponse.body);
        String code = wooData['code'].toString();

        if (code.contains("incorrect_password")) {
          _handleLogout(
              'Login Failed. Please check your password and, if needed, click "Forgot Password" below.',
              isFromLogin: isFromLogin);
          return;
        }
        if (code.contains("invalid_email")) {
          await _tryMobileLogin(emailAddress, password, isFromLogin);
          return;
        }
      }

      if (!isFromRefresh) {
        _handleLogout("Your session has expired. Please log in to continue.",
            isFromLogin: isFromLogin);
      }
    } catch (e) {
      if (!isFromRefresh) {
        _handleLogout("Your session has expired. Please log in to continue.",
            isFromLogin: isFromLogin);
      }
    }
  }

  Future<void> _tryMobileLogin(
      String email, String password, bool isFromLogin) async {
    final mobileUrl =
        Uri.parse('${AppConstants.serverUrl}/api/users/signin_mobile');
    final mobileResponse = await http.post(
      mobileUrl,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'email': email, 'password': password},
    );
    if (mobileResponse.statusCode == 200) {
      await _handleLoginSuccess(mobileResponse,
          email: email, password: password);

      return;
    }
    if (mobileResponse.statusCode == 403) {
      _handleLogout("Your session has expired. Please log in to continue.",
          isFromLogin: isFromLogin);
      return;
    }
    _handleLogout("Your session has expired. Please log in to continue.",
        isFromLogin: isFromLogin);
  }

  Future<void> _handleLoginSuccess(http.Response response,
      {String? email, String? password}) async {
    final data = jsonDecode(response.body);
    final token = data['token'] ?? "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);

    if (email != null && password != null) {
      await prefs.setString("email", email);
      await prefs.setString("password", password);
    }
  }

  void _handleLogout(String msg, {bool isFromLogin = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();
    await DatabaseHelper().clearAllTables();
    await preferences.clearPrefs();

    if (!isFromLogin) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
        (Route<dynamic> route) {
          log("ROUTE NAME ${route.settings.name}");
          return route.settings.name == AppRoutes.loginScreen;
        },
      );
    }

    if (navigatorKey.currentState?.context != null) {
      showBottomAlert(navigatorKey.currentState!.context, msg);
    }
  }
}
