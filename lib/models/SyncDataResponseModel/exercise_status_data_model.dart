// To parse this JSON data, do
//
//     final getExerciseStatusModel = getExerciseStatusModelFromJson(jsonString);

import 'dart:convert';

List<ExerciseStatusDataModel> exerciseStatusDataModelFromJson(String str) =>
    List<ExerciseStatusDataModel>.from(json.decode(str).map((x) => ExerciseStatusDataModel.fromJson(x)));

String exerciseStatusDataModelToJson(List<ExerciseStatusDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExerciseStatusDataModel {
  String? id;
  String? userId;
  String? split;
  String? dataId;
  String? exerciseId;
  String? totalWeight;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? status;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getExerciseStatusModelId;

  ExerciseStatusDataModel({
    this.id,
    this.userId,
    this.split,
    this.dataId,
    this.exerciseId,
    this.totalWeight,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.status,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getExerciseStatusModelId,
  });

  factory ExerciseStatusDataModel.fromJson(Map<String, dynamic> json) => ExerciseStatusDataModel(
        id: json["_id"],
        userId: json["userId"],
        split: json["split"],
        dataId: json["dataId"],
        exerciseId: json["exerciseId"],
        totalWeight: json["totalWeight"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        type: json["type"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getExerciseStatusModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "split": split,
        "dataId": dataId,
        "exerciseId": exerciseId,
        "totalWeight": totalWeight,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "status": status,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getExerciseStatusModelId,
      };
}
