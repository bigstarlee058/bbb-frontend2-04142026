import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/athletes_list_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/collection_grid.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/join_challenge_widget.dart';
import 'package:bbb/components/program_phases_widget.dart';
import 'package:bbb/components/share_achievement_new_dialog.dart';
import 'package:bbb/components/staff_list_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/get_all_achivements.dart';
import 'package:bbb/pages/DashBoardScreen/step_progress_bar.dart';
import 'package:bbb/pages/DashBoardScreen/week_calender.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_average_rir.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_exercise_completed.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_weight_lifted.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/scroll_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final today = DateTime.now();

  // double _opacity = 1.0;
  // UserDataManager userManager = UserDataManager();
  List<String> title = [];
  int focusedIndexStuff = 0;
  UserDataProvider? userData;
  DataProvider? dataProvider;
  late MainPageProvider mainPageProvider;
  late MonthProvider monthProvider;
  late ScrollProvider scrollProvider;
  String selectedChart = "Exercises Completed";

  @override
  void initState() {
    super.initState();
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    scrollProvider = Provider.of<ScrollProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);

    loadUserInfo();
    loadStaffsData();
    loadFeaturedChallengeData();
    loadFeaturedCollectionData();
    // loadAchievementsData(true);
    loadProgramPhaseData();
    requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void loadStaffsData() async {
    await dataProvider?.fetchStaffs();
  }

  Future<void> loadAchievementsData(value) async {
    await dataProvider?.getAllAchievement(value);
  }

  void loadFeaturedChallengeData() async {
    await dataProvider?.fetchFeaturedChalleng();
  }

  Future<void> loadUserInfo() async {
    await userData?.loadUserInfo();
  }

  void loadFeaturedCollectionData() async {
    await dataProvider?.fetchFeaturedColllections();
  }

  void loadProgramPhaseData() async {
    await dataProvider?.getProgramPhaseDetails();
  }

  Future<void> _initializeFetchData() async {
    log('DASHBOARD PAGE INIT');
    if (dataProvider != null) {
      await dataProvider?.fetchMonthWorkouts(3);
    } else {
      debugPrint("dataProvider is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataProvider == null || userData == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor));
    }
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            WidgetsBinding.instance.scheduleFrameCallback(
              (timeStamp) {
                scrollProvider.updateOffSet(notification.metrics.pixels);
              },
            );
          }
          return true;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            imageLoad(media),
            mainContent(context, media),
            Consumer<ScrollProvider>(
              builder: (context, scrollValue, child) {
                double blurValue =
                    (scrollValue.scrollOffset / ScreenUtil.verticalScale(35))
                            .clamp(0, 1) *
                        5;
                double targetHeight = ScreenUtil.verticalScale(4.5);
                return ClipRRect(
                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                    child: Container(
                      color: Colors.black.withOpacity(
                          (scrollValue.scrollOffset /
                                      ScreenUtil.verticalScale(35))
                                  .clamp(0, 1) *
                              0.7),
                      height: targetHeight + MediaQuery.of(context).padding.top,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: targetHeight,
                          width: media.width,
                          padding: EdgeInsets.only(
                            left: ScreenUtil.horizontalScale(6),
                          ),
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil.verticalScale(0.1)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer<UserDataProvider>(
                                    builder: (context, userData, child) {
                                      return AnimatedOpacity(
                                        opacity: scrollValue.scrollOffset > 0
                                            ? 0
                                            : 1,
                                        duration: Duration(milliseconds: 300),
                                        child: Text(
                                          'Hi ${userData.userName}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                ScreenUtil.horizontalScale(5.5),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: CommonStreakWithNotification(
                                      routeString: '/exerciseLibrary',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget imageLoad(Size media) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: dataProvider!.cachedImageMap.entries.map((entry) {
          return Visibility(
            visible: true,
            child: Utils.appImage(
              media,
              image: entry.value,
              imageKey: entry.key,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget mainContent(BuildContext context, Size media) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async => await _initializeFetchData().then((value) async {
        loadUserInfo();
        loadStaffsData();
        loadFeaturedChallengeData();
        loadProgramPhaseData();
        loadFeaturedCollectionData();
        if (!context.mounted) return;
        await monthProvider.onInit(context: context, isEnabled: false);
        await loadAchievementsData(false);
      }),
      child: SingleChildScrollView(
        physics: NoBottomBounceScrollPhysics(),
        child: Stack(
          children: [
            Stack(
              children: [
                Consumer<MonthProvider>(
                  builder: (context, monthData, child) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil.verticalScale(4) +
                            MediaQuery.of(context).padding.top,
                      ),
                      child: Builder(
                        builder: (context) {
                          if ((monthData.monthDataModel?.weeks == null ||
                                  monthData.loader) ||
                              monthData.switchMonthLoader ||
                              monthData.week == 0) {
                            return const SizedBox();
                          }

                          if ((monthData.week ?? 0) > 4) {
                            return const SizedBox();
                          }
                          if (monthData.todayTitleId.isNotEmpty) {
                            int? index = monthData.monthDataModel
                                ?.weeks?[(monthData.week ?? 1) - 1].idList
                                ?.indexWhere((element) =>
                                    element == monthData.todayTitleId);

                            if ((index ?? 0) < 0) {
                              return SizedBox();
                            }

                            String split = monthData
                                    .monthDataModel
                                    ?.weeks?[(monthData.week ?? 1) - 1]
                                    .idList
                                    ?.first
                                    .toString()
                                    .split(" ")[1] ??
                                "";
                            String dataId =
                                "$split-${monthData.monthDataModel?.id}-${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].id}-${monthData.todayTitleId}";

                            final data = monthData.allDayHistoryModel
                                .where((element) => element.dataId == dataId);
                            String status = "";
                            if (data.isNotEmpty) {
                              status = data.first.status ?? "";
                            }
                            final dayIndex = int.parse((monthData
                                        .monthDataModel
                                        ?.weeks![(monthData.week ?? 1) - 1]
                                        .dayList?[index ?? 0]
                                        .toString()
                                        .replaceAll("Workout", "")
                                        .replaceAll("Rest", "")
                                        .replaceAll("Day", "")
                                        .replaceAll(" ", "") ??
                                    "0")) -
                                1;

                            DayDataModel dayData =
                                "${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].dayList![index ?? 0] ?? ""}"
                                        .toString()
                                        .contains("Workout")
                                    ? monthData
                                        .monthDataModel!
                                        .weeks![(monthData.week ?? 1) - 1]
                                        .days![dayIndex]
                                    : DayDataModel();

                            bool isRestDay =
                                "${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].dayList![index ?? 0] ?? ""}"
                                    .toString()
                                    .contains("Rest Day");

                            int nextWorkOutIndex = monthData
                                    .monthDataModel!
                                    .weeks![(monthData.week ?? 1) - 1]
                                    .dayList![index ?? 0]
                                    .toString()
                                    .contains("Workout")
                                ? int.parse(monthData
                                        .monthDataModel!
                                        .weeks![(monthData.week ?? 1) - 1]
                                        .dayList![index ?? 0]
                                        .toString()
                                        .replaceAll("Day ", "")
                                        .replaceAll(" Workout", "")) -
                                    1
                                : 0;

                            String todayTitleName = "Pump Day";

                            final dataList = monthProvider.dayHistoryModel
                                .where((element) =>
                                    element.type?.contains("Pump Day") ==
                                        true &&
                                    element.status != Status.empty)
                                .toList();

                            if (monthProvider.pumpDays.isNotEmpty) {
                              if (dataList.isNotEmpty) {
                                int index1 = monthProvider.pumpDays.indexWhere(
                                    (el1) => dataList.any((e1) => (e1.dayId ==
                                            monthProvider.todayTitleId &&
                                        e1.type.toString().replaceAll(
                                                "Pump Day - ", "") ==
                                            el1.id)));
                                if (index1 != -1) {
                                  todayTitleName =
                                      monthProvider.pumpDays[index1].title ??
                                          "Pump Day";
                                } else {
                                  if (monthProvider.pumpDays.length == 1) {
                                    todayTitleName =
                                        monthProvider.pumpDays[0].title ??
                                            "Pump Day";
                                  } else {
                                    int index1 = monthProvider.pumpDays
                                        .indexWhere((el1) => dataList.any(
                                            (e1) =>
                                                e1.type.toString().replaceAll(
                                                    "Pump Day - ", "") ==
                                                el1.id));
                                    todayTitleName = monthProvider
                                            .pumpDays[index == -1
                                                ? 0
                                                : index1 == 0
                                                    ? 1
                                                    : 0]
                                            .title ??
                                        "Pump Day";
                                  }
                                }
                              } else {
                                todayTitleName =
                                    monthProvider.pumpDays[0].title ??
                                        "Pump Day";
                              }
                            }
                            DayHistoryModel? matchingElement =
                                monthData.allDayHistoryModel.firstWhere(
                              (element) =>
                                  element.dataId == dataId &&
                                  element.type!.contains("Pump Day"),
                              orElse: () => DayHistoryModel(),
                            );
                            String title = matchingElement.id != null
                                ? matchingElement.title ?? "Pump Day"
                                : !monthData.isPumpDayAvailable && isRestDay
                                    ? (monthData
                                            .monthDataModel!
                                            .weeks![(monthData.week ?? 1) - 1]
                                            .restDayList![int.parse(monthData
                                                .monthDataModel!
                                                .weeks![
                                                    (monthData.week ?? 1) - 1]
                                                .dayList![index ?? 0]
                                                .toString()
                                                .split(" ")
                                                .toList()
                                                .last) -
                                            1] ??
                                        monthData
                                            .monthDataModel!
                                            .weeks![(monthData.week ?? 1) - 1]
                                            .dayList![index ?? 0] ??
                                        "")
                                    : !isRestDay
                                        ? monthData
                                                .monthDataModel!
                                                .weeks![monthData.week! - 1]
                                                .days![nextWorkOutIndex]
                                                .title ??
                                            ""
                                        : monthData.pumpDays.isEmpty
                                            ? "Pump Day"
                                            : todayTitleName;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(8),
                                vertical: ScreenUtil.verticalScale(2),
                              ),
                              height: media.height * 0.22,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    status == Status.completed
                                        ? "You've successfully completed:"
                                        : 'Your current workout:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.verticalScale(2),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          status == Status.completed
                                              ? "Week ${monthData.week ?? 0}"
                                              : title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                ScreenUtil.horizontalScale(6.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil.horizontalScale(8)),
                                    decoration: status == Status.completed
                                        ? BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                ScreenUtil.verticalScale(4)))
                                        : const BoxDecoration(),
                                    child: status == Status.completed
                                        ? ButtonWidget(
                                            text: "Review your Week",
                                            textColor: Colors.white,
                                            onPress: () async {
                                              monthProvider
                                                  .updateIsOnMonthPage(false);
                                              monthProvider
                                                  .updateScrollToRestDay(true);
                                              mainPageProvider.changeTab(1);
                                            },
                                            color: AppColors.primaryColor,
                                            isLoading: false,
                                          )
                                        : ButtonWidget(
                                            text: title.contains("Rest Day")
                                                ? "Mark Complete"
                                                : status == Status.started
                                                    ? 'Continue Your Workout'
                                                    : 'Start Your Workout',
                                            textColor: AppColors.primaryColor,
                                            color: status == Status.completed ||
                                                    status == Status.skipped
                                                ? Colors.white70
                                                : Colors.white,
                                            onPress: status ==
                                                        Status.completed ||
                                                    status == Status.skipped
                                                ? null
                                                : () => continueWorkoutOnTap(
                                                    isRestDay,
                                                    monthData,
                                                    dataId,
                                                    index,
                                                    dayData,
                                                    context),
                                            isLoading: false,
                                          ),
                                  )
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(8),
                                vertical: ScreenUtil.verticalScale(2),
                              ),
                              height: media.height * 0.22,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "You've successfully completed:",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.verticalScale(2),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Week ${monthData.week ?? 0}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                ScreenUtil.verticalScale(3),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil.horizontalScale(8)),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            ScreenUtil.verticalScale(4))),
                                    child: ButtonWidget(
                                      text: "Review your Week",
                                      textColor: Colors.white,
                                      onPress: () async {
                                        monthProvider
                                            .updateIsOnMonthPage(false);
                                        monthProvider
                                            .updateScrollToRestDay(true);
                                        mainPageProvider.changeTab(1);
                                      },
                                      color: AppColors.primaryColor,
                                      isLoading: false,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: media.height / 3.429 +
                      ScreenUtil.verticalScale(4) +
                      MediaQuery.of(context).padding.top,
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
            Container(
              margin: EdgeInsets.only(
                  top: media.height / 3.43 +
                      ScreenUtil.verticalScale(4) +
                      MediaQuery.of(context).padding.top),
              child: Container(
                width: media.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  ),
                ),
                child: Column(children: [
                  /// MONTH STATUS

                  currentMonthStatus(media),
                  const SizedBox(height: 15),

                  /// MONTH_VIEW AND EDIT PROGRAM

                  monthViewAndEditProgram(),

                  /// WEEK ACTIVITY

                  currentWeekActivity(),

                  /// WEEK ACTIVITY

                  graphs(),

                  /// ACHIEVEMENT PART

                  achievementSection(),

                  /// JOIN CHALLENGE

                  Consumer<DataProvider>(builder: (context, value, child) {
                    return value.featureChallengeData.id != ""

                        ///Please recheck this multiple
                        ? JoinChallengeWidget(
                            featureChallenge: value.featureChallengeData)
                        : SizedBox(height: ScreenUtil.verticalScale(5));
                  }),

                  /// PROGRAM WIDGET

                  ProgramPhasesWidget(),

                  /// PERIODIZATION CYCLE

                  periodizationCycle(media),

                  ///Featured Collections

                  featuredCollections(media),

                  /// MEET OUR TEAM

                  meetOurTeam(media),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget currentMonthStatus(Size media) {
    return Container(
      width: media.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(55),
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(7),
        vertical: ScreenUtil.verticalScale(1.5),
      ),
      child: Consumer<MonthProvider>(
        builder: (context, value, child) {
          if (monthProvider.monthDataModel == null ||
              value.currentWeek == 0 ||
              (value.monthDataModel?.weeks?.isEmpty ?? false)) {
            return const SizedBox();
          }

          final startTime = value.startTime ?? DateTime.now();

          int dayDelta = DateTime(today.year, today.month, today.day)
              .difference(
                  DateTime(startTime.year, startTime.month, startTime.day))
              .inDays;

          int week = (dayDelta ~/ 7) + 1;

          final val1 = (week - 1) * 7;

          final val2 = value.allDayHistoryModel.where((element) =>
              element.weekId ==
                  value.monthDataModel!.weeks![value.currentWeek - 1].id &&
              element.split == value.splitType &&
              element.monthId == value.monthDataModel?.id &&
              (element.status == "Completed" || element.status == "Skipped"));
          int count = week > 4 ? val1 : val1 + val2.length;

          if (count > 28) {
            count = 28;
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.horizontalScale(7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(top: ScreenUtil.verticalScale(1.2)),
                      child: Text(
                        "Current Month Status",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: ScreenUtil.horizontalScale(5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${28 - count} days remaining',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil.verticalScale(1.5),
                    ),
                  ),
                  Text(
                    '${count * 100 ~/ 28}% Complete',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil.verticalScale(1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StepProgressBar(
                totalSteps: 4,
                progress: ((count * 100 ~/ 28) / 100) * 4,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget monthViewAndEditProgram() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                monthProvider.updateIsOnMonthPage(true);
                monthProvider.updateScrollToRestDay(false);

                HapticFeedBack.buttonClick();
                mainPageProvider.changeTab(1);
              },
              style: ElevatedButton.styleFrom(
                shape: Utils.buttonStyle,
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                'Month View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.verticalScale(2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil.horizontalScale(3)),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                monthProvider.updateIsOnMonthPage(true);
                monthProvider.updateScrollToRestDay(false);

                HapticFeedBack.buttonClick();
                monthProvider.updateSelectedSection(1);
                mainPageProvider.changeTab(1);
              },
              style: ElevatedButton.styleFrom(
                shape: Utils.buttonStyle,
                side: BorderSide(width: 2.0, color: AppColors.primaryColor),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                'Edit Program',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: ScreenUtil.verticalScale(2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Consumer<MonthProvider> currentWeekActivity() {
    return Consumer<MonthProvider>(
      builder: (context, monthProvider, child) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(7)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: ScreenUtil.verticalScale(2),
                        top: ScreenUtil.verticalScale(2.5)),
                    child: Text(
                      "Current Week Activity",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: ScreenUtil.horizontalScale(5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/streak-calendar');
              },
              child: Container(
                color: Colors.transparent,
                child: WeekCalender(monthProvider: monthProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Consumer<MonthProvider> graphs() {
    return Consumer<MonthProvider>(
      builder: (context, value, child) {
        // reportExerciseCompletedGraphHistory
        // reportAverageRIRGraphHistory
        // reportWeightLiftedGraphHistory

        final listA = value.reportExerciseCompletedGraphHistory
            .map((e) => e["totalCompletedExercise"].value > 0)
            .toList();
        final listB = value.reportWeightLiftedGraphHistory
            .map((e) => e["totalWeight"].value > 0)
            .toList();
        final listC = value.reportAverageRIRGraphHistory
            .map((e) => e["totalAverageRIR"].value > 0)
            .toList();
        final isAvailable = listA.any((element) => element == true) ||
            listB.any((element) => element == true) ||
            listC.any((element) => element == true);
        if (isAvailable) {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.horizontalScale(7),
                    vertical: ScreenUtil.verticalScale(2.3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Recent Activity",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: ScreenUtil.horizontalScale(5.2),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: const Color.fromARGB(255, 252, 252, 252),
                      elevation: 10,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      itemBuilder: (context) {
                        return [
                          "Exercises Completed",
                          // "Time Spent",
                          "Weight Lifted",
                          "Average RIR",
                        ].map((str) {
                          return PopupMenuItem(
                              value: str,
                              child: Material(
                                elevation: 0,
                                color: const Color.fromARGB(255, 252, 252, 252),
                                child: Text(
                                  str,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: ScreenUtil.verticalScale(1.5),
                                  ),
                                ),
                              ));
                        }).toList();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            selectedChart,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil.verticalScale(1.5),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onSelected: (v) {
                        setState(() {
                          selectedChart = v;
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.horizontalScale(8.5))
                    .copyWith(top: 6),
                child: selectedChart == "Exercises Completed"
                    ? const ReportExerciseCompletedGraph()
                    : selectedChart == "Weight Lifted"
                        ? const ReportWeightLiftedGraph()
                        // : const TimeSpentGraph(),
                        : selectedChart == "Average RIR"
                            ? const ReportAverageRIRGraph()
                            // : const TimeSpentGraph(),
                            : const SizedBox(),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(9),
                  vertical: ScreenUtil.verticalScale(1),
                ),
                child: ButtonWidget(
                  text: 'See all progress reports',
                  textColor: Colors.white,
                  color: AppColors.primaryColor,
                  onPress: () {
                    Navigator.pushNamed(context, "/graphAndReports");
                  },
                  isLoading: false,
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Consumer<DataProvider> achievementSection() {
    return Consumer<DataProvider>(builder: (context, value, child) {
      List<AchievementModel>? data = dataProvider?.achievementList
          .where(
              (element) => element.achievements!.any((e) => e.achieved == true))
          .toList();
      return dataProvider!.achievementList.isEmpty || data!.isEmpty
          ? SizedBox()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil.horizontalScale(7),
                      vertical: ScreenUtil.verticalScale(2.3)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.horizontalScale(3.5),
                        vertical: ScreenUtil.horizontalScale(5)),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Achievements',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: ScreenUtil.horizontalScale(5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(2.2),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            3,
                            (index) {
                              return (data.length - 1) < index
                                  ? Expanded(child: SizedBox())
                                  : Builder(builder: (context) {
                                      final data1 = data[index]
                                          .achievements
                                          ?.where((element) =>
                                              element.achieved == false)
                                          .toList();

                                      Achievement? data2;
                                      if ((data1 != null && data1.isEmpty)) {
                                        data2 = data[index].achievements?.last;
                                      } else {
                                        int? index1 = data[index]
                                            .achievements
                                            ?.indexWhere((element) =>
                                                element.achievementAchievementId
                                                    ?.achievementIdId ==
                                                data1
                                                    ?.first
                                                    .achievementAchievementId
                                                    ?.achievementIdId);
                                        data2 = data[index].achievements?[
                                            index1 == 0
                                                ? 0
                                                : (index1 ?? 0) - 1];
                                      }

                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            int? index1 = data[index]
                                                .achievements
                                                ?.indexWhere(
                                                  (element) =>
                                                      element
                                                          .achievementAchievementId
                                                          ?.achievementIdId ==
                                                      data2
                                                          ?.achievementAchievementId
                                                          ?.achievementIdId,
                                                );

                                            AnimatedDialog.showAnimatedDialog(
                                              context: context,
                                              pageBuilder:
                                                  (context, anim1, anim2) =>
                                                      ShareAchievementNewDialog(
                                                item: data[index],
                                                achievements:
                                                    data[index].achievements ??
                                                        [],
                                                currentPage: index1 == 0
                                                    ? 0
                                                    : ((index1! + 1) ==
                                                            (data[index]
                                                                    .achievements
                                                                    ?.length ??
                                                                0))
                                                        ? index1
                                                        : index1 + 1,
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Stack(
                                                children: [
                                                  SizedBox(
                                                    height: ScreenUtil
                                                        .verticalScale(8),
                                                    width: ScreenUtil
                                                        .verticalScale(8),
                                                    child: appShimmerImage(
                                                      color: Colors.transparent,
                                                      height: ScreenUtil
                                                          .verticalScale(8),
                                                      width: ScreenUtil
                                                          .verticalScale(8),
                                                      networkImageUrl: "${data2?.achievementAchievementId?.image}"
                                                              .startsWith(
                                                                  'https://storage.cloud.google.com/')
                                                          ? data2?.achievementAchievementId
                                                                  ?.image ??
                                                              "".replaceFirst(
                                                                  'https://storage.cloud.google.com/',
                                                                  'https://storage.googleapis.com/')
                                                          : data2?.achievementAchievementId
                                                                  ?.image ??
                                                              "unknown",
                                                      fit: BoxFit.cover,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    500)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.horizontalScale(9),
                  ).copyWith(top: ScreenUtil.verticalScale(1.2)),
                  child: ButtonWidget(
                    text: 'See all Achievements',
                    textColor: Colors.white,
                    color: AppColors.primaryColor,
                    onPress: () {
                      Navigator.pushNamed(context, "/seeAllAchievementPage");
                    },
                    isLoading: false,
                  ),
                ),
              ],
            );
    });
  }

  Widget periodizationCycle(Size media) {
    return SizedBox(
      width: media.width,
      child: Column(
        children: [
          SizedBox(
            height: ScreenUtil.verticalScale(2.5),
          ),
          Consumer<DataProvider>(builder: (context, dataProvider, child) {
            return dataProvider.athletesData.isNotEmpty
                ? CarouselSlider.builder(
                    itemCount: dataProvider.athletesData.length,
                    options: CarouselOptions(
                      height: ScreenUtil.verticalScale(38),
                      viewportFraction: 0.65,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.4,
                      enableInfiniteScroll: true,
                      autoPlay: false,
                      onPageChanged: (index, reason) {},
                      scrollDirection: Axis.horizontal,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.pushNamed(context, '/meetOurStaff');
                          },
                          child: AnimatedContainer(
                            width: media.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            duration: const Duration(milliseconds: 300),
                            child: AthletesListWidget(
                              height: ScreenUtil.verticalScale(38),
                              width: ScreenUtil.horizontalScale(60),
                              oneAthlete: dataProvider.athletesData[index],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox();
          }),
        ],
      ),
    );
  }

  Consumer<DataProvider> featuredCollections(Size media) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        bool isAppUser = userData?.user["singuptype"] != "web" ? true : false;

        return isAppUser
            ? SizedBox(height: ScreenUtil.verticalScale(2.5))
            : (dataProvider.collectionsData.isNotEmpty)
                ? Container(
                    width: media.width,
                    margin: EdgeInsets.symmetric(
                      vertical: ScreenUtil.verticalScale(2.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: ScreenUtil.horizontalScale(7),
                              right: ScreenUtil.horizontalScale(7),
                              bottom: ScreenUtil.verticalScale(2.4)),
                          width: media.width,
                          child: Center(
                            child: Text(
                              "Featured Collections",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: ScreenUtil.horizontalScale(5),
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        CarouselSlider.builder(
                          itemCount: dataProvider.staffsData.length,
                          options: CarouselOptions(
                            height: ScreenUtil.verticalScale(38),
                            viewportFraction: 0.65,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.4,
                            enableInfiniteScroll: true,
                            autoPlay: false,
                            onPageChanged: (index, reason) {},
                            scrollDirection: Axis.horizontal,
                          ),
                          itemBuilder: (context, index, realIndex) {
                            return CollectionGrid(
                                collection:
                                    dataProvider.collectionsData[index]);
                          },
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: ScreenUtil.verticalScale(5));
      },
    );
  }

  Widget meetOurTeam(Size media) {
    return SizedBox(
      width: media.width,
      child: Column(
        children: [
          Container(
            width: media.width,
            margin: EdgeInsets.only(
              left: ScreenUtil.horizontalScale(7),
              right: ScreenUtil.horizontalScale(7),
              bottom: ScreenUtil.verticalScale(2.4),
            ),
            child: Center(
              child: Text(
                "Meet our team",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: ScreenUtil.horizontalScale(5),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return (dataProvider.staffsData.isNotEmpty)
                  ? CarouselSlider.builder(
                      itemCount: dataProvider.staffsData.length,
                      options: CarouselOptions(
                        height: ScreenUtil.verticalScale(38),
                        viewportFraction: 0.65,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.4,
                        enableInfiniteScroll: true,
                        autoPlay: false,
                        onPageChanged: (index, reason) {},
                        scrollDirection: Axis.horizontal,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, '/meetOurStaff');
                            },
                            child: AnimatedContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              duration: const Duration(milliseconds: 300),
                              child: StaffListWidget(
                                height: ScreenUtil.verticalScale(38),
                                width: ScreenUtil.horizontalScale(60),
                                oneStaff: dataProvider.staffsData[index],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox();
            },
          ),

          SizedBox(
            height: 100,
          )

          /// Old

          // staffs.isNotEmpty
          //     ? StaffCarousel(
          //         athletes: staffs, // List of athlete widgets (or data),
          //         height: ScreenUtil.verticalScale(48),
          //       )
          //     : const SizedBox(),
        ],
      ),
    );
  }

  Future<void> continueWorkoutOnTap(
      bool isRestDay,
      MonthProvider monthData,
      String dataId,
      int? index,
      DayDataModel dayData,
      BuildContext context) async {
    HapticFeedBack.buttonClick();
    bool isPumpDay = (isRestDay &&
            monthData.allDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            (monthData.isPumpDayAvailable &&
                (monthData.allDayHistoryModel.any((element) =>
                    element.dataId == dataId &&
                    element.type != "Rest Day")))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (monthProvider.allDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type == "Rest Day" &&
                element.status == ""))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (!monthProvider.allDayHistoryModel
                .map((e) => e.dataId)
                .toList()
                .contains(dataId)));

    monthData.changeIsPumpDay(isPumpDay);

    if (isPumpDay) {
      final dataList = monthProvider.dayHistoryModel
          .where((element) =>
              element.type?.contains("Pump Day") == true &&
              element.status != Status.empty)
          .toList();

      if (dataList.isNotEmpty) {
        int index1 = monthProvider.pumpDays.indexWhere((el1) => dataList.any(
            (e1) => (e1.dayId == monthProvider.todayTitleId &&
                e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider.updatePumpDayData(monthProvider.pumpDays[index1]);
        } else {
          int index1 = monthProvider.pumpDays.indexWhere((el1) => dataList.any(
              (e1) =>
                  e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
          monthProvider.updatePumpDayData(monthProvider.pumpDays[index == -1
              ? 0
              : index1 == 0
                  ? 1
                  : 0]);
        }
      } else {
        monthProvider.updatePumpDayData(monthProvider.pumpDays[0]);
      }
      // monthData.updatePumpDayData(monthData
      //     .pumpDays[int.parse(monthData.monthDataModel!.weeks![monthData.week! - 1].dayList![index ?? 0].toString().split(" ").last) - 1]);
    }

    monthData.overviewCurrentWeek = monthData.week ?? 1;
    monthData.overviewCurrentDay = ((index ?? 1) + 1);
    monthData.dayDataModel = dayData;
    userData?.previousPage = true;
    // monthData.alternateEquipmentType = monthData.equipmentType;
    monthData.weekDataModel =
        monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1];
    monthData.updateIsPastWeek(
        monthData.weekStatuses[(monthData.week ?? 1) - 1] == WeekType.pastWeek);

    final dayIndex = monthProvider.overviewCurrentDay;
    int nextWorkOutIndex = monthProvider.weekDataModel!.dayList![dayIndex - 1]
            .toString()
            .contains("Workout")
        ? int.parse(monthProvider.weekDataModel!.dayList![dayIndex - 1]
                .toString()
                .replaceAll("Day ", "")
                .replaceAll(" Workout", "")) -
            1
        : 0;
    String currentDayTitle = monthProvider.weekDataModel!.dayList![dayIndex - 1]
            .toString()
            .contains("Workout")
        ? monthProvider.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider.weekDataModel!.dayList![dayIndex - 1];
    // if (currentDayTitle.contains("Rest Day") && (!monthProvider.isPumpDay)) {
    //   Navigator.pushNamed(context, '/dayOverview');
    // }

    final isCompletedOrSkipped = (monthProvider.allSplitDayHistoryModel.any(
        (element) =>
            (element.status == Status.completed ||
                element.status == Status.skipped) &&
            element.dataId == dataId));

    if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider.isPumpDay) &&
        isCompletedOrSkipped) {
      return;
    } else if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider.isPumpDay) &&
        !isCompletedOrSkipped) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

      await Future.delayed(Duration(milliseconds: 20)).then(
        (value) {
          monthProvider.updateIsOnMonthPage(false);
          monthProvider.updateScrollToRestDay(true);
          mainPageProvider.changeTab(1);
        },
      );

      _completeRestDay(
              status: Status.completed, type: 'Rest Day', endDate: true)
          .then(
        (value) {
          if (context.mounted) {
            monthProvider.onInit(context: context, isEnabled: false);
          }
        },
      );
      await monthProvider.checkForPumpDay();
      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (c1) {
      //     return skipWorkoutDialog(context, c1);`
      //   },
      // );
    } else {
      if (monthProvider.isPumpDay) {
        if ((monthProvider.allSplitDayHistoryModel.any((element) =>
                (element.status == Status.completed ||
                    element.status == Status.skipped) &&
                element.dataId == dataId)) ==
            false) {
          _saveDayData(
              type: "Pump Day - ${monthProvider.pumpDayModel?.id}",
              status: Status.started,
              title: monthProvider.pumpDayModel?.title);
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today').then(
            (value) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) async => await monthProvider.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider.dayHistoryModel
                .any((element) => element.dataId == dataId)) ==
            false) {
          _saveDayData(status: Status.started, type: 'Workout Day');
        }
        if (!context.mounted) return;
        await Navigator.pushNamed(context, '/today');
      }
    }
    // Navigator.pushNamed(context, '/dayOverview');
  }

  Future<void> _saveDayData(
      {required String status, required String type, String? title}) async {
    String split = monthProvider.monthDataModel
            ?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}";

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider.monthDataModel?.id,
      "weekId": monthProvider.weekDataModel?.id,
      "dayId": monthProvider
          .weekDataModel?.idList![monthProvider.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": "",
    };

    DayHistoryModel? matchingElement = monthProvider.dayHistoryModel.firstWhere(
      (element) => element.dataId == dataId,
      orElse: () => DayHistoryModel(),
    );

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement.startTime.toString(),
      "endTime":
          (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
    };

    final apiBody = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement.startTime.toString(),
      "endTime":
          (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
      "dataId": dataId
    };

    if (matchingElement.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);
      await DatabaseHelper().updateData(
          tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);
      await DatabaseHelper()
          .insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider.fetchAllDayStatusLocalData();
    monthProvider.findWeekStatuses();
    monthProvider.fetchToday();
    monthProvider.manageStreak();
    monthProvider.getLiftedWeightGraphData();
  }

  Future<void> _completeRestDay(
      {required String status,
      required String type,
      String? title,
      bool endDate = false}) async {
    String split = monthProvider.monthDataModel
            ?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}";

    if (status == Status.completed) {
      ApiRepo.addDayStatusList(body: {
        "date": "${DateTime.now().toUtc()}",
        "status": Status.completed
      });
    }

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider.monthDataModel?.id,
      "weekId": monthProvider.weekDataModel?.id,
      "dayId": monthProvider
          .weekDataModel?.idList![monthProvider.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": endDate ? "${DateTime.now().toUtc()}" : "",
    };

    DayHistoryModel? matchingElement = monthProvider.dayHistoryModel.firstWhere(
        (element) => element.dataId == dataId,
        orElse: () => DayHistoryModel());

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement.startTime.toString(),
      "endTime": (status == Status.completed)
          ? "${DateTime.now().toUtc()}"
          : (endDate ? "${DateTime.now().toUtc()}" : ""),
    };

    final apiBody = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement.startTime.toString(),
      "endTime": (status == Status.completed)
          ? "${DateTime.now().toUtc()}"
          : (endDate ? "${DateTime.now().toUtc()}" : ""),
      "dataId": dataId
    };

    if (matchingElement.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);

      await DatabaseHelper().updateData(
          tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);

      await DatabaseHelper()
          .insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider.fetchAllDayStatusLocalData();
    monthProvider.findWeekStatuses();
    monthProvider.fetchToday();
    monthProvider.manageStreak();
    monthProvider.getLiftedWeightGraphData();
  }
}
