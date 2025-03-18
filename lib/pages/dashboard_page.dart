import 'dart:developer';

import 'package:bbb/components/athletes_list_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/collection_grid.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/join_challenge_widget.dart';
import 'package:bbb/components/staff_list_widget.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/pages/Charts/exercise_completed.dart';
import 'package:bbb/pages/Charts/weight_lifted.dart';
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
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
  Challenges featureChallengeData = Challenges(id: '', title: '', description: '', photo: '');

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
    requestNotificationPermission();

    // _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   double offset = _scrollController.offset;
    //   double newOpacity = (40 - offset) / 40;
    //   newOpacity = newOpacity.clamp(0.0, 1.0);
    //
    //   setState(() {
    //     _opacity = newOpacity;
    //   });
    // });
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void loadStaffsData() async {
    await dataProvider?.fetchStaffs();
  }

  void loadFeaturedChallengeData() async {
    await dataProvider?.fetchFeaturedChalleng();
    if (dataProvider!.featureChallengeData.id != "") {
      if (mounted) {
        setState(() {
          featureChallengeData = dataProvider!.featureChallengeData;
        });
      }
    }
  }

  void loadUserInfo() async {
    await userData?.loadUserInfo();
  }

  void loadFeaturedCollectionData() async {
    await dataProvider?.fetchFeaturedColllections();
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          WidgetsBinding.instance.scheduleFrameCallback(
            (timeStamp) {
              scrollProvider.updateOffSet(notification.metrics.pixels);
            },
          );
          return true;
        },
        child: Stack(
          children: [
            Consumer<ScrollProvider>(
              builder: (context, scrollProvider, child) {
                return Opacity(
                  opacity: scrollProvider.scrollOffset <= 0.0 ? 1 : 0,
                  child: Container(
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
                );
              },
            ),
            Consumer<ScrollProvider>(
              builder: (context, scrollProvider, child) {
                return scrollProvider.scrollOffset <= 0.0
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: media.height / 2,
                          width: media.width,
                          child: SafeArea(
                            child: Consumer<ScrollProvider>(
                              builder: (context, scrollProvider, child) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 10, bottom: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(8),
                                          top: ScreenUtil.verticalScale(0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Consumer<UserDataProvider>(
                                              builder: (context, userData, child) => userData.userName != ""
                                                  ? Text(
                                                      // 'Hi Nick'
                                                      'Hi ${userData.userName}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil.verticalScale(2.9),
                                                        height: 2,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: ScreenUtil.horizontalScale(0),
                                                  right: ScreenUtil.horizontalScale(0),
                                                  top: ScreenUtil.verticalScale(0),
                                                ),
                                                child: const CommonStreakWithNotification(routeString: "dashboard"),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : SizedBox();
              },
            ),
            RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async => await _initializeFetchData().then((value) async => await monthProvider.onInit(isEnabled: false)),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                Consumer<ScrollProvider>(
                                  builder: (context, scrollProvider, child) {
                                    return Opacity(
                                      opacity: scrollProvider.scrollOffset > 0.0 ? 1 : 0,
                                      child: Container(
                                        height: media.height / 2,
                                        width: media.width,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(image: AssetImage('assets/img/back.jpg'), fit: BoxFit.cover, opacity: 1),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: media.height / 2,
                                  width: media.width,
                                  child: SafeArea(
                                    child: Column(
                                      children: [
                                        Consumer<ScrollProvider>(
                                          builder: (context, scrollProvider, child) {
                                            return Container(
                                              margin: const EdgeInsets.only(right: 10, bottom: 0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: ScreenUtil.horizontalScale(8),
                                                      top: ScreenUtil.verticalScale(0),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Consumer<UserDataProvider>(
                                                            builder: (context, userData, child) => userData.userName != ""
                                                                ? Text(
                                                                    // 'Hi Nick'
                                                                    scrollProvider.scrollOffset >= 0.0 ? 'Hi ${userData.userName}' : "",
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: ScreenUtil.verticalScale(2.9),
                                                                      height: 2,
                                                                    ),
                                                                  )
                                                                : const SizedBox()),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                              left: ScreenUtil.horizontalScale(0),
                                                              right: ScreenUtil.horizontalScale(0),
                                                              top: ScreenUtil.verticalScale(0),
                                                            ),
                                                            child: scrollProvider.scrollOffset >= 0.0
                                                                ? const CommonStreakWithNotification(routeString: "dashboard")
                                                                : Row(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            alignment: Alignment.center,
                                                                            padding: EdgeInsets.all(ScreenUtil.verticalScale(0.65)),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.transparent,
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(color: Colors.transparent),
                                                                            ),
                                                                            child: Text(
                                                                              '',
                                                                              style: TextStyle(
                                                                                color: Colors.transparent,
                                                                                fontSize: ScreenUtil.verticalScale(0.8),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Icon(
                                                                            Icons.local_fire_department_outlined,
                                                                            color: Colors.transparent,
                                                                            size: ScreenUtil.verticalScale(3),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      IconButton(
                                                                        onPressed: null,
                                                                        icon: Icon(
                                                                          Icons.notifications_none,
                                                                          color: Colors.transparent,
                                                                          size: ScreenUtil.verticalScale(3),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        Consumer<MonthProvider>(
                                          builder: (context, monthData, child) {
                                            if ((monthData.monthDataModel?.weeks == null || monthData.loader)) {
                                              return const SizedBox();
                                            }

                                            if (monthData.week! > 4) {
                                              return const SizedBox();
                                            }

                                            if (monthData.todayTitleId.isNotEmpty) {
                                              int? index = monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].idList
                                                  ?.indexWhere((element) => element == monthData.todayTitleId);

                                              String split = monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].idList?.first
                                                      .toString()
                                                      .split(" ")[1] ??
                                                  "";

                                              String dataId =
                                                  "$split-${monthData.monthDataModel?.id}-${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].id}-${monthData.todayTitleId}";

                                              final data = monthData.allDayHistoryModel.where((element) => element.dataId == dataId);
                                              String status = "";
                                              if (data.isNotEmpty) {
                                                status = data.first.status ?? "";
                                              }
                                              final dayIndex = int.parse((monthData
                                                          .monthDataModel?.weeks![(monthData.week ?? 1) - 1].dayList?[index ?? 0]
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
                                                      ? monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1].days![dayIndex]
                                                      : DayDataModel();

                                              bool isRestDay =
                                                  "${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].dayList![index ?? 0] ?? ""}"
                                                      .toString()
                                                      .contains("Rest Day");

                                              int nextWorkOutIndex = monthData
                                                      .monthDataModel!.weeks![(monthData.week ?? 1) - 1].dayList![index ?? 0]
                                                      .toString()
                                                      .contains("Workout")
                                                  ? int.parse(monthData
                                                          .monthDataModel!.weeks![(monthData.week ?? 1) - 1].dayList![index ?? 0]
                                                          .toString()
                                                          .replaceAll("Day ", "")
                                                          .replaceAll(" Workout", "")) -
                                                      1
                                                  : 0;

                                              String pumpDayTitle = "Pump Day";

                                              final dataList = monthProvider.dayHistoryModel
                                                  .where((element) =>
                                                      element.type?.contains("Pump Day") == true && element.status != Status.empty)
                                                  .toList();
                                              if (monthProvider.pumpDays.isNotEmpty) {
                                                if (dataList.isNotEmpty) {
                                                  int index1 = monthProvider.pumpDays.indexWhere((el1) => dataList.any((e1) =>
                                                      (e1.dayId == monthProvider.todayTitleId &&
                                                          e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
                                                  if (index1 != -1) {
                                                    pumpDayTitle = monthProvider.pumpDays[index1].title ?? "Pump Day";
                                                  } else {
                                                    if (monthProvider.pumpDays.length == 1) {
                                                      pumpDayTitle = monthProvider.pumpDays[0].title ?? "Pump Day";
                                                    } else {
                                                      int index1 = monthProvider.pumpDays.indexWhere((el1) =>
                                                          dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
                                                      pumpDayTitle = monthProvider
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
                                                  pumpDayTitle = monthProvider.pumpDays[0].title ?? "Pump Day";
                                                }
                                              }

                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: ScreenUtil.horizontalScale(8),
                                                  vertical: ScreenUtil.verticalScale(2),
                                                ),
                                                height: media.height * 0.22,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Your current workout:',
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
                                                          Builder(builder: (context) {
                                                            // DayHistoryModel? matchingElement = monthData.allDayHistoryModel.firstWhere(
                                                            //   (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                            //   orElse: () => DayHistoryModel(),
                                                            // );
                                                            return Text(
                                                              /*matchingElement.id != null
                                                                  ? matchingElement.title ?? "Pump Day"
                                                                  : */
                                                              !isRestDay
                                                                  ? monthData.monthDataModel!.weeks![monthData.week! - 1]
                                                                          .days![nextWorkOutIndex].title ??
                                                                      ""
                                                                  : monthData.pumpDays.isEmpty
                                                                      ? "Pump Day"
                                                                      : pumpDayTitle,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: ScreenUtil.verticalScale(3),
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            );
                                                          })
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
                                                      decoration: status == Status.completed
                                                          ? BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)))
                                                          : const BoxDecoration(),
                                                      child: status == Status.completed
                                                          ? ButtonWidget(
                                                              text: "Completed",
                                                              textColor: Colors.white,
                                                              onPress: () {},
                                                              color: Colors.green,
                                                              isLoading: false,
                                                            )
                                                          : ButtonWidget(
                                                              text: status == Status.started ? 'Continue Workout' : 'Start Workout',
                                                              textColor: AppColors.primaryColor,
                                                              color: status == Status.completed || status == Status.skipped
                                                                  ? Colors.white70
                                                                  : Colors.white,
                                                              onPress: status == Status.completed || status == Status.skipped
                                                                  ? null
                                                                  : () => continueWorkoutOnTap(
                                                                      isRestDay, monthData, dataId, index, dayData, context),
                                                              isLoading: false,
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            } else {
                                              String split = monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].idList?.first
                                                      .toString()
                                                      .split(" ")[1] ??
                                                  "";

                                              String dataId =
                                                  "$split-${monthData.monthDataModel?.id}-${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].id}-${monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1].idList?.last}";

                                              DayHistoryModel data = monthData.allDayHistoryModel.firstWhere(
                                                (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                orElse: () => DayHistoryModel(title: "Pump Day"),
                                              );

                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: ScreenUtil.horizontalScale(8),
                                                  vertical: ScreenUtil.verticalScale(2),
                                                ),
                                                height: media.height * 0.22,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Your current workout:',
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
                                                            data.id != null
                                                                ? data.title
                                                                : (monthData
                                                                        .monthDataModel!.weeks![(monthData.week ?? 1) - 1].dayList?.last) ??
                                                                    "",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: ScreenUtil.verticalScale(3),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4))),
                                                      child: ButtonWidget(
                                                        text: "Completed",
                                                        textColor: Colors.white,
                                                        onPress: () {},
                                                        color: Colors.green,
                                                        isLoading: false,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: media.height / 2.54,
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
                            // Extra content below the Stack if needed
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: media.height / 2.55,
                            bottom: ScreenUtil.verticalScale(15),
                          ),
                          child: Container(
                            width: media.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ScreenUtil.verticalScale(6)),
                              ),
                            ),
                            child: Column(children: [
                              Container(
                                width: media.width,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(55),
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(10),
                                  vertical: ScreenUtil.verticalScale(2),
                                ),
                                child: Consumer<MonthProvider>(
                                  builder: (context, value, child) {
                                    if (value.currentWeek == 0 || (value.monthDataModel?.weeks?.isEmpty ?? false)) return const SizedBox();

                                    final startTime = value.startTime ?? DateTime.now();

                                    int dayDelta = DateTime(today.year, today.month, today.day)
                                        .difference(DateTime(startTime.year, startTime.month, startTime.day))
                                        .inDays;

                                    int week = (dayDelta ~/ 7) + 1;

                                    final val1 = (week - 1) * 7;

                                    final val2 = value.allDayHistoryModel.where((element) =>
                                        element.weekId == value.monthDataModel!.weeks![value.currentWeek - 1].id &&
                                        element.split == value.splitType &&
                                        element.monthId == value.monthDataModel?.id &&
                                        (element.status == "Completed" || element.status == "Skipped"));

                                    final count = week > 4 ? val1 : val1 + val2.length;

                                    return Column(
                                      children: [
                                        const SizedBox(height: 10),
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
                                        const SizedBox(height: 5),
                                        Stack(
                                          children: [
                                            Container(
                                              width: media.width,
                                              height: ScreenUtil.verticalScale(0.5),
                                              decoration: BoxDecoration(color: Colors.grey[300]),
                                            ),
                                            Container(
                                              width: (ScreenUtil.horizontalScale(80)) / (28 / count),
                                              height: ScreenUtil.verticalScale(0.5),
                                              decoration: const BoxDecoration(color: AppColors.primaryColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          HapticFeedBack.buttonClick();
                                          mainPageProvider.changeTab(1);
                                        },
                                        style: ElevatedButton.styleFrom(
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
                                  ],
                                ),
                              ),
                              Consumer<MonthProvider>(
                                builder: (context, monthProvider, child) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20, bottom: 10),
                                              child: Text(
                                                "Recent Streak",
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: ScreenUtil.horizontalScale(5.2),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomCalendarWidget(monthProvider: monthProvider),
                                    ],
                                  );
                                },
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8), vertical: 15),
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
                                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                  horizontal: ScreenUtil.horizontalScale(10),
                                ),
                                child: selectedChart == "Exercises Completed"
                                    ? const ExerciseCompletedGraph()
                                    : selectedChart == "Weight Lifted"
                                        ? const WeightLiftedGraph()
                                        // : const TimeSpentGraph(),
                                        : const SizedBox(),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(10),
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
                              featureChallengeData.id != ""

                                  ///Please recheck this multiple
                                  ? JoinChallengeWidget(featureChallenge: featureChallengeData)
                                  : Container(),

                              /// New Method

                              SizedBox(
                                width: media.width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: media.width,
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(6),
                                          right: ScreenUtil.horizontalScale(6),
                                          top: ScreenUtil.verticalScale(0),
                                          bottom: 20),
                                      child: Text(
                                        "Member Spotlight",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: ScreenUtil.verticalScale(2.3),
                                          fontWeight: FontWeight.w800,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
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
                              ),

                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return (dataProvider.collectionsData.isNotEmpty)
                                      ? Container(
                                          width: media.width,
                                          margin: EdgeInsets.only(
                                            top: ScreenUtil.verticalScale(8),
                                            bottom: ScreenUtil.verticalScale(4),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: ScreenUtil.horizontalScale(5), right: ScreenUtil.horizontalScale(5), bottom: 20),
                                                width: media.width,
                                                child: Text(
                                                  "Featured Collections",
                                                  style: TextStyle(
                                                    color: AppColors.primaryColor,
                                                    fontSize: ScreenUtil.verticalScale(2.4),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  textAlign: TextAlign.start,
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
                                                  return CollectionGrid(collection: dataProvider.collectionsData[index]);
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              ),

                              SizedBox(
                                width: media.width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: media.width,
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(6),
                                          right: ScreenUtil.horizontalScale(6),
                                          top: ScreenUtil.verticalScale(2),
                                          bottom: 20),
                                      child: Text(
                                        "Meet our team",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: ScreenUtil.verticalScale(2.3),
                                          fontWeight: FontWeight.w800,
                                        ),
                                        textAlign: TextAlign.start,
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

                                    /// Old

                                    // staffs.isNotEmpty
                                    //     ? StaffCarousel(
                                    //         athletes: staffs, // List of athlete widgets (or data),
                                    //         height: ScreenUtil.verticalScale(48),
                                    //       )
                                    //     : const SizedBox(),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void continueWorkoutOnTap(
      bool isRestDay, MonthProvider monthData, String dataId, int? index, DayDataModel dayData, BuildContext context) {
    HapticFeedBack.buttonClick();
    bool isPumpDay = (isRestDay &&
            monthData.allDayHistoryModel.any((element) => element.dataId == dataId && element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            (monthData.isPumpDayAvailable &&
                (monthData.allDayHistoryModel.any((element) => element.dataId == dataId && element.type != "Rest Day")))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (monthProvider.allDayHistoryModel
                .any((element) => element.dataId == dataId && element.type == "Rest Day" && element.status == ""))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (!monthProvider.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId)));

    monthData.changeIsPumpDay(isPumpDay);

    if (isPumpDay) {
      final dataList = monthProvider.dayHistoryModel
          .where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty)
          .toList();

      if (dataList.isNotEmpty) {
        int index1 = monthProvider.pumpDays.indexWhere((el1) =>
            dataList.any((e1) => (e1.dayId == monthProvider.todayTitleId && e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider.updatePumpDayData(monthProvider.pumpDays[index1]);
        } else {
          int index1 =
              monthProvider.pumpDays.indexWhere((el1) => dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
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
    monthData.alternateEquipmentType = monthData.equipmentType;
    monthData.weekDataModel = monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1];
    monthData.updateIsPastWeek(monthData.weekStatuses[(monthData.week ?? 1) - 1] == WeekType.pastWeek);
    Navigator.pushNamed(context, '/dayOverview');
  }
}

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({super.key, required this.monthProvider});
  final MonthProvider monthProvider;
  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
      child: Card(
        color: Colors.grey.shade50,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: TableCalendar(
                availableGestures: AvailableGestures.horizontalSwipe,
                rowHeight: 40.0,
                daysOfWeekHeight: 20.0,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                headerStyle: HeaderStyle(
                  headerPadding: const EdgeInsets.only(bottom: 10),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.primaryColor),
                  rightChevronIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppColors.primaryColor),
                  titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
                  titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(fontSize: 12.0),
                  weekendTextStyle: TextStyle(fontSize: 12.0),
                  outsideTextStyle: TextStyle(fontSize: 10.0),
                ),
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, day, focusedDay) => _buildDayState(day),
                  outsideBuilder: (context, date, _) {
                    return _buildDayState(date);
                  },
                  defaultBuilder: (context, date, _) {
                    return _buildDayState(date);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildDayState(DateTime date) {
    if (widget.monthProvider.monthLocalDataModel.isNotEmpty) {
      DateTime? oldestStartDate = widget.monthProvider.monthLocalDataModel
          .map((e) => Utils.formattedDate(e.monthStartDate!))
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final nowUtc = DateTime.now();

      List<DayHistoryModel> data = widget.monthProvider.decodedDataAll();

      bool isCurrentDay = date.year == nowUtc.year && date.month == nowUtc.month && date.day == nowUtc.day;

      if (data.isEmpty) {
        if (isCurrentDay) {
          return _buildCurrentWorkoutDay(date);
        } else if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
          return _buildCustomDayCircle(date, Colors.blue);
        }
      }

      DateTime futureDay = DateTime(nowUtc.year, nowUtc.month, nowUtc.day).add(Duration(days: 1));

      if (date.isBefore(futureDay)) {
        for (var day in data) {
          final workoutDate = day.endTime!;

          DateTime localTime = Utils.formattedDate("$workoutDate");

          if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
            if (day.status == Status.completed) {
              return _buildCustomDayCircle(date, AppColors.primaryColor);
            } else if (day.status == Status.skipped) {
              return _buildCustomDayCircle(date, Colors.blue);
            }
          }
        }
      }

      if (isCurrentDay) {
        for (var day in data) {
          final workoutDate = day.endTime!;
          DateTime localTime = Utils.formattedDate("$workoutDate");
          if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
            if (day.status == Status.completed) {
              return _buildCustomDayCircle(date, AppColors.primaryColor);
            } else if (day.status == Status.skipped) {
              return _buildCustomDayCircle(date, Colors.blue);
            }
          }
          return _buildCurrentWorkoutDay(date);
        }
      }
      if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
        if (DateTime(futureDay.year, futureDay.month, futureDay.day) != DateTime(date.year, date.month, date.day)) {
          return _buildCustomDayCircle(date, Colors.blue);
        }
      }
    }
    return null;
  }

  Widget _buildCustomDayCircle(DateTime date, Color circleColor) {
    return Container(
      alignment: Alignment.center,
      width: 28.0,
      height: 28.0,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: Text(
        '${date.day}',
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCurrentWorkoutDay(DateTime date) {
    return Container(
      alignment: Alignment.center,
      width: 28.0,
      height: 28.0,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Text(
        '${date.day}',
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
