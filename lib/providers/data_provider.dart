import 'dart:convert';
import 'dart:developer';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/month_response_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/SyncDataResponseModel/avhievements_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/day_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_notes_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_set_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/month_enrollment_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/removed_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/streak_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/swap_exercise_data_model.dart';
import 'package:bbb/models/bonuses.dart';
import 'package:bbb/models/category.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/models/equipmenttitle.dart';
import 'package:bbb/models/exerciselibrary.dart';
import 'package:bbb/models/staffs.dart';
import 'package:bbb/models/tutorials.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise_model.dart';

class DataProvider extends ChangeNotifier {
  List<ExerciseLibrary> adminExercises = [];
  List<CategoryTitle> adminCategory = [];
  List<EquipmentTitle> adminEquipment = [];
  List<Equipment> adminEquipmentsData = [];
  List<Bonuses> adminBonusesData = [];
  MonthProvider? monthProvider;

  List<Staffs> staffsData = [];
  List<dynamic> selectWeekBasedOnSplit = [];
  List<Staffs> athletesData = [];
  List<Collections> collectionsData = [];
  String equipmentCheckpoint = '';
  String bonusCheckpoint = '';
  String workoutCheckpoint = '';
  bool equipmentCheckpointState = false;
  bool bonusCheckpointState = false;
  bool workoutCheckpointState = false;

  Collections collectionData = Collections(id: "", title: "", description: "", photo: "", equipments: []);
  Exercise currentExerciseObj = Exercise(
      id: "",
      title: "",
      vimeoId: "",
      thumbnail: "",
      description: "",
      guide: "",
      relatedExercises: [],
      categories: [],
      usedEquipments: [],
      files: []);
  late List<Exercise> currentRelatedExercises = [];

