import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_colors.dart';

class ExerciseHistoryProvider extends ChangeNotifier {
  List todayHistory = [];
  var history;
  String exerciseId = "";

  late SharedPreferences prefs;

  Map<String, dynamic> object = {};

  List filteredData = [];

  List<Map<String, dynamic>> liftedWeightEachDay = [];
  List<Map<String, dynamic>> graphHistory = [];

  String today = DateFormat('dd/MM/yyy').format(DateTime.now()).toString();

  updatedObject(Map<String, dynamic> value) {
    object = value;
    notifyListeners();
  }

  updateId(String id) {
    exerciseId = id;
  }

  getExercise() async {
    prefs = await SharedPreferences.getInstance();
    var data = prefs.getString("exerciseHistoryNew");
    if (data != null) {
      history = jsonDecode(data);

      log("OLD HISTORY $history");

      todayHistory = history[today]['completedSets'];
    } else {
      history = {
        today: {
          'totalWeightLifted': 0,
          'completedSets': [],
          'status': "",
        },
      };
    }

    log('history==========>>>>>${jsonEncode(history)}');
    getLiftedWeightGraphData();
    notifyListeners();
  }

  saveExercise(int index) {
    int index = todayHistory.indexWhere((element) =>
        element['monthIndex'] == object['monthIndex'] &&
        element['weekIndex'] == object['weekIndex'] &&
        element['dayId'] == object['dayId'] &&
        element['index'] == object['index'] &&
        element['split_type'] == object['split_type'] &&
        element['subIndex'] == object['subIndex'] &&
        element['exerciseId'] == object['exerciseId']);

    if (index > -1) {
      todayHistory[index] = object;
    } else {
      todayHistory.add(object);
    }

    history[today]['completedSets'] = todayHistory;
    prefs.setString("exerciseHistoryNew", jsonEncode(history));

    calculateTotalWeight(history);
  }

  getFilteredHistory() {
    var data = prefs.getString("exerciseHistoryNew");

    if (data != null) {
      history = jsonDecode(data);
      todayHistory = history[today]['completedSets'];
    } else {
      history = {
        today: {'totalWeightLifted': 0, 'completedSets': []},
      };
    }

    filteredData = [];

    if (history[today]['completedSets'].isNotEmpty) {
      // Loop over each date and its exercises
      history.forEach((key, element) {
        // Create a new list to hold filtered exercises for the current date
        List<dynamic> filteredElement = [];

        // Only keep exercises that match the exerciseId
        for (var e in element['completedSets']) {
          // Add exercise if it matches the exerciseId
          if (e['exerciseId'] == exerciseId) {
            filteredElement.add(e); // Only add exercises that match the exerciseId
          }
        }

        // If there are filtered exercises, add them to the final list
        if (filteredElement.isNotEmpty) {
          filteredData.add({"date": formatDate(key), "data": filteredElement});
        }

        debugPrint('key==========>>>>>$key');
        debugPrint('filteredElement==========>>>>>$filteredElement');
      });
    }
  }

  void calculateTotalWeight(var data) {
    List<int> totalWeight = [];
    for (var exercise in data[today]['completedSets']) {
      int weight = exercise['weight'] ?? 0;
      int reps = exercise['reps'] ?? 0;
      totalWeight.add(weight * reps);
    }
    int totalSum = totalWeight.reduce((sum, element) => sum + element);
    history[today]['totalWeightLifted'] = totalSum;
    prefs.setString("exerciseHistoryNew", jsonEncode(history));
    notifyListeners();
  }

  int totalLiftedWeight = 0;

  void getLiftedWeightGraphData() {
    if (history != null) {
      history.forEach((key, element) {
        String day = getDayTitle(key);
        liftedWeightEachDay.add({
          "day": day,
          "totalWeightLifted": element['totalWeightLifted'],
        });
        totalLiftedWeight = totalLiftedWeight + element['totalWeightLifted'] as int;
      });
    }
    graphHistory = processWeekData(liftedWeightEachDay);
    notifyListeners();
  }

  List<Map<String, dynamic>> processWeekData(List<Map<String, dynamic>> data) {
    List<String> allDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    // Get today's DateTime and name
    DateTime today = DateTime.now();
    String todayDayName = DateFormat('EEE').format(today);

    // Ensure all missing days are added with default values
    for (String day in allDays) {
      if (!data.any((entry) => entry['day'] == day)) {
        data.add({"day": day, "totalWeightLifted": 0});
      }
    }

    // Create a mapping of day to totalWeightLifted
    Map<String, int> dayToWeight = {for (var entry in data) entry["day"]: entry["totalWeightLifted"]};

    // Rearrange days to start from the day after today
    int todayIndex = allDays.indexOf(todayDayName);
    List<String> reorderedDays = [...allDays.sublist(todayIndex + 1), ...allDays.sublist(0, todayIndex + 1)];

    // Generate the final dataset with all days
    return reorderedDays.map((day) {
      return {
        "day": day,
        "totalWeightLifted": _BarData(
          AppColors.primaryColor,
          (dayToWeight[day] ?? 0).toDouble(),
          0.0,
        ),
      };
    }).toList();
  }

  String formatDate(String date) {
    try {
      // Parse the date string (assuming it's in "DD/MM/YYYY" format)
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);

      // Format it to "MMM dd, yyyy" format (e.g., "Nov 05, 2024")
      String formattedDate = DateFormat("MMM dd, yyyy").format(parsedDate);

      return formattedDate;
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  String getDayTitle(String dateStr) {
    // Parse the date
    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateTime dateTime = inputFormat.parse(dateStr);

    // Format to get day title
    DateFormat outputFormat = DateFormat('EEE'); // EEE gives day title (e.g., Mon, Tue)
    return outputFormat.format(dateTime);
  }
}

class _BarData {
  const _BarData(this.color, this.value, this.shadowValue);
  final Color color;
  final double value;
  final double shadowValue;
}
