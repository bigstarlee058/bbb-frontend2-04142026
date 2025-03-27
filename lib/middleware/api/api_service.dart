// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:bbb/middleware/api/api_exception.dart';
// import 'package:bbb/middleware/api/base_service.dart';
// import 'package:bbb/values/app_constants.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// enum APIType { aPost, aGet, aDelete, aPut }
//
// class ApiService extends BaseService {
//   var response;
//
//   Future<String?> getAuthToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authToken = prefs.getString('authToken');
//     return authToken;
//   }
//
//   Future<dynamic> getResponse({required APIType apiType, required String url, Map<String, dynamic>? body}) async {
//     try {
//       String? userIdToken = await getAuthToken();
//       Map<String, String> header = {'AUTH_TOKEN': userIdToken ?? ""};
//       log('header :::::::::::::::::: $header');
//       String mainUrl = AppConstants.serverUrl + url;
//       if (apiType == APIType.aGet) {
//         var result = await http.get(
//           Uri.parse(mainUrl),
//           headers: header,
//         );
//         response = returnResponse(result.statusCode, result.body);
//       } else if (apiType == APIType.aPost) {
//         var result = await http.post(Uri.parse(mainUrl), headers: header, body: body);
//         response = returnResponse(result.statusCode, result.body);
//       } else if (apiType == APIType.aPut) {
//         var result = await http.put(Uri.parse(mainUrl), headers: header, body: body);
//         response = returnResponse(result.statusCode, result.body);
//       } else if (apiType == APIType.aDelete) {
//         var result = await http.delete(Uri.parse(mainUrl), headers: header);
//         response = returnResponse(result.statusCode, result.body);
//       }
//       return response;
//     } catch (e) {
//       log('Error=>.ERROR. $e');
//     }
//   }
//
//   returnResponse(int status, var result) {
//     switch (status) {
//       case 200:
//         return jsonDecode(result);
//       case 400:
//         throw BadRequestException('Bad Request');
//       case 401:
//         throw UnauthorisedException('Unauthorised user');
//       case 404:
//         throw ServerException('Page not found');
//       case 500:
//       default:
//         throw FetchDataException('Internal Server Error');
//     }
//   }
// }

import 'dart:developer';

import 'package:bbb/middleware/api/api_exception.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum APIType { aPost, aGet, aDelete, aPut }

class ApiService extends BaseService {
  var response;
  Dio dio = Dio();

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<dynamic> getResponse({required APIType apiType, required String url, Map<String, dynamic>? body}) async {
    try {
      String? userIdToken = await getAuthToken();
      Map<String, String> header = {'AUTH_TOKEN': userIdToken ?? ""};
      log('header :::::::::::::::::: $header');

      String mainUrl = AppConstants.serverUrl + url;

      Response result;

      switch (apiType) {
        case APIType.aGet:
          result = await dio.get(mainUrl, options: Options(headers: header), data: body);
          break;
        case APIType.aPost:
          result = await dio.post(mainUrl, data: body, options: Options(headers: header));
          break;
        case APIType.aPut:
          result = await dio.put(mainUrl, data: body, options: Options(headers: header));
          break;
        case APIType.aDelete:
          result = await dio.delete(mainUrl, options: Options(headers: header));
          break;
      }

      return returnResponse(result.statusCode ?? 500, result.data);
    } catch (e) {
      log('Error=>.ERROR. $e');
      return null;
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
}
