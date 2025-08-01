import 'dart:convert';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';

List<RadarChartHistoryModel> radarChartHistoryModelFromJson(String str) =>
    List<RadarChartHistoryModel>.from(
        json.decode(str).map((x) => RadarChartHistoryModel.fromJson(x)));

String radarChartHistoryModelToJson(List<RadarChartHistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RadarChartHistoryModel {
  String? exerciseId;
  String? exerciseName;
  List<ExerciseHistoryDataModel>? exerciseHistoryData;

  RadarChartHistoryModel({
    this.exerciseId,
    this.exerciseName,
    this.exerciseHistoryData,
  });

  factory RadarChartHistoryModel.fromJson(Map<String, dynamic> json) =>
      RadarChartHistoryModel(
        exerciseId: json["exerciseId"],
        exerciseName: json["exerciseName"],
        exerciseHistoryData: json["exerciseHistoryData"] == null
            ? []
            : List<ExerciseHistoryDataModel>.from(json["exerciseHistoryData"]!
                .map((x) => ExerciseHistoryDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "exerciseId": exerciseId,
        "exerciseName": exerciseName,
        "exerciseHistoryData": exerciseHistoryData == null
            ? []
            : List<dynamic>.from(exerciseHistoryData!.map((x) => x.toJson())),
      };
}
