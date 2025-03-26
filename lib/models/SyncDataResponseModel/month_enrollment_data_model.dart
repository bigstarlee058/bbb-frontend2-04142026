// To parse this JSON data, do
//
//     final monthEnrollmentDataModel = monthEnrollmentDataModelFromJson(jsonString);

import 'dart:convert';

List<MonthEnrollmentDataModel> monthEnrollmentDataModelFromJson(String str) =>
    List<MonthEnrollmentDataModel>.from(json.decode(str).map((x) => MonthEnrollmentDataModel.fromJson(x)));

String monthEnrollmentDataModelToJson(List<MonthEnrollmentDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MonthEnrollmentDataModel {
  String? id;
  int? index;
  DateTime? startDate;
  DateTime? endDate;

  MonthEnrollmentDataModel({
    this.id,
    this.index,
    this.startDate,
    this.endDate,
  });

  factory MonthEnrollmentDataModel.fromJson(Map<String, dynamic> json) => MonthEnrollmentDataModel(
        id: json["_id"],
        index: json["index"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "index": index,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
      };
}
