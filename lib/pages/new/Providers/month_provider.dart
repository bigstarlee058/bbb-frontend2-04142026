import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/pages/new/Month/Database/month_prefrence.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/circuit_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/day_history_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/excersie_detail_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/exercise_history_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/history_data_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/month_response_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/pump_day_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/removed_exercise_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/rest_day_model.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/warm_up_model.dart';
import 'package:bbb/pages/new/Month/database/month_database.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../values/app_constants.dart';

enum WeekType { pastWeek, currentWeek, futureWeek }

class MonthProvider extends ChangeNotifier {
  late MainPageProvider mainPageProvider;
  DayDataModel? dayDataModel;
  WeekDataModel? weekDataModel;
  List<WeekType> weekStatuses = [];
  List<RestDayModel> restDayModel = [];
  PumpDayModel? pumpDayModel;
  String selectedButtonTitle = "Mark Complete";
  List<String> buttonTitle = ["Mark Complete", "Swap To Pump Day"];
  bool isPumpDay = false;
  bool isPumpDayAvailable = false;
  DateTime selectedWeekDate = DateTime.now();
  String todayTitleId = "";
  bool isPastWeek = false;
  bool isCircuit = false;
  String circuitIndex = "";
  int circuitsIndex = 0;
  int streak = 0;

  updateCircuit(String val, int index) {
    circuitIndex = val;
    circuitsIndex = index;
    notifyListeners();
  }

  updateIsCircuit(bool val) {
    isCircuit = val;
    notifyListeners();
  }

  updateIsPastWeek(bool val) {
    isPastWeek = val;
    notifyListeners();
  }

  changeValue(List<String> val1, String val2) {
    buttonTitle = val1;
    selectedButtonTitle = val2;
    notifyListeners();
  }

