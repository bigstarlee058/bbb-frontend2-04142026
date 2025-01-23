import 'dart:convert';

List<ExerciseHistoryModel> exerciseHistoryModelFromJson(String str) =>
    List<ExerciseHistoryModel>.from(json.decode(str).map((x) => ExerciseHistoryModel.fromJson(x)));

String exerciseHistoryModelToJson(List<ExerciseHistoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExerciseHistoryModel {
  int? id;
  String? dataId;
  String? exerciseId;
  String? monthId;
  String? weekId;
  String? dayId;
  String? type;
  DateTime? date;
  String? status;
  String? split;

  ExerciseHistoryModel({
    this.id,
    this.dataId,
    this.exerciseId,
    this.monthId,
    this.weekId,
    this.dayId,
    this.type,
    this.date,
    this.status,
    this.split,
  });

  factory ExerciseHistoryModel.fromJson(Map<String, dynamic> json) => ExerciseHistoryModel(
        id: json["id"],
        dataId: json["dataId"],
        exerciseId: json["exerciseId"],
        monthId: json["monthId"],
        weekId: json["weekId"],
        dayId: json["dayId"],
        type: json["type"],
        date: json["date"] == null || json["date"].isEmpty ? null : DateTime.parse(json["date"]),
        status: json["status"],
        split: json["split"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dataId": dataId,
        "exerciseId": exerciseId,
        "monthId": monthId,
        "weekId": weekId,
        "dayId": dayId,
        "type": type,
        "date": date?.toIso8601String(),
        "status": status,
        "split": split,
      };
}
