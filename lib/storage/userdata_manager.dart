import 'dart:convert';
import 'dart:developer';
// import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  List<dynamic> dayHistory = [];
  List<dynamic> exerciseData = [];
  List<dynamic> exerciseHistory = [];
  String daySplit = "3";

  Future<bool> daySplitExists()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('day_split') == null || prefs.getString('day_split')!.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> saveDaySplit(String newDaySplit) async {
    daySplit = newDaySplit;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('day_split', newDaySplit);
  }

  Future<String> getDaySplit() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    daySplit = pref.getString('day_split')!;

    return daySplit;
  }

  Future<bool> exerciseDataExists()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('exercise_data') == null || prefs.getString('exercise_data')!.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> saveExerciseData(List<dynamic> newExerciseData) async {
    exerciseData = newExerciseData;


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('exercise_data', jsonEncode(newExerciseData));
  }

  Future<List<dynamic>> getExerciseData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String exerciseDataString = pref.getString('exercise_data')!;

    if (exerciseDataString.isNotEmpty) {
      exerciseData = jsonDecode(exerciseDataString) as List<dynamic>;
    }
    return exerciseData;
  }

  Future<bool> dayHistoryExists()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('day_history') == null || prefs.getString('day_history')!.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> saveDayHistory(List<dynamic> newDayHistory) async {
    dayHistory = newDayHistory;


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('day_history', jsonEncode(newDayHistory));
  }

  Future<List<dynamic>> getDayHistory() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String dayHistoryString = pref.getString('day_history')!;


    if (dayHistoryString.isNotEmpty) {
      dayHistory = jsonDecode(dayHistoryString) as List<dynamic>;
    }
    return dayHistory;
  }

  Future<bool> exerciseHistoryExists()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('exercise_history') == null || prefs.getString('exercise_history')!.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> saveExerciseHistory(List<dynamic> newExerciseHistory) async {
    exerciseHistory = newExerciseHistory;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('exercise_history', jsonEncode(newExerciseHistory));
  }

  Future<List<dynamic>> getExerciseHistory() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String exerciseHistoryString = pref.getString('exercise_history')!;



    if (exerciseHistoryString.isNotEmpty) {
      exerciseHistory = jsonDecode(exerciseHistoryString) as List<dynamic>;
    }
    return exerciseHistory;
  }
}