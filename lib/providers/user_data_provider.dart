import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/models/day.dart';
import 'package:bbb/models/dayexercise.dart';
import 'package:bbb/models/equipment.dart';
import 'package:bbb/models/restday.dart';
import 'package:bbb/models/warmup.dart';
import 'package:bbb/storage/notes_manager.dart';
import 'package:bbb/storage/userdata_manager.dart';
import 'package:bbb/utils/custom_prints.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../middleware/notification_service.dart';
import '../models/exercise.dart';

class UserDataProvider extends ChangeNotifier {
  String selectedExerciseFormat = "A";
  String selectedExerciseFormatAlternate = "A";
  String selectedDaySplit = "3";
  String currentDayTitle = "3";
  int currentMonth = 1;
  int currentWeek = 1;
  int currentDay = 1;
  int currentTrackDay = 1;
  int currentExIndex = 1;
  int showTimerIndex = -1;
  int totalCompletedDays = -1;
  int completedDay = 0;
  // int currentStreak = 0;
  int nextDayIndex = 1; // To show primary color circle in current week
  bool isRestDay = false;
  int previousPage = 1;
  late Day currentDayObj;
  WarmUp currentWarmup = WarmUp(id: '', title: '', vimeoId: '', description: '', equipments: [], files: [], length: 0, thumbnail: "");
  RestDay currentRestDay = RestDay(id: '', title: '', description: '', vimeoId: '', equipments: []);
  DayExercise currentExercise = DayExercise(
      id: "", id_: "", typeId: 0, name: "", guide: "", sets: 0, reps: 0, rest: 0, weight: 0, duration: "", formats: [], extra: [] //new
      );
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
  late List<Exercise> allFilterExercises = [];
  late List<Exercise> allExercises = [];
  List<dynamic> dayHistory = [];
  List<dynamic> exerciseHistory = [];
  List<dynamic> notesData = [];
  List<dynamic> exerciseData = [];
  List<Map<String, dynamic>> dailyExercises = [];

  bool isWeekCompleted = false;
  List<String> completedExerciseIds = [];

  String userId = "";
  String userName = "";
  String userEmail = "";

  var userData;
  bool isEditExercise = false;
  UserDataManager userManager = UserDataManager();
  NotesManager notesDataManager = NotesManager();

  List<Map<String, dynamic>> _historyData = []; //ExerciseHistory

  List<Map<String, dynamic>> get historyData => _historyData;

  int normalSetReps = 5;
  int normalSetWeight = 5;
  int normalSetRest = 0;

  List streaksData = [];
  List streaksDataCalender = [];

  int streakCount = 0;

  String currentExpandedItem = "0:0";

  updateExpandedItem(String value) {
    currentExpandedItem = value;
    notifyListeners();
  }

  List<String> currentWeekDayTitle = [];
  String compareDaySplit = "3";

  void saveDayTitles(List<String> data) {
    currentWeekDayTitle = data;
    compareDaySplit = selectedDaySplit;
    notifyListeners();
  }

  void updateDayTitles(String title, int id) {
    currentWeekDayTitle[id] = title;
    notifyListeners();
  }

  void setCurrentDayTitle(String title) {
    currentDayTitle = title;
    notifyListeners();
  }

  getStreaksData(String date) async {
    streaksData = [];
    streaksDataCalender = [];

    streakCount = 0;

    print("getStreaksData $date");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tempData = prefs.getString("streaksData");

    // Parse existing streaks data if available
    if (tempData != null) {
      streaksData = jsonDecode(tempData);
    }
    log('tempData :::::::::::::::::: $tempData');
    DateTime startDate = DateTime.now();
    DateTime todayDate = DateTime.now();

    // If data exists, find the last recorded date; otherwise, use the start date
    if (streaksData.isNotEmpty) {
      String lastRecordedDate = streaksData.last["date"];
      startDate = DateTime.parse(lastRecordedDate).add(const Duration(days: 1));
    } else {
      startDate = DateTime.parse(date);
    }

    // Get the last Sunday before the current week
    DateTime lastSunday = todayDate.subtract(Duration(days: todayDate.weekday));

    // Add missing days to streaksData
    for (DateTime currentDate = startDate;
        currentDate.isBefore(lastSunday) || currentDate.isAtSameMomentAs(lastSunday);
        currentDate = currentDate.add(const Duration(days: 1))) {
      // Only add dates that don't already exist
      bool dateExists = streaksData.any((entry) => entry["date"] == currentDate.toString());
      if (!dateExists) {
        streaksData.add({
          "date": currentDate.toString(),
          "status": "skipped",
          "selectedDaySplit": 3,
        });
      }
    }
    var data = streaksData.reversed.toList();

    log('data ::::::f:::::::::::: $data');
    var groupedItems = groupByDate(data);

    // Print grouped items
    for (var group in groupedItems) {
      log('group :::::::::::::::::: $group');

      streaksDataCalender.add(group.first);
    }
    for (var group in groupedItems) {
      log('group :::::::::::::::::: $group');

      if (group.first['status'] == "finished") {
        streakCount++;
      } else {
        break;
      }
    }
    // streakCount = streaksData.where(() => entry["status"] == "finished").length;
    log('streaksDataCalender :::::::::::::::::: $streaksDataCalender');
    log("streaksData ${jsonEncode(streaksData)}");
  }

  List<List<Map<String, dynamic>>> groupByDate(List<dynamic> items) {
    List<List<Map<String, dynamic>>> groupedLists = [];
    List<String> addedDates = [];

    for (var item in items) {
      DateTime date = DateTime.parse(item['date']);
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      int existingGroupIndex = addedDates.indexOf(dateKey);
      if (existingGroupIndex != -1) {
        groupedLists[existingGroupIndex].add(item);
      } else {
        groupedLists.add([item]);
        addedDates.add(dateKey);
      }
    }

    return groupedLists;
  }

