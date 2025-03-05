import 'dart:developer';

import 'package:vibration/vibration.dart';

class HapticFeedBack {
  static Future buttonClick() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(
        duration: 50,
      );
    } else {
      log("Device does not support vibration");
    }
  }
}
