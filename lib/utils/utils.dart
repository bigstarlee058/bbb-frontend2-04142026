import 'package:intl/intl.dart';

class Utils {
  static DateTime formattedDate(String date) {
    String utcTimeString = date;
    DateTime utcTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTimeString);
    DateTime localTime = utcTime.toLocal();
    return localTime;
  }
}

extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1);
  }
}
