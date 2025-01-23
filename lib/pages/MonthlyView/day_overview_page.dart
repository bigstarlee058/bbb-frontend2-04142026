import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/select_dropdown.dart';
import 'package:bbb/models/day.dart';
import 'package:bbb/models/week.dart';
import 'package:bbb/pages/video_intro_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/pump_day_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/providers/weekly_graph_provider.dart';
import 'package:bbb/routes/fade_page_route.dart';
import 'package:bbb/utils/custom_prints.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/pump_day_model.dart';
import '../../values/app_constants.dart';

class DayOverviewPage extends StatefulWidget {
  const DayOverviewPage({super.key});

  @override
  State<DayOverviewPage> createState() => _DayOverviewPageState();
}

class _DayOverviewPageState extends State<DayOverviewPage> {
  final today = DateTime.now();
  DataProvider? dataProvider;
  UserDataProvider? userData;
  int? week;
  int? day;
  late MainPageProvider mainPageProvider;
  bool isToday = true;
  bool isThisWeek = true;
  bool isSkipped = false;
  bool isCompleted = false;
  bool isNoDataHistory = false;

  bool isPumpDay = false;
  String pumpDayTitle = '';
  String pumpDayNote = '';

  late WeeklyGraphProvider weeklyGraphProvider;

  String selectedButtonTitle = "Mark Complete";
  List<String> buttonTitle = ["Mark Complete", "Swap To Pump Day"];
  String currentDayTitle = '';
  String pumpDayId = '';

  bool isPumpDayAvailable = false;

  late PumpDayProvider pumpDayProvider;
  late PumpDayModel pumpDayModel;
  
