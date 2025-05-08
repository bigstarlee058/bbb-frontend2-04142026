// // To parse this JSON data, do
// //
// //     final state = stateFromJson(jsonString);
//
// import 'dart:convert';
//
// List<State> stateFromJson(String str) => List<State>.from(json.decode(str).map((x) => State.fromJson(x)));
//
// String stateToJson(List<State> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class State {
//   String stateName;
//
//   State({
//     required this.stateName,
//   });
//
//   factory State.fromJson(Map<String, dynamic> json) => State(
//     stateName: json["state_name"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "state_name": stateName,
//   };
// }

// To parse this JSON data, do
//
//     final statesModel = statesModelFromJson(jsonString);

import 'dart:convert';

StatesModel statesModelFromJson(String str) => StatesModel.fromJson(json.decode(str));

String statesModelToJson(StatesModel data) => json.encode(data.toJson());

class StatesModel {
  List<String>? states;

  StatesModel({
    this.states,
  });

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
        states: json["states"] == null ? [] : List<String>.from(json["states"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "states": states == null ? [] : List<dynamic>.from(states!.map((x) => x)),
      };
}
