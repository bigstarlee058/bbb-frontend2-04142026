import 'dart:developer';
import 'dart:io';

import 'package:vibration/vibration.dart';

class HapticFeedBack {
  static Future buttonClick() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(
        duration: Platform.isIOS ? 5 : 30,
      );
    } else {
      log("Device does not support vibration");
    }
  }
}
