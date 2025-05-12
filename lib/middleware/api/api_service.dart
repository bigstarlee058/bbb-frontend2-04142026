import 'dart:developer';

import 'package:bbb/middleware/api/api_exception.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum APIType { aPost, aGet, aDelete, aPut }

class ApiService extends BaseService {
  Dio dio = Dio();

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<dynamic> getResponse({required APIType apiType, required String url, Map<String, dynamic>? body}) async {
    String mainUrl = AppConstants.serverUrl + url;
    try {
      // return;
      String? userIdToken = await getAuthToken();
      Map<String, String> header = {'AUTH_TOKEN': userIdToken ?? ""};

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
      log('Error=>$mainUrl ERROR. $e');
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
