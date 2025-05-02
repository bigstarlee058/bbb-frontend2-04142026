// To parse this JSON data, do
//
//     final faQsModel = faQsModelFromJson(jsonString);

import 'dart:convert';

List<FaQsModel> faQsModelFromJson(String str) => List<FaQsModel>.from(json.decode(str).map((x) => FaQsModel.fromJson(x)));

String faQsModelToJson(List<FaQsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FaQsModel {
  String? id;
  String? question;
  String? answer;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? faQsModelId;

  FaQsModel({
    this.id,
    this.question,
    this.answer,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.faQsModelId,
  });

  factory FaQsModel.fromJson(Map<String, dynamic> json) => FaQsModel(
        id: json["_id"],
        question: json["question"],
        answer: json["answer"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        faQsModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "question": question,
        "answer": answer,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": faQsModelId,
      };
}
