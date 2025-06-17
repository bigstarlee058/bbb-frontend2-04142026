import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/custom_slide_to_act.dart';
import 'package:bbb/components/expansion_panel.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/select_dropdown.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/excersie_detail_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/history_data_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/removed_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/swap_exercise_model.dart';
import 'package:bbb/pages/MonthView/TodayPage/circuits_view.dart';
import 'package:bbb/pages/MonthView/TodayPage/video_slider.dart';
import 'package:bbb/pages/MonthView/TodayPage/workout_card.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/scroll_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';

import '../../../models/MonthResponseModel/all_exercise_model.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> with SingleTickerProviderStateMixin {
  final today = DateTime.now();
  MonthProvider? monthProvider;
  String searchQuery = "";
  DataProvider? dataProvider;
  ScrollProvider? scrollProvider;

  List<ExerciseDataModel> exercises = [];
  List<RemovedExerciseModel> removedExercise = [];
  bool isCurrentDayCompleted = false;
  bool isCurrentDaySkipped = false;
  String currentDayTitle = '';
  MainPageProvider? mainPageProvider;
  bool loader = false;
  final GlobalKey<CustomSlideActionState> key = GlobalKey();

  bool isInit = true;

  bool isEditMode = false;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    scrollProvider = Provider.of<ScrollProvider>(context, listen: false);

    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await initData());
    super.initState();
  }

  Future<void> initData() async {
    mainPageProvider?.changeTab(1);

    final dayIndex = monthProvider!.overviewCurrentDay;
    await monthProvider?.fetchSingleDayHistoryLocalData();
    await monthProvider?.fetchDayStatusLocalData();
    await monthProvider?.fetchExerciseStatusLocalData();

    int nextWorkOutIndex = monthProvider!.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? int.parse(monthProvider!.weekDataModel!.dayList![dayIndex - 1]
                .toString()
                .replaceAll("Day ", "")
                .replaceAll(" Workout", "")) -
            1
        : 0;
    currentDayTitle = monthProvider!.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider!.weekDataModel!.dayList![dayIndex - 1];
    await monthProvider?.getRestDayData();

    await fetchExtraAddedExercise().then(
      (value) async {
        int nextWorkOutIndex =
            monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1].toString().contains("Workout")
                ? int.parse(monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1]
                        .toString()
                        .replaceAll("Day ", "")
                        .replaceAll(" Workout", "")) -
                    1
                : 0;
        currentDayTitle =
            monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1].toString().contains("Workout")
                ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
                : monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1];
        // fetchWarmupData();
        monthProvider?.fetchExerciseStatusLocalData();
        fetchRemovedExerciseLocalData();
        isCurrentDayCompleted = monthProvider?.dayHistoryDetails?.status == Status.completed;
        isCurrentDaySkipped = monthProvider?.dayHistoryDetails?.status == Status.skipped ||
            (monthProvider?.dayHistoryDetails == null &&
                monthProvider!.weekStatuses[(monthProvider!.week ?? 1) - 1] == WeekType.pastWeek) ||
            (monthProvider!.actualWeek! > 4 && monthProvider?.dayHistoryDetails?.status == Status.started);

        monthProvider?.fetchAllExercise();
      },
    );

    isInit = false;
    setState(() {});
  }

  Future<void> fetchExtraAddedExercise() async {
    setState(
      () {
        exercises = [];
        loader = true;
        exercises = monthProvider!.isPumpDay
            ? monthProvider!.pumpDayModel!.exercises!
            : monthProvider!.dayDataModel!.exercises ?? [];
      },
    );

    await monthProvider?.fetchExtraAddedExerciseData().then(
      (value) {
        if (monthProvider!.addedExerciseList.isNotEmpty) {
          for (var element in monthProvider!.addedExerciseList) {
            exercises.removeWhere((ele) => element.exerciseId == ele.exerciseId);
          }
          exercises.addAll(monthProvider!.addedExerciseList.map((e) => e.exerciseJson!));
        }
      },
    ).then(
      (value) async {
        try {
          await monthProvider?.fetchSwapExerciseData().then(
            (value) {
              if (monthProvider!.swapExerciseList.isNotEmpty) {
                for (var element in monthProvider!.swapExerciseList) {
                  exercises.removeAt(int.parse(element.insertIndex ?? "0"));
                  exercises.insert(int.parse(element.insertIndex ?? "0"), element.exerciseJson!);
                }
              }
            },
          );
        } catch (e) {
          log('e=====111=====>>>>>$e');
        }

        try {
          await monthProvider?.fetchAllRemovedExerciseLocalData().then(
            (value) {
              if (monthProvider!.allRemovedExercise.isNotEmpty) {
                String split = monthProvider
                        ?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
                        .toString()
                        .split(" ")[1] ??
                    "";

                String dataId =
                    "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

                for (var element in monthProvider!.allRemovedExercise) {
                  exercises
                      .removeWhere((exercise) => element.dataId == dataId && exercise.exerciseId == element.exerciseId);
                }
              }
            },
          );
        } catch (e) {
          log('e=====222=====>>>>>$e');
        }
      },
    );

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => setState(() => loader = false),
      );
    }
  }

  Future<void> onPressed(int exerciseIndex, String dataId, bool isLast) async {
    monthProvider?.selectedExercise == null;
    monthProvider?.exerciseDetailModel == null;
    monthProvider?.updateIsCircuit(false);
    monthProvider?.updateCircuit("", 0);
    monthProvider?.setSelectedExercise(exercises[exerciseIndex], exerciseIndex);
    monthProvider?.updateWarmUp(false, "");
    monthProvider?.updateIsLastExercise(isLast);
    // String isChecked = preferences.getString(SharedPreference.exerciseTutorial) ?? "";
    // if (isChecked != "true") {
    //   monthProvider?.tutorialOnInit(context);
    // }
    await Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
    monthProvider?.fetchExerciseSingleExerciseLocalData(dataId);
  }

  fetchRemovedExerciseLocalData() async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.removedExerciseHistory,
        monthId: "${monthProvider?.monthDataModel?.id}",
        weekId: "${monthProvider?.weekDataModel?.id}",
        split: split,
        dayId: "${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}}");
    if (data.isNotEmpty) {
      removedExercise =
          List<RemovedExerciseModel>.from(json.decode(jsonEncode(data)).map((x) => RemovedExerciseModel.fromJson(x)));
    } else {
      removedExercise = [];
    }
    monthProvider?.fetchAllRemovedExerciseLocalData();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
  }

  Future<void> removeExercise(String exerciseId) async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";
    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$exerciseId";
    final data = {
      "exerciseId": exerciseId,
      "dataId": dataId,
      "split": split,
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
    };
    ApiRepo.addRemovedExercise(body: data);
    await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.removedExerciseHistory);
    await fetchRemovedExerciseLocalData();

    if (monthProvider!.addedExerciseList.isNotEmpty) {
      ExtraExerciseModel data = monthProvider!.addedExerciseList
          .firstWhere((element) => element.dataId == dataId, orElse: () => ExtraExerciseModel());
      if (data.id != null) {
        ApiRepo.deleteExtraExercise(dataId: data.dataId ?? "");
        await DatabaseHelper().deleteSingleData(tableName: DatabaseHelper.extraExerciseHistory, id: data.dataId ?? "");
        await monthProvider?.fetchExtraAddedExerciseData();
      }
    }

    if (monthProvider!.swapExerciseList.isNotEmpty) {
      SwapExerciseModel data = monthProvider!.swapExerciseList
          .firstWhere((element) => element.dataId == dataId, orElse: () => SwapExerciseModel());
      if (data.id != null) {
        ApiRepo.deleteSwapExercise(dataId: data.dataId ?? "");
        await DatabaseHelper().deleteSingleData(tableName: DatabaseHelper.swapExerciseHistory, id: data.dataId ?? "");
        await monthProvider?.fetchSwapExerciseData();
      }
    }
    exercises.removeWhere((element) => element.exerciseId == exerciseId);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
  }

  @override
  void didChangeDependencies() {
    var contact = ModalRoute.of(context)?.settings.arguments;
    if (contact != null) {
      contact as Map;
      setState(() {});
    }
    super.didChangeDependencies();
  }

  int getTextLineCount({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final double lineHeight = textPainter.preferredLineHeight;
    final int lineCount = (textPainter.size.height / lineHeight).ceil();

    return lineCount;
  }

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (monthProvider?.isCurrentMonth != "Future") {
        monthProvider?.fetchAllDayStatusLocalData();
        monthProvider?.checkForPumpDay();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    context.watch<MainPageProvider>();
    ScreenUtil.init(context);

    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.axis == Axis.vertical) {
          WidgetsBinding.instance.scheduleFrameCallback(
            (timeStamp) {
              scrollProvider?.updateOffSet2(notification.metrics.pixels);
            },
          );
        }
        return true;
      },
      child: isInit
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            )
          : Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  // Container(
                  //   height: media.height,
                  //   width: media.width,
                  //   decoration: const BoxDecoration(
                  //     image: DecorationImage(image: AssetImage('assets/img/back.jpg'), fit: BoxFit.cover, opacity: 1),
                  //   ),
                  // ),
                  Utils.appImage(
                    media,
                    // dataProvider?.screenBackgroundResponse?.imageToday ?? "",
                    image: dataProvider!.cachedImageMap["imageToday"],

                    imageKey: "imageToday",
                  ),
                  // Container(
                  //   height: media.height / 1,
                  //   width: media.width,
                  //   decoration: const BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage('assets/img/back_dark.jpg'),
                  //       fit: BoxFit.cover,
                  //       opacity: 1,
                  //     ),
                  //   ),
                  // ),
                  Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Consumer<ScrollProvider>(
                          builder: (context, scrollValue, child) {
                            double targetHeight = scrollValue.scrollOffset2 > 40
                                ? ScreenUtil.verticalScale(3.2)
                                : ScreenUtil.verticalScale(4.8);

                            return Column(
                              children: [
                                SizedBox(height: Platform.isAndroid ? ScreenUtil.verticalScale(0.09) : 0),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: targetHeight,
                                  width: media.width,
                                  decoration: BoxDecoration(color: Colors.transparent),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: BackArrowWidget(
                                            bigSize: 4.8,
                                            position: scrollValue.scrollOffset2,
                                            onPress: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        monthProvider!.isCurrentMonth == "Future" ||
                                                isCurrentDayCompleted ||
                                                isCurrentDaySkipped ||
                                                monthProvider!.isCircuit ||
                                                monthProvider!.isPumpDay
                                            ? SizedBox()
                                            : Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  AnimatedContainer(
                                                    duration: Duration(milliseconds: 500),
                                                    margin: EdgeInsets.only(
                                                      left: ScreenUtil.horizontalScale(1.5),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: (scrollValue.scrollOffset2) > 25
                                                          ? Colors.transparent
                                                          : Color(0XFFd18a9b),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: SizedBox(
                                                      width: ScreenUtil.verticalScale(4.8),
                                                      height: ScreenUtil.verticalScale(4.8),
                                                      child: Center(
                                                        child: GestureDetector(
                                                          onTap: toggleEditMode,
                                                          child: Icon(
                                                            isEditMode ? Icons.close : Icons.edit,
                                                            color: Colors.white,
                                                            size: ScreenUtil.verticalScale(2.2),
                                                            // size: ScreenUtil
                                                            //     .verticalScale(
                                                            //         isEditMode
                                                            //             ? 2.5
                                                            //             : 2),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  isEditMode
                                                      ? Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            "Edit Mode",
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: ScreenUtil.verticalScale(2),
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: CommonStreakWithNotification(routeString: "today"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5)
                              ],
                            );
                          },
                        ),
                      ),
                      // AppBar(
                      //   titleSpacing: -5,
                      //   toolbarHeight: ScreenUtil.verticalScale(5.1) + 5,
                      //   surfaceTintColor: Colors.transparent,
                      //   backgroundColor: Colors.transparent,
                      //   centerTitle: false,
                      //   leading: Padding(
                      //     padding: const EdgeInsets.only(bottom: 5),
                      //     child: BackArrowWidget(
                      //       onPress: () {
                      //         Navigator.pop(context);
                      //       },
                      //     ),
                      //   ),
                      //   title: isCurrentDayCompleted ||
                      //           isCurrentDaySkipped ||
                      //           monthProvider!.isCircuit ||
                      //           monthProvider!.isPumpDay
                      //       ? SizedBox()
                      //       : Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Container(
                      //               margin: EdgeInsets.only(
                      //                   left: ScreenUtil.horizontalScale(4),
                      //                   bottom: 5),
                      //               decoration: const BoxDecoration(
                      //                 color: Color(0XFFd18a9b),
                      //                 shape: BoxShape.circle,
                      //               ),
                      //               child: SizedBox(
                      //                 width: ScreenUtil.verticalScale(4.2),
                      //                 height: ScreenUtil.verticalScale(4.2),
                      //                 child: Center(
                      //                   child: IconButton(
                      //                     padding: EdgeInsets.zero,
                      //                     icon: Icon(
                      //                       isEditMode ? Icons.close : Icons.edit,
                      //                       color: Colors.white,
                      //                       size: ScreenUtil.verticalScale(
                      //                           isEditMode ? 2.9 : 2.4),
                      //                     ),
                      //                     onPressed: toggleEditMode,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             isEditMode
                      //                 ? Padding(
                      //                     padding:
                      //                         const EdgeInsets.only(left: 10),
                      //                     child: Text(
                      //                       "Edit Mode",
                      //                       style: TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize:
                      //                               ScreenUtil.verticalScale(2),
                      //                           fontWeight: FontWeight.w600),
                      //                     ),
                      //                   )
                      //                 : SizedBox()
                      //           ],
                      //         ),
                      //   actions: [
                      //     Padding(
                      //         padding: EdgeInsets.only(right: 10),
                      //         child: const CommonStreakWithNotification(
                      //             routeString: "today"))
                      //   ],
                      // ),
                      Expanded(
                        child: SizedBox(
                          height: media.height,
                          child: SingleChildScrollView(
                            physics: NoBottomBounceScrollPhysics(),
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil.verticalScale(
                                            monthProvider!.isCircuit || monthProvider!.isPumpDay ? 1 : 2)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            monthProvider!.isPumpDay || monthProvider!.isCircuit
                                                ? SizedBox()
                                                : Text(
                                                    "Option ${monthProvider!.equipmentType}: ${monthProvider!.equipmentType == "A" ? "Fully equipped gym" : monthProvider?.equipmentType == "B" ? "Home gym" : "Dumbbells and bands"}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: ScreenUtil.verticalScale(1.9),
                                                    ),
                                                  ),
                                            Consumer<MonthProvider>(
                                              builder: (context, monthProvider, child) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5,
                                                      bottom: getTextLineCount(
                                                                  text: (monthProvider.isPumpDay
                                                                      ? monthProvider.pumpDayModel?.title ?? "Pump Day"
                                                                      : currentDayTitle),
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: ScreenUtil.horizontalScale(6),
                                                                      fontWeight: FontWeight.bold),
                                                                  maxWidth:
                                                                      (media.width - ScreenUtil.horizontalScale(16))) >
                                                              1
                                                          ? media.height * 0.030
                                                          : media.height * 0.048),
                                                  child: Text(
                                                    (monthProvider.isPumpDay
                                                        ? monthProvider.pumpDayModel?.title ?? "Pump Day"
                                                        : currentDayTitle),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil.verticalScale(3),
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: media.width,
                                  margin: EdgeInsets.only(
                                    top: media.height /
                                        ((monthProvider!.isCircuit || monthProvider!.isPumpDay) ? 9.6 : 7.6),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isEditMode ? Color(0xffe5f0f9) : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                                    ),
                                  ),

                                  /// NICK SUGGESTION REMOVE CONTAINER

                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top: -(media.height /
                                                ((monthProvider!.isCircuit || monthProvider!.isPumpDay) ? 9.6 : 7.6)) +
                                            0.9,
                                        child: SizedBox(
                                          height: (media.height /
                                              ((monthProvider!.isCircuit || monthProvider!.isPumpDay) ? 9.6 : 7.6)),
                                          width: media.width,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: ClipPath(
                                              clipper: DiagonalClipper(),
                                              child: AnimatedContainer(
                                                duration: Duration(milliseconds: 300),
                                                height: media.height / 11,
                                                width: media.width / 6,
                                                color: isEditMode ? Color(0xffe5f0f9) : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(6.5)),
                                        child: Column(
                                          children: [
                                            monthProvider!.isPumpDay || monthProvider!.isCircuit
                                                ? SizedBox()
                                                : VideoSlider(
                                                    dayDataModel: monthProvider!.dayDataModel!,
                                                  ),
                                            isEditMode
                                                ? Container(
                                                    margin: EdgeInsets.symmetric(
                                                      horizontal: ScreenUtil.horizontalScale(7),
                                                      vertical: ScreenUtil.verticalScale(1.2),
                                                    ).copyWith(top: ScreenUtil.horizontalScale(6)),
                                                    child: Builder(builder: (context) {
                                                      String split = monthProvider
                                                              ?.monthDataModel
                                                              ?.weeks?[monthProvider!.overviewCurrentWeek - 1]
                                                              .idList
                                                              ?.first
                                                              .toString()
                                                              .split(" ")[1] ??
                                                          "";

                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          if (monthProvider!.isPumpDay
                                                              ? (monthProvider?.pumpDayModel!.formats != null &&
                                                                  monthProvider!.pumpDayModel!.formats!.contains(
                                                                      split.toString().replaceAll("split", "")))
                                                              : (monthProvider?.dayDataModel!.formats != null &&
                                                                  monthProvider!.dayDataModel!.formats!.contains(
                                                                      split.toString().replaceAll("split", "")))) ...[
                                                            Container(
                                                              margin:
                                                                  EdgeInsets.only(left: ScreenUtil.verticalScale(2)),
                                                              child: Text(
                                                                'Choose equipment availability',
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                    color: Colors.black54,
                                                                    fontSize: ScreenUtil.verticalScale(1.5)),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            SelectDropdown(
                                                              onChange: (String newValue) async {
                                                                monthProvider?.changeEquipmentType(newValue);
                                                              },
                                                            ),
                                                          ]
                                                        ],
                                                      );
                                                    }),
                                                  )
                                                : SizedBox(),
                                            warmUpSection(media),
                                            Container(
                                              width: media.width,
                                              margin: EdgeInsets.only(left: ScreenUtil.verticalScale(3)),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(right: ScreenUtil.verticalScale(3)),
                                                      child: Text(
                                                        "Today's workout",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.horizontalScale(5.5),
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: media.height * 0.03),
                                                  monthProvider!.isPumpDay
                                                      ? CircuitsView(
                                                          isEditable: isEditMode,
                                                          circuit: monthProvider!.pumpDayModel!.circuits!,
                                                          isDayCompleted: isCurrentDayCompleted,
                                                          isDaySkipped: isCurrentDaySkipped)
                                                      : const SizedBox(),
                                                  loader
                                                      ? SizedBox()
                                                      : Column(
                                                          children: List.generate(
                                                            exercises.length,
                                                            (i) {
                                                              if (removedExercise.any((element) =>
                                                                      element.exerciseId == exercises[i].exerciseId!) ||
                                                                  (!exercises[i]
                                                                          .formats!
                                                                          .contains(monthProvider?.equipmentType) &&
                                                                      (exercises[i].isAddedUpdated == false ||
                                                                          exercises[i].isAddedUpdated == null))) {
                                                                return const SizedBox();
                                                              }
                                                              String split = monthProvider
                                                                      ?.monthDataModel
                                                                      ?.weeks?[monthProvider!.overviewCurrentWeek - 1]
                                                                      .idList
                                                                      ?.first
                                                                      .toString()
                                                                      .split(" ")[1] ??
                                                                  "";

                                                              String dataId =
                                                                  "$split-${monthProvider!.monthDataModel?.id}-${monthProvider!.weekDataModel?.id}-${monthProvider!.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${exercises[i].exerciseId}";

                                                              bool isExist = (!monthProvider!.exerciseHistoryModel
                                                                      .any((item) => item.dataId != dataId)) &&
                                                                  monthProvider!.isPastWeek;

                                                              return Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: ScreenUtil.verticalScale(3)),
                                                                    child: WorkoutCard(
                                                                      isEditMode: isEditMode,
                                                                      image: exercises[i].thumbnail ?? "unknown",
                                                                      dataId: dataId,
                                                                      isDayCompleted: isCurrentDayCompleted,
                                                                      isDaySkipped: isCurrentDaySkipped,
                                                                      exerciseId: exercises[i].exerciseId!,
                                                                      isCircuit: false,
                                                                      isCompleted: monthProvider!.exerciseHistoryModel
                                                                          .any((element) =>
                                                                              element.dataId == dataId &&
                                                                              element.status == Status.completed),
                                                                      isSkipped: ((isCurrentDaySkipped ||
                                                                                  isCurrentDayCompleted) &&
                                                                              monthProvider!.exerciseHistoryModel.any(
                                                                                (element) => element.dataId != dataId,
                                                                              )) ||
                                                                          (monthProvider!.exerciseHistoryModel.any(
                                                                                  (element) =>
                                                                                      element.dataId == dataId &&
                                                                                      element.status ==
                                                                                          Status.skipped) ||
                                                                              isExist) ||
                                                                          isCurrentDaySkipped,
                                                                      exerciseIndex: i,
                                                                      onPress: (Function()? function) async {
                                                                        if (isEditMode) {
                                                                          return;
                                                                        } else {
                                                                          await onPressed(
                                                                            i,
                                                                            dataId,
                                                                            i ==
                                                                                exercises.indexWhere(
                                                                                  (element) =>
                                                                                      element.exerciseId ==
                                                                                      exercises.last.exerciseId,
                                                                                ),
                                                                          ).then(
                                                                            (value) {
                                                                              function!();
                                                                            },
                                                                          );
                                                                        }
                                                                      },
                                                                      openSwapModal: () async {
                                                                        await swipeExerciseDialog(i, exercises[i]);
                                                                      },
                                                                      exercise: exercises[i],
                                                                      exerciseData: exercises[i].id!,
                                                                      name: exercises[i].name!.isEmpty
                                                                          ? "Exercise ${i + 1}"
                                                                          : exercises[i].name!,
                                                                      onRemove: () =>
                                                                          removeExercise(exercises[i].exerciseId!),
                                                                      enabled: /*isCurrentDayCompleted || isCurrentDaySkipped
                                                              ? false
                                                              : monthProvider!.exerciseHistoryModel.any((element) =>
                                                                          element.dataId == dataId && element.status == Status.completed) ||
                                                                      isExist
                                                                  ? false
                                                                  :*/
                                                                          true,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: ScreenUtil.verticalScale(3),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            monthProvider?.dayHistoryDetails == null ||
                                                    isCurrentDayCompleted ||
                                                    isCurrentDaySkipped ||
                                                    monthProvider!.isPastWeek ||
                                                    monthProvider!.isPumpDay ||
                                                    monthProvider!.isCircuit ||
                                                    monthProvider!.isCurrentMonth == "Future"
                                                ? const SizedBox()
                                                : Padding(
                                                    padding: EdgeInsets.only(top: ScreenUtil.verticalScale(1.6)),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        await addExerciseDialog();
                                                      },
                                                      child: IntrinsicWidth(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.add,
                                                              color: Colors.grey.shade600,
                                                              size: ScreenUtil.verticalScale(3),
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              "Add Exercise",
                                                              style: TextStyle(
                                                                fontSize: ScreenUtil.verticalScale(2),
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            if (isEditMode || monthProvider!.isCurrentMonth == "Future")
                                              SizedBox()
                                            else if (monthProvider!.isCurrentMonth == "Past")
                                              Column(
                                                children: [
                                                  Container(
                                                    height: 1,
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: ScreenUtil.horizontalScale(6), vertical: 36),
                                                    width: media.width * 0.75,
                                                    color: Colors.black12,
                                                  ),
                                                  SizedBox(height: media.height * 0.025),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                                    child: ButtonWidget(
                                                      text: monthProvider?.dayHistoryDetails?.status == Status.completed
                                                          ? "Completed"
                                                          : "Skipped",
                                                      textColor: Colors.white,
                                                      onPress: null,
                                                      color: AppColors.primaryColor,
                                                      isLoading: false,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else ...[
                                              (monthProvider!.isPumpDay || monthProvider!.isCircuit)
                                                  ? SizedBox()
                                                  : Container(
                                                      height: 1,
                                                      margin: EdgeInsets.symmetric(
                                                          horizontal: ScreenUtil.horizontalScale(6), vertical: 36),
                                                      width: media.width * 0.75,
                                                      color: Colors.black12,
                                                    ),
                                              SizedBox(height: media.height * 0.025),
                                              Consumer<MonthProvider>(builder: (context, value, child) {
                                                return value.dayHistoryDetails != null &&
                                                        value.dayHistoryDetails?.status == Status.skipped
                                                    ? Container(
                                                        margin: EdgeInsets.symmetric(
                                                            horizontal: ScreenUtil.verticalScale(5)),
                                                        child: ButtonWidget(
                                                          text: "Unskip?",
                                                          textColor: Colors.white,
                                                          onPress: () async {
                                                            String type = value.isPumpDay ? "" : 'Workout Day';

                                                            await _skipUnskipDayData(
                                                              status: "",
                                                              type: type,
                                                              title: "",
                                                            );
                                                            isCurrentDaySkipped = false;
                                                            setState(() {});
                                                          },
                                                          color: AppColors.skipDayColor,
                                                          isLoading: false,
                                                        ),
                                                      )
                                                    : Builder(builder: (context) {
                                                        return (value.dayHistoryDetails == null ||
                                                                    (isCurrentDaySkipped || isCurrentDayCompleted)) &&
                                                                value.isCurrentMonth == "Current" &&
                                                                !value.isPastWeek
                                                            ? Container(
                                                                margin: EdgeInsets.symmetric(
                                                                    horizontal: ScreenUtil.verticalScale(5)),
                                                                child: ButtonWidget(
                                                                  text: value.dayHistoryDetails?.status ==
                                                                          Status.completed
                                                                      ? "Reset Day?"
                                                                      : "Skipped",
                                                                  textColor: Colors.white,
                                                                  onPress: value.dayHistoryDetails?.status ==
                                                                          Status.completed
                                                                      ? () {
                                                                          AnimatedDialog.showAnimatedDialog(
                                                                            context: context,
                                                                            pageBuilder: (c1, anim1, anim2) => resetDay(
                                                                              context,
                                                                              c1,
                                                                              () {
                                                                                _resetDayData(
                                                                                    status: Status.reset,
                                                                                    type: monthProvider!.isPumpDay
                                                                                        ? "Pump Day - ${monthProvider?.pumpDayModel?.id}"
                                                                                        : "Workout Day",
                                                                                    status1: Status.reset);
                                                                                Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          );
                                                                        }
                                                                      : null,
                                                                  color: AppColors.primaryColor,
                                                                  isLoading: false,
                                                                ),
                                                              )
                                                            : Column(
                                                                children: [
                                                                  value.dayHistoryDetails?.status != Status.skipped &&
                                                                          value.dayHistoryDetails?.status !=
                                                                              Status.completed
                                                                      ? Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  ScreenUtil.verticalScale(3.2)),
                                                                          child: CustomSlideAction(
                                                                            key: key,
                                                                            height: ScreenUtil.verticalScale(7.2),
                                                                            outerColor: AppColors.primaryColor,
                                                                            innerColor: AppColors.backOffSetColor,
                                                                            sliderButtonIconPadding:
                                                                                ScreenUtil.verticalScale(1.3),
                                                                            submitButtonIconPadding:
                                                                                ScreenUtil.verticalScale(1.8),
                                                                            sliderButtonIcon: Image.asset(
                                                                              "assets/icons/chevron.png",
                                                                              color: AppColors.primaryColor,
                                                                              height: ScreenUtil.verticalScale(2),
                                                                            ),
                                                                            submittedButtonIcon: Image.asset(
                                                                              "assets/icons/check.png",
                                                                              color: AppColors.primaryColor,
                                                                              height: ScreenUtil.verticalScale(2),
                                                                            ),
                                                                            onSubmit: () async {
                                                                              return await onSwipe(value).then(
                                                                                (value) {
                                                                                  key.currentState?.reset();
                                                                                },
                                                                              );
                                                                            },
                                                                            child: Text(
                                                                              "Swipe to complete",
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: ScreenUtil.verticalScale(2.2),
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  ScreenUtil.verticalScale(3.2)),
                                                                          child: ButtonWidget(
                                                                            text: value.dayHistoryDetails?.status ==
                                                                                    Status.completed
                                                                                ? "Completed"
                                                                                : value.dayHistoryDetails?.status ==
                                                                                        Status.skipped
                                                                                    ? "Skipped"
                                                                                    : "Finish the workout",
                                                                            textColor: Colors.white,
                                                                            onPress: value.dayHistoryDetails?.status ==
                                                                                        Status.completed ||
                                                                                    value.dayHistoryDetails?.status ==
                                                                                        Status.skipped
                                                                                ? null
                                                                                : () async {
                                                                                    HapticFeedBack.buttonClick();
                                                                                    await _saveDayData(
                                                                                        status: Status.skipped,
                                                                                        type: monthProvider!.isPumpDay
                                                                                            ? "Pump Day - ${monthProvider?.pumpDayModel?.id}"
                                                                                            : "Workout Day",
                                                                                        status1: Status.completed);
                                                                                    if (!context.mounted) return;
                                                                                    value.updateCurrentDayTitleId(value
                                                                                            .weekDataModel?.idList![
                                                                                        value.overviewCurrentDay - 1]);
                                                                                    Navigator.pushNamed(
                                                                                        context, '/dayCompleted');
                                                                                  },
                                                                            color: AppColors.primaryColor,
                                                                            isLoading: false,
                                                                          ),
                                                                        ),
                                                                  const SizedBox(height: 14),
                                                                  value.dayHistoryDetails?.status != Status.skipped &&
                                                                          value.dayHistoryDetails?.status !=
                                                                              Status.completed
                                                                      ? Container(
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  ScreenUtil.verticalScale(3.2)),
                                                                          child: ButtonWidget(
                                                                            text: "Skip the workout",
                                                                            textColor: Colors.white,
                                                                            color: AppColors.skipDayColor,
                                                                            isLoading: false,
                                                                            onPress: () async {
                                                                              AnimatedDialog.showAnimatedDialog(
                                                                                context: context,
                                                                                pageBuilder: (c1, anim1, anim2) =>
                                                                                    skipWorkoutDialog(context, c1),
                                                                              );
                                                                            },
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                ],
                                                              );
                                                      });
                                              })
                                            ],
                                            const SizedBox(
                                              height: 150,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomBar()
                ],
              ),
            ),
    );
  }

  Widget skipWorkoutDialog(BuildContext context, BuildContext c1) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFFFFFF),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ScreenUtil.verticalScale(2)),
                        Text(
                          "Skip workout",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil.verticalScale(2.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(1)),
                          child: Text(
                            "Are you sure you want to skip\n this workout?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: ScreenUtil.verticalScale(2),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(c1).pop(),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil.verticalScale(1.7),
                                    ),
                                  ),
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.horizontalScale(3)),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _saveDayData(
                                        status: Status.skipped,
                                        type: monthProvider!.isPumpDay
                                            ? "Pump Day - ${monthProvider?.pumpDayModel?.id}"
                                            : "Workout Day",
                                        status1: Status.skipped);
                                    Navigator.of(c1).pop();
                                    if (!context.mounted) return;
                                    Navigator.pushNamed(context, '/home');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: AppColors.skipDayColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil.verticalScale(1.7),
                                    ),
                                  ),
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       IconButton(
                  //         icon: const Icon(Icons.close),
                  //         onPressed: () {
                  //           Navigator.of(c1).pop();
                  //         },
                  //       ),
                  //       SizedBox(width: ScreenUtil.horizontalScale(2)),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                    child: Icon(size: ScreenUtil.verticalScale(2.5), Icons.close, color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSwipe(MonthProvider value) async {
    HapticFeedBack.buttonClick();
    await _saveDayData(
        status: Status.skipped,
        type: monthProvider!.isPumpDay ? "Pump Day - ${monthProvider?.pumpDayModel?.id}" : "Workout Day",
        status1: Status.completed);
    value.updateCurrentDayTitleId(value.weekDataModel?.idList![value.overviewCurrentDay - 1]);
    if (!mounted) return;
    Navigator.pushNamed(context, '/dayCompleted');
  }

  /// ADD EXERCISE SECTION

  Future<void> addExerciseDialog() async {
    monthProvider?.fetchAllExercise();
    searchQuery = "";
    if (mounted) {
      return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          var media = MediaQuery.of(context).size;
          int? selectExerciseSwapIndex;
          int itemsPerPage = 5;
          int currentPageAll = 0;

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.all(0),
                child: Consumer<MonthProvider>(
                  builder: (context, value, child) {
                    return value.exerciseLoader
                        ? ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: ScreenUtil.horizontalScale(96),
                              maxHeight: ScreenUtil.verticalScale(62),
                            ),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              alignment: Alignment.topCenter,
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.primaryColor),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: ScreenUtil.horizontalScale(96),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: ScreenUtil.verticalScale(65),
                              ),
                              child: Builder(builder: (context) {
                                List<Widget> buildExerciseList(List<Exercise> exercises, int currentPage, bool isAll) {
                                  int startIndex = currentPage * itemsPerPage +
                                      (!isAll ? 0 : monthProvider!.relatedExercises.length);
                                  int endIndex = (startIndex + itemsPerPage) >
                                          exercises.length + (!isAll ? 0 : monthProvider!.relatedExercises.length)
                                      ? exercises.length + (!isAll ? 0 : monthProvider!.relatedExercises.length)
                                      : startIndex + itemsPerPage;

                                  return [
                                    for (int i = startIndex; i < endIndex; i++) ...[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectExerciseSwapIndex = i;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(width: ScreenUtil.horizontalScale(5)),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  appShimmerImage(
                                                    width: ScreenUtil.horizontalScale(10),
                                                    height: ScreenUtil.horizontalScale(10),
                                                    networkImageUrl: exercises[i -
                                                                (!isAll ? 0 : monthProvider!.relatedExercises.length)]
                                                            .thumbnail ??
                                                        "",
                                                    fit: BoxFit.cover,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(ScreenUtil.horizontalScale(1)),
                                                    ),
                                                  ),
                                                  SizedBox(width: ScreenUtil.horizontalScale(2)),
                                                  Flexible(
                                                      child: Text(
                                                    exercises[i - (!isAll ? 0 : monthProvider!.relatedExercises.length)]
                                                            .title ??
                                                        "",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil.verticalScale(2),
                                                    ),
                                                  )),
                                                  SizedBox(width: ScreenUtil.horizontalScale(2)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(
                                                ScreenUtil.verticalScale(1),
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.primaryColor,
                                                  width: 2,
                                                ),
                                                color: selectExerciseSwapIndex == i
                                                    ? AppColors.primaryColor
                                                    : Colors.white,
                                              ),
                                              child: selectExerciseSwapIndex == i
                                                  ? Icon(
                                                      Icons.check,
                                                      size: ScreenUtil.verticalScale(2),
                                                      color: Colors.white,
                                                    )
                                                  : Icon(
                                                      null,
                                                      size: ScreenUtil.verticalScale(2),
                                                    ),
                                            ),
                                            SizedBox(width: ScreenUtil.horizontalScale(5)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ];
                                }

                                Widget buildPaginationControls(
                                    int currentPage, int totalItems, Function(int) onPageChange) {
                                  int totalPages = (totalItems / itemsPerPage).ceil();
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: currentPage > 0 ? () => onPageChange(0) : null,
                                          icon: const Icon(Icons.first_page),
                                        ),
                                        IconButton(
                                          onPressed: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
                                          icon: const Icon(Icons.arrow_back),
                                        ),
                                        Text('Page ${currentPage + 1} of $totalPages'),
                                        IconButton(
                                          onPressed: (currentPage + 1) < totalPages
                                              ? () => onPageChange(currentPage + 1)
                                              : null,
                                          icon: const Icon(Icons.arrow_forward),
                                        ),
                                        IconButton(
                                          onPressed: (currentPage + 1) < totalPages
                                              ? () => onPageChange(totalPages - 1)
                                              : null,
                                          icon: const Icon(Icons.last_page),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                monthProvider!.allFilterExercises.removeWhere((element) =>
                                    monthProvider!.addedExerciseList.any((ele) => ele.exerciseId == element.id) ||
                                    exercises.any((ele) => ele.exerciseId == element.id));

                                return AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                  alignment: Alignment.topCenter,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: media.width,
                                          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 10),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Search for your exercise',
                                              style: TextStyle(
                                                fontSize: ScreenUtil.horizontalScale(5.5),
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SearchEquipmentField(
                                          onChanged: (query) {
                                            setState(() {
                                              searchQuery = query;
                                              currentPageAll = 0;
                                              monthProvider?.fetchAllFilterEx(query);
                                            });
                                          },
                                        ),
                                        searchQuery.isEmpty
                                            ? SizedBox(
                                                height: media.width * 0,
                                              )
                                            : monthProvider!.allFilterExercises.isNotEmpty
                                                ? Column(
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          maxHeight: ScreenUtil.verticalScale(60),
                                                        ),
                                                        child: SingleChildScrollView(
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                              children: buildExerciseList(
                                                                  monthProvider!.allFilterExercises,
                                                                  currentPageAll,
                                                                  false),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Pagination controls for all exercises
                                                      buildPaginationControls(
                                                        currentPageAll,
                                                        monthProvider!.allFilterExercises.length,
                                                        (page) {
                                                          setState(() {
                                                            currentPageAll = page;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(
                                                    height: media.width * 0.45,
                                                    child: const Center(
                                                      child: Text(
                                                        "No exercise available!",
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                                              .copyWith(bottom: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ButtonWidget(
                                                    text: "Cancel",
                                                    textColor: Colors.black,
                                                    color: const Color(0xFFDDDDDD),
                                                    onPress: () {
                                                      Navigator.pop(context);
                                                    },
                                                    isLoading: false),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: ButtonWidget(
                                                    text: "Confirm",
                                                    textColor: Colors.white,
                                                    color: AppColors.primaryColor,
                                                    onPress: () async {
                                                      ExerciseDataModel newDayExercise = ExerciseDataModel();

                                                      if (exercises.isNotEmpty) {
                                                        newDayExercise = ExerciseDataModel(
                                                          isAddedUpdated: true,
                                                          id: "",
                                                          exerciseId: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!].id ??
                                                              "",
                                                          typeId: exercises[0].typeId ?? 1,
                                                          name: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!]
                                                                  .title ??
                                                              "Exercise ${exercises.length + 1}",
                                                          guide: exercises[0].guide ?? "",
                                                          sets: exercises[0].sets ?? 0,
                                                          reps: exercises[0].reps ?? 0,
                                                          rest: exercises[0].rest ?? 0,
                                                          weight: exercises[0].weight ?? 0,
                                                          formats: exercises[0].formats ?? [],
                                                          thumbnail: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!]
                                                                  .thumbnail ??
                                                              "unknown",
                                                          extra: exercises[0].extra ?? [],
                                                        );
                                                      } else {
                                                        newDayExercise = ExerciseDataModel(
                                                          isAddedUpdated: true,
                                                          id: "",
                                                          exerciseId: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!].id ??
                                                              "",
                                                          typeId: 1,
                                                          name: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!]
                                                                  .title ??
                                                              "Exercise ${exercises.length + 1}",
                                                          thumbnail: monthProvider
                                                                  ?.allFilterExercises[selectExerciseSwapIndex!]
                                                                  .thumbnail ??
                                                              "unknown",
                                                          guide: "",
                                                          sets: 5,
                                                          reps: 10,
                                                          rest: 3,
                                                          weight: 30,
                                                          formats: ["A", "B", "C"],
                                                          extra: [
                                                            ExtraDataModel(
                                                              weight: 0,
                                                              rest: 120,
                                                              load: 0,
                                                              reps: 0,
                                                              sets: 3,
                                                              type: 3,
                                                              id: "extraaddedexercisesetsdefaultvalueid",
                                                            )
                                                          ],
                                                        );
                                                      }

                                                      String split = monthProvider
                                                              ?.monthDataModel
                                                              ?.weeks?[monthProvider!.overviewCurrentWeek - 1]
                                                              .idList
                                                              ?.first
                                                              .toString()
                                                              .split(" ")[1] ??
                                                          "";
                                                      String dataId =
                                                          "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${monthProvider?.allFilterExercises[selectExerciseSwapIndex!].id}";

                                                      Map<String, dynamic> data = {
                                                        "dataId": dataId,
                                                        "split": split,
                                                        "monthId": monthProvider?.monthDataModel?.id,
                                                        "weekId": monthProvider?.weekDataModel?.id,
                                                        "dayId": monthProvider?.weekDataModel
                                                            ?.idList![monthProvider!.overviewCurrentDay - 1],
                                                        "date": "${DateTime.now().toUtc()}",
                                                        "exerciseId": monthProvider
                                                            ?.allFilterExercises[selectExerciseSwapIndex!].id,
                                                        "exerciseJson": jsonEncode(newDayExercise)
                                                      };

                                                      RemovedExerciseModel removedDataExit = removedExercise.firstWhere(
                                                        (element) => element.dataId == dataId,
                                                        orElse: () => RemovedExerciseModel(),
                                                      );
                                                      if (removedDataExit.id != null) {
                                                        ApiRepo.deleteRemovedExercise(
                                                            dataId: removedDataExit.dataId ?? "");
                                                        await DatabaseHelper().deleteSingleData(
                                                            tableName: DatabaseHelper.removedExerciseHistory,
                                                            id: removedDataExit.dataId!);
                                                      }

                                                      exercises.add(newDayExercise);
                                                      ApiRepo.addExtraExercise(body: data);
                                                      await DatabaseHelper().insertData(
                                                          tableName: DatabaseHelper.extraExerciseHistory, data: data);
                                                      await monthProvider?.fetchExtraAddedExerciseData();
                                                      setState(() {});
                                                      if (!context.mounted) return;
                                                      Navigator.pop(context);
                                                    },
                                                    isLoading: false),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                  },
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> swipeExerciseDialog(int selectedIndex, dynamic exercise) async {
    monthProvider?.fetchAllExercise();
    monthProvider?.fetchRelatedExercise(exercise.exerciseId ?? "");
    searchQuery = "";
    if (mounted) {
      return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          var media = MediaQuery.of(context).size;
          int? selectRelatedExerciseSwapIndex;
          int? selectExerciseSwapIndex;
          int itemsPerPage = monthProvider!.relatedExercises.isEmpty
              ? 4
              : monthProvider!.relatedExercises.length > 2
                  ? 2
                  : 3;
          int itemsPerPageRelated = 2;
          int currentPageRelated = 0;
          int currentPageAll = 0;

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.white,
                insetPadding: EdgeInsets.zero,
                child: Consumer<MonthProvider>(builder: (context, value, child) {
                  return value.exerciseLoader
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ScreenUtil.horizontalScale(96),
                            maxHeight: ScreenUtil.verticalScale(45),
                          ),
                          child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              alignment: Alignment.topCenter,
                              child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor))),
                        )
                      : SizedBox(
                          width: ScreenUtil.horizontalScale(96),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: ScreenUtil.verticalScale(70),
                            ),
                            child: Builder(builder: (context) {
                              List<Widget> buildExerciseList(List<Exercise> exercises, int currentPage) {
                                int startIndex = currentPage * itemsPerPage;
                                int endIndex = (startIndex + itemsPerPage) > exercises.length
                                    ? exercises.length
                                    : startIndex + itemsPerPage;

                                return [
                                  for (int i = startIndex; i < endIndex; i++) ...[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectRelatedExerciseSwapIndex = null;
                                          selectExerciseSwapIndex = i;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(width: ScreenUtil.horizontalScale(5)),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                appShimmerImage(
                                                  width: ScreenUtil.horizontalScale(10),
                                                  height: ScreenUtil.horizontalScale(10),
                                                  networkImageUrl: exercises[i - (0)].thumbnail ?? "unknown",
                                                  fit: BoxFit.cover,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(ScreenUtil.horizontalScale(1)),
                                                  ),
                                                ),
                                                SizedBox(width: ScreenUtil.horizontalScale(2)),
                                                Flexible(
                                                    child: Text(
                                                  exercises[i - (0)].title ?? "",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: ScreenUtil.verticalScale(2),
                                                  ),
                                                )),
                                                SizedBox(width: ScreenUtil.horizontalScale(2)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1),
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primaryColor,
                                                width: 2,
                                              ),
                                              color:
                                                  selectExerciseSwapIndex == i ? AppColors.primaryColor : Colors.white,
                                            ),
                                            child: selectExerciseSwapIndex == i
                                                ? Icon(
                                                    Icons.check,
                                                    size: ScreenUtil.verticalScale(2),
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    null,
                                                    size: ScreenUtil.verticalScale(2),
                                                  ),
                                          ),
                                          SizedBox(width: ScreenUtil.horizontalScale(5)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ];
                              }

                              Widget buildPaginationControls(
                                  int currentPage, int totalItems, Function(int) onPageChange) {
                                int totalPages = (totalItems / itemsPerPage).ceil();
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: currentPage > 0 ? () => onPageChange(0) : null,
                                        icon: const Icon(Icons.first_page),
                                      ),
                                      IconButton(
                                        onPressed: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                      Text('Page ${currentPage + 1} of $totalPages'),
                                      IconButton(
                                        onPressed:
                                            (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                      IconButton(
                                        onPressed:
                                            (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
                                        icon: const Icon(Icons.last_page),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              List<Widget> buildRelatedExerciseList(List<RelatedExercises> exercises, int currentPage) {
                                int startIndex = currentPage * itemsPerPageRelated;
                                int endIndex = (startIndex + itemsPerPageRelated) > exercises.length
                                    ? exercises.length
                                    : startIndex + itemsPerPageRelated;

                                return [
                                  for (int i = startIndex; i < endIndex; i++) ...[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectExerciseSwapIndex = null;

                                          selectRelatedExerciseSwapIndex = i;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(width: ScreenUtil.horizontalScale(5)),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                appShimmerImage(
                                                  width: ScreenUtil.horizontalScale(10),
                                                  height: ScreenUtil.horizontalScale(10),
                                                  networkImageUrl: exercises[i].thumbnail ?? "unknown",
                                                  fit: BoxFit.cover,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(ScreenUtil.horizontalScale(1)),
                                                  ),
                                                ),
                                                SizedBox(width: ScreenUtil.horizontalScale(2)),
                                                Flexible(
                                                    child: Text(
                                                  exercises[i].title ?? "",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: ScreenUtil.verticalScale(2),
                                                  ),
                                                )),
                                                SizedBox(width: ScreenUtil.horizontalScale(2)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                              ScreenUtil.verticalScale(1),
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primaryColor,
                                                width: 2,
                                              ),
                                              color: selectRelatedExerciseSwapIndex == i
                                                  ? AppColors.primaryColor
                                                  : Colors.white,
                                            ),
                                            child: selectRelatedExerciseSwapIndex == i
                                                ? Icon(
                                                    Icons.check,
                                                    size: ScreenUtil.verticalScale(2),
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    null,
                                                    size: ScreenUtil.verticalScale(2),
                                                  ),
                                          ),
                                          SizedBox(width: ScreenUtil.horizontalScale(5)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ];
                              }

                              Widget buildPaginationControlsRelatedExercise(
                                  int currentPage, int totalItems, Function(int) onPageChange) {
                                int totalPages = (totalItems / itemsPerPageRelated).ceil();
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: currentPage > 0 ? () => onPageChange(0) : null,
                                        icon: const Icon(Icons.first_page),
                                      ),
                                      IconButton(
                                        onPressed: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                      Text('Page ${currentPage + 1} of $totalPages'),
                                      IconButton(
                                        onPressed:
                                            (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                      IconButton(
                                        onPressed:
                                            (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
                                        icon: const Icon(Icons.last_page),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              monthProvider!.allFilterExercises.removeWhere((element) =>
                                  monthProvider!.addedExerciseList.any((ele) => ele.exerciseId == element.id) ||
                                  exercises.any((ele) => ele.exerciseId == element.id));

                              monthProvider!.relatedExercises.removeWhere((element) =>
                                  monthProvider!.swapExerciseList.any((ele) => ele.exerciseId == element.sId) ||
                                  monthProvider!.addedExerciseList.any((ele) => ele.exerciseId == element.sId) ||
                                  exercises.any((ele) => ele.exerciseId == element.sId));

                              return AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                                alignment: Alignment.topCenter,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: media.width,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 20, bottom: 8),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Swap exercise option',
                                            style: TextStyle(
                                              fontSize: ScreenUtil.horizontalScale(5.5),
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      monthProvider!.relatedExercises.isNotEmpty
                                          ? Column(
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: ScreenUtil.verticalScale(60),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Builder(
                                                        builder: (context) {
                                                          final seenIds = <String>{};
                                                          final filteredList =
                                                              monthProvider!.relatedExercises.where((item) {
                                                            return seenIds.add(item.sId!);
                                                          }).toList();
                                                          return Column(
                                                            children: [
                                                              Column(
                                                                children: buildRelatedExerciseList(
                                                                    filteredList, currentPageRelated),
                                                              ),
                                                              buildPaginationControlsRelatedExercise(
                                                                currentPageRelated,
                                                                monthProvider!.relatedExercises.length,
                                                                (page) {
                                                                  setState(() {
                                                                    currentPageRelated = page;
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Center(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 12, bottom: 18),
                                                child: Text(
                                                  "No exercise available!",
                                                  style: TextStyle(fontSize: 17),
                                                ),
                                              ),
                                            ),
                                      Container(
                                        width: media.width,
                                        padding: const EdgeInsets.only(left: 24, right: 24),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Or search our library',
                                            style: TextStyle(
                                                fontSize: ScreenUtil.horizontalScale(5.5),
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: SearchEquipmentField(
                                          onChanged: (query) {
                                            setState(() {
                                              searchQuery = query;
                                              currentPageAll = 0;
                                              monthProvider?.fetchAllFilterEx(query);
                                            });
                                          },
                                        ),
                                      ),
                                      searchQuery.isEmpty
                                          ? SizedBox(
                                              height: media.width * 0.0,
                                            )
                                          : monthProvider!.allFilterExercises.isNotEmpty
                                              ? Column(
                                                  children: [
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxHeight: ScreenUtil.verticalScale(60),
                                                      ),
                                                      child: SingleChildScrollView(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: Column(
                                                            children: buildExerciseList(
                                                                monthProvider!.allFilterExercises, currentPageAll),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    buildPaginationControls(
                                                      currentPageAll,
                                                      monthProvider!.allFilterExercises.length,
                                                      (page) {
                                                        setState(() {
                                                          currentPageAll = page;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(
                                                  height: media.width * 0.25,
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      child: Text(
                                                        "No exercise available!",
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                                            .copyWith(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ButtonWidget(
                                                  text: "Cancel",
                                                  textColor: Colors.black,
                                                  color: const Color(0xFFDDDDDD),
                                                  onPress: () {
                                                    Navigator.pop(context);
                                                  },
                                                  isLoading: false),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: ButtonWidget(
                                                  text: "Confirm",
                                                  textColor: Colors.white,
                                                  color: AppColors.primaryColor,
                                                  onPress: () async {
                                                    RelatedExercises? relatedExerciseData;
                                                    Exercise? exerciseDataModel;

                                                    if (selectRelatedExerciseSwapIndex == null) {
                                                      exerciseDataModel =
                                                          monthProvider!.allFilterExercises[selectExerciseSwapIndex!];
                                                    } else {
                                                      relatedExerciseData = monthProvider!
                                                          .relatedExercises[selectRelatedExerciseSwapIndex!];
                                                    }

                                                    ExerciseDataModel newDayExercise = ExerciseDataModel(
                                                      isAddedUpdated: true,
                                                      id: "",
                                                      exerciseId:
                                                          exerciseDataModel?.id ?? relatedExerciseData?.sId ?? "",
                                                      typeId: exercises[selectedIndex].typeId ?? 1,
                                                      thumbnail: exerciseDataModel?.thumbnail ??
                                                          relatedExerciseData?.thumbnail ??
                                                          "unknown",
                                                      name: exerciseDataModel?.title ??
                                                          relatedExerciseData?.title ??
                                                          "Exercise ${exercises.length + 1}",
                                                      guide: exercises[selectedIndex].guide ?? "",
                                                      sets: exercises[selectedIndex].sets ?? 0,
                                                      reps: exercises[selectedIndex].reps ?? 0,
                                                      rest: exercises[selectedIndex].rest ?? 0,
                                                      weight: exercises[selectedIndex].weight ?? 0,
                                                      formats: exercises[selectedIndex].formats ?? [],
                                                      extra: exercises[selectedIndex].extra ?? [],
                                                    );

                                                    String split = monthProvider
                                                            ?.monthDataModel
                                                            ?.weeks?[monthProvider!.overviewCurrentWeek - 1]
                                                            .idList
                                                            ?.first
                                                            .toString()
                                                            .split(" ")[1] ??
                                                        "";

                                                    String dataId =
                                                        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${exerciseDataModel?.id ?? relatedExerciseData?.sId ?? ""}";

                                                    Map<String, dynamic> data = {
                                                      "dataId": dataId,
                                                      "split": split,
                                                      "monthId": monthProvider?.monthDataModel?.id,
                                                      "weekId": monthProvider?.weekDataModel?.id,
                                                      "dayId": monthProvider?.weekDataModel
                                                          ?.idList![monthProvider!.overviewCurrentDay - 1],
                                                      "date": "${DateTime.now().toUtc()}",
                                                      "exerciseId":
                                                          exerciseDataModel?.id ?? relatedExerciseData?.sId ?? "",
                                                      "exerciseJson": jsonEncode(newDayExercise),
                                                      "insertIndex": selectedIndex.toString()
                                                    };

                                                    RemovedExerciseModel removedDataExit = removedExercise.firstWhere(
                                                      (element) => element.dataId == dataId,
                                                      orElse: () => RemovedExerciseModel(),
                                                    );

                                                    if (removedDataExit.id != null) {
                                                      ApiRepo.deleteRemovedExercise(
                                                          dataId: removedDataExit.dataId ?? "");
                                                      await DatabaseHelper().deleteSingleData(
                                                          tableName: DatabaseHelper.removedExerciseHistory,
                                                          id: removedDataExit.dataId!);
                                                    }
                                                    exercises.removeAt(selectedIndex);
                                                    exercises.insert(selectedIndex, newDayExercise);
                                                    ApiRepo.addSwapExercise(body: data);
                                                    await DatabaseHelper().insertData(
                                                        tableName: DatabaseHelper.swapExerciseHistory, data: data);
                                                    await monthProvider?.fetchSwapExerciseData();
                                                    await removeExercise(exercise.exerciseId ?? "");
                                                    setState(() {});
                                                    if (!context.mounted) return;
                                                    Navigator.pop(context);
                                                  },
                                                  isLoading: false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                }),
              );
            },
          );
        },
      );
    }
  }

  /// SAVE DATA INTO SQL

  Future<void> _saveExerciseData({required String status, required String id, required String type}) async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$id";

    final data = {
      "dataId": dataId,
      "exerciseId": id,
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type
    };

    final data1 = {"status": status, "type": type};
    final apiReqBody = {"status": status, "type": type, "dataId": dataId};

    if (monthProvider!.exerciseHistoryModel.isNotEmpty) {
      if (monthProvider!.exerciseHistoryModel.any((element) => element.dataId == dataId)) {
        ApiRepo.updateExerciseStatus(body: apiReqBody);
        await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseStatus, id: dataId);
      } else {
        ApiRepo.addExerciseStatus(body: data);
        await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
      }
    } else {
      ApiRepo.addExerciseStatus(body: data);
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
    }

    if (status == Status.reset) {
      if (type.contains("Circuit")) {
        if (monthProvider!.pumpDayModel!.circuits != null && monthProvider!.pumpDayModel!.circuits!.isNotEmpty) {
          for (int i = 0; i < monthProvider!.pumpDayModel!.circuits!.length; i++) {
            var element = monthProvider!.pumpDayModel!.circuits![i];

            String exId = element.id ?? "";

            String cManagerId =
                "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$exId";

            await DatabaseHelper().deleteSingleData(tableName: DatabaseHelper.circuitManager, id: cManagerId);

            if (element.circuitExercises != null && element.circuitExercises!.isNotEmpty) {
              for (int j = 0; j < element.circuitExercises!.length; j++) {
                var cir = element.circuitExercises![j];
                if (cir.extra != null && cir.extra!.isNotEmpty) {
                  for (int z = 0; z < cir.extra!.length; z++) {
                    var sets = cir.extra![z];
                    String dataId =
                        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${cir.exerciseId}";
                    final db = await DatabaseHelper().database;
                    List<Map<String, dynamic>> result = await db.rawQuery('''
                                                            SELECT * FROM ${DatabaseHelper.exerciseHistory}
                                                            WHERE dataId LIKE ?
                                                            ''', ['%$dataId%']);
                    List<HistoryDataModel> data = List<HistoryDataModel>.from(
                        json.decode(jsonEncode(result)).map((x) => HistoryDataModel.fromJson(x)));
                    if (data.isNotEmpty) {
                      for (var element in data) {
                        var dataId = element.dataId;

                        Map<String, dynamic> updateData = {
                          "sets": sets.sets.toString(),
                          "reps": sets.reps.toString(),
                          "weight": sets.weight.toString(),
                          "rest": sets.rest.toString(),
                          "load": sets.load.toString(),
                          "type": sets.type.toString(),
                          "effort": "100",
                          "date": "${DateTime.now().toUtc()}",
                          "status": Status.empty,
                          "totalSet": "0",
                        };

                        Map<String, dynamic> updateData1 = {
                          "sets": sets.sets.toString(),
                          "reps": sets.reps.toString(),
                          "weight": sets.weight.toString(),
                          "rest": sets.rest.toString(),
                          "load": sets.load.toString(),
                          "type": sets.type.toString(),
                          "effort": "100",
                          "date": "${DateTime.now().toUtc()}",
                          "status": Status.empty,
                          "totalSet": "0",
                          "dataId": dataId,
                        };

                        ApiRepo.updateExerciseHistory(body: updateData1);
                        await DatabaseHelper()
                            .updateData(data: updateData, tableName: DatabaseHelper.exerciseHistory, id: dataId!);
                      }
                    }
                  }
                }
              }
            }
          }
        }
        if (exercises.isNotEmpty) {
          for (int j = 0; j < exercises.length; j++) {
            var exercise = exercises[j];
            if (exercise.extra != null && exercise.extra!.isNotEmpty) {
              for (int z = 0; z < exercise.extra!.length; z++) {
                var sets = exercise.extra![z];

                String dataId =
                    "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${exercise.exerciseId}";
                final db = await DatabaseHelper().database;
                List<Map<String, dynamic>> result = await db.rawQuery('''
                                                            SELECT * FROM ${DatabaseHelper.exerciseHistory}
                                                            WHERE dataId LIKE ?
                                                            ''', ['%$dataId%']);
                List<HistoryDataModel> data = List<HistoryDataModel>.from(
                    json.decode(jsonEncode(result)).map((x) => HistoryDataModel.fromJson(x)));
                if (data.isNotEmpty) {
                  for (var element in data) {
                    var dataId = element.dataId;

                    Map<String, dynamic> updateData = {
                      "sets": sets.sets.toString(),
                      "reps": sets.reps.toString(),
                      "weight": sets.weight.toString(),
                      "rest": sets.rest.toString(),
                      "load": sets.load.toString(),
                      "type": sets.type.toString(),
                      "effort": "100",
                      "date": "${DateTime.now().toUtc()}",
                      "status": Status.empty,
                      "totalSet": "0",
                    };

                    Map<String, dynamic> updateData1 = {
                      "sets": sets.sets.toString(),
                      "reps": sets.reps.toString(),
                      "weight": sets.weight.toString(),
                      "rest": sets.rest.toString(),
                      "load": sets.load.toString(),
                      "type": sets.type.toString(),
                      "effort": "100",
                      "date": "${DateTime.now().toUtc()}",
                      "status": Status.empty,
                      "totalSet": "0",
                      "dataId": dataId,
                    };

                    ApiRepo.updateExerciseHistory(body: updateData1);
                    await DatabaseHelper()
                        .updateData(data: updateData, tableName: DatabaseHelper.exerciseHistory, id: dataId!);
                  }
                }
              }
            }
          }
        }
      } else {
        if (exercises.isNotEmpty) {
          for (int j = 0; j < exercises.length; j++) {
            var exercise = exercises[j];
            if (exercise.extra != null && exercise.extra!.isNotEmpty) {
              for (int z = 0; z < exercise.extra!.length; z++) {
                var sets = exercise.extra![z];

                String dataId =
                    "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${exercise.exerciseId}";
                final db = await DatabaseHelper().database;
                List<Map<String, dynamic>> result = await db.rawQuery('''
                                                            SELECT * FROM ${DatabaseHelper.exerciseHistory}
                                                            WHERE dataId LIKE ?
                                                            ''', ['%$dataId%']);
                List<HistoryDataModel> data = List<HistoryDataModel>.from(
                    json.decode(jsonEncode(result)).map((x) => HistoryDataModel.fromJson(x)));
                if (data.isNotEmpty) {
                  for (var element in data) {
                    var dataId = element.dataId;

                    Map<String, dynamic> updateData = {
                      "sets": sets.sets.toString(),
                      "reps": sets.reps.toString(),
                      "weight": sets.weight.toString(),
                      "rest": sets.rest.toString(),
                      "load": sets.load.toString(),
                      "type": sets.type.toString(),
                      "effort": "100",
                      "date": "${DateTime.now().toUtc()}",
                      "status": Status.empty,
                      "totalSet": "0",
                    };

                    Map<String, dynamic> updateData1 = {
                      "sets": sets.sets.toString(),
                      "reps": sets.reps.toString(),
                      "weight": sets.weight.toString(),
                      "rest": sets.rest.toString(),
                      "load": sets.load.toString(),
                      "type": sets.type.toString(),
                      "effort": "100",
                      "date": "${DateTime.now().toUtc()}",
                      "status": Status.empty,
                      "totalSet": "0",
                      "dataId": dataId,
                    };

                    ApiRepo.updateExerciseHistory(body: updateData1);
                    await DatabaseHelper()
                        .updateData(data: updateData, tableName: DatabaseHelper.exerciseHistory, id: dataId!);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Future<void> _saveDayData({required String status, required String type, required String status1}) async {
    await monthProvider?.fetchExerciseStatusLocalData();
    if (status1 == Status.completed) {
      ApiRepo.addDayStatusList(body: {"date": "${DateTime.now().toUtc()}", "status": Status.completed});
    }
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    double totalWeight = 0;
    int exCount = 0;
    double totalSet = 0;
    double totalRIR = 0;

    for (int i = 0; i < monthProvider!.exerciseHistoryModel.length; i++) {
      var element = monthProvider!.exerciseHistoryModel[i];
      if (element.status == Status.completed) {
        exCount++;
        totalWeight += double.parse(element.totalWeight!);
        totalSet += double.parse(element.totalSet ?? "0");
        totalRIR += double.parse(element.totalRIR ?? "0");
      }
    }

    double average = totalRIR / totalSet;

    if (monthProvider!.isPumpDay) {
      if (monthProvider!.pumpDayModel!.circuits!.isNotEmpty) {
        final data = monthProvider!.pumpDayModel!.circuits!;
        for (int i = 0; i < data.length; i++) {
          var elementI = data[i];
          for (int j = 0; j < elementI.round!; j++) {
            for (int z = 0; z < elementI.circuitExercises!.length; z++) {
              var elementZ = elementI.circuitExercises?[z];

              String dataId =
                  "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementZ?.exerciseId}-$i:$j:$z";

              bool? val = monthProvider?.exerciseHistoryModel.any((element) =>
                  element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
              if (val == false) {
                await _saveExerciseData(
                    status: status, id: "${elementZ?.exerciseId}-$i:$j:$z", type: 'Circuit - $i:$j:$z');
              }
            }
          }
        }
      }
    }
    // return;
    if (exercises.isNotEmpty) {
      final data = exercises;

      for (int i = 0; i < data.length; i++) {
        var elementI = data[i];

        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.exerciseId}";

        bool? val = monthProvider?.exerciseHistoryModel.any((element) =>
            element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
        if (val == false) {
          await _saveExerciseData(status: status, id: elementI.exerciseId!, type: 'Exercise');
        }
      }
    }

    if (monthProvider!.isPumpDay
        ? monthProvider?.pumpDayModel?.warmups != null
        : monthProvider!.dayDataModel!.warmups != null) {
      final data =
          monthProvider!.isPumpDay ? monthProvider?.pumpDayModel?.warmups : monthProvider!.dayDataModel!.warmups;
      for (int i = 0; i < data!.length; i++) {
        var elementI = data[i];

        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.warmupId}";
        bool? val = monthProvider?.exerciseHistoryModel.any((element) =>
            element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
        if (val == false) {
          await _saveExerciseData(status: status, id: elementI.warmupId!, type: 'Warmup');
        }
      }
    }

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    final data = monthProvider?.dayHistoryModel.where((element) => element.dataId == dataId).toList();

    final data1 = {
      "status": status1,
      "type": type,
      "endTime": (status == Status.completed || status == Status.skipped) ? "${DateTime.now().toUtc()}" : "",
      "totalWeight": totalWeight.toString(),
      "completedExercise": exCount.toString(),
      "averageRIR": average.toString(),
      if (data!.isNotEmpty)
        "startTime": data.first.startTime == null ? "${DateTime.now().toUtc()}" : data.first.startTime.toString()
    };

    final apiReqBody = {
      "status": status1,
      "type": type,
      "endTime": (status == Status.completed || status == Status.skipped) ? "${DateTime.now().toUtc()}" : "",
      "totalWeight": totalWeight.toString(),
      "completedExercise": exCount.toString(),
      "dataId": dataId,
      "averageRIR": average.toString(),
      if (data.isNotEmpty)
        "startTime": data.first.startTime == null ? "${DateTime.now().toUtc()}" : data.first.startTime.toString()
    };
    await ApiRepo.updateDayStatus(body: apiReqBody);
    await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);

    await monthProvider?.updateDayData();
    monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.fetchDayStatusLocalData();
    await monthProvider?.fetchSingleDayHistoryLocalData();
    await monthProvider?.updatePumpDayStatus();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }

  Future<void> _skipUnskipDayData({required String status, required String type, String? title}) async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    await unSkipped(status);

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "startTime": status == Status.empty ? "" : "${DateTime.now().toUtc()}",
      "endTime": status == Status.empty ? "" : "${DateTime.now().toUtc()}",
    };

    DayHistoryModel? matchingElement = monthProvider?.dayHistoryModel
        .firstWhere((element) => element.dataId == dataId, orElse: () => DayHistoryModel());

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime": status == Status.empty ? "" : "${DateTime.now().toUtc()}",
    };

    final apiBody = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
      "dataId": dataId
    };

    if (matchingElement?.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);
      await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }
    await monthProvider?.fetchSingleDayHistoryLocalData();
    await monthProvider?.updateDayData();
    await monthProvider?.fetchExerciseHistoryLocalData();
    await monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.updatePumpDayStatus();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }

  Future<void> unSkipped(String status) async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    if (monthProvider!.isPumpDay) {
      if (monthProvider!.pumpDayModel!.circuits!.isNotEmpty) {
        final data = monthProvider!.pumpDayModel!.circuits!;
        for (int i = 0; i < data.length; i++) {
          var elementI = data[i];
          for (int j = 0; j < elementI.round!; j++) {
            for (int z = 0; z < elementI.circuitExercises!.length; z++) {
              var elementZ = elementI.circuitExercises?[z];
              String dataId =
                  "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementZ?.exerciseId}-$i:$j:$z";
              bool? val = monthProvider?.exerciseHistoryModel
                  .any((element) => element.dataId == dataId && element.status == Status.skipped);
              if (val == true) {
                await _unskipExerciseData(
                    status: status, id: "${elementZ?.exerciseId}-$i:$j:$z", type: 'Circuit - $i:$j:$z');
              }
            }
          }
        }
      }
    }

    if (monthProvider!.isPumpDay
        ? monthProvider!.pumpDayModel!.exercises != null
        : monthProvider!.dayDataModel!.exercises != null) {
      final data =
          monthProvider!.isPumpDay ? monthProvider!.pumpDayModel!.exercises : monthProvider!.dayDataModel!.exercises;
      for (int i = 0; i < data!.length; i++) {
        var elementI = data[i];
        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.exerciseId}";
        bool? val = monthProvider?.exerciseHistoryModel
            .any((element) => element.dataId == dataId && element.status == Status.skipped);
        if (val == true) {
          await _unskipExerciseData(status: status, id: elementI.exerciseId!, type: 'Exercise');
        }
      }
    }
    if (monthProvider!.isPumpDay
        ? monthProvider!.pumpDayModel!.warmups != null
        : monthProvider!.dayDataModel!.warmups != null) {
      final data =
          monthProvider!.isPumpDay ? monthProvider!.pumpDayModel!.warmups : monthProvider!.dayDataModel!.warmups;
      for (int i = 0; i < data!.length; i++) {
        var elementI = data[i];
        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.warmupId}";
        bool? val = monthProvider?.exerciseHistoryModel
            .any((element) => element.dataId == dataId && element.status == Status.skipped);
        if (val == true) {
          await _unskipExerciseData(status: status, id: elementI.warmupId!, type: 'Warmup');
        }
      }
    }
  }

  Future<void> _unskipExerciseData({required String status, required String id, required String type}) async {
    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$id";
    final data = {"status": status, "type": type};
    final apiReqBody = {"status": status, "type": type, "dataId": dataId};
    ApiRepo.updateExerciseStatus(body: apiReqBody);
    await DatabaseHelper().updateData(tableName: DatabaseHelper.exerciseStatus, id: dataId, data: data);
  }

  Widget bottomBar() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(15),
            vertical: ScreenUtil.verticalScale(2),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.verticalScale(1),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Consumer<MainPageProvider>(builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      value.changeTab(0);
                    },
                    icon: SvgPicture.asset(
                      'assets/img/1-home.svg',
                      colorFilter: ColorFilter.mode(
                          value.selectedPage == 0 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                      width: ScreenUtil.horizontalScale(8.5),
                      height: ScreenUtil.horizontalScale(8.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      monthProvider?.updateIsOnMonthPage(true);
                      monthProvider?.updateScrollToRestDay(false);

                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      value.changeTab(1);
                    },
                    icon: SvgPicture.asset(
                      'assets/img/2-calendar.svg',
                      colorFilter: ColorFilter.mode(
                          value.selectedPage == 1 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                      width: ScreenUtil.horizontalScale(8.5),
                      height: ScreenUtil.horizontalScale(8.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      value.changeTab(2);
                    },
                    icon: SvgPicture.asset(
                      'assets/img/3-statistics.svg',
                      colorFilter: ColorFilter.mode(
                          value.selectedPage == 2 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                      width: ScreenUtil.horizontalScale(8.5),
                      height: ScreenUtil.horizontalScale(8.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      value.changeTab(3);
                    },
                    icon: SvgPicture.asset(
                      'assets/img/4-account.svg',
                      colorFilter: ColorFilter.mode(
                          value.selectedPage == 3 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                      width: ScreenUtil.horizontalScale(9),
                      height: ScreenUtil.horizontalScale(9),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );

  /// WARMUP SECTION

  bool _isExpanded = false;
  int curExpandedIdx = 0;
  Widget warmUpSection(Size media) {
    final warmUps =
        monthProvider!.isPumpDay ? monthProvider!.pumpDayModel!.warmups! : monthProvider!.dayDataModel!.warmups ?? [];
    return warmUps.isEmpty
        ? SizedBox(height: 15)
        : Column(
            children: [
              SizedBox(
                height: ScreenUtil.verticalScale(1),
              ),
              Theme(
                data: ThemeData().copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(0)),
                  child: Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      top: ScreenUtil.verticalScale(2),
                      bottom: _isExpanded ? 0 : ScreenUtil.verticalScale(2),
                    ),
                    child: ExpansionPanelList(
                      dividerColor: Colors.transparent,
                      sidePadding: true,
                      animationDuration: Duration(milliseconds: 300),
                      expandIconColor: isEditMode ? Colors.grey.shade700 : Colors.grey.shade400,
                      materialGapSize: 10,
                      expandedHeaderPadding: EdgeInsets.zero,
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          _isExpanded = isExpanded;
                          curExpandedIdx = isExpanded ? 0 : -1;
                        });
                      },
                      elevation: 0,
                      children: [
                        expansionPanel1(monthProvider!, media),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(6),
                  vertical: ScreenUtil.verticalScale(1.5),
                ),
                width: media.width * 0.75,
                color: Colors.black12,
              ),
              SizedBox(
                height: ScreenUtil.verticalScale(1.5),
              )
            ],
          );
  }

  ExpansionPanel expansionPanel1(MonthProvider monthProvider, Size media) {
    final warmUps =
        monthProvider.isPumpDay ? monthProvider.pumpDayModel!.warmups! : monthProvider.dayDataModel!.warmups ?? [];

    return ExpansionPanel(
      isExpanded: _isExpanded,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return Padding(
          padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(6)),
          child: Row(
            children: [
              Text(
                "Warmup",
                maxLines: 1,
                style: TextStyle(
                  fontSize: ScreenUtil.horizontalScale(5.5),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: DashedBorder(
                      spaceLength: 8,
                      strokeCap: StrokeCap.square,
                      dashLength: 1,
                      top: BorderSide(color: isEditMode ? Colors.grey.shade700 : Colors.grey.shade400, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
            ],
          ),
        );
      },
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        itemCount: warmUps.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(3)).copyWith(top: 20, bottom: 20),
        separatorBuilder: (context, index) => SizedBox(height: ScreenUtil.verticalScale(3)),
        itemBuilder: (context, index) {
          return Consumer<MonthProvider>(
            builder: (context, monthProvider, child) {
              String split = monthProvider.monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first
                      .toString()
                      .split(" ")[1] ??
                  "";

              String warmUpDataId =
                  "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${warmUps[index].warmupId ?? ""}";

              bool isExist = (!monthProvider.exerciseHistoryModel.any((item) => item.dataId != warmUpDataId)) &&
                  monthProvider.isPastWeek;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(ScreenUtil.verticalScale(12)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (isEditMode) {
                      return;
                    } else {
                      monthProvider.updateWarmUp(true, warmUps[index].warmupId ?? '');
                      monthProvider.updateIsLastExercise(false);
                      Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: const Color(0xFFF3F3F3),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.verticalScale(12)),
                      ),
                      side: const BorderSide(color: Color(0x12000000), width: 0.5),
                    ),
                    surfaceTintColor: Colors.transparent,
                    overlayColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    width: media.width,
                    padding: EdgeInsets.only(right: ScreenUtil.verticalScale(2)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.verticalScale(12)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Consumer<MonthProvider>(builder: (context, value, child) {
                          return Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    child: appShimmerImage(
                                      height: media.width / 4,
                                      width: media.width / 4,
                                      networkImageUrl:
                                          "${warmUps[index].thumbnail}".startsWith('https://storage.cloud.google.com/')
                                              ? warmUps[index].thumbnail ??
                                                  "".replaceFirst('https://storage.cloud.google.com/',
                                                      'https://storage.googleapis.com/')
                                              : warmUps[index].thumbnail ?? "unknown",
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                        bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: media.width / 4,
                                    width: media.width / 4,
                                    decoration: monthProvider.exerciseHistoryModel.any((element) =>
                                            element.dataId == warmUpDataId && element.status == Status.completed)
                                        ? BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFFAADDAA).withValues(alpha: 0.8),
                                                const Color(0xFFAADDAA).withValues(alpha: 0.8),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                              bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                            ),
                                          )
                                        : monthProvider.exerciseHistoryModel.any((element) =>
                                                    element.dataId == warmUpDataId &&
                                                    element.status == Status.skipped) ||
                                                isExist
                                            ? BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.secondColor.withValues(alpha: 0.8),
                                                    AppColors.secondColor.withValues(alpha: 0.8),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                                ),
                                              )
                                            : BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                                ),
                                              ),
                                    child: Icon(
                                      monthProvider.exerciseHistoryModel.any((element) =>
                                              element.dataId == warmUpDataId && element.status == Status.completed)
                                          ? Icons.check
                                          : Icons.close,
                                      color: monthProvider.exerciseHistoryModel.any((element) =>
                                                  element.dataId == warmUpDataId &&
                                                  element.status == Status.completed) ||
                                              (monthProvider.exerciseHistoryModel.any((element) =>
                                                      element.dataId == warmUpDataId &&
                                                      element.status == Status.skipped) ||
                                                  isExist)
                                          ? Colors.white
                                          : Colors.transparent,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (context) {
                                    return SizedBox(
                                      width: media.width / 2.5,
                                      child: Text(
                                        (warmUps[index].title!.isEmpty ? "Warmup" : warmUps[index].title ?? "Warmup"),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: ScreenUtil.horizontalScale(3.8),
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    height: ScreenUtil.verticalScale(1.5),
                                  ),
                                  SizedBox(
                                    width: media.width / 2.5,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 2),
                                          child: SvgPicture.asset(
                                            "assets/icons/trend.svg",
                                            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                                            width: 20,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            (warmUps[index].guide!.isEmpty ? "" : warmUps[index].guide ?? ""),
                                            maxLines: 1,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.grey,
                                              fontSize: ScreenUtil.verticalScale(1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          );
                        }),
                        isEditMode
                            ? SizedBox()
                            : GestureDetector(
                                onTap: null,
                                child: Container(
                                  padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: ScreenUtil.verticalScale(3),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _resetDayData({required String status, required String type, required String status1}) async {
    await monthProvider?.fetchExerciseStatusLocalData();

    String split = monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    double totalWeight = 0;
    int exCount = 0;
    double average = 0;

    if (monthProvider!.isPumpDay) {
      if (monthProvider!.pumpDayModel!.circuits!.isNotEmpty) {
        final data = monthProvider!.pumpDayModel!.circuits!;
        for (int i = 0; i < data.length; i++) {
          var elementI = data[i];
          for (int j = 0; j < elementI.round!; j++) {
            for (int z = 0; z < elementI.circuitExercises!.length; z++) {
              var elementZ = elementI.circuitExercises?[z];

              await _saveExerciseData(
                  status: Status.reset, id: "${elementZ?.exerciseId}-$i:$j:$z", type: 'Circuit - $i:$j:$z');
            }
          }
        }
      }
    }

    // return;

    if (exercises.isNotEmpty) {
      final data = exercises;

      for (int i = 0; i < data.length; i++) {
        var elementI = data[i];

        await _saveExerciseData(status: Status.reset, id: elementI.exerciseId!, type: 'Exercise');
      }
    }

    if (monthProvider!.isPumpDay
        ? monthProvider?.pumpDayModel?.warmups != null
        : monthProvider!.dayDataModel!.warmups != null) {
      final data =
          monthProvider!.isPumpDay ? monthProvider?.pumpDayModel?.warmups : monthProvider!.dayDataModel!.warmups;
      for (int i = 0; i < data!.length; i++) {
        var elementI = data[i];

        await _saveExerciseData(status: status, id: elementI.warmupId!, type: 'Warmup');
      }
      Navigator.pop(context);
    }

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    final data1 = {
      "status": status1,
      "type": type,
      "endTime": "",
      "startTime": "${DateTime.now().toUtc()}",
      "totalWeight": totalWeight.toString(),
      "completedExercise": exCount.toString(),
      "averageRIR": average.toString(),
    };

    final apiReqBody = {
      "status": status1,
      "type": type,
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": "",
      "totalWeight": totalWeight.toString(),
      "completedExercise": exCount.toString(),
      "dataId": dataId,
      "averageRIR": average.toString(),
    };
    await ApiRepo.updateDayStatus(body: apiReqBody);
    await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);

    await monthProvider?.updateDayData();
    monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.fetchDayStatusLocalData();
    await monthProvider?.fetchSingleDayHistoryLocalData();
    await monthProvider?.updatePumpDayStatus();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }

  Widget resetDay(BuildContext context, BuildContext c1, void Function()? onPressed) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFFFFFF),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ScreenUtil.verticalScale(2)),
                        Text(
                          "Are you sure?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil.verticalScale(2.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(1.5)),
                          child: Text(
                            "This action reset your progress for this day. Are you sure you want to proceed?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: ScreenUtil.verticalScale(2),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!c1.mounted) return;
                                    Navigator.of(c1).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil.verticalScale(1.7),
                                    ),
                                    side: BorderSide(width: 2.0, color: AppColors.primaryColor),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.verticalScale(2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.horizontalScale(2.5)),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: onPressed,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: ScreenUtil.verticalScale(1.7),
                                    ),
                                  ),
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(2),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                    child: Icon(size: ScreenUtil.verticalScale(2.5), Icons.close, color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchEquipmentField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchEquipmentField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(3),
        vertical: ScreenUtil.horizontalScale(1),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search Exercises',
          hintStyle: TextStyle(
            color: Colors.black45,
            fontSize: ScreenUtil.verticalScale(2),
          ),
          suffixIcon: Icon(
            Icons.search,
            size: ScreenUtil.verticalScale(4),
            color: Colors.grey[300],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(2),
          ),
        ),
      ),
    );
  }
}
