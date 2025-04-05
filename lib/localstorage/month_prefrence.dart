import 'package:shared_preferences/shared_preferences.dart';

final preferences = SharedPreference();

class SharedPreference {
  static SharedPreferences? _preferences;

  static const String monthId = "MONTH-ID";
  static const String split = "SPLIT-TYPE";
  static const String lastMonthDataUpdate = "LAST-MONTH-UPDATE";
  static const String lastStreakCount = "STREAK-COUNT";
  static const String lastTimerAddress = "LAST-TIMER-ADDRESS";
  static const String lastTimerPassed = "LAST-TIMER-PASSED";
  static const String lastExitTime = "LAST-EXIT-TIME";
  static const String isPause = "IS-PAUSE";
  static const String payload = "PAYLOAD";
  static const String fromNotification = "FROM-NOTIFICATION";
  static const String exerciseTutorial = "EXERCISE-TUTORIAL";
  static const String inTheExerciseScreenOrNot = "EXERCISE-SCREEN-OR-NOT";
  static const String notificationSwitch = "notificationSwitch";
  static const String isHapticFeedbackOn = "IS-HAPTIC-FEEDBACK-ON";

  init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool?> putString(String key, String value) async {
    return _preferences?.setString(key, value);
  }

  String? getString(String key, {String defValue = ""}) {
    return _preferences == null ? defValue : _preferences!.getString(key) ?? defValue;
  }

  Future<bool?> putInt(String key, int value) async {
    return _preferences?.setInt(key, value);
  }

  Future<bool?> setBool(String key, bool value) async {
    return _preferences?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _preferences?.getBool(key);
  }

  int? getInt(String key, {int defValue = 0}) {
    return _preferences == null ? defValue : _preferences!.getInt(key) ?? defValue;
  }

  clearValue(String key) {
    return _preferences!.remove(key);
  }
}
