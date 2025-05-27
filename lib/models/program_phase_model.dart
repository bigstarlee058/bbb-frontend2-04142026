// To parse this JSON data, do
//
//     final programPhaseModel = programPhaseModelFromJson(jsonString);

import 'dart:convert';

ProgramPhaseModel programPhaseModelFromJson(String str) => ProgramPhaseModel.fromJson(json.decode(str));

String programPhaseModelToJson(ProgramPhaseModel data) => json.encode(data.toJson());

class ProgramPhaseModel {
  Phase? phasesmaininfo;
  List<Phase>? phases;

  ProgramPhaseModel({
    this.phasesmaininfo,
    this.phases,
  });

  factory ProgramPhaseModel.fromJson(Map<String, dynamic> json) => ProgramPhaseModel(
        phasesmaininfo: json["phasesmaininfo"] == null ? null : Phase.fromJson(json["phasesmaininfo"]),
        phases: json["phases"] == null ? [] : List<Phase>.from(json["phases"]!.map((x) => Phase.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "phasesmaininfo": phasesmaininfo?.toJson(),
        "phases": phases == null ? [] : List<dynamic>.from(phases!.map((x) => x.toJson())),
      };
}

class Phase {
  String? id;
  String? title;
  String? thumbnail;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? phaseId;
  String? contenttitle;

  Phase({
    this.id,
    this.title,
    this.thumbnail,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.phaseId,
    this.contenttitle,
  });

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
        id: json["_id"],
        title: json["title"],
        thumbnail: json["thumbnail"],
        description: json["description"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        phaseId: json["id"],
        contenttitle: json["contenttitle"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "thumbnail": thumbnail,
        "description": description,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "id": phaseId,
        "contenttitle": contenttitle,
      };
}
