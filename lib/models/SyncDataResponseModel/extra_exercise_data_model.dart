import 'dart:convert';

List<ExtraExerciseDataModel> extraExerciseDataModelFromJson(String str) =>
    List<ExtraExerciseDataModel>.from(json.decode(str).map((x) => ExtraExerciseDataModel.fromJson(x)));

String extraExerciseDataModelToJson(List<ExtraExerciseDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExtraExerciseDataModel {
  String? id;
  String? userId;
  String? dataId;
  String? split;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? exerciseId;
  String? exerciseJson;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getExtraExerciseModelId;

  ExtraExerciseDataModel({
    this.id,
    this.userId,
    this.dataId,
    this.split,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.exerciseId,
    this.exerciseJson,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getExtraExerciseModelId,
  });

  factory ExtraExerciseDataModel.fromJson(Map<String, dynamic> json) => ExtraExerciseDataModel(
        id: json["_id"],
        userId: json["userId"],
        dataId: json["dataId"],
        split: json["split"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        exerciseId: json["exerciseId"],
        exerciseJson: json["exerciseJson"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getExtraExerciseModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "dataId": dataId,
        "split": split,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "exerciseId": exerciseId,
        "exerciseJson": exerciseJson,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getExtraExerciseModelId,
      };
}
