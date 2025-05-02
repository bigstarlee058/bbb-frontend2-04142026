// To parse this JSON data, do
//
//     final getChooseEquipmentModel = getChooseEquipmentModelFromJson(jsonString);

import 'dart:convert';

GetChooseEquipmentModel getChooseEquipmentModelFromJson(String str) => GetChooseEquipmentModel.fromJson(json.decode(str));

String getChooseEquipmentModelToJson(GetChooseEquipmentModel data) => json.encode(data.toJson());

class GetChooseEquipmentModel {
  String? id;
  int? v;
  DateTime? createdAt;
  String? description;
  String? title;
  DateTime? updatedAt;
  String? vimeoId;
  List<FileElement>? files;

  GetChooseEquipmentModel({
    this.id,
    this.v,
    this.createdAt,
    this.description,
    this.title,
    this.updatedAt,
    this.vimeoId,
    this.files,
  });

  factory GetChooseEquipmentModel.fromJson(Map<String, dynamic> json) => GetChooseEquipmentModel(
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
