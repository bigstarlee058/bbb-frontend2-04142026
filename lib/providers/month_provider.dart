import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/models/MonthResponseModel/all_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/circuit_model.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/excersie_detail_model.dart';
import 'package:bbb/models/MonthResponseModel/exercise_history_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/history_data_model.dart';
import 'package:bbb/models/MonthResponseModel/month_enrollment_model.dart';
import 'package:bbb/models/MonthResponseModel/month_response_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/pump_day_model.dart';
import 'package:bbb/models/MonthResponseModel/removed_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/rest_day_model.dart';
import 'package:bbb/models/MonthResponseModel/swap_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/warm_up_model.dart';
import 'package:bbb/models/SyncDataResponseModel/day_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/day_status_list_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/month_enrollment_data_model.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_constants.dart';

enum WeekType { pastWeek, currentWeek, futureWeek }

class Status {
  static const String empty = "";
  static const String started = "Started";
  static const String skipped = "Skipped";
  static const String completed = "Completed";
}

class MonthProvider extends ChangeNotifier {
  late MainPageProvider mainPageProvider;

  DayDataModel? dayDataModel;
  WeekDataModel? weekDataModel;
  PumpDayModel? pumpDayModel;
  List<PumpDayModel> pumpDays = [];

  List<WeekType> weekStatuses = [];
  List<String> weekStatusesString = [];
  List<RestDayModel> restDayModel = [];

  List<ExerciseHistoryDataModel> exerciseHistroy = [];

  // String selectedButtonTitle = "Mark Complete";
  // List<String> buttonTitle = ["Mark Complete", "Swap To Pump Day"];

  bool isPumpDay = false;
  bool isPumpDayAvailable = false;
  bool isPastWeek = false;
  bool isCircuit = false;
  bool isLastExercise = false;

  DateTime selectedWeekDate = DateTime.now();

  String todayTitleId = "";
  String currentDayTitleId = "";
  String circuitIndex = "";
  // String routeString = "dashboard";
  int circuitsIndex = 0;
  int streak = 0;

  updatePumpDayData(PumpDayModel value) {
    pumpDayModel = value;
    notifyListeners();
  }

  updateIsPastWeek(bool val) {
    isPastWeek = val;
    notifyListeners();
  }

  // changeValue(List<String> val1, String val2) {
  //   buttonTitle = val1;
  //   selectedButtonTitle = val2;
  //   notifyListeners();
  // }

  // changeSelectedButtonTitle(String val2) {
  //   selectedButtonTitle = val2;
  //   notifyListeners();
  // }

  changeIsPumpDay(bool val) {
    isPumpDay = val;
    notifyListeners();
  }

  changeIsPumpDayAvail(bool val) {
    isPumpDayAvailable = val;
    notifyListeners();
  }

  updateCircuit(String val, int index) {
    circuitIndex = val;
    circuitsIndex = index;
    notifyListeners();
  }

  updateIsLastExercise(bool val) {
    isLastExercise = val;
    notifyListeners();
  }

  updateIsCircuit(bool val) {
    isCircuit = val;
    notifyListeners();
  }

  updateCurrentDayTitleId(String val) {
    currentDayTitleId = val;
    notifyListeners();
  }

  // setInitialPumpDayValues() {
  //   selectedButtonTitle = "Mark Complete";
  //   buttonTitle = ["Mark Complete", "Swap To Pump Day"];
  //   isPumpDay = false;
  //   isPumpDayAvailable = false;
  // }

  fetchExerciseHistroy() async {
    exerciseHistroy = await ApiRepo.fetchExerciseForTheExercise(selectedExercise!.exerciseId ?? "");
    notifyListeners();
  }

