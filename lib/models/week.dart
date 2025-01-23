import 'package:bbb/models/day.dart';

class Week {
  Week({
    required this.index,
    required this.title,
    required this.description,
    required this.vimeoId,
    required this.thumbnail,
    required this.restdayId,
    required this.pumpDayIds,
    required this.days,
    this.sId,
  });

  int index;
  String title;
  String description;
  String vimeoId;
  String restdayId;
  String thumbnail;
  List<Day> days = [];
  List pumpDayIds = [];
  // List<dynamic> days = [];
  String? sId;
}
