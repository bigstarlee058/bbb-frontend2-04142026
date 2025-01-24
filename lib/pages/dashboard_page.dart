import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/athletes_list_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/collection_grid.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/join_challenge_widget.dart';
import 'package:bbb/components/staff_list_widget.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/models/day.dart';
import 'package:bbb/pages/Charts/time_spent.dart';
import 'package:bbb/pages/new/Month/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/new/Providers/month_provider.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/exercise_history_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/storage/userdata_manager.dart';
import 'package:bbb/utils/convert_util.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/pump_day_provider.dart';
import '../providers/weekly_graph_provider.dart';
import 'Charts/exercise_completed.dart';
import 'Charts/weight_lifted.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final today = DateTime.now();

  // final PageController _pageController = PageController();

  UserDataManager userManager = UserDataManager();

  late WeeklyGraphProvider weeklyGraphProvider;
  late ExerciseHistoryProvider exerciseHistoryProvider;

  List<String> title = [];

  int focusedIndexStuff = 0;
  UserDataProvider? userData;
  DataProvider? dataProvider;
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  late MainPageProvider mainPageProvider;

  String selectedChart = "Exercises Completed";

  // PageController _controller = PageController();
  // int _activeIndex = 0;

  // List<Widget> athletes = [];

  // List<Widget> staffs = [];

  Challenges featureChallengeData = Challenges(id: '', title: '', description: '', photo: '');

  final List<Collections> collections = [];

  late PumpDayProvider pumpDayProvider;
  late final String restDayId;
  bool isPumpDay = false;
  var isPumpDayData;

  @override
  void initState() {
    super.initState();
    // _controller = PageController(viewportFraction: 0.7, initialPage: 0);
    weeklyGraphProvider = Provider.of<WeeklyGraphProvider>(context, listen: false);
    exerciseHistoryProvider = Provider.of<ExerciseHistoryProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    pumpDayProvider = Provider.of<PumpDayProvider>(context, listen: false);
    weeklyGraphProvider.getWeeklyProgress();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    exerciseHistoryProvider.getExercise();

    loadUserInfo();
    loadStaffsData();
    loadFeaturedChallengeData();
    loadFeaturedCollectionData();
    requestNotificationPermission();
    super.initState();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void loadUserInfo() async {
    await userData?.loadUserInfo();
    await userData!.getStreaksData(dataProvider!.workout.startDate);
    if (dataProvider?.workout.startDate != null) {
      if (mounted) {
        setDateTime();
      }
    } else {
      debugPrint("Start date is null after fetching workouts.");
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

  void loadFeaturedCollectionData() async {
    await dataProvider?.fetchFeaturedColllections();
  }

  void setDateTime() {
    try {
      if (dataProvider?.workout.startDate is! String) {
        log("CALLED====> ");
        return;
      }
      debugPrint("this is setDataTime");
      DateTime startTime = DateTime.parse(dataProvider!.workout.startDate);
      int dayDelta = today.difference(startTime).inDays;
      userData?.currentWeek = (dayDelta ~/ 7) + 1;
      userData?.currentDay = dayDelta % 7 + 1;
      userData?.currentMonth = dataProvider!.workout.index;

      if (dataProvider?.workout.weeks == null || dataProvider!.workout.weeks.isEmpty) {
        debugPrint("Workout weeks data is empty.");
        return;
      }

      List<Day> cardDataArr = List<Day>.from(dataProvider!.workout.weeks[(dayDelta ~/ 7)].days);
      if (userData?.selectedDaySplit == null) {
        debugPrint("No selectedDaySplit specified.");
        return;
      }

      List<Day> tempCardDataArr = [];
      List<Day> restDataArr = [];
      List<int> workoutIndices = userData!.selectedDaySplit == "3"
          ? [0, 2, 4]
          : userData!.selectedDaySplit == "4"
              ? [0, 1, 3, 4]
              : [0, 1, 2, 3, 4];

      for (var day in cardDataArr) {
        if (day.formats.contains(userData!.selectedDaySplit)) {
          tempCardDataArr.add(day);
        } else if (restDataArr.isEmpty) {
          restDataArr.add(day);
        }
      }

      if (tempCardDataArr.isEmpty && restDataArr.isNotEmpty) {
        tempCardDataArr.addAll(restDataArr);
      }

      cardDataArr = updateTempCardDataArrFor(
          userData!.selectedDaySplit == "3"
              ? "5"
              : userData!.selectedDaySplit == "4"
                  ? "5"
                  : userData!.selectedDaySplit == "5"
                      ? "3"
                      : "0",
          tempCardDataArr,
          workoutIndices,
          restDataArr,
          context);

      if (userData!.currentWeekDayTitle.isNotEmpty == false) {
        debugPrint("current week title is mepty ${userData?.currentWeekDayTitle}");
        for (var element in cardDataArr) {
          if (userData!.selectedDaySplit == "3") {
            if (element.formats.contains("3")) {
              title.add("Day ${element.typeId} ${element.title}");
            }
          } else if (userData!.selectedDaySplit == "4") {
            if (element.formats.contains("4")) {
              title.add("Day ${element.typeId} ${element.title}");
            }
          } else {
            if (userData!.selectedDaySplit == "5") {
              title.add("Day ${element.typeId} ${element.title}");
            }
          }
        }

        if (userData!.selectedDaySplit == "3") {
          title.insert(1, "Rest Day 1");
          title.insert(3, "Rest Day 2");
          title.insert(5, "Rest Day 3");
          title.insert(6, "Rest Day 4");
        } else if (userData!.selectedDaySplit == "4") {
          title.insert(2, "Rest Day 1");
          title.insert(5, "Rest Day 2");
          title.insert(6, "Rest Day 3");
        } else {
          title.insert(5, "Rest Day 1");
          title.insert(6, "Rest Day 2");
        }

        userData!.setCurrentDayTitle(title[userData!.nextDayIndex - 1]);
        userData!.saveDayTitles(title);
        userData?.notifyListeners();
        setState(() {});
      } else if (userData?.compareDaySplit != userData?.selectedDaySplit) {
        debugPrint("selectedday split is not same ${userData?.currentWeekDayTitle}");
        for (var element in cardDataArr) {
          if (userData!.selectedDaySplit == "3") {
            if (element.formats.contains("3")) {
              title.add("Day ${element.typeId} ${element.title}");
            }
          } else if (userData!.selectedDaySplit == "4") {
            if (element.formats.contains("4")) {
              title.add("Day ${element.typeId} ${element.title}");
            }
          } else {
            if (userData!.selectedDaySplit == "5") {
              title.add("Day ${element.typeId} ${element.title}");
            }
          }
        }

        if (userData!.selectedDaySplit == "3") {
          title.insert(1, "Rest Day 1");
          title.insert(3, "Rest Day 2");
          title.insert(5, "Rest Day 3");
          title.insert(6, "Rest Day 4");
        } else if (userData!.selectedDaySplit == "4") {
          title.insert(2, "Rest Day 1");
          title.insert(5, "Rest Day 2");
          title.insert(6, "Rest Day 3");
        } else {
          title.insert(5, "Rest Day 1");
          title.insert(6, "Rest Day 2");
        }

        userData!.setCurrentDayTitle(title[userData!.nextDayIndex - 1]);
        userData!.saveDayTitles(title);
        userData?.notifyListeners();
        setState(() {});
      }

      dataProvider!.selectWeekBasedOnSplit = cardDataArr;
      isPumpDayData = pumpDayProvider.checkForPumpDay(
          userData!.currentMonth, userData!.currentWeek, userData!.nextDayIndex, userData!.selectedDaySplit);
      isPumpDay = isPumpDayData != null;
      for (int j = 0; j < 7; j++) {
        bool isDayFinished = false;

        for (var day in userData!.dayHistory) {
          if ('${day['monthIndex']} ${day['weekIndex']} ${day['daySplit']} ${day['dayIndex']} ${day['state']}' ==
                  '${userData?.currentMonth} ${userData!.currentWeek} ${userData?.selectedDaySplit} ${j + 1} ${AppConstants.STATE_FINISHED}' ||
              '${day['monthIndex']} ${day['weekIndex']} ${day['daySplit']} ${day['dayIndex']} ${day['state']}' ==
                  '${userData?.currentMonth} ${userData!.currentWeek} ${userData?.selectedDaySplit} ${j + 1} ${AppConstants.STATE_SKIPPED}') {
            isDayFinished = true;
            break;
          }
        }
        if (!isDayFinished) {
          userData?.nextDayIndex = j + 1;
          userData?.currentDayObj = cardDataArr[j + 1];
          debugPrint("this is setDataTime1 ${j + 1}");
          debugPrint("this is setDataTime2 ${userData?.currentDay}");
          // userData?.currentWeek = widget.weekIndex + 1;
          // userData?.currentDay = index + 1;
          // userData?.currentDayObj = wObj;
          userData?.isRestDay = !(cardDataArr[j + 1].formats.contains(userData!.selectedDaySplit));
          restDayId = dataProvider!.workout.weeks[userData!.currentWeek - 1].restdayId;
          userData?.fetchRestDay(restDayId);
          userData?.notifyListeners();
          break;
        }
      }

      dataProvider?.dataLoaded = true;
    } catch (e) {
      dataProvider?.dataLoaded = false;
    }

    pumpDayProvider.getPumpDayHistory(context);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (mounted) {
          setDateTime();
        }
      },
    );

    debugPrint("this is widget build context");
    debugPrint("this is widget build context ${userData?.currentWeekDayTitle}");
    if (dataProvider == null || userData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                                                      : const SizedBox()),
                                            ],
                                          ),
                                        ),

                                        ///
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Padding(
                                                //   padding: EdgeInsets.only(
                                                //     left: ScreenUtil.horizontalScale(0),
                                                //     right: ScreenUtil.horizontalScale(2),
                                                //     top: ScreenUtil.verticalScale(1.5),
                                                //   ),  // No padding on the left, moves the icon to the far left
                                                //   child: GestureDetector(
                                                //     onTap: () {
                                                //       Navigator.pushNamed(context, '/calendar');
                                                //     },
                                                //     child: Icon(
                                                //       Icons.calendar_month,
                                                //       color: Colors.white,
                                                //       size: ScreenUtil.verticalScale(3),
                                                //     ),
                                                //   ),
                                                // ),

                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil.horizontalScale(0),
                                                    right: ScreenUtil.horizontalScale(0),
                                                    top: ScreenUtil.verticalScale(0),
                                                  ),
                                                  child: const CommonStreakWithNotification(),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Consumer<MonthProvider>(
                                    builder: (context, monthData, child) {
                                      if (monthData.monthDataModel?.weeks == null) {
                                        return const SizedBox();
                                      }
                                      if (monthData.todayTitleId.isNotEmpty) {
                                        int? index = monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].idList?.indexWhere(
                                          (element) => element == monthData.todayTitleId,
                                        );
                                        String dataId =
                                            "${monthData.splitType}-${monthData.monthDataModel?.id}-${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].id}-${monthData.todayTitleId}";

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
                                                      monthData.allDayHistoryModel.any(
                                                        (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                      )
                                                          ? "Pump Day"
                                                          : (monthData.monthDataModel?.weeks?[monthData.week! - 1].dayList?[index ?? 0]) ??
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
                                                decoration: status == "Completed"
                                                    ? BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3.2)))
                                                    : const BoxDecoration(),
                                                child: status == "Completed"
                                                    ? const ButtonWidget(
                                                        text: "Completed",
                                                        textColor: Colors.white,
                                                        onPress: null,
                                                        color: Colors.white,
                                                        isLoading: false,
                                                      )
                                                    : ButtonWidget(
                                                        text: status == "Started" ? 'Continue Workout' : 'Start Workout',
                                                        textColor: AppColors.primaryColor,
                                                        color: status == "Completed" || status == "Skipped" ? Colors.white70 : Colors.white,
                                                        onPress: status == "Completed" || status == "Skipped"
                                                            ? null
                                                            : () async {
                                                                monthData.overviewCurrentWeek = monthData.week ?? 1;
                                                                monthData.overviewCurrentDay = ((index ?? 1) + 1);
                                                                monthData.dayDataModel = dayData;
                                                                monthData.alternateEquipmentType = monthData.equipmentType;
                                                                monthData.weekDataModel =
                                                                    monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1];
                                                                monthData.updateIsPastWeek(
                                                                    monthData.weekStatuses[(monthData.week ?? 1) - 1] == WeekType.pastWeek);
                                                                Navigator.pushNamed(context, '/dayOverview');
                                                              },
                                                        isLoading: false,
                                                      ),
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        String dataId =
                                            "${monthData.splitType}-${monthData.monthDataModel?.id}-${monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].id}-${monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1].idList?.last}";
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
                                                      monthData.allDayHistoryModel.any(
                                                        (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                      )
                                                          ? "Pump Day"
                                                          : (monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1].dayList?.last) ??
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
                                                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3.2))),
                                                child: const ButtonWidget(
                                                  text: "Completed",
                                                  textColor: Colors.white,
                                                  onPress: null,
                                                  color: Colors.white,
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
                              if (value.currentWeek == 0 || value.monthDataModel!.weeks!.isEmpty) return const SizedBox();
                              final val1 = (value.currentWeek - 1) * 7;
                              final val2 = value.allDayHistoryModel.where((element) =>
                                  element.weekId == value.monthDataModel!.weeks![value.currentWeek - 1].id &&
                                  element.split == value.splitType &&
                                  element.monthId == value.monthDataModel?.id &&
                                  (element.status == "Completed" || element.status == "Skipped"));

                              final count = val2.length + val1;

                              return Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$count/28 days tracked',
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
                              // const SizedBox(width: 15),
                              // Expanded(
                              //   child: ElevatedButton(
                              //     onPressed: () {},
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.white,
                              //       padding: const EdgeInsets.symmetric(
                              //         vertical: 20,
                              //       ),
                              //       side: const BorderSide(
                              //         color:
                              //             AppColors.primaryColor, // Border color
                              //         width: 2, // Border width
                              //       ),
                              //     ),
                              //     child: Text(
                              //       'Edit Schedule',
                              //       style: TextStyle(
                              //         color: AppColors.primaryColor,
                              //         fontSize: ScreenUtil.verticalScale(2),
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(8),
                          ),
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
                                shadowColor: Colors.black.withOpacity(0.2),
                                itemBuilder: (context) {
                                  return [
                                    "Exercises Completed",
                                    "Time Spent",
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
                                    print('!!!===== $v');
                                    selectedChart = v;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(10),
                          ),
                          child: selectedChart == "Exercises Completed"
                              ? const ExerciseCompletedGraph()
                              : selectedChart == "Weight Lifted"
                                  ? const WeightLiftedGraph()
                                  : const TimeSpentGraph(),
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
                            ? Container(
                                child: JoinChallengeWidget(featureChallenge: featureChallengeData),
                              )
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
                                  "Athlete Spotlight",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: ScreenUtil.verticalScale(2.3),
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Consumer<DataProvider>(builder: (context, dataProvider, child) {
                                return (dataProvider.athletesData.length ?? 0) > 0
                                    ? CarouselSlider.builder(
                                        itemCount: dataProvider.athletesData.length ?? 0,
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

                        Consumer<DataProvider>(builder: (context, dataProvider, child) {
                          return (dataProvider.collectionsData.length ?? 0) > 0
                              ? Container(
                                  width: media.width,
                                  margin: EdgeInsets.only(
                                    left: ScreenUtil.horizontalScale(5),
                                    right: ScreenUtil.horizontalScale(5),
                                    top: ScreenUtil.verticalScale(8),
                                    bottom: ScreenUtil.verticalScale(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: media.width,
                                        margin: EdgeInsets.only(bottom: 20, left: ScreenUtil.horizontalScale(1)),
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
                                      for (int index = 0; index < (dataProvider.collectionsData.length / 2).ceil(); index++)
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(child: CollectionGrid(collection: dataProvider.collectionsData[index * 2])),
                                                Expanded(
                                                  child: (index * 2 + 1 < dataProvider.collectionsData.length)
                                                      ? CollectionGrid(
                                                          collection: dataProvider.collectionsData[index * 2 + 1],
                                                        )
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 14, // Adds spacing after each row
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                )
                              : const SizedBox();
                        }),

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
                                  "Meet our Staff",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: ScreenUtil.verticalScale(2.3),
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Consumer<DataProvider>(builder: (context, dataProvider, child) {
                                return (dataProvider.staffsData.length ?? 0) > 0
                                    ? CarouselSlider.builder(
                                        itemCount: dataProvider.staffsData.length ?? 0,
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
                              }),

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
        ));
  }
}
