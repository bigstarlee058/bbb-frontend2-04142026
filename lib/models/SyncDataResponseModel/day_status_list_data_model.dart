import 'dart:convert';

List<DayStatusListDataModel> dayStatusDataModelFromJson(String str) =>
    List<DayStatusListDataModel>.from(json.decode(str).map((x) => DayStatusListDataModel.fromJson(x)));

String dayStatusDataModelToJson(List<DayStatusListDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DayStatusListDataModel {
  String? id;
  String? userId;
  DateTime? date;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? dayStatusDataModelId;

  DayStatusListDataModel({
    this.id,
    this.userId,
    this.date,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.dayStatusDataModelId,
  });

  factory DayStatusListDataModel.fromJson(Map<String, dynamic> json) => DayStatusListDataModel(
        id: json["_id"],
        userId: json["userId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        dayStatusDataModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "date": date?.toIso8601String(),
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": dayStatusDataModelId,
      };
}
