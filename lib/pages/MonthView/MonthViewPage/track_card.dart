import 'dart:developer';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/custom/expansion_panel.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/theme.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class WeeklyTrackCard extends StatefulWidget {
  const WeeklyTrackCard({
    super.key,
    required this.index,
    this.monthProvider,
    required this.title,
    required this.thisWeek,
    required this.weekIndex,
    required this.isOpened,
    required this.isCompleted,
    required this.startDate,
    required this.cardData,
    required this.daySplit,
    required this.expandedVal,
    required this.completedWeek,
    required this.restDayId,
    required this.pumpDayIds,
  });

  final int index;
  final MonthProvider? monthProvider;
  final String title;
  final bool thisWeek;
  final int weekIndex;
  final bool isOpened;
  final bool isCompleted;
  final DateTime startDate;
  final WeekDataModel cardData;
  final String daySplit;
  final bool expandedVal;
  final int completedWeek;
  final String restDayId;
  final List<String> pumpDayIds;

  @override
  State<WeeklyTrackCard> createState() => _WeeklyTrackCardState();
}

class _WeeklyTrackCardState extends State<WeeklyTrackCard> {
  List<String> moreOptions = ["None", "Recommended", "Last Visited"];

  MonthProvider? monthProvider;
  int? mainIndex;
  // WeekDataModel? weekDataModel;
  List<DayDataModel> dayDataList = [];
  // int curExpandedIdx = 0;
  bool ischecked = false;
  // bool _isExpanded = false;
  bool thisWeek = false;
  List<String> dayTitles = [];