  void addStreaks(String state) async {
    log('state :::::::::::::::::: $state');
    log("CALLED");
    streakCount = 0;
    streaksDataCalender = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      "date": DateTime.now().toString(),
      "status": state,
      "selectedDaySplit": selectedDaySplit,
      "day": currentDay,
    };
    if (state == AppConstants.STATE_SKIPPED || state == AppConstants.STATE_FINISHED) {
      // if (state == AppConstants.STATE_FINISHED) {
      //   streakCount++;
      // } else {
      //   streakCount = 0;
      // }
      streaksData.add(data);
    } else if (state == AppConstants.STATE_NOT_STARTED) {
      int index = streaksData.indexWhere(
        (element) {
          log('element["day"] :::::::::::::::::: ${element["day"]}');
          log('DateFormat:::::::::::::::::: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(element["date"]))}  ${DateFormat('dd-MM-yyyy').format(DateTime.now())}');
          return DateFormat('dd-MM-yyyy').format(DateTime.parse(element["date"])) == DateFormat('dd-MM-yyyy').format(DateTime.now()) &&
              element["day"].toString() == currentDay.toString();
        },
      );

      log('index :::::::::::::::::: $index');
      streaksData.removeAt(index);
    }
    log('streaksData :::::::::::::::::: $streaksData');
    prefs.setString("streaksData", jsonEncode(streaksData));

    var data1 = streaksData.reversed.toList();

    log('data :::::w2::::::::::::: $data');
    var groupedItems = groupByDate(data1);
    for (var group in groupedItems) {
      log('group :::::::::::::::::: $group');

      streaksDataCalender.add(group.first);
    }
    log('streaksDataCalender :::::::::::::::::: $streaksDataCalender');
    notifyListeners();
    // Print grouped items
    for (var group in groupedItems) {
      log('group :::::::::::::::::: $group');
      if (group.first['status'] == "finished") {
        streakCount++;
      } else {
        break;
      }
    }

