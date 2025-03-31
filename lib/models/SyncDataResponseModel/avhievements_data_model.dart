import 'dart:convert';

List<AchievementsDataModel> achievementsDataModelFromJson(String str) =>
    List<AchievementsDataModel>.from(json.decode(str).map((x) => AchievementsDataModel.fromJson(x)));

String achievementsDataModelToJson(List<AchievementsDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AchievementsDataModel {
  String? id;
  String? userId;
  DateTime? achievementsDate;
  String? achievementsTitle;
  String? achievementsSubtitle;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? achievementsDataModelId;

  AchievementsDataModel({
    this.id,
    this.userId,
    this.achievementsDate,
    this.achievementsTitle,
    this.achievementsSubtitle,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.achievementsDataModelId,
  });

  factory AchievementsDataModel.fromJson(Map<String, dynamic> json) => AchievementsDataModel(
        id: json["_id"],
        userId: json["userId"],
        achievementsDate: json["achievements_date"] == null ? null : DateTime.parse(json["achievements_date"]),
        achievementsTitle: json["achievements_title"],
        achievementsSubtitle: json["achievements_subtitle"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        achievementsDataModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "achievements_date": achievementsDate?.toIso8601String(),
        "achievements_title": achievementsTitle,
        "achievements_subtitle": achievementsSubtitle,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": achievementsDataModelId,
      };
}
