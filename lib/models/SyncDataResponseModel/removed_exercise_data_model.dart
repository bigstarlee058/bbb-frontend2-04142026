import 'dart:convert';

List<RemovedExerciseDataModel> removedExerciseDataModelFromJson(String str) =>
    List<RemovedExerciseDataModel>.from(json.decode(str).map((x) => RemovedExerciseDataModel.fromJson(x)));

String removedExerciseDataModelToJson(List<RemovedExerciseDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RemovedExerciseDataModel {
  String? id;
  String? userId;
  String? dataId;
  String? monthId;
  String? exerciseId;
  String? split;
  String? weekId;
  String? dayId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getRemoveExerciseModelId;

  RemovedExerciseDataModel({
    this.id,
    this.userId,
    this.dataId,
    this.monthId,
    this.exerciseId,
    this.split,
    this.weekId,
    this.dayId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getRemoveExerciseModelId,
  });

  factory RemovedExerciseDataModel.fromJson(Map<String, dynamic> json) => RemovedExerciseDataModel(
        id: json["_id"],
        userId: json["userId"],
        dataId: json["dataId"],
        monthId: json["monthId"],
        exerciseId: json["exerciseId"],
        split: json["split"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getRemoveExerciseModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "dataId": dataId,
        "monthId": monthId,
        "exerciseId": exerciseId,
        "split": split,
        "weekId": weekId,
        "dayId": dayId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getRemoveExerciseModelId,
      };
}
