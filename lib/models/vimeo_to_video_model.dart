// To parse this JSON data, do
//
//     final vimeoToVideoModel = vimeoToVideoModelFromJson(jsonString);

import 'dart:convert';

VimeoToVideoModel vimeoToVideoModelFromJson(String str) =>
    VimeoToVideoModel.fromJson(json.decode(str));

String vimeoToVideoModelToJson(VimeoToVideoModel data) =>
    json.encode(data.toJson());

class VimeoToVideoModel {
  List<FileElement>? files;

  VimeoToVideoModel({
    this.files,
  });

  factory VimeoToVideoModel.fromJson(Map<String, dynamic> json) =>
      VimeoToVideoModel(
        files: json["files"] == null
            ? []
            : List<FileElement>.from(
                json["files"]!.map((x) => FileElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "files": files == null
            ? []
            : List<dynamic>.from(files!.map((x) => x.toJson())),
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
        createdTime: json["created_time"] == null
            ? null
            : DateTime.parse(json["created_time"]),
        fps: json["fps"].toInt(),
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
