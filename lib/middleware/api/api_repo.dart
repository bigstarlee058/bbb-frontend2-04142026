import 'dart:developer';

import 'package:bbb/middleware/api/api_service.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/models/SyncDataResponseModel/day_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_notes_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_set_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/removed_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/swap_exercise_data_model.dart';
import 'package:flutter/material.dart';

class ApiRepo extends BaseService {
  /// ExerciseHistory ========================================================================

  static Future<List<ExerciseHistoryDataModel>> fetchExerciseHistory(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchExerciseHistory}?monthId=$monthId");
    debugPrint('response-fetchExerciseHistory :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExerciseHistoryDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addExerciseHistory({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseHistory, body: body);
    log('response-addExerciseHistory :::::::::::::::::: $response');
    return response;
  }

  static Future<void> updateExerciseHistory({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateExerciseHistory, body: body);
    log('response-updateExerciseHistory :::::::::::::::::: $response');
    return response;
  }

  /// ExerciseStatus ========================================================================

  static Future<List<ExerciseStatusDataModel>> fetchExerciseStatus(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchExerciseStatus}?monthId=$monthId");
    log('response-fetchExerciseStatus :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExerciseStatusDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addExerciseStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseStatus, body: body);
    log('response-addExerciseStatus :::::::::::::::::: $response');
    return response;
  }

  static Future<void> updateExerciseStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateExerciseStatus, body: body);
    log('response-updateExerciseStatus :::::::::::::::::: $response');
    return response;
  }

  /// DayStatus ========================================================================

  static Future<List<DayStatusDataModel>> fetchDayStatus(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchDayStatus}?monthId=$monthId");
    log('response-fetchDayStatus :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => DayStatusDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addDayStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addDayStatus, body: body);
    log('response-addDayStatus :::::::::::::::::: $response');
    return response;
  }

  static Future<void> updateDayStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateDayStatus, body: body);
    log('response-updateDayStatus :::::::::::::::::: $response');
    return response;
  }

  /// ExtraSet ========================================================================

  static Future<List<ExtraSetDataModel>> fetchExtraSet(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchExtraSet}?monthId=$monthId");
    log('response-fetchExtraSet :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExtraSetDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addExtraSet({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExtraSet, body: body);
    log('response-addExtraSet :::::::::::::::::: $response');
    return response;
  }

  /// ExerciseNotes ========================================================================

  static Future<List<ExerciseNotesDataModel>> fetchExerciseNotes() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExerciseNotes);
    log('response-fetchExerciseNotes :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExerciseNotesDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addExerciseNotes({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseNotes, body: body);
    log('response-addExerciseNotes :::::::::::::::::: $response');
    return response;
  }

  /// RemovedExercise ========================================================================

  static Future<List<RemovedExerciseDataModel>> fetchRemovedExercise(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchRemovedExercise}?monthId=$monthId");
    log('response-fetchRemovedExercise :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => RemovedExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addRemovedExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addRemovedExercise, body: body);
    log('response-addRemovedExercise :::::::::::::::::: $response');
    return response;
  }

  static Future<void> deleteRemovedExercise({required String dataId}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: "${BaseService.deleteRemovedExercise}?dataId=$dataId");
    log('response-deleteRemovedExercise :::::::::::::::::: $response');
    return response;
  }

  /// ExtraExercise ========================================================================

  static Future<List<ExtraExerciseDataModel>> fetchExtraExercise(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchExtraExercise}?monthId=$monthId");
    log('response-fetchExtraExercise :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExtraExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addExtraExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExtraExercise, body: body);
    log('response-addExtraExercise :::::::::::::::::: $response');
    return response;
  }

  static Future<void> deleteExtraExercise({required String dataId}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: "${BaseService.deleteExtraExercise}?dataId=$dataId");
    log('response-deleteExtraExercise :::::::::::::::::: $response');
    return response;
  }

  /// SwapExercise ========================================================================

  static Future<List<SwapExerciseDataModel>> fetchSwapExercise(String monthId) async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: "${BaseService.fetchSwapExercise}?monthId=$monthId");
    if (response is List) {
      return response.map((json) => SwapExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  static Future<void> addSwapExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addSwapExercise, body: body);
    log('response-addSwapExercise :::::::::::::::::: $response');
    return response;
  }

  static Future<void> deleteSwapExercise({required String dataId}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: "${BaseService.deleteSwapExercise}?dataId=$dataId");
    log('response-deleteSwapExercise :::::::::::::::::: $response');
    return response;
  }
}
