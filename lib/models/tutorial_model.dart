// To parse this JSON data, do
//
//     final tutorialModel = tutorialModelFromJson(jsonString);

import 'dart:convert';

List<TutorialModel> tutorialModelFromJson(String str) => List<TutorialModel>.from(json.decode(str).map((x) => TutorialModel.fromJson(x)));

String tutorialModelToJson(List<TutorialModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TutorialModel {
  String? id;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? vimeoId;
  String? imgUrl;
  String? description;
  String? title;
  String? thumbnail;
  String? tutorialModelId;

  TutorialModel({
    this.id,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.vimeoId,
    this.imgUrl,
    this.description,
    this.title,
    this.thumbnail,
    this.tutorialModelId,
  });

  factory TutorialModel.fromJson(Map<String, dynamic> json) => TutorialModel(
        id: json["_id"],
        v: json["__v"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        vimeoId: json["vimeoId"],
        imgUrl: json["imgUrl"],
        description: json["description"],
        title: json["title"],
        thumbnail: json["thumbnail"],
        tutorialModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "vimeoId": vimeoId,
        "imgUrl": imgUrl,
        "description": description,
        "title": title,
        "thumbnail": thumbnail,
        "id": tutorialModelId,
      };
}
