import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_colors.dart';

class WeeklyGraphProvider extends ChangeNotifier {
  List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool? timerRunning;

  String? daySplit;

  int splitIndex = 0;

  late SharedPreferences prefs;

  List weeklyProgress = [];
  Duration? workoutTime;

  var exerciseCompleted = [];
  var timeSpent = [];
  var titles = [];

  getWeeklyProgress() async {
    prefs = await SharedPreferences.getInstance();

    daySplit = prefs.getString('day_split') ?? "3";

    splitIndex = daySplit == "3"
        ? 0
        : daySplit == "4"
            ? 1
            : 2;

    var data = prefs.getString("weeklyProgress");
    timerRunning = prefs.getBool("timerRunning");

    if (data != null) {
      weeklyProgress = jsonDecode(data);
      String date = DateFormat("dd/MM/yyyy").format(DateTime.now());
      bool exist = weeklyProgress.any((element) => element['date'] == date);

      if (exist) {
        log("DATA Exist");
      } else {
        weeklyProgress.add({
          "day": daysOfWeek[DateTime.now().weekday],
          "date": date,
          "exercise_completed": [
            {"split_type": "3", "workout_time": "00:00", "completed": 0},
            {"split_type": "4", "workout_time": "00:00", "completed": 0},
            {"split_type": "5", "workout_time": "00:00", "completed": 0}
          ],
        });
        log("DATA Not Exist");
      }
    } else {
      weeklyProgress = [];
      int currentDayIndex = DateTime.now().weekday - 1; // To make it 0-based for indexing
      for (int i = 0; i < 7; i++) {
        // Calculate the date for the day
        DateTime dayDate = DateTime.now().subtract(Duration(days: currentDayIndex - i));
        String date = DateFormat("dd/MM/yyyy").format(dayDate);

        // Calculate the correct index for the day of the week
        int dayIndex = (currentDayIndex - (6 - i)) % 7;
        if (dayIndex < 0) dayIndex += 7; // Handle negative indices by wrapping around

        // Add data to the list
        Map<String, dynamic> json = {
          "day": daysOfWeek[dayIndex],
          "date": date,
          "exercise_completed": [
            {"split_type": "3", "workout_time": "00:00", "completed": 0},
            {"split_type": "4", "workout_time": "00:00", "completed": 0},
            {"split_type": "5", "workout_time": "00:00", "completed": 0}
          ],
        };
        weeklyProgress.add(json);
      }
    }
    loadGraphData();
    prefs.setString("weeklyProgress", jsonEncode(weeklyProgress));
    getTotalCompletedExercises();

    log("weeklyProgress $weeklyProgress");
    notifyListeners();
  }

  startTimer() async {
    print("TIMER STARTED");

    if (timerRunning ?? false) {
      stopTimer();
    }
    DateTime today = DateTime.now();
    prefs.setString("startTime", today.toString());
    await getWeeklyProgress();

    timerRunning = true;
    prefs.setBool("timerRunning", true);

    notifyListeners();
  }

  stopTimer() {
    timerRunning = false;
    prefs.setBool("timerRunning", false);
    DateTime endTime = DateTime.now();
    DateTime startTime = DateTime.parse(prefs.getString("startTime")!);

    Duration elapsed = endTime.difference(startTime);

    workoutTime = _parseDuration(weeklyProgress[6]['exercise_completed'][splitIndex]['workout_time']);
    Duration totalDuration = elapsed + workoutTime!;
    weeklyProgress[6]['exercise_completed'][splitIndex]['workout_time'] = _formatDuration(totalDuration);
    prefs.setString("weeklyProgress", jsonEncode(weeklyProgress));
    log("STOP $weeklyProgress");
  }

  markExerciseCompleted() {
    log("VALUE markExerciseCompleted");
    weeklyProgress[weeklyProgress.length - 1]['exercise_completed'][splitIndex]['completed'] =
        weeklyProgress[weeklyProgress.length - 1]['exercise_completed'][splitIndex]['completed'] + 1;
    prefs.setString("weeklyProgress", jsonEncode(weeklyProgress));
    notifyListeners();
  }

