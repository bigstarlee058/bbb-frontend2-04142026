import 'dart:convert';

List<AchievementsModel> achievementsModelFromJson(String str) =>
    List<AchievementsModel>.from(json.decode(str).map((x) => AchievementsModel.fromJson(x)));

String achievementsModelToJson(List<AchievementsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AchievementsModel {
  int? id;
  DateTime? achievementsDate;
  String? achievementsTitle;
  String? achievementsSubtitle;

  AchievementsModel({
    this.id,
    this.achievementsDate,
    this.achievementsTitle,
    this.achievementsSubtitle,
  });

  factory AchievementsModel.fromJson(Map<String, dynamic> json) => AchievementsModel(
        id: json["id"],
        achievementsDate: json["achievementsDate"] == null ? null : DateTime.parse(json["achievementsDate"]),
        achievementsTitle: json["achievementsTitle"],
        achievementsSubtitle: json["achievementsSubtitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "achievementsDate": achievementsDate?.toIso8601String(),
        "achievementsTitle": achievementsTitle,
        "achievementsSubtitle": achievementsSubtitle,
      };
}
