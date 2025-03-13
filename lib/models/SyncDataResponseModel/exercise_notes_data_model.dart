import 'dart:convert';

List<ExerciseNotesDataModel> exerciseNotesModelFromJson(String str) =>
    List<ExerciseNotesDataModel>.from(json.decode(str).map((x) => ExerciseNotesDataModel.fromJson(x)));

String exerciseNotesModelToJson(List<ExerciseNotesDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExerciseNotesDataModel {
  String? id;
  String? userId;
  String? exerciseId;
  DateTime? date;
  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? getExerciseNotesModelId;

  ExerciseNotesDataModel({
    this.id,
    this.userId,
    this.exerciseId,
    this.date,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getExerciseNotesModelId,
  });

  factory ExerciseNotesDataModel.fromJson(Map<String, dynamic> json) => ExerciseNotesDataModel(
        id: json["_id"],
        userId: json["userId"],
        exerciseId: json["exerciseId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        note: json["note"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        getExerciseNotesModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "exerciseId": exerciseId,
        "date": date?.toIso8601String(),
        "note": note,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": getExerciseNotesModelId,
      };
}
