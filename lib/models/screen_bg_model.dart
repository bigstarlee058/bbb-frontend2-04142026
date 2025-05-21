// To parse this JSON data, do
//
//     final screenBackgroundResponse = screenBackgroundResponseFromJson(jsonString);

import 'dart:convert';

ScreenBackgroundResponse screenBackgroundResponseFromJson(String str) => ScreenBackgroundResponse.fromJson(json.decode(str));

String screenBackgroundResponseToJson(ScreenBackgroundResponse data) => json.encode(data.toJson());

class ScreenBackgroundResponse {
  String? id;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? vimeoId;
  String? imgUrl;
  List<Slide>? slides;
  String? imageLogin;
  String? imageSignup;
  String? imageAchievement;
  String? imageApparel;
  String? imageDashboard;
  String? imageEmailConfirm;
  String? imageExerciseLibrary;
  String? imageFaQs;
  String? imageForgot;
  String? imageGraphs;
  String? imageMonthView;
  String? imageMyProfle;
  String? imageProfile;
  String? imageSetting;
  String? imageStreakCalendar;
  String? imageToday;
  String? imageTools;
  String? screenBackgroundResponseId;

  ScreenBackgroundResponse({
    this.id,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.vimeoId,
    this.imgUrl,
    this.slides,
    this.imageLogin,
    this.imageSignup,
    this.imageAchievement,
    this.imageApparel,
    this.imageDashboard,
    this.imageEmailConfirm,
    this.imageExerciseLibrary,
    this.imageFaQs,
    this.imageForgot,
    this.imageGraphs,
    this.imageMonthView,
    this.imageMyProfle,
    this.imageProfile,
    this.imageSetting,
    this.imageStreakCalendar,
    this.imageToday,
    this.imageTools,
    this.screenBackgroundResponseId,
  });

  factory ScreenBackgroundResponse.fromJson(Map<String, dynamic> json) => ScreenBackgroundResponse(
        id: json["_id"],
        v: json["__v"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        vimeoId: json["vimeoId"],
        imgUrl: json["imgUrl"],
        slides: json["slides"] == null ? [] : List<Slide>.from(json["slides"]!.map((x) => Slide.fromJson(x))),
        imageLogin: json["imageLogin"],
        imageSignup: json["imageSignup"],
        imageAchievement: json["imageAchievement"],
        imageApparel: json["imageApparel"],
        imageDashboard: json["imageDashboard"],
        imageEmailConfirm: json["imageEmailConfirm"],
        imageExerciseLibrary: json["imageExerciseLibrary"],
        imageFaQs: json["imageFAQs"],
        imageForgot: json["imageForgot"],
        imageGraphs: json["imageGraphs"],
        imageMonthView: json["imageMonthView"],
        imageMyProfle: json["imageMyProfle"],
        imageProfile: json["imageProfile"],
        imageSetting: json["imageSetting"],
        imageStreakCalendar: json["imageStreakCalendar"],
        imageToday: json["imageToday"],
        imageTools: json["imageTools"],
        screenBackgroundResponseId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "vimeoId": vimeoId,
        "imgUrl": imgUrl,
        "slides": slides == null ? [] : List<dynamic>.from(slides!.map((x) => x.toJson())),
        "imageLogin": imageLogin,
        "imageSignup": imageSignup,
        "imageAchievement": imageAchievement,
        "imageApparel": imageApparel,
        "imageDashboard": imageDashboard,
        "imageEmailConfirm": imageEmailConfirm,
        "imageExerciseLibrary": imageExerciseLibrary,
        "imageFAQs": imageFaQs,
        "imageForgot": imageForgot,
        "imageGraphs": imageGraphs,
        "imageMonthView": imageMonthView,
        "imageMyProfle": imageMyProfle,
        "imageProfile": imageProfile,
        "imageSetting": imageSetting,
        "imageStreakCalendar": imageStreakCalendar,
        "imageToday": imageToday,
        "imageTools": imageTools,
        "id": screenBackgroundResponseId,
      };
}

class Slide {
  String? title;
  String? description;
  String? id;
  String? slideId;

  Slide({
    this.title,
    this.description,
    this.id,
    this.slideId,
  });

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
        title: json["title"],
        description: json["description"],
        id: json["_id"],
        slideId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "_id": id,
        "id": slideId,
      };
}
