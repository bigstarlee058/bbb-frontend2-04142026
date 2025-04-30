import 'dart:developer';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/athletes_list_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/collection_grid.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/join_challenge_widget.dart';
import 'package:bbb/components/program_phases_widget.dart';
import 'package:bbb/components/share_achievement_dialog.dart';
import 'package:bbb/components/staff_list_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/challenges.dart';
import 'package:bbb/pages/Charts/exercise_completed.dart';
import 'package:bbb/pages/Charts/weight_lifted.dart';
import 'package:bbb/pages/DashBoardScreen/step_progress_bar.dart';
import 'package:bbb/pages/DashBoardScreen/week_calender.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/date_notifier.dart';
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
import 'package:flutter_svg/svg.dart';
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
  Challenges featureChallengeData = Challenges(id: '', title: '', description: '', photo: '');
  final DateStreamNotifier _dateNotifier = DateStreamNotifier();
  DateTime _currentDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    onInit();
    _dateNotifier.stream.listen((newDate) {
      if (_currentDate.day != newDate.day) {
        setState(() {
          _currentDate = newDate;
          monthProvider.onInit(context, isEnabled: false);
        });
      }
    });
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

  Future<void> loadUserInfo() async {
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => monthProvider.getLiftedWeightGraphData(),
      // ),
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
                    height: media.height / 1,
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
                                return Consumer<UserDataProvider>(builder: (context, userData, child) {
                                  return AppBar(
                                    toolbarHeight: ScreenUtil.verticalScale(5.1),
                                    backgroundColor: Colors.transparent,
                                    centerTitle: false,
                                    leading: SizedBox(),
                                    titleSpacing: ScreenUtil.horizontalScale(6),
                                    leadingWidth: 0,
                                    title: Text(
                                      'Hi ${userData.userName}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.horizontalScale(5.5),
                                      ),
                                    ),
                                    actions: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
                                      )
                                    ],
                                  );
                                });
                                // Container(
                                //   margin: const EdgeInsets.only(right: 10, bottom: 0),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Padding(
                                //         padding: EdgeInsets.only(
                                //           left: ScreenUtil.horizontalScale(8),
                                //           top: ScreenUtil.verticalScale(0),
                                //         ),
                                //         child: Row(
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             Consumer<UserDataProvider>(
                                //               builder: (context, userData, child) => userData.userName != ""
                                //                   ? Text(
                                //                       // 'Hi Nick'
                                //                       'Hi ${userData.userName}',
                                //                       style: TextStyle(
                                //                         color: Colors.white,
                                //                         fontSize: ScreenUtil.verticalScale(2.9),
                                //                         height: 2,
                                //                       ),
                                //                     )
                                //                   : const SizedBox(),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       const CommonStreakWithNotification(routeString: "dashboard"),
                                //     ],
                                //   ),
                                // );
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
              onRefresh: () async => await _initializeFetchData().then((value) async {
                if (!context.mounted) return;
                await monthProvider.onInit(context, isEnabled: false);
              }),
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
                                        height: media.height / 1,
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
                                            return Column(
                                              children: [
                                                scrollProvider.scrollOffset >= 0.0
                                                    ? Consumer<UserDataProvider>(
                                                        builder: (context, userData, child) {
                                                          return AppBar(
                                                            toolbarHeight: ScreenUtil.verticalScale(5.1),
                                                            backgroundColor: Colors.transparent,
                                                            centerTitle: false,
                                                            leading: SizedBox(),
                                                            titleSpacing: ScreenUtil.horizontalScale(6),
                                                            leadingWidth: 0,
                                                            title: Text(
                                                              'Hi ${userData.userName}',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: ScreenUtil.horizontalScale(5.5),
                                                              ),
                                                            ),
                                                            actions: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 10),
                                                                child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                  height: scrollProvider.scrollOffset >= 0.0 ? 0 : ScreenUtil.verticalScale(5.1),
                                                )
                                              ],
                                            );
                                            // Container(
                                            //   margin: const EdgeInsets.only(right: 10, bottom: 0),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     children: [
                                            //       Padding(
                                            //         padding: EdgeInsets.only(
                                            //           left: ScreenUtil.horizontalScale(8),
                                            //           top: ScreenUtil.verticalScale(0),
                                            //         ),
                                            //         child: Row(
                                            //           mainAxisAlignment: MainAxisAlignment.center,
                                            //           children: [
                                            //             Consumer<UserDataProvider>(
                                            //                 builder: (context, userData, child) => userData.userName != ""
                                            //                     ? Text(
                                            //                         scrollProvider.scrollOffset >= 0.0 ? 'Hi ${userData.userName}' : "",
                                            //                         style: TextStyle(
                                            //                           color: Colors.white,
                                            //                           fontSize: ScreenUtil.verticalScale(2.9),
                                            //                           height: 2,
                                            //                         ),
                                            //                       )
                                            //                     : const SizedBox()),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       scrollProvider.scrollOffset >= 0.0
                                            //           ? const CommonStreakWithNotification(routeString: "dashboard")
                                            //           : Row(
                                            //               children: [
                                            //                 Row(
                                            //                   children: [
                                            //                     Container(
                                            //                       alignment: Alignment.center,
                                            //                       padding: EdgeInsets.all(ScreenUtil.verticalScale(0.65)),
                                            //                       decoration: BoxDecoration(
                                            //                         color: Colors.transparent,
                                            //                         shape: BoxShape.circle,
                                            //                         border: Border.all(color: Colors.transparent),
                                            //                       ),
                                            //                       child: Text(
                                            //                         '',
                                            //                         style: TextStyle(
                                            //                           color: Colors.transparent,
                                            //                           fontSize: ScreenUtil.verticalScale(0.8),
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                     Icon(
                                            //                       Icons.local_fire_department_outlined,
                                            //                       color: Colors.transparent,
                                            //                       size: ScreenUtil.verticalScale(3),
                                            //                     )
                                            //                   ],
                                            //                 ),
                                            //                 IconButton(
                                            //                   /// COMMENT THIS SIZE-BOX AND UNCOMMENT ICON BUTTON IF PUT NOTIFICATION ICON BACK
                                            //                   onPressed: null, icon: SizedBox(),
                                            //                   // icon: Icon(
                                            //                   //   Icons.notifications_none,
                                            //                   //   color: Colors.transparent,
                                            //                   //   size: ScreenUtil.verticalScale(3),
                                            //                   // ),
                                            //                 )
                                            //               ],
                                            //             ),
                                            //     ],
                                            //   ),
                                            // );
                                          },
                                        ),
                                        Consumer<MonthProvider>(
                                          builder: (context, monthData, child) {
                                            if ((monthData.monthDataModel?.weeks == null || monthData.loader)) {
                                              return const SizedBox();
                                            }

                                            if ((monthData.week ?? 0) > 4) {
                                              return const SizedBox();
                                            }
                                            if (monthData.todayTitleId.isNotEmpty) {
                                              int? index = monthData.monthDataModel?.weeks?[(monthData.week ?? 1) - 1].idList
                                                  ?.indexWhere((element) => element == monthData.todayTitleId);

                                              if ((index ?? 0) < 0) {
                                                return SizedBox();
                                              }

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

                                              String todayTitleName = "Pump Day";

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
                                                    todayTitleName = monthProvider.pumpDays[index1].title ?? "Pump Day";
                                                  } else {
                                                    if (monthProvider.pumpDays.length == 1) {
                                                      todayTitleName = monthProvider.pumpDays[0].title ?? "Pump Day";
                                                    } else {
                                                      int index1 = monthProvider.pumpDays.indexWhere((el1) =>
                                                          dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
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
                                                  todayTitleName = monthProvider.pumpDays[0].title ?? "Pump Day";
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
                                                            DayHistoryModel? matchingElement = monthData.allDayHistoryModel.firstWhere(
                                                              (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                              orElse: () => DayHistoryModel(),
                                                            );
                                                            return Text(
                                                              matchingElement.id != null
                                                                  ? matchingElement.title ?? "Pump Day"
                                                                  : !monthData.isPumpDayAvailable
                                                                      ? monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1]
                                                                              .dayList![index ?? 0] ??
                                                                          ""
                                                                      : !isRestDay
                                                                          ? monthData.monthDataModel!.weeks![monthData.week! - 1]
                                                                                  .days![nextWorkOutIndex].title ??
                                                                              ""
                                                                          : monthData.pumpDays.isEmpty
                                                                              ? "Pump Day"
                                                                              : todayTitleName,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: ScreenUtil.horizontalScale(6.5),
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
                                                              text:
                                                                  status == Status.started ? 'Continue Your Workout' : 'Start Your Workout',
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
                                topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
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
                                  horizontal: ScreenUtil.horizontalScale(7),
                                  vertical: ScreenUtil.verticalScale(1.5),
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
                                    int count = week > 4 ? val1 : val1 + val2.length;

                                    if (count > 28) {
                                      count = 28;
                                    }
                                    return Column(
                                      children: [
                                        const SizedBox(height: 15),
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
                                        // const SizedBox(height: 10),
                                        // Stack(
                                        //   children: [
                                        //     Row(
                                        //       children: List.generate(
                                        //         4,
                                        //         (index) => Expanded(
                                        //           child: Container(
                                        //             margin: EdgeInsets.symmetric(horizontal: 3),
                                        //             color: Colors.grey[300],
                                        //             height: ScreenUtil.verticalScale(0.6),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     Container(
                                        //       width: (ScreenUtil.horizontalScale(80)) / (28 / count),
                                        //       height: ScreenUtil.verticalScale(0.6),
                                        //       decoration: BoxDecoration(
                                        //         gradient: LinearGradient(
                                        //           colors: [AppColors.backOffSetColor, AppColors.primaryColor],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 13),
                              Container(
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
                                          'Edit Schedule',
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
                              ),
                              Consumer<MonthProvider>(
                                builder: (context, monthProvider, child) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: ScreenUtil.verticalScale(1.4), top: ScreenUtil.verticalScale(2.3)),
                                              child: Text(
                                                "Streak Calendar",
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
                              ),
                              Consumer<MonthProvider>(
                                builder: (context, value, child) {
                                  final listA = monthProvider.graphHistory.map((e) => e["totalCompletedExercise"].value > 0).toList();
                                  final listB = monthProvider.graphHistory.map((e) => e["totalWeight"].value > 0).toList();
                                  final isAvailable = listA.any((element) => element == true) || listB.any((element) => element == true);
                                  if (isAvailable) {
                                    return Column(
                                      children: [
                                        SizedBox(height: ScreenUtil.verticalScale(1.9)),
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                          child: Text(
                                            // "Recent Activity",
                                            "Current Week Activity",
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: ScreenUtil.horizontalScale(5),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: ScreenUtil.verticalScale(1),
                                                top: ScreenUtil.verticalScale(1.5),
                                              ),
                                              child: PopupMenuButton<String>(
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
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: ScreenUtil.horizontalScale(8.5),
                                          ),
                                          child: selectedChart == "Exercises Completed"
                                              ? const ExerciseCompletedGraph()
                                              : selectedChart == "Weight Lifted"
                                                  ? const WeightLiftedGraph()
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
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(7), vertical: ScreenUtil.verticalScale(2.3)),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(3.5), vertical: ScreenUtil.horizontalScale(5)),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
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
                                      Consumer<MonthProvider>(builder: (context, value, child) {
                                        final data = value.items.where((element) => element["isArchived"] == true).toList();
                                        return !value.items.any((element) => element["isArchived"] == true)
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 2, bottom: 5),
                                                  child: Text(
                                                    "No achievements available!",
                                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                                  ),
                                                ),
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  data.sort((a, b) =>
                                                      DateTime.parse(a["time"].toString()).compareTo(DateTime.parse(b["time"].toString())));
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: List.generate(
                                                      3,
                                                      (index) => (data.length - 1) < index
                                                          ? Expanded(child: SizedBox())
                                                          : Expanded(
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  AnimatedDialog.showAnimatedDialog(
                                                                    context: context,
                                                                    pageBuilder: (context, anim1, anim2) => ShareAchievementDialog(
                                                                      title: data[index]["title"],
                                                                      imagePath: data[index]["image"],
                                                                      subtitle: data[index]["subtitle"],
                                                                      time: data[index]["time"],
                                                                    ),
                                                                  );
                                                                },
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    SvgPicture.asset(
                                                                      height: ScreenUtil.verticalScale(7),
                                                                      data[index]["image"],
                                                                      colorFilter:
                                                                          ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                                                                      fit: BoxFit.contain,
                                                                    ),
                                                                    const SizedBox(height: 10),
                                                                    Text(
                                                                      data[index]["title"],
                                                                      maxLines: 1,
                                                                      textAlign: TextAlign.center,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                        fontSize: ScreenUtil.verticalScale(1.45),
                                                                        color: AppColors.primaryColor,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                  );
                                                },
                                              );
                                      }),
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
                              featureChallengeData.id != ""

                                  ///Please recheck this multiple
                                  ? JoinChallengeWidget(featureChallenge: featureChallengeData)
                                  : SizedBox(height: ScreenUtil.verticalScale(5)),

                              ProgramPhasesWidget(),

                              /// New Method

                              SizedBox(
                                width: media.width,
                                child: Column(
                                  children: [
                                    // Container(
                                    //   width: media.width,
                                    //   margin: EdgeInsets.only(
                                    //       left: ScreenUtil.horizontalScale(7), right: ScreenUtil.horizontalScale(7), bottom: 20),
                                    //   child: Text(
                                    //     "Member Spotlight",
                                    //     style: TextStyle(
                                    //       color: AppColors.primaryColor,
                                    //       fontSize: ScreenUtil.verticalScale(2.3),
                                    //       fontWeight: FontWeight.w800,
                                    //     ),
                                    //     textAlign: TextAlign.start,
                                    //   ),
                                    // ),
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
                              ),

                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return (dataProvider.collectionsData.isNotEmpty)
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
                                                  return CollectionGrid(collection: dataProvider.collectionsData[index]);
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(height: ScreenUtil.verticalScale(5));
                                },
                              ),

                              SizedBox(
                                width: media.width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: media.width,
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(7),
                                          right: ScreenUtil.horizontalScale(7),
                                          bottom: ScreenUtil.verticalScale(2.4)),
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

  Future<void> continueWorkoutOnTap(
      bool isRestDay, MonthProvider monthData, String dataId, int? index, DayDataModel dayData, BuildContext context) async {
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
    // monthData.alternateEquipmentType = monthData.equipmentType;
    monthData.weekDataModel = monthData.monthDataModel!.weeks![(monthData.week ?? 1) - 1];
    monthData.updateIsPastWeek(monthData.weekStatuses[(monthData.week ?? 1) - 1] == WeekType.pastWeek);

    final dayIndex = monthProvider.overviewCurrentDay;
    int nextWorkOutIndex = monthProvider.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? int.parse(monthProvider.weekDataModel!.dayList![dayIndex - 1].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
        : 0;
    String currentDayTitle = monthProvider.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? monthProvider.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider.weekDataModel!.dayList![dayIndex - 1];
    // if (currentDayTitle.contains("Rest Day") && (!monthProvider.isPumpDay)) {
    //   Navigator.pushNamed(context, '/dayOverview');
    // }

    final isCompletedOrSkipped = (monthProvider.allSplitDayHistoryModel
        .any((element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId));

    if (currentDayTitle.contains("Rest Day") && (!monthProvider.isPumpDay) && isCompletedOrSkipped) {
      return;
    } else if (currentDayTitle.contains("Rest Day") && (!monthProvider.isPumpDay) && !isCompletedOrSkipped) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      context.read<MainPageProvider>().changeTab(1);
      monthProvider.updateIsOnMonthPage(false);

      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (c1) {
      //     return skipWorkoutDialog(context, c1);
      //   },
      // );
    } else {
      if (monthProvider.isPumpDay) {
        if ((monthProvider.allSplitDayHistoryModel
                .any((element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId)) ==
            false) {
          _saveDayData(
              type: "Pump Day - ${monthProvider.pumpDayModel?.id}", status: Status.started, title: monthProvider.pumpDayModel?.title);
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today').then(
            (value) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await monthProvider.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider.dayHistoryModel.any((element) => element.dataId == dataId)) == false) {
          _saveDayData(status: Status.started, type: 'Workout Day');
        }
        if (!context.mounted) return;
        await Navigator.pushNamed(context, '/today');
      }
    }
    // Navigator.pushNamed(context, '/dayOverview');
  }

  Future<void> _saveDayData({required String status, required String type, String? title}) async {
    String split = monthProvider.monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}";

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider.monthDataModel?.id,
      "weekId": monthProvider.weekDataModel?.id,
      "dayId": monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1],
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
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
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
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
      "dataId": dataId
    };

    if (matchingElement.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);
      await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider.fetchAllDayStatusLocalData();
    monthProvider.findWeekStatuses();
    monthProvider.fetchToday();
    monthProvider.manageStreak();
    monthProvider.getLiftedWeightGraphData();
  }
}
