// To parse this JSON data, do
//
//     final getChooseWorkoutModel = getChooseWorkoutModelFromJson(jsonString);

import 'dart:convert';

GetChooseWorkoutModel getChooseWorkoutModelFromJson(String str) => GetChooseWorkoutModel.fromJson(json.decode(str));

String getChooseWorkoutModelToJson(GetChooseWorkoutModel data) => json.encode(data.toJson());

class GetChooseWorkoutModel {
  String? id;
  int? v;
  DateTime? createdAt;
  String? description;
  String? title;
  DateTime? updatedAt;
  String? vimeoId;
  List<FileElement>? files;

  GetChooseWorkoutModel({
    this.id,
    this.v,
    this.createdAt,
    this.description,
    this.title,
    this.updatedAt,
    this.vimeoId,
    this.files,
  });

  factory GetChooseWorkoutModel.fromJson(Map<String, dynamic> json) => GetChooseWorkoutModel(
        id: json["_id"],
        v: json["__v"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        description: json["description"],
        title: json["title"],
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        vimeoId: json["vimeoId"],
        files: json["files"] == null ? [] : List<FileElement>.from(json["files"]!.map((x) => FileElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "description": description,
        "title": title,
        "updatedAt": updatedAt?.toIso8601String(),
        "vimeoId": vimeoId,
        "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x.toJson())),
      };
}

class FileElement {
  String? quality;
  String? rendition;
  String? type;
  int? width;
  int? height;
  String? link;
  DateTime? createdTime;
  int? fps;
  int? size;
  dynamic md5;
  String? publicName;
  String? sizeShort;
  String? linkSecure;

  FileElement({
    this.quality,
    this.rendition,
    this.type,
    this.width,
    this.height,
    this.link,
    this.createdTime,
    this.fps,
    this.size,
    this.md5,
    this.publicName,
    this.sizeShort,
    this.linkSecure,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        quality: json["quality"],
        rendition: json["rendition"],
        type: json["type"],
        width: json["width"],
        height: json["height"],
        link: json["link"],
        createdTime: json["created_time"] == null ? null : DateTime.parse(json["created_time"]),
        fps: json["fps"],
        size: json["size"],
        md5: json["md5"],
        publicName: json["public_name"],
        sizeShort: json["size_short"],
        linkSecure: json["link_secure"],
      );

  Map<String, dynamic> toJson() => {
        "quality": quality,
        "rendition": rendition,
        "type": type,
        "width": width,
        "height": height,
        "link": link,
        "created_time": createdTime?.toIso8601String(),
        "fps": fps,
        "size": size,
        "md5": md5,
        "public_name": publicName,
        "size_short": sizeShort,
        "link_secure": linkSecure,
      };
}
