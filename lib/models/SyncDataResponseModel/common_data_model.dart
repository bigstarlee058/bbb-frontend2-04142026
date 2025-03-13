import 'dart:convert';

CommonDataModel commonDataModelFromJson(String str) => CommonDataModel.fromJson(json.decode(str));

String commonDataModelToJson(CommonDataModel data) => json.encode(data.toJson());

class CommonDataModel {
  bool? result;

  CommonDataModel({
    this.result,
  });

  factory CommonDataModel.fromJson(Map<String, dynamic> json) => CommonDataModel(
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
      };
}
