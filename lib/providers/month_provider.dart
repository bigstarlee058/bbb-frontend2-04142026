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
import 'package:bbb/models/MonthResponseModel/month_response_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/pump_day_model.dart';
import 'package:bbb/models/MonthResponseModel/removed_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/rest_day_model.dart';
import 'package:bbb/models/MonthResponseModel/swap_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/warm_up_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_status_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/extra_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/removed_exercise_data_model.dart';
import 'package:bbb/models/SyncDataResponseModel/swap_exercise_data_model.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/cache_image_manager.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_constants.dart';

enum WeekType { pastWeek, currentWeek, futureWeek }

class Status {
  static const String empty = "";
  static const String started = "Started";
  static const String skipped = "Skipped";
  static const String completed = "Completed";
  static const String reset = "Reset";
}

class MonthProvider extends ChangeNotifier {
  late MainPageProvider mainPageProvider;
  late UserDataProvider userDataProvider;

  Map<String, dynamic> heroText = {};

  List<int> expandWeeks = [];

  updateExpandWeeks(int mainIndex) {
    if (expandWeeks.contains(mainIndex)) {
      expandWeeks.remove(mainIndex);
    } else {
      expandWeeks.add(mainIndex);
    }
    notifyListeners();
  }

  FileImage? monthTitleImage;

  DayDataModel? dayDataModel;
  WeekDataModel? weekDataModel;
  PumpDayModel? pumpDayModel;
  List<PumpDayModel> pumpDays = [];

  List<WeekType> weekStatuses = [];
  List<String> weekStatusesString = [];
  List<RestDayModel> restDayModel = [];

  List<ExerciseHistoryDataModel> exerciseHistroy = [];

  bool isPumpDay = false;
  bool isPumpDayAvailable = false;
  bool isPastWeek = false;
  bool isCircuit = false;
  bool isLastExercise = false;
  bool settingLoader = false;
  bool isOnMonthPage = false;
  DateTime selectedWeekDate = DateTime.now();

  String todayTitleId = "";
  String currentDayTitleId = "";
  String circuitIndex = "";
  int circuitsIndex = 0;
  int streak = 0;
  int selectedSection = 0;
  bool scrollToRestDay = false;

  updateScrollToRestDay(bool value) {
    scrollToRestDay = value;
    notifyListeners();
  }

  updateIsOnMonthPage(bool value) {
    isOnMonthPage = value;
    notifyListeners();
  }

  updateSelectedSection(int index) {
    selectedSection = index;
    notifyListeners();
  }

  updatePumpDayData(PumpDayModel value) {
    pumpDayModel = value;
    notifyListeners();
  }

  updateIsPastWeek(bool val) {
    isPastWeek = val;
    notifyListeners();
  }

  updateSettingLoader(bool val) {
    settingLoader = val;
    notifyListeners();
  }

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

  fetchExerciseHistroy() async {
    try {
      exerciseHistroy = await ApiRepo.fetchExerciseForTheExercise(
          selectedExercise!.exerciseId ?? "");
      notifyListeners();
    } catch (e) {
      debugPrint("FETCH HISTORY ISSUE $e");
    }
  }