  @override
  void initState() {
    pumpDayProvider = Provider.of<PumpDayProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    ///if its pumpday then fetch its details

    weeklyGraphProvider = Provider.of<WeeklyGraphProvider>(context, listen: false);

    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );

    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );

    fetchDayTitle();

    isSkipped = (userData!.dayHistory).any((element) =>
        ('${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}') ==
        ('${userData!.currentMonth} ${userData!.currentWeek} ${userData!.selectedDaySplit} ${userData!.currentDay} ${AppConstants.STATE_SKIPPED}'));

    isCompleted = (userData!.dayHistory).any((element) =>
        ('${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}') ==
        ('${userData!.currentMonth} ${userData!.currentWeek} ${userData!.selectedDaySplit} ${userData!.currentDay} ${AppConstants.STATE_FINISHED}'));

    isNoDataHistory = userData!.dayHistory.isEmpty ? true : false;
    DateTime startTime = DateTime.parse(dataProvider?.workout.startDate as String);
    int dayDelta = today.difference(startTime).inDays;
    week = (dayDelta ~/ 7);
    day = dayDelta % 7;
    customPrintB("week -->     ${week}");
    customPrintB("day  -->    ${day}");
    customPrintB("isCompleted -->     ${isCompleted}");
    customPrintB("isSkipped  -->    ${isSkipped}");
    customPrintB("isRestDay  -->    ${userData?.isRestDay}");
    customPrintB("isNoDataHistory  -->    ${isNoDataHistory}");
    customPrintB("isRestDay  -->    ${userData?.isRestDay}");

    // print( dataProvider!.selectWeekBasedOnSplit);
    // if (dataProvider!.workout.weeks.length >= userData!.currentWeek) {
    //   Week firstWeek =
    //       dataProvider?.workout?.weeks[userData!.currentWeek - 1] as Week;
    //
    //   if (firstWeek.days.length > userData!.currentDay) {
    //     Day dayObj = firstWeek.days[userData!.currentDay - 1] as Day;
    //     userData?.currentDayObj = dayObj;
    //   }

    ///============================================================
    //if (dataProvider!.selectWeekBasedOnSplit.length >= userData!.currentWeek) {
    // Week firstWeek =
    // dataProvider!.selectWeekBasedOnSplit[userData!.currentWeek - 1];

    // if (dataProvider!.selectWeekBasedOnSplit[userData!.currentWeek - 1].length > userData!.currentDay) {
    Day dayObj = dataProvider!.selectWeekBasedOnSplit[userData!.currentDay - 1];
    userData?.currentDayObj = dayObj;
    //  }
    /// =======================================================
    // if (firstWeek.days.length > userData!.currentDay) {
    //   Day dayObj = firstWeek.days[userData!.currentDay - 1] as Day;
    //   userData?.currentDayObj = dayObj;
    // }

    //   if (firstWeek.restdayId.isNotEmpty) {
    //     userData?.fetchRestDay(firstWeek.restdayId);
    //   }
    // }

    isToday = ((week! + 1 == userData!.currentWeek) && (day! + 1 == userData!.currentDay));
    isThisWeek = (week! + 1 == userData!.currentWeek);
    var anyData = userData!.currentRestDay.description;
    customPrintB("isToday      $isToday");
    customPrintB("isThisWeek      $isThisWeek");
    customPrintB("isCompleted      $isCompleted");
    customPrintB("isSkipped      $isSkipped");
    fetchPumpDayBalance();
    checkForPumpDay();

    super.initState();
  }

  ///check if user has used all available pump days for this week
  fetchPumpDayBalance() async {
    int length = await pumpDayProvider.checkForPumpDayBalance(userData!.currentMonth, userData!.currentWeek, userData!.selectedDaySplit);

    if (dataProvider!.workout.weeks[userData!.currentWeek - 1].pumpDayIds.isNotEmpty &&
        length < dataProvider!.workout.weeks[userData!.currentWeek - 1].pumpDayIds.length) {
      isPumpDayAvailable = true;

      log('isPumpDayAvailable :::::::::::::::::: ${isPumpDayAvailable}');
      setState(() {});
    }
  }

  checkForPumpDay() {
    if (currentDayTitle.contains("Rest Day")) {
      var isPumpDayData =
          pumpDayProvider.checkForPumpDay(userData!.currentMonth, userData!.currentWeek, userData!.currentDay, userData!.selectedDaySplit);

      isPumpDay = isPumpDayData != null;

      if (isPumpDay) {
        buttonTitle = ['Start Workout', 'Swap To Rest Day'];
        selectedButtonTitle = "Start Workout";
        pumpDayTitle = isPumpDayData['current_title'];
        pumpDayId = isPumpDayData['pumpDayId'];
        fetchPumpDayData(pumpDayId);
      }
      fetchPumpDayData('');
      setState(() {});
    }
  }

  fetchPumpDayData(String id) async {
    if (currentDayTitle.contains("Rest Day")) {
      if (id == "") {
        int restDayIndex = int.parse(currentDayTitle.split(" ").last);
        int index = (restDayIndex - 1) % 2;

        if (dataProvider!.workout.weeks[userData!.currentWeek - 1].pumpDayIds.length == 1) {
          id = dataProvider!.workout.weeks[userData!.currentWeek - 1].pumpDayIds[0];
        } else {
          id = dataProvider!.workout.weeks[userData!.currentWeek - 1].pumpDayIds[index];
        }
      }

      pumpDayId = id;
      log('pumpDayId :::::::::::::::::: ${pumpDayId}');
      pumpDayModel = await dataProvider!.fetchPumpDayData(id);
      setState(() {});
    }

    pumpDayNote = pumpDayModel.description ?? "Pump Day Note";
    pumpDayTitle = pumpDayModel.title ?? "Pump Day";
  }

  fetchDayTitle() {
    currentDayTitle = userData!.currentWeekDayTitle[userData!.currentDay - 1];
    // isPumpDay = currentDayTitle.contains("Pump Day") ? true: false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        isThisWeek && isCompleted
                            ? Container(
                                height: media.height / 2.35,
                                width: media.width,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/img/back.jpg'),
                                    fit: BoxFit.cover,
                                    opacity: 1,
                                  ),
                                ),
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.saturation,
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/img/back.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: media.height / 2.35,
                                width: media.width,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/img/back.jpg'),
                                    fit: BoxFit.cover,
                                    opacity: 1,
                                  ),
                                ),
                              ),
                        isThisWeek && isCompleted
                            ? Container(
                                height: media.height / 1.8,
                                width: media.width,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(.5),
                                      Colors.black.withOpacity(1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
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
                                                  margin: EdgeInsets.only(
                                                    left: ScreenUtil.horizontalScale(4),
                                                  ),
                                                  decoration: const BoxDecoration(
                                                    color:  Color(0XFFd18a9b),
                                                    // color: (isThisWeek && isCompleted)
                                                    //     ? Colors.grey.withOpacity(.99)
                                                    //     : const Color(0XFFd18a9b),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SizedBox(
                                                    width: ScreenUtil.horizontalScale(10), // Size of the circle
                                                    height: ScreenUtil.horizontalScale(10),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero, // Removes the default padding
                                                      icon: const Icon(
                                                        Icons.keyboard_arrow_left,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        debugPrint("this is previous page ${userData?.previousPage}");
                                                        userData?.previousPage == 1
                                                            ? mainPageProvider.changeTab(0)
                                                            : mainPageProvider.changeTab(1);
                                                        Navigator.pop(context);
                                                      },
                                                      iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const CommonStreakWithNotification()
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Aug, 2024',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2),
                                              ),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil.verticalScale(1.5),
                                            ),
                                            Consumer<UserDataProvider>(
                                              builder: (context, userData, child) => userData?.currentWeek != null
                                                  ? Text(
                                                      "WEEK ${userData?.currentWeek}, DAY ${userData?.currentDay},",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil.verticalScale(2),
                                                        fontWeight: FontWeight.bold,
                                                        height: 1,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ),
                                            Consumer<UserDataProvider>(
                                              builder: (context, userData, child) => userData.currentRestDay.id != ''
                                                  ? Text(
                                                      isPumpDay ? pumpDayTitle : currentDayTitle,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil.verticalScale(3),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtil.verticalScale(2.5)),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(10),
                                        ),
                                        child: ButtonWidget(
                                          text: (userData != null &&
                                                  userData!.currentDayObj != null &&
                                                  !userData!.currentDayObj.formats.contains(userData!.selectedDaySplit))
                                              ? "Watch Video"
                                              : "Watch Video Intro",
                                          color: const Color(0xEEFFFFFF),
                                          onPress: () {
                                            Navigator.of(context).push(
                                              FadePageRoute(page: const VideoIntroWidget(vimeoId: '953289606')),
                                            );
                                          },
                                          textColor:
                                              // (isThisWeek && isCompleted)?
                                              // Color(0xFF8A2BE2):
                                              AppColors.primaryColor,
                                          isLoading: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: media.height / 1.8,
                                width: media.width,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        // isThisWeek && isCompleted?
                                        //
                                        // [
                                        //   const Color(0xFF8A2BE2).withOpacity(.0000),
                                        //   const Color(0xFF8A2BE2).withOpacity(.000),
                                        //
                                        // ]:
                                        [
                                      AppColors.primaryColor.withOpacity(0.7),
                                      AppColors.primaryColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
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
                                                  margin: EdgeInsets.only(
                                                    left: ScreenUtil.horizontalScale(4),
                                                  ),
                                                  decoration: const BoxDecoration(
                                                    color: //(isThisWeek && isCompleted)?
                                                        // Color(0xFF8A2BE2):
                                                        Color(0XFFd18a9b),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SizedBox(
                                                    width: ScreenUtil.horizontalScale(10), // Size of the circle
                                                    height: ScreenUtil.horizontalScale(10),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero, // Removes the default padding
                                                      icon: const Icon(
                                                        Icons.keyboard_arrow_left,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        debugPrint("this is previous page ${userData?.previousPage}");
                                                        userData?.previousPage == 1
                                                            ? mainPageProvider.changeTab(0)
                                                            : mainPageProvider.changeTab(1);
                                                        Navigator.pop(context);
                                                      },
                                                      iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const CommonStreakWithNotification()
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('MMM, yyyy').format(DateTime.now()),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(2),
                                              ),
                                            ),
                                            // Text(
                                            //   'Aug, 2024',
                                            //   style: TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: ScreenUtil.verticalScale(2.5),
                                            //   ),
                                            // ),

                                            Consumer<UserDataProvider>(
                                              builder: (context, userData, child) => userData?.currentWeek != null
                                                  ? Text(
                                                      "Week ${userData.currentWeek}, Day ${userData.currentDay}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ScreenUtil.verticalScale(2.3),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ),
                                            SizedBox(
                                              height: ScreenUtil.verticalScale(0.5),
                                            ),
                                            Text(
                                              isPumpDay ? pumpDayTitle : currentDayTitle,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                height: 1.1,
                                                fontSize: ScreenUtil.verticalScale(4),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtil.verticalScale(2.5)),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(10),
                                        ),
                                        child: ButtonWidget(
                                          text: (userData != null &&
                                                  userData!.currentDayObj != null &&
                                                  !userData!.currentDayObj.formats.contains(userData!.selectedDaySplit))
                                              ? "Watch Video"
                                              : "Watch Video Intro",
                                          color: const Color(0xEEFFFFFF),
                                          onPress: () {
                                            Navigator.of(context).push(
                                              FadePageRoute(page: const VideoIntroWidget(vimeoId: '953289606')),
                                            );
                                          },
                                          textColor:
                                              // (isThisWeek && isCompleted)?
                                              // Color(0xFF8A2BE2):
                                              AppColors.primaryColor,
                                          isLoading: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
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
                Positioned(
                  // bottom: -33,
                  child: Container(
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
                      margin: EdgeInsets.only(top: media.height / 19),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const IconRowWithDot(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: ScreenUtil.verticalScale(3.5),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                if (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit)) ...[
                                  Consumer<DataProvider>(builder: (context, dataProvider, child) {
                                    // var currentWeekIndex = userData!.currentWeek - 1;
                                    // var currentDayIndex = userData!.currentDay - 1;

                                    // Safely accessing workout data
                                    String description = "";
                                    // if (dataProvider.workout != null &&
                                    //     currentWeekIndex >= 0 &&
                                    //     currentWeekIndex < dataProvider.workout!.weeks.length) {
                                    //   Week currentWeek = dataProvider.workout!.weeks[currentWeekIndex];
                                    //   if (currentDayIndex >= 0 && currentDayIndex < currentWeek.days.length) {
                                    //     description = currentWeek.days[currentDayIndex].description ?? "";
                                    //   }
                                    // }
                                    description = userData!.currentDayObj.description;
                                    return BulletPoint(text: description);
                                  })
                                ] else ...[
                                  Consumer<UserDataProvider>(
                                    builder: (context, userData, child) => userData?.currentRestDay.id != ''
                                        ? BulletPoint(
                                            text: isPumpDay ? pumpDayNote : userData!.currentRestDay.description ?? "",
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.verticalScale(20),
                          ),
                          // Container(
                          //   margin: EdgeInsets.symmetric(
                          //     horizontal: ScreenUtil.horizontalScale(10),
                          //     vertical: ScreenUtil.verticalScale(2),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       if (userData!.currentDayObj.formats
                          //           .contains(userData?.selectedDaySplit)) ...[
                          //         Container(
                          //           margin: EdgeInsets.only(
                          //               left: ScreenUtil.verticalScale(2)),
                          //           child: Text(
                          //             'Choose equipent availiability',
                          //             textAlign: TextAlign.left,
                          //             style: TextStyle(
                          //                 color: Colors.black54,
                          //                 fontSize:
                          //                     ScreenUtil.verticalScale(1.5)),
                          //           ),
                          //         ),
                          //         const SizedBox(height: 10),
                          //         SelectDropdown(
                          //           onChange: (String newValue) {
                          //             userData?.selectedExerciseFormatAlternate =
                          //                 newValue;
                          //             userData?.notifyListeners();
                          //           },
                          //         ),
                          //       ]
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //     margin: EdgeInsets.symmetric(
                          //         horizontal: ScreenUtil.horizontalScale(10)),
                          //     child: ButtonWidget(
                          //       text: (userData!.currentDayObj.formats
                          //               .contains(userData?.selectedDaySplit))
                          //           ? (isThisWeek && !isCompleted && !isSkipped
                          //               ? "Start the workout"
                          //               : "View the workout")
                          //           : (isThisWeek && !isCompleted && !isSkipped
                          //               ? "Mark Rest Day Complete"
                          //               : isCompleted
                          //                   ? "Completed"
                          //                   : "Skipped"),
                          //       textColor: Colors.white,
                          //       onPress: (isThisWeek &&
                          //                   !isCompleted &&
                          //                   !isSkipped ||
                          //               userData!.currentDayObj.formats
                          //                   .contains(
                          //                       userData?.selectedDaySplit))
                          //           ? () async {
                          //               if ((userData!.currentDayObj.formats
                          //                   .contains(
                          //                       userData?.selectedDaySplit))) {
                          //                 // userData?.updateOrAddDayHistory(AppConstants.STATE_STARTED);
                          //                 Navigator.pushNamed(
                          //                     context, '/today');
                          //               } else {
                          //                 // await userData?.finishCurrentDay();
                          //                 userData?.updateOrAddDayHistory(
                          //                     AppConstants.STATE_FINISHED);
                          //                 // Navigator.pushNamed(context, '/home');
                          //                 Navigator.pushNamed(
                          //                   context,
                          //                   '/dayCompleted',
                          //                   arguments: userData?.currentDay,
                          //                 );
                          //               }
                          //             }
                          //           : null,
                          //       color: AppColors.primaryColor,
                          //       isLoading: false,
                          //     )
                          //     // ButtonWidget(
                          //     //   text: (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                          //     //       ? "Start the workout"
                          //     //       : "Mark Rest Day Complete",
                          //     //   textColor: Colors.grey,
                          //     //   onPress: () {
                          //     //   },
                          //     //   color: const Color.fromARGB(90, 214, 211, 211),
                          //     //   isLoading: false,
                          //     // ),
                          //     ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Wrap(
        children: [
          SizedBox(
            height: ScreenUtil.verticalScale(5),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(10),
              vertical: ScreenUtil.verticalScale(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit)) ...[
                  Container(
                    margin: EdgeInsets.only(left: ScreenUtil.verticalScale(2)),
                    child: Text(
                      'Choose equipent availiability',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black54, fontSize: ScreenUtil.verticalScale(1.5)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectDropdown(
                    onChange: (String newValue) {
                      userData?.selectedExerciseFormatAlternate = newValue;
                      userData?.notifyListeners();
                    },
                  ),
                ]
              ],
            ),
          ),

          (isPumpDay || currentDayTitle.contains("Rest Day") && isPumpDayAvailable)
              ? Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: media.height * 0.075,
                        margin: EdgeInsets.only(
                          bottom: ScreenUtil.verticalScale(2),
                          left: ScreenUtil.horizontalScale(10),
                          top: ScreenUtil.verticalScale(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD2CBCB)),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              ScreenUtil.verticalScale(4),
                            ),
                            bottomLeft: Radius.circular(
                              ScreenUtil.verticalScale(4),
                            ),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x20888888),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: DropdownButton<String>(
                            value: selectedButtonTitle,
                            icon: const Icon(Icons.keyboard_arrow_down_outlined),
                            iconSize: ScreenUtil.verticalScale(4),
                            iconEnabledColor: Colors.grey[400],
                            elevation: 16,
                            isExpanded: false,
                            style: TextStyle(
                              color: const Color(0xBB888888),
                              fontSize: ScreenUtil.verticalScale(1.8),
                              fontWeight: FontWeight.w600,
                            ),
                            underline: Container(),
                            onChanged: (String? newValue) {
                              selectedButtonTitle = newValue!;
                              setState(() {});
                            },
                            items: buttonTitle.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          // ["Mark Complete", "Swap To Pump Day"];
                          // ['Start Workout', 'Swap To Rest Day'];

                          if (selectedButtonTitle == "Mark Complete") {
                            userData?.updateOrAddDayHistory(AppConstants.STATE_FINISHED);
                            // Navigator.pushNamed(context, '/home');
                            Navigator.pushNamed(
                              context,
                              '/dayCompleted',
                              arguments: userData?.currentDay,
                            );
                          } else if (selectedButtonTitle == "Swap To Pump Day") {
                            isPumpDay = true;
                            // userData?.updateDayTitles(pumpDayTitle, userData!.currentDay - 1);
                            debugPrint("this is Pumpday1 ${userData?.currentDay}");
                            debugPrint("this is Pumpday2 ${userData?.nextDayIndex}");
                            buttonTitle = ['Start Workout', 'Swap To Rest Day'];
                            selectedButtonTitle = "Start Workout";
                            var data = {
                              "previous_title": currentDayTitle,
                              "month": userData!.currentMonth,
                              "week": userData!.currentWeek,
                              "day": userData!.currentDay,
                              "current_title": pumpDayTitle,
                              "day_split": userData!.selectedDaySplit,
                              "pumpDayId": pumpDayId,
                            };

                            pumpDayProvider.savePumpDays(data);

                            setState(() {});

                            log('data==========>>>>>${data}');
                          } else if (selectedButtonTitle == "Start Workout") {
                            weeklyGraphProvider.startTimer();
                            userData?.updateOrAddDayHistory(AppConstants.STATE_STARTED);
                            Navigator.pushNamed(context, '/today', arguments: {'isPumpDay': isPumpDay});

                            ///navigate to today page
                          } else if (selectedButtonTitle == "Swap To Rest Day") {
                            isPumpDay = false;
                            buttonTitle = ["Mark Complete", "Swap To Pump Day"];
                            // userData?.updateDayTitles(currentDayTitle, userData!.currentDay - 1);
                            selectedButtonTitle = "Mark Complete";
                            var data = {
                              "previous_title": currentDayTitle,
                              "month": userData!.currentMonth,
                              "week": userData!.currentWeek,
                              "day": userData!.currentDay,
                              "current_title": pumpDayTitle,
                              "day_split": userData!.selectedDaySplit,
                              "pumpDayId": pumpDayId,
                            };
                            pumpDayProvider.removePumpDay(data);
                            setState(() {});
                          }
                        },
                        child: Container(
                          height: media.height * 0.075,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 10),
                          margin: EdgeInsets.only(
                            bottom: ScreenUtil.verticalScale(2),
                            right: ScreenUtil.horizontalScale(10),
                            top: ScreenUtil.verticalScale(2),
                            left: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                ScreenUtil.verticalScale(4),
                              ),
                              bottomRight: Radius.circular(
                                ScreenUtil.verticalScale(4),
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20888888),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: ScreenUtil.verticalScale(1.8),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : isThisWeek && isSkipped
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
                      child: Builder(builder: (context) {
                        return ButtonWidget(
                          text: "Skipped. View here",
                          textColor: Colors.white,
                          onPress: () {
                            Navigator.pushNamed(context, '/today');
                          },
                          color: AppColors.primaryColor,
                          isLoading: false,
                        );
                      })
                      // ButtonWidget(
                      //   text: (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                      //       ? "Start the workout"
                      //       : "Mark Rest Day Complete",
                      //   textColor: Colors.grey,
                      //   onPress: () {
                      //   },
                      //   color: const Color.fromARGB(90, 214, 211, 211),
                      //   isLoading: false,
                      // ),
                      )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
                      child: Builder(builder: (context) {
                        return ButtonWidget(
                          text: (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                              // ?  "Start the workout"
                              ? (isThisWeek && !isCompleted && !isSkipped && isNoDataHistory ? "Start the workout" : "View the workout")
                              : (isThisWeek && !isCompleted && !isSkipped && isNoDataHistory
                                  ? "Mark Rest Day Complete"
                                  : isCompleted
                                      ? "Completed"
                                      // : "Skipped"),
                                      : "Mark Rest Day Complete"),
                          textColor: Colors.white,
                          onPress: (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                              // ?  "Start the workout"
                              ? (isThisWeek && !isCompleted && !isSkipped && isNoDataHistory
                                  ? () async {
                                      userData?.updateOrAddDayHistory(AppConstants.STATE_STARTED);
                                      weeklyGraphProvider.startTimer();
                                      Navigator.pushNamed(context, '/today');
                                    }
                                  : () async {
                                      Navigator.pushNamed(context, '/today');
                                    })
                              : () async {
                                  debugPrint('dayCompleted==========>>>>>');
                                  // await userData?.finishCurrentDay();
                                  userData?.updateOrAddDayHistory(AppConstants.STATE_FINISHED);
                                  // Navigator.pushNamed(context, '/home');
                                  Navigator.pushNamed(
                                    context,
                                    '/dayCompleted',
                                    arguments: userData?.currentDay,
                                  );
                                },
                          // onPress: (isThisWeek && !isCompleted && !isSkipped ||
                          //         userData!.currentDayObj.formats
                          //             .contains(userData?.selectedDaySplit))
                          //     ? () async {
                          //         if ((userData!.currentDayObj.formats
                          //             .contains(userData?.selectedDaySplit))) {
                          //           userData?.updateOrAddDayHistory(
                          //               AppConstants.STATE_STARTED);
                          //           weeklyGraphProvider.startTimer();
                          //           Navigator.pushNamed(context, '/today');
                          //         } else {
                          //           debugPrint('dayCompleted==========>>>>>');
                          //           // await userData?.finishCurrentDay();
                          //           userData?.updateOrAddDayHistory(
                          //               AppConstants.STATE_FINISHED);
                          //           // Navigator.pushNamed(context, '/home');
                          //           Navigator.pushNamed(
                          //             context,
                          //             '/dayCompleted',
                          //             arguments: userData?.currentDay,
                          //           );
                          //         }
                          //       }
                          //     : null,
                          color: AppColors.primaryColor,
                          isLoading: false,
                        );
                      })),

          SizedBox(
            height: ScreenUtil.verticalScale(8),
          ),
          // (isThisWeek && userData?.isRestDay==false && !isCompleted)?
          (isThisWeek && !isCompleted)
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(10)),
                  child: ButtonWidget(
                    text: isThisWeek && isSkipped
                        ?
                        // "Day Skipped. Unskip?":
                        "Unskip?"
                        : "Skip Day",
                    textColor: Colors.white,
                    onPress: (isThisWeek && !isSkipped || userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                        ? () async {
                            ///Condition if skipped then we will show unskip

                            // userData?.updateOrAddDayHistory(
                            //     AppConstants
                            //         .STATE_SKIPPED);
                            // Navigator.pop(context);
                            log('isThisWeek :::::::::::::::::: ${isThisWeek}');
                            log('isSkipped :::::::::::::::::: ${isSkipped}');
                            if (isThisWeek && isSkipped) {
                              userData?.updateOrAddDayHistory(AppConstants.STATE_NOT_STARTED);

                              userData?.notifyListeners();
                              setState(() {
                                isSkipped = false;
                              });
                              // Navigator.pop(context);
                            } else {
                              userData?.updateOrAddDayHistory(AppConstants.STATE_SKIPPED);

                              userData?.notifyListeners();
                              Navigator.pop(context);
                            }
                          }
                        : () async {


                            ///Condition if rest day skipped then we will show unskip
                            if (isThisWeek && isSkipped) {
                              userData?.updateOrAddDayHistory(AppConstants.STATE_NOT_STARTED);
                              userData?.notifyListeners();
                              setState(() {
                                isSkipped = false;
                              });
                              // Navigator.pop(context);
                            } else {
                              userData?.updateOrAddDayHistory(AppConstants.STATE_SKIPPED);
                              userData?.notifyListeners();
                              Navigator.pop(context);
                            }
                          },
                    color: AppColors.skipDayColor,
                    isLoading: false,
                  )
                  // ButtonWidget(
                  //   text: (userData!.currentDayObj.formats.contains(userData?.selectedDaySplit))
                  //       ? "Start the workout"
                  //       : "Mark Rest Day Complete",
                  //   textColor: Colors.grey,
                  //   onPress: () {
                  //   },
                  //   color: const Color.fromARGB(90, 214, 211, 211),
                  //   isLoading: false,
                  // ),
                  )
              : const SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: ScreenUtil.verticalScale(11),
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text != ""
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: ScreenUtil.verticalScale(1.3)),
                  Icon(Icons.circle, size: ScreenUtil.verticalScale(0.6), color: Colors.black54),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: ScreenUtil.verticalScale(1.3)),
                ]),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: media.width / 1.4),
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil.horizontalScale(4),
                color: Colors.black54,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
