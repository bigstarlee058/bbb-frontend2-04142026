import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static DateTime formattedDate(String date) {
    String utcTimeString = date;
    DateTime utcTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTimeString);
    DateTime localTime = utcTime.toLocal();
    return localTime;
  }

  static BorderRadius buttonRadius = BorderRadius.circular(20);

  static RoundedRectangleBorder buttonStyle = RoundedRectangleBorder(borderRadius: buttonRadius);
}

extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1);
  }
}
