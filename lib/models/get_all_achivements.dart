// To parse this JSON data, do
//
//     final achievementModel = achievementModelFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';

List<AchievementModel> achievementModelFromJson(String str) =>
    List<AchievementModel>.from(
        json.decode(str).map((x) => AchievementModel.fromJson(x)));

String achievementModelToJson(List<AchievementModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AchievementModel {
  String? id;
  String? title;
  String? thumbnail;
  String? description;
  double? currentValue;
  List<Achievement>? achievements;

  AchievementModel({
    this.id,
    this.title,
    this.currentValue,
    this.achievements,
    this.thumbnail,
    this.description,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json["id"],
      title: json["title"],
      currentValue: double.parse("${json["currentValue"]}"),
      description: json["description"],
      thumbnail: json["thumbnail"],
      achievements: json["achievements"] == null
          ? []
          : List<Achievement>.from(
              json["achievements"]!.map((x) => Achievement.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "thumbnail": thumbnail,
        "title": title,
        "currentValue": currentValue,
        "achievements": achievements == null
            ? []
            : List<dynamic>.from(achievements!.map((x) => x.toJson())),
      };
}

class Achievement {
  int? index;
  AchievementId? achievementAchievementId;
  String? id;
  String? achievementId;
  bool? achieved;
  String? achievedDate;

  Achievement({
    this.index,
    this.achievementAchievementId,
    this.id,
    this.achievementId,
    this.achieved,
    this.achievedDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        index: json["index"],
        achievementAchievementId: json["achievementId"] == null
            ? null
            : AchievementId.fromJson(json["achievementId"]),
        id: json["_id"],
        achievementId: json["id"],
        achieved: json["achieved"] ?? false,
        achievedDate: json["achievedDate"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "achievementId": achievementAchievementId?.toJson(),
        "_id": id,
        "id": achievementId,
        "achieved": achieved,
        "achievedDate": achievedDate,
      };
}

class AchievementId {
  String? id;
  String? title;
  String? image;
  String? targettype;
  Target? target;
  int? value;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? targettypeRef;
  String? achievementIdId;

  AchievementId({
    this.id,
    this.title,
    this.image,
    this.targettype,
    this.target,
    this.value,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.targettypeRef,
    this.achievementIdId,
  });

  factory AchievementId.fromJson(Map<String, dynamic> json) => AchievementId(
        id: json["_id"],
        title: json["title"],
        image: json["image"],
        targettype: json["targettype"],
        target: json["target"] == null ? null : Target.fromJson(json["target"]),
        value: json["value"],
        description: json["description"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        targettypeRef: json["targettypeRef"],
        achievementIdId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "image": image,
        "targettype": targettype,
        "target": target?.toJson(),
        "value": value,
        "description": description,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "targettypeRef": targettypeRef,
        "id": achievementIdId,
      };
}

class Target {
  String? id;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? targetId;
  String? thumbnail;

  Target({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.targetId,
    this.thumbnail,
  });

  factory Target.fromJson(Map<String, dynamic> json) => Target(
        id: json["_id"],
        title: json["title"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        targetId: json["id"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": targetId,
        "thumbnail": thumbnail,
      };
}

// // To parse this JSON data, do
// //
// //     final achievementModel = achievementModelFromJson(jsonString);
//
// import 'dart:convert';
//
// List<AchievementModel> achievementModelFromJson(String str) =>
//     List<AchievementModel>.from(
//         json.decode(str).map((x) => AchievementModel.fromJson(x)));
//
// String achievementModelToJson(List<AchievementModel> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class AchievementId {
//   String? id;
//   String? title;
//   String? image;
//   AchievementModel? target;
//   int? value;
//   String? description;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? achievementIdId;
//
//   AchievementId({
//     this.id,
//     this.title,
//     this.image,
//     this.target,
//     this.value,
//     this.description,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.achievementIdId,
//   });
//
//   factory AchievementId.fromJson(Map<String, dynamic> json) => AchievementId(
//         id: json["_id"],
//         title: json["title"],
//         image: json["image"],
//         target: json["target"] == null
//             ? null
//             : AchievementModel.fromJson(json["target"]),
//         value: json["value"],
//         description: json["description"],
//         createdAt: json["createdAt"] == null
//             ? null
//             : DateTime.parse(json["createdAt"]),
//         updatedAt: json["updatedAt"] == null
//             ? null
//             : DateTime.parse(json["updatedAt"]),
//         v: json["__v"],
//         achievementIdId: json["id"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "title": title,
//         "image": image,
//         "target": target?.toJson(),
//         "value": value,
//         "description": description,
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//         "__v": v,
//         "id": achievementIdId,
//       };
// }
//
// class Achievement {
//   int? index;
//   AchievementId? achievementAchievementId;
//   String? id;
//   String? achievementId;
//
//   Achievement({
//     this.index,
//     this.achievementAchievementId,
//     this.id,
//     this.achievementId,
//   });
//
//   factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
//         index: json["index"],
//         achievementAchievementId: json["achievementId"] == null
//             ? null
//             : AchievementId.fromJson(json["achievementId"]),
//         id: json["_id"],
//         achievementId: json["id"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "index": index,
//         "achievementId": achievementAchievementId?.toJson(),
//         "_id": id,
//         "id": achievementId,
//       };
// }
//
// class AchievementModel {
//   String? id;
//   String? title;
//   List<Achievement>? achievements;
//   String? description;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? achievementModelId;
//
//   AchievementModel({
//     this.id,
//     this.title,
//     this.achievements,
//     this.description,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.achievementModelId,
//   });
//
//   factory AchievementModel.fromJson(Map<String, dynamic> json) =>
//       AchievementModel(
//         id: json["_id"],
//         title: json["title"],
//         achievements: json["achievements"] == null
//             ? []
//             : List<Achievement>.from(
//                 json["achievements"]!.map((x) => Achievement.fromJson(x))),
//         description: json["description"],
//         createdAt: json["createdAt"] == null
//             ? null
//             : DateTime.parse(json["createdAt"]),
//         updatedAt: json["updatedAt"] == null
//             ? null
//             : DateTime.parse(json["updatedAt"]),
//         v: json["__v"],
//         achievementModelId: json["id"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "_id": id,
//         "title": title,
//         "achievements": achievements == null
//             ? []
//             : List<dynamic>.from(achievements!.map((x) => x.toJson())),
//         "description": description,
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//         "__v": v,
//         "id": achievementModelId,
//       };
// }
