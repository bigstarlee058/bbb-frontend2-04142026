import 'dart:convert';
import 'dart:developer';

import 'package:bbb/models/bonuses.dart';
import 'package:bbb/models/category.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/models/day.dart';
import 'package:bbb/models/dayexercise.dart';
import 'package:bbb/models/daywarmup.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/models/equipmenttitle.dart';
import 'package:bbb/models/exerciselibrary.dart';
import 'package:bbb/models/month.dart';
import 'package:bbb/models/pump_day_model.dart';
import 'package:bbb/models/staffs.dart';
import 'package:bbb/models/tutorials.dart';
import 'package:bbb/models/week.dart';
import 'package:bbb/pages/new/Month/Model/new_model.dart';
import 'package:bbb/pages/new/Month/new_exercise_manager.dart';
import 'package:bbb/pages/new/provider/month_provider.dart';
import 'package:bbb/storage/exercise_manager.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  Month original = Month(id: '', index: 1, title: '', description: '', vimeoId: '', thumbnail: '', weeks: [], startDate: '', endDate: '');
  Month workout = Month(id: '', index: 1, title: '', description: '', vimeoId: '', thumbnail: '', weeks: [], startDate: '', endDate: '');
  bool dataLoaded = false;
  int totalDays = 1;
  MonthWorkoutsManager monthManager = MonthWorkoutsManager();
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
  PumpDayModel? pumpDayModel;

  Collections collectionData = Collections(id: "", title: "", description: "", photo: "", equipments: []);

  Challenges featureChallengeData = Challenges(id: '', title: '', description: '', photo: '');
  Tutorials tutorialData = Tutorials(id: "", title: "", description: "", photo: "", files: []);

  Future<void> removeExerciseById(int currentWeek, int currentDay, String exerciseID) async {
    original = workout;
    Month newWorkouts = Month(
      id: original.id,
      index: original.index,
      title: original.title,
      description: original.description,
      vimeoId: original.vimeoId,
      thumbnail: original.thumbnail,
      startDate: original.startDate,
      endDate: original.endDate,
      weeks: original.weeks.map((week) {
        if (week.index == currentWeek) {
          return Week(
            index: week.index,
            title: week.title,
            restdayId: week.restdayId,
            description: week.description,
            vimeoId: week.vimeoId,
            thumbnail: week.thumbnail,
            pumpDayIds: week.pumpDayIds,
            days: week.days.map((dynamic day) {
              if ((day as Day).typeId == currentDay) {
                return Day(
                  id: day.id,
                  typeId: day.typeId,
                  title: day.title,
                  vimeoId: day.vimeoId,
                  description: day.description,
                  thumbnail: day.thumbnail,
                  formats: day.formats,
                  warmups: day.warmups,
                  exercises: day.exercises.where((exercise) => (exercise as DayExercise).id != exerciseID).toList(),
                );
              }
              return day;
            }).toList(),
          );
        }
        return week;
      }).toList(),
    );

    await monthManager.saveNewMonth(newWorkouts);
    workout = await monthManager.getMonth(original.index);

    notifyListeners();
  }

  Future<void> swapExerciseById(
      int currentWeek, int currentDay, int selectedIndex, String exerciseID, String newName, String targetExerciseID) async {
    original = workout;
    Month newWorkouts = Month(
      id: original.id,
      index: original.index,
      title: original.title,
      description: original.description,
      vimeoId: original.vimeoId,
      thumbnail: original.thumbnail,
      startDate: original.startDate,
      endDate: original.endDate,
      weeks: original.weeks.map((week) {
        if (week.index == currentWeek) {
          return Week(
            index: week.index,
            title: week.title,
            restdayId: week.restdayId,
            description: week.description,
            vimeoId: week.vimeoId,
            thumbnail: week.thumbnail,
            pumpDayIds: week.pumpDayIds,
            days: week.days.map((Day day) {
              if (day.typeId == currentDay) {
                List exercises = day.exercises;
                int exerciseIndex = exercises.indexWhere((exercise) => exercise.id == exerciseID);

                if (exerciseIndex != -1) {
                  exercises[exerciseIndex].name = newName;
                  exercises[exerciseIndex].id = targetExerciseID;
                }

                return Day(
                  id: day.id,
                  typeId: day.typeId,
                  title: day.title,
                  vimeoId: day.vimeoId,
                  description: day.description,
                  thumbnail: day.thumbnail,
                  formats: day.formats,
                  warmups: day.warmups,
                  exercises: exercises,
                );
              }
              return day;
            }).toList(),
          );
        }
        return week;
      }).toList(),
    );

    await monthManager.saveNewMonth(newWorkouts);
    workout = await monthManager.getMonth(original.index);

    notifyListeners();
  }

  Future<void> addExerciseById(int currentWeek, int currentDay, DayExercise newExercise) async {
    original = workout;
    Month newWorkouts = Month(
      id: original.id,
      index: original.index,
      title: original.title,
      description: original.description,
      vimeoId: original.vimeoId,
      thumbnail: original.thumbnail,
      startDate: original.startDate,
      endDate: original.endDate,
      weeks: original.weeks.map((week) {
        if (week.index == currentWeek) {
          return Week(
            pumpDayIds: week.pumpDayIds,
            index: week.index,
            title: week.title,
            restdayId: week.restdayId,
            description: week.description,
            vimeoId: week.vimeoId,
            thumbnail: week.thumbnail,
            days: week.days.map((dynamic day) {
              if ((day as Day).typeId == currentDay) {
                List exercises = day.exercises;
                exercises.add(newExercise);

                return Day(
                  id: day.id,
                  typeId: day.typeId,
                  title: day.title,
                  vimeoId: day.vimeoId,
                  description: day.description,
                  thumbnail: day.thumbnail,
                  formats: day.formats,
                  warmups: day.warmups,
                  exercises: exercises,
                );
              }
              return day;
            }).toList(),
          );
        }
        return week;
      }).toList(),
    );

    await monthManager.saveNewMonth(newWorkouts);
    workout = await monthManager.getMonth(original.index);

    notifyListeners();
  }

  void filter(String gymAccess, String daySplit) async {
    original = await monthManager.getMonth(original.index);
    log(' original.length;==========>>>>>${original.weeks[0].days[0].exercises.length}');
    workout = Month(
      id: original.id,
      index: original.index,
      title: original.title,
      description: original.description,
      vimeoId: original.vimeoId,
      thumbnail: original.thumbnail,
      startDate: original.startDate,
      endDate: original.endDate,
      weeks: original.weeks.map((week) {
        return Week(
          pumpDayIds: week.pumpDayIds,
          index: week.index,
          title: week.title,
          restdayId: week.restdayId,
          description: week.description,
          vimeoId: week.vimeoId,
          thumbnail: week.thumbnail,
          days: week.days
              // .where((dynamic day) =>
              // (day as Day).formats.contains(daySplit)) // Cast to Day
              .map((dynamic day) {
            return Day(
              id: day.id,
              typeId: (day as Day).typeId,
              title: day.title,
              vimeoId: day.vimeoId,
              description: day.description,
              thumbnail: day.thumbnail,
              formats: day.formats,
              warmups: day.warmups,
              exercises: day.exercises
                  .where((dynamic exercise) => (exercise as DayExercise).formats.contains(gymAccess)) // Cast to DayExercise
                  .toList(),
              // exerciseTypeCnt: day.exerciseTypeCnt,
            );
          }).toList(),
        );
      }).toList(),
    );

    notifyListeners();
  }

  Future<PumpDayModel> fetchPumpDayData(String id) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/pump-days/get/$id');
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
        log('fetchCircuits :::::::::::::::::: ${response.body}');

        pumpDayModel = pumpDayModelFromJson(response.body);
      } else {
        throw Exception('Failed to fetch Circuits data');
      }
    } catch (e) {
      throw Exception('Failed to fetch Circuits data');
    }

    return pumpDayModel!;
  }

  void clearAll() {
    original = workout;
    workout = Month(id: '', index: 1, title: '', description: '', vimeoId: '', thumbnail: '', weeks: [], startDate: '', endDate: '');
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the authToken from SharedPreferences
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
      debugPrint('User data updated successfully');
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
        log('fetchFeaturedColllections :::::::::::::::::: ${response.body}');

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
        debugPrint("this is data provider ${exerciseList.length}");
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
    // if (monthManager.currentMonthIndex != -1) {
    //   workout = await monthManager.getMonth(monthManager.currentMonthIndex);
    //   return;
    // }

    // Month monthInfo;
    final Map<String, String> queryParams = {
      'month': month.toString(),
      'equipment': '0',
      'split': '5',
    };

    Uri url = Uri.parse('${AppConstants.serverUrl}/api/workouts/current');
    url = Uri.http(url.authority, url.path, queryParams);

    String? userIdToken = await getAuthToken();
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': userIdToken ?? "",
      },
    );

    // Print JSON as a string for debugging
    if (response.statusCode == 200) {
      await getMonthInfoFromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      throw Exception('Failed to load exercise info');
    }
  }

  ///OLD
  Future<void> getMonthInfoFromJson(Map<String, dynamic> responseData) async {
    debugPrint("this is fetch month workout data");
    try {
      // Database db = await DatabaseHelper().database;
      // monthDataModel = MonthDataModel.fromJson(responseData);
      // final data = await DatabaseHelper().fetchData(tableName: "WeeksSplit3");
      // log('data :::::::::::::::::: ${data}');
      // if (data.isEmpty) {
      //   for (var element in monthDataModel.weeks!) {
      //     DatabaseHelper().insertWeek(element, db);
      //   }
      // } else {
      //   log("already store data----");
      // }
      //
      // // log('d :::::::::::::::::: ${d}');

      totalDays = 0;
      List<Week> weekList = [];
      for (var singleinfo in responseData["weeks"] ?? []) {
        List<Day> dayList = [];
        totalDays = totalDays + 7;

        for (var singleDayinfo in singleinfo["days"] ?? []) {
          List<String> formatList = [];
          // debugPrint("this is dataprovider ${singleDayinfo["formats"].toString()}");
          for (var singleFormatInfo in singleDayinfo["formats"] ?? []) {
            String formatInfo = singleFormatInfo ?? "";

            formatList.add(formatInfo);
          }

          // Improved handling in warmups and exercises lists
          List<DayWarmup> warmupList = (singleDayinfo["warmups"] as List<dynamic>? ?? []).map((singleWarmUpInfo) {
            return DayWarmup(
              id: singleWarmUpInfo["warmupId"] ?? "1",
              typeId: singleWarmUpInfo["typeId"] ?? 1,
              name: singleWarmUpInfo["name"] ?? "",
              guide: singleWarmUpInfo["guide"] ?? "",
              sets: singleWarmUpInfo["sets"] ?? 0,
              reps: singleWarmUpInfo["reps"] ?? 0,
              weight: singleWarmUpInfo["weight"] ?? "",
              duration: singleWarmUpInfo["duration"] ?? "",
              formats: singleWarmUpInfo["formats"] ?? [],
              warmupId: singleWarmUpInfo["warmupId"] ?? "",
            );
          }).toList();

          List<DayExercise> exerciseList = (singleDayinfo["exercises"] as List<dynamic>? ?? []).map((singleExerciseInfo) {
            return DayExercise(
              id: singleExerciseInfo["exerciseId"] ?? "",
              id_: singleExerciseInfo["id_"] ?? "",
              // this one chnage _id
              typeId: singleExerciseInfo["typeId"] ?? 1,
              name: singleExerciseInfo["name"] ?? "Exercise",
              guide: singleExerciseInfo["guide"] ?? "",
              sets: singleExerciseInfo["sets"] ?? 0,
              reps: singleExerciseInfo["reps"] ?? 0,
              rest: singleExerciseInfo["rest"] ?? 0,
              weight: singleExerciseInfo["weight"] ?? 0,
              duration: singleExerciseInfo["duration"] ?? "",
              formats: singleExerciseInfo["formats"] ?? [],
              extra: singleExerciseInfo["extra"] ?? [],
            );
          }).toList();
          // Add the day info and increment total days
          Day dayInfo = Day(
            id: singleDayinfo["_id"] ?? "",
            typeId: singleDayinfo["typeId"] ?? 1,
            title: singleDayinfo["title"] ?? "",
            vimeoId: singleDayinfo["vimeoId"] ?? "",
            description: singleDayinfo["description"] ?? "",
            thumbnail: singleDayinfo["thumbnail"] ?? "",
            formats: formatList,
            warmups: warmupList,
            exercises: exerciseList,
          );
          dayList.add(dayInfo);
        }
        weekList.add(Week(
          pumpDayIds: singleinfo["pumpDayIds"],
          index: singleinfo["index"] ?? 0,
          title: singleinfo["title"] ?? "",
          description: singleinfo["description"] ?? "",
          restdayId: singleinfo["restdayId"] ?? "",
          vimeoId: singleinfo["vimeoId"] ?? "",
          thumbnail: singleinfo["thumbnail"] ?? "",
          sId: singleinfo["_id"],
          //new
          days: dayList,
        ));
      }
      Month newMonth = Month(
        id: responseData["_id"] ?? "",
        // CHANGE: Default to empty string if null
        index: responseData["index"] ?? 1,
        title: responseData["title"] ?? "",
        description: responseData["description"] ?? "",
        vimeoId: responseData["vimeoId"] ?? "",
        thumbnail: responseData["thumbnail"] ?? "",
        weeks: weekList,
        startDate: responseData["startDate"] ?? DateTime.now(),
        // CHANGE: Default to empty string if null
        endDate: responseData["endDate"] ?? DateTime.now(),
      );
      MonthDataModel monthDataModelSplit3 = MonthDataModel.fromJson(responseData);
      MonthDataModel monthDataModelSplit4 = MonthDataModel.fromJson(responseData);
      MonthDataModel monthDataModelSplit5 = MonthDataModel.fromJson(responseData);
      List split3 = [
        "Day 1 Workout",
        "Rest Day 1",
        "Day 2 Workout",
        "Rest Day 2",
        "Day 3 Workout",
        "Rest Day 3",
        "Rest Day 4",
      ];

      List split4 = [
        "Day 1 Workout",
        "Day 2 Workout",
        "Rest Day 1",
        "Day 3 Workout",
        "Day 4 Workout",
        "Rest Day 2",
        "Rest Day 3",
      ];

      List split5 = [
        "Day 1 Workout",
        "Day 2 Workout",
        "Day 3 Workout",
        "Day 4 Workout",
        "Day 5 Workout",
        "Rest Day 1",
        "Rest Day 2",
      ];

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
          for (var i = 0; i < element.days!.length; i++) {
            element.days?[i].dayType = split5[i];
          }
        },
      );

      await preferences.putString("${SplitType.split5}-${monthDataModelSplit5.id}", jsonEncode(monthDataModelSplit5));
      monthProvider?.restDayModel = [];

      monthDataModelSplit3.weeks?.forEach(
        (element) async {
          final data = await monthProvider?.fetchRestDay(element.restdayId ?? "");
          monthProvider?.restDayModel.add(data!);
        },
      );

      await monthManager.saveMonth(newMonth);
      workout = await monthManager.getMonth(newMonth.index);

      notifyListeners();
    } catch (e) {
      debugPrint("issue in month view loading=> $e");
    } // Notify listeners of changes
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
          // Parse the timestamps to DateTime
          DateTime currentEquipmentCheckpoint = DateTime.parse(equipmentCheckpoint);
          DateTime currentBonusCheckoutPoint = DateTime.parse(bonusCheckpoint);
          DateTime currentWorkoutCheckPoint = DateTime.parse(workoutCheckpoint);
          DateTime newEquipmentCheckpoint = DateTime.parse(responseData["equipmentCheckpoint"]);
          DateTime newBonusCheckpoint = DateTime.parse(responseData["bonusCheckpoint"]);
          DateTime newWorkoutCheckpoint = DateTime.parse(responseData["workoutCheckpoint"]);

          // Compare the DateTime values
          if (currentEquipmentCheckpoint.isBefore(newEquipmentCheckpoint)) {
            equipmentCheckpointState = true; // Update the state
            equipmentCheckpoint = responseData["equipmentCheckpoint"]; // Update the checkpoint
          }
          if (currentBonusCheckoutPoint.isBefore(newBonusCheckpoint)) {
            bonusCheckpointState = true; // Update the state
            bonusCheckpoint = responseData["bonusCheckpoint"]; // Update the checkpoint
          }
          if (currentWorkoutCheckPoint.isBefore(newWorkoutCheckpoint)) {
            workoutCheckpointState = true; // Update the state
            workoutCheckpoint = responseData["workoutCheckpoint"]; // Update the checkpoint
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
}
