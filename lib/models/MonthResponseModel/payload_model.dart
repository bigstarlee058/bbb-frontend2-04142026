import 'dart:convert';

PayloadModel payloadModelFromJson(String str) => PayloadModel.fromJson(json.decode(str));

String payloadModelToJson(PayloadModel data) => json.encode(data.toJson());

class PayloadModel {
  String? name;
  String? exerciseId;
  int? exerciseIndex;
  String? monthId;
  String? weekId;
  String? dayId;
  int? weekIndex;
  int? dayIndex;
  String? circuitIndex;
  String? index;
  String? subIndex;
  String? dataId;
  bool? isPumpday;
  bool? isCircuit;

  PayloadModel({
    this.name,
    this.exerciseId,
    this.exerciseIndex,
    this.monthId,
    this.weekId,
    this.dayId,
    this.weekIndex,
    this.dayIndex,
    this.isPumpday,
    this.circuitIndex,
    this.isCircuit,
    this.index,
    this.dataId,
    this.subIndex,
  });

  factory PayloadModel.fromJson(Map<String, dynamic> json) => PayloadModel(
        name: json["name"],
        exerciseId: json["exercise_id"],
        exerciseIndex: json["exercise_index"],
        monthId: json["month_id"],
        weekId: json["week_id"],
        dayId: json["day_id"],
        weekIndex: json["week_index"],
        dayIndex: json["day_index"],
        isPumpday: json["is_pumpday"],
        isCircuit: json["is_circuit"],
        circuitIndex: json["circuit_index"],
        index: json["index"],
        subIndex: json["subIndex"],
        dataId: json["dataId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "exercise_id": exerciseId,
        "exercise_index": exerciseIndex,
        "month_id": monthId,
        "week_id": weekId,
        "day_id": dayId,
        "week_index": weekIndex,
        "day_index": dayIndex,
        "is_pumpday": isPumpday,
        "is_circuit": isCircuit,
        "circuit_index": circuitIndex,
        "index": index,
        "subIndex": subIndex,
        "dataId": dataId,
      };
}