  Future<void> checkPumpDayAvail() async {
    try {
      final dataList = dayHistoryModel.where((element) =>
          element.type?.contains("Pump Day") == true &&
          element.status != Status.empty);

      int pumpDayCount =
          monthDataModel?.weeks?[week! - 1].pumpDayIds?.length ?? 0;

      changeIsPumpDay(false);

      if (dataList.isEmpty || dataList.length < pumpDayCount) {
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
    await getAllPumpDayForThisWeek().then(
      (value) {
        if (pumpDays.isEmpty) {
          changeIsPumpDayAvail(false);
          changeIsPumpDay(false);
        }
      },
    );

    notifyListeners();
  }

  Future<void> updatePumpDayStatus() async {
    try {
      final dataList = dayHistoryModel.where((element) =>
          element.type?.contains("Pump Day") == true &&
          element.status != Status.empty);

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

      for (var i = 0;
          i < (monthDataModel?.weeks?[week! - 1].pumpDayIds?.length ?? 0);
          i++) {
        var value = await fetchPumpDay(
            monthDataModel!.weeks![week! - 1].pumpDayIds![i]);
        if (value != null) {
          pumpDays.add(value);
        }
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

  MonthDataModel? monthDataModel;
  WarmUpModel? warmUpModel;

  String warmupId = "";

  List<WeekDataModel> weeksDataList = [];

  bool isFilterLoading = false;

  clearWarmupModel() {
    warmUpModel = null;
    // isWarmup = false;
  }

  updateLocalData() async {
    findWeekStatuses();
    await fetchToday();
    await fetchAllDayStatusLocalData();
    if (isCurrentMonth == "Current") {
      await fetchDayStatusLocalData();
    }
    await fetchSingleDayHistoryLocalData();
    findWeekStatuses();
    await fetchToday();
  }

  updateDayData() async {
    if (isCurrentMonth == "Current") {
      await fetchDayStatusLocalData();
    }
    await fetchAllDayStatusLocalData();
    findWeekStatuses();
    await fetchToday();
  }

  Future<void> fetchToday() async {
    try {
      if (monthDataModel?.weeks == null ||
          monthDataModel!.weeks!.isEmpty ||
          week == null ||
          week! - 1 < 0 ||
          week == 0) {
        return;
      }
      if (actualWeek! > 4) {
        todayTitleId = "";
        return;
      }

      for (var element in monthDataModel!.weeks![week! - 1].idList ?? []) {
        try {
          bool value = allDayHistoryModel.any((ele1) =>
              "${ele1.split}-${ele1.monthId}-${ele1.weekId}-$element" ==
                  ele1.dataId &&
              ele1.weekId == monthDataModel!.weeks?[week! - 1].id &&
              (ele1.status == Status.completed ||
                  ele1.status == Status.skipped));

          if (!value) {
            todayTitleId = element;
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
        debugPrint(
            "Error: Failed to fetch RestDay. Status Code: ${response.statusCode}");
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
      if (isCurrentMonth == "Current") {
        final fixedStartDate =
            DateTime(startTime!.year, startTime!.month, startTime!.day);
        final fixedEndDate =
            DateTime(endTime!.year, endTime!.month, endTime!.day);
        const totalWeeks = 4;

        for (int weekNumber = 1; weekNumber <= totalWeeks; weekNumber++) {
          try {
            final weekStartForSelected =
                fixedStartDate.add(Duration(days: (weekNumber - 1) * 7));
            final weekEndForSelected =
                weekStartForSelected.add(const Duration(days: 6));

            final secondDay = weekStartForSelected.add(const Duration(days: 1));
            selectedWeekDate = secondDay;

            final currentDate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
      } else {
        if (isCurrentMonth == "Past") {
          weekStatuses = [
            WeekType.pastWeek,
            WeekType.pastWeek,
            WeekType.pastWeek,
            WeekType.pastWeek
          ];
          weekStatusesString = ["P", "P", "P", "P"];
        } else {
          weekStatuses = [
            WeekType.futureWeek,
            WeekType.futureWeek,
            WeekType.futureWeek,
            WeekType.futureWeek
          ];
          weekStatusesString = ["F", "F", "F", "F"];
        }
        findSplitTypeList();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint("Error in findWeekStatuses: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  MonthDataModel? pastMonthDataModel;
  List<String> lastSplit = [];
  List<DayHistoryModel> newStreakData = [];
  List<String> newLastSplit = [];

  Future<void> findSplitTypeList() async {
    try {
      lastSplit = [];
      newLastSplit = [];
      newStreakData = [];

      final data1 = allSplitDayHistoryModel
          .where((element) =>
              (element.status != Status.empty ||
                  element.status != Status.started) &&
              element.monthId == monthDataModel?.id)
          .toList();

      data1.sort((a, b) {
        DateTime aDate = a.endTime ?? a.startTime ?? a.date!;
        DateTime localTimeADate = Utils.formattedDate("$aDate");
        DateTime bDate = b.endTime ?? b.startTime ?? b.date!;
        DateTime localTimeBDate = Utils.formattedDate("$bDate");
        return (localTimeBDate).compareTo(localTimeADate);
      });

      weekStatusesString.removeWhere((element) => element != "P");

      if (weekStatusesString.isNotEmpty) {
        for (var i = 0;
            i <
                ((weekStatusesString.length == 4)
                    ? weekStatusesString.length
                    : weekStatusesString.length + 1);
            i++) {
          try {
            final data = data1.where((element) {
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

                if (isCurrentMonth == "Current" || isCurrentMonth == "Future") {
                  final monthId =
                      preferences.getString(SharedPreference.monthId) ?? "";

                  if (i ==
                      ((weekStatusesString.length == 4)
                          ? weekStatusesString.length
                          : weekStatusesString.length + 1)) {
                    split = splitType ?? "";
                  }

                  final rawTempData = preferences.getString("$split-$monthId");
                  if (rawTempData!.isNotEmpty) {
                    pastMonthDataModel = MonthDataModel.fromJson(
                        jsonDecode(rawTempData.toString()));
                    WeekDataModel weekDataModel = pastMonthDataModel!.weeks![i];
                    monthDataModel!.weeks![i] = weekDataModel;
                  }
                } else {
                  final data = pastMonthDataList.where(
                      (element) => element["monthId"] == monthDataModel?.id);
                  if (data.isNotEmpty) {
                    var newData =
                        data.first["monthData"][split == SplitType.split3
                            ? 0
                            : split == SplitType.split4
                                ? 1
                                : 2];
                    pastMonthDataModel = newData;
                    WeekDataModel weekDataModel = pastMonthDataModel!.weeks![i];
                    monthDataModel!.weeks![i] = weekDataModel;
                  }
                }
              } else {
                if (isCurrentMonth == "Current") {
                  lastSplit = addCurrentSplitForRemaining(lastSplit);
                  final monthId =
                      preferences.getString(SharedPreference.monthId) ?? "";
                  final rawTempData =
                      preferences.getString("$splitType-$monthId");
                  if (rawTempData!.isNotEmpty) {
                    pastMonthDataModel = MonthDataModel.fromJson(
                        jsonDecode(rawTempData.toString()));
                    WeekDataModel weekDataModel = pastMonthDataModel!.weeks![i];
                    monthDataModel!.weeks![i] = weekDataModel;
                  }
                }
              }

              newStreakData.addAll(allSplitDayHistoryModel
                  .where((element) =>
                      monthDataModel!.weeks![i].id == element.weekId &&
                      monthDataModel?.id == element.monthId &&
                      element.split == (data.first.split ?? "") &&
                      element.status == Status.completed)
                  .toList());
            } else {
              lastSplit.add(splitType ?? "");
            }
          } catch (innerError, innerStackTrace) {
            debugPrint(
                "Error processing week index $i in findSplitTypeList1: $innerError");
            debugPrint("StackTrace: $innerStackTrace");
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error in findSplitTypeList1: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  List<String> addCurrentSplitForRemaining(List<String> inputList) {
    final result = List<String>.from(inputList);
    while (result.length < 4) {
      result.add(splitType ?? "");
    }
    return result;
  }

  bool loader = false;
  bool loader1 = false;

  Future<void> onInit({bool isEnabled = true, BuildContext? context}) async {
    try {
      loader1 = true;
      if (context != null) {
        userDataProvider =
            Provider.of<UserDataProvider>(context, listen: false);
      }
      if (isEnabled) {
        loader = true;
      }

      notifyListeners();
      String split = (preferences.getString(SharedPreference.split) ?? "")
          .replaceAll("split", "");

      await changeDaySplit(split);

      splitType ??= SplitType.split3;
      fetchAllRemovedExerciseLocalData();

      await getSplitData().then(
        (value) async {
          try {
            if (monthDataModel != null) {
              DateTime today = DateTime.now();
              startTime = Utils.formattedDate(
                  "${monthDataModel?.startDate ?? DateTime.now().toUtc()}");
              endTime = Utils.formattedDate(
                  "${monthDataModel?.endDate ?? DateTime.now().toUtc()}");
              int dayDelta = DateTime(today.year, today.month, today.day)
                  .difference(DateTime(
                      startTime!.year, startTime!.month, startTime!.day))
                  .inDays;
              actualWeek = (dayDelta ~/ 7) + 1;
              week = actualWeek! > 4 ? 4 : actualWeek;
              day = dayDelta % 7 + 1;
              currentWeek = week!;

              notifyListeners();
              await fetchAllDayStatusLocalData();

              updateOnInitMethods();
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
      loader1 = false;
      notifyListeners();
    }
  }

  Future<void> updateOnInitMethods() async {
    if (isCurrentMonth == "Current") {
      fetchDayStatusLocalData();
    }

    checkForPumpDay();

    getLiftedWeightGraphData();

    manageStreak();

    // await updateAchievementsData();

    // updateAchievements();

    findWeekStatuses();

    fetchToday();

    final processedUrl = (monthDataModel?.thumbnail ?? "")
            .startsWith('https://storage.cloud.google.com/')
        ? (monthDataModel?.thumbnail ?? "").replaceFirst(
            'https://storage.cloud.google.com/',
            'https://storage.googleapis.com/')
        : (monthDataModel?.thumbnail ?? "");
    try {
      final file = await CustomCacheManager().getSingleFile(processedUrl);
      monthTitleImage = FileImage(file);
    } catch (e) {
      debugPrint("Image cache failed : $e");
    }
    notifyListeners();

    NotificationService.scheduleMonthlyReminder(
        20, monthDataModel?.endDate ?? DateTime.now().toUtc());
    NotificationService.scheduleWeekReminder(
        30, monthDataModel?.endDate ?? DateTime.now().toUtc());
  }

  Future<void> fetchWarmUp(String warmUpId) async {
    try {
      log('warmUpId==========>>>>>${warmUpId}');
      Uri url =
          Uri.parse('${AppConstants.serverUrl}/api/warmups/get/$warmUpId');
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
        log('Failed to load fetchWarmUp');
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchWarmUp: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  Future<PumpDayModel?> fetchPumpDay(String id) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/pump-days/get/$id');
    String? userIdToken = await getAuthToken();
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'AUTH_TOKEN': userIdToken ?? ""
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        PumpDayModel pumpDayModel = PumpDayModel.fromJson(responseData);
        return pumpDayModel;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchPumpDay: $e");
      debugPrint("StackTrace: $stackTrace");
      return null;
    }
  }

  MonthDataModel? getCurrentMonthData() {
    String monthId = preferences.getString(SharedPreference.monthId) ?? "";
    String split = preferences.getString(SharedPreference.split) ?? "";
    try {
      final rawTempData = preferences.getString("$split-$monthId");
      if (rawTempData != null && rawTempData.isNotEmpty) {
        return MonthDataModel.fromJson(jsonDecode(rawTempData));
      }
    } catch (e) {
      log('e :::::::getCurrentMonthData::::::::::: $e');
    }
    return null;
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
        notifyListeners();
      }
      await findSplitTypeList();
      getRestDayData();
      notifyListeners();
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
        restDayModel = List<RestDayModel>.from(
            json.decode(rawTempData1).map((x) => RestDayModel.fromJson(x)));
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

      await preferences.putString(
          SharedPreference.split, "split${value.isEmpty ? "3" : value}");

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in changeDaySplit: $e");
      debugPrint("StackTrace: $stackTrace");
    }
  }

  void changeEquipmentType(String value) async {
    equipmentType = value;
    await preferences.putString(
        SharedPreference.equipmentType, value.isEmpty ? "A" : equipmentType);
    notifyListeners();
  }

  Future<void> filterWorkouts() async {
    isFilterLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      if (isCurrentMonth == "Current") {
        await getSplitData();
      } else {
        await getSplitDataPastMonth(monthLocalDataModel[currentMonthIndex]);
      }
    } catch (e, stackTrace) {
      debugPrint("Error in filterWorkouts: $e");
      debugPrint("StackTrace: $stackTrace");
    } finally {
      isFilterLoading = false;
      notifyListeners();
    }
  }

  /// =============================++++++++++++++++++++++++++++++++++

  bool isWarmup = false;

  List<RelatedExercises> relatedExercises = [];
  List<ExerciseDataModel> swapOptionExercises = [];
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

  Future<void> fetchRelatedExercise(
      String exerciseId,
      List formates,
      List<ExerciseDataModel> exercises,
      int typeId,
      String exerciseName) async {
    final seen = <String>{};
    swapOptionExercises = exercises.where((element) {
      final isValid = !element.formats!.contains(equipmentType) &&
          element.typeId == typeId &&
          element.exerciseId != exerciseId &&
          seen.add(element.exerciseId ?? '');
      return isValid;
    }).toList();

    final monthId = preferences.getString(SharedPreference.monthId) ?? "";
    final split = preferences.getString(SharedPreference.split) ?? "";
    final rawTempData = preferences.getString("$split-$monthId");

    if (rawTempData?.isNotEmpty == true) {
      final monthDataModel = MonthDataModel.fromJson(jsonDecode(rawTempData!));

      int nextWorkOutIndex = weekDataModel!.dayList![overviewCurrentDay - 1]
              .toString()
              .contains("Workout")
          ? int.parse(weekDataModel!.dayList![overviewCurrentDay - 1]
                  .toString()
                  .replaceAll("Day ", "")
                  .replaceAll(" Workout", "")) -
              1
          : 0;

      final extraExercises = monthDataModel
          .weeks?[overviewCurrentWeek - 1].days?[nextWorkOutIndex].exercises
          ?.where((element) =>
              element.typeId == typeId &&
              element.exerciseId != exerciseId &&
              seen.add(element.exerciseId ?? ''))
          .toList();

      if (extraExercises != null) {
        swapOptionExercises.addAll(extraExercises);
      }
    }

    if (exerciseDetailModelData != null) {
      if (exerciseDetailModelData?.sId == exerciseId) {
        notifyListeners();
        return;
      }
    }

    updateExerciseLoader(true);

    String? userIdToken = await getAuthToken();
    exerciseDetailModelData = null;
    try {
      Uri url =
          Uri.parse('${AppConstants.serverUrl}/api/exercises/get/$exerciseId');
      final response = await http
          .get(url, headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""});

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
      List<Exercise> exercises =
          jsonData.map((e) => Exercise.fromJson(e)).toList();
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
      allFilterExercises = allExercises
          .where((exercise) =>
              exercise.title!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
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

  Future<void> fetchCurrentExercise(String id) async {
    try {
      final userIdToken = await getAuthToken();

      final url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get/$id');
      final response =
          await http.get(url, headers: {'AUTH_TOKEN': userIdToken ?? ""});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = ExerciseDetailModel.fromJson(data);
        exerciseDetailModel = model;
        usedEquipments = List.from(model.usedEquipments ?? []);

        notifyListeners(); // Single rebuild
      } else {
        throw Exception('Failed to load exercise info');
      }
    } catch (e) {
      log("fetchCurrentExercise ERROR: $e");
    }
  }

  updateWarmUp(bool val, String id) {
    isWarmup = val;
    warmupId = id;
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
    String time =
        preferences.getString(SharedPreference.lastTimerPassed) ?? "0";
    String lastTime =
        preferences.getString(SharedPreference.lastExitTime) ?? "";
    String pause = preferences.getString(SharedPreference.isPause) ?? "false";

    timePassed = time;
    DateTime data =
        DateTime.parse(lastTime.isEmpty ? DateTime.now().toString() : lastTime);
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
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => notifyListeners());
  }

  bool addSet = false;

  updateAddSet(bool val) {
    addSet = val;
    notifyListeners();
  }

  Future<void> fetchTimerAddress() async {
    if (addSet) {
      return;
    }

    String address =
        preferences.getString(SharedPreference.lastTimerAddress) ?? "";
    await getPassedTime();
    timerAddress = address;
    if (timerAddress.isNotEmpty) {
      var data = timerAddress.split("-");
      if (data.isNotEmpty &&
          data[0] != "-1" &&
          data[2] == "$selectedExIndex" &&
          data[3] == "$overviewCurrentWeek" &&
          data[4] == "$overviewCurrentDay") {
        updateExpandedItem(
            "${data[0]}:${data[1]}:${data[2]}:${data[3]}:${data[4]}");
      } else {
        updateExpandedItem(
            "0:0:$selectedExIndex:$overviewCurrentWeek:$overviewCurrentDay");
      }
    } else {
      if (currentExpandedItem == "0:0") {
        updateExpandedItem(
            "0:0:$selectedExIndex:$overviewCurrentWeek:$overviewCurrentDay");
      }
    }

    notifyListeners();
    updateAddSet(false);
  }

  Future<void> setShowTimerIndex(int index, int subIndex, int exerciseIndex,
      {bool removeVal = false}) async {
    if (index != -1 && subIndex != -1 && exerciseIndex != -1) {
      timerAddress =
          "$index-$subIndex-$exerciseIndex-$overviewCurrentWeek-$overviewCurrentDay";
      await preferences.putString(
          SharedPreference.lastTimerAddress, timerAddress);
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
      await clearValues();
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

  Future<void> savePassedTime(
      String timePassed1,
      int totalTime,
      BuildContext context,
      String dataId,
      String index,
      String subIndex) async {
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
        NotificationService.zonedScheduleNotification(
            newTime, selectedExIndex, payLoad);
      }
    }
    await preferences.putString(SharedPreference.lastTimerPassed, timePassed1);
    await preferences.putString(
        SharedPreference.lastExitTime, DateTime.now().toString());
    final pf = await SharedPreferences.getInstance();
    await pf.setString(SharedPreference.lastTimerPassed, timePassed1);
    await pf.setString(
        SharedPreference.lastExitTime, DateTime.now().toString());
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
        totalFormat1Weight += int.parse(
            (element.weight?.isNotEmpty ?? false ? element.weight : "0") ??
                "0");
        totalFormat1Reps += int.parse(
            (element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
      if (element.type == "2") {
        totalFormat2Weight += int.parse(
            (element.weight?.isNotEmpty ?? false ? element.weight : "0") ??
                "0");
        totalFormat2Reps += int.parse(
            (element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
      if (element.type == "3") {
        totalFormat3Weight += int.parse(
            (element.weight?.isNotEmpty ?? false ? element.weight : "0") ??
                "0");
        totalFormat3Reps += int.parse(
            (element.reps?.isNotEmpty ?? false ? element.reps : "0") ?? "0");
      }
    }

    totalFormat1Set =
        historyDataModel.where((element) => element.type == "1").length;
    totalFormat2Set =
        historyDataModel.where((element) => element.type == "2").length;
    totalFormat3Set =
        historyDataModel.where((element) => element.type == "3").length;

    bool a = (!(totalFormat1Set == 0 &&
        totalFormat1Weight == 0 &&
        totalFormat1Reps == 0 &&
        totalFormat1Rest == 0));
    bool b = (!(totalFormat2Set == 0 &&
        totalFormat2Weight == 0 &&
        totalFormat2Reps == 0 &&
        totalFormat2Rest == 0));
    bool c = (!(totalFormat3Set == 0 &&
        totalFormat3Weight == 0 &&
        totalFormat3Reps == 0 &&
        totalFormat3Rest == 0));

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
      DateTime localDay =
          DateTime(localTime.year, localTime.month, localTime.day);
      return localDay.isBefore(currentDate) ||
          localDay.isAtSameMomentAs(currentDate);
    }).toList();
    try {
      if (filteredDataList.length == 1) {
        DateTime currentDate =
            filteredDataList[0].endTime ?? filteredDataList[0].startTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");
        DateTime localDay =
            DateTime(localTime.year, localTime.month, localTime.day);
        pastDate = localDay;
      }

      for (var element in filteredDataList) {
        DateTime currentDate = element.endTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");
        DateTime localDay =
            DateTime(localTime.year, localTime.month, localTime.day);

        DateTime currentDate1 =
            filteredDataList[0].endTime ?? filteredDataList[0].startTime!;
        DateTime localTime1 = Utils.formattedDate("$currentDate1");
        DateTime localDay1 =
            DateTime(localTime1.year, localTime1.month, localTime1.day);

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime firstDay =
            DateTime(localDay1.year, localDay1.month, localDay1.day);
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
    // await updateAchievementsData();
    // await updateAchievements();
    notifyListeners();
  }

  List<DayHistoryModel> decodedDataAll() {
    String encodedTempData = jsonEncode(allSplitDayHistoryModel);
    List<DayHistoryModel> decodedData;
    try {
      decodedData = List<DayHistoryModel>.from(
        json.decode(encodedTempData).map((x) => DayHistoryModel.fromJson(x)),
      );
      decodedData.removeWhere((element) =>
          element.status == Status.empty ||
          element.status == Status.started ||
          element.endTime == null);
      decodedData.sort((a, b) {
        DateTime aDate = a.endTime!;
        DateTime localTimeADate = Utils.formattedDate("$aDate");
        DateTime bDate = b.endTime!;
        DateTime localTimeBDate = Utils.formattedDate("$bDate");
        return localTimeBDate.compareTo(localTimeADate);
      });

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      decodedData.removeWhere((element) {
        DateTime date = element.endTime!;
        DateTime localTimeADate = Utils.formattedDate("$date");
        DateTime localDay = DateTime(
            localTimeADate.year, localTimeADate.month, localTimeADate.day);
        return localDay.isAfter(today) && localDay != today;
      });

      Map<String, Map<String, dynamic>> latestByDay = {};
      for (var entry in decodedData) {
        DateTime currentDate = entry.endTime!;
        DateTime localTime = Utils.formattedDate("$currentDate");

        String dayKey = localTime.toString().substring(0, 10);
        if (!latestByDay.containsKey(dayKey) ||
            (entry.status == Status.completed)) {
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
          tableName: DatabaseHelper.exerciseHistory, id: dataId);

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
      String split = monthDataModel
              ?.weeks?[overviewCurrentWeek - 1].idList?.first
              .toString()
              .split(" ")[1] ??
          "";

      final data = await DatabaseHelper().getFilteredWithExerciseData(
        split: split,
        tableName: DatabaseHelper.exerciseHistory,
        exerciseId: "${exerciseDetailModel?.sId}",
        monthId: monthDataModel?.id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1]
                .idList![overviewCurrentDay - 1] ??
            "",
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        historyDataModel = List<HistoryDataModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => HistoryDataModel.fromJson(x)));
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
      String split = monthDataModel
              ?.weeks?[overviewCurrentWeek - 1].idList?.first
              .toString()
              .split(" ")[1] ??
          "";
      final data = await DatabaseHelper().getDataByAnyWithSplitField(
          tableName: DatabaseHelper.exerciseHistory,
          id: "${exerciseDetailModel?.sId}",
          fieldName: 'exerciseId',
          split: split);

      if (data.isNotEmpty) {
        exerciseWiseHistoryDataModel = List<HistoryDataModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => HistoryDataModel.fromJson(x)));
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
      String split = monthDataModel
              ?.weeks?[overviewCurrentWeek - 1].idList?.first
              .toString()
              .split(" ")[1] ??
          "";
      final data = await DatabaseHelper().getFilteredWithMWDData(
        split: split,
        tableName: DatabaseHelper.exerciseStatus,
        monthId: monthDataModel?.id ?? "",
        dayId: monthDataModel!.weeks?[overviewCurrentWeek - 1]
                .idList![overviewCurrentDay - 1] ??
            "",
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        exerciseHistoryModel = List<ExerciseHistoryModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => ExerciseHistoryModel.fromJson(x)));
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
      final data = await DatabaseHelper().getDataByDataId(
          tableName: DatabaseHelper.exerciseStatus, id: dataId);
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
      String split = monthDataModel?.weeks?[week! - 1].idList?.first
              .toString()
              .split(" ")[1] ??
          "";

      final data = await DatabaseHelper().getFilteredWithMWData(
        split: split,
        tableName: DatabaseHelper.dayStatus,
        monthId: monthDataModel?.id ?? "",
        weekId: monthDataModel!.weeks?[week! - 1].id ?? "",
      );

      if (data.isNotEmpty) {
        dayHistoryModel = List<DayHistoryModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => DayHistoryModel.fromJson(x)));
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

  Future<void> fetchAllDayStatusLocalData() async {
    // try {
    await getAllDayStatusData();

    // String split = monthDataModel?.weeks?[week! - 1].idList?.first.toString().split(" ")[1] ?? "";

    final data = await DatabaseHelper().getFilteredWithMData(
        split: splitType ?? "",
        tableName: DatabaseHelper.dayStatus,
        monthId: monthDataModel?.id ?? "");
    if (data.isNotEmpty) {
      allDayHistoryModel = List<DayHistoryModel>.from(json
          .decode(jsonEncode(data))
          .map((x) => DayHistoryModel.fromJson(x)));
    } else {
      allDayHistoryModel = [];
    }

    // for (var element in monthDataModel!.weeks!) {
    //   if (allDayHistoryModel.any((data) => data.weekId == element.id)) {
    //     if (splitType == SplitType.split3) {
    //       element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3", "Rest Day 4"];
    //     } else if (splitType == SplitType.split4) {
    //       element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3"];
    //     } else {
    //       element.restDayList = ["Rest Day 1", "Rest Day 2"];
    //     }
    //     final list = allDayHistoryModel.where((e1) => e1.type!.contains("Pump Day") && e1.weekId == element.id).toList();
    //     if (list.isNotEmpty) {
    //       for (var pump in list) {
    //         int pumpDayIndex = int.parse(pump.dayId?.split(" ").last ?? "1");
    //         int restDayIndex = element.restDayList!.indexOf("Rest Day $pumpDayIndex");
    //         if (restDayIndex != -1) {
    //           element.restDayList?[restDayIndex] = "Pump Day";
    //         }
    //       }
    //     }
    //   }
    // }

    if (allSplitDayHistoryModel.isNotEmpty) {
      for (int i = 0; i < monthDataModel!.weeks!.length; i++) {
        var element = monthDataModel!.weeks![i];
        if (allSplitDayHistoryModel.any((data) => data.weekId == element.id)) {
          if (isCurrentMonth == "Current" || isCurrentMonth == "Future") {
            if (splitType == SplitType.split3) {
              element.restDayList = [
                "Rest Day 1",
                "Rest Day 2",
                "Rest Day 3",
                "Rest Day 4"
              ];
            } else if (splitType == SplitType.split4) {
              element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3"];
            } else {
              element.restDayList = ["Rest Day 1", "Rest Day 2"];
            }
          } else {
            if (lastSplit[i] == SplitType.split3) {
              element.restDayList = [
                "Rest Day 1",
                "Rest Day 2",
                "Rest Day 3",
                "Rest Day 4"
              ];
            } else if (lastSplit[i] == SplitType.split4) {
              element.restDayList = ["Rest Day 1", "Rest Day 2", "Rest Day 3"];
            } else {
              element.restDayList = ["Rest Day 1", "Rest Day 2"];
            }
          }
          if (lastSplit.isNotEmpty) {
            final list = allSplitDayHistoryModel.where((e1) {
              return e1.type!.contains("Pump Day") &&
                  e1.weekId == element.id &&
                  (isCurrentMonth == "Future"
                          ? (splitType ?? "")
                          : lastSplit[i]) ==
                      e1.split;
            }).toList();
            if (list.isNotEmpty) {
              for (int j = 0; j < list.length; j++) {
                var pump = list[j];
                int pumpDayIndex =
                    int.parse(pump.dayId?.split(" ").last ?? "1");

                int restDayIndex =
                    element.restDayList!.indexOf("Rest Day $pumpDayIndex");
                if (restDayIndex != -1) {
                  element.restDayList?[restDayIndex] = pump.title ?? "Pump Day";
                }
              }
            }
          }
        }
      }
      for (var e in monthDataModel!.weeks!) {
        int restDayCount = 1;
        for (int i = 0; i < e.restDayList!.length; i++) {
          if (e.restDayList![i].startsWith('Rest Day')) {
            e.restDayList![i] = 'Rest Day ${restDayCount++}';
          }
        }
      }
    }
    notifyListeners();
    // } catch (e) {
    //   debugPrint("Error fetching all day status local data: $e");
    // }
  }

  Future<void> getAllDayStatusData() async {
    try {
      final data1 =
          await DatabaseHelper().fetchData(tableName: DatabaseHelper.dayStatus);
      if (data1.isNotEmpty) {
        allSplitDayHistoryModel = List<DayHistoryModel>.from(json
            .decode(jsonEncode(data1))
            .map((x) => DayHistoryModel.fromJson(x)));
      } else {
        allSplitDayHistoryModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching all day status data: $e");
    }
  }

  DayHistoryModel? dayHistoryDetails;

  fetchSingleDayHistoryLocalData() async {
    dayHistoryDetails = null;
    if (overviewCurrentDay == 0) {
      return null;
    }
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";
    String dataId =
        "$split-${monthDataModel?.id}-${weekDataModel?.id ?? monthDataModel?.weeks?[(overviewCurrentWeek) - 1].id}-${monthDataModel?.weeks?[(overviewCurrentWeek) - 1].idList?[overviewCurrentDay - 1] ?? ""}";

    try {
      final data = await DatabaseHelper()
          .getDataByDataId(tableName: DatabaseHelper.dayStatus, id: dataId);
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
      final data = await DatabaseHelper()
          .fetchData(tableName: DatabaseHelper.circuitManager);
      if (data.isNotEmpty) {
        circuitModel = List<CircuitModel>.from(
            json.decode(jsonEncode(data)).map((x) => CircuitModel.fromJson(x)));
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
      final data = await DatabaseHelper()
          .fetchData(tableName: DatabaseHelper.removedExerciseHistory);
      if (data.isNotEmpty) {
        allRemovedExercise = List<RemovedExerciseModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => RemovedExerciseModel.fromJson(x)));
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
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    try {
      final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.extraExerciseHistory,
        monthId: monthDataModel?.id ?? "",
        split: split,
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
        dayId: monthDataModel!
            .weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1],
      );

      if (data.isNotEmpty) {
        addedExerciseList = List<ExtraExerciseModel>.from(
            data.map((x) => ExtraExerciseModel.fromJson(x)));
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
    String split = monthDataModel?.weeks?[overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    try {
      final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.swapExerciseHistory,
        monthId: monthDataModel?.id ?? "",
        split: split,
        weekId: monthDataModel!.weeks?[overviewCurrentWeek - 1].id ?? "",
        dayId: monthDataModel!
            .weeks?[overviewCurrentWeek - 1].idList![overviewCurrentDay - 1],
      );

      if (data.isNotEmpty) {
        swapExerciseList = List<SwapExerciseModel>.from(
            data.map((x) => SwapExerciseModel.fromJson(x)));
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
      final data = await DatabaseHelper()
          .fetchData(tableName: DatabaseHelper.monthHistory);
      if (data.isNotEmpty) {
        monthLocalDataModel = List<MonthResponseModel>.from(json
            .decode(jsonEncode(data))
            .map((x) => MonthResponseModel.fromJson(x)));
        monthLocalDataModel.sort((b, a) => DateTime.parse(a.monthStartDate!)
            .compareTo(DateTime.parse(b.monthStartDate!)));
        String userRole = preferences.getString(SharedPreference.role) ?? "0";
        if (userRole == "0") {
          String mID = preferences.getString(SharedPreference.monthId) ?? "";
          final DateTime? currentStartDate = DateTime.tryParse(
            monthLocalDataModel
                    .firstWhere(
                      (element) => element.monthId == mID,
                      orElse: () => MonthResponseModel(),
                    )
                    .monthStartDate ??
                '',
          );

          final filteredList = monthLocalDataModel.where((item) {
            final itemDate = DateTime.parse(item.monthStartDate!);
            return itemDate.isBefore(currentStartDate!) ||
                itemDate.isAtSameMomentAs(currentStartDate);
          }).toList();

          monthLocalDataModel = filteredList;
        }
      } else {
        monthLocalDataModel = [];
      }
    } catch (e) {
      debugPrint("Error fetching month local data: $e");
    }

    notifyListeners();
  }

  /// CHART =============================++++++++++++++++++++++++++++++++++

  String graphType = "";

  updateGraphType(String value) {
    graphType = value;
    notifyListeners();
  }

  getLiftedWeightGraphData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      changeWeekExerciseCompleted("Week $currentWeek");
      changeWeekWeightLifted("Week $currentWeek");
      changeAverageRIR("Week $currentWeek");
    });
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
    exerciseReportGraphData(
        weekNumber: int.parse(value.toString().replaceAll("Week ", "")));
  }

  Map<String, Map<String, dynamic>> reportFilterExerciseCompletedChartData(
      int weekNumber) {
    reportMaximumValueOfTotalEx = 0;

    List<Map<String, dynamic>> weeks = getWeeks(
        Utils.formattedDate(monthDataModel!.startDate!.toString()),
        Utils.formattedDate(monthDataModel!.endDate!.toString()));

    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber,
        orElse: () => {});

    const weekdays = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun"
    };
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allSplitDayHistoryModel.where((data) {
      if (data.status != Status.completed) {
        return false;
      }
      DateTime entryDate = data.endTime!;
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate);
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};

    filteredData.sort(
      (a, b) {
        return a.endTime!.compareTo(b.endTime!);
      },
    );

    try {
      for (var element in filteredData) {
        if (element.status == Status.completed) {
          DateTime dateTime = element.endTime!;
          DateTime localTime = Utils.formattedDate("$dateTime");
          String date = localTime.toIso8601String().split('T')[0];
          int completedExercise = int.parse(
              (element.completedExercise?.isNotEmpty ?? false
                      ? element.completedExercise
                      : "0") ??
                  "0");
          String day = weekdays[localTime.weekday] ?? "";
          if (combinedData.containsKey(date)) {
            combinedData[date]!['completedExercise'] += completedExercise;
          } else {
            combinedData[date] = {
              'date': date,
              'day': day,
              'completedExercise': completedExercise
            };
          }
        }
      }

      combinedData.forEach((key, value) {
        if (double.parse(value["completedExercise"].toString()) >
            reportMaximumValueOfTotalEx) {
          reportMaximumValueOfTotalEx =
              double.parse(value["completedExercise"].toString());
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
      Map<String, Map<String, dynamic>> combinedData =
          reportFilterExerciseCompletedChartData(week);
      if (combinedData.isNotEmpty) {
        combinedData.forEach(
          (key, value) {
            reportExerciseCompletedEachDay.add({
              "day": value['day'],
              "totalCompletedExercise": value['completedExercise'],
              "date": key
            });
          },
        );
      }
      reportExerciseCompletedGraphHistory =
          reportProcessExerciseCompletedGraphData(
              reportExerciseCompletedEachDay);
    } catch (e) {
      debugPrint("Error fetching exercise report graph data: $e");
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessExerciseCompletedGraphData(
      List<Map<String, dynamic>> data) {
    totalExerciseCompletedInAWeek = 0;
    List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    try {
      for (String day in allDays) {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({"day": day, "totalCompletedExercise": 0});
        }
      }
      Map<String, List<double>> exerciseData = {
        for (var entry in data)
          entry["day"]: [
            double.parse(entry["totalCompletedExercise"].toString())
          ],
      };

      final list = allDays.map((day) {
        List<double> dataList = exerciseData[day]!;
        totalExerciseCompletedInAWeek += dataList[0];
        return {
          "day": day,
          "totalCompletedExercise":
              _BarData(AppColors.primaryColor, dataList[0], 0.0)
        };
      }).toList();
      return list;
    } catch (e) {
      debugPrint("Error processing exercise completed graph data: $e");
      return [];
    }
  }

  /// ::::: AVERAGE RIR ================================================================================

  String reportAverageRIRWeek = "Week 1";
  List<Map<String, dynamic>> reportAverageRIRGraphHistory = [];
  double reportMaximumValueOfAverageRIR = 0;
  List<Map<String, dynamic>> reportAverageRIREachDay = [];
  double averageRIRInAWeek = 0;

  changeAverageRIR(value) {
    String newValue =
        "Week ${int.parse(value.toString().replaceAll("Week ", "")) > 4 ? 4 : int.parse(value.toString().replaceAll("Week ", ""))}";

    reportAverageRIRWeek = newValue;
    notifyListeners();
    averageRIRGraphData(
        weekNumber: int.parse(value.toString().replaceAll("Week ", "")));
  }

  Map<String, Map<String, dynamic>> reportFilterAverageRIRChartData(
      int weekNumber) {
    reportMaximumValueOfAverageRIR = 0;

    List<Map<String, dynamic>> weeks = getWeeks(
        Utils.formattedDate(monthDataModel!.startDate!.toString()),
        Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber,
        orElse: () => {});

    const weekdays = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun"
    };
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allSplitDayHistoryModel.where((data) {
      if (data.status != Status.completed) {
        return false;
      }

      DateTime entryDate = Utils.formattedDate(data.endTime!.toString());
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate);
    }).toList();

    Map<String, Map<String, dynamic>> combinedData = {};

    try {
      for (var element in filteredData) {
        if (element.status == Status.completed) {
          DateTime dateTime = element.endTime!;
          DateTime localTime = Utils.formattedDate("$dateTime");
          String dateSort = localTime.toIso8601String().split('T')[0];

          double averageRIR = element.averageRIR != "NaN"
              ? double.parse((element.averageRIR?.isNotEmpty ?? false
                      ? element.averageRIR
                      : "0") ??
                  "0")
              : 0;
          String day = weekdays[localTime.weekday] ?? "";
          if (combinedData.containsKey(dateSort)) {
            combinedData[dateSort]!['averageRIR'] += averageRIR;
          } else {
            combinedData[dateSort] = {
              'date': dateSort,
              'day': day,
              'averageRIR': averageRIR
            };
          }
        }
      }

      combinedData.forEach((key, value) {
        if (double.parse(value["averageRIR"].toString()) >
            reportMaximumValueOfAverageRIR) {
          reportMaximumValueOfAverageRIR =
              double.parse(value["averageRIR"].toString());
        }
      });

      reportMaximumValueOfAverageRIR += 6;
    } catch (e) {
      debugPrint("Error filtering Average RIR chart data: $e");
    }

    notifyListeners();
    return combinedData;
  }

  Future<void> averageRIRGraphData({int? weekNumber}) async {
    reportAverageRIREachDay = [];
    int week = weekNumber ?? currentWeek;
    try {
      Map<String, Map<String, dynamic>> combinedData =
          reportFilterAverageRIRChartData(week);
      if (combinedData.isNotEmpty) {
        combinedData.forEach(
          (key, value) {
            reportAverageRIREachDay.add({
              "day": value['day'],
              "totalAverageRIR": value['averageRIR'],
              "date": key
            });
          },
        );
      }
      reportAverageRIRGraphHistory =
          reportProcessAverageRIRGraphData(reportAverageRIREachDay);
    } catch (e) {
      debugPrint("Error fetching average RIR graph data: $e");
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessAverageRIRGraphData(
      List<Map<String, dynamic>> data) {
    averageRIRInAWeek = 0;
    List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    try {
      for (String day in allDays) {
        if (!data.any((entry) => entry['day'] == day)) {
          data.add({"day": day, "totalAverageRIR": 0});
        }
      }
      Map<String, List<double>> exerciseData = {
        for (var entry in data)
          entry["day"]: [double.parse(entry["totalAverageRIR"].toString())],
      };

      final list = allDays.map((day) {
        List<double> dataList = exerciseData[day]!;
        averageRIRInAWeek += dataList[0];
        return {
          "day": day,
          "totalAverageRIR": _BarData(AppColors.primaryColor, dataList[0], 0.0)
        };
      }).toList();

      return list;
    } catch (e) {
      debugPrint("Error processing average RIR graph data: $e");
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

    weightReportGraphData(
        weekNumber: int.parse(newValue.toString().replaceAll("Week ", "")));
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> reportFilterWeightLiftedChartData(
      int weekNumber) {
    reportMaximumValueOfWeight = 0;

    List<Map<String, dynamic>> weeks = getWeeks(
        Utils.formattedDate(monthDataModel!.startDate!.toString()),
        Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber,
        orElse: () => {});
    const weekdays = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun"
    };
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allSplitDayHistoryModel.where((data) {
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
        DateTime dateTime = element.endTime!;
        DateTime localTime = Utils.formattedDate("$dateTime");

        String dateSort = localTime.toIso8601String().split('T')[0];
        double totalWeight = double.parse(
            (element.totalWeight?.isNotEmpty ?? false
                    ? element.totalWeight
                    : "0") ??
                "0");
        String day = weekdays[localTime.weekday] ?? "";
        if (combinedData.containsKey(dateSort)) {
          combinedData[dateSort]!['totalWeight'] += totalWeight;
        } else {
          combinedData[dateSort] = {
            'date': dateSort,
            'totalWeight': totalWeight,
            'day': day
          };
        }
      }
    }

    combinedData.forEach((key, value) {
      if (double.parse(value["totalWeight"].toString()) >
          reportMaximumValueOfWeight) {
        reportMaximumValueOfWeight =
            double.parse(value["totalWeight"].toString());
      }
    });

    reportMaximumValueOfWeight = roundUpToNiceValue(reportMaximumValueOfWeight);

    notifyListeners();
    return combinedData;
  }

  double roundUpToNiceValue(double value) {
    if (value <= 0) return 0;
    int rounded = ((value + 9999) / 10000).floor() * 10000;
    return rounded.toDouble();
  }

  Future<void> weightReportGraphData({int? weekNumber}) async {
    reportWeightLiftedEachDay = [];
    int week = weekNumber ?? currentWeek;

    try {
      Map<String, Map<String, dynamic>> combinedData =
          reportFilterWeightLiftedChartData(week);
      if (combinedData.isNotEmpty) {
        combinedData.forEach((key, value) {
          reportWeightLiftedEachDay.add({
            "day": value['day'],
            "totalWeight": value['totalWeight'],
            "date": key
          });
        });
      }
    } catch (e) {
      debugPrint('Error in weightReportGraphData: $e');
    }

    try {
      reportWeightLiftedGraphHistory =
          reportProcessWeightLiftedGraphData(reportWeightLiftedEachDay);
    } catch (e) {
      debugPrint('Error in processing weight lifted graph data: $e');
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessWeightLiftedGraphData(
      List<Map<String, dynamic>> data) {
    totalWeightLiftedInAWeek = 0;
    List<String> allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

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
        for (var entry in data)
          entry["day"]: [double.parse(entry["totalWeight"].toString())]
      };
    } catch (e) {
      debugPrint('Error while creating weight data map: $e');
    }

    final list = allDays.map((day) {
      List<double> dataList = weightData[day] ?? [0.0];
      totalWeightLiftedInAWeek += dataList[0];
      return {
        "day": day,
        "totalWeight": _BarData(AppColors.primaryColor, dataList[0], 0.0)
      };
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
    timeSpentReportGraphData(
        weekNumber: int.parse(value.toString().replaceAll("Week ", "")));
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> reportFilterTimeSpentChartData(
      int weekNumber) {
    reportMaximumValueOfTotalTime = 0;

    List<Map<String, dynamic>> weeks = getWeeks(
        Utils.formattedDate(monthDataModel!.startDate!.toString()),
        Utils.formattedDate(monthDataModel!.endDate!.toString()));
    var week = weeks.firstWhere((week) => week['weekNumber'] == weekNumber,
        orElse: () => {});
    const weekdays = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun"
    };
    DateTime startDate = DateTime.parse(week['startDate']);
    DateTime endDate = DateTime.parse(week['endDate']);

    List<DayHistoryModel> filteredData = allSplitDayHistoryModel.where((data) {
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
          DateTime dateTime = element.date!;

          DateTime localTime = Utils.formattedDate("$dateTime");

          String date = localTime.toIso8601String().split('T')[0];

          DateTime aDate = element.startTime!;
          DateTime localTimeADate = Utils.formattedDate("$aDate");
          DateTime bDate = element.endTime!;
          DateTime localTimeBDate = Utils.formattedDate("$bDate");

          int workoutTimeInSeconds =
              localTimeBDate.difference(localTimeADate).inSeconds;

          String day = weekdays[localTime.weekday] ?? "";
          if (combinedData.containsKey(date)) {
            combinedData[date]!['workoutTime'] += workoutTimeInSeconds;
          } else {
            combinedData[date] = {
              'date': date,
              'day': day,
              'workoutTime': workoutTimeInSeconds
            };
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

        if (double.parse(value["workoutTime"].toString()) >
            reportMaximumValueOfTotalTime) {
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
    Map<String, Map<String, dynamic>> combinedData =
        reportFilterTimeSpentChartData(week);

    if (combinedData.isNotEmpty) {
      combinedData.forEach((key, value) {
        try {
          reportTimeSpentEachDay.add({
            "day": value['day'],
            "totalTime": value['workoutTime'],
            "date": key
          });
        } catch (e) {
          debugPrint('Error while adding data for day $key: $e');
        }
      });
    }
    try {
      reportTimeSpentGraphHistory =
          reportProcessTimeSpentGraphData(reportTimeSpentEachDay);
    } catch (e) {
      debugPrint('Error while processing time spent graph data: $e');
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> reportProcessTimeSpentGraphData(
      List<Map<String, dynamic>> data) {
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
      for (var entry in data)
        entry["day"]: [double.parse(entry["totalTime"].toString())]
    };

    final list = allDays.map((day) {
      List<double> dataList = timeData[day]!;
      return {
        "day": day,
        "totalTime": _BarData(AppColors.primaryColor, dataList[0], 0.0)
      };
    }).toList();

    return list;
  }

  void clearAllValues() {
    dayDataModel = null;
    weekDataModel = null;
    pumpDayModel = null;
    pumpDays = [];
    weekStatuses = [];
    weekStatusesString = [];
    restDayModel = [];
    exerciseHistroy = [];
    isPumpDay = false;
    isPumpDayAvailable = false;
    isPastWeek = false;
    isCircuit = false;
    isLastExercise = false;
    settingLoader = false;
    isOnMonthPage = false;
    selectedWeekDate = DateTime.now();
    todayTitleId = "";
    currentDayTitleId = "";
    circuitIndex = "";
    circuitsIndex = 0;
    streak = 0;
    selectedSection = 0;
    scrollToRestDay = false;
    startTime = null;
    endTime = null;
    week = null;
    actualWeek = null;
    day = null;
    currentWeek = 0;
    overviewCurrentDay = 0;
    overviewCurrentWeek = 0;
    splitType = null;
    equipmentType = "A";
    monthDataModel = null;
    warmUpModel = null;
    warmupId = "";
    weeksDataList = [];
    isFilterLoading = false;
    pastMonthDataModel = null;
    lastSplit = [];
    newStreakData = [];
    newLastSplit = [];
    loader = false;
    loader1 = false;
    isWarmup = false;
    relatedExercises = [];
    usedEquipments = [];

    allExercisesMainList = "";
    allFilterExercises = [];
    allExercises = [];

    selectedExIndex = 0;

    exerciseDetailModel = null;
    selectedExercise = null;

    selectedWarmUpSetTotal = 0;
    selectedBackOffSetTotal = 0;
    selectedWorkingSetTotal = 0;

    exerciseLoader = false;
    timerAddress = "";
    timePassed = "";
    currentExpandedItem = "0:0";

    expandedDataHistory;
    historyDataModel = [];
    exerciseWiseHistoryDataModel = [];
    exerciseHistoryModel = [];
    exerciseHistoryDetails;
    dayHistoryModel = [];
    allDayHistoryModel = [];
    allSplitDayHistoryModel = [];
    dayHistoryDetails;
    circuitModel = [];
    allRemovedExercise = [];
    addedExerciseList = [];
    swapExerciseList = [];
    monthLocalDataModel = [];
    reportTimeSpent = "Week 1";
    reportTimeSpentGraphHistory = [];
    reportMaximumValueOfTotalTime = 0;
    reportTimeSpentEachDay = [];
    reportWeightLifted = "Week 1";
    reportWeightLiftedGraphHistory = [];
    reportMaximumValueOfWeight = 0;
    reportWeightLiftedEachDay = [];
    totalWeightLiftedInAWeek = 0;
    reportExerciseCompletedWeek = "Week 1";
    reportAverageRIRWeek = "Week 1";
    reportExerciseCompletedGraphHistory = [];
    reportAverageRIRGraphHistory = [];
    reportMaximumValueOfTotalEx = 0;
    reportMaximumValueOfAverageRIR = 0;
    reportExerciseCompletedEachDay = [];
    reportAverageRIREachDay = [];
    totalExerciseCompletedInAWeek = 0;
    averageRIRInAWeek = 0;
    // graphHistory = [];
    // maximumValueOfWeight = 0;
    // maximumValueOfTotalEx = 0;
    // maximumValueOfTotalTime = 0;
    // liftedWeightEachDay = [];
    notifyListeners();
  }

  /// PAST MONTH DATA ===============================================================================================
  int currentMonthIndex = 0;
  String isCurrentMonth = "Current";
  int weekExpandedHeight = 0;
  bool openWeek = false;

  updateOpenWeek(bool value) {
    openWeek = value;
    notifyListeners();
  }

  updateIsCurrentMonth(String value) {
    isCurrentMonth = value;
    notifyListeners();
  }

  updateCurrentMonthIndex(int index) {
    currentMonthIndex = index;
    notifyListeners();
  }

  updateWeekExpandedHeight(int weekHeight, int weekIndex) {
    if (weekHeight < 0) {
      weekHeight = 0;
    }

    weekExpandedHeight = weekHeight;
    notifyListeners();
  }

  List<Map<String, dynamic>> pastMonthDataList = [];

  bool switchMonthLoader = false;

  fetchPastMonth(MonthResponseModel monthData, BuildContext context) async {
    switchMonthLoader = true;
    notifyListeners();

    String id = preferences.getString(SharedPreference.monthId) ?? "";
    int index =
        monthLocalDataModel.indexWhere((element) => element.monthId == id);
    updateIsCurrentMonth(index == currentMonthIndex
        ? "Current"
        : index > currentMonthIndex
            ? "Future"
            : "Past");
    if (isCurrentMonth == "Current") {
      updateWeekExpandedHeight(-1, -1);
      await onInit(context: context, isEnabled: true);
      await Future.delayed(Duration(milliseconds: 700));
      switchMonthLoader = false;
      notifyListeners();
    } else {
      updateWeekExpandedHeight(-1, -1);
      await fetchMonthWorkout(
        DateTime.parse(monthData.monthStartDate ?? "")
            .add(Duration(days: 14))
            .toUtc()
            .toString(),
        context,
        monthData,
      );

      notifyListeners();
    }
  }

  Future fetchMonthWorkout(
      String date, BuildContext context, MonthResponseModel monthData) async {
    try {
      final Map<String, String> queryParams = {
        'month': '0',
        'equipment': '0',
        'split': '',
        'date': date
      };
      Uri url = Uri.parse('${AppConstants.serverUrl}/api/workouts/current');
      String? userIdToken = await getAuthToken();
      final response = await http.post(
        url,
        body: queryParams,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'AUTH_TOKEN': userIdToken ?? ""
        },
      );
      if (response.statusCode == 200) {
        if (context.mounted) {
          await getMonthInfoFromJson(
              responseData: jsonDecode(response.body), context, monthData);
        }
      }
    } catch (e) {
      log("issue in month view loading=> $e");
    }
  }

  Future<void> getMonthInfoFromJson(context, month,
      {Map<String, dynamic>? responseData}) async {
    try {
      List<MonthDataModel> monthData = [];

      if (responseData != null) {
        MonthDataModel monthDataModelSplit3 =
            MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit4 =
            MonthDataModel.fromJson(responseData);
        MonthDataModel monthDataModelSplit5 =
            MonthDataModel.fromJson(responseData);

        // bool val = pastMonthDataList.any(
        //   (element) => element["monthId"] == monthDataModelSplit3.id,
        // );

        // if (!val) {
        List split3 = [
          "Day 1 Workout",
          "Rest Day 1",
          "Day 2 Workout",
          "Rest Day 2",
          "Day 3 Workout",
          "Rest Day 3",
          "Rest Day 4"
        ];

        List split4 = [
          "Day 1 Workout",
          "Day 2 Workout",
          "Rest Day 1",
          "Day 3 Workout",
          "Day 4 Workout",
          "Rest Day 2",
          "Rest Day 3"
        ];

        List split5 = [
          "Day 1 Workout",
          "Day 2 Workout",
          "Day 3 Workout",
          "Day 4 Workout",
          "Day 5 Workout",
          "Rest Day 1",
          "Rest Day 2"
        ];

        monthDataModelSplit3.weeks?.forEach((element) {
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
          element.restDayList = [
            "Rest Day 1",
            "Rest Day 2",
            "Rest Day 3",
            "Rest Day 4"
          ];
          element.days
              ?.removeWhere((element) => !element.formats!.contains("3"));
          for (var i = 0; i < element.days!.length; i++) {
            element.days?[i].dayType = split3[i];
          }
        });

        monthDataModelSplit4.weeks?.forEach((element) {
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
          element.days
              ?.removeWhere((element) => !element.formats!.contains("4"));
          for (var i = 0; i < element.days!.length; i++) {
            element.days?[i].dayType = split4[i];
          }
        });

        monthDataModelSplit5.weeks?.forEach((element) {
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
          element.days
              ?.removeWhere((element) => !element.formats!.contains("5"));
          for (var i = 0; i < element.days!.length; i++) {
            element.days?[i].dayType = split5[i];
          }
        });

        monthData = [
          monthDataModelSplit3,
          monthDataModelSplit4,
          monthDataModelSplit5,
        ];

        pastMonthDataList
            .add({"monthId": monthDataModelSplit3.id, "monthData": monthData});

        notifyListeners();

        if (isCurrentMonth != "Current") {
          List<HistoryDataModel> monthExerciseHistoryStatus = [];
          final exerciseHistoryLocal = await DatabaseHelper().getDataByM(
              tableName: DatabaseHelper.exerciseHistory,
              monthId: monthDataModel?.id ?? "");
          List<ExerciseHistoryDataModel> exerciseHistroy =
              await ApiRepo.fetchExerciseHistory(monthDataModelSplit3.id ?? "");
          if (exerciseHistroy.isNotEmpty) {
            monthExerciseHistoryStatus = List<HistoryDataModel>.from(json
                .decode(jsonEncode(exerciseHistoryLocal))
                .map((x) => HistoryDataModel.fromJson(x)));

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

              HistoryDataModel matchingElement =
                  monthExerciseHistoryStatus.firstWhere(
                (el1) => element.dataId == el1.dataId,
                orElse: () => HistoryDataModel(),
              );

              if (matchingElement.id != null) {
                await DatabaseHelper().insertData(
                    data: body, tableName: DatabaseHelper.exerciseHistory);
              }
            }
          }

          List<ExerciseHistoryModel> monthExerciseStatus = [];
          final exerciseStatusLocal = await DatabaseHelper().getDataByM(
              tableName: DatabaseHelper.exerciseStatus,
              monthId: monthDataModel?.id ?? "");
          List<ExerciseStatusDataModel> exerciseStatus =
              await ApiRepo.fetchExerciseStatus(monthDataModelSplit3.id ?? "");
          if (exerciseStatus.isNotEmpty) {
            monthExerciseStatus = List<ExerciseHistoryModel>.from(json
                .decode(jsonEncode(exerciseStatusLocal))
                .map((x) => ExerciseHistoryModel.fromJson(x)));

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
              ExerciseHistoryModel matchingElement =
                  monthExerciseStatus.firstWhere(
                (el1) => element.dataId == el1.dataId,
                orElse: () => ExerciseHistoryModel(),
              );
              if (matchingElement.id != null) {
                await DatabaseHelper().insertData(
                    data: body, tableName: DatabaseHelper.exerciseStatus);
              }
            }
          }

          await onInitPastMonth(context, month);

          switchMonthLoader = false;
          notifyListeners();

          List<RemovedExerciseModel> monthRemovedExercise = [];
          final removedExerciseLocal = await DatabaseHelper().getDataByM(
              tableName: DatabaseHelper.removedExerciseHistory,
              monthId: monthDataModel?.id ?? "");

          List<RemovedExerciseDataModel> removedExercise =
              await ApiRepo.fetchRemovedExercise(monthDataModelSplit3.id ?? "");
          if (removedExercise.isNotEmpty) {
            monthRemovedExercise = List<RemovedExerciseModel>.from(json
                .decode(jsonEncode(removedExerciseLocal))
                .map((x) => RemovedExerciseModel.fromJson(x)));

            for (var element in removedExercise) {
              final body = {
                "exerciseId": element.exerciseId ?? "",
                "dataId": element.dataId ?? "",
                "split": element.split ?? "",
                "monthId": element.monthId ?? "",
                "weekId": element.weekId ?? "",
                "dayId": element.dataId ?? "",
              };

              RemovedExerciseModel matchingElement =
                  monthRemovedExercise.firstWhere(
                (el1) => element.dataId == el1.dataId,
                orElse: () => RemovedExerciseModel(),
              );
              if (matchingElement.id != null) {
                await DatabaseHelper().insertData(
                    data: body,
                    tableName: DatabaseHelper.removedExerciseHistory);
              }
            }
          }

          List<ExtraExerciseModel> monthExtraExercise = [];
          final extraExerciseLocal = await DatabaseHelper().getDataByM(
              tableName: DatabaseHelper.extraExerciseHistory,
              monthId: monthDataModel?.id ?? "");

          List<ExtraExerciseDataModel> extraExercise =
              await ApiRepo.fetchExtraExercise(monthDataModelSplit3.id ?? "");
          if (extraExercise.isNotEmpty) {
            monthExtraExercise = List<ExtraExerciseModel>.from(json
                .decode(jsonEncode(extraExerciseLocal))
                .map((x) => ExtraExerciseModel.fromJson(x)));

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

              ExtraExerciseModel matchingElement =
                  monthExtraExercise.firstWhere(
                (el1) => element.dataId == el1.dataId,
                orElse: () => ExtraExerciseModel(),
              );
              if (matchingElement.id != null) {
                await DatabaseHelper().insertData(
                    data: body, tableName: DatabaseHelper.extraExerciseHistory);
              }
            }
          }

          List<SwapExerciseModel> monthSwapExercise = [];
          final swapExerciseLocal = await DatabaseHelper().getDataByM(
              tableName: DatabaseHelper.swapExerciseHistory,
              monthId: monthDataModel?.id ?? "");

          List<SwapExerciseDataModel> swapExercise =
              await ApiRepo.fetchSwapExercise(monthDataModelSplit3.id ?? "");
          if (swapExercise.isNotEmpty) {
            monthSwapExercise = List<SwapExerciseModel>.from(json
                .decode(jsonEncode(swapExerciseLocal))
                .map((x) => SwapExerciseModel.fromJson(x)));

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

              SwapExerciseModel matchingElement = monthSwapExercise.firstWhere(
                (el1) => element.dataId == el1.dataId,
                orElse: () => SwapExerciseModel(),
              );
              if (matchingElement.id != null) {
                await DatabaseHelper().insertData(
                    data: body, tableName: DatabaseHelper.swapExerciseHistory);
              }
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      log("issue in month view loading=> $e");
    } finally {
      switchMonthLoader = false;
      notifyListeners();
    }
  }

  Future<void> onInitPastMonth(context, MonthResponseModel monthData) async {
    try {
      userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      notifyListeners();
      String split = (preferences.getString(SharedPreference.split) ?? "")
          .replaceAll("split", "");
      await changeDaySplit(split);
      splitType ??= SplitType.split3;

      await fetchAllRemovedExerciseLocalData();

      await getSplitDataPastMonth(monthData).then(
        (value) async {
          try {
            if (monthDataModel != null) {
              final processedUrl = (monthDataModel?.thumbnail ?? "")
                      .startsWith('https://storage.cloud.google.com/')
                  ? (monthDataModel?.thumbnail ?? "").replaceFirst(
                      'https://storage.cloud.google.com/',
                      'https://storage.googleapis.com/')
                  : (monthDataModel?.thumbnail ?? "");
              try {
                final file =
                    await CustomCacheManager().getSingleFile(processedUrl);
                monthTitleImage = FileImage(file);
              } catch (e) {
                debugPrint("Image cache failed : $e");
              }
              notifyListeners();
              DateTime today = DateTime.now();
              startTime = Utils.formattedDate(
                  "${monthDataModel?.startDate ?? DateTime.now().toUtc()}");
              endTime = Utils.formattedDate(
                  "${monthDataModel?.endDate ?? DateTime.now().toUtc()}");
              int dayDelta = DateTime(today.year, today.month, today.day)
                  .difference(DateTime(
                      startTime!.year, startTime!.month, startTime!.day))
                  .inDays;

              actualWeek = (dayDelta ~/ 7) + 1;
              week = actualWeek! > 4 ? 4 : actualWeek;
              week = (week ?? 0) > 0 ? week! : 0;
              day = dayDelta % 7 + 1;
              currentWeek = (week ?? 0) > 0 ? week! : 0;

              await fetchMonthLocalData();
              await fetchAllDayStatusLocalData();

              await filterWorkouts();
              await updateLocalData();
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
      notifyListeners();
    }
  }

  Future<void> getSplitDataPastMonth(MonthResponseModel monthData) async {
    monthDataModel = null;

    try {
      final data = pastMonthDataList
          .where((element) => element["monthId"] == monthData.monthId);

      if (data.isNotEmpty) {
        monthDataModel = data.first["monthData"][splitType == SplitType.split3
            ? 0
            : splitType == SplitType.split4
                ? 1
                : 2];
        weeksDataList = monthDataModel!.weeks!;
      }

      if (isCurrentMonth == "Past") {
        weekStatusesString = ["P", "P", "P", "P"];
      } else if (isCurrentMonth == "Future") {
        weekStatusesString = ["F", "F", "F", "F"];
      }

      notifyListeners();
      findSplitTypeList();

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Error in getSplitData: $e");
      debugPrint("StackTrace: $stackTrace");
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
