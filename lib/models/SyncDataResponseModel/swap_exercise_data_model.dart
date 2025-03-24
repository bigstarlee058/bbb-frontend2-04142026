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
  String? date;
  String? exerciseId;
  String? exerciseJson;
  String? insertIndex;
  String? createdAt;
  String? updatedAt;
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
        date: json["date"],
        exerciseId: json["exerciseId"],
        exerciseJson: json["exerciseJson"],
        insertIndex: json["insertIndex"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
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
        "date": date,
        "exerciseId": exerciseId,
        "exerciseJson": exerciseJson,
        "insertIndex": insertIndex,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "id": getSwapExerciseModelId,
      };
}