  @override
  void initState() {
    super.initState();
    monthProvider = widget.monthProvider;
    mainIndex = widget.index;
    // weekDataModel = widget.monthProvider?.weeksDataList[mainIndex!];
    thisWeek = ((mainIndex! + 1) == monthProvider?.week);
    // _isExpanded = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (monthProvider!.isCurrentMonth == "Current") {
        if ((mainIndex! + 1) == monthProvider?.week ? true : false) {
          monthProvider!.updateWeekExpandedHeight(82.5, mainIndex ?? 0);
        }
        await Future.delayed(Duration.zero).then(
          (value) {
            if ((mainIndex! + 1) == monthProvider?.week) {
              if (!monthProvider!.expandWeeks.contains(mainIndex)) {
                monthProvider?.updateExpandWeeks(mainIndex ?? 0);
              }
            }
            // return _isExpanded =
            //     (mainIndex! + 1) == monthProvider?.week ? true : false;
          },
        );
      } else {
        // bool isFuture =
        //     monthProvider?.weekStatuses[mainIndex ?? 0] == WeekType.futureWeek;

        if ((mainIndex! + 1) == 1 ? true : false) {
          monthProvider!.updateWeekExpandedHeight(82.5, mainIndex ?? 0);
        }
        await Future.delayed(Duration.zero).then(
          (value) {
            if ((mainIndex! + 1) == 1) {
              if (!monthProvider!.expandWeeks.contains(mainIndex)) {
                monthProvider?.updateExpandWeeks(0);
              }
            }
            // return _isExpanded = (mainIndex! + 1) == 1 ? true : false;
          },
        );
      }
    });

    dayDataList = widget.monthProvider!.weeksDataList[mainIndex!].days!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthProvider>(
      builder: (context, monthProvider, child) {
        return Container(
          child: monthProvider.weekStatuses.isEmpty
              ? SizedBox()
              : filterViewList1(monthProvider),
        );
      },
    );
  }

  Widget filterViewList1(MonthProvider monthProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).brightness == Brightness.light
                ? lightTheme.copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  )
                : darkTheme.copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(0)),
              child: ExpansionPanelList(
                sidePadding: true,
                animationDuration: Duration(milliseconds: 300),
                expandIconColor: Colors.grey.shade400,
                // materialGapSize: 10,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (panelIndex, isExpanded) async {
                  if (isExpanded) {
                    monthProvider.updateWeekExpandedHeight(
                        monthProvider.weekExpandedHeight + (82.5),
                        mainIndex ?? 0);
                    setState(() {});
                    await Future.delayed(Duration(milliseconds: 100)).then(
                      (value) {
                        widget.monthProvider?.updateExpandWeeks(mainIndex ?? 0);
                        // _isExpanded = isExpanded;
                        // curExpandedIdx = isExpanded ? 0 : -1;
                      },
                    );
                  } else {
                    // _isExpanded = isExpanded;
                    // curExpandedIdx = isExpanded ? 0 : -1;
                    widget.monthProvider?.updateExpandWeeks(mainIndex ?? 0);
                    setState(() {});
                    await Future.delayed(Duration(milliseconds: 310)).then(
                      (value) => monthProvider.updateWeekExpandedHeight(
                          monthProvider.weekExpandedHeight - (82.5),
                          mainIndex ?? 0),
                    );
                  }
                },
                elevation: 0,
                children: [
                  expansionPanel1(monthProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanel expansionPanel1(MonthProvider monthProvider) {
    return ExpansionPanel(
      isExpanded: monthProvider.expandWeeks.contains(mainIndex),
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return SizedBox(
          height: ScreenUtil.verticalScale(4),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(6)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title != ""
                        ? (widget.title
                            .toString()
                            .toLowerCase()
                            .capitalizeFirst())
                        : "Week",
                    // style: GoogleFonts.plusJakartaSans(
                    //   color: Colors.black,
                    //   fontSize: ScreenUtil.verticalScale(1.8),
                    //   fontWeight: FontWeight.bold,
                    // ),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: ScreenUtil.horizontalScale(5.5),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: ScreenUtil.verticalScale(2)),
                      child: Container(
                        decoration: BoxDecoration(
                          border: DashedBorder(
                            spaceLength: 8,
                            strokeCap: StrokeCap.square,
                            dashLength: 1,
                            top: BorderSide(
                                color: Colors.grey.shade400, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
          ),
        );
      },
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          monthProvider.weekStatuses[widget.weekIndex] == WeekType.futureWeek
              ? Padding(
                  padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(6))
                      .copyWith(top: ScreenUtil.verticalScale(1)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: ScreenUtil.verticalScale(1.5),
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 2),
                      Text(
                        "Week unlocks on ${DateFormat("MM/dd/yyyy").format(widget.startDate)}",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: ScreenUtil.verticalScale(1.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : monthProvider.weekStatuses[widget.weekIndex] ==
                      WeekType.currentWeek
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(6))
                          .copyWith(top: ScreenUtil.verticalScale(1)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.radio_button_checked,
                          //   size: ScreenUtil.verticalScale(1.7),
                          //   color: Colors.grey.shade600,
                          // ),
                          // SizedBox(width: 2),
                          Builder(builder: (context) {
                            return Text(
                              "This week finishes on ${DateFormat("MM/dd/yyyy").format(widget.startDate.add(Duration(days: 6)))}",
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(1.5),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }),
                        ],
                      ),
                    )
                  : monthProvider.weekStatuses[widget.weekIndex] ==
                          WeekType.pastWeek
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6))
                              .copyWith(top: ScreenUtil.verticalScale(1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: ScreenUtil.verticalScale(1.7),
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 2),
                              Text(
                                "Week finished on ${DateFormat("MM/dd/yyyy").format(widget.startDate.add(Duration(days: 6)))}",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
          SizedBox(height: ScreenUtil.verticalScale(2.5)),
          ListView.separated(
            separatorBuilder: (context, index) =>
                SizedBox(height: ScreenUtil.verticalScale(1)),
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                widget.monthProvider!.weeksDataList[mainIndex!].dayList!.length,
            itemBuilder: (context, index) {
              final dayIndex = int.parse(widget
                      .monthProvider!.weeksDataList[mainIndex!].dayList![index]
                      .toString()
                      .replaceAll("Workout", "")
                      .replaceAll("Rest", "")
                      .replaceAll("Day", "")
                      .replaceAll(" ", "")) -
                  1;

              DayDataModel dayData = widget
                      .monthProvider!.weeksDataList[mainIndex!].dayList![index]
                      .toString()
                      .contains("Workout")
                  ? dayDataList[dayIndex]
                  : DayDataModel();
              bool isRestDay = widget
                  .monthProvider!.weeksDataList[mainIndex!].dayList?[index]
                  .contains("Rest Day");

              final exerciseDetails = isRestDay ? null : dayData.exercises!;

              int? exerciseCount = 0;
              if (exerciseDetails != null &&
                  monthProvider.allRemovedExercise.isNotEmpty) {
                String split = monthProvider
                        .monthDataModel?.weeks?[mainIndex!].idList?.first
                        .toString()
                        .split(" ")[1] ??
                    "";

                String dataId1 =
                    "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].idList![index]}";

                List<String> matchingExerciseIds = monthProvider
                    .allRemovedExercise
                    .where((entry) => entry.dataId == dataId1)
                    .map((entry) => entry.exerciseId!)
                    .toList();
                exerciseCount = exerciseDetails.where(
                  (element) {
                    return !matchingExerciseIds.contains(element.exerciseId);
                  },
                ).length;
              } else {
                exerciseCount = exerciseDetails?.length;
              }

              String split = monthProvider
                      .monthDataModel?.weeks?[mainIndex!].idList?.first
                      .toString()
                      .split(" ")[1] ??
                  "";

              String dataId =
                  "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel!.weeks![mainIndex!].id}-${widget.monthProvider!.weeksDataList[mainIndex!].idList![index]}";

              int nextWorkOutIndex = widget
                      .monthProvider!.weeksDataList[mainIndex!].dayList![index]
                      .toString()
                      .contains("Workout")
                  ? int.parse(widget.monthProvider!.weeksDataList[mainIndex!]
                          .dayList![index]
                          .toString()
                          .replaceAll("Day ", "")
                          .replaceAll(" Workout", "")) -
                      1
                  : 0;
              return SizedBox(
                child: widget.monthProvider!.weeksDataList[mainIndex!]
                        .dayList![index]
                        .toString()
                        .contains("Workout")
                    ? workoutday(monthProvider, isRestDay, dataId, index,
                        dayData, context, nextWorkOutIndex, exerciseCount)
                    : isRestPumpOption(isRestDay, monthProvider, dataId) &&
                            monthProvider.isPumpDayAvailable &&
                            (monthProvider.allSplitDayHistoryModel
                                .where((e) => e.dataId == dataId)
                                .isEmpty)
                        ? selection(
                            monthProvider,
                            index,
                            dayData,
                            context,
                            widget.monthProvider!.weeksDataList[mainIndex!]
                                .idList![index],
                            dataId)
                        : pumpDayRestday(
                            monthProvider, dataId, index, isRestDay, dayData),
              );
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(.5)),
        ],
      ),
    );
  }

  Widget workoutday(
      MonthProvider monthProvider,
      bool isRestDay,
      String dataId,
      int index,
      DayDataModel dayData,
      BuildContext context,
      int nextWorkOutIndex,
      int? exerciseCount) {
    return GestureDetector(
      onTap: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek &&
              monthProvider.isCurrentMonth != "Future"
          ? null
          : () => continueWorkoutOnTap(
              isRestDay,
              dataId,
              index,
              dayData,
              context,
              mainIndex!,
              widget.monthProvider!.weeksDataList[mainIndex!].idList![index]),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
        child: Container(
          margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black.withValues(alpha: 0.1), width: 0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
            color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/
                Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              ScreenUtil.verticalScale(2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil.verticalScale(8.8),
                width: ScreenUtil.verticalScale(8.8),
                // margin: EdgeInsets.all(ScreenUtil.verticalScale(1)),
                decoration: BoxDecoration(
                  color: monthProvider.weekStatuses[mainIndex!] ==
                          WeekType.futureWeek
                      ? Theme.of(context).brightness == Brightness.light
                          ? AppColors.greyColor1
                          : Theme.of(context).canvasColor
                      : (monthProvider.weekStatuses[mainIndex!] ==
                                      WeekType.pastWeek &&
                                  monthProvider
                                      .allSplitDayHistoryModel.isEmpty) ||
                              monthProvider.allSplitDayHistoryModel.any((e) =>
                                  e.status == Status.skipped &&
                                  e.dataId == dataId)
                          ? AppColors.skipDayColor
                          : monthProvider.allSplitDayHistoryModel.any((e) =>
                                  e.status == Status.completed &&
                                  e.dataId == dataId)
                              ? Colors.green
                              : monthProvider.weekStatuses[mainIndex!] ==
                                      WeekType.currentWeek
                                  ? Theme.of(context).brightness ==
                                          Brightness.light
                                      ? AppColors.greyColor1
                                      : Theme.of(context).canvasColor
                                  : AppColors.skipDayColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(2)),
                    bottomLeft: Radius.circular(ScreenUtil.verticalScale(2)),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
                  child: Center(
                    child: monthProvider.weekStatuses[mainIndex!] ==
                            WeekType.futureWeek
                        ? Icon(Icons.hourglass_top,
                            color: Colors.black, size: 25)
                        : monthProvider.allSplitDayHistoryModel.any((e) =>
                                (e.status == Status.completed) &&
                                e.dataId == dataId)
                            ? Icon(
                                Icons.check,
                                size: 25,
                                color: Colors.white,
                              )
                            : monthProvider.allSplitDayHistoryModel.any((e) =>
                                        (e.status == Status.skipped) &&
                                        e.dataId == dataId) ||
                                    monthProvider.weekStatuses[mainIndex!] ==
                                        WeekType.pastWeek
                                ? Icon(
                                    Icons.close,
                                    size: 25,
                                    color: Colors.white,
                                  )
                                : Image.asset(
                                    "assets/img/workout1.png",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    height: ScreenUtil.verticalScale(3.8),
                                  ),
                  ),
                ),
              ),
              SizedBox(width: 3 + ScreenUtil.verticalScale(1)),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Builder(
                              builder: (context) {
                                return Text(
                                  "${widget.monthProvider!.weeksDataList[mainIndex!].days![nextWorkOutIndex].title}",
                                  style: TextStyle(
                                      color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/
                                          Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                      fontSize: ScreenUtil.verticalScale(1.8),
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (!isRestDay) ...[
                            Builder(builder: (context) {
                              int exCount = widget
                                  .monthProvider!
                                  .weeksDataList[mainIndex!]
                                  .days![nextWorkOutIndex]
                                  .exercises!
                                  .where((element) => (element.formats!
                                          .contains(
                                              monthProvider.equipmentType) ||
                                      element.isAddedUpdated == true))
                                  .toList()
                                  .length;

                              return Text(
                                exCount > 1
                                    ? '$exCount Exercises'
                                    : " $exCount Exercise",
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.4),
                                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/
                                      Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
                      Spacer(),
                      monthProvider.weekStatuses[mainIndex!] ==
                              WeekType.currentWeek
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.verticalScale(1.2),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                                color: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_right_outlined,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                size: ScreenUtil.verticalScale(3),
                              ),
                            )
                          /*Theme(
                              data: ThemeData(popupMenuTheme: PopupMenuThemeData(color: Colors.white)),
                              child: PopupMenuButton(
                                surfaceTintColor: Colors.white,
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : Colors.black,
                                ),
                                itemBuilder: (context) {
                                  return [
                                    if (monthProvider.allSplitDayHistoryModel
                                            .any((e) => (e.status != Status.skipped && e.status != Status.completed) && e.dataId == dataId) ||
                                        monthProvider.allSplitDayHistoryModel.where((e) => e.dataId == dataId).isEmpty) ...[
                                      PopupMenuItem(
                                        onTap: () async {
                                          await Future.delayed(Duration(milliseconds: 300)).then(
                                            (v) {},
                                          );
                                        },
                                        child: Text("Mark Skip"),
                                      ),
                                      PopupMenuItem(
                                        child: Text("Mark Complete"),
                                      ),
                                    ],
                                    PopupMenuItem(
                                      onTap: () async {
                                        await Future.delayed(Duration(milliseconds: 300)).then(
                                          (v) {
                                            continueWorkoutOnTap(
                                                isRestDay, dataId, index, dayData, context, mainIndex!, weekDataModel!.idList![index]);
                                          },
                                        );
                                      },
                                      child: Text("View the Day"),
                                    ),
                                  ];
                                },
                              ),
                            )*/
                          : SizedBox(),
                      SizedBox(width: 5)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selection(MonthProvider monthProvider, int index, DayDataModel dayData,
      BuildContext context, String dayId, String dataId) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              monthProvider.changeIsPumpDay(true);

              final dataList = monthProvider.dayHistoryModel
                  .where((element) =>
                      element.type?.contains("Pump Day") == true &&
                      element.status != Status.empty)
                  .toList();

              if (dataList.isNotEmpty) {
                int index1 = monthProvider.pumpDays.indexWhere((el1) =>
                    dataList.any((e1) => (e1.dayId == dayId &&
                        e1.type.toString().replaceAll("Pump Day - ", "") ==
                            el1.id)));
                if (index1 != -1) {
                  monthProvider
                      .updatePumpDayData(monthProvider.pumpDays[index1]);
                } else {
                  int index1 = monthProvider.pumpDays.indexWhere((el1) =>
                      dataList.any((e1) =>
                          e1.type.toString().replaceAll("Pump Day - ", "") ==
                          el1.id));
                  monthProvider
                      .updatePumpDayData(monthProvider.pumpDays[index == -1
                          ? 0
                          : index1 == 0
                              ? 1
                              : 0]);
                }
              } else {
                monthProvider.updatePumpDayData(monthProvider.pumpDays[0]);
              }

              // monthProvider?.updatePumpDayData(monthProvider!.pumpDays[
              //     int.parse(monthProvider!.monthDataModel!.weeks![monthProvider!.week! - 1].dayList![index].toString().split(" ").last) - 1]);
              monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
              monthProvider.overviewCurrentDay = index + 1;
              monthProvider.dayDataModel = dayData;
              // monthProvider.alternateEquipmentType = monthProvider.equipmentType;
              monthProvider.weekDataModel =
                  widget.monthProvider!.weeksDataList[mainIndex!];
              monthProvider.updateIsPastWeek(
                  monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek);

              if ((monthProvider.allSplitDayHistoryModel.any((element) =>
                      (element.status == Status.completed ||
                          element.status == Status.skipped) &&
                      element.dataId == dataId)) ==
                  false) {
                _saveDayData(
                  type: "Pump Day - ${monthProvider.pumpDayModel?.id}",
                  status: Status.started,
                  title: monthProvider.pumpDayModel?.title,
                );
                if (!context.mounted) return;
                await monthProvider.fetchAllDayStatusLocalData();
                await Navigator.pushNamed(context, '/today').then(
                  (value) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (timeStamp) async =>
                            await monthProvider.checkForPumpDay());
                  },
                );
              } else {
                if (!context.mounted) return;
                await monthProvider.fetchAllDayStatusLocalData();
                await Navigator.pushNamed(context, '/today');
              }

              // await Navigator.pushNamed(context, '/dayOverview');
            },
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(6)),
              child: Container(
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/
                      Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(width: ScreenUtil.verticalScale(1)),
                    Container(
                      height: ScreenUtil.verticalScale(8.8),
                      width: ScreenUtil.verticalScale(8.8),
                      // margin: EdgeInsets.symmetric(
                      //     vertical: ScreenUtil.verticalScale(1)),
                      decoration: BoxDecoration(
                        color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.backOffSetColor :*/
                            Theme.of(context).brightness == Brightness.light
                                ? AppColors.greyColor1
                                : Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil.verticalScale(2)),
                          bottomLeft:
                              Radius.circular(ScreenUtil.verticalScale(2)),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          height: ScreenUtil.verticalScale(4.2),
                          "assets/img/pumpday.png",
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Pump Day",
                          style: TextStyle(
                              color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: ScreenUtil.verticalScale(1.5),
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 10),
          child: Center(
              child: Text("or", style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (monthProvider.weekStatuses[mainIndex!] !=
                  WeekType.currentWeek) {
                return;
              }
              monthProvider.changeIsPumpDay(false);
              monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
              monthProvider.overviewCurrentDay = index + 1;
              monthProvider.dayDataModel = dayData;
              monthProvider.weekDataModel =
                  widget.monthProvider!.weeksDataList[mainIndex!];
              monthProvider.updateIsPastWeek(
                  monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek);
              AnimatedDialog.showAnimatedDialog(
                context: context,
                pageBuilder: (c1, anim1, anim2) =>
                    skipWorkoutDialog(context, c1),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(6)),
              child: Container(
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(width: ScreenUtil.verticalScale(1)),
                    Container(
                      height: ScreenUtil.verticalScale(8.8),
                      width: ScreenUtil.verticalScale(8.8),
                      // margin: EdgeInsets.symmetric(
                      //     vertical: ScreenUtil.verticalScale(1)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.greyColor1
                            : Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil.verticalScale(2)),
                          bottomLeft:
                              Radius.circular(ScreenUtil.verticalScale(2)),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          height: ScreenUtil.verticalScale(4.2),
                          "assets/img/restday.png",
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          "Rest Day",
                          style: TextStyle(
                              color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: ScreenUtil.verticalScale(1.5),
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget pumpDayRestday(MonthProvider monthProvider, String dataId, int index,
      bool isRestDay, DayDataModel dayData) {
    return monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
        ? Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
            child: Container(
              margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(
                  ScreenUtil.verticalScale(2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: ScreenUtil.verticalScale(8.8),
                    width: ScreenUtil.verticalScale(8.8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.greyColor1
                          : Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(2)),
                        bottomLeft:
                            Radius.circular(ScreenUtil.verticalScale(2)),
                      ),
                    ),
                    // margin: EdgeInsets.all(ScreenUtil.verticalScale(1)),
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
                      child: Center(
                        child: Icon(Icons.hourglass_top,
                            color: Colors.black, size: 25),
                      ),
                    ),
                  ),
                  SizedBox(width: 3 + ScreenUtil.verticalScale(1)),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: InkWell(
                        onTap: null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pump Day or Rest Day",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: ScreenUtil.verticalScale(1.8),
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Builder(builder: (context) {
            DayHistoryModel? matchingElement =
                monthProvider.allSplitDayHistoryModel.firstWhere(
                    (element) =>
                        element.dataId == dataId &&
                        element.type!.contains("Pump Day"),
                    orElse: () => DayHistoryModel());
            return Slidable(
              enabled: isRestDay &&
                      matchingElement.id == null &&
                      ((monthProvider.allSplitDayHistoryModel.any((e) =>
                              (e.status == Status.completed ||
                                  e.status == Status.skipped) &&
                              e.dataId == dataId) ==
                          true)) &&
                      monthProvider.isPumpDayAvailable
                  ? true
                  : (matchingElement.type ?? "").contains("Pump Day") &&
                      monthProvider.weekStatuses[mainIndex!] ==
                          WeekType.currentWeek &&
                      ((monthProvider.allSplitDayHistoryModel.any((e) =>
                              (e.status == Status.completed ||
                                  e.status == Status.skipped) &&
                              e.dataId == dataId) ==
                          false)),
              endActionPane: ActionPane(
                extentRatio: 0.22,
                motion: const ScrollMotion(),
                children: [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Row(
                      children: [
                        SizedBox(
                          width: ScreenUtil.horizontalScale(2),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(4),
                          width: ScreenUtil.verticalScale(4),
                          child: Row(
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  if (monthProvider.weekStatuses[mainIndex!] !=
                                      WeekType.currentWeek) {
                                    return;
                                  }
                                  if (isRestDay &&
                                      matchingElement.id == null &&
                                      ((monthProvider.allSplitDayHistoryModel
                                              .any((e) =>
                                                  (e.status ==
                                                          Status.completed ||
                                                      e.status ==
                                                          Status.skipped) &&
                                                  e.dataId == dataId) ==
                                          true)) &&
                                      monthProvider.isPumpDayAvailable) {
                                    await Future.delayed(
                                            Duration(milliseconds: 300))
                                        .then(
                                      (v) async {
                                        monthProvider.changeIsPumpDay(false);
                                        monthProvider.overviewCurrentWeek =
                                            widget.weekIndex + 1;
                                        monthProvider.overviewCurrentDay =
                                            index + 1;
                                        monthProvider.dayDataModel = dayData;
                                        monthProvider.weekDataModel = widget
                                            .monthProvider!
                                            .weeksDataList[mainIndex!];
                                        await deletePumpDayData();
                                      },
                                    );
                                  } else {
                                    await Future.delayed(
                                            Duration(milliseconds: 300))
                                        .then(
                                      (v) async {
                                        monthProvider.changeIsPumpDay(false);
                                        monthProvider.overviewCurrentWeek =
                                            widget.weekIndex + 1;
                                        monthProvider.overviewCurrentDay =
                                            index + 1;
                                        monthProvider.dayDataModel = dayData;
                                        monthProvider.weekDataModel = widget
                                            .monthProvider!
                                            .weeksDataList[mainIndex!];
                                        await deletePumpDayData();
                                      },
                                    );
                                  }
                                },
                                icon: Icons.swap_horiz,
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(3)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   width: ScreenUtil.horizontalScale(5),
                  // ),
                  // SizedBox(
                  //   height: ScreenUtil.verticalScale(4),
                  //   width: ScreenUtil.verticalScale(4),
                  //   child: Row(
                  //     children: [
                  //       SlidableAction(
                  //         onPressed: (context) {
                  //           // widget.onRemove();
                  //         },
                  //         icon: Icons.close,
                  //         backgroundColor: Colors.red,
                  //         foregroundColor: Colors.white,
                  //         padding: const EdgeInsets.all(0),
                  //         borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.horizontalScale(6)),
                child: Container(
                  margin:
                      EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                    color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/
                        Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(ScreenUtil.verticalScale(2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: ScreenUtil.verticalScale(8.8),
                        width: ScreenUtil.verticalScale(8.8),
                        // margin: EdgeInsets.all(ScreenUtil.verticalScale(1)),
                        decoration: BoxDecoration(
                          color: monthProvider.weekStatuses[mainIndex!] ==
                                  WeekType.futureWeek
                              ? Theme.of(context).brightness == Brightness.light
                                  ? AppColors.greyColor1
                                  : Theme.of(context).canvasColor
                              : (monthProvider.weekStatuses[mainIndex!] ==
                                              WeekType.pastWeek &&
                                          monthProvider.allSplitDayHistoryModel
                                              .isEmpty) ||
                                      monthProvider.allSplitDayHistoryModel.any(
                                          (e) =>
                                              e.status == Status.skipped &&
                                              e.dataId == dataId)
                                  ? AppColors.skipDayColor
                                  : monthProvider.allSplitDayHistoryModel.any(
                                          (e) =>
                                              e.status == Status.completed &&
                                              e.dataId == dataId)
                                      ? Colors.green
                                      : monthProvider
                                                  .weekStatuses[mainIndex!] ==
                                              WeekType.currentWeek
                                          ? Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppColors.greyColor1
                                              : Theme.of(context).canvasColor
                                          : AppColors.skipDayColor,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ScreenUtil.verticalScale(2)),
                            bottomLeft:
                                Radius.circular(ScreenUtil.verticalScale(2)),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
                          child: Center(
                            child: monthProvider.weekStatuses[mainIndex!] ==
                                    WeekType.futureWeek
                                ? Icon(Icons.hourglass_top,
                                    color: Colors.black, size: 25)
                                : monthProvider.allSplitDayHistoryModel.any(
                                        (e) =>
                                            (e.status == Status.completed) &&
                                            e.dataId == dataId)
                                    ? Icon(
                                        Icons.check,
                                        size: 25,
                                        color: Colors.white,
                                      )
                                    : monthProvider.allSplitDayHistoryModel.any(
                                                (e) =>
                                                    (e.status ==
                                                        Status.skipped) &&
                                                    e.dataId == dataId) ||
                                            monthProvider
                                                    .weekStatuses[mainIndex!] ==
                                                WeekType.pastWeek
                                        ? Icon(
                                            Icons.close,
                                            size: 25,
                                            color: Colors.white,
                                          )
                                        : Image.asset(
                                            (matchingElement.type ?? "")
                                                    .contains("Pump Day")
                                                ? "assets/img/pumpday.png"
                                                : "assets/img/restday.png",
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            height:
                                                ScreenUtil.verticalScale(4.2),
                                          ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3 + ScreenUtil.verticalScale(1)),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: InkWell(
                            onTap: monthProvider.weekStatuses[mainIndex!] ==
                                    WeekType.futureWeek
                                ? null
                                : () => continueWorkoutOnTap(
                                    isRestDay,
                                    dataId,
                                    index,
                                    dayData,
                                    context,
                                    mainIndex!,
                                    widget
                                        .monthProvider!
                                        .weeksDataList[mainIndex!]
                                        .idList![index]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Builder(builder: (context) {
                                  int i = int.parse(widget
                                          .monthProvider!
                                          .weeksDataList[mainIndex!]
                                          .dayList![index]
                                          .toString()
                                          .split(" ")
                                          .toList()
                                          .last) -
                                      1;

                                  return i <
                                          widget
                                              .monthProvider!
                                              .weeksDataList[mainIndex!]
                                              .restDayList!
                                              .length
                                      ? Text(
                                          matchingElement.type == null
                                              ? (widget
                                                      .monthProvider!
                                                      .weeksDataList[mainIndex!]
                                                      .restDayList?[i] ??
                                                  "Rest Day")
                                              : (matchingElement.type ?? "")
                                                      .contains("Pump Day")
                                                  ? "${matchingElement.title}"
                                                  : widget
                                                      .monthProvider!
                                                      .weeksDataList[mainIndex!]
                                                      .restDayList?[i],
                                          style: TextStyle(
                                              color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                              fontSize:
                                                  ScreenUtil.verticalScale(1.8),
                                              fontWeight: FontWeight.bold,
                                              height: 1),
                                        )
                                      : SizedBox();
                                }),
                                Spacer(),
                                monthProvider.weekStatuses[mainIndex!] ==
                                            WeekType.currentWeek &&
                                        (matchingElement.type ?? "")
                                            .contains("Pump Day")
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ScreenUtil.verticalScale(1.2),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.transparent,
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_right_outlined,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          size: ScreenUtil.verticalScale(3),
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(width: 5)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
  }

  bool isRestPumpOption(
      bool isRestDay, MonthProvider monthProvider, String dataId) {
    return ((isRestDay &&
                monthProvider.weekStatuses[mainIndex!] ==
                    WeekType.currentWeek &&
                monthProvider.isPumpDayAvailable) &&
            (monthProvider.allSplitDayHistoryModel.any((element) =>
                    (element.status != Status.skipped &&
                        element.status != Status.completed &&
                        (dataId == element.dataId))) ||
                (!monthProvider.allSplitDayHistoryModel
                    .map((e) => e.dataId)
                    .toList()
                    .contains(dataId)))) ||
        ((isRestDay &&
                monthProvider.weekStatuses[mainIndex!] ==
                    WeekType.currentWeek) &&
            (monthProvider.allSplitDayHistoryModel.any((element) =>
                ((element.status == Status.started) &&
                    dataId == element.dataId))));
  }

  Future<void> continueWorkoutOnTap(
      bool isRestDay,
      String dataId,
      int index,
      DayDataModel dayData,
      BuildContext context,
      int weekIndex,
      String dayId) async {
    DayHistoryModel? matchingElement = monthProvider!.allSplitDayHistoryModel
        .firstWhere(
            (element) =>
                element.dataId == dataId && element.type!.contains("Pump Day"),
            orElse: () => DayHistoryModel());

    bool isRestDayForPastWeek =
        monthProvider!.weekStatuses[mainIndex!] == WeekType.pastWeek &&
            (!(matchingElement.title ?? "").contains("Pump Day"));
    bool isPumpDay = (isRestDay &&
            monthProvider!.allSplitDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allSplitDayHistoryModel.any((element) =>
                element.dataId == dataId && element.type != "Rest Day"))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allSplitDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type == "Rest Day" &&
                element.status == ""))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (!monthProvider!.allSplitDayHistoryModel
                .map((e) => e.dataId)
                .toList()
                .contains(dataId)));

    monthProvider?.changeIsPumpDay(
        isRestDayForPastWeek ? !isRestDayForPastWeek : isPumpDay);

    if (isPumpDay) {
      final dataList = monthProvider?.dayHistoryModel
          .where((element) =>
              element.type?.contains("Pump Day") == true &&
              element.status != Status.empty)
          .toList();

      if (dataList!.isNotEmpty) {
        int index1 = monthProvider!.pumpDays.indexWhere((el1) => dataList.any(
            (e1) => (e1.dayId == dayId &&
                e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider?.updatePumpDayData(monthProvider!.pumpDays[index1]);
        } else {
          int index1 = monthProvider!.pumpDays.indexWhere((el1) => dataList.any(
              (e1) =>
                  e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
          monthProvider?.updatePumpDayData(monthProvider!.pumpDays[index == -1
              ? 0
              : index1 == 0
                  ? 1
                  : 0]);
        }
      } else {
        monthProvider?.updatePumpDayData(monthProvider!.pumpDays[0]);
      }
    }

    monthProvider?.overviewCurrentWeek = widget.weekIndex + 1;
    monthProvider?.overviewCurrentDay = index + 1;
    monthProvider?.dayDataModel = dayData;
    // monthProvider?.alternateEquipmentType = monthProvider!.equipmentType;
    monthProvider?.weekDataModel =
        widget.monthProvider!.weeksDataList[mainIndex!];
    monthProvider?.updateIsPastWeek(
        monthProvider!.weekStatuses[mainIndex!] == WeekType.pastWeek);

    final dayIndex = monthProvider!.overviewCurrentDay;
    int nextWorkOutIndex = monthProvider!.weekDataModel!.dayList![dayIndex - 1]
            .toString()
            .contains("Workout")
        ? int.parse(monthProvider!.weekDataModel!.dayList![dayIndex - 1]
                .toString()
                .replaceAll("Day ", "")
                .replaceAll(" Workout", "")) -
            1
        : 0;
    String currentDayTitle = monthProvider!
            .weekDataModel!.dayList![dayIndex - 1]
            .toString()
            .contains("Workout")
        ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider!.weekDataModel!.dayList![dayIndex - 1];

    final isCompletedOrSkipped = (monthProvider!.allSplitDayHistoryModel.any(
        (element) =>
            (element.status == Status.completed ||
                element.status == Status.skipped) &&
            element.dataId == dataId));

    if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider!.isPumpDay) &&
        isCompletedOrSkipped) {
      return;
    } else if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider!.isPumpDay) &&
        !isCompletedOrSkipped) {
      if (monthProvider?.weekStatuses[mainIndex!] != WeekType.currentWeek) {
        return;
      }
      AnimatedDialog.showAnimatedDialog(
        context: context,
        pageBuilder: (c1, anim1, anim2) => skipWorkoutDialog(context, c1),
      );
    } else {
      if (monthProvider!.isPumpDay) {
        if ((monthProvider!.allSplitDayHistoryModel.any((element) =>
                (element.status == Status.completed ||
                    element.status == Status.skipped) &&
                element.dataId == dataId)) ==
            false) {
          if (monthProvider?.isCurrentMonth == "Future") {
            _saveDayData(
                type: "Pump Day - ${monthProvider!.pumpDayModel?.id}",
                status: Status.started,
                title: monthProvider!.pumpDayModel?.title);
          }
          if (!context.mounted) return;
          await monthProvider?.fetchAllDayStatusLocalData();
          await Navigator.pushNamed(context, '/today').then(
            (value) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) async => await monthProvider?.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await monthProvider?.fetchAllDayStatusLocalData();
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider?.dayHistoryModel
                .any((element) => element.dataId == dataId)) ==
            false) {
          if (monthProvider?.isCurrentMonth == "Current") {
            _saveDayData(status: Status.started, type: 'Workout Day');
          }
        }
        if (!context.mounted) return;
        await monthProvider?.fetchAllDayStatusLocalData();
        await Navigator.pushNamed(context, '/today');
      }
    }

    // Navigator.pushNamed(context, '/dayOverview');
  }

  Widget skipWorkoutDialog(BuildContext context, BuildContext c1) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
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
                          "Rest Day",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: ScreenUtil.verticalScale(2.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(2),
                              vertical: ScreenUtil.verticalScale(1)),
                          child: Text(
                            "Would you like to mark today\nas a rest day?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: ScreenUtil.verticalScale(2),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                          child: Row(
                            children: [
                              // Expanded(
                              //   child: ElevatedButton(
                              //     onPressed: () async {
                              //       await _saveDayData(status: Status.skipped, type: 'Rest Day', endDate: true).then(
                              //         (value) {
                              //           monthProvider?.onInit(context, isEnabled: false);
                              //         },
                              //       );
                              //       if (!c1.mounted) return;
                              //       Navigator.of(c1).pop();
                              //       await monthProvider?.checkForPumpDay();
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(15),
                              //       ),
                              //       backgroundColor: AppColors.skipDayColor,
                              //       padding: EdgeInsets.symmetric(
                              //         vertical: ScreenUtil.verticalScale(1.7),
                              //       ),
                              //     ),
                              //     child: Text(
                              //       "Skip day",
                              //       style: TextStyle(
                              //         fontSize: ScreenUtil.verticalScale(2),
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.white,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: ScreenUtil.horizontalScale(3)),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _saveDayData(
                                            status: Status.completed,
                                            type: 'Rest Day',
                                            endDate: true)
                                        .then(
                                      (value) {
                                        monthProvider?.onInit(
                                            context: context, isEnabled: false);
                                      },
                                    );
                                    if (!c1.mounted) return;
                                    Navigator.of(c1).pop();
                                  },
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
                                    "Confirm",
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
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                    child: Icon(
                        size: ScreenUtil.verticalScale(2.5),
                        Icons.close,
                        color: Colors.white),
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

  deletePumpDayData() async {
    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";
    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";
    await DatabaseHelper()
        .deleteSingleData(id: dataId, tableName: DatabaseHelper.dayStatus);
    ApiRepo.deleteDayStatus(body: {
      "dateId": dataId,
      "dayId": monthProvider
          ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "weekId": monthProvider?.weekDataModel?.id,
      "monthId": monthProvider?.monthDataModel?.id,
    });

    await monthProvider?.fetchAllDayStatusLocalData();
    await monthProvider?.fetchDayStatusLocalData();
    await monthProvider?.checkForPumpDay();
    monthProvider?.findWeekStatuses();
    monthProvider?.fetchToday();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
    monthProvider?.fetchToday();
    // monthProvider?.filter();
  }

  Future<void> _saveDayData(
      {required String status,
      required String type,
      String? title,
      bool endDate = false}) async {
    if (monthProvider?.weekStatuses[mainIndex!] == WeekType.currentWeek &&
        monthProvider?.isCurrentMonth == "Current") {
      String split = monthProvider?.monthDataModel
              ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
              .toString()
              .split(" ")[1] ??
          "";
      DateTime nowUT = await NTP.now();
      String dataId =
          "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

      if (status == Status.completed) {
        ApiRepo.addDayStatusList(
            body: {"date": "${nowUT}", "status": Status.completed});
      }

      final data = {
        "title": title ?? "",
        "dataId": dataId,
        "monthId": monthProvider?.monthDataModel?.id,
        "weekId": monthProvider?.weekDataModel?.id,
        "dayId": monthProvider
            ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
        "split": split,
        "date": "${nowUT}",
        "status": status,
        "type": type,
        "startTime": "${nowUT}",
        "endTime": endDate ? "${nowUT}" : "",
      };

      DayHistoryModel? matchingElement = monthProvider?.dayHistoryModel
          .firstWhere((element) => element.dataId == dataId,
              orElse: () => DayHistoryModel());

      final data1 = {
        "title": title ?? "",
        "status": status,
        "type": type,
        "startTime": status == Status.empty
            ? ""
            : matchingElement?.startTime == null
                ? "${nowUT}"
                : matchingElement?.startTime.toString(),
        "endTime": (status == Status.completed)
            ? "${nowUT}"
            : (endDate ? "${nowUT}" : ""),
      };

      final apiBody = {
        "title": title ?? "",
        "status": status,
        "type": type,
        "startTime": status == Status.empty
            ? ""
            : matchingElement?.startTime == null
                ? "${nowUT}"
                : matchingElement?.startTime.toString(),
        "endTime": (status == Status.completed)
            ? "${nowUT}"
            : (endDate ? "${nowUT}" : ""),
        "dataId": dataId
      };

      if (matchingElement?.id != null) {
        ApiRepo.updateDayStatus(body: apiBody);

        await DatabaseHelper().updateData(
            tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
      } else {
        ApiRepo.addDayStatus(body: data);

        await DatabaseHelper()
            .insertData(data: data, tableName: DatabaseHelper.dayStatus);
      }
    }

    await monthProvider?.fetchAllDayStatusLocalData();

    monthProvider?.findWeekStatuses();
    monthProvider?.fetchToday();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }
}
