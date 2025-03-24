import 'dart:convert';

List<ExtraSetDataModel> extraSetDataModelFromJson(String str) =>
    List<ExtraSetDataModel>.from(json.decode(str).map((x) => ExtraSetDataModel.fromJson(x)));

String extraSetDataModelToJson(List<ExtraSetDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExtraSetDataModel {
  String? id;
  String? userId;
  String? dataId;
  String? date;
  String? sets;
  String? reps;
  String? weight;
  String? rest;
  String? load;
  String? type;
  String? extraId;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? getExtraSetModelId;

  ExtraSetDataModel({
    this.id,
    this.userId,
    this.dataId,
    this.date,
    this.sets,
    this.reps,
    this.weight,
    this.rest,
    this.load,
    this.type,
    this.extraId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.getExtraSetModelId,
  });

  factory ExtraSetDataModel.fromJson(Map<String, dynamic> json) => ExtraSetDataModel(
        id: json["_id"],
        userId: json["userId"],
        dataId: json["dataId"],
        date: json["date"],
        sets: json["sets"],
        reps: json["reps"],
        weight: json["weight"],
        rest: json["rest"],
        load: json["load"],
        type: json["type"],
        extraId: json["extraId"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
        getExtraSetModelId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "dataId": dataId,
        "date": date,
        "sets": sets,
        "reps": reps,
        "weight": weight,
        "rest": rest,
        "load": load,
        "type": type,
        "extraId": extraId,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "id": getExtraSetModelId,
      };
}
