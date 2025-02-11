import 'dart:convert';

import 'package:bbb/models/MonthResponseModel/new_model.dart';

List<ExtraExerciseModel> extraExerciseModelFromJson(String str) =>
    List<ExtraExerciseModel>.from(json.decode(str).map((x) => ExtraExerciseModel.fromJson(x)));

String extraExerciseModelToJson(List<ExtraExerciseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExtraExerciseModel {
  int? id;
  String? dataId;
  String? split;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? exerciseId;
  ExerciseDataModel? exerciseJson;

  ExtraExerciseModel({
    this.id,
    this.dataId,
    this.split,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.exerciseId,
    this.exerciseJson,
  });

  factory ExtraExerciseModel.fromJson(Map<String, dynamic> json) => ExtraExerciseModel(
        id: json["id"],
        dataId: json["dataId"],
        split: json["split"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        exerciseId: json["exerciseId"],
        exerciseJson: ExerciseDataModel.fromJson(jsonDecode(json["exerciseJson"])),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dataId": dataId,
        "split": split,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "exerciseId": exerciseId,
        "exerciseJson": exerciseJson?.toJson(),
      };
}