  changeSelectedButtonTitle(String val2) {
    selectedButtonTitle = val2;
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

  setInitialPumpDayValues() {
    selectedButtonTitle = "Mark Complete";
    buttonTitle = ["Mark Complete", "Swap To Pump Day"];
    isPumpDay = false;
    isPumpDayAvailable = false;
  }

  Future<void> checkForPumpDay(String title) async {
    pumpDayModel = null;
    if (title.contains("Rest Day")) {
      final dataList = dayHistoryModel.where((element) => element.type!.contains("Pump Day"));
      if (dataList.isNotEmpty) {
        String dataId = "$splitType-${monthDataModel?.id}-${weekDataModel?.id}-${weekDataModel?.idList![overviewCurrentDay - 1]}";
        for (var element in dataList) {
          if (element.dataId == dataId) {
            changeIsPumpDay(true);
            await pumpDayData(element.type!.split("- ").last, title);
          }
        }
      }
      if (pumpDayModel == null) {
        checkPumpDayAvail();
      }
      if (isPumpDayAvailable) pumpDayData("", title);
    }
  }

  checkPumpDayAvail() async {
    final dataList = dayHistoryModel.where((element) => element.type!.contains("Pump Day"));
    changeIsPumpDay(false);
    if (dataList.length < 2 || dataList.isEmpty) {
      changeIsPumpDayAvail(true);
    } else {
      changeIsPumpDayAvail(false);
    }
  }

  pumpDayData(String id, String title) async {
    if (id == "") {
      int restDayIndex = int.parse(title.split(" ").last);
      int index = (restDayIndex - 1) % 2;
      if (monthDataModel!.weeks?[currentWeek - 1].pumpDayIds?.length == 1) {
        id = monthDataModel!.weeks![currentWeek - 1].pumpDayIds![0];
      } else {
        id = monthDataModel!.weeks![currentWeek - 1].pumpDayIds![index];
      }
    }
    await fetchPumpDayData(id);
  }

  /// MAIN SCREEN =============================++++++++++++++++++++++++++++++++++

  DateTime today = DateTime.now();
  DateTime? startTime;
  DateTime? endTime;

  int? week;
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

  fetchToday() async {
    todayTitleId = "";
    for (var element in monthDataModel!.weeks![week! - 1].idList!) {
      bool? value = allDayHistoryModel.any((ele1) =>
          "${ele1.split}-${ele1.monthId}-${ele1.weekId}-$element" == ele1.dataId &&
          ele1.weekId == monthDataModel!.weeks?[week! - 1].id &&
          (ele1.status == "Completed" || ele1.status == "Skipped"));
      if (value == false) {
        todayTitleId = element;
        await preferences.putString(SharedPreference.todayTitleId, todayTitleId);
        notifyListeners();
        break;
      }
    }
  }

  Future<RestDayModel> fetchRestDay(String id) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/restdays/get/$id');
    url = Uri.http(url.authority, url.path);
    String? userIdToken = await getAuthToken();

    final response = await http.get(
      url,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'AUTH_TOKEN': userIdToken ?? ""},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      RestDayModel restDayModel = RestDayModel.fromJson(responseData);
      return restDayModel;
    } else {
      throw Exception('Failed to load fetchWarmUp');
    }
  }

  void findWeekStatuses() {
    weekStatuses = [];
    final fixedStartDate = DateTime(startTime!.year, startTime!.month, startTime!.day);
    final fixedEndDate = DateTime(endTime!.year, endTime!.month, endTime!.day);

    const totalWeeks = 4;

    for (int weekNumber = 1; weekNumber <= totalWeeks; weekNumber++) {
      final weekStartForSelected = fixedStartDate.add(Duration(days: (weekNumber - 1) * 7));
      final weekEndForSelected = weekStartForSelected.add(const Duration(days: 6)); // 7 days total for each week

      final secondDay = weekStartForSelected.add(const Duration(days: 1));
      selectedWeekDate = secondDay;

      final currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      WeekType? weekType;
      if (currentDate.isBefore(weekStartForSelected)) {
        weekType = WeekType.futureWeek;
      } else if (currentDate.isAfter(weekEndForSelected)) {
        weekType = WeekType.pastWeek;
      } else if (currentDate.isAfter(fixedEndDate)) {
        weekType = WeekType.pastWeek;
      } else {
        weekType = WeekType.currentWeek;
      }

      weekStatuses.add(weekType);
    }

    log('All Week Statuses: $weekStatuses');
    notifyListeners();
  }

  Future<void> onInit() async {
    String split = (preferences.getString(SharedPreference.split) ?? "").replaceAll("split", "");
    await changeDaySplit(split);
    splitType ??= SplitType.split3;
    await fetchAllRemovedExerciseLocalData();
    await getSplitData().then(
      (value) async {
        filter();
        startTime = monthDataModel?.startDate ?? DateTime.now();
        endTime = monthDataModel?.endDate ?? DateTime.now();
        await fetchMonthLocalData();
        await fetchAllDayStatusLocalData();
        manageStreak();
        int dayDelta = today.difference(startTime!).inDays;
        week = (dayDelta ~/ 7) + 1;
        currentWeek = week!;
        day = dayDelta % 7 + 1;
        findWeekStatuses();
        fetchToday();
      },
    );

    notifyListeners();
  }

  Future<void> fetchWarmUp(String warmUpId) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/warmups/get/$warmUpId');
    url = Uri.http(url.authority, url.path);
    String? userIdToken = await getAuthToken();
    final response = await http.get(
      url,
      headers: <String, String>{
        'AUTH_TOKEN': userIdToken ?? "",
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      if (responseData != null) {
        warmUpModel = WarmUpModel.fromJson(jsonDecode(response.body));
      }

      notifyListeners();
    } else {
      throw Exception('Failed to load fetchWarmUp');
    }
  }

  Future<void> fetchPumpDayData(String id) async {
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
        pumpDayModel = PumpDayModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch Circuits data');
      }
    } catch (e) {
      throw Exception('Failed to fetch Circuits data');
    }
    notifyListeners();
  }

  Future<void> getSplitData() async {
    monthDataModel = null;
    weeksDataList = [];
    String monthId = preferences.getString(SharedPreference.monthId) ?? "";
    String split = preferences.getString(SharedPreference.split) ?? "";

    final rawTempData = preferences.getString("$split-$monthId");

    final rawTempData1 = preferences.getString("REST-$monthId");
    if (rawTempData!.isNotEmpty) {
      monthDataModel = MonthDataModel.fromJson(jsonDecode(rawTempData.toString()));
      weeksDataList = monthDataModel!.weeks!;
    }

    if (rawTempData1!.isNotEmpty) {
      restDayModel = List<RestDayModel>.from(json.decode(rawTempData1).map((x) => RestDayModel.fromJson(x)));
    }

    notifyListeners();
  }

  Future<void> changeDaySplit(String value) async {
    if (value == "3" || value.isEmpty) {
      splitType = SplitType.split3;
    } else if (value == "4") {
      splitType = SplitType.split4;
    } else {
      splitType = SplitType.split5;
    }

    await preferences.putString(SharedPreference.split, "split${value.isEmpty ? "3" : value}");
    notifyListeners();
  }

  void changeEquipmentType(String value) async {
    equipmentType = value;
    notifyListeners();
  }

  Future<void> filterWorkouts() async {
    isFilterLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
    await getSplitData();
    filter();
    isFilterLoading = false;
    notifyListeners();
  }

  void filter() {
    List<ExerciseDataModel> itemsToRemove = [];
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
  }

  void innerFilter() {
    isFilterLoading = true;
    notifyListeners();
    List<ExerciseDataModel> itemsToRemove = [];
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
    isFilterLoading = false;
    notifyListeners();
  }

  /// EXCERSIE =============================++++++++++++++++++++++++++++++++++

  bool isWarmup = false;

  List<RelatedExercises> relatedExercises = [];
  List<UsedEquipments> usedEquipments = [];

  int selectedExIndex = 0;

  ExerciseDetailModel? exerciseDetailModel;
  ExerciseDataModel? selectedExercise;

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
        log('response.body==========>>>>>${response.body}');
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
    relatedExercises = [];
    if (responseData != null) {
      exerciseDetailModel = ExerciseDetailModel.fromJson(responseData);
      usedEquipments.addAll(exerciseDetailModel!.usedEquipments!);
      relatedExercises.addAll(exerciseDetailModel!.relatedExercises!);
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

  updateExpandedItem(String value) {
    currentExpandedItem = value;
    notifyListeners();
  }

  Future<String> getPassedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timePassed = prefs.getString("passedTime") ?? "0";

    DateTime data = DateTime.parse(prefs.getString("timeWhenExitScreen") ?? DateTime.now().toString());
    var difference = DateTime.now().difference(data);
    bool val = prefs.getBool("isPause") ?? false;
    log("getPassedTime >>>> $timePassed");
    if (timePassed != "") {
      if (val) {
        int totalTimePassed = int.parse(timePassed);
        timePassed = totalTimePassed.toString();
      } else {
        int totalTimePassed = int.parse(timePassed) + difference.inSeconds;
        timePassed = totalTimePassed.toString();
      }
    }

    notifyListeners();

    return timePassed;
  }

  fetchTimerAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await getPassedTime();
    timerAddress = preferences.getString("timerRunningAddress") ?? "";

    if (timerAddress.isNotEmpty) {
      var data = timerAddress.split("-");
      if (data.isNotEmpty && data[0] != "-1") {
        updateExpandedItem("${data[0]}:${data[1]}");
      } else {
        updateExpandedItem("0:0");
      }
    }
    notifyListeners();
  }

  void setShowTimerIndex(int index, int subIndex, int exerciseIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (index != -1 && subIndex != -1 && exerciseIndex != -1) {
      await prefs.setString("timerRunningAddress", "$index-$subIndex-$exerciseIndex");
      timerAddress = "$index-$subIndex-$exerciseIndex";
    } else {
      NotificationService.clearNotification();
      await prefs.setString("timerRunningAddress", "");
      prefs.setString("passedTime", "");
      timerAddress = "";
      timePassed = "";
    }
    notifyListeners();

    // showTimerIndex = index;
    // notifyListeners();
  }

  void savePassedTime(String timePassed1, int totalTime, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (timerAddress != '') {
      timePassed = timePassed1;
      int newTime = totalTime - int.parse(timePassed);
      if (newTime.isNegative || newTime == 0) {
      } else {
        NotificationService.zonedScheduleNotification(
            newTime, selectedExIndex, {'name': selectedExercise?.name.toString(), 'id': selectedExIndex, 'context': context});
      }
    }
    notifyListeners();

    await prefs.setString("passedTime", timePassed);
    await prefs.setString("timeWhenExitScreen", DateTime.now().toString());
  }

  /// STREAK COUNT =============================++++++++++++++++++++++++++++++++++

  manageStreak() async {
    List<DayHistoryModel> data = decodedData();
    log('data :::::::::::::::::: ${jsonEncode(data)}');
    streak = 0;
    DateTime? pastDate;

    for (var element in data) {
      DateTime currentDate = element.endTime!;
      if (pastDate != null) {
        int difference = pastDate.difference(currentDate).inDays;
        if (difference > 1) {
          break;
        }
      }
      if (element.status == 'Completed') {
        streak++;
      } else {
        break;
      }
      pastDate = currentDate;
    }
    await preferences.putInt(SharedPreference.lastStreakCount, streak);
    notifyListeners();
  }

  List<DayHistoryModel> decodedData() {
    String encodedTempData = jsonEncode(allDayHistoryModel);
    final decodedData = List<DayHistoryModel>.from(json.decode(encodedTempData).map((x) => DayHistoryModel.fromJson(x)));
    decodedData.removeWhere((element) => element.status == "" || element.status == "Started");
    decodedData.sort((a, b) => b.endTime!.compareTo(a.endTime!));
    Map<String, Map<String, dynamic>> latestByDay = {};
    for (var entry in decodedData) {
      String dayKey = entry.endTime.toString().substring(0, 10);
      DateTime dateTime = entry.endTime!;
      if (!latestByDay.containsKey(dayKey) || DateTime.parse(latestByDay[dayKey]!['date']).isBefore(dateTime)) {
        latestByDay[dayKey] = entry.toJson();
      }
    }
    decodedData.removeWhere((entry) {
      String dayKey = entry.endTime.toString().substring(0, 10);
      return latestByDay[dayKey]!['id'] != entry.id;
    });
    return decodedData;
  }

  /// LOCAL DATA =============================++++++++++++++++++++++++++++++++++

  HistoryDataModel? expandedDataHistory;

  fetchExerciseSingleSetLocalData(dataId) async {
    final data = await DatabaseHelper().getDataById(tableName: DatabaseHelper.exerciseHistory, id: dataId);
    if (data != null) {
      expandedDataHistory = HistoryDataModel.fromJson(data);
    } else {
      expandedDataHistory = null;
    }
    notifyListeners();
  }

  List<HistoryDataModel> historyDataModel = [];

  fetchExerciseHistoryLocalData() async {
    historyDataModel = [];
    final data = await DatabaseHelper().getFilteredWithExerciseData(
      split: splitType!,
      tableName: DatabaseHelper.exerciseHistory,
      exerciseId: "${exerciseDetailModel?.sId}",
      monthId: monthDataModel?.id ?? "",
      dayId: weekDataModel?.idList![overviewCurrentDay - 1] ?? "",
      weekId: weekDataModel?.id ?? "",
    );
    if (data.isNotEmpty) {
      historyDataModel = List<HistoryDataModel>.from(json.decode(jsonEncode(data)).map((x) => HistoryDataModel.fromJson(x)));
      return historyDataModel;
    }
  }

  List<ExerciseHistoryModel> exerciseHistoryModel = [];

  fetchExerciseStatusLocalData() async {
    final data = await DatabaseHelper().getFilteredWithMWDData(
      split: splitType!,
      tableName: DatabaseHelper.exerciseStatus,
      monthId: monthDataModel?.id ?? "",
      dayId: weekDataModel?.idList![overviewCurrentDay - 1] ?? "",
      weekId: weekDataModel?.id ?? "",
    );

    if (data.isNotEmpty) {
      exerciseHistoryModel = List<ExerciseHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => ExerciseHistoryModel.fromJson(x)));
    } else {
      exerciseHistoryModel = [];
    }
    notifyListeners();
  }

  ExerciseHistoryModel? exerciseHistoryDetails;

  fetchExerciseSingleExerciseLocalData(dataId) async {
    exerciseHistoryDetails = null;
    final data = await DatabaseHelper().getDataById(tableName: DatabaseHelper.exerciseStatus, id: dataId);
    if (data != null) {
      exerciseHistoryDetails = ExerciseHistoryModel.fromJson(data);
    } else {
      exerciseHistoryDetails = null;
    }
    notifyListeners();
  }

  List<DayHistoryModel> dayHistoryModel = [];

  fetchDayStatusLocalData() async {
    dayHistoryModel = [];
    final data = await DatabaseHelper().getFilteredWithMWData(
      split: splitType!,
      tableName: DatabaseHelper.dayStatus,
      monthId: monthDataModel?.id ?? "",
      weekId: weekDataModel?.id ?? "",
    );
    if (data.isNotEmpty) {
      dayHistoryModel = List<DayHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => DayHistoryModel.fromJson(x)));
    } else {
      dayHistoryModel = [];
    }
    notifyListeners();
  }

  List<DayHistoryModel> allDayHistoryModel = [];

  fetchAllDayStatusLocalData() async {
    allDayHistoryModel = [];
    final data = await DatabaseHelper().getFilteredWithMData(
      split: splitType!,
      tableName: DatabaseHelper.dayStatus,
      monthId: monthDataModel?.id ?? "",
    );
    if (data.isNotEmpty) {
      allDayHistoryModel = List<DayHistoryModel>.from(json.decode(jsonEncode(data)).map((x) => DayHistoryModel.fromJson(x)));
    } else {
      allDayHistoryModel = [];
    }
    notifyListeners();
  }

  DayHistoryModel? dayHistoryDetails;

  fetchSingleDayHistoryLocalData() async {
    if (overviewCurrentDay == 0) {
      return null;
    }

    dayHistoryDetails = null;
    String dataId =
        "$splitType-${monthDataModel?.id}-${weekDataModel?.id ?? monthDataModel?.weeks?[(overviewCurrentWeek) - 1].id}-${monthDataModel?.weeks?[(overviewCurrentWeek) - 1].idList?[overviewCurrentDay - 1] ?? ""}";

    final data = await DatabaseHelper().getDataById(tableName: DatabaseHelper.dayStatus, id: dataId);
    if (data != null) {
      dayHistoryDetails = DayHistoryModel.fromJson(data);
    } else {
      dayHistoryDetails = null;
    }
    notifyListeners();
  }

  List<CircuitModel> circuitModel = [];

  fetchCircuitModelLocalData() async {
    circuitModel = [];
    final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.circuitManager);
    if (data.isNotEmpty) {
      circuitModel = List<CircuitModel>.from(json.decode(jsonEncode(data)).map((x) => CircuitModel.fromJson(x)));
    } else {
      circuitModel = [];
    }
    notifyListeners();
  }

  List<RemovedExerciseModel> allRemovedExercise = [];

  fetchAllRemovedExerciseLocalData() async {
    final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.removedExerciseHistory);
    if (data.isNotEmpty) {
      allRemovedExercise = List<RemovedExerciseModel>.from(json.decode(jsonEncode(data)).map((x) => RemovedExerciseModel.fromJson(x)));
    } else {
      allRemovedExercise = [];
    }
    notifyListeners();
  }

  List<MonthResponseModel> monthLocalDataModel = [];

  fetchMonthLocalData() async {
    final data = await DatabaseHelper().fetchData(tableName: DatabaseHelper.monthHistory);
    log('data :::::::11::::::::::: ${jsonEncode(data)}');
    if (data.isNotEmpty) {
      monthLocalDataModel = List<MonthResponseModel>.from(json.decode(jsonEncode(data)).map((x) => MonthResponseModel.fromJson(x)));
    } else {
      monthLocalDataModel = [];
    }
    notifyListeners();
  }
}
