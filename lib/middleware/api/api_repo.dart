import 'dart:developer';

import 'package:bbb/middleware/api/api_service.dart';
import 'package:bbb/middleware/api/base_service.dart';
import 'package:bbb/models/SyncDataResponseModel/day_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_notes_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_set_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/removed_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/swap_exercise_data_model.dart';

class ApiRepo extends BaseService {
  /// ExerciseHistory ========================================================================

  Future<void> fetchExerciseHistory() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExerciseHistory);
    log('response-fetchExerciseHistory :::::::::::::::::: $response');
    return response;
  }

  Future<void> addExerciseHistory({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseHistory, body: body);
    log('response-addExerciseHistory :::::::::::::::::: $response');
    return response;
  }

  Future<void> updateExerciseHistory({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateExerciseHistory, body: body);
    log('response-updateExerciseHistory :::::::::::::::::: $response');
    return response;
  }

  /// ExerciseStatus ========================================================================

  Future<List<ExerciseStatusDataModel>> fetchExerciseStatus() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExerciseStatus);
    log('response-fetchExerciseStatus :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExerciseStatusDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addExerciseStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseStatus, body: body);
    log('response-addExerciseStatus :::::::::::::::::: $response');
    return response;
  }

  Future<void> updateExerciseStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateExerciseStatus, body: body);
    log('response-updateExerciseStatus :::::::::::::::::: $response');
    return response;
  }

  /// DayStatus ========================================================================

  Future<List<DayStatusDataModel>> fetchDayStatus() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchDayStatus);
    log('response-fetchDayStatus :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => DayStatusDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addDayStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addDayStatus, body: body);
    log('response-addDayStatus :::::::::::::::::: $response');
    return response;
  }

  Future<void> updateDayStatus({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPut, url: BaseService.updateDayStatus, body: body);
    log('response-updateDayStatus :::::::::::::::::: $response');
    return response;
  }

  /// ExtraSet ========================================================================

  Future<List<ExtraSetDataModel>> fetchExtraSet() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExtraSet);
    log('response-fetchExtraSet :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExtraSetDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addExtraSet({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExtraSet, body: body);
    log('response-addExtraSet :::::::::::::::::: $response');
    return response;
  }

  /// ExerciseNotes ========================================================================

  Future<List<ExerciseNotesDataModel>> fetchExerciseNotes() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExerciseNotes);
    log('response-fetchExerciseNotes :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExerciseNotesDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addExerciseNotes({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExerciseNotes, body: body);
    log('response-addExerciseNotes :::::::::::::::::: $response');
    return response;
  }

  /// RemovedExercise ========================================================================

  Future<List<RemovedExerciseDataModel>> fetchRemovedExercise() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchRemovedExercise);
    log('response-fetchRemovedExercise :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => RemovedExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addRemovedExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addRemovedExercise, body: body);
    log('response-addRemovedExercise :::::::::::::::::: $response');
    return response;
  }

  Future<void> deleteRemovedExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: BaseService.deleteRemovedExercise, body: body);
    log('response-deleteRemovedExercise :::::::::::::::::: $response');
    return response;
  }

  /// ExtraExercise ========================================================================

  Future<List<ExtraExerciseDataModel>> fetchExtraExercise() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchExtraExercise);
    log('response-fetchExtraExercise :::::::::::::::::: $response');
    if (response is List) {
      return response.map((json) => ExtraExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addExtraExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addExtraExercise, body: body);
    log('response-addExtraExercise :::::::::::::::::: $response');
    return response;
  }

  Future<void> deleteExtraExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: BaseService.deleteExtraExercise, body: body);
    log('response-deleteExtraExercise :::::::::::::::::: $response');
    return response;
  }

  /// SwapExercise ========================================================================

  Future<List<SwapExerciseDataModel>> fetchSwapExercise() async {
    var response = await ApiService().getResponse(apiType: APIType.aGet, url: BaseService.fetchSwapExercise);
    if (response is List) {
      return response.map((json) => SwapExerciseDataModel.fromJson(json)).toList();
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }

  Future<void> addSwapExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aPost, url: BaseService.addSwapExercise, body: body);
    log('response-addSwapExercise :::::::::::::::::: $response');
    return response;
  }

  Future<void> deleteSwapExercise({required Map<String, dynamic> body}) async {
    var response = await ApiService().getResponse(apiType: APIType.aDelete, url: BaseService.deleteSwapExercise, body: body);
    log('response-deleteSwapExercise :::::::::::::::::: $response');
    return response;
  }
}
