import 'dart:convert';

import 'package:bbb/models/MonthResponseModel/new_model.dart';

List<SwapExerciseModel> swapExerciseModelFromJson(String str) =>
    List<SwapExerciseModel>.from(json.decode(str).map((x) => SwapExerciseModel.fromJson(x)));

String swapExerciseModelToJson(List<SwapExerciseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SwapExerciseModel {
  int? id;
  String? dataId;
  String? split;
  String? monthId;
  String? weekId;
  String? dayId;
  DateTime? date;
  String? exerciseId;
  ExerciseDataModel? exerciseJson;
  String? insertIndex;

  SwapExerciseModel({
    this.id,
    this.dataId,
    this.split,
    this.monthId,
    this.weekId,
    this.dayId,
    this.date,
    this.exerciseId,
    this.insertIndex,
    this.exerciseJson,
  });

  factory SwapExerciseModel.fromJson(Map<String, dynamic> json) => SwapExerciseModel(
        id: json["id"],
        dataId: json["dataId"],
        split: json["split"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        exerciseId: json["exerciseId"],
        insertIndex: json["insertIndex"],
        exerciseJson: ExerciseDataModel.fromJson(jsonDecode(json["exerciseJson"])),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dataId": dataId,
        "split": split,
        "monthId": monthId,
        "weekId": weekId,
        "insertIndex": insertIndex,
        "dayId": dayId,
        "date": date?.toIso8601String(),
        "exerciseId": exerciseId,
        "exerciseJson": exerciseJson?.toJson(),
      };
}
