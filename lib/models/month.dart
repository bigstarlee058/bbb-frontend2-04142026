
import 'package:bbb/models/week.dart';

class Month {
  Month({
    required this.id,
    required this.index,
    required this.title,
    required this.description,
    required this.vimeoId,
    required this.thumbnail,
    required this.weeks,
    required this.startDate,
    required this.endDate,
  });

  String id;
  int index;
  String title;
  String description;
  String vimeoId;
  String thumbnail;
  String startDate;
  String endDate;
  List<Week> weeks = [];
  // List<dynamic> weeks = [];
}
