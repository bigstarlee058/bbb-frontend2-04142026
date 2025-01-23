import 'dart:developer';

import 'package:bbb/models/day.dart';
import 'package:bbb/models/dayexercise.dart';
import 'package:bbb/models/week.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/pump_day_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/convert_util.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/custom_prints.dart';
import '../values/app_constants.dart';

class WeeklyTrackCard extends StatefulWidget {
  const WeeklyTrackCard({
    super.key,
    required this.title,
    required this.thisWeek,
    required this.weekIndex,
    required this.isOpened,
    required this.isCompleted,
    required this.startDate,
    required this.cardData,
    required this.daySplit,
    required this.expandedVal,
    required this.weekStatus,
    required this.completedWeek,
    required this.restDayId,
    required this.pumpDayIds,
    this.dataProvider,
    this.userDataProvider,
  });

  final String title;
  final bool thisWeek;
  final int weekIndex;
  final bool isOpened;
  final bool isCompleted;
  final DateTime startDate;
  final Week cardData;
  final String daySplit;
  final bool expandedVal;
  final int weekStatus;
  final int completedWeek;
  final String restDayId;
  final List pumpDayIds;
  final DataProvider? dataProvider;
  final UserDataProvider? userDataProvider;

  @override
  State<WeeklyTrackCard> createState() => _WeeklyTrackCardState();
}

class _WeeklyTrackCardState extends State<WeeklyTrackCard> {
  List<String> moreOptions = ["None", "Recommended", "Last Visited"];
  UserDataProvider? userData;
  int curExpandedIdx = 0;
  bool ischecked = false;
  bool _isExpanded = false;
  bool thisWeek = false;
  int totalExercises = 0;
  late int compareCurrentWeek = 0;
  List<Day> cardDataArr = [];
  final today = DateTime.now();
  DataProvider? dataProvider;
  List<String> dayTitles = [];
  late PumpDayProvider pumpDayProvider;

  @override
  void initState() {
    super.initState();
    pumpDayProvider = Provider.of<PumpDayProvider>(context, listen: false);

    userData = widget.userDataProvider;
    dataProvider = widget.dataProvider;

    thisWeek = widget.thisWeek;
    _isExpanded = widget.expandedVal;
    cardDataArr = [...widget.cardData.days];

    for (var element in cardDataArr) {
      if (element.formats.contains(widget.daySplit)) {
        totalExercises += element.exercises.length;
      }
    }
    compareCurrentWeek = userData!.currentWeek;
  }

  @override
  Widget build(BuildContext context) {
    return totalExercises != 0
        ? Container(
            child: filterViewList(),
          )
        : Container();
  }

