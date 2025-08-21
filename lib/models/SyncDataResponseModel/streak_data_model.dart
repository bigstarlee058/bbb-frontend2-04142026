import 'dart:convert';

StreakDataModel streakDataModelFromJson(String str) =>
    StreakDataModel.fromJson(json.decode(str));

String streakDataModelToJson(StreakDataModel data) =>
    json.encode(data.toJson());

class StreakDataModel {
  String? id;
  String? userId;
  int? v;
  String? count;
  DateTime? createdAt;
  DateTime? updatedAt;

  StreakDataModel({
    this.id,
    this.userId,
    this.v,
    this.count,
    this.createdAt,
    this.updatedAt,
  });

  factory StreakDataModel.fromJson(Map<String, dynamic> json) =>
      StreakDataModel(
        id: json["_id"],
        userId: json["userId"],
        v: json["__v"],
        count: json["count"].toString(),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "__v": v,
        "count": count,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