    notifyListeners();
  }

  void saveNormalSetReps(int value) {
    normalSetReps = value;
    notifyListeners();
  }

  void saveNormalSetWeight(int value) {
    normalSetWeight = value;
    notifyListeners();
  }

  void saveNormalSetRest(int value) {
    normalSetRest = value;
    notifyListeners();
  }

  void getDaySplit() async {
    bool daySplitExists = await userManager.daySplitExists();
    if (daySplitExists) {
      selectedDaySplit = await userManager.getDaySplit();
    } else {
      selectedDaySplit = "3";
      userManager.saveDaySplit("3");
    }
  }

  void changeDaySplit(String newValue) async {
    selectedDaySplit = newValue;
    notifyListeners();
    userManager.saveDaySplit(selectedDaySplit);
  }

  String timerAddress = "";
  String timePassed = "";

  fetchTimerAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    getPassedTime();
    timerAddress = preferences.getString("timerRunningAddress") ?? "";
    var data = timerAddress.split("-");

    log('data :::::::::n::::::::: $data');
    if (data.isNotEmpty && data[0] != "-1") {
      updateExpandedItem("${data[0]}:${data[1]}");
    } else {
      updateExpandedItem("0:0");
    }
    notifyListeners();
  }

  void setShowTimerIndex(int index, int subIndex, int exerciseIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (index != -1 && subIndex != -1 && exerciseIndex != -1) {
      await prefs.setString("timerRunningAddress", "$index-$subIndex-$exerciseIndex");
      timerAddress = "$index-$subIndex-$exerciseIndex";

      log("TIMER STARTED AT $index-$subIndex-$exerciseIndex");
    } else {
      NotificationService.clearNotification();
      log("TIMER ENDED ");
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
    log('currentExIndex :::::::::::::::::: $currentExIndex');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (timerAddress != '') {
      timePassed = timePassed1;
      int newTime = totalTime - int.parse(timePassed);
      if (newTime.isNegative || newTime == 0) {
      } else {
        NotificationService.zonedScheduleNotification(
            newTime, currentExIndex, {'name': currentExercise.name.toString(), 'id': currentExIndex, 'context': context});
      }

      log('newTime :::::::::::::::::: $newTime');
    }

    ///set background notification which send notification after "newTime"

    notifyListeners();
    await prefs.setString("passedTime", timePassed);
    await prefs.setString("timeWhenExitScreen", DateTime.now().toString());
    timerAddress = "";
    timePassed = "";
  }

  Future<String> getPassedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timePassed = prefs.getString("passedTime") ?? "0";
    DateTime data = DateTime.parse(prefs.getString("timeWhenExitScreen") ?? DateTime.now().toString());

    var difference = DateTime.now().difference(data);

    log("getPassedTime $timePassed");
    if (timePassed != "") {
      int totalTimePassed = int.parse(timePassed) + difference.inSeconds;
      timePassed = totalTimePassed.toString();
    }
    notifyListeners();
    return timePassed;
  }

  void addNewNote(String newNote) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    notesData.add({
      'exercise_id': currentExercise.id,
      'date': formattedDate,
      'content': newNote,
    });
    saveNotesData();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the authToken from SharedPreferences
    String? authToken = prefs.getString('authToken');
    return authToken;
  }

  Future<void> loadNotesData() async {
    bool notesExists = await notesDataManager.notesDataExists();
    if (notesExists) {
      notesData = await notesDataManager.getNotesData();
      notifyListeners();
    }
  }

  void saveNotesData() {
    notesDataManager.saveNotesData(notesData);
    notifyListeners();
  }

  void updateCurrentExercise(DayExercise newExercise) {
    currentExercise = newExercise;
    notifyListeners();
  }

  void completeExercise(String exerciseID) {
    completedExerciseIds.add(exerciseID);
    notifyListeners();
  }

  //Here are some thing to fix.
  void completeCurrentExercise() {
    completedExerciseIds.add(currentExercise.id);
    notifyListeners();
  }

  String getCurrentDayState() {
    for (var history in dayHistory) {
      if (int.parse((history['monthIndex']).toString()) == currentMonth &&
          int.parse((history['weekIndex']).toString()) == currentWeek &&
          history['daySplit'] == selectedDaySplit &&
          history['dayIndex'] == nextDayIndex.toString()) {
        return history['state'];
      }
    }
    return AppConstants.STATE_NOT_STARTED;
  }

  void updateOrAddDayHistory(String stateString) {
    addStreaks(stateString);

    debugPrint('addStreaks==========>>>>> updateOrAddDayHistory');

    debugPrint('updateOrAddDayHistory==========>>>>>');
    // Determine the previous day and week
    int previousDay = currentDay - 1;
    int previousWeek = currentWeek;
    if (currentDay == 0) {
      previousDay = 6; // Last day of the previous week
      previousWeek -= 1;
    }

    // Find the previous day's history
    final Map<String, dynamic>? previousDayHistory = dayHistory.firstWhere(
      (history) =>
          int.parse((history['monthIndex']).toString()) == currentMonth &&
          int.parse((history['weekIndex']).toString()) == previousWeek &&
          history['daySplit'] == selectedDaySplit &&
          history['dayIndex'] == previousDay.toString() &&
          history['state'] == AppConstants.STATE_FINISHED, // State finished
      orElse: () => null, // Return null if no previous day's history is found
    );

    if (dayHistory.any((history) =>
        int.parse((history['monthIndex']).toString()) == currentMonth &&
        int.parse((history['weekIndex']).toString()) == currentWeek &&
        history['daySplit'] == selectedDaySplit &&
        history['dayIndex'] == currentDay.toString())) {
      dayHistory = dayHistory.map((history) {
        if (int.parse((history['monthIndex']).toString()) == currentMonth &&
            int.parse((history['weekIndex']).toString()) == currentWeek &&
            history['daySplit'] == selectedDaySplit &&
            history['dayIndex'] == currentDay.toString()) {
          history['state'] = stateString;

          // Check for streak increment
          if (previousDayHistory != null && stateString == AppConstants.STATE_FINISHED) {
            history['streak'] = (int.parse(history['streak']) + 1).toString();
          } else if (stateString == AppConstants.STATE_FINISHED) {
            history['streak'] = '1'; // Start a new streak
          } else {
            history['streak'] = '0'; // Reset streak if not finished
          }
        }
        return history;
      }).toList();
    } else {
      final Map<String, String> queryParams = {
        'monthIndex': currentMonth.toString(),
        'weekIndex': currentWeek.toString(),
        'daySplit': selectedDaySplit,
        'dayIndex': currentDay.toString(),
        'state': stateString,
        'streak': (previousDayHistory != null && stateString == AppConstants.STATE_FINISHED)
            ? (int.parse(previousDayHistory['streak']) + 1).toString()
            : (stateString == AppConstants.STATE_FINISHED ? '1' : '0'),
      };

      dayHistory.add(queryParams);
    }
    final currentDayHistory = dayHistory.firstWhere(
      (history) =>
          int.parse((history['monthIndex']).toString()) == currentMonth &&
          int.parse((history['weekIndex']).toString()) == currentWeek &&
          history['daySplit'] == selectedDaySplit &&
          history['dayIndex'] == currentDay.toString(),
      orElse: () => null,
    );

    // if (currentDayHistory != null) {
    //   currentStreak = int.tryParse(currentDayHistory['streak'] ?? '0') ?? 0;
    // } else {
    //   currentStreak = 0; // Default to 0 if no current day history is found
    // }
    userManager.saveDayHistory(dayHistory);
    notifyListeners();
  }

  void updateOrAddExerciseData(int exerciseIndex, int setIndex, int weight, int reps, int repsInReverse, String exerciseName) {
    debugPrint("this is updateadd exercise $setIndex ---$exerciseIndex---$exerciseName");
    var currentDate = DateTime.now();
    // if (exerciseData.any((data) =>
    //     int.parse((data['monthIndex']).toString()) == currentMonth &&
    //     int.parse((data['weekIndex']).toString()) == currentWeek &&
    //     data['daySplit'].toString() == selectedDaySplit &&
    //     data['gymAccess'].toString() == selectedExerciseFormatAlternate &&
    //     data['exerciseIndex'].toString() == exerciseIndex.toString() &&
    //     data['exerciseName'].toString() == exerciseName.toString() &&
    //     data['setIndex'].toString() == setIndex.toString() &&
    //     data['dayIndex'].toString() == currentDay.toString())) {
    //   exerciseData = exerciseData.map((data) {
    //     if (int.parse((data['monthIndex']).toString()) == currentMonth &&
    //         int.parse((data['weekIndex']).toString()) == currentWeek &&
    //         data['daySplit'].toString() == selectedDaySplit &&
    //         data['gymAccess'].toString() == selectedExerciseFormatAlternate &&
    //         data['dayIndex'].toString() == currentDay.toString() &&
    //         data['exerciseIndex'].toString() == exerciseIndex.toString() &&
    //         data['exerciseName'].toString() == exerciseName.toString() &&
    //         data['setIndex'].toString() == setIndex.toString()) {
    //       data['weight'] = weight.toString();
    //       data['reps'] = reps.toString();
    //       data['repsInReverse'] = repsInReverse.toString();
    //     }
    //     return data;
    //   }).toList();
    // } else {
    //   final Map<String, String> queryParams = {
    //     'monthIndex': currentMonth.toString(),
    //     'weekIndex': currentWeek.toString(),
    //     'daySplit': selectedDaySplit,
    //     'gymAccess': selectedExerciseFormatAlternate,
    //     'dayIndex': currentDay.toString(),
    //     'exerciseIndex': exerciseIndex.toString(),
    //     'exerciseName' : exerciseName.toString(),
    //     'setIndex': setIndex.toString(),
    //     'weight': weight.toString(),
    //     'reps': reps.toString(),
    //     'repsInReverse': repsInReverse.toString(),
    //     'date': currentDate.toString()
    //   };

    //   exerciseData.add(queryParams);
    // }
    final Map<String, String> queryParams = {
      'monthIndex': currentMonth.toString(),
      'weekIndex': currentWeek.toString(),
      'daySplit': selectedDaySplit,
      'gymAccess': selectedExerciseFormatAlternate,
      'dayIndex': currentDay.toString(),
      'exerciseIndex': exerciseIndex.toString(),
      'exerciseName': exerciseName.toString(),
      'setIndex': setIndex.toString(),
      'weight': weight.toString(),
      'reps': reps.toString(),
      'repsInReverse': repsInReverse.toString(),
      'date': currentDate.toString()
    };

    exerciseData.add(queryParams);

    userManager.saveExerciseData(exerciseData);
    notifyListeners();
  }

  void addCurrentExerciseData(int exerciseIndex, int weight, int reps) {
    final Map<String, String> queryParams = {
      'sets': "1",
      'weight': "5",
      'reps': "5",
      'rest': "300",
      'load': '0',
      'type': "3",
      '_id': "6748897a16b1b804c5faa949"
    };
    currentDayObj.exercises[exerciseIndex].extra.add(queryParams);
    notifyListeners();
  }

  Future<List<dynamic>> getExerciseData(String exerciseName, int selectedFilterIndex) async {
    List<dynamic> exerciseData = [];
    bool exerciseDataExists = await userManager.exerciseDataExists();
    if (exerciseDataExists) {
      exerciseData = await userManager.getExerciseData();
    }
    DateTime currentDate = DateTime.now();
    DateTime startDate;
    switch (selectedFilterIndex) {
      case 1:
        startDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
        break;
      case 2:
        startDate = DateTime(currentDate.year, currentDate.month - 3, currentDate.day);
        break;
      case 3:
        startDate = DateTime(currentDate.year - 1, currentDate.month, currentDate.day);
        break;
      default:
        startDate = currentDate;
    }
    List<dynamic> getExercises = exerciseData
        .where((data) {
          DateTime exerciseDate = DateTime.parse(data['date']); // Ensure the 'date' is in a valid format
          return data['exerciseName'].toString() == exerciseName &&
              exerciseDate.isAfter(startDate) &&
              exerciseDate.isBefore(currentDate.add(Duration(days: 1))); // To include today
        })
        .cast<Map<String, dynamic>>()
        .toList();

    return getExercises;
  }

  Future<int> calculateTotalWeightForDay() async {
    List<dynamic> exerciseData = [];

    bool exerciseDataExists = await userManager.exerciseDataExists();

    if (exerciseDataExists) {
      exerciseData = await userManager.getExerciseData();
    }

    int totalWeight = 0;
    // Filter exercise data for the given day, week, and month
    dailyExercises = exerciseData
        .where((data) =>
            int.parse(data['dayIndex'].toString()) == currentDay &&
            int.parse(data['monthIndex'].toString()) == currentMonth &&
            int.parse(data['weekIndex'].toString()) == currentWeek &&
            data['daySplit'].toString() == selectedDaySplit &&
            data['gymAccess'].toString() == selectedExerciseFormatAlternate)
        .cast<Map<String, dynamic>>()
        .toList();
    // Iterate over the filtered data and calculate total weight
    for (var exercise in dailyExercises) {
      int weight = int.parse(exercise['weight']);
      int reps = int.parse(exercise['reps']);
      int sets = 1; // Each entry represents a set, so set multiplier is 1

      totalWeight += weight * reps * sets;
    }
    return totalWeight;
    // return 30;
  }

  void removeExerciseDataById(int exerciseIndexToRemove) {
    exerciseData.removeWhere((data) =>
        int.parse(data['exerciseIndex'].toString()) == exerciseIndexToRemove &&
        int.parse(data['monthIndex'].toString()) == currentMonth &&
        int.parse(data['weekIndex'].toString()) == currentWeek &&
        data['daySplit'].toString() == selectedDaySplit &&
        data['gymAccess'].toString() == selectedExerciseFormatAlternate &&
        data['dayIndex'].toString() == currentDay.toString());

    userManager.saveExerciseData(exerciseData);

    notifyListeners();
  }

  // loadUserInfo() {
  //   getDaySplit();
  //   loadNotesData();
  //   fetchUserInfo();
  // }
  Future<void> loadUserInfo() async {
    try {
      getDaySplit();
      await loadNotesData();
      bool dayHistoryExists = await userManager.dayHistoryExists();
      if (dayHistoryExists) {
        dayHistory = await userManager.getDayHistory();
      }
      await fetchUserInfo();
    } catch (e) {
      debugPrint("--------------Error loading user info: $e");
      // Handle the error (e.g., show a message to the user)
    }
  }

  // dayHistory API
  Future<Map<String, dynamic>> fetchUserInfo() async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/get_user');
    String? token = await getAuthToken();

    debugPrint('token==========>>>>>$token');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'AUTH_TOKEN': token ?? "",
      },
    );
    // Convert response body to JSON object
    final jsonResponse = jsonDecode(response.body);

    // Print JSON as a string for debugging

    // log('jsonResponse==========>>>>>${jsonResponse}');

    if (response.statusCode == 200) {
      getUserDataFromJson(jsonResponse);
      notifyListeners();
      return jsonResponse;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Future<void> updateUserInfo(String? id, Map<String, dynamic> userDetails) async {
  //   Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/$id');
  //
  //   String? userIdToken = await getAuthToken();
  //   final response = await http.put(url,
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'AUTH_TOKEN': userIdToken ?? "",
  //       },
  //       body: jsonEncode(userDetails));
  //
  //   if (response.statusCode == 200) {
  //     debugPrint('User data updated successfully');
  //   } else {
  //     throw Exception('Failed to update user data: ${response.body}');
  //   }
  // }

  Future<void> updateUserInfo(String? id, Map<String, dynamic> userDetails, File? imageFile) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/$id');

    String? userIdToken = await getAuthToken();

    try {
      // Create a multipart request
      http.MultipartRequest request = http.MultipartRequest("PUT", url);

      // Add the user details as a nested JSON string
      request.fields['detail'] = jsonEncode(userDetails);

      // Add the image file

      if (imageFile != null) {
        final stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image', // Field name for the image
          stream,
          length,
          filename: basename(imageFile.path),
        );
        request.files.add(multipartFile);
      } else {
        request.fields['image'] = '';
      }

      // Add headers
      request.headers.addAll({
        'AUTH_TOKEN': userIdToken!,
        'Accept': 'application/json',
      });

      // Send the request
      http.StreamedResponse response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        // userData['avatarUrl'] = ""
        debugPrint('User data updated successfully with image');
        final responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);

        log('data :::::::rt::::::::::: ${data['result']['detail']['avatarUrl']}');
        updateUserData(data['result']['detail']);
      } else {
        debugPrint('Failed to update user data. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user info: $e');
    }
  }

  void fetchWarmUp(String warmUpId) async {
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
        currentWarmup = WarmUp(
          id: responseData["_id"],
          title: responseData["title"],
          length: responseData["length"],
          thumbnail: responseData["thumbnail"],
          files: responseData["files"],
          vimeoId: responseData["vimeoId"],
          description: responseData["description"],
          equipments: responseData["equipments"] ?? [],
        );
      }

      notifyListeners();
    } else {
      throw Exception('Failed to load fetchWarmUp');
    }
  }

  void fetchRestDay(String restDayId) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/restdays/get/$restDayId');
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
      dynamic responseData = jsonDecode(response.body);

      currentRestDay = RestDay(
        id: responseData["id"],
        title: responseData["title"],
        description: responseData["description"],
        vimeoId: responseData["vimeoId"],
        equipments: responseData["equipments"],
      );

      notifyListeners();
    } else {
      throw Exception('Failed to load fetchWarmUp');
    }
  }

  Future fetchAllExercise() async {
    final Map<String, String> queryParams = {
      'page': '1',
      'perPage': '10',
      'search': '',
      'sortBy': '',
    };

    Uri url = Uri.parse('${AppConstants.serverUrl}/api/exercises/get');
    url = Uri.http(url.authority, url.path, queryParams);
    String? userIdToken = await getAuthToken();

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
  }

  Future fetchAllFilterEx(String searchQuery) async {
    if (searchQuery.isEmpty) {
      allFilterExercises = allExercises;
    } else {
      allFilterExercises = allExercises.where((exercise) => exercise.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    notifyListeners();
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

  void getExercisesFromJson(responseData) {
    allExercises.clear();
    allFilterExercises.clear();

    for (var singleItem in responseData["exercises"]) {
      Exercise newExercise = Exercise(
          id: singleItem["_id"] ?? "",
          title: singleItem["title"] ?? "",
          vimeoId: singleItem["vimeoId"] ?? "",
          thumbnail: singleItem["thumbnail"] ?? "",
          description: singleItem["description"] ?? "",
          guide: singleItem["guide"] ?? "",
          relatedExercises: singleItem["relatedExercises"] ?? [],
          categories: singleItem["categories"] ?? [],
          usedEquipments: singleItem["usedEquipments"] ?? [],
          files: singleItem['files'] ?? []);
      allExercises.add(newExercise);
      allFilterExercises.add(newExercise);
    }

    notifyListeners();
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

  // Future<void> getUserDataFromJson(responseData) async {
  //   userId = responseData["_id"];
  //   userName = responseData["name"];
  //   userEmail = responseData["email"];
  //   // dayHistory = responseData["dayHistory"];
  //   // exerciseHistory = responseData["workoutsHistory"];

  //   notifyListeners();

  //   bool dayHistoryExists = await userManager.dayHistoryExists();
  //   bool exerciseHistoryExists = await userManager.exerciseHistoryExists();
  //   bool exerciseDataExists = await userManager.exerciseDataExists();
  //   if (dayHistoryExists) {
  //     dayHistory = await userManager.getDayHistory();
  //   }
  //   if (exerciseHistoryExists) {
  //     exerciseHistory = await userManager.getExerciseHistory();
  //   }
  //   if (exerciseDataExists) {
  //     exerciseData = await userManager.getExerciseData();
  //   }

  //   totalCompletedDays = dayHistory
  //       .where((day) =>
  //           day['monthIndex'].toString() == currentMonth.toString() &&
  //           day['state'].toString() == AppConstants.STATE_FINISHED &&
  //           day['daySplit'].toString() == selectedDaySplit)
  //       .length;

  //   currentStreak = dayHistory
  //       .where((day) =>
  //           day['state'].toString() == AppConstants.STATE_FINISHED)
  //       .length;

  //   notifyListeners();

  // }

  updateUserData(var value) async {
    // log('userData :::::::::::::::::: ${userData}');
    await fetchUserInfo();
    // userData = value;
    log('value UPDATE :::::::::::::::::: $value');
    notifyListeners();
  }

  Future<void> getUserDataFromJson(responseData) async {
    userId = responseData["_id"];
    userName = responseData["name"];
    userEmail = responseData["email"];
    userData = responseData;

    // dayHistory = responseData["dayHistory"];
    // exerciseHistory = responseData["workoutsHistory"];

    notifyListeners();

    bool dayHistoryExists = await userManager.dayHistoryExists();
    bool exerciseHistoryExists = await userManager.exerciseHistoryExists();
    bool exerciseDataExists = await userManager.exerciseDataExists();

    if (dayHistoryExists) {
      dayHistory = await userManager.getDayHistory();
    }
    if (exerciseHistoryExists) {
      exerciseHistory = await userManager.getExerciseHistory();
    }
    if (exerciseDataExists) {
      exerciseData = await userManager.getExerciseData();
    }

    totalCompletedDays = dayHistory
        .where((day) =>
            day['monthIndex'].toString() == currentMonth.toString() &&
            day['state'].toString() == AppConstants.STATE_FINISHED &&
            day['daySplit'].toString() == selectedDaySplit)
        .length;
    // Calculate current streak
    // currentStreak = _calculateCurrentStreak(dayHistory);
    completedDay = totalCompletedDays;
    notifyListeners();
  }

  int _calculateCurrentStreak(List<dynamic> dayHistory) {
    if (dayHistory == []) {
      return 0;
    }
    final todayHistory = dayHistory.firstWhere(
      (day) =>
          int.parse(day['monthIndex']) == currentMonth &&
          int.parse(day['weekIndex']) == currentWeek &&
          day['daySplit'] == selectedDaySplit &&
          int.parse(day['dayIndex']) == currentDay,
      orElse: () => null,
    );

    final previousDay = currentDay == 0 ? 6 : currentDay - 1; // Handle week wrap
    final previousWeek = currentDay == 0 ? currentWeek - 1 : currentWeek;
    final previousHistory = dayHistory.firstWhere(
      (day) =>
          int.parse(day['monthIndex']) == currentMonth &&
          int.parse(day['weekIndex']) == previousWeek &&
          day['daySplit'] == selectedDaySplit &&
          int.parse(day['dayIndex']) == previousDay,
      orElse: () => null,
    );

    // Get the previous day's streak
    final previousStreak = previousHistory != null ? int.parse(previousHistory['streak'] ?? '0') : 0;

    // Determine today's streak
    if (todayHistory != null && todayHistory['state'].toString() == AppConstants.STATE_FINISHED) {
      return previousStreak + 1;
    }

    return previousStreak;
  }

  void finishCurrentWarmUp() async {
    try {
      final Map<String, String> queryParams = {
        'monthIndex': currentMonth.toString(),
        'weekIndex': currentWeek.toString(),
        // 'dayId': currentDayObj.id ?? "",
        // 'exerciseId': currentExercise.id ?? "",
        'dayIndex': currentDay.toString(),
        'daySplit': selectedDaySplit,
        'gymAccess': selectedExerciseFormatAlternate,
        'exerciseIndex': "warmup",
        'state': AppConstants.STATE_FINISHED,
      };

      /// created issue with warmup
      // if (exerciseHistory.any((history) =>
      // int.parse((history['monthIndex']).toString()) == currentMonth &&
      //     int.parse((history['weekIndex']).toString()) == currentWeek &&
      //     history['daySplit'].toString() == selectedDaySplit &&
      //     history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
      //     history['dayIndex'].toString() == currentDay.toString() &&
      //     (history['exerciseIndex'].toString() == currentExIndex.toString() ||
      //         history['exerciseIndex'].toString() == "warmup"))) {
      //   return;
      // }

      exerciseHistory.add(queryParams);
      userManager.saveExerciseHistory(exerciseHistory);
      notifyListeners();
    } catch (e) {
      customPrintR("exception when warmup marked $e");
    }
  }

  void finishCurrentExercise() async {
    final Map<String, String> queryParams = {
      'monthIndex': currentMonth.toString(),
      'weekIndex': currentWeek.toString(),
      'dayIndex': currentDay.toString(),
      'daySplit': selectedDaySplit,
      'gymAccess': selectedExerciseFormatAlternate,
      'exerciseIndex': currentExIndex.toString(),
      'state': AppConstants.STATE_FINISHED,
    };

    // monthIndex:  currentMonth.toString()
    // weekIndex: currentWeek.toString()
    // dayId: currentDay.toString()
    // exerciseId: currentExercise.id
    // sets: currentExercise.sets;
    // resp: currentExercise.reps;
    // weight: currentExercise.weight;
    // rest: currentExercise.rest;

    if (exerciseHistory.any((history) =>
        int.parse((history['monthIndex']).toString()) == currentMonth &&
        int.parse((history['weekIndex']).toString()) == currentWeek &&
        history['daySplit'].toString() == selectedDaySplit &&
        history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
        history['dayIndex'].toString() == currentDay.toString() &&
        history['exerciseIndex'].toString() == currentExIndex.toString())) {
      return;
    }

    exerciseHistory.add(queryParams);
    userManager.saveExerciseHistory(exerciseHistory);
    notifyListeners();

    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/exercise_done');
    url = Uri.http(url.authority, url.path, queryParams);

    String? userIdToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'FIREBASE_AUTH_TOKEN': userIdToken ?? "",
      },
      body: jsonEncode(queryParams),
    );

    if (response.statusCode == 200) {
      debugPrint(queryParams.toString());

      exerciseHistory.add(queryParams);

      if (jsonDecode(response.body)["result"] == true) {
        // completeCurrentExercise();
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load exercise info');
    }
  }

  void updateOrAddExerciseHistory(String stateString) async {
    if (exerciseHistory.any((history) =>
        int.parse((history['monthIndex']).toString()) == currentMonth &&
        int.parse((history['weekIndex']).toString()) == currentWeek &&
        history['daySplit'].toString() == selectedDaySplit &&
        history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
        history['dayIndex'].toString() == currentDay.toString() &&
        history['exerciseIndex'].toString() == currentExIndex.toString())) {
      exerciseHistory = exerciseHistory.map((history) {
        if (int.parse((history['monthIndex']).toString()) == currentMonth &&
            int.parse((history['weekIndex']).toString()) == currentWeek &&
            history['daySplit'].toString() == selectedDaySplit &&
            history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
            history['dayIndex'].toString() == currentDay.toString() &&
            history['exerciseIndex'].toString() == currentExIndex.toString()) {
          history['state'] = stateString;
        }
        return history;
      }).toList();
    } else {
      final Map<String, String> queryParams = {
        'monthIndex': currentMonth.toString(),
        'weekIndex': currentWeek.toString(),
        'dayIndex': currentDay.toString(),
        'daySplit': selectedDaySplit,
        'gymAccess': selectedExerciseFormatAlternate,
        'exerciseIndex': currentExIndex.toString(),
        'state': stateString,
      };
      exerciseHistory.add(queryParams);
    }
    log('exerciseHistory :::::::::::::::::: $exerciseHistory');
    // final Map<String, String> queryParams1 = {
    // "monthIndex":  currentMonth.toString(),
    // "weekIndex": currentWeek.toString(),
    // "dayId": currentDayObj.id,
    // "exerciseId": currentExercise.id,
    // "sets": currentExercise.sets.toString(),
    // "resp": currentExercise.reps.toString(),
    // "weight": currentExercise.weight.toString(),
    // "rest": currentExercise.rest.toString(),
    // };
    //
    // log("CALLED====2");
    //
    // Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/exercise_done');
    // url = Uri.http(url.authority, url.path, queryParams1);
    //
    // String? userIdToken = await getAuthToken();
    // final response = await http.post(
    //   url,
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'AUTH_TOKEN': userIdToken ?? "",
    //   },
    //   body: jsonEncode(queryParams1),
    // );
    //
    // if (response.statusCode == 200) {
    //
    //   log("CALLED====3");
    //   debugPrint(queryParams1.toString());
    //
    //   exerciseHistory.add(queryParams1);
    //
    //   if (jsonDecode(response.body)["result"] == true) {
    //     // completeCurrentExercise();
    //   }
    //   notifyListeners();
    // } else {
    //   log("CALLED====4 ${response.statusCode}");
    //   log("CALLED====5 ${queryParams1}");
    //   throw Exception('Failed to load exercise info');
    // }

    userManager.saveExerciseHistory(exerciseHistory);
    notifyListeners();
  }

  Future finishCurrentDay() async {
    completedDay = completedDay + 1;
    updateOrAddDayHistory(AppConstants.STATE_FINISHED);
    notifyListeners();

    if (dayHistory.any((history) =>
        int.parse((history['monthIndex']).toString()) == currentMonth &&
        int.parse((history['weekIndex']).toString()) == currentWeek &&
        history['daySplit'] == selectedDaySplit &&
        history['dayIndex'] == currentDay.toString())) {
      return;
    }
    if (exerciseHistory.any((history) =>
        int.parse((history['monthIndex']).toString()) == currentMonth &&
        int.parse((history['weekIndex']).toString()) == currentWeek &&
        history['daySplit'].toString() == selectedDaySplit &&
        history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
        history['dayIndex'].toString() == currentDay.toString() &&
        history['exerciseIndex'].toString() == currentExIndex.toString())) {
      exerciseHistory = exerciseHistory.map((history) {
        if (int.parse((history['monthIndex']).toString()) == currentMonth &&
            int.parse((history['weekIndex']).toString()) == currentWeek &&
            history['daySplit'].toString() == selectedDaySplit &&
            history['gymAccess'].toString() == selectedExerciseFormatAlternate &&
            history['dayIndex'].toString() == currentDay.toString() &&
            history['exerciseIndex'].toString() == currentExIndex.toString()) {}
        return history;
      }).toList();
    }
    // queryParams = {
    //   'monthIndex': currentMonth.toString(),
    //   'weekIndex': currentWeek.toString(),
    //   'daySplit': selectedDaySplit,
    //   'dayIndex': currentDay.toString(),
    //   'state': "finished",
    //   "exercise": excerciseDay.toString()
    // };
    // queryParams = {
    //   'monthIndex': currentMonth.toString(),
    //   'weekIndex': currentWeek.toString(),
    //   'daySplit': selectedDaySplit,
    //   'dayIndex': currentDay.toString(),
    //   'state': "finished",
    //   "streak": currentStreak.toString()
    // };
    //
    //
    // Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/day_done');
    // url = Uri.http(url.authority, url.path, queryParams);
    //
    // String? userIdToken = await getAuthToken();
    // final response = await http.post(
    //   url,
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'AUTH_TOKEN': userIdToken ?? "",
    //   },
    //   body: jsonEncode(queryParams),
    // );
    //
    // if (response.statusCode == 200) {
    //   if (jsonDecode(response.body)["result"] == true) {
    //     // completeCurrentExercise();
    //   }
    //   notifyListeners();
    // } else {
    //   throw Exception('Failed to load exercise info');
    // }
  }

  void removeExerciseSet(int exerciseIndex, int setIndex) {
    // Remove the specific set data from exerciseData
    exerciseData.removeWhere((data) =>
        int.parse(data['exerciseIndex'].toString()) == exerciseIndex &&
        int.parse(data['setIndex'].toString()) == setIndex &&
        int.parse(data['monthIndex'].toString()) == currentMonth &&
        int.parse(data['weekIndex'].toString()) == currentWeek &&
        data['daySplit'].toString() == selectedDaySplit &&
        data['gymAccess'].toString() == selectedExerciseFormatAlternate &&
        data['dayIndex'].toString() == currentDay.toString());

    // Save the updated exerciseData to persistent storage (if necessary)
    userManager.saveExerciseData(exerciseData);

    // Notify listeners to rebuild the UI
    notifyListeners();
  }

  updateNextDayIndex(dayIndex) {
    if (dayIndex == 6) {
      nextDayIndex = 7;
    } else {
      nextDayIndex = dayIndex;
    }

    notifyListeners();
  }

  // Initialize data (called when app starts or page loads)
  Future<void> loadHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('historyData');
    if (data != null) {
      _historyData = List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    notifyListeners();
  }

  // Add or update history data
  Future<void> updateHistoryData(List<Map<String, dynamic>> newData) async {
    _historyData = newData;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('historyData', jsonEncode(_historyData));
    notifyListeners();
  }

  // Add a single workout record
  Future<void> addWorkout(Map<String, dynamic> workout) async {
    _historyData.add(workout);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('historyData', jsonEncode(_historyData));
    notifyListeners();
  }

  ///Function that make an update the currentObject:

  void todayHistoryCreated(exerciseIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('todayData');
    if (currentDayObj?.exercises[exerciseIndex].extra.isNotEmpty ?? false) {
      List<Map<String, dynamic>> historyData = [];
      List<Map<String, dynamic>> sets = [];
      // multiple loop each set contain subsett
      for (int i = 0; i < currentDayObj!.exercises[exerciseIndex].extra.length; i++) {
        final extraItem = currentDayObj!.exercises[exerciseIndex].extra[i];

        int setCount = _safeParseInt(extraItem['sets'].toString());

        // List<Map<String, dynamic>> sets = [];
        for (int setIndex = 0; setIndex < setCount; setIndex++) {
          sets.add({
            'index': i,
            'subIndex': setIndex,
            'reps': _safeParseInt(extraItem['reps'].toString()),
            'weight': _safeParseInt(extraItem['weight'].toString()),
            'rir': _safeParseInt(extraItem['rir'].toString()),
            'rest': _safeParseInt(extraItem['rest'].toString())
          });
        }
      }

      Map<String, dynamic> workout = {
        'date': DateTime.now().toString(), // In future we add actual date
        'sets': sets,
      };

      historyData.add(workout);

      // Save the history

      await prefs.setString('todayData', jsonEncode(historyData));
      customPrintB("SUCCESSFULLY ADDED");
    }
  }

  List<Map<String, dynamic>> todayHistoryData = [];
  Future<void> getTodayHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todayDataJson = prefs.getString('todayData');
    if (todayDataJson != null) {
      List<Map<String, dynamic>> historyData = List<Map<String, dynamic>>.from(jsonDecode(todayDataJson));
    }

    customPrintR(jsonEncode(historyData));
    // Save the updated data back to SharedPreferences
    await prefs.setString('todayData', jsonEncode(historyData));
  }

  void updateTodayHistoryData(int index, int subIndex, Map<String, dynamic> updatedSetData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todayDataJson = prefs.getString('todayData');

    if (todayDataJson != null) {
      List<Map<String, dynamic>> historyData = List<Map<String, dynamic>>.from(jsonDecode(todayDataJson));

      for (var workout in historyData) {
        if (workout['sets'] != null) {
          for (var set in workout['sets']) {
            if (set['index'] == index && set['subIndex'] == subIndex) {
              set.addAll(updatedSetData); // Update the set with the new data
            }
          }
        }
      }

      customPrintR(jsonEncode(historyData));
      // Save the updated data back to SharedPreferences
      await prefs.setString('todayData', jsonEncode(historyData));
    }

    log("prefs.getString('todayData') ${prefs.getString('todayData')}");
  }

// Store today's data in the actual exercise history
  void storeTodayDataInMainExerciseHistoryData() async {
    // Retrieve today's data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todayDataJson = prefs.getString('todayData');

    if (todayDataJson != null) {
      // Decode the today's data and save it into the main history
      List<Map<String, dynamic>> todayData = List<Map<String, dynamic>>.from(jsonDecode(todayDataJson));

      // Fetch the actual history stored in SharedPreferences
      String? actualHistoryJson = prefs.getString('historyData');
      List<Map<String, dynamic>> actualHistoryData = [];

      if (actualHistoryJson != null) {
        actualHistoryData = List<Map<String, dynamic>>.from(jsonDecode(actualHistoryJson));
      }

      // Append today's data to the actual history
      actualHistoryData.addAll(todayData);

      // Store the updated actual history back into SharedPreferences
      await prefs.setString('historyData', jsonEncode(actualHistoryData));
    }
  }

  void exerciseHistoryCreated(exerciseIndex) async {
    if (currentDayObj?.exercises[exerciseIndex].extra.isNotEmpty ?? false) {
      List<Map<String, dynamic>> historyData = [];
      List<Map<String, dynamic>> sets = [];
      // multiple loop each set contain subsett
      for (int i = 0; i < currentDayObj!.exercises[exerciseIndex].extra.length; i++) {
        final extraItem = currentDayObj!.exercises[exerciseIndex].extra[i];

        int setCount = _safeParseInt(extraItem['sets'].toString());

        // List<Map<String, dynamic>> sets = [];
        for (int setIndex = 0; setIndex < setCount; setIndex++) {
          sets.add({
            'index': i,
            'subIndex': setIndex,
            'reps': _safeParseInt(extraItem['reps'].toString()),
            'weight': _safeParseInt(extraItem['weight'].toString()),
            'rir': _safeParseInt(extraItem['rir'].toString()),
            'rest': _safeParseInt(extraItem['rest'].toString())
          });
        }

        // Create a workout record with date and sets
        // Map<String, dynamic> workout = {
        //   'date': DateTime.now().toString(), // In future we add actual date
        //   'sets': sets,
        // };
        //
        // historyData.add(workout);
      }

      Map<String, dynamic> workout = {
        'date': DateTime.now().toString(), // In future we add actual date
        'sets': sets,
      };

      historyData.add(workout);

      // Save the history
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('todayData', jsonEncode(historyData));
      await prefs.setString('historyData', jsonEncode(historyData));
    }
  }

  clean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('todayData');
    await prefs.remove('historyData');
  }

// Helper function to safely parse integers
  int _safeParseInt(String? value) {
    if (value == null || value.isEmpty) {
      return 0;
    }
    return int.tryParse(value) ?? 0; // Return 0 if parsing fails
  }
}
