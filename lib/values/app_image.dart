import 'package:bbb/main.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AppImage {
  static Widget imageLogin({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[1]["image"],
      imageKey: allImages[1]["key"],
    );
  }

  static Widget imageSignup({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[2]["image"],
      imageKey: allImages[2]["key"],
    );
  }

  static Widget imageEmailConfirm({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[3]["image"],
      imageKey: allImages[3]["key"],
    );
  }

  static Widget imageAchievement({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[4]["image"],
      imageKey: allImages[4]["key"],
    );
  }

  static Widget imageApparel({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[5]["image"],
      imageKey: allImages[5]["key"],
    );
  }

  static Widget imageExerciseLibrary({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[6]["image"],
      imageKey: allImages[6]["key"],
    );
  }

  static Widget imageFaQs({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[7]["image"],
      imageKey: allImages[7]["key"],
    );
  }

  static Widget imageForgot({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[8]["image"],
      imageKey: allImages[8]["key"],
    );
  }

  static Widget imageGraphs({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[9]["image"],
      imageKey: allImages[9]["key"],
    );
  }

  static Widget imageMonthView({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[10]["image"],
      imageKey: allImages[10]["key"],
    );
  }

  static Widget imageMyProfle({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[11]["image"],
      imageKey: allImages[11]["key"],
    );
  }

  static Widget imageProfile({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[12]["image"],
      imageKey: allImages[12]["key"],
    );
  }

  static Widget imageSetting({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[13]["image"],
      imageKey: allImages[13]["key"],
    );
  }

  static Widget imageStreakCalendar({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[14]["image"],
      imageKey: allImages[14]["key"],
    );
  }

  static Widget imageToday({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[15]["image"],
      imageKey: allImages[15]["key"],
    );
  }

  static Widget imageTools({Widget? child}) {
    return Utils.appImage(
      child: child,
      Size(ScreenUtil.horizontalScale(100), ScreenUtil.verticalScale(100)),
      image: allImages[16]["image"],
      imageKey: allImages[16]["key"],
    );
  }
}
