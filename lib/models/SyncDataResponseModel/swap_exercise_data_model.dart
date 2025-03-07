import 'dart:convert';

List<SwapExerciseDataModel> swapExerciseDataModelFromJson(String str) =>
    List<SwapExerciseDataModel>.from(json.decode(str).map((x) => SwapExerciseDataModel.fromJson(x)));

String swapExerciseDataModelToJson(List<SwapExerciseDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SwapExerciseDataModel {
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
  String? insertIndex;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getSwapExerciseModelId;

  SwapExerciseDataModel({
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
    this.insertIndex,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getSwapExerciseModelId,
  });

  factory SwapExerciseDataModel.fromJson(Map<String, dynamic> json) => SwapExerciseDataModel(
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
        insertIndex: json["insertIndex"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getSwapExerciseModelId: json["id"],
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
        "insertIndex": insertIndex,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getSwapExerciseModelId,
      };
}
