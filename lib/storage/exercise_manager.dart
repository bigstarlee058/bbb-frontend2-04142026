// import 'dart:convert';
import 'dart:convert';

import 'package:bbb/models/month.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/convert_util.dart';

class MonthWorkoutsManager {
  final List<Month> workoutMonths = [];
  int currentMonthIndex = -1;
  bool monthExisting = false;

  Future<void> saveMonth(dynamic newMonth) async {
    currentMonthIndex = newMonth.index;
    await deleteMonth(currentMonthIndex);
    String monthString = monthToJson(newMonth);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('month${newMonth.index}') == null || prefs.getString('month${newMonth.index}')!.isEmpty) {
      debugPrint("No Month is here.");
      prefs.setString('month${newMonth.index}', monthString);
      monthExisting = false;
    } else {
      debugPrint("Month is existing.");
      monthExisting = false;
    }
  }

  Future<void> deleteMonth(int monthIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isKeyPresent = prefs.containsKey('month$monthIndex');
    if (isKeyPresent) {
      await prefs.remove('month$monthIndex');
      debugPrint("Month data for index $monthIndex deleted.");
    } else {
      debugPrint("No data found for month index $monthIndex to delete.");
    }
  }

  Future<void> saveNewMonth(dynamic newMonth) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String monthString = monthToJson(newMonth);
    prefs.setString('month${newMonth.index}', monthString);
  }

  Future<Month> getMonth(int monthIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Month newMonth =
        Month(id: '', index: monthIndex, title: '', description: '', vimeoId: '', thumbnail: '', weeks: [], startDate: '', endDate: '');

    if (!(prefs.getString('month${newMonth.index}') == null || prefs.getString('month${newMonth.index}')!.isEmpty)) {
      String monthString = prefs.getString('month${newMonth.index}')!;
      newMonth = jsonToMonth(monthString);
    }

    return newMonth;
  }
}
