// To parse this JSON data, do
//
//     final newVersionModel = newVersionModelFromJson(jsonString);

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
  Android? android;
  Android? ios;
  String? newVersionModelId;

  NewVersionModel({
    this.id,
    this.v,
    this.createdAt,
    this.latestVersion,
    this.updateTitle,
    this.updatedAt,
    this.updateMessage,
    this.android,
    this.ios,
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
        android:
            json["android"] == null ? null : Android.fromJson(json["android"]),
        ios: json["ios"] == null ? null : Android.fromJson(json["ios"]),
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
        "android": android?.toJson(),
        "ios": ios?.toJson(),
        "id": newVersionModelId,
      };
}

class Android {
  bool? forceUpdate;
  bool? showPopUp;
  String? version;

  Android({
    this.forceUpdate,
    this.version,
    this.showPopUp,
  });

  factory Android.fromJson(Map<String, dynamic> json) => Android(
        forceUpdate: json["forceUpdate"],
        showPopUp: json["showPopUp"],
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "forceUpdate": forceUpdate,
        "showPopUp": showPopUp,
        "version": version,
      };
}
