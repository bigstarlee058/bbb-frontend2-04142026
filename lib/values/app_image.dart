import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AppImage {
  static Widget _safeImage(DataProvider value, int index, {Widget? child}) {
    return (value.allImageList.length > index)
        ? Utils.appImage(
            child: child,
            Size(
              ScreenUtil.horizontalScale(100),
              ScreenUtil.verticalScale(100),
            ),
            image: value.allImageList[index]["image"],
            imageKey: value.allImageList[index]["key"],
          )
        : const SizedBox();
  }

  static Widget imageLogin(DataProvider value, {Widget? child}) =>
      _safeImage(value, 1, child: child);

  static Widget imageSignup(DataProvider value, {Widget? child}) =>
      _safeImage(value, 2, child: child);

  static Widget imageEmailConfirm(DataProvider value, {Widget? child}) =>
      _safeImage(value, 3, child: child);

  static Widget imageAchievement(DataProvider value, {Widget? child}) =>
      _safeImage(value, 4, child: child);

  static Widget imageApparel(DataProvider value, {Widget? child}) =>
      _safeImage(value, 5, child: child);

  static Widget imageExerciseLibrary(DataProvider value, {Widget? child}) =>
      _safeImage(value, 6, child: child);

  static Widget imageFaQs(DataProvider value, {Widget? child}) =>
      _safeImage(value, 7, child: child);

  static Widget imageForgot(DataProvider value, {Widget? child}) =>
      _safeImage(value, 8, child: child);

  static Widget imageGraphs(DataProvider value, {Widget? child}) =>
      _safeImage(value, 9, child: child);

  static Widget imageMonthView(DataProvider value, {Widget? child}) =>
      _safeImage(value, 10, child: child);

  static Widget imageMyProfle(DataProvider value, {Widget? child}) =>
      _safeImage(value, 11, child: child);

  static Widget imageProfile(DataProvider value, {Widget? child}) =>
      _safeImage(value, 12, child: child);

  static Widget imageSetting(DataProvider value, {Widget? child}) =>
      _safeImage(value, 13, child: child);

  static Widget imageStreakCalendar(DataProvider value, {Widget? child}) =>
      _safeImage(value, 14, child: child);

  static Widget imageToday(DataProvider value, {Widget? child}) =>
      _safeImage(value, 15, child: child);

  static Widget imageTools(DataProvider value, {Widget? child}) =>
      _safeImage(value, 16, child: child);
}
