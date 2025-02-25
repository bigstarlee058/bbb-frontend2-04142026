import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/models/MonthResponseModel/excersie_detail_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/removed_exercise_model.dart';
import 'package:bbb/models/MonthResponseModel/swap_exercise_model.dart';
import 'package:bbb/pages/MonthView/TodayPage/circuits_view.dart';
import 'package:bbb/pages/MonthView/TodayPage/workout_card.dart';
import 'package:bbb/pages/video_intro_page.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/routes/fade_page_route.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/MonthResponseModel/all_exercise_model.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final today = DateTime.now();
  MonthProvider? monthProvider;
  String searchQuery = "";

  List<ExerciseDataModel> exercises = [];
  List<RemovedExerciseModel> removedExercise = [];
  int totalWarmups = 0;
  bool isCurrentDayCompleted = false;
  bool isCurrentDaySkipped = false;
  String currentDayTitle = '';
  MainPageProvider? mainPageProvider;
  bool loader = false;

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        mainPageProvider?.changeTab(1);

        await fetchExtraAddedExercise().then(
          (value) {
            int nextWorkOutIndex =
                monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1].toString().contains("Workout")
                    ? int.parse(monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1]
                            .toString()
                            .replaceAll("Day ", "")
                            .replaceAll(" Workout", "")) -
                        1
                    : 0;
            currentDayTitle = monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1].toString().contains("Workout")
                ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
                : monthProvider!.weekDataModel!.dayList![monthProvider!.overviewCurrentDay - 1];
            fetchWarmupData();
            monthProvider?.fetchExerciseStatusLocalData();
            fetchRemovedExerciseLocalData();
            log(' monthProvider?.dayHistoryDetails? :::::::::::::::::: ${jsonEncode(monthProvider?.dayHistoryDetails)}');
            log('monthProvider?.actualWeek :::::::::::::::::: ${monthProvider?.actualWeek}');
            isCurrentDayCompleted = monthProvider?.dayHistoryDetails?.status == Status.completed;
            isCurrentDaySkipped = monthProvider?.dayHistoryDetails?.status == Status.skipped ||
                monthProvider?.dayHistoryDetails == null ||
                (monthProvider!.actualWeek! > 4 && monthProvider?.dayHistoryDetails?.status == Status.started);

            monthProvider?.fetchAllExercise();
          },
        );
      },
    );
    super.initState();
  }

  Future<void> fetchExtraAddedExercise() async {
    setState(
      () {
        log('monthProvider!.dayDataModel!.exercises! :::::::::::::::::: ${monthProvider!.dayDataModel!.exercises!}');
        exercises = [];
        log('exercises :::::::::::::::::: ${exercises.length}');
        loader = true;
        exercises = monthProvider!.isPumpDay ? monthProvider!.pumpDayModel!.exercises! : monthProvider!.dayDataModel!.exercises!;
        totalWarmups =
            monthProvider!.isPumpDay ? monthProvider!.pumpDayModel!.warmups!.length : monthProvider!.dayDataModel!.warmups!.length;

        log('exercises :::::::::::::::::: ${exercises.length}');
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
        await monthProvider?.fetchSwapExerciseData().then(
          (value) {
            if (monthProvider!.swapExerciseList.isNotEmpty) {
              for (var element in monthProvider!.swapExerciseList) {
                exercises.removeWhere((exercise) => exercise.exerciseId == element.exerciseId);
                exercises.insert(int.parse(element.insertIndex ?? "0"), element.exerciseJson!);
              }
            }
          },
        );
        await monthProvider?.fetchAllRemovedExerciseLocalData().then(
          (value) {
            if (monthProvider!.allRemovedExercise.isNotEmpty) {
              String split =
                  monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ??
                      "";

              String dataId =
                  "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

              for (var element in monthProvider!.allRemovedExercise) {
                exercises.removeWhere((exercise) => element.dataId == dataId && exercise.exerciseId == element.exerciseId);
              }
            }
          },
        );
      },
    );

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => setState(() => loader = false),
      );
    }
  }

  void fetchWarmupData() {
    final warmups = monthProvider!.isPumpDay ? monthProvider?.pumpDayModel?.warmups : monthProvider?.dayDataModel?.warmups;
    if (warmups != null && warmups.isNotEmpty) {
      monthProvider?.fetchWarmUp(warmups[0].warmupId!);
    }
  }

  Future<void> onPressed(int exerciseIndex, String dataId, bool isLast) async {
    monthProvider?.updateIsCircuit(false);
    monthProvider?.updateCircuit("", 0);
    monthProvider?.setSelectedExercise(exercises[exerciseIndex], exerciseIndex);
    monthProvider?.updateWarmUp(false);
    monthProvider?.updateIsLastExercise(isLast);
    await Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
    monthProvider?.fetchExerciseSingleExerciseLocalData(dataId);
  }

  fetchRemovedExerciseLocalData() async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    final data = await DatabaseHelper().getFilteredWithMWDData(
        tableName: DatabaseHelper.removedExerciseHistory,
        monthId: "${monthProvider?.monthDataModel?.id}",
        weekId: "${monthProvider?.weekDataModel?.id}",
        split: split,
        dayId: "${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}}");
    if (data.isNotEmpty) {
      removedExercise = List<RemovedExerciseModel>.from(json.decode(jsonEncode(data)).map((x) => RemovedExerciseModel.fromJson(x)));
    } else {
      removedExercise = [];
    }
    monthProvider?.fetchAllRemovedExerciseLocalData();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
    }
  }

  Future<void> removeExercise(String exerciseId) async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
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
    await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.removedExerciseHistory);
    await fetchRemovedExerciseLocalData();

    if (monthProvider!.addedExerciseList.isNotEmpty) {
      ExtraExerciseModel data =
          monthProvider!.addedExerciseList.firstWhere((element) => element.dataId == dataId, orElse: () => ExtraExerciseModel());
      if (data.id != null) {
        await DatabaseHelper().deleteSingleData(tableName: DatabaseHelper.extraExerciseHistory, id: data.dataId ?? "");
        await monthProvider?.fetchExtraAddedExerciseData();
      }
    }

    if (monthProvider!.swapExerciseList.isNotEmpty) {
      SwapExerciseModel data =
          monthProvider!.swapExerciseList.firstWhere((element) => element.dataId == dataId, orElse: () => SwapExerciseModel());
      if (data.id != null) {
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    context.watch<MainPageProvider>();
    ScreenUtil.init(context);
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => fetchExtraAddedExercise(),
      // ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: media.height,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: media.height / 2,
                                width: media.width,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/img/back.jpg'),
                                    fit: BoxFit.cover,
                                    opacity: 1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: media.height / 2,
                                width: media.width,
                                child: SafeArea(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(4)),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0XFFd18a9b),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SizedBox(
                                                    width: ScreenUtil.horizontalScale(10),
                                                    height: ScreenUtil.horizontalScale(10),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(
                                                        Icons.keyboard_arrow_left,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        // Navigator.pushNamed(context, '/dayOverview');
                                                      },
                                                      iconSize: ScreenUtil.verticalScale(4),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const CommonStreakWithNotification(routeString: "today")
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Option ${monthProvider!.alternateEquipmentType}:",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2),
                                              ),
                                            ),
                                            Text(
                                              monthProvider!.alternateEquipmentType == "A"
                                                  ? "Fully equipped gym"
                                                  : monthProvider?.alternateEquipmentType == "B"
                                                      ? "Home gym"
                                                      : "Dumbbells and bands",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2.3),
                                              ),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil.verticalScale(0.5),
                                            ),
                                            Consumer<MonthProvider>(builder: (context, monthProvider, child) {
                                              return Text(
                                                monthProvider.isPumpDay ? monthProvider.pumpDayModel?.title ?? "Pump Day" : currentDayTitle,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  height: 1.1,
                                                  fontSize: ScreenUtil.verticalScale(4),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtil.verticalScale(2.5)),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(10),
                                        ),
                                        child: ButtonWidget(
                                          text: "Watch Video Intro",
                                          color: const Color(0xEEFFFFFF),
                                          onPress: () {
                                            Navigator.of(context).push(
                                              FadePageRoute(
                                                page: const VideoIntroWidget(vimeoId: '953289606'),
                                              ),
                                            );
                                          },
                                          textColor: AppColors.primaryColor,
                                          isLoading: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: media.height / 2.64,
                                width: media.width,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: ClipPath(
                                    clipper: DiagonalClipper(),
                                    child: Container(
                                      height: media.height / 11,
                                      width: media.width / 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: media.width,
                        margin: EdgeInsets.only(
                          top: media.height / 2.65,
                          bottom: ScreenUtil.verticalScale(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(6)),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(8)),
                          child: Column(
                            children: [
                              totalWarmups == 0 ? const SizedBox() : warmUpSection(media),
                              Container(
                                width: media.width,
                                margin: EdgeInsets.only(left: ScreenUtil.verticalScale(3)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's workout",
                                      style: TextStyle(
                                        fontSize: ScreenUtil.horizontalScale(5.5),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: media.height * 0.025),
                                    monthProvider!.isPumpDay
                                        ? CircuitsView(
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
                                                if (removedExercise.any((element) => element.exerciseId == exercises[i].exerciseId!)) {
                                                  return const SizedBox();
                                                }
                                                String split = monthProvider
                                                        ?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
                                                        .toString()
                                                        .split(" ")[1] ??
                                                    "";

                                                String dataId =
                                                    "$split-${monthProvider!.monthDataModel?.id}-${monthProvider!.weekDataModel?.id}-${monthProvider!.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${exercises[i].exerciseId}";

                                                bool isExist =
                                                    (!monthProvider!.exerciseHistoryModel.any((item) => item.dataId != dataId)) &&
                                                        monthProvider!.isPastWeek;
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(right: ScreenUtil.verticalScale(3)),
                                                      child: WorkoutCard(
                                                        image: exercises[i].thumbnail ??
                                                            "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
                                                        dataId: dataId,
                                                        isDayCompleted: isCurrentDayCompleted,
                                                        isDaySkipped: isCurrentDaySkipped,
                                                        exerciseId: exercises[i].exerciseId!,
                                                        isCircuit: false,
                                                        isCompleted: monthProvider!.exerciseHistoryModel.any(
                                                            (element) => element.dataId == dataId && element.status == Status.completed),
                                                        isSkipped: (monthProvider!.exerciseHistoryModel.any((element) =>
                                                                    element.dataId == dataId && element.status == Status.skipped) ||
                                                                isExist) ||
                                                            isCurrentDaySkipped,
                                                        exerciseIndex: i,
                                                        onPress: (Function()? function) async {
                                                          await onPressed(
                                                            i,
                                                            dataId,
                                                            i ==
                                                                exercises.indexWhere(
                                                                  (element) => element.exerciseId == exercises.last.exerciseId,
                                                                ),
                                                          ).then(
                                                            (value) {
                                                              function!();
                                                            },
                                                          );
                                                        },
                                                        openSwapModal: () async {
                                                          await swipeExerciseDialog(i, exercises[i]);
                                                        },
                                                        exercise: exercises[i],
                                                        exerciseData: exercises[i].id!,
                                                        name: exercises[i].name!.isEmpty ? "Exercise ${i + 1}" : exercises[i].name!,
                                                        onRemove: () => removeExercise(exercises[i].exerciseId!),
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
                              SizedBox(height: ScreenUtil.verticalScale(2)),
                              monthProvider?.dayHistoryDetails == null ||
                                      isCurrentDayCompleted ||
                                      isCurrentDaySkipped ||
                                      monthProvider!.isPastWeek
                                  ? const SizedBox()
                                  : Padding(
                                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                      child: ButtonWidget(
                                        onPress: () async {
                                          await addExerciseDialog();
                                        },
                                        isLoading: false,
                                        color: Colors.grey,
                                        textColor: Colors.white,
                                        text: "Add Exercise",
                                      ),
                                    ),
                              const SizedBox(height: 36),
                              Container(
                                height: 1,
                                margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                                width: media.width * 0.75,
                                color: Colors.black12,
                              ),
                              const SizedBox(height: 36),
                              monthProvider?.dayHistoryDetails == null ||
                                      (isCurrentDaySkipped || isCurrentDayCompleted) ||
                                      monthProvider!.isPastWeek
                                  ? Container(
                                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                      child: ButtonWidget(
                                        text: monthProvider?.dayHistoryDetails?.status == Status.completed ? "Completed" : "Skipped",
                                        textColor: Colors.white,
                                        onPress: null,
                                        color: AppColors.primaryColor,
                                        isLoading: false,
                                      ),
                                    )
                                  : Consumer<MonthProvider>(
                                      builder: (context, value, child) => Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                            child: ButtonWidget(
                                              text: value.dayHistoryDetails?.status == Status.completed
                                                  ? "Completed"
                                                  : value.dayHistoryDetails?.status == Status.skipped
                                                      ? "Skipped"
                                                      : "Finish the workout",
                                              textColor: Colors.white,
                                              onPress: value.dayHistoryDetails?.status == Status.completed ||
                                                      value.dayHistoryDetails?.status == Status.skipped
                                                  ? null
                                                  : () async {
                                                      await _saveDayData(
                                                          status: Status.skipped,
                                                          type: monthProvider!.isPumpDay
                                                              ? "Pump Day - ${monthProvider?.pumpDayModel?.id}"
                                                              : "Workout Day",
                                                          status1: Status.completed);
                                                      if (!context.mounted) return;
                                                      Navigator.pushNamed(context, '/dayCompleted');
                                                    },
                                              color: AppColors.primaryColor,
                                              isLoading: false,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          value.dayHistoryDetails?.status != Status.skipped &&
                                                  value.dayHistoryDetails?.status != Status.completed
                                              ? Container(
                                                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                                  child: ButtonWidget(
                                                    text: "Skip the workout",
                                                    textColor: Colors.white,
                                                    onPress: () async {
                                                      await _saveDayData(
                                                          status: Status.skipped,
                                                          type: monthProvider!.isPumpDay
                                                              ? "Pump Day- ${monthProvider?.pumpDayModel?.id}"
                                                              : "Workout Day",
                                                          status1: Status.skipped);
                                                      if (!context.mounted) return;
                                                      Navigator.pushNamed(context, '/home');
                                                    },
                                                    color: AppColors.skipDayColor,
                                                    isLoading: false,
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                              const SizedBox(
                                height: 90,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
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
                          colorFilter: ColorFilter.mode(value.selectedPage == 0 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(8.5),
                          height: ScreenUtil.horizontalScale(8.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          value.changeTab(1);
                        },
                        icon: SvgPicture.asset(
                          'assets/img/2-calendar.svg',
                          colorFilter: ColorFilter.mode(value.selectedPage == 1 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
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
                          colorFilter: ColorFilter.mode(value.selectedPage == 2 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
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
                          colorFilter: ColorFilter.mode(value.selectedPage == 3 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(9),
                          height: ScreenUtil.horizontalScale(9),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// WARMUP SECTION

  Widget warmUpSection(Size media) {
    return Container(
      width: media.width,
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(4),
        vertical: ScreenUtil.verticalScale(2),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.verticalScale(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warm-Up',
              style: TextStyle(fontSize: ScreenUtil.horizontalScale(6), fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Consumer<MonthProvider>(builder: (context, monthProvider, child) {
              String split =
                  monthProvider.monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

              String warmUpDataId =
                  "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${monthProvider.warmUpModel?.id}";

              bool isExist = (!monthProvider.exerciseHistoryModel.any((item) => item.dataId != warmUpDataId)) && monthProvider.isPastWeek;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  appShimmerImage(
                    networkImageUrl: "${monthProvider.warmUpModel?.thumbnail}".startsWith('https://storage.cloud.google.com/')
                        ? monthProvider.warmUpModel?.thumbnail ??
                            "".replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                        : monthProvider.warmUpModel?.thumbnail ?? "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
                    borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil.verticalScale(1)),
                    ),
                    height: media.width / 3.7,
                    width: media.width / 3.7,
                    child: Container(
                      decoration: monthProvider.exerciseHistoryModel
                              .any((element) => element.dataId == warmUpDataId && element.status == Status.completed)
                          ? BoxDecoration(
                              gradient: LinearGradient(colors: [
                                const Color(0xFFAADDAA).withValues(alpha: 0.8),
                                const Color(0xFFAADDAA).withValues(alpha: 0.8),
                              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  ScreenUtil.verticalScale(1),
                                ),
                              ),
                            )
                          : (monthProvider.exerciseHistoryModel
                                      .any((element) => element.dataId == warmUpDataId && element.status == Status.skipped) ||
                                  isExist)
                              ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondColor.withValues(alpha: 0.8),
                                      AppColors.secondColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      ScreenUtil.verticalScale(1),
                                    ),
                                  ),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      ScreenUtil.verticalScale(1),
                                    ),
                                  ),
                                ),
                      child: Icon(
                        monthProvider.exerciseHistoryModel
                                .any((element) => element.dataId == warmUpDataId && element.status == Status.completed)
                            ? Icons.check
                            : Icons.close,
                        color: (monthProvider.exerciseHistoryModel.any((element) =>
                                    element.dataId == warmUpDataId &&
                                    (element.status == Status.completed || element.status == Status.skipped)) ||
                                isExist)
                            ? Colors.white
                            : Colors.transparent,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: media.width * 0.1,
                  ),
                  SizedBox(
                    height: media.width / 3.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: ScreenUtil.horizontalScale(6.5),
                          width: ScreenUtil.horizontalScale(6.5),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/deadline.png'),
                              fit: BoxFit.cover,
                              opacity: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil.horizontalScale(6.2),
                          width: ScreenUtil.horizontalScale(6.2),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/play.png'),
                              fit: BoxFit.cover,
                              opacity: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil.horizontalScale(6),
                          width: ScreenUtil.horizontalScale(6),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/question.png'),
                              fit: BoxFit.cover,
                              opacity: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: media.width / 3.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${monthProvider.warmUpModel?.length ?? ""} Min',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil.horizontalScale(4.5),
                          ),
                        ),
                        Text(
                          totalWarmups == 1 ? "1 Video" : '$totalWarmups Videos',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil.horizontalScale(4.5),
                          ),
                        ),
                        Text(
                          'Optional',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil.horizontalScale(4.5),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            }),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: ScreenUtil.verticalScale(3),
              ),
              child: Consumer<MonthProvider>(
                builder: (context, monthProvider, child) {
                  String split =
                      monthProvider.monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ??
                          "";

                  String warmUpDataId =
                      "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${monthProvider.warmUpModel?.id}";
                  bool isExist =
                      (!monthProvider.exerciseHistoryModel.any((item) => item.dataId != warmUpDataId)) && monthProvider.isPastWeek;

                  return ButtonWidget(
                    text: monthProvider.exerciseHistoryModel
                            .any((element) => element.dataId == warmUpDataId && element.status == Status.completed)
                        ? "Completed"
                        : monthProvider.exerciseHistoryModel
                                    .any((element) => element.dataId == warmUpDataId && element.status == Status.skipped) ||
                                isExist
                            ? "Skipped"
                            : "Start the warm-up",
                    textColor: Colors.white,
                    onPress: monthProvider.exerciseHistoryModel.any((element) =>
                                element.dataId == warmUpDataId &&
                                (element.status == Status.completed || element.status == Status.skipped)) ||
                            isExist
                        ? null
                        : () async {
                            monthProvider.updateWarmUp(true);
                            monthProvider.updateIsLastExercise(false);
                            Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
                          },
                    color: AppColors.primaryColor,
                    isLoading: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ADD EXERCISE SECTION

  Future<void> addExerciseDialog() async {
    monthProvider?.fetchAllExercise();

    if (mounted) {
      return showDialog(
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
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                          )
                        : SizedBox(
                            width: ScreenUtil.horizontalScale(96),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: ScreenUtil.verticalScale(65),
                              ),
                              child: Builder(builder: (context) {
                                List<Widget> buildExerciseList(List<Exercise> exercises, int currentPage, bool isAll) {
                                  int startIndex = currentPage * itemsPerPage + (!isAll ? 0 : monthProvider!.relatedExercises.length);
                                  int endIndex =
                                      (startIndex + itemsPerPage) > exercises.length + (!isAll ? 0 : monthProvider!.relatedExercises.length)
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
                                                    networkImageUrl:
                                                        exercises[i - (!isAll ? 0 : monthProvider!.relatedExercises.length)].thumbnail ??
                                                            "",
                                                    fit: BoxFit.cover,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(ScreenUtil.horizontalScale(1)),
                                                    ),
                                                  ),
                                                  SizedBox(width: ScreenUtil.horizontalScale(2)),
                                                  Flexible(
                                                      child: Text(
                                                    exercises[i - (!isAll ? 0 : monthProvider!.relatedExercises.length)].title ?? "",
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
                                                color: selectExerciseSwapIndex == i ? AppColors.primaryColor : Colors.white,
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

                                Widget buildPaginationControls(int currentPage, int totalItems, Function(int) onPageChange) {
                                  int totalPages = (totalItems / itemsPerPage).ceil();
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
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
                                          onPressed: (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                                          icon: const Icon(Icons.arrow_forward),
                                        ),
                                        IconButton(
                                          onPressed: (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
                                          icon: const Icon(Icons.last_page),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                monthProvider!.allFilterExercises.removeWhere((element) =>
                                    monthProvider!.addedExerciseList.any((ele) => ele.exerciseId == element.id) ||
                                    exercises.any((ele) => ele.exerciseId == element.id));

                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: media.width,
                                        padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Select from the list:',
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
                                      monthProvider!.allFilterExercises.isNotEmpty
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
                                                        children:
                                                            buildExerciseList(monthProvider!.allFilterExercises, currentPageAll, false),
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
                                          : const Center(
                                              child: Text("No exercise available"),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: const Color(0xFFDDDDDD),
                                                shadowColor: Colors.grey,
                                                padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                ExerciseDataModel newDayExercise = ExerciseDataModel();
                                                if (exercises.isNotEmpty) {
                                                  newDayExercise = ExerciseDataModel(
                                                    id: "",
                                                    exerciseId: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].id ?? "",
                                                    typeId: exercises[0].typeId ?? 1,
                                                    name: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].title ??
                                                        "Exercise ${exercises.length + 1}",
                                                    guide: exercises[0].guide ?? "",
                                                    sets: exercises[0].sets ?? 0,
                                                    reps: exercises[0].reps ?? 0,
                                                    rest: exercises[0].rest ?? 0,
                                                    weight: exercises[0].weight ?? 0,
                                                    formats: exercises[0].formats ?? [],
                                                    thumbnail: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].thumbnail ??
                                                        "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
                                                    extra: exercises[0].extra ?? [],
                                                  );
                                                } else {
                                                  newDayExercise = ExerciseDataModel(
                                                    id: "",
                                                    exerciseId: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].id ?? "",
                                                    typeId: 1,
                                                    name: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].title ??
                                                        "Exercise ${exercises.length + 1}",
                                                    thumbnail: monthProvider?.allFilterExercises[selectExerciseSwapIndex!].thumbnail ??
                                                        "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
                                                    guide: "",
                                                    sets: 5,
                                                    reps: 10,
                                                    rest: 3,
                                                    weight: 30,
                                                    formats: ["A", "B", "C"],
                                                  );
                                                }

                                                String split = monthProvider
                                                        ?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
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
                                                  "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
                                                  "date": "${DateTime.now().toUtc()}",
                                                  "exerciseId": monthProvider?.allFilterExercises[selectExerciseSwapIndex!].id,
                                                  "exerciseJson": jsonEncode(newDayExercise)
                                                };

                                                RemovedExerciseModel removedDataExit = removedExercise.firstWhere(
                                                  (element) => element.dataId == dataId,
                                                  orElse: () => RemovedExerciseModel(),
                                                );
                                                if (removedDataExit.id != null) {
                                                  await DatabaseHelper().deleteSingleData(
                                                      tableName: DatabaseHelper.removedExerciseHistory, id: removedDataExit.dataId!);
                                                }

                                                exercises.add(newDayExercise);
                                                await DatabaseHelper()
                                                    .insertData(tableName: DatabaseHelper.extraExerciseHistory, data: data);
                                                await monthProvider?.fetchExtraAddedExerciseData();
                                                setState(() {});
                                                if (!context.mounted) return;
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: AppColors.primaryColor,
                                                shadowColor: Colors.grey,
                                                padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                insetPadding: const EdgeInsets.all(0),
                child: Consumer<MonthProvider>(builder: (context, value, child) {
                  return value.exerciseLoader
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ScreenUtil.horizontalScale(96),
                            maxHeight: ScreenUtil.verticalScale(58),
                          ),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
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
                                int endIndex =
                                    (startIndex + itemsPerPage) > exercises.length ? exercises.length : startIndex + itemsPerPage;

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
                                                  networkImageUrl: exercises[i - (0)].thumbnail ??
                                                      "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
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
                                              color: selectExerciseSwapIndex == i ? AppColors.primaryColor : Colors.white,
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

                              Widget buildPaginationControls(int currentPage, int totalItems, Function(int) onPageChange) {
                                int totalPages = (totalItems / itemsPerPage).ceil();
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
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
                                        onPressed: (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                      IconButton(
                                        onPressed: (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
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
                                                  networkImageUrl: exercises[i].thumbnail ??
                                                      "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
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
                                              color: selectRelatedExerciseSwapIndex == i ? AppColors.primaryColor : Colors.white,
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

                              Widget buildPaginationControlsRelatedExercise(int currentPage, int totalItems, Function(int) onPageChange) {
                                int totalPages = (totalItems / itemsPerPageRelated).ceil();
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
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
                                        onPressed: (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                      IconButton(
                                        onPressed: (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
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

                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: media.width,
                                      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 20, bottom: 8),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Select Related Exercise',
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
                                                        final filteredList = monthProvider!.relatedExercises.where((item) {
                                                          return seenIds.add(item.sId!);
                                                        }).toList();
                                                        return Column(
                                                          children: [
                                                            Column(
                                                              children: buildRelatedExerciseList(filteredList, currentPageRelated),
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
                                                "No related exercise available!",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                    Container(
                                      width: media.width,
                                      padding: const EdgeInsets.only(left: 24, right: 24),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Or select from the list:',
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
                                            height: media.width * 0.4,
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
                                                          children: buildExerciseList(monthProvider!.allFilterExercises, currentPageAll),
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
                                            : Padding(
                                                padding: const EdgeInsets.only(bottom: 5),
                                                child: Center(
                                                  child: Text(
                                                    "No exercise available!",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor: const Color(0xFFDDDDDD),
                                              shadowColor: Colors.grey,
                                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              RelatedExercises? relatedExerciseData;
                                              Exercise? exerciseDataModel;

                                              if (selectRelatedExerciseSwapIndex == null) {
                                                exerciseDataModel = monthProvider!.allFilterExercises[selectExerciseSwapIndex!];
                                              } else {
                                                relatedExerciseData = monthProvider!.relatedExercises[selectRelatedExerciseSwapIndex!];
                                              }

                                              ExerciseDataModel newDayExercise = ExerciseDataModel(
                                                id: "",
                                                exerciseId: exerciseDataModel?.id ?? relatedExerciseData?.sId ?? "",
                                                typeId: exercises[selectedIndex].typeId ?? 1,
                                                thumbnail: exerciseDataModel?.thumbnail ??
                                                    relatedExerciseData?.thumbnail ??
                                                    "https://asset.cloudinary.com/de3iwsrnr/41efbf82db182182b093eeb0a294827e",
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
                                                      ?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
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
                                                "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
                                                "date": "${DateTime.now().toUtc()}",
                                                "exerciseId": exerciseDataModel?.id ?? relatedExerciseData?.sId ?? "",
                                                "exerciseJson": jsonEncode(newDayExercise),
                                                "insertIndex": selectedIndex.toString()
                                              };

                                              RemovedExerciseModel removedDataExit = removedExercise.firstWhere(
                                                (element) => element.dataId == dataId,
                                                orElse: () => RemovedExerciseModel(),
                                              );

                                              if (removedDataExit.id != null) {
                                                await DatabaseHelper().deleteSingleData(
                                                    tableName: DatabaseHelper.removedExerciseHistory, id: removedDataExit.dataId!);
                                              }
                                              exercises.removeAt(selectedIndex);
                                              exercises.insert(selectedIndex, newDayExercise);
                                              await DatabaseHelper().insertData(tableName: DatabaseHelper.swapExerciseHistory, data: data);
                                              await monthProvider?.fetchSwapExerciseData();
                                              await removeExercise(exercise.exerciseId ?? "");
                                              setState(() {});
                                              if (!context.mounted) return;
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: AppColors.primaryColor,
                                              shadowColor: Colors.grey,
                                              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

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

    final data1 = {
      "status": status,
      "type": type,
    };

    if (monthProvider!.exerciseHistoryModel.isNotEmpty) {
      if (monthProvider!.exerciseHistoryModel.any((element) => element.dataId == dataId)) {
        await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseStatus, id: dataId);
      } else {
        await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
      }
    } else {
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
    }
  }

  Future<void> _saveDayData({required String status, required String type, required String status1}) async {
    await monthProvider?.fetchExerciseStatusLocalData();

    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    double totalWeight = 0;
    int exCount = 0;

    for (int i = 0; i < monthProvider!.exerciseHistoryModel.length; i++) {
      var element = monthProvider!.exerciseHistoryModel[i];
      if (element.status == Status.completed) {
        exCount++;
        totalWeight += double.parse(element.totalWeight!);
      }
    }

    if (monthProvider!.isPumpDay) {
      if (monthProvider!.pumpDayModel!.circuits!.isNotEmpty) {
        final data = monthProvider!.pumpDayModel!.circuits!;
        for (int i = 0; i < data.length; i++) {
          var elementI = data[i];
          for (int j = 0; j < elementI.round!; j++) {
            for (int z = 0; z < elementI.circuitExercises!.length; z++) {
              var elementZ = elementI.circuitExercises?[z];

              String dataId =
                  "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementZ?.exerciseId}-$i:$j";

              bool? val = monthProvider?.exerciseHistoryModel
                  .any((element) => element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
              if (val == false) {
                await _saveExerciseData(status: status, id: "${elementZ?.exerciseId}-$i:$j", type: 'Circuit - $i:$j');
              }
            }
          }
        }
      }
    }

    if (exercises.isNotEmpty) {
      final data = exercises;

      for (int i = 0; i < data.length; i++) {
        var elementI = data[i];

        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.exerciseId}";

        bool? val = monthProvider?.exerciseHistoryModel
            .any((element) => element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
        if (val == false) {
          await _saveExerciseData(status: status, id: elementI.exerciseId!, type: 'Exercise');
        }
      }
    }

    if (monthProvider!.isPumpDay ? monthProvider?.pumpDayModel?.warmups != null : monthProvider!.dayDataModel!.warmups != null) {
      final data = monthProvider!.isPumpDay ? monthProvider?.pumpDayModel?.warmups : monthProvider!.dayDataModel!.warmups;
      for (int i = 0; i < data!.length; i++) {
        var elementI = data[i];

        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${elementI.warmupId}";
        bool? val = monthProvider?.exerciseHistoryModel
            .any((element) => element.dataId == dataId && (element.status == Status.completed || element.status == Status.skipped));
        if (val == false) {
          await _saveExerciseData(status: status, id: elementI.warmupId!, type: 'Warmup');
        }
      }
    }

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    ///

    final data1 = {
      "status": status1,
      "type": type,
      "endTime": (status == Status.completed || status == Status.skipped) ? "${DateTime.now().toUtc()}" : "",
      "totalWeight": totalWeight.toString(),
      "completedExercise": exCount.toString(),
    };

    await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);

    await monthProvider?.updateDayData();
    monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.fetchDayStatusLocalData();
    await monthProvider?.fetchSingleDayHistoryLocalData();
    await monthProvider?.updatePumpDayStatus();

    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
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
