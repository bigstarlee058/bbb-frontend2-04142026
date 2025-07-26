import 'dart:convert';

NewVersionModel newVersionModelFromJson(String str) =>
    NewVersionModel.fromJson(json.decode(str));

String newVersionModelToJson(NewVersionModel data) =>
    json.encode(data.toJson());

class NewVersionModel {
  String? id;
  int? v;
  DateTime? createdAt;
  String? latestVersion;
  String? updateTitle;
  DateTime? updatedAt;
  String? updateMessage;
  String? newVersionModelId;

  NewVersionModel({
    this.id,
    this.v,
    this.createdAt,
    this.latestVersion,
    this.updateTitle,
    this.updatedAt,
    this.updateMessage,
    this.newVersionModelId,
  });

  factory NewVersionModel.fromJson(Map<String, dynamic> json) =>
      NewVersionModel(
        id: json["_id"],
        v: json["__v"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        latestVersion: json["latest_version"],
        updateTitle: json["update_title"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        updateMessage: json["update_message"],
        newVersionModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "latest_version": latestVersion,
        "update_title": updateTitle,
        "updatedAt": updatedAt?.toIso8601String(),
        "update_message": updateMessage,
        "id": newVersionModelId,
      };
}
