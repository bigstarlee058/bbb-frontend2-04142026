import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:vibration/vibration.dart';

class HapticFeedBack {
  static Future buttonClick() async {
    final rawData = await preferences.getBool(SharedPreference.isHapticFeedbackOn);
    if (rawData == true || rawData == null) {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(
          duration: Platform.isIOS ? 5 : 30,
        );
      } else {
        log("Device does not support vibration");
      }
    }
  }
}
