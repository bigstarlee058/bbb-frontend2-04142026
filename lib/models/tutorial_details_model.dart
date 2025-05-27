// To parse this JSON data, do
//
//     final tutorialDataModel = tutorialDataModelFromJson(jsonString);

import 'dart:convert';

TutorialDataModel tutorialDataModelFromJson(String str) => TutorialDataModel.fromJson(json.decode(str));

String tutorialDataModelToJson(TutorialDataModel data) => json.encode(data.toJson());

class TutorialDataModel {
  String? id;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? vimeoId;
  String? imgUrl;
  String? description;
  String? title;
  String? thumbnail;
  List<FileElement>? files;

  TutorialDataModel({
    this.id,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.vimeoId,
    this.imgUrl,
    this.description,
    this.title,
    this.thumbnail,
    this.files,
  });

  factory TutorialDataModel.fromJson(Map<String, dynamic> json) => TutorialDataModel(
        id: json["_id"],
        v: json["__v"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        vimeoId: json["vimeoId"],
        imgUrl: json["imgUrl"],
        description: json["description"],
        title: json["title"],
        thumbnail: json["thumbnail"],
        files: json["files"] == null ? [] : List<FileElement>.from(json["files"]!.map((x) => FileElement.fromJson(x))),
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