  int totalCompletedExercises = 0;

  getTotalCompletedExercises() {
    for (var element in weeklyProgress) {
      for (var exercise in element['exercise_completed']) {
        if (exercise['split_type'] == daySplit) {
          totalCompletedExercises = totalCompletedExercises + exercise['completed'] as int;
        }
      }
    }

    notifyListeners();
  }

  // addData(){
  //   weeklyProgress[0]['exercise_completed'][splitIndex]['workout_time']= "02:00";
  //   weeklyProgress[1]['exercise_completed'][splitIndex]['workout_time']= "2:45";
  //   weeklyProgress[2]['exercise_completed'][splitIndex]['workout_time']= "03:15";
  //   weeklyProgress[3]['exercise_completed'][splitIndex]['workout_time']= "1:30";
  //   weeklyProgress[4]['exercise_completed'][splitIndex]['workout_time']= "00:00";
  //   weeklyProgress[5]['exercise_completed'][splitIndex]['workout_time']= "04:30";
  //   weeklyProgress[6]['exercise_completed'][splitIndex]['workout_time']= "01:01";
  //   prefs.setString("weeklyProgress", jsonEncode(weeklyProgress));
  // }
  double chatHeight = 8;
  loadGraphData() async {
    exerciseCompleted = [];
    timeSpent = [];
    titles = [];

// Ensure only the last 7 entries from weeklyProgress are considered
    final lastSevenProgress = weeklyProgress.length > 7 ? weeklyProgress.sublist(weeklyProgress.length - 7) : weeklyProgress;

    for (var element in lastSevenProgress) {
      titles.add(element['day']);
      exerciseCompleted.add(_BarData(
        AppColors.primaryColor,
        double.parse("${element['exercise_completed'][splitIndex]["completed"]}"),
        0.0,
      ));

      if (chatHeight <= double.parse("${element['exercise_completed'][splitIndex]["workout_time"].replaceAll(":", ".")}")) {
        chatHeight = double.parse("${element['exercise_completed'][splitIndex]["workout_time"].replaceAll(":", ".")}");
      }


      // if (int.parse(element['exercise_completed'][splitIndex]["workout_time"].split(":").first) > 8) {
      timeSpent.add(_BarData(
        AppColors.primaryColor,
        double.parse("${element['exercise_completed'][splitIndex]["workout_time"].replaceAll(":", ".")}"),
        0.0,
      ));
      // } else {
      //   timeSpent.add(_BarData(
      //     AppColors.primaryColor,
      //     double.parse("${element['exercise_completed'][splitIndex]["workout_time"].replaceAll(":", ".")}"),
      //     0.0,
      //   ));
      // }

      notifyListeners();
    }
    log('chatHeight ::::::::::::::::::${(chatHeight / 8).round().toDouble()} ${chatHeight}');
    if (chatHeight >= 8) {
      chatHeight = (((chatHeight / 8)).round()*8).toDouble();
    }
    log('chatHeight ::::::::::::::::::11 ${chatHeight}');
    notifyListeners();
  }

  // Helper function to format Duration to hh:mm
  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}';
  }

  // Helper function to ensure two digits (for formatting)
  String _twoDigits(int n) {
    if (n >= 0 && n < 10) {
      return '0$n';
    } else {
      return '$n';
    }
  }

  // Helper function to parse a string in "hh:mm" format back to Duration
  Duration _parseDuration(String time) {
    final parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }
}

class _BarData {
  const _BarData(this.color, this.value, this.shadowValue);
  final Color color;
  final double value;
  final double shadowValue;
}

// var newData = [
//   {
//     "date":"",
//     "day":"Mon",
//     "status":"",
//     "split_type":"",
//     "workout_time":"",
//     "completed_exercise_count":0,
//     "totalWeightLifted":"",
//     "completedSets":[]
//   }
// ];
