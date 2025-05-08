// // To parse this JSON data, do
// //
// //     final city = cityFromJson(jsonString);
//
// import 'dart:convert';
//
// List<City> cityFromJson(String str) => List<City>.from(json.decode(str).map((x) => City.fromJson(x)));
//
// String cityToJson(List<City> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class City {
//   String cityName;
//
//   City({
//     required this.cityName,
//   });
//
//   factory City.fromJson(Map<String, dynamic> json) => City(
//     cityName: json["city_name"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "city_name": cityName,
//   };
// }

// To parse this JSON data, do
//
//     final cityModel = cityModelFromJson(jsonString);

import 'dart:convert';

CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));

String cityModelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
  List<String>? cities;

  CityModel({
    this.cities,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        cities: json["cities"] == null ? [] : List<String>.from(json["cities"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "cities": cities == null ? [] : List<dynamic>.from(cities!.map((x) => x)),
      };
}