  Widget filterViewList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTileGroup(
            toggleType: ToggleType.expandOnlyCurrent,
            spaceBetweenItem: 15,
            onExpansionItemChanged: (idx, isExpand) => {
              curExpandedIdx = idx,
            },
            children: [
              FilterViewItem(_isExpanded, widget.title),
            ],
          ),
        ],
      ),
    );
  }

  ExpansionTileItem FilterViewItem(bool initExpanded, String title) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return ExpansionTileItem(
      tilePadding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(5),
        vertical: ScreenUtil.verticalScale(0.5),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title != "" ? title : "Week",
              style: GoogleFonts.plusJakartaSans(
                color: widget.weekStatus == 1 || widget.weekStatus == 2 ? AppColors.primaryColor : Colors.white,
                fontSize: ScreenUtil.verticalScale(2),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(width: ScreenUtil.verticalScale(3)),
          if (!_isExpanded)
            Text(
              '${userData!.selectedDaySplit} workouts',
              style: GoogleFonts.plusJakartaSans(
                color: widget.weekStatus == 1 || widget.weekStatus == 2 ? Colors.black38 : Colors.white,
                fontSize: ScreenUtil.verticalScale(1.5),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF0D0D0D),
      collapsedBackgroundColor: widget.weekStatus == 1 || widget.weekStatus == 2 ? const Color(0xFF0D0D0D) : AppColors.primaryColor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
        color: widget.weekStatus == 1 || widget.weekStatus == 2 ? Colors.grey[100] : AppColors.primaryColor,
      ),
      iconColor: widget.weekStatus == 1 || widget.weekStatus == 2 ? Colors.grey[400] : AppColors.primaryColor,
      collapsedIconColor: widget.weekStatus == 1 || widget.weekStatus == 2 ? AppColors.primaryColor : Colors.white,
      initiallyExpanded: initExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                ischecked = !ischecked;
              });
            },
            child: Container(
              padding: EdgeInsets.all(
                ScreenUtil.verticalScale(1),
              ),
              decoration: widget.isCompleted
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor, width: 2),
                      color: AppColors.primaryColor,
                    )
                  : null,
              child: widget.isCompleted
                  ? Icon(
                      Icons.check,
                      size: ScreenUtil.verticalScale(2),
                      color: Colors.white,
                    )
                  : Icon(null, size: ScreenUtil.verticalScale(2)),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            child: Container(
              padding: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.weekStatus == 1 || widget.weekStatus == 2 ? AppColors.primaryColor : Colors.white,
                  width: 2,
                ),
                color: widget.weekStatus == 1 || widget.weekStatus == 2 ? AppColors.primaryColor : Colors.white,
              ),
              child: Icon(
                _isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined,
                color: widget.weekStatus == 1 || widget.weekStatus == 2 ? Colors.white : AppColors.primaryColor,
                weight: 900,
                size: ScreenUtil.verticalScale(3),
              ),
            ),
          ),
        ],
      ),
      children: [
        /// OLD
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6))),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(1),
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      widget.cardData.description ?? "",
                      style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.7),
                        color: widget.weekStatus == 1 || widget.weekStatus == 2 ? const Color(0xFF888888) : Colors.white,
                        //const Color(0xFF888888),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.verticalScale(3),
                    ),

                    ///NEW
                    Consumer<PumpDayProvider>(builder: (context, pumpDayProvider, child) {
                      ///NEW WAY TO HANDLE SPLIT DAYS
                      if (widget.daySplit == "3") {
                        List<Day> tempCardDataArr = [];
                        List<Day> restDataArr = [];
                        List<int> workoutIndices = [0, 2, 4];
                        for (int i = 0; i < cardDataArr.length; i++) {
                          if (cardDataArr[i].formats.contains("3")) {
                            tempCardDataArr.add(cardDataArr[i]);
                          }
                          // else {
                          //   if (restDataArr.isEmpty) {
                          //     // restDataArr.add(cardDataArr[i]);
                          //   }
                          // }
                        }
                        cardDataArr = updateTempCardDataArrFor("5", tempCardDataArr, workoutIndices, restDataArr, context);
                        dataProvider!.selectWeekBasedOnSplit = cardDataArr;
                        // dataProvider?.notifyListeners();
                      } else if (widget.daySplit == "4") {
                        // Update card list
                        List<Day> tempCardDataArr = [];
                        List<Day> restDataArr = [];
                        List<int> workoutIndices = [0, 1, 3, 4]; // Workout days: Mon, Wed, Fri

                        for (int i = 0; i < cardDataArr.length; i++) {
                          if (cardDataArr[i].formats.contains("4")) {
                            tempCardDataArr.add(cardDataArr[i]);
                          }
                          // else {
                          //   if (restDataArr.isEmpty) {
                          //     // restDataArr.add(cardDataArr[i]);
                          //   }
                          // }
                        }

                        cardDataArr = updateTempCardDataArrFor("5", tempCardDataArr, workoutIndices, restDataArr, context);
                        dataProvider!.selectWeekBasedOnSplit = cardDataArr;
                        dataProvider?.notifyListeners();
                      } else if (widget.daySplit == "5") {
                        // Update card list
                        List<Day> tempCardDataArr = [];
                        List<Day> restDataArr = [];
                        List<int> workoutIndices = [0, 1, 2, 3, 4]; // Workout days: Mon, Wed, Fri

                        for (int i = 0; i < cardDataArr.length; i++) {
                          if (cardDataArr[i].formats.contains("5")) {
                            tempCardDataArr.add(cardDataArr[i]);
                          }
                          // else {
                          //   // if (restDataArr.isEmpty) {
                          //   //   // restDataArr.add(cardDataArr[i]);
                          //   // }
                          // }
                        }

                        cardDataArr = updateTempCardDataArrFor("3", tempCardDataArr, workoutIndices, restDataArr, context);
                        dataProvider?.selectWeekBasedOnSplit = cardDataArr;
                        // dataProvider?.notifyListeners();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cardDataArr.asMap().entries.map((entry) {
                          var index = entry.key; // Accurate index
                          Day wObj = entry.value;
                          int exercieCount = wObj.exercises
                              .where((dynamic exercise) => (exercise as DayExercise)
                                  .formats
                                  .contains(userData?.selectedExerciseFormatAlternate)) // Cast to DayExercise
                              .toList()
                              .length;

                          var isLast = wObj == cardDataArr.last;
                          bool isRestDay = !(wObj.formats.contains(widget.daySplit));

                          var isPumpDayData =
                              pumpDayProvider.checkForPumpDay(userData!.currentMonth, widget.weekIndex + 1, index + 1, widget.daySplit);

                          bool isPumpDay = isPumpDayData != null;

                          return SizedBox(
                            height: !isRestDay ? media.height * 0.084 : media.height * 0.06,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isRestDay) const Spacer(),
                                    Consumer<UserDataProvider>(
                                      builder: (context, userData, child) {
                                        if (compareCurrentWeek == widget.completedWeek) {
                                          for (int j = 0; j < 7; j++) {
                                            bool isDayFinished = false;
                                            for (var day in userData.dayHistory) {
                                              if ('${day['monthIndex']} ${day['weekIndex']} ${day['daySplit']} ${day['dayIndex']} ${day['state']}' ==
                                                      '${userData.currentMonth} ${widget.cardData.index} ${widget.daySplit} ${j + 1} ${AppConstants.STATE_FINISHED}' ||
                                                  '${day['monthIndex']} ${day['weekIndex']} ${day['daySplit']} ${day['dayIndex']} ${day['state']}' ==
                                                      '${userData.currentMonth} ${widget.cardData.index} ${widget.daySplit} ${j + 1} ${AppConstants.STATE_SKIPPED}') {
                                                isDayFinished = true;
                                                break;
                                              }
                                            }
                                            if (!isDayFinished) {
                                              userData.nextDayIndex = j + 1;
                                              // userData?.notifyListeners();
                                              break;
                                            }
                                          }
                                        }
                                        return Column(
                                          children: [
                                            if (index == 6)
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            DottedDashedLine(
                                              height: ((!isRestDay && index != 0) || index == 6) ? media.width * 0.02 : 0,
                                              width: 0,
                                              dashColor: Colors.grey.withOpacity(0.5),
                                              axis: Axis.vertical,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                                              decoration: BoxDecoration(
                                                color: compareCurrentWeek != widget.completedWeek
                                                    ? Colors.white
                                                    : index == userData.nextDayIndex - 1
                                                        ? AppColors.primaryColor
                                                        : Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: userData.dayHistory.isEmpty
                                                  ? noDataHistroyWeeks(
                                                      context, widget.startDate, index, compareCurrentWeek, widget.completedWeek)
                                                  : (userData.dayHistory).any((element) => compareCurrentWeek == widget.completedWeek)
                                                      ? Builder(
                                                          builder: (context) {
                                                            return Builder(builder: (context) {
                                                              return currentWeekIcon(
                                                                  context, index + 1, wObj, index == userData.nextDayIndex - 1);
                                                            });
                                                          },
                                                        )
                                                      : (userData.dayHistory).any((element) => compareCurrentWeek < widget.completedWeek)
                                                          ? futureWeekIcon(context, wObj)
                                                          : previousWeekIcon(context, wObj, index + 1),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if (index != 6)
                                      DottedDashedLine(
                                        height: isLast ? media.width * 0.03 : media.width * 0.053,
                                        width: 0,
                                        dashColor: Colors.grey.withOpacity(0.5),
                                        axis: Axis.vertical,
                                      )
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    // Define your button action here
                                    userData?.currentWeek = widget.weekIndex + 1;
                                    userData?.currentDay = index + 1;
                                    userData?.currentDayObj = wObj;
                                    userData?.previousPage = 2;
                                    debugPrint("this is weekly track card6 ${index + 1}");
                                    customPrintR("first ${!(wObj.formats.contains(widget.daySplit))}");
                                    userData?.isRestDay = !(wObj.formats.contains(widget.daySplit));
                                    userData?.notifyListeners();
                                    userData?.fetchRestDay(widget.restDayId);

                                    Navigator.pushNamed(context, '/dayOverview');
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: index == 6 ? MainAxisAlignment.center : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                              child: Text(
                                                isPumpDay
                                                    ? isPumpDayData['current_title']
                                                    : isRestDay
                                                        ? "Rest Day"
                                                        : "Day ${wObj.typeId} ${wObj.title}",
                                                style: TextStyle(
                                                  color: widget.weekStatus == 1 || widget.weekStatus == 2
                                                      ? AppColors.primaryColor
                                                      : Colors.white,
                                                  fontSize: ScreenUtil.verticalScale(2),
                                                  fontWeight: FontWeight.bold,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(children: [
                                                  if (!isRestDay) ...[
                                                    Text(
                                                      exercieCount > 1 ? '$exercieCount Exercises' : " $exercieCount Exercise",
                                                      style: TextStyle(
                                                        fontSize: ScreenUtil.verticalScale(1.4),
                                                        color:
                                                            widget.weekStatus == 1 || widget.weekStatus == 2 ? Colors.grey : Colors.white,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ]
                                                ]),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (index == 6)
                                            const SizedBox(
                                              height: 2,
                                            ),
                                          SizedBox(height: ((!isRestDay && index != 0) || index == 6) ? media.width * 0.02 : 0),
                                          SizedBox(
                                            child: SizedBox(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: ScreenUtil.horizontalScale(1),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      userData?.currentWeek = widget.weekIndex + 1;
                                                      userData?.currentDay = index + 1;
                                                      userData?.currentDayObj = wObj;
                                                      userData?.isRestDay = !(wObj.formats.contains(widget.daySplit));
                                                      userData?.previousPage = 2;
                                                      userData?.notifyListeners();
                                                      userData?.isRestDay = !(wObj.formats.contains(widget.daySplit));
                                                      Navigator.pushNamed(context, '/dayOverview');
                                                    },
                                                    child: InkWell(
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                          ScreenUtil.verticalScale(0.5),
                                                        ),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                          color: Colors.white,
                                                        ),
                                                        child: Icon(
                                                          Icons.keyboard_arrow_right_outlined,
                                                          color: AppColors.primaryColor,
                                                          size: ScreenUtil.verticalScale(2.5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: index == 6
                                                ? media.width * 0.01
                                                : isLast
                                                    ? media.width * 0.035
                                                    : media.width * 0.056,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget previousWeekIcon(BuildContext context, wObj, index) {
    return userData?.dayHistory.isEmpty ?? false
        ? currentWeekIcon(context, index, wObj, false)
        : Container(
            height: ScreenUtil.verticalScale(3.4),
            width: ScreenUtil.verticalScale(3.4),
            decoration: BoxDecoration(
              color: (userData!.dayHistory).any((element) =>
                      '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                      '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} ${wObj.typeId} ${AppConstants.STATE_FINISHED}')
                  ? const Color(0xff9A354E) // Use primary color for completed tasks
                  : (userData!.dayHistory).any((element) =>
                          '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                          '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} ${wObj.typeId} ${AppConstants.STATE_SKIPPED}')
                      ? Colors.blue // Blue for skipped tasks
                      : Colors.blue, // Default color for other cases
              shape: BoxShape.circle,
            ),
            child: Center(
              child: (userData!.dayHistory).any((element) =>
                      '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                      '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_FINISHED}')
                  ? const Icon(Icons.check, color: Colors.white, size: 20) // White checkmark for completed tasks
                  : (userData!.dayHistory).any((element) =>
                          '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                          '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_SKIPPED}')
                      ? const Icon(Icons.close, color: Colors.white, size: 20) // White "X" for skipped tasks
                      : const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          );
  }

  Widget futureWeekIcon(BuildContext context, wObj) {
    return Container(
      height: ScreenUtil.verticalScale(3.4),
      width: ScreenUtil.verticalScale(3.4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(child: Icon(Icons.hourglass_top, color: Colors.black38, size: 20)),
    );
  }

  Widget noDataHistroyWeeks(BuildContext context, DateTime? startData, int index, compareCurrentWeek, completedweek) {
    DateTime toDateOnly(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    DateTime currentWeekStart() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    }

    int currentIndex() {
      return userData!.nextDayIndex - 1;
    }

    if (startData == null) {
      return const Text("NA");
    }

    // Convert startData and currentWeek to date-only
    // final currentWeek = toDateOnly(currentWeekStart());
    // final startDateOnly = toDateOnly(startData);
    final todayIndex = currentIndex();

    if (compareCurrentWeek > completedweek) {
      // Previous week
      return Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: const BoxDecoration(
          color: Colors.blue, // Default color for other cases
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.close, color: Colors.white, size: 20),
        ),
      );
    } else if (compareCurrentWeek == completedweek) {
      // Current week
      if (index == todayIndex) {
        return Container(
          height: ScreenUtil.verticalScale(3.4),
          width: ScreenUtil.verticalScale(3.4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
      } else {
        return Container(
          height: ScreenUtil.verticalScale(3.4),
          width: ScreenUtil.verticalScale(3.4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15), // Default color for other cases
            shape: BoxShape.circle,
          ),
          // child: const Center(child: null),//const Icon(Icons.close, color: Colors.white, size: 20) // White "X" for skipped tasks
        );
      }
    } else if (compareCurrentWeek < completedweek) {
      // Future week
      return Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.hourglass_top, color: Colors.black38, size: 20)),
      );
    } else {
      // Fallback case
      return Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.hourglass_top, color: Colors.black38, size: 20)),
      );
    }
  }

  Widget currentWeekIcon(BuildContext context, index, wObj, passCurrentIndex) {
    return Container(
      height: ScreenUtil.verticalScale(3.4),
      width: ScreenUtil.verticalScale(3.4),
      decoration: BoxDecoration(
        color: passCurrentIndex == true
            ? Colors.white
            : (userData!.dayHistory).any((element) =>
                    '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                    '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_FINISHED}')
                ? Colors.green // Use primary color for completed tasks
                : (userData!.dayHistory).any((element) =>
                        '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                        '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_SKIPPED}')
                    ? Colors.blue // Blue for skipped tasks
                    : Colors.grey.withOpacity(0.15), // Default color for other cases
        shape: BoxShape.circle,
      ),
      child: Center(
          child: passCurrentIndex == true &&
                  (userData!.dayHistory).any((element) =>
                      '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                      '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_FINISHED}')
              ? Container(
                  height: ScreenUtil.verticalScale(3.4),
                  width: ScreenUtil.verticalScale(3.4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20))
              : (userData!.dayHistory).any((element) =>
                      '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                      '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_FINISHED}')
                  ? const Icon(Icons.check, color: Colors.white, size: 20) // White checkmark for completed tasks
                  : (userData!.dayHistory).any((element) =>
                          '${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}' ==
                          '${userData!.currentMonth} ${widget.cardData.index} ${widget.daySplit} $index ${AppConstants.STATE_SKIPPED}')
                      ? const Icon(Icons.close, color: Colors.white, size: 20) // White "X" for skipped tasks
                      : null //const Icon(Icons.close, color: Colors.white, size: 20),
          ),
    );
  }

  int getDayIndex() {
    final now = DateTime.now();
    return now.weekday - 1; // Monday = 0, Tuesday = 1, ..., Sunday = 6
  }

  String currentWeekFormatted() {
    // Get today's date
    final now = DateTime.now();
    // Calculate the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Format and return as YYYY-MM-DD
    return formatDate(startOfWeek);
  }

  String formatDate(DateTime date) {
    // Convert DateTime to YYYY-MM-DD format
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int currentIndex() {
    // Get today's date
    final now = DateTime.now();
    // Adjust weekday to match Monday = 0, ..., Sunday = 6
    return now.weekday - 1;
  }
}