  Future<void> checkPumpDayAvail() async {
    try {
      final dataList = dayHistoryModel.where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty);

      changeIsPumpDay(false);

      if (dataList.isEmpty || dataList.length < 2) {
        changeIsPumpDayAvail(true);
      } else {
        changeIsPumpDayAvail(false);
      }
    } catch (e, stackTrace) {
      debugPrint("Error in checkPumpDayAvail: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<void> checkForPumpDay() async {
    await checkPumpDayAvail();
    await getAllPumpDayForThisWeek();
    notifyListeners();
  }

  Future<void> updatePumpDayStatus() async {
    try {
      final dataList = dayHistoryModel.where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty);

      if (dataList.isEmpty || dataList.length < 2) {
        changeIsPumpDayAvail(true);
      } else {
        changeIsPumpDayAvail(false);
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in updatePumpDayStatus: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<void> getAllPumpDayForThisWeek() async {
    try {
      List<PumpDayModel> pumpDays = [];
      notifyListeners();

      for (var i = 0; i < (monthDataModel?.weeks?[week! - 1].pumpDayIds?.length ?? 0); i++) {
        var value = await fetchPumpDay(monthDataModel!.weeks![week! - 1].pumpDayIds![i]);
        pumpDays.add(value);
      }

      this.pumpDays = pumpDays;

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in getAllPumpDayForThisWeek: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  /// MAIN SCREEN =============================++++++++++++++++++++++++++++++++++

  DateTime? startTime;
  DateTime? endTime;

  int? week;
  int? actualWeek;
  int? day;
  int currentWeek = 0;
  int overviewCurrentDay = 0;
  int overviewCurrentWeek = 0;

  String? splitType;

  String equipmentType = "A";
  String alternateEquipmentType = "A";

  MonthDataModel? monthDataModel;
  WarmUpModel? warmUpModel;

  List<WeekDataModel> weeksDataList = [];

  bool isFilterLoading = false;

  updateLocalData() async {
    findWeekStatuses();
    await fetchToday();
    await fetchAllDayStatusLocalData();
    await fetchDayStatusLocalData();
    await fetchSingleDayHistoryLocalData();
    findWeekStatuses();
    await fetchToday();
  }

  updateDayData() async {
    await fetchDayStatusLocalData();
    await fetchAllDayStatusLocalData();
    findWeekStatuses();
    await fetchToday();
  }

  Future<void> fetchToday() async {
    try {
      // todayTitleId = "";

      if (monthDataModel?.weeks == null || monthDataModel!.weeks!.isEmpty || week == null || week! - 1 < 0) {
        debugPrint("Error: Invalid week data in fetchToday.");
        return;
      }
      if (actualWeek! > 4) {
        todayTitleId = "";
        return;
      }

      for (var element in monthDataModel!.weeks![week! - 1].idList ?? []) {
        try {
          bool value = allDayHistoryModel.any((ele1) =>
              "${ele1.split}-${ele1.monthId}-${ele1.weekId}-$element" == ele1.dataId &&
              ele1.weekId == monthDataModel!.weeks?[week! - 1].id &&
              (ele1.status == Status.completed || ele1.status == Status.skipped));

          if (!value) {
            todayTitleId = element;
            // await preferences.putString(SharedPreference.todayTitleId, todayTitleId);
            notifyListeners();
            break;
          } else {
            todayTitleId = "";
          }
        } catch (innerError, innerStackTrace) {
          debugPrint("Error processing element: $element");
          debugPrint("Error: $innerError");
          debugPrint("StackTrace: $innerStackTrace");
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchToday: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<RestDayModel?> fetchRestDay(String id) async {
    try {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/restdays/get/$id');
      url = Uri.http(url.authority, url.path);

      String? userIdToken = await getAuthToken();

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return RestDayModel.fromJson(responseData);
      } else {
        debugPrint("Error: Failed to fetch RestDay. Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchRestDay: $e");
      debugPrint("StackTrace: $stackTrace");
      return null;
    }
  }

  void findWeekStatuses() {
    try {
      weekStatuses = [];
      weekStatusesString = [];

      final fixedStartDate = DateTime(startTime!.year, startTime!.month, startTime!.day);
      final fixedEndDate = DateTime(endTime!.year, endTime!.month, endTime!.day);
      const totalWeeks = 4;

      for (int weekNumber = 1; weekNumber <= totalWeeks; weekNumber++) {
        try {
          final weekStartForSelected = fixedStartDate.add(Duration(days: (weekNumber - 1) * 7));
          final weekEndForSelected = weekStartForSelected.add(const Duration(days: 6));

          final secondDay = weekStartForSelected.add(const Duration(days: 1));
          selectedWeekDate = secondDay;

          final currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          WeekType? weekType;
          String week;

          if (currentDate.isBefore(weekStartForSelected)) {
            weekType = WeekType.futureWeek;
            week = "F";
          } else if (currentDate.isAfter(weekEndForSelected)) {
            weekType = WeekType.pastWeek;
            week = "P";
          } else if (currentDate.isAfter(fixedEndDate)) {
            weekType = WeekType.pastWeek;
            week = "P";
          } else {
            weekType = WeekType.currentWeek;
            week = "C";
          }

          weekStatuses.add(weekType);
          weekStatusesString.add(week);
        } catch (innerError, innerStackTrace) {
          debugPrint("Error processing weekNumber $weekNumber: $innerError");
          debugPrint("StackTrace: $innerStackTrace");
        }
      }

      findSplitTypeList();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in findWeekStatuses: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  MonthDataModel? pastMonthDataModel;
  List<String> lastSplit = [];
  List<DayStatusListDataModel> dayStatusList = [];
  List<DayHistoryModel> newStreakData = [];
  List<String> newLastSplit = [];

  void findSplitTypeList() {
    try {
      lastSplit = [];
      newLastSplit = [];
      newStreakData = [];

      allSplitDayHistoryModel.removeWhere((element) => element.status == Status.empty || element.status == Status.started);

      allSplitDayHistoryModel.sort((a, b) {
        DateTime aDate = a.endTime ?? a.startTime ?? a.date!;
        DateTime localTimeADate = Utils.formattedDate("$aDate");
        DateTime bDate = b.endTime ?? b.startTime ?? b.date!;
        DateTime localTimeBDate = Utils.formattedDate("$bDate");
        return (localTimeBDate).compareTo(localTimeADate);
      });

      weekStatusesString.removeWhere((element) => element != "P");

      if (weekStatusesString.isNotEmpty) {
        for (var i = 0; i < ((weekStatusesString.length == 4) ? weekStatusesString.length : weekStatusesString.length + 1); i++) {
          try {
            final data = allSplitDayHistoryModel.where((element) {
              return element.weekId == monthDataModel!.weeks![i].id;
            }).toList();

            if (data.isNotEmpty) {
              if (weekStatusesString.length > i) {
                data.sort((a, b) {
                  DateTime aDate = a.endTime ?? a.startTime ?? a.date!;
                  DateTime localTimeADate = Utils.formattedDate("$aDate");
                  DateTime bDate = b.endTime ?? b.startTime ?? b.date!;
                  DateTime localTimeBDate = Utils.formattedDate("$bDate");
                  return (localTimeBDate).compareTo(localTimeADate);
                });
                lastSplit.add(data.first.split ?? "");

                String split = data.first.split ?? "";
                final rawTempData = preferences.getString("$split-${monthDataModel?.id}");

                if (rawTempData!.isNotEmpty) {
                  pastMonthDataModel = MonthDataModel.fromJson(jsonDecode(rawTempData.toString()));
                  WeekDataModel weekDataModel = pastMonthDataModel!.weeks![i];
                  monthDataModel!.weeks![i] = weekDataModel;
                }
              }
              newStreakData.addAll(allSplitDayHistoryModel
                  .where((element) =>
                      monthDataModel!.weeks![i].id == element.weekId &&
                      monthDataModel?.id == element.monthId &&
                      element.split == (data.first.split ?? "") &&
                      element.status == Status.completed)
                  .toList());
            }
          } catch (innerError, innerStackTrace) {
            debugPrint("Error processing week index $i in findSplitTypeList: $innerError");
            debugPrint("StackTrace: $innerStackTrace");
          }
        }
      }

      filter();
    } catch (e, stackTrace) {
      debugPrint("Error in findSplitTypeList: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  bool loader = false;

  Future<void> onInit({bool isEnabled = true}) async {
    try {
      if (isEnabled) {
        loader = true;
        notifyListeners();
      }

      String split = (preferences.getString(SharedPreference.split) ?? "").replaceAll("split", "");
      await changeDaySplit(split);
      splitType ??= SplitType.split3;

      await fetchAllRemovedExerciseLocalData();

      await getSplitData().then(
        (value) async {
          try {
            if (monthDataModel != null) {
              DateTime today = DateTime.now();
              startTime = Utils.formattedDate("${monthDataModel?.startDate ?? DateTime.now().toUtc()}");
              endTime = Utils.formattedDate("${monthDataModel?.endDate ?? DateTime.now().toUtc()}");
              await NotificationService.scheduleMonthlyReminder(20, monthDataModel?.endDate ?? DateTime.now().toUtc());
              await NotificationService.scheduleWeekReminder(30, monthDataModel?.endDate ?? DateTime.now().toUtc());
              int dayDelta = DateTime(today.year, today.month, today.day)
                  .difference(DateTime(startTime!.year, startTime!.month, startTime!.day))
                  .inDays;
              actualWeek = (dayDelta ~/ 7) + 1;
              week = actualWeek! > 4 ? 4 : actualWeek;
              day = dayDelta % 7 + 1;
              currentWeek = week!;
              dayStatusList = await ApiRepo.fetchDayStatusList() ?? [];
              await fetchMonthLocalData();
              await fetchAllDayStatusLocalData();
              await fetchDayStatusLocalData();
              await checkForPumpDay();
              await getLiftedWeightGraphData();
              await manageStreak();
              findWeekStatuses();
              fetchToday();
              filter();
            }
          } catch (innerError, innerStackTrace) {
            debugPrint("Error inside getSplitData.then in onInit: $innerError");
            debugPrint("StackTrace: $innerStackTrace");
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint("Error in onInit: $e");
      debugPrint("StackTrace: $stackTrace");
    } finally {
      loader = false;
      notifyListeners();
    }
  }

  Future<void> fetchWarmUp(String warmUpId) async {
    try {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/warmups/get/$warmUpId');
      url = Uri.http(url.authority, url.path);
      String? userIdToken = await getAuthToken();

      final response = await http.get(
        url,
        headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic>? responseData = jsonDecode(response.body);
        if (responseData != null) {
          warmUpModel = WarmUpModel.fromJson(responseData);
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load fetchWarmUp');
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchWarmUp: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  // Future<void> fetchPumpDayData(String id) async {
  //   Uri url = Uri.parse('${AppConstants.serverUrl}/api/pump-days/get/$id');
  //   String? userIdToken = await getAuthToken();
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'AUTH_TOKEN': userIdToken ?? "",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       pumpDayModel = PumpDayModel.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to fetch Circuits data');
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint("Error in fetchPumpDayData: $e");
  //     debugPrint("StackTrace: $stackTrace");
  //     throw Exception('Failed to fetch Circuits data');
  //   }
  //
  //   notifyListeners();
  // }

  Future<PumpDayModel> fetchPumpDay(String id) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/pump-days/get/$id');
    String? userIdToken = await getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'AUTH_TOKEN': userIdToken ?? ""},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        PumpDayModel pumpDayModel = PumpDayModel.fromJson(responseData);
        return pumpDayModel;
      } else {
        throw Exception('Failed to load fetchPumpDay');
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchPumpDay: $e");
      debugPrint("StackTrace: $stackTrace");
      throw Exception('Failed to load fetchPumpDay');
    }
  }

  Future<void> getSplitData() async {
    monthDataModel = null;
    String monthId = preferences.getString(SharedPreference.monthId) ?? "";
    String split = preferences.getString(SharedPreference.split) ?? "";

    try {
      final rawTempData = preferences.getString("$split-$monthId");
      if (rawTempData != null && rawTempData.isNotEmpty) {
        monthDataModel = MonthDataModel.fromJson(jsonDecode(rawTempData));
        weeksDataList = monthDataModel!.weeks!;
      }

      findSplitTypeList();
      await getRestDayData();
    } catch (e, stackTrace) {
      debugPrint("Error in getSplitData: $e");
      debugPrint("StackTrace: $stackTrace");
    }

    notifyListeners();
  }

  getRestDayData() {
    String monthId = preferences.getString(SharedPreference.monthId) ?? "";

    try {
      final rawTempData1 = preferences.getString("REST-$monthId");
      if (rawTempData1 != null && rawTempData1.isNotEmpty) {
        restDayModel = List<RestDayModel>.from(json.decode(rawTempData1).map((x) => RestDayModel.fromJson(x)));
      }
    } catch (e, stackTrace) {
      debugPrint("Error in getRestDayData: $e");
      debugPrint("StackTrace: $stackTrace");
    }
    notifyListeners();
  }

  Future<void> changeDaySplit(String value) async {
    try {
      if (value == "3" || value.isEmpty) {
        splitType = SplitType.split3;
      } else if (value == "4") {
        splitType = SplitType.split4;
      } else {
        splitType = SplitType.split5;
      }

      await preferences.putString(SharedPreference.split, "split${value.isEmpty ? "3" : value}");

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in changeDaySplit: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  void changeEquipmentType(String value) async {
    equipmentType = value;
    notifyListeners();
  }

  Future<void> filterWorkouts() async {
    isFilterLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 50));
      await getSplitData();
      filter();
    } catch (e, stackTrace) {
      debugPrint("Error in filterWorkouts: $e");
      debugPrint("StackTrace: $stackTrace");
    } finally {
      isFilterLoading = false;
      notifyListeners();
    }
  }

  void filter() {
    List<ExerciseDataModel> itemsToRemove = [];

    try {
      for (var weekIndex = 0; weekIndex < (monthDataModel?.weeks?.length ?? 0); weekIndex++) {
        var week = monthDataModel!.weeks![weekIndex];

        for (var dayIndex = 0; dayIndex < (week.days?.length ?? 0); dayIndex++) {
          var day = week.days![dayIndex];
          for (var exerciseIndex = 0; exerciseIndex < (day.exercises?.length ?? 0); exerciseIndex++) {
            final exercise = day.exercises![exerciseIndex];
            if (!exercise.formats!.contains(equipmentType)) {
              itemsToRemove.add(weeksDataList[weekIndex].days![dayIndex].exercises![exerciseIndex]);
            }
          }
        }
      }

      for (var item in itemsToRemove) {
        for (var week in weeksDataList) {
          week.days?.forEach((day) {
            day.exercises?.remove(item);
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error in filter: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  void innerFilter() {
    isFilterLoading = true;
    notifyListeners();
    List<ExerciseDataModel> itemsToRemove = [];

    try {
      if (alternateEquipmentType != equipmentType) {
        for (var weekIndex = 0; weekIndex < (weeksDataList.length); weekIndex++) {
          var week = weeksDataList[weekIndex];
          for (var dayIndex = 0; dayIndex < (week.days?.length ?? 0); dayIndex++) {
            var day = week.days![dayIndex];
            for (var exerciseIndex = 0; exerciseIndex < (day.exercises?.length ?? 0); exerciseIndex++) {
              final exercise = day.exercises![exerciseIndex];
              if (!exercise.formats!.contains(alternateEquipmentType)) {
                itemsToRemove.add(weeksDataList[weekIndex].days![dayIndex].exercises![exerciseIndex]);
              }
            }
          }
        }

        for (var item in itemsToRemove) {
          for (var week in weeksDataList) {
            week.days?.forEach((day) {
              day.exercises?.remove(item);
            });
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error in innerFilter: $e");
      debugPrint("StackTrace: $stackTrace");
    }

    isFilterLoading = false;
    notifyListeners();
  }

  /// EXCERSIE =============================++++++++++++++++++++++++++++++++++

  bool isWarmup = false;

  List<RelatedExercises> relatedExercises = [];
  List<UsedEquipments> usedEquipments = [];

  String allExercisesMainList = "";
  List<Exercise> allFilterExercises = [];
  List<Exercise> allExercises = [];

  int selectedExIndex = 0;

  ExerciseDetailModel? exerciseDetailModel;
  ExerciseDataModel? selectedExercise;

  int selectedWarmUpSetTotal = 0;
  int selectedBackOffSetTotal = 0;
  int selectedWorkingSetTotal = 0;

  bool exerciseLoader = false;

  updateSetValue(warmUpSetTotal, backOffSetTotal, workingSetTotal) {
    selectedWarmUpSetTotal = warmUpSetTotal;
    selectedBackOffSetTotal = backOffSetTotal;
    selectedWorkingSetTotal = workingSetTotal;
    notifyListeners();
  }

  addSetCountInWorkingSet() {
    selectedWorkingSetTotal++;
    notifyListeners();
  }

  updateExerciseLoader(bool value) {
    exerciseLoader = value;
    notifyListeners();
  }

  ExerciseDetailModel? exerciseDetailModelData;

  Future<void> fetchRelatedExercise(String exerciseId) async {
    if (exerciseDetailModelData != null) {
      if (exerciseDetailModelData?.sId == exerciseId) {
        return;
      }
    }

    updateExerciseLoader(true);

    String? userIdToken = await getAuthToken();
    exerciseDetailModelData = null;
    try {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get/$exerciseId');
      final response = await http.get(url, headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""});

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null) {
          exerciseDetailModelData = ExerciseDetailModel.fromJson(responseData);
          if (exerciseDetailModelData?.relatedExercises != null) {
            relatedExercises = exerciseDetailModelData!.relatedExercises!;
          }
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load exercise info');
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching related exercises: $e");
      debugPrint("StackTrace: $stackTrace");
    }
    updateExerciseLoader(false);
  }

  Future fetchAllExercise() async {
    if (allExercisesMainList.isNotEmpty) {
      List<dynamic> jsonData = jsonDecode(allExercisesMainList);
      List<Exercise> exercises = jsonData.map((e) => Exercise.fromJson(e)).toList();
      allExercises = exercises;
      allFilterExercises = exercises;
      notifyListeners();
      return;
    }

    updateExerciseLoader(true);
    final Map<String, String> queryParams = {
      'page': '',
      'perPage': '',
      'search': '',
      'sortBy': '',
    };

    Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get');
    url = Uri.http(url.authority, url.path, queryParams);
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
        getExercisesFromJson(jsonDecode(response.body));
        notifyListeners();
      } else {
        throw Exception('Failed to load exercise info');
      }
    } catch (e) {
      debugPrint("Error fetching exercises: $e");
    } finally {
      updateExerciseLoader(false);
    }
  }

  Future fetchAllFilterEx(String searchQuery) async {
    if (searchQuery.isEmpty) {
      allFilterExercises = allExercises;
    } else {
      allFilterExercises = allExercises.where((exercise) => exercise.title!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    notifyListeners();
  }

  void getExercisesFromJson(responseData) {
    allExercisesMainList = "";

    AllExerciseModel allExerciseModel = AllExerciseModel.fromJson(responseData);
    allExercises = allExerciseModel.exercises!;
    allFilterExercises = allExerciseModel.exercises!;
    allExercisesMainList = jsonEncode(allExerciseModel.exercises);

    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  Future fetchCurrentExercise(String id) async {
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
    usedEquipments = [];
    if (responseData != null) {
      exerciseDetailModel = ExerciseDetailModel.fromJson(responseData);
      usedEquipments.addAll(exerciseDetailModel!.usedEquipments!);
      notifyListeners();
    }
    notifyListeners();
  }

  updateWarmUp(bool val) {
    isWarmup = val;
    notifyListeners();
  }

  setSelectedExercise(ExerciseDataModel value, int index) {
    selectedExercise = value;
    selectedExIndex = index;
    notifyListeners();
  }

  /// TIMER LOGIC =============================++++++++++++++++++++++++++++++++++

  String timerAddress = "";
  String timePassed = "";
  String currentExpandedItem = "0:0";

  updateExpandedItem(String value) async {
    currentExpandedItem = value;
    notifyListeners();
  }

  getPassedTime() {
    String time = preferences.getString(SharedPreference.lastTimerPassed) ?? "0";
    String lastTime = preferences.getString(SharedPreference.lastExitTime) ?? "";
    String pause = preferences.getString(SharedPreference.isPause) ?? "false";

    timePassed = time;
    DateTime data = DateTime.parse(lastTime.isEmpty ? DateTime.now().toString() : lastTime);
    var difference = DateTime.now().difference(data);
    if (timePassed != "") {
      if (pause == "true") {
        int totalTimePassed = int.parse(timePassed);
        timePassed = totalTimePassed.toString();
        log("pause == true");
      } else {
        int totalTimePassed = int.parse(timePassed) + difference.inSeconds;
        timePassed = totalTimePassed.toString();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => notifyListeners());
  }

  Future<void> fetchTimerAddress() async {
    String address = preferences.getString(SharedPreference.lastTimerAddress) ?? "";
    await getPassedTime();
    timerAddress = address;
    if (timerAddress.isNotEmpty) {
      var data = timerAddress.split("-");
      if (data.isNotEmpty &&
          data[0] != "-1" &&
          data[2] == "$selectedExIndex" &&
          data[3] == "$overviewCurrentWeek" &&
          data[4] == "$overviewCurrentDay") {
        updateExpandedItem("${data[0]}:${data[1]}:${data[2]}:${data[3]}:${data[4]}");
      } else {
        updateExpandedItem("0:0:$selectedExIndex:$overviewCurrentWeek:$overviewCurrentDay");
      }
    } else {
      if (currentExpandedItem == "0:0") {
        updateExpandedItem("0:0:$selectedExIndex:$overviewCurrentWeek:$overviewCurrentDay");
      }
    }
    notifyListeners();
  }

  Future<void> setShowTimerIndex(int index, int subIndex, int exerciseIndex, {bool removeVal = false}) async {
    if (index != -1 && subIndex != -1 && exerciseIndex != -1) {
      timerAddress = "$index-$subIndex-$exerciseIndex-$overviewCurrentWeek-$overviewCurrentDay";
      await preferences.putString(SharedPreference.lastTimerAddress, timerAddress);
      final pf = await SharedPreferences.getInstance();
      await pf.setString(SharedPreference.lastTimerAddress, timerAddress);
      if (removeVal) {
        await preferences.putString(SharedPreference.lastTimerPassed, "");
        await preferences.putString(SharedPreference.lastExitTime, "");
        final pf = await SharedPreferences.getInstance();
        await pf.setString(SharedPreference.lastTimerPassed, "");
        await pf.setString(SharedPreference.lastExitTime, "");
      }
    } else {
      log("CLEAR VALUES");
      clearValues();
      NotificationService.clearNotification(10);
    }
    notifyListeners();
  }

  clearValues() async {
    timerAddress = "";
    timePassed = "";
    NotificationService.clearNotification(10);
    await preferences.putString(SharedPreference.lastTimerAddress, "");
    await preferences.putString(SharedPreference.lastTimerPassed, "");
    await preferences.putString(SharedPreference.lastExitTime, "");
    final pf = await SharedPreferences.getInstance();
    await pf.setString(SharedPreference.lastTimerAddress, "");
    await pf.setString(SharedPreference.lastTimerPassed, "");
    await pf.setString(SharedPreference.lastExitTime, "");

    notifyListeners();
  }

  Future<void> savePassedTime(String timePassed1, int totalTime, BuildContext context, String dataId, String index, String subIndex) async {
    if (timerAddress != '') {
      timePassed = timePassed1;
      int newTime = totalTime - int.parse(timePassed);
      if (newTime.isNegative || newTime == 0) {
      } else {
        final payLoad = {
          'name': selectedExercise?.name.toString(),
          'exercise_id': selectedExercise?.exerciseId ?? "",
          'exercise_index': selectedExIndex,
          'month_id': monthDataModel?.id,
          'week_id': weekDataModel?.id,
          'day_id': dayDataModel?.id,
          'week_index': overviewCurrentWeek,
          'day_index': overviewCurrentDay,
          'is_pumpday': isPumpDay,
          'is_circuit': isCircuit,
          'circuit_index': isCircuit ? circuitIndex : "",
          'index': index,
          'subIndex': subIndex,
          'dataId': dataId,
        };
        NotificationService.zonedScheduleNotification(newTime, selectedExIndex, payLoad);
      }
    }
    await preferences.putString(SharedPreference.lastTimerPassed, timePassed1);
    await preferences.putString(SharedPreference.lastExitTime, DateTime.now().toString());
    final pf = await SharedPreferences.getInstance();
    await pf.setString(SharedPreference.lastTimerPassed, timePassed1);
    await pf.setString(SharedPreference.lastExitTime, DateTime.now().toString());
    notifyListeners();
  }

  Future<void> exerciseCompletedApi() async {
    int totalFormat1Set = 0;
    int totalFormat1Weight = 0;
    int totalFormat1Reps = 0;
    int totalFormat1Rest = 0;

    int totalFormat2Set = 0;
    int totalFormat2Weight = 0;
    int totalFormat2Reps = 0;
    int totalFormat2Rest = 0;

    int totalFormat3Set = 0;
    int totalFormat3Weight = 0;
    int totalFormat3Reps = 0;
    int totalFormat3Rest = 0;

    for (var element in historyDataModel) {
      if (element.type == "1") {
        totalFormat1Weight += int.parse((element.weight?.isNotEmpty ?? false ? element.weight : "0") ?? "0");
        totalFormat1Reps += int.parse((element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
      if (element.type == "2") {
        totalFormat2Weight += int.parse((element.weight?.isNotEmpty ?? false ? element.weight : "0") ?? "0");
        totalFormat2Reps += int.parse((element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
      if (element.type == "3") {
        totalFormat3Weight += int.parse((element.weight?.isNotEmpty ?? false ? element.weight : "0") ?? "0");
        totalFormat3Reps += int.parse((element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
    }

    totalFormat1Set = historyDataModel.where((element) => element.type == "1").length;
    totalFormat2Set = historyDataModel.where((element) => element.type == "2").length;
    totalFormat3Set = historyDataModel.where((element) => element.type == "3").length;

    bool a = (!(totalFormat1Set == 0 && totalFormat1Weight == 0 && totalFormat1Reps == 0 && totalFormat1Rest == 0));
    bool b = (!(totalFormat2Set == 0 && totalFormat2Weight == 0 && totalFormat2Reps == 0 && totalFormat2Rest == 0));
    bool c = (!(totalFormat3Set == 0 && totalFormat3Weight == 0 && totalFormat3Reps == 0 && totalFormat3Rest == 0));

    final body = {
      "monthIndex": "${monthDataModel?.index}",
      "weekIndex": "${weekDataModel?.index}",
      "dayId": "${weekDataModel?.days?[overviewCurrentDay - 1].id}",
      "day": DateFormat("MM/dd/yyyy").format(DateTime.now()),
      "exerciseId": "${exerciseDetailModel?.sId}",
      "exercises": [
        if (a)
          {
            "sets": "$totalFormat1Set",
            "weight": "$totalFormat1Weight",
            "resp": "$totalFormat1Reps",
            "rest": "$totalFormat1Rest",
            "type": "1",
          },
        if (b)
          {
            "sets": "$totalFormat2Set",
            "weight": "$totalFormat2Weight",
            "resp": "$totalFormat2Reps",
            "rest": "$totalFormat2Rest",
            "type": "2",
          },
        if (c)
          {
            "sets": "$totalFormat3Set",
            "weight": "$totalFormat3Weight",
            "resp": "$totalFormat3Reps",
            "rest": "$totalFormat3Rest",
            "type": "3",
          }
      ]
    };
    if (a || b || c) {
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/exercise_done');
      String? userIdToken = await getAuthToken();
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'AUTH_TOKEN': userIdToken ?? "",
          },
          body: jsonEncode(body));
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to load exercise info');
      }
    }
  }

  /// STREAK COUNT =============================++++++++++++++++++++++++++++++++++

  manageStreak() async {
    List<DayHistoryModel> data = decodedDataAll();
    int streak = 0;
    int savedStreak = preferences.getInt(SharedPreference.lastStreakCount) ?? 0;
    DateTime? pastDate;

    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);
    List<DayHistoryModel> filteredDataList = data.where((e) {
      DateTime date = e.endTime ?? e.startTime!;
      DateTime localTime = Utils.formattedDate("$date");
      DateTime localDay = DateTime(localTime.year, localTime.month, localTime.day);
      return localDay.isBefore(currentDate) || localDay.isAtSameMomentAs(currentDate);
    }).toList();
    try {
      if (filteredDataList.length == 1) {
        DateTime currentDate = filteredDataList[0].endTime ?? filteredDataList[0].startTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");
        DateTime localDay = DateTime(localTime.year, localTime.month, localTime.day);
        pastDate = localDay;
      }

      for (var element in filteredDataList) {
        DateTime currentDate = element.endTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");
        DateTime localDay = DateTime(localTime.year, localTime.month, localTime.day);

        DateTime currentDate1 = filteredDataList[0].endTime ?? filteredDataList[0].startTime!;
        DateTime localTime1 = Utils.formattedDate("$currentDate1");
        DateTime localDay1 = DateTime(localTime1.year, localTime1.month, localTime1.day);

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime firstDay = DateTime(localDay1.year, localDay1.month, localDay1.day);
        if (firstDay != today) {
          int difference = today.difference(firstDay).inDays;
          if (difference > 1) {
            streak = 0;
            break;
          }
        }

        if (pastDate != null) {
          int difference = pastDate.difference(localDay).inDays;
          if (difference > 1) {
            break;
          }
        }
        if (element.status == Status.completed) {
          streak++;
        } else {
          break;
        }
        pastDate = localDay;
      }
    } catch (e) {
      debugPrint('Error managing streak: $e');
    }
    if (savedStreak != streak) {
      this.streak = streak;
      var data = {'count': '$streak'};
      await ApiRepo.updateStreakCount(body: data);
    } else {
      this.streak = savedStreak;
    }

    await preferences.putInt(SharedPreference.lastStreakCount, streak);

    updateAchievements();
    notifyListeners();
  }

  List<DayHistoryModel> decodedDataAll() {
    String encodedTempData = jsonEncode(allSplitDayHistoryModel);
    List<DayHistoryModel> decodedData;
    try {
      decodedData = List<DayHistoryModel>.from(
        json.decode(encodedTempData).map((x) => DayHistoryModel.fromJson(x)),
      );

      decodedData.removeWhere((element) => element.status == Status.empty || element.status == Status.started);

      decodedData.sort((a, b) {
        DateTime aDate = a.endTime!;
        DateTime localTimeADate = Utils.formattedDate("$aDate");
        DateTime bDate = b.endTime!;
        DateTime localTimeBDate = Utils.formattedDate("$bDate");
        // return DateTime(localTimeBDate.year, localTimeBDate.month, localTimeBDate.day)
        //     .compareTo(DateTime(localTimeADate.year, localTimeADate.month, localTimeADate.day));
        return localTimeBDate.compareTo(localTimeADate);
      });

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      decodedData.removeWhere((element) {
        DateTime date = element.endTime!;
        DateTime localTimeADate = Utils.formattedDate("$date");
        DateTime localDay = DateTime(localTimeADate.year, localTimeADate.month, localTimeADate.day);
        return localDay.isAfter(today) && localDay != today;
      });

      Map<String, Map<String, dynamic>> latestByDay = {};
      for (var entry in decodedData) {
        DateTime currentDate = entry.endTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");

        String dayKey = localTime.toString().substring(0, 10);
        if (!latestByDay.containsKey(dayKey) || (entry.status == Status.completed)) {
          latestByDay[dayKey] = entry.toJson();
        }
      }

      decodedData.removeWhere((entry) {
        DateTime currentDate = entry.endTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");
        String dayKey = localTime.toString().substring(0, 10);
        return latestByDay[dayKey]!['id'] != entry.id;
      });
    } catch (e) {
      debugPrint('Error decoding data: $e');
      return [];
    }
    return decodedData;
  }

  /// LOCAL DATA =============================++++++++++++++++++++++++++++++++++

  HistoryDataModel? expandedDataHistory;

  Future<void> fetchExerciseSingleSetLocalData(dataId) async {
    try {
      final data = await DatabaseHelper().getDataByDataId(
        tableName: DatabaseHelper.exerciseHistory,
        id: dataId,
      );

      if (data != null) {
        expandedDataHistory = HistoryDataModel.fromJson(data);
      } else {
        expandedDataHistory = null;
      }
    } catch (e) {
      debugPrint('Error fetching exercise data: $e');
      expandedDataHistory = null;
    }

    notifyListeners();
  }

  Future<HistoryDataModel?> fetchSingleSetLocalData(dataId) async {
    HistoryDataModel? expandedDataHistory;

    try {
      final data = await DatabaseHelper().getDataByDataId(
        tableName: DatabaseHelper.exerciseHistory,
        id: dataId,
      );

      if (data != null) {
        expandedDataHistory = HistoryDataModel.fromJson(data);
      } else {
        expandedDataHistory = null;
      }
    } catch (e) {
      debugPrint('Error fetching exercise data: $e');
      expandedDataHistory = null;
    }
    return expandedDataHistory;
  }

  List<HistoryDataModel> historyDataModel = [];

  Future<void> fetchExerciseHistoryLocalData() async {
    try {
      String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

      final data = await DatabaseHelper().getFilteredWithExerciseData(
        split: split,
        tableName: DatabaseHelper.exerciseHistory,
        exerciseId: "${exerciseDetailModel?.sId}",
        monthId: monthDataModel?.id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1] ?? "",
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        historyDataModel = List<HistoryDataModel>.from(json.decode(jsonEncode(data)).map((x) => HistoryDataModel.fromJson(x)));
      } else {
        historyDataModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching exercise history data: $e");
    }
  }

  List<HistoryDataModel> exerciseWiseHistoryDataModel = [];

  fetchExerciseWiseHistoryLocalData() async {
    try {
      String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
      final data = await DatabaseHelper().getDataByAnyWithSplitField(
          tableName: DatabaseHelper.exerciseHistory, id: "${exerciseDetailModel?.sId}", fieldName: 'exerciseId', split: split);

      if (data.isNotEmpty) {
        exerciseWiseHistoryDataModel = List<HistoryDataModel>.from(json.decode(jsonEncode(data)).map((x) => HistoryDataModel.fromJson(x)));
        return exerciseWiseHistoryDataModel;
      } else {
        exerciseWiseHistoryDataModel = [];
        return exerciseWiseHistoryDataModel;
      }
    } catch (e) {
      debugPrint("Error fetching exercise wise history data: $e");
    }
  }

  List<ExerciseHistoryModel> exerciseHistoryModel = [];

  Future<void> fetchExerciseStatusLocalData() async {
    try {
      String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
      final data = await DatabaseHelper().getFilteredWithMWDData(
        split: split,
        tableName: DatabaseHelper.exerciseStatus,
        monthId: monthDataModel?.id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1] ?? "",
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        exerciseHistoryModel = List<ExerciseHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => ExerciseHistoryModel.fromJson(x)));
      } else {
        exerciseHistoryModel = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching exercise status data: $e");
    }
  }

  ExerciseHistoryModel? exerciseHistoryDetails;
  Future<void> fetchExerciseSingleExerciseLocalData(dataId) async {
    try {
      final data = await DatabaseHelper().getDataByDataId(tableName: DatabaseHelper.exerciseStatus, id: dataId);
      if (data != null) {
        exerciseHistoryDetails = ExerciseHistoryModel.fromJson(data);
      } else {
        exerciseHistoryDetails = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching single exercise local data: $e");
    }
  }

  List<DayHistoryModel> dayHistoryModel = [];

  Future<void> fetchDayStatusLocalData() async {
    try {
      String split = monthDataModel?.weeks?[week! - 1].idList?.first.toString().split(" ")[1] ?? "";

      final data = await DatabaseHelper().getFilteredWithMWData(
        split: split,
        tableName: DatabaseHelper.dayStatus,
        monthId: monthDataModel?.id ?? "",
        weekId: monthDataModel!.weeks?[week! - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        dayHistoryModel = List<DayHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => DayHistoryModel.fromJson(x)));
      } else {
        dayHistoryModel = [];
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching day status local data: $e");
    }
  }

  List<DayHistoryModel> allDayHistoryModel = [];
  List<DayHistoryModel> allSplitDayHistoryModel = [];
  List<String> restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3", "Rest Day 4"];

  Future<void> fetchAllDayStatusLocalData() async {
    try {
      String split = monthDataModel?.weeks?[week! - 1].idList?.first.toString().split(" ")[1] ?? "";

      final data = await DatabaseHelper().getFilteredWithMData(
        split: split,
        tableName: DatabaseHelper.dayStatus,
        monthId: monthDataModel?.id ?? "",
      );

      if (data.isNotEmpty) {
        allDayHistoryModel = List<DayHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => DayHistoryModel.fromJson(x)));
      } else {
        allDayHistoryModel = [];
      }

      final dataList = allDayHistoryModel
          .where((element) => element.weekId == monthDataModel?.weeks?[week! - 1].id && element.dataId.toString().contains("Rest Day"))
          .toList();

      if (dataList.isNotEmpty) {
        restDayList = [];
        List<int> restDays = [];
        Map<int, String> pumpDays = {};
        dataList.sort((a, b) => int.parse(a.dayId!.split(" ").last).compareTo(int.parse(b.dayId!.split(" ").last)));
        for (var item in dataList) {
          if (item.type.toString().contains("Rest Day")) {
            RegExp regex = RegExp(r'Rest Day (\d+)');
            Match? match = regex.firstMatch(item.dayId ?? "");
            if (match != null) {
              restDays.add(int.parse(match.group(1)!));
            }
          } else if (item.type.toString().startsWith("Pump Day")) {
            RegExp regex = RegExp(r'Rest Day (\d+)');
            Match? match = regex.firstMatch(item.dayId ?? "");
            if (match != null) {
              int restDayNumber = int.parse(match.group(1)!);
              pumpDays[restDayNumber] = "PUMPDAY";
            }
          }
        }
        restDays.sort();
        int count = 1;
        int restDayIndex = 1;
        while (restDayList.length < 4) {
          if (pumpDays.containsKey(count)) {
            restDayList.add("PUMPDAY");
          } else if (restDayIndex < restDays.length && restDays[restDayIndex] == count) {
            restDayList.add("Rest Day $restDayIndex");
            restDayIndex++;
          } else {
            restDayList.add("Rest Day $restDayIndex");
            restDayIndex++;
          }
          count++;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching all day status local data: $e");
    }
    await getAllDayStatusData();
  }

  Future<void> getAllDayStatusData() async {
    try {
      final data1 = await DatabaseHelper().fetchData(tableName: DatabaseHelper.dayStatus);
      if (data1.isNotEmpty) {
        allSplitDayHistoryModel = List<DayHistoryModel>.from(json.decode(jsonEncode(data1)).map((x) => DayHistoryModel.fromJson(x)));
      } else {
        allSplitDayHistoryModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching all day status data: $e");
    }
  }

  DayHistoryModel? dayHistoryDetails;

  fetchSingleDayHistoryLocalData() async {
    if (overviewCurrentDay == 0) {
      return null;
    }
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
    String dataId =
        "$split-${monthDataModel?.id}-${weekDataModel?.id ?? monthDataModel?.weeks?[(overviewCurrentWeek) - 1].id}-${monthDataModel?.weeks?[(overviewCurrentWeek) - 1].idList?[overviewCurrentDay - 1] ?? ""}";

    try {
      final data = await DatabaseHelper().getDataByDataId(tableName: DatabaseHelper.dayStatus, id: dataId);
      if (data != null) {
        dayHistoryDetails = DayHistoryModel.fromJson(data);
      } else {
        dayHistoryDetails = null;
      }
    } catch (e) {
      debugPrint("Error fetching single day history data: $e");
    }

    notifyListeners();
  }

  List<CircuitModel> circuitModel = [];

  Future<void> fetchCircuitModelLocalData() async {
    try {
      final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.circuitManager);
      if (data.isNotEmpty) {
        circuitModel = List<CircuitModel>.from(json.decode(jsonEncode(data)).map((x) => CircuitModel.fromJson(x)));
      } else {
        circuitModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching circuit model data: $e");
    }
    notifyListeners();
  }

  List<RemovedExerciseModel> allRemovedExercise = [];

  Future<void> fetchAllRemovedExerciseLocalData() async {
    try {
      final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.removedExerciseHistory);
      if (data.isNotEmpty) {
        allRemovedExercise = List<RemovedExerciseModel>.from(json.decode(jsonEncode(data)).map((x) => RemovedExerciseModel.fromJson(x)));
      } else {
        allRemovedExercise = [];
      }
    } catch (e) {
      debugPrint("Error fetching removed exercise data: $e");
    }
    notifyListeners();
  }

  List<ExtraExerciseModel> addedExerciseList = [];

  Future<void> fetchExtraAddedExerciseData() async {
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    try {
      final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.extraExerciseHistory,
        monthId: monthDataModel?.id ?? "",
        split: split,
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1],
      );

      if (data.isNotEmpty) {
        addedExerciseList = List<ExtraExerciseModel>.from(data.map((x) => ExtraExerciseModel.fromJson(x)));
      } else {
        addedExerciseList = [];
      }
    } catch (e) {
      debugPrint("Error fetching extra added exercise data: $e");
    }

    notifyListeners();
  }

  List<SwapExerciseModel> swapExerciseList = [];

  Future<void> fetchSwapExerciseData() async {
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    try {
      final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.swapExerciseHistory,
        monthId: monthDataModel?.id ?? "",
        split: split,
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1],
      );

      if (data.isNotEmpty) {
        swapExerciseList = List<SwapExerciseModel>.from(data.map((x) => SwapExerciseModel.fromJson(x)));
      } else {
        swapExerciseList = [];
      }
    } catch (e) {
      debugPrint("Error fetching swap exercise data: $e");
    }

    notifyListeners();
  }

  List<MonthResponseModel> monthLocalDataModel = [];
  Future<void> fetchMonthLocalData() async {
    try {
      final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.monthHistory);
      if (data.isNotEmpty) {
        monthLocalDataModel = List<MonthResponseModel>.from(json.decode(jsonEncode(data)).map((x) => MonthResponseModel.fromJson(x)));
      } else {
        monthLocalDataModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching month local data: $e");
    }

    notifyListeners();
  }

  /// CHART =============================++++++++++++++++++++++++++++++++++

  List<Map<String, dynamic>> graphHistory = [];
  double maximumValueOfWeight = 0;
  double maximumValueOfTotalEx = 0;
  double maximumValueOfTotalTime = 0;
  List<Map<String, dynamic>> liftedWeightEachDay = [];

  Map<String, Map<String, dynamic>> filterChartData() {
    // try {
    maximumValueOfWeight = 0;
    maximumValueOfTotalEx = 0;
    maximumValueOfTotalTime = 0;
    const weekdays = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"};
    DateTime today = DateTime.now().toUtc();
    DateTime sixDaysAgo = today.subtract(const Duration(days: 6));

    List<DayHistoryModel> filteredData = allDayHistoryModel.where((entry) {
      if (entry.status != Status.completed) {
        return false;
      }
      DateTime entryDate = entry.endTime!;
      DateTime localTime = Utils.formattedDate("$entryDate");
      return localTime.isAfter(sixDaysAgo) && localTime.isBefore(today.add(const Duration(days: 1)));
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};
    for (var element in filteredData) {
      if (element.status == Status.completed) {
        DateTime dateDateTime = element.date!;
        DateTime localTime = Utils.formattedDate("$dateDateTime");
        DateTime aDate = element.startTime!;
        DateTime localTimeADate = Utils.formattedDate("$aDate");
        DateTime bDate = element.endTime!;
        DateTime localTimeBDate = Utils.formattedDate("$bDate");

        String date = localTime.toIso8601String().split('T')[0];
        double totalWeight = double.parse((element.totalWeight?.isNotEmpty ?? false ? element.totalWeight : "0") ?? "0");
        int completedExercise = int.parse((element.completedExercise?.isNotEmpty ?? false ? element.completedExercise : "0") ?? "0");

        int workoutTimeInSeconds = localTimeBDate.difference(localTimeADate).inSeconds;

        String day = weekdays[localTime.weekday] ?? "";
        if (combinedData.containsKey(date)) {
          combinedData[date]!['totalWeight'] += totalWeight;
          combinedData[date]!['completedExercise'] += completedExercise;
          combinedData[date]!['workoutTime'] += workoutTimeInSeconds;
        } else {
          combinedData[date] = {
            'date': date,
            'totalWeight': totalWeight,
            'day': day,
            'completedExercise': completedExercise,
            'workoutTime': workoutTimeInSeconds,
          };
        }
      }
    }

    combinedData.forEach((key, value) {
      if (double.parse(value["totalWeight"].toString()) > maximumValueOfWeight) {
        maximumValueOfWeight = double.parse(value["totalWeight"].toString());
      }
      if (double.parse(value["completedExercise"].toString()) > maximumValueOfTotalEx) {
        maximumValueOfTotalEx = double.parse(value["completedExercise"].toString());
      }

      final timeInSeconds = double.parse(value["workoutTime"].toString());
      int hours = timeInSeconds ~/ 3600;

      if (double.parse(value["workoutTime"].toString()) > maximumValueOfTotalTime) {
        maximumValueOfTotalTime = double.parse(hours.toString());
      }
    });

    maximumValueOfWeight += 3000;
    maximumValueOfTotalEx += 6;
    maximumValueOfTotalTime += 2;

    notifyListeners();
    return combinedData;
    // } catch (e) {
    //   debugPrint("Error filtering chart data: $e");
    //   return {};
    // }
  }

  Future<void> getLiftedWeightGraphData() async {
    // try {
    liftedWeightEachDay = [];
    graphHistory = [];

    Map<String, Map<String, dynamic>> combinedData = filterChartData();

    if (combinedData.isNotEmpty) {
      combinedData.forEach(
        (key, value) {
          liftedWeightEachDay.add({
            "day": value['day'],
            "totalCompletedExercise": value['completedExercise'],
            "totalTime": value['workoutTime'],
            "totalWeight": value['totalWeight'],
            "date": key,
          });
        },
      );
    }

    graphHistory = processLiftedWeightGraphData(liftedWeightEachDay);

    notifyListeners();
    // } catch (e) {
    //   debugPrint("Error getting lifted weight graph data: $e");
    // }
  }

  List<Map<String, dynamic>> processLiftedWeightGraphData(List<Map<String, dynamic>> data) {
    try {
      List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      DateTime today = DateTime.now();
      String todayDayName = DateFormat('EEE').format(today);

      for (String day in allDays) {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({
            "day": day,
            "totalCompletedExercise": 0,
            "totalTime": 0,
            "totalWeight": 0,
          });
        }
      }

      Map<String, List<double>> dayToWeight = {
        for (var entry in data)
          entry["day"]: [
            double.parse(entry["totalCompletedExercise"].toString()),
            double.parse(entry["totalTime"].toString()),
            double.parse(entry["totalWeight"].toString()),
          ],
      };

      int todayIndex = allDays.indexOf(todayDayName);
      List<String> reorderedDays = [...allDays.sublist(todayIndex + 1), ...allDays.sublist(0, todayIndex + 1)];

      final list = reorderedDays.map((day) {
        List<double> dataList = dayToWeight[day]!;

        return {
          "day": day,
          "totalCompletedExercise": _BarData(AppColors.primaryColor, dataList[0], 0.0),
          "totalTime": _BarData(AppColors.primaryColor, dataList[1], 0.0),
          "totalWeight": _BarData(AppColors.primaryColor, dataList[2], 0.0),
        };
      }).toList();

      return list;
    } catch (e) {
      debugPrint("Error processing lifted weight graph data: $e");
      return [];
    }
  }

  /// ::::: EXERCISE COMPLETED ================================================================================

  List<Map<String, dynamic>> getWeeks(DateTime start, DateTime end) {
    List<Map<String, dynamic>> weeks = [];
    try {
      for (int i = 0; i < 4; i++) {
        DateTime weekStart = start.add(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        weeks.add({
          'weekNumber': i + 1,
          'startDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(weekStart),
          'endDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(weekEnd),
        });
      }
    } catch (e) {
      debugPrint("Error generating weeks: $e");
    }

    return weeks;
  }

  String reportExerciseCompletedWeek = "Week 1";
  List<Map<String, dynamic>> reportExerciseCompletedGraphHistory = [];
  double reportMaximumValueOfTotalEx = 0;
  List<Map<String, dynamic>> reportExerciseCompletedEachDay = [];
  double totalExerciseCompletedInAWeek = 0;

  changeWeekExerciseCompleted(value) {
    String newValue =
        "Week ${int.parse(value.toString().replaceAll("Week ", "")) > 4 ? 4 : int.parse(value.toString().replaceAll("Week ", ""))}";

    reportExerciseCompletedWeek = newValue;
    notifyListeners();
    exerciseReportGraphData(weekNumber: int.parse(value.toString().replaceAll("Week ", "")));
  }

  Map<String, Map<String, dynamic>> reportFilterExerciseCompletedChartData(int weekNumber) {
    reportMaximumValueOfTotalEx = 0;

    List<Map<String, dynamic>> weeks =
        getWeeks(Utils.formattedDate(monthDataModel!.startDate!.toString()), Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber, orElse: () => {});

    const weekdays = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"};
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allDayHistoryModel.where((data) {
      if (data.status != Status.completed) {
        return false;
      }
      DateTime entryDate = data.endTime!;
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate);
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};

    try {
      for (var element in filteredData) {
        if (element.status == Status.completed) {
          DateTime dateDateTime = element.date!;
          String date = dateDateTime.toIso8601String().split('T')[0];
          int completedExercise = int.parse((element.completedExercise?.isNotEmpty ?? false ? element.completedExercise : "0") ?? "0");
          String day = weekdays[dateDateTime.weekday] ?? "";

          if (combinedData.containsKey(date)) {
            combinedData[date]!['completedExercise'] += completedExercise;
          } else {
            combinedData[date] = {'date': date, 'day': day, 'completedExercise': completedExercise};
          }
        }
      }

      combinedData.forEach((key, value) {
        if (double.parse(value["completedExercise"].toString()) > reportMaximumValueOfTotalEx) {
          reportMaximumValueOfTotalEx = double.parse(value["completedExercise"].toString());
        }
      });

      reportMaximumValueOfTotalEx += 6;
    } catch (e) {
      debugPrint("Error filtering exercise completed chart data: $e");
    }

    notifyListeners();
    return combinedData;
  }

  Future<void> exerciseReportGraphData({int? weekNumber}) async {
    reportExerciseCompletedEachDay = [];
    int week = weekNumber ?? currentWeek;
    try {
      Map<String, Map<String, dynamic>> combinedData = reportFilterExerciseCompletedChartData(week);
      if (combinedData.isNotEmpty) {
        combinedData.forEach(
          (key, value) {
            reportExerciseCompletedEachDay.add({"day": value['day'], "totalCompletedExercise": value['completedExercise'], "date": key});
          },
        );
      }
      reportExerciseCompletedGraphHistory = reportProcessExerciseCompletedGraphData(reportExerciseCompletedEachDay);
    } catch (e) {
      debugPrint("Error fetching exercise report graph data: $e");
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessExerciseCompletedGraphData(List<Map<String, dynamic>> data) {
    totalExerciseCompletedInAWeek = 0;
    List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    try {
      for (String day in allDays) {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({"day": day, "totalCompletedExercise": 0});
        }
      }
      Map<String, List<double>> exerciseData = {
        for (var entry in data) entry["day"]: [double.parse(entry["totalCompletedExercise"].toString())],
      };

      final list = allDays.map((day) {
        List<double> dataList = exerciseData[day]!;
        totalExerciseCompletedInAWeek += dataList[0];
        return {"day": day, "totalCompletedExercise": _BarData(AppColors.primaryColor, dataList[0], 0.0)};
      }).toList();

      return list;
    } catch (e) {
      debugPrint("Error processing exercise completed graph data: $e");
      return [];
    }
  }

  /// ::::: WEIGHT LIFTED ================================================================================

  String reportWeightLifted = "Week 1";
  List<Map<String, dynamic>> reportWeightLiftedGraphHistory = [];
  double reportMaximumValueOfWeight = 0;
  List<Map<String, dynamic>> reportWeightLiftedEachDay = [];
  double totalWeightLiftedInAWeek = 0;

  changeWeekWeightLifted(value) {
    String newValue =
        "Week ${int.parse(value.toString().replaceAll("Week ", "")) > 4 ? 4 : int.parse(value.toString().replaceAll("Week ", ""))}";

    reportWeightLifted = newValue;

    weightReportGraphData(weekNumber: int.parse(newValue.toString().replaceAll("Week ", "")));
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> reportFilterWeightLiftedChartData(int weekNumber) {
    reportMaximumValueOfWeight = 0;

    List<Map<String, dynamic>> weeks =
        getWeeks(Utils.formattedDate(monthDataModel!.startDate!.toString()), Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber, orElse: () => {});
    const weekdays = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"};
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allDayHistoryModel.where((data) {
      if (data.status != Status.completed) {
        return false;
      }

      DateTime entryDate = data.endTime!;

      DateTime localTime = Utils.formattedDate("$entryDate");
      return localTime.isAfter(startDate) && localTime.isBefore(endDate);
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};

    for (var element in filteredData) {
      if (element.status == Status.completed) {
        DateTime dateDateTime = element.date!;
        String date = dateDateTime.toIso8601String().split('T')[0];
        double totalWeight = double.parse((element.totalWeight?.isNotEmpty ?? false ? element.totalWeight : "0") ?? "0");
        String day = weekdays[dateDateTime.weekday] ?? "";
        if (combinedData.containsKey(date)) {
          combinedData[date]!['totalWeight'] += totalWeight;
        } else {
          combinedData[date] = {'date': date, 'totalWeight': totalWeight, 'day': day};
        }
      }
    }

    combinedData.forEach((key, value) {
      if (double.parse(value["totalWeight"].toString()) > reportMaximumValueOfWeight) {
        reportMaximumValueOfWeight = double.parse(value["totalWeight"].toString());
      }
    });

    reportMaximumValueOfWeight += 3000;

    notifyListeners();
    return combinedData;
  }

  Future<void> weightReportGraphData({int? weekNumber}) async {
    reportWeightLiftedEachDay = [];
    int week = weekNumber ?? currentWeek;

    try {
      Map<String, Map<String, dynamic>> combinedData = reportFilterWeightLiftedChartData(week);
      if (combinedData.isNotEmpty) {
        combinedData.forEach((key, value) {
          reportWeightLiftedEachDay.add({"day": value['day'], "totalWeight": value['totalWeight'], "date": key});
        });
      }
    } catch (e) {
      debugPrint('Error in weightReportGraphData: $e');
    }

    try {
      reportWeightLiftedGraphHistory = reportProcessWeightLiftedGraphData(reportWeightLiftedEachDay);
    } catch (e) {
      debugPrint('Error in processing weight lifted graph data: $e');
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessWeightLiftedGraphData(List<Map<String, dynamic>> data) {
    totalWeightLiftedInAWeek = 0;
    List<String> allDays = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    try {
      for (String day in allDays) {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({"day": day, "totalWeight": 0});
        }
      }
    } catch (e) {
      debugPrint('Error while adding missing days: $e');
    }

    Map<String, List<double>> weightData = {};
    try {
      weightData = {
        for (var entry in data) entry["day"]: [double.parse(entry["totalWeight"].toString())]
      };
    } catch (e) {
      debugPrint('Error while creating weight data map: $e');
    }

    final list = allDays.map((day) {
      List<double> dataList = weightData[day] ?? [0.0];
      totalWeightLiftedInAWeek += dataList[0];
      return {"day": day, "totalWeight": _BarData(AppColors.primaryColor, dataList[0], 0.0)};
    }).toList();

    return list;
  }

  /// ::::: TIME SPENT ================================================================================

  String reportTimeSpent = "Week 1";
  List<Map<String, dynamic>> reportTimeSpentGraphHistory = [];
  double reportMaximumValueOfTotalTime = 0;
  List<Map<String, dynamic>> reportTimeSpentEachDay = [];

  changeWeekTimeSpent(value) {
    reportTimeSpent = value;
    timeSpentReportGraphData(weekNumber: int.parse(value.toString().replaceAll("Week ", "")));
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> reportFilterTimeSpentChartData(int weekNumber) {
    reportMaximumValueOfTotalTime = 0;

    List<Map<String, dynamic>> weeks =
        getWeeks(Utils.formattedDate(monthDataModel!.startDate!.toString()), Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber, orElse: () => {});
    const weekdays = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thu", 5: "Fri", 6: "Sat", 7: "Sun"};
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allDayHistoryModel.where((data) {
      if (data.status != Status.completed) {
        return false;
      }

      DateTime entryDate = data.endTime!;
      DateTime localTime = Utils.formattedDate("$entryDate");

      return localTime.isAfter(startDate) && localTime.isBefore(endDate);
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};

    for (var element in filteredData) {
      if (element.status == Status.completed) {
        try {
          DateTime dateDateTime = element.date!;
          String date = dateDateTime.toIso8601String().split('T')[0];

          DateTime aDate = element.startTime!;
          DateTime localTimeADate = Utils.formattedDate("$aDate");
          DateTime bDate = element.endTime!;
          DateTime localTimeBDate = Utils.formattedDate("$bDate");

          int workoutTimeInSeconds = localTimeBDate.difference(localTimeADate).inSeconds;

          String day = weekdays[dateDateTime.weekday] ?? "";
          if (combinedData.containsKey(date)) {
            combinedData[date]!['workoutTime'] += workoutTimeInSeconds;
          } else {
            combinedData[date] = {'date': date, 'day': day, 'workoutTime': workoutTimeInSeconds};
          }
        } catch (e) {
          debugPrint('Error while processing element: $e');
        }
      }
    }

    combinedData.forEach((key, value) {
      try {
        final timeInSeconds = double.parse(value["workoutTime"].toString());
        int hours = timeInSeconds ~/ 3600;

        if (double.parse(value["workoutTime"].toString()) > reportMaximumValueOfTotalTime) {
          reportMaximumValueOfTotalTime = double.parse(hours.toString());
        }
      } catch (e) {
        debugPrint('Error while calculating maximum value of total time: $e');
      }
    });

    reportMaximumValueOfTotalTime += 2;

    notifyListeners();
    return combinedData;
  }

  Future<void> timeSpentReportGraphData({int? weekNumber}) async {
    reportTimeSpentEachDay = [];

    int week = weekNumber ?? currentWeek;
    Map<String, Map<String, dynamic>> combinedData = reportFilterTimeSpentChartData(week);

    if (combinedData.isNotEmpty) {
      combinedData.forEach((key, value) {
        try {
          reportTimeSpentEachDay.add({"day": value['day'], "totalTime": value['workoutTime'], "date": key});
        } catch (e) {
          debugPrint('Error while adding data for day $key: $e');
        }
      });
    }
    try {
      reportTimeSpentGraphHistory = reportProcessTimeSpentGraphData(reportTimeSpentEachDay);
    } catch (e) {
      debugPrint('Error while processing time spent graph data: $e');
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessTimeSpentGraphData(List<Map<String, dynamic>> data) {
    List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    for (String day in allDays) {
      try {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({"day": day, "totalTime": 0});
        }
      } catch (e) {
        debugPrint('Error while checking or adding day $day: $e');
      }
    }

    Map<String, List<double>> timeData = {
      for (var entry in data) entry["day"]: [double.parse(entry["totalTime"].toString())]
    };

    final list = allDays.map((day) {
      List<double> dataList = timeData[day]!;
      return {"day": day, "totalTime": _BarData(AppColors.primaryColor, dataList[0], 0.0)};
    }).toList();

    return list;
  }

  /// ::::: ACHIEVEMENT

  final List<Map<String, dynamic>> items = [
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "Breaking the Ice",
      "subtitle": "Your First Workout Finished",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "I Got This",
      "subtitle": "First Week Finished",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "I'm Determined",
      "subtitle": "First Month Finished",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "3 in a Row",
      "subtitle": "Achieved the streak of 3",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "7 in a Row",
      "subtitle": "Achieved the streak of 7",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "14 in a Row",
      "subtitle": "Achieved the Streak of 14",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "30 in a row",
      "subtitle": "Achieved the streak of 30",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "250k Monster",
      "subtitle": "Total Weight Lifted > 250k lbs",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "500k Monster",
      "subtitle": "Total Weight Lifted > 500k lbs",
      "isArchived": false,
      "time": "${DateTime.now().toUtc()}"
    },
  ];
  List<AchievementsModel> achievementsModel = [];

  updateAchievements() async {
    final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.achievementHistory);
    if (data.isNotEmpty) {
      achievementsModel = List<AchievementsModel>.from(json.decode(jsonEncode(data)).map((x) => AchievementsModel.fromJson(x)));
    } else {
      achievementsModel = [];
    }

    for (var element in achievementsModel) {
      if (element.achievementsTitle == "Breaking the Ice") {
        items[0]["isArchived"] = true;
        items[0]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "I Got This") {
        items[1]["isArchived"] = true;
        items[1]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "I'm Determined") {
        items[2]["isArchived"] = true;
        items[2]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "3 in a Row") {
        items[3]["isArchived"] = true;
        items[3]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "7 in a Row") {
        items[4]["isArchived"] = true;
        items[4]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "14 in a Row") {
        items[5]["isArchived"] = true;
        items[5]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "30 in a Row") {
        items[6]["isArchived"] = true;
        items[6]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "250k Monster") {
        items[7]["isArchived"] = true;
        items[7]["time"] = element.achievementsDate.toString();
      }
      if (element.achievementsTitle == "500k Monster") {
        items[8]["isArchived"] = true;
        items[8]["time"] = element.achievementsDate.toString();
      }
    }

    if (items[0]["isArchived"] == false || achievementsModel.isEmpty) {
      if (allDayHistoryModel.any((element) => element.status == Status.completed)) {
        items[0]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "Breaking the Ice", achievementsSubtitle: "Your First Workout Finished");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }

    if (items[1]["isArchived"] == false || achievementsModel.isEmpty) {
      if (monthLocalDataModel.length > 1 ||
          (Utils.formattedDate(monthLocalDataModel.first.monthEndDate ?? "${DateTime.now()}").isBefore(DateTime.now()) == true)) {
        items[2]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "I'm Determined", achievementsSubtitle: "First Month Finished");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }

    if (items[3]["isArchived"] == false || achievementsModel.isEmpty) {
      if (streak >= 3) {
        items[3]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "3 in a Row", achievementsSubtitle: "Achieved the streak of 3");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }

    if (items[4]["isArchived"] == false || achievementsModel.isEmpty) {
      if (streak >= 7) {
        items[4]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "7 in a Row", achievementsSubtitle: "Achieved the streak of 7");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }
    if (items[5]["isArchived"] == false || achievementsModel.isEmpty) {
      if (streak >= 14) {
        items[5]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "14 in a Row", achievementsSubtitle: "Achieved the streak of 14");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }

    if (items[6]["isArchived"] == false || achievementsModel.isEmpty) {
      if (streak >= 30) {
        items[6]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "30 in a Row", achievementsSubtitle: "Achieved the streak of 30");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }
    }

    if (items[7]["isArchived"] == false ||
        items[8]["isArchived"] == false ||
        items[2]["isArchived"] == false ||
        achievementsModel.isEmpty) {
      List<DayStatusDataModel> dayMainData = await ApiRepo.fetchDayAllStatus();
      double totalWeight = 0;

      for (var element in dayMainData) {
        if (element.status == Status.completed) {
          totalWeight += double.parse(element.totalWeight ?? "0");
        }
      }

      if (totalWeight >= 250000) {
        items[7]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "250k Monster", achievementsSubtitle: "Total Weight Lifted > 250k lbs");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }

      if (totalWeight >= 500000) {
        items[8]["isArchived"] = true;
        final data = UpdateAchievementsRequest(achievementsTitle: "500k Monster", achievementsSubtitle: "Total Weight Lifted > 500k lbs");
        await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
        ApiRepo.addAchievementsList(body: data.toJson1());
      }

      List<MonthEnrollmentDataModel> monthEnrollment = await ApiRepo.fetchMonthEnrollment();

      if (monthEnrollment.isNotEmpty) {
        final weekFinishedDate = monthEnrollment.first.startDate?.add(Duration(days: 7));
        if (weekFinishedDate!.isBefore(DateTime.now())) {
          items[1]["isArchived"] = true;
          final data = UpdateAchievementsRequest(achievementsTitle: "I Got This", achievementsSubtitle: "First Week Finished");
          await DatabaseHelper().insertData(tableName: DatabaseHelper.achievementHistory, data: data.toJson());
          ApiRepo.addAchievementsList(body: data.toJson1());
        }
      }
    }

    notifyListeners();
  }
}

class _BarData {
  const _BarData(
    this.color,
    this.value,
    this.shadowValue,
  );
  final Color color;
  final double value;
  final double shadowValue;
}

class UpdateAchievementsRequest {
  final String? achievementsDate;
  final String achievementsTitle;
  final String achievementsSubtitle;

  UpdateAchievementsRequest({
    this.achievementsDate,
    required this.achievementsTitle,
    required this.achievementsSubtitle,
  });

  Map<String, dynamic> toJson() {
    return {
      "achievementsDate": achievementsDate ?? "${DateTime.now().toUtc()}",
      "achievementsTitle": achievementsTitle,
      "achievementsSubtitle": achievementsSubtitle,
    };
  }

  Map<String, dynamic> toJson1() {
    return {
      "achievements_date": achievementsDate ?? "${DateTime.now().toUtc()}",
      "achievements_title": achievementsTitle,
      "achievements_subtitle": achievementsSubtitle,
    };
  }
}
