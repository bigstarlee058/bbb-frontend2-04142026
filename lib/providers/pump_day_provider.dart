import 'dart:convert';

import 'package:bbb/providers/user_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PumpDayProvider extends ChangeNotifier {
  List pumpDayHistory = [];
  List pumpDays = [];
  late SharedPreferences preferences;
  UserDataProvider? userData;

  bool isPumpDay = false;

  ///added pump days data from local
  getPumpDayHistory(BuildContext context) async {
    userData = Provider.of(context, listen: false);
    preferences = await SharedPreferences.getInstance();
    var temp = preferences.getString("pumpDayHistory");
    if (temp != null) {
      pumpDayHistory = jsonDecode(temp);
    }

    var isPumpDayData = checkForPumpDay(userData!.currentMonth, userData!.currentWeek, userData!.currentDay, userData!.selectedDaySplit);
    isPumpDay = isPumpDayData != null;

    notifyListeners();
  }

  checkForPumpDay(int month, int week, int day, String split) {
    var matched = pumpDayHistory.where(
      (element) {
        return element['month'] == month && element['week'] == week && element['day'] == day && element['day_split'] == split;
      },
    );
    if (matched.toList().isNotEmpty) {
      return matched.toList().first;
    }
    // current_title
    return null;
  }

  checkForPumpDayBalance(int month, int week, String split) async {
    var matched = pumpDayHistory.where(
      (element) {
        return element['month'] == month && element['week'] == week && element['day_split'] == split;
      },
    );
    return matched.toList().length;
  }

  ///save pump days
  savePumpDays(var data) async {
    pumpDayHistory.add(data);
    preferences.setString("pumpDayHistory", jsonEncode(pumpDayHistory));
    notifyListeners();
  }

  ///remove pumpDay
  removePumpDay(var data) {
    pumpDayHistory.removeWhere((element) =>
        element['moth'] == data['moth'] &&
        element['week'] == data['week'] &&
        element['day_split'] == data['day_split'] &&
        element['day'] == data['day']);
    preferences.setString("pumpDayHistory", jsonEncode(pumpDayHistory));
    notifyListeners();
  }
}
