import 'dart:convert';

AllExerciseModel allExerciseModelFromJson(String str) => AllExerciseModel.fromJson(json.decode(str));

String allExerciseModelToJson(AllExerciseModel data) => json.encode(data.toJson());

class AllExerciseModel {
  List<Exercise>? exercises;
  List<Category>? categories;
  List<Category>? equipments;

  AllExerciseModel({
    this.exercises,
    this.categories,
    this.equipments,
  });

  factory AllExerciseModel.fromJson(Map<String, dynamic> json) => AllExerciseModel(
        exercises: json["exercises"] == null ? [] : List<Exercise>.from(json["exercises"]!.map((x) => Exercise.fromJson(x))),
        categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
        equipments: json["equipments"] == null ? [] : List<Category>.from(json["equipments"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "exercises": exercises == null ? [] : List<dynamic>.from(exercises!.map((x) => x.toJson())),
        "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "equipments": equipments == null ? [] : List<dynamic>.from(equipments!.map((x) => x.toJson())),
      };
}

class Category {
  String? id;
  String? title;
  String? categoryId;

  Category({
    this.id,
    this.title,
    this.categoryId,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["_id"],
        title: json["title"],
        categoryId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "id": categoryId,
      };
}

class Exercise {
  String? id;
  String? title;
  String? vimeoId;
  String? thumbnail;
  String? description;
  List<String>? categories;
  String? guide;
  List<String>? relatedExercises;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  List<String>? usedEquipments;

  Exercise({
    this.id,
    this.title,
    this.vimeoId,
    this.thumbnail,
    this.description,
    this.categories,
    this.guide,
    this.relatedExercises,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.usedEquipments,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json["_id"],
        title: json["title"],
        vimeoId: json["vimeoId"],
        thumbnail: json["thumbnail"],
        description: json["description"],
        categories: json["categories"] == null ? [] : List<String>.from(json["categories"]!.map((x) => x)),
        guide: json["guide"],
        relatedExercises: json["relatedExercises"] == null ? [] : List<String>.from(json["relatedExercises"]!.map((x) => x)),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        usedEquipments: json["usedEquipments"] == null ? [] : List<String>.from(json["usedEquipments"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "vimeoId": vimeoId,
        "thumbnail": thumbnail,
        "description": description,
        "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x)),
        "guide": guide,
        "relatedExercises": relatedExercises == null ? [] : List<dynamic>.from(relatedExercises!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "usedEquipments": usedEquipments == null ? [] : List<dynamic>.from(usedEquipments!.map((x) => x)),
      };
}
