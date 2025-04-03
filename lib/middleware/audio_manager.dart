import 'dart:developer';

import 'package:flutter/services.dart';

class AudioManager {
  static const platform = MethodChannel('audio_focus');

  static Future<void> requestAudioFocus() async {
    try {
      await platform.invokeMethod('requestAudioFocus');
    } catch (e) {
      log("Error requesting audio focus: $e");
    }
  }

  static Future<void> abandonAudioFocus() async {
    try {
      await platform.invokeMethod('abandonAudioFocus');
    } catch (e) {
      log("Error abandoning audio focus: $e");
    }
  }
}
