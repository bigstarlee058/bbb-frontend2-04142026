// To parse this JSON data, do
//
//     final exerciseHistoryDataModel = exerciseHistoryDataModelFromJson(jsonString);

import 'dart:convert';

List<ExerciseHistoryDataModel> exerciseHistoryDataModelFromJson(String str) =>
    List<ExerciseHistoryDataModel>.from(json.decode(str).map((x) => ExerciseHistoryDataModel.fromJson(x)));

String exerciseHistoryDataModelToJson(List<ExerciseHistoryDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExerciseHistoryDataModel {
  String? id;
  String? userId;
  String? split;
  String? dataId;
  String? exerciseId;
  String? extraId;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? status;
  String? sets;
  String? reps;
  String? weight;
  String? rest;
  String? load;
  String? type;
  String? effort;
  String? index;
  String? subIndex;
  String? totalSet;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? exerciseHistoryDataModelId;

  ExerciseHistoryDataModel({
    this.id,
    this.userId,
    this.split,
    this.dataId,
    this.exerciseId,
    this.extraId,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.status,
    this.sets,
    this.reps,
    this.weight,
    this.rest,
    this.load,
    this.effort,
    this.type,
    this.index,
    this.subIndex,
    this.createdAt,
    this.totalSet,
    this.updatedAt,
    this.v,
    this.exerciseHistoryDataModelId,
  });

  factory ExerciseHistoryDataModel.fromJson(Map<String, dynamic> json) => ExerciseHistoryDataModel(
        id: json["_id"],
        userId: json["userId"],
        split: json["split"],
        dataId: json["dataId"],
        exerciseId: json["exerciseId"],
        extraId: json["extraId"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        type: json["type"],
        totalSet: json["totalSet"],
        sets: json["sets"],
        reps: json["reps"],
        weight: json["weight"],
        rest: json["rest"],
        load: json["load"],
        effort: json["effort"],
        index: json["index"],
        subIndex: json["subIndex"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        exerciseHistoryDataModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "split": split,
        "dataId": dataId,
        "exerciseId": exerciseId,
        "extraId": extraId,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "type": type,
        "date": date?.toIso8601String(),
        "status": status,
        "sets": sets,
        "reps": reps,
        "weight": weight,
        "rest": rest,
        "load": load,
        "totalSet": totalSet,
        "effort": effort,
        "index": index,
        "subIndex": subIndex,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": exerciseHistoryDataModelId,
      };
}
