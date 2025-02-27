import 'package:intl/intl.dart';

class Utils {
  static DateTime formattedDate(String date) {
    String utcTimeString = date;
    DateTime utcTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTimeString);
    DateTime localTime = utcTime.toLocal();
    return localTime;
  }
}