  Challenges featureChallengeData = Challenges(id: '', title: '', description: '', photo: '');
  Tutorials tutorialData = Tutorials(id: "", title: "", description: "", photo: "", files: []);

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  Future<bool> joinChallenge(String? userid, String? challengeid) async {
    final challengeDetail = {
      '_id': challengeid,
      'joinedUserId': userid,
    };
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/challenges');
    String? userIdToken = await getAuthToken();
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
        body: jsonEncode(challengeDetail));
    if (response.statusCode == 200) {
      log('User data updated successfully');
      return true;
    } else {
      throw Exception('Failed to update user data: ${response.body}');
    }
  }

  List<Staffs> get staffs => staffsData;
  List<Staffs> get athletes => athletesData;

  Future<void> fetchStaffs() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/staffs/admin/get');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['staffs'] is List) {
          // Map the 'staffs' list to Staff objects
          staffsData = (data['staffs'] as List).where((item) => item['type'] == 1).map((item) => Staffs.fromJson(item)).toList();
          athletesData = (data['staffs'] as List).where((item) => item['type'] == 2).map((item) => Staffs.fromJson(item)).toList();
          notifyListeners(); // Notify listeners to update the UI
        }
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Challenges get featureChallenge => featureChallengeData;

  Future<void> fetchFeaturedChalleng() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/challenges/get-featured');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          featureChallengeData = Challenges.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  List<Collections> get collections => collectionsData;

  Future<void> fetchFeaturedColllections() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/collections/get-featured');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['collections'] is List) {
          // Map the 'staffs' list to Staff objects
          collectionsData = (data['collections'] as List).map((item) => Collections.fromJson(item)).toList();
          notifyListeners(); // Notify listeners to update the UI
        }
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Collections get oneCollection => collectionData;

  Future<void> fetchOneCollection(String collectionId) async {
    collectionData = Collections(id: "", title: "", description: "", photo: "", equipments: []);
    notifyListeners();
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/collections/get/$collectionId');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        collectionData = Collections.fromJson(data);
        notifyListeners(); // Notify listeners to update the UI
      } else {
        collectionData = Collections(id: "", title: "", description: "", photo: "", equipments: []);
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future<void> fetchAdminData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get');
    String? userIdToken = await getAuthToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('exercises') && responseData.containsKey('categories') && responseData.containsKey('equipments')) {
        List<dynamic> exercisesData = responseData['exercises'];
        List<ExerciseLibrary> exerciseList = exercisesData.map((exerciseJson) {
          return ExerciseLibrary.fromJson(exerciseJson);
        }).toList();
        List<dynamic> categoriesData = responseData['categories'];
        List<CategoryTitle> categoryList = categoriesData.map((categoryJson) {
          return CategoryTitle.fromJson(categoryJson);
        }).toList();

        List<dynamic> equipmentsData = responseData['equipments'];
        List<EquipmentTitle> equipmentList = equipmentsData.map((equipmentJson) {
          return EquipmentTitle.fromJson(equipmentJson);
        }).toList();

        adminExercises = exerciseList;
        adminCategory = categoryList;
        adminEquipment = equipmentList;

        notifyListeners();
      } else {
        throw Exception('Missing data in response (exercises, categories, or equipments)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future<void> fetchAdminEquipmentsData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/equipments/admin/get');
    String? userIdToken = await getAuthToken();
    log('userIdToken :::::::::::::::::: ${userIdToken}');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('equipments')) {
        List<dynamic> equipmentsData = responseData['equipments'];
        List<Equipment> equipmentList = equipmentsData.map((equipmentJson) {
          return Equipment.fromJson(equipmentJson);
        }).toList();

        adminEquipmentsData = equipmentList;

        notifyListeners();
      } else {
        throw Exception('Missing data in response (equipments)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future<void> fetchAdminBonusesData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/bonuses/admin/get');
    String? userIdToken = await getAuthToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('bonuses')) {
        List<dynamic> bonusesData = responseData['bonuses'];
        List<Bonuses> bonusesList = bonusesData.map((bonusJson) {
          return Bonuses.fromJson(bonusJson);
        }).toList();

        adminBonusesData = bonusesList;

        notifyListeners();
      } else {
        throw Exception('Missing data in response (bonuses)');
      }
    } else {
      throw Exception('Failed to load admin data');
    }
  }

  Future fetchMonthWorkouts(int month) async {
    final Map<String, String> queryParams = {
      'month': month.toString(),
      'equipment': '0',
      'split': '5',
      'date': "${DateTime.now().toUtc()}"
    };
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/workouts/current');
    String? userIdToken = await getAuthToken();
    final response = await http.post(
      url,
      body: queryParams,
      headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded', 'AUTH_TOKEN': userIdToken ?? ""},
    );
    if (response.statusCode == 200) {
      await getMonthInfoFromJson(responseData: jsonDecode(response.body));
      notifyListeners();
    } else {
      await getMonthInfoFromJson();
    }
  }

  Future<void> getMonthInfoFromJson({Map<String, dynamic>? responseData}) async {
    try {
      if (responseData != null) {
        MonthDataModel monthDataModelSplit3 = MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit4 = MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit5 = MonthDataModel.fromJson(responseData);
        await monthProvider?.fetchMonthLocalData();

        List split3 = ["Day 1 Workout", "Rest Day 1", "Day 2 Workout", "Rest Day 2", "Day 3 Workout", "Rest Day 3", "Rest Day 4"];

        List split4 = ["Day 1 Workout", "Day 2 Workout", "Rest Day 1", "Day 3 Workout", "Day 4 Workout", "Rest Day 2", "Rest Day 3"];

        List split5 = ["Day 1 Workout", "Day 2 Workout", "Day 3 Workout", "Day 4 Workout", "Day 5 Workout", "Rest Day 1", "Rest Day 2"];

        await preferences.putString(SharedPreference.monthId, "${monthDataModelSplit3.id}");
        monthDataModelSplit3.weeks?.forEach(
          (element) {
            element.dayList = split3;
            element.idList = [
              "${element.id} split3 Day 1 Workout",
              "${element.id} split3 Rest Day 1",
              "${element.id} split3 Day 2 Workout",
              "${element.id} split3 Rest Day 2",
              "${element.id} split3 Day 3 Workout",
              "${element.id} split3 Rest Day 3",
              "${element.id} split3 Rest Day 4",
            ];
            element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3", "Rest Day 4"];
            element.days?.removeWhere((element) => !element.formats!.contains("3"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split3[i];
            }
          },
        );

        await preferences.putString("${SplitType.split3}-${monthDataModelSplit3.id}", jsonEncode(monthDataModelSplit3));
        monthDataModelSplit4.weeks?.forEach(
          (element) {
            element.dayList = split4;
            element.idList = [
              "${element.id} split4 Day 1 Workout",
              "${element.id} split4 Day 2 Workout",
              "${element.id} split4 Rest Day 1",
              "${element.id} split4 Day 3 Workout",
              "${element.id} split4 Day 4 Workout",
              "${element.id} split4 Rest Day 2",
              "${element.id} split4 Rest Day 3",
            ];
            element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3"];
            element.days?.removeWhere((element) => !element.formats!.contains("4"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split4[i];
            }
          },
        );
        await preferences.putString("${SplitType.split4}-${monthDataModelSplit4.id}", jsonEncode(monthDataModelSplit4));
        monthDataModelSplit5.weeks?.forEach(
          (element) {
            element.dayList = split5;
            element.idList = [
              "${element.id} split5 Day 1 Workout",
              "${element.id} split5 Day 2 Workout",
              "${element.id} split5 Day 3 Workout",
              "${element.id} split5 Day 4 Workout",
              "${element.id} split5 Day 5 Workout",
              "${element.id} split5 Rest Day 1",
              "${element.id} split5 Rest Day 2",
            ];
            element.restDayList = ["Rest Day 1", "Rest Day 2"];
            element.days?.removeWhere((element) => !element.formats!.contains("5"));
            for (var i = 0; i < element.days!.length; i++) {
              element.days?[i].dayType = split5[i];
            }
          },
        );
        await preferences.putString("${SplitType.split5}-${monthDataModelSplit5.id}", jsonEncode(monthDataModelSplit5));
        final dataList = [];
        for (var element in monthDataModelSplit3.weeks ?? []) {
          final data = await monthProvider?.fetchRestDay(element.restdayId ?? "");
          dataList.add(data);
          await preferences.putString("REST-${monthDataModelSplit3.id}", jsonEncode(dataList));
        }
        final value = await DatabaseHelper().areAllTablesEmpty();
        if (value) {
          List<MonthEnrollmentDataModel> monthEnrollment = await ApiRepo.fetchMonthEnrollment();

          if (monthEnrollment.isNotEmpty) {
            for (var element in monthEnrollment) {
              final body = {
                "monthId": element.id ?? "",
                "monthStartDate": element.startDate.toString(),
                "monthEndDate": element.endDate.toString(),
              };
              await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.monthHistory);
            }
          } else {
            MonthResponseModel? matchingElement = monthProvider?.monthLocalDataModel
                .firstWhere((element) => element.monthId == monthDataModelSplit3.id, orElse: () => MonthResponseModel());

            final data = {
              "monthId": monthDataModelSplit3.id,
              "monthStartDate": monthDataModelSplit3.startDate.toString(),
              "monthEndDate": monthDataModelSplit3.endDate.toString()
            };

            if (matchingElement?.id == null) {
              await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.monthHistory);
            }
          }
          List<AchievementsDataModel> achievementsData = await ApiRepo.fetchAchievementsList();
          if (achievementsData.isNotEmpty) {
            for (var element in achievementsData) {
              final body = {
                "achievementsTitle": element.achievementsTitle ?? "",
                "achievementsSubtitle": element.achievementsSubtitle ?? "",
                "achievementsDate": element.achievementsDate.toString(),
              };
              await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.achievementHistory);
            }
          }
          StreakDataModel? streakDataModel = await ApiRepo.fetchStreakCount();
          await preferences.putInt(SharedPreference.lastStreakCount, int.parse((streakDataModel?.count ?? "0")));

          List<DayStatusDataModel> dayStatus = await ApiRepo.fetchDayStatus(monthDataModelSplit3.id ?? "");

          if (dayStatus.isNotEmpty) {
            for (var element in dayStatus) {
              final body = {
                "title": element.title ?? "",
                "dataId": element.dataId ?? " ",
                "monthId": element.monthId ?? "",
                "weekId": element.weekId ?? "",
                "dayId": element.dayId ?? "",
                "split": element.split ?? "",
                "date": element.date ?? "",
                "status": element.status ?? "",
                "type": element.type ?? "",
                "startTime": element.startTime ?? "",
                "endTime": element.endTime ?? "",
                "completedExercise": element.completedExerciseCount ?? "",
                "totalWeight": element.totalWeight ?? "",
                "averageRIR": element.averageRIR ?? "",
              };
              await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.dayStatus);
            }

            List<ExerciseHistoryDataModel> exerciseHistroy = await ApiRepo.fetchExerciseHistory(monthDataModelSplit3.id ?? "");
            if (exerciseHistroy.isNotEmpty) {
              for (var element in exerciseHistroy) {
                final body = {
                  "split": element.split ?? "",
                  "dataId": element.dataId ?? "",
                  "exerciseId": element.exerciseId ?? "",
                  "extraId": element.extraId ?? "",
                  "monthId": element.monthId ?? "",
                  "weekId": element.weekId ?? "",
                  "dayId": element.dayId ?? "",
                  "sets": element.sets?.toString() ?? "",
                  "reps": element.reps?.toString() ?? "",
                  "weight": element.weight?.toString() ?? "",
                  "rest": element.rest?.toString() ?? "",
                  "load": element.load?.toString() ?? "",
                  "type": element.type ?? "",
                  "effort": element.effort?.toString() ?? "",
                  "date": element.date?.toString() ?? "",
                  "index": int.parse(element.index ?? "0"),
                  "subIndex": int.parse(element.subIndex ?? ""),
                  "status": element.status ?? "",
                  "totalSet": element.totalSet?.toString() ?? "",
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseHistory);
              }
            }
            List<ExerciseStatusDataModel> exerciseStatus = await ApiRepo.fetchExerciseStatus(monthDataModelSplit3.id ?? "");
            if (exerciseStatus.isNotEmpty) {
              for (var element in exerciseStatus) {
                final body = {
                  "dataId": element.dataId ?? "",
                  "exerciseId": element.exerciseId ?? "",
                  "monthId": element.monthId ?? "",
                  "weekId": element.weekId ?? "",
                  "dayId": element.dayId ?? "",
                  "split": element.split ?? "",
                  "date": element.date ?? "",
                  "status": element.status ?? "",
                  "type": element.type ?? "",
                  "totalWeight": element.totalWeight ?? "",
                  "totalSet": element.totalSet ?? "",
                  "totalRIR": element.totalRIR ?? "",
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseStatus);
              }
            }
            List<ExerciseNotesDataModel> exerciseNotes = await ApiRepo.fetchExerciseNotes();
            if (exerciseNotes.isNotEmpty) {
              for (var element in exerciseNotes) {
                final body = {
                  "exerciseId": element.exerciseId ?? "",
                  "date": element.date ?? "",
                  "note": element.note ?? "",
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.exerciseNotes);
              }
            }
            List<ExtraSetDataModel> extraSet = await ApiRepo.fetchExtraSet(monthDataModelSplit3.id ?? "");
            if (extraSet.isNotEmpty) {
              for (var element in extraSet) {
                final body = {
                  "sets": int.parse(element.sets ?? ""),
                  "reps": int.parse(element.reps ?? ""),
                  "weight": int.parse(element.weight ?? ""),
                  "rest": int.parse(element.reps ?? ""),
                  "load": int.parse(element.load ?? ""),
                  "type": int.parse(element.type ?? ""),
                  "extraId": "${element.extraId}",
                  "date": element.date,
                  "dataId": element.dataId,
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.extraSetHistory);
              }
            }
            List<RemovedExerciseDataModel> removedExercise = await ApiRepo.fetchRemovedExercise(monthDataModelSplit3.id ?? "");
            if (removedExercise.isNotEmpty) {
              for (var element in removedExercise) {
                final body = {
                  "exerciseId": element.exerciseId ?? "",
                  "dataId": element.dataId ?? "",
                  "split": element.split ?? "",
                  "monthId": element.monthId ?? "",
                  "weekId": element.weekId ?? "",
                  "dayId": element.dataId ?? "",
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.removedExerciseHistory);
              }
            }
            List<ExtraExerciseDataModel> extraExercise = await ApiRepo.fetchExtraExercise(monthDataModelSplit3.id ?? "");
            if (extraExercise.isNotEmpty) {
              for (var element in extraExercise) {
                final body = {
                  "dataId": element.dataId ?? "",
                  "split": element.split ?? "",
                  "monthId": element.monthId ?? "",
                  "weekId": element.weekId ?? "",
                  "dayId": element.dayId ?? "",
                  "date": element.date ?? "",
                  "exerciseId": element.exerciseId ?? "",
                  "exerciseJson": element.exerciseJson ?? ""
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.extraExerciseHistory);
              }
            }
            List<SwapExerciseDataModel> swapExercise = await ApiRepo.fetchSwapExercise(monthDataModelSplit3.id ?? "");
            if (swapExercise.isNotEmpty) {
              for (var element in swapExercise) {
                final body = {
                  "dataId": element.dataId ?? "",
                  "split": element.split ?? "",
                  "monthId": element.monthId ?? "",
                  "weekId": element.weekId ?? "",
                  "dayId": element.dayId ?? "",
                  "date": element.date ?? "",
                  "exerciseId": element.exerciseId ?? "",
                  "exerciseJson": element.exerciseJson ?? "",
                  "insertIndex": element.insertIndex ?? ""
                };
                await DatabaseHelper().insertData(data: body, tableName: DatabaseHelper.swapExerciseHistory);
              }
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      log("issue in month view loading=> $e");
    }
  }

  Future<void> fetchCheckoutPoint() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/settings/');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        var responseData = data[0];

        if (equipmentCheckpoint == '' || bonusCheckpoint == '' || workoutCheckpoint == '') {
          equipmentCheckpoint = responseData["equipmentCheckpoint"];
          bonusCheckpoint = responseData["bonusCheckpoint"];
          workoutCheckpoint = responseData["workoutCheckpoint"];
        } else {
          DateTime currentEquipmentCheckpoint = DateTime.parse(equipmentCheckpoint);
          DateTime currentBonusCheckoutPoint = DateTime.parse(bonusCheckpoint);
          DateTime currentWorkoutCheckPoint = DateTime.parse(workoutCheckpoint);
          DateTime newEquipmentCheckpoint = DateTime.parse(responseData["equipmentCheckpoint"]);
          DateTime newBonusCheckpoint = DateTime.parse(responseData["bonusCheckpoint"]);
          DateTime newWorkoutCheckpoint = DateTime.parse(responseData["workoutCheckpoint"]);

          if (currentEquipmentCheckpoint.isBefore(newEquipmentCheckpoint)) {
            equipmentCheckpointState = true;
            equipmentCheckpoint = responseData["equipmentCheckpoint"];
          }
          if (currentBonusCheckoutPoint.isBefore(newBonusCheckpoint)) {
            bonusCheckpointState = true;
            bonusCheckpoint = responseData["bonusCheckpoint"];
          }
          if (currentWorkoutCheckPoint.isBefore(newWorkoutCheckpoint)) {
            workoutCheckpointState = true;
            workoutCheckpoint = responseData["workoutCheckpoint"];
          }
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future<void> fetchTutorialData() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/tutorials/');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data != null) {
          tutorialData = Tutorials.fromJson(data);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load staff data');
      }
    } catch (e) {
      throw Exception('Failed to load staff data');
    }
  }

  Future fetchCurrentEx(String id, String called) async {
    try {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get/$id');

      url = Uri.http(url.authority, url.path);
      String? userIdToken = await getAuthToken();

      final response = await http.get(
        url,
        headers: <String, String>{
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        getExerciseFromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to load exercise info');
      }
    } catch (e) {
      log("fetchCurrentEx ERROR $e ");
    }
  }

  void getExerciseFromJson(responseData) {
    if (responseData != null) {
      currentRelatedExercises.clear();
      List<Equipment> equipments = [];

      if (responseData["relatedExercises"] != null && responseData["relatedExercises"].length > 0) {
        for (var singleItem in responseData["relatedExercises"]) {
          Exercise newExercise = Exercise(
              id: singleItem["id"] ?? "",
              title: singleItem["title"] ?? "",
              vimeoId: singleItem["vimeoId"] ?? "",
              thumbnail: singleItem["thumbnail"] ?? "",
              description: singleItem["description"] ?? "",
              guide: singleItem["guide"] ?? "",
              relatedExercises: singleItem["relatedExercises"] ?? [],
              categories: singleItem["categories"] ?? [],
              usedEquipments: singleItem["usedEquipments"] ?? [],
              files: singleItem['files'] ?? []);

          currentRelatedExercises.add(newExercise);
        }
      }

      if (responseData["usedEquipments"] != null && responseData["usedEquipments"].length > 0) {
        for (var singleItem in responseData["usedEquipments"]) {
          Equipment newEquipment = Equipment(
            id: singleItem["id"] ?? "",
            title: singleItem["title"] ?? "",
            thumbnail: singleItem["thumbnail"] ?? "",
            description: singleItem["description"] ?? "",
            link: singleItem["link"] ?? "",
            createdAt: singleItem["createdAt"] ?? "",
          );
          equipments.add(newEquipment);
        }
      }

      Exercise exerciseObj = Exercise(
          id: responseData["id"] ?? "",
          title: responseData["title"] ?? "",
          vimeoId: responseData["vimeoId"] ?? "",
          thumbnail: responseData["thumbnail"] ?? "",
          description: responseData["description"] ?? "",
          guide: responseData["guide"] ?? "",
          relatedExercises: currentRelatedExercises,
          categories: responseData["categories"] ?? [],
          usedEquipments: equipments,
          files: responseData['files'] ?? []);

      currentExerciseObj = exerciseObj;
    }

    notifyListeners();
  }
}
