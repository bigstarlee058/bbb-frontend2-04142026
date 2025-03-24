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
  String? date;
  String? exerciseId;
  String? exerciseJson;
  String? createdAt;
  String? updatedAt;
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
        date: json["date"],
        exerciseId: json["exerciseId"],
        exerciseJson: json["exerciseJson"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
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
        "date": date,
        "exerciseId": exerciseId,
        "exerciseJson": exerciseJson,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "id": getExtraExerciseModelId,
      };
}
