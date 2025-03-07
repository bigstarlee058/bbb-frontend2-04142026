import 'dart:convert';

List<DayStatusDataModel> dayStatusDataModelFromJson(String str) =>
    List<DayStatusDataModel>.from(json.decode(str).map((x) => DayStatusDataModel.fromJson(x)));

String dayStatusDataModelToJson(List<DayStatusDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DayStatusDataModel {
  String? id;
  String? userId;
  String? split;
  String? dataId;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? status;
  String? title;
  DateTime? startTime;
  String? endTime;
  String? type;
  String? totalWeight;
  String? completedExerciseCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getDayStautsModelId;

  DayStatusDataModel({
    this.id,
    this.userId,
    this.split,
    this.dataId,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.status,
    this.title,
    this.startTime,
    this.endTime,
    this.type,
    this.totalWeight,
    this.completedExerciseCount,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getDayStautsModelId,
  });

  factory DayStatusDataModel.fromJson(Map<String, dynamic> json) => DayStatusDataModel(
        id: json["_id"],
        userId: json["userId"],
        split: json["split"],
        dataId: json["dataId"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        title: json["title"],
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"],
        type: json["type"],
        totalWeight: json["totalWeight"],
        completedExerciseCount: json["completedExerciseCount"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getDayStautsModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "split": split,
        "dataId": dataId,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "status": status,
        "title": title,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime,
        "type": type,
        "totalWeight": totalWeight,
        "completedExerciseCount": completedExerciseCount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getDayStautsModelId,
      };
}
