import 'dart:convert';
import 'dart:developer';

import 'package:bbb/middleware/api/api_exception.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum APIType { aPost, aGet, aDelete, aPut }

class ApiService extends BaseService {
  var response;

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  Future<dynamic> getResponse({required APIType apiType, required String url, Map<String, dynamic>? body}) async {
    try {
      String? userIdToken = await getAuthToken();
      Map<String, String> header = {'AUTH_TOKEN': userIdToken ?? ""};
      String mainUrl = AppConstants.serverUrl + url;
      if (apiType == APIType.aGet) {
        var result = await http.get(Uri.parse(mainUrl), headers: header);
        response = returnResponse(result.statusCode, result.body);
      } else if (apiType == APIType.aPost) {
        var result = await http.post(Uri.parse(mainUrl), headers: header, body: body);
        response = returnResponse(result.statusCode, result.body);
      } else if (apiType == APIType.aPut) {
        var result = await http.put(Uri.parse(mainUrl), headers: header, body: body);
        response = returnResponse(result.statusCode, result.body);
      } else if (apiType == APIType.aDelete) {
        var result = await http.delete(Uri.parse(mainUrl), headers: header);
        response = returnResponse(result.statusCode, result.body);
      }
      return response;
    } catch (e) {
      log('Error=>.ERROR. $e');
    }
  }

  returnResponse(int status, var result) {
    switch (status) {
      case 200:
        return jsonDecode(result);
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
