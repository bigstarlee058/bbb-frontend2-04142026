import 'dart:convert';

List<DayHistoryModel> dayHistoryModelFromJson(String str) =>
    List<DayHistoryModel>.from(json.decode(str).map((x) => DayHistoryModel.fromJson(x)));

String dayHistoryModelToJson(List<DayHistoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DayHistoryModel {
  int? id;
  String? dataId;
  String? split;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? status;
  DateTime? startTime;
  DateTime? endTime;
  String? workoutTime;
  String? type;

  DayHistoryModel({
    this.id,
    this.dataId,
    this.split,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.status,
    this.startTime,
    this.endTime,
    this.workoutTime,
    this.type,
  });

  factory DayHistoryModel.fromJson(Map<String, dynamic> json) => DayHistoryModel(
        id: json["id"],
        dataId: json["dataId"],
        split: json["split"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null || json["date"] == "" ? null : DateTime.parse(json["date"]),
        status: json["status"],
        startTime: json["startTime"] == null || json["startTime"] == "" ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null || json["endTime"] == "" ? null : DateTime.parse(json["endTime"]),
        workoutTime: json["workoutTime"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dataId": dataId,
        "split": split,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "status": status,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "workoutTime": workoutTime,
        "type": type,
      };
}
