import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/expansion_panel.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
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
  WeekDataModel? weekDataModel;
  List<DayDataModel> dayDataList = [];
  int curExpandedIdx = 0;
  bool ischecked = false;
  bool _isExpanded = false;
  bool thisWeek = false;
  List<String> dayTitles = [];

  @override
  void initState() {
    super.initState();
    monthProvider = widget.monthProvider;
    mainIndex = widget.index;
    weekDataModel = widget.monthProvider?.weeksDataList[mainIndex!];
    thisWeek = ((mainIndex! + 1) == monthProvider?.week);
    // _isExpanded = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (monthProvider!.isCurrentMonth == "Current") {
        if ((mainIndex! + 1) == monthProvider?.week ? true : false) {
          monthProvider!.updateWeekExpandedHeight((monthProvider!.isCurrentMonth == "Current") ? 84 : 0);
        }
        await Future.delayed(Duration.zero).then(
          (value) => _isExpanded = (mainIndex! + 1) == monthProvider?.week ? true : false,
        );
      }
    });

    dayDataList = weekDataModel!.days!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthProvider>(
      builder: (context, monthProvider, child) {
        return Container(
          child: monthProvider.weekStatuses.isEmpty ? SizedBox() : filterViewList1(monthProvider),
        );
      },
    );
  }

  Widget filterViewList1(MonthProvider monthProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Theme(
            data: ThemeData().copyWith(
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
                    monthProvider.updateWeekExpandedHeight(monthProvider.weekExpandedHeight + 84);
                    await Future.delayed(Duration(milliseconds: 100)).then(
                      (value) {
                        _isExpanded = isExpanded;
                        curExpandedIdx = isExpanded ? 0 : -1;
                        setState(() {});
                      },
                    );
                  } else {
                    _isExpanded = isExpanded;
                    curExpandedIdx = isExpanded ? 0 : -1;
                    setState(() {});
                    await Future.delayed(Duration(milliseconds: 310)).then(
                      (value) => monthProvider.updateWeekExpandedHeight(monthProvider.weekExpandedHeight - 84),
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
      isExpanded: _isExpanded,
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
                    widget.title != "" ? (widget.title.toString().toLowerCase().capitalizeFirst()) : "Week",
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
                      padding: EdgeInsets.only(top: ScreenUtil.verticalScale(2)),
                      child: Container(
                        decoration: BoxDecoration(
                          border: DashedBorder(
                            spaceLength: 8,
                            strokeCap: StrokeCap.square,
                            dashLength: 1,
                            top: BorderSide(color: Colors.grey.shade400, width: 1.5),
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: ScreenUtil.verticalScale(1)),
          ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: ScreenUtil.verticalScale(1)),
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: weekDataModel!.dayList!.length,
            itemBuilder: (context, index) {
              final dayIndex = int.parse(weekDataModel!.dayList![index]
                      .toString()
                      .replaceAll("Workout", "")
                      .replaceAll("Rest", "")
                      .replaceAll("Day", "")
                      .replaceAll(" ", "")) -
                  1;

              DayDataModel dayData = weekDataModel!.dayList![index].toString().contains("Workout") ? dayDataList[dayIndex] : DayDataModel();
              bool isRestDay = weekDataModel?.dayList?[index].contains("Rest Day");

              final exerciseDetails = isRestDay ? null : dayData.exercises!;

              int? exerciseCount = 0;
              if (exerciseDetails != null && monthProvider.allRemovedExercise.isNotEmpty) {
                String split = monthProvider.monthDataModel?.weeks?[mainIndex!].idList?.first.toString().split(" ")[1] ?? "";

                String dataId1 =
                    "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].idList![index]}";

                List<String> matchingExerciseIds =
                    monthProvider.allRemovedExercise.where((entry) => entry.dataId == dataId1).map((entry) => entry.exerciseId!).toList();
                exerciseCount = exerciseDetails.where(
                  (element) {
                    return !matchingExerciseIds.contains(element.exerciseId);
                  },
                ).length;
              } else {
                exerciseCount = exerciseDetails?.length;
              }

              String split = monthProvider.monthDataModel?.weeks?[mainIndex!].idList?.first.toString().split(" ")[1] ?? "";

              String dataId =
                  "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel!.weeks![mainIndex!].id}-${weekDataModel!.idList![index]}";

              int nextWorkOutIndex = weekDataModel!.dayList![index].toString().contains("Workout")
                  ? int.parse(weekDataModel!.dayList![index].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
                  : 0;
              return weekDataModel!.dayList![index].toString().contains("Workout")
                  ? workoutday(monthProvider, isRestDay, dataId, index, dayData, context, nextWorkOutIndex, exerciseCount)
                  : isRestPumpOption(isRestDay, monthProvider, dataId) &&
                          monthProvider.isPumpDayAvailable &&
                          (monthProvider.allSplitDayHistoryModel.where((e) => e.dataId == dataId).isEmpty)
                      ? selection(monthProvider, index, dayData, context, weekDataModel!.idList![index], dataId)
                      : pumpDayRestday(monthProvider, dataId, index, isRestDay, dayData);
            },
          ),
          SizedBox(height: ScreenUtil.verticalScale(1)),
        ],
      ),
    );
  }

  Widget workoutday(MonthProvider monthProvider, bool isRestDay, String dataId, int index, DayDataModel dayData, BuildContext context,
      int nextWorkOutIndex, int? exerciseCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
          color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/ Colors.grey[50],
          borderRadius: BorderRadius.circular(
            ScreenUtil.verticalScale(1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: ScreenUtil.verticalScale(7.8),
              width: ScreenUtil.verticalScale(7.8),
              margin: EdgeInsets.all(ScreenUtil.verticalScale(1)),
              decoration: BoxDecoration(
                color: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                    ? AppColors.greyColor
                    : (monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek && monthProvider.allSplitDayHistoryModel.isEmpty) ||
                            monthProvider.allSplitDayHistoryModel.any((e) => e.status == Status.skipped && e.dataId == dataId)
                        ? AppColors.skipDayColor
                        : monthProvider.allSplitDayHistoryModel.any((e) => e.status == Status.completed && e.dataId == dataId)
                            ? Colors.green
                            : monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek
                                ? AppColors.greyColor
                                : AppColors.skipDayColor,
                borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(1)),
              ),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
                child: Center(
                  child: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                      ? Icon(Icons.hourglass_top, color: Colors.black, size: 25)
                      : monthProvider.allSplitDayHistoryModel.any((e) => (e.status == Status.completed) && e.dataId == dataId)
                          ? Icon(
                              Icons.check,
                              size: 25,
                              color: Colors.white,
                            )
                          : monthProvider.allSplitDayHistoryModel.any((e) => (e.status == Status.skipped) && e.dataId == dataId) ||
                                  monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek
                              ? Icon(
                                  Icons.close,
                                  size: 25,
                                  color: Colors.white,
                                )
                              : Image.asset(
                                  "assets/img/workoutday.png",
                                  color: Colors.black,
                                ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: SizedBox(
                height: 60,
                child: InkWell(
                  onTap: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                      ? null
                      : () => continueWorkoutOnTap(isRestDay, dataId, index, dayData, context, mainIndex!, weekDataModel!.idList![index]),
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
                                  "${weekDataModel!.days![nextWorkOutIndex].title}",
                                  style: TextStyle(
                                      color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/ Colors.black,
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
                              int exCount = weekDataModel!.days![nextWorkOutIndex].exercises!
                                  .where((element) =>
                                      (element.formats!.contains(monthProvider.equipmentType) || element.isAddedUpdated == true))
                                  .toList()
                                  .length;

                              return Text(
                                exCount > 1 ? '$exCount Exercises' : " $exCount Exercise",
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.4),
                                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/ Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
                      Spacer(),
                      monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.verticalScale(1.2),
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
                                color: AppColors.blackColor,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget selection(MonthProvider monthProvider, int index, DayDataModel dayData, BuildContext context, String dayId, String dataId) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              monthProvider.changeIsPumpDay(true);

              final dataList = monthProvider.dayHistoryModel
                  .where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty)
                  .toList();

              if (dataList.isNotEmpty) {
                int index1 = monthProvider.pumpDays.indexWhere(
                    (el1) => dataList.any((e1) => (e1.dayId == dayId && e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
                if (index1 != -1) {
                  monthProvider.updatePumpDayData(monthProvider.pumpDays[index1]);
                } else {
                  int index1 = monthProvider.pumpDays
                      .indexWhere((el1) => dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
                  monthProvider.updatePumpDayData(monthProvider.pumpDays[index == -1
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
              monthProvider.weekDataModel = weekDataModel;
              monthProvider.updateIsPastWeek(monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek);

              if ((monthProvider.allSplitDayHistoryModel.any(
                      (element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId)) ==
                  false) {
                _saveDayData(
                  type: "Pump Day - ${monthProvider.pumpDayModel?.id}",
                  status: Status.started,
                  title: monthProvider.pumpDayModel?.title,
                );
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

              // await Navigator.pushNamed(context, '/dayOverview');
            },
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil.horizontalScale(6)),
              child: Container(
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/ Colors.grey[50],
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Container(
                      height: ScreenUtil.verticalScale(7.8),
                      // width: ScreenUtil.verticalScale(7.8),
                      margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(1)),
                      decoration: BoxDecoration(
                        color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.backOffSetColor :*/
                            AppColors.greyColor,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil.verticalScale(1),
                        ),
                      ),
                      child: Image.asset(
                        height: ScreenUtil.verticalScale(4),
                        width: ScreenUtil.verticalScale(4),
                        "assets/img/pumpday.png",
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "Pump Day",
                      style: TextStyle(
                          color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/ Colors.black,
                          fontSize: ScreenUtil.verticalScale(1.5),
                          fontWeight: FontWeight.bold,
                          height: 1),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 10),
          child: Center(child: Text("or", style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (monthProvider.weekStatuses[mainIndex!] != WeekType.currentWeek) return;
              monthProvider.changeIsPumpDay(false);
              monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
              monthProvider.overviewCurrentDay = index + 1;
              monthProvider.dayDataModel = dayData;
              // monthProvider.alternateEquipmentType = monthProvider.equipmentType;
              monthProvider.weekDataModel = weekDataModel;
              monthProvider.updateIsPastWeek(monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek);
              AnimatedDialog.showAnimatedDialog(
                context: context,
                pageBuilder: (c1, anim1, anim2) => skipWorkoutDialog(context, c1),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: ScreenUtil.horizontalScale(6)),
              child: Container(
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/ Colors.grey[50],
                  borderRadius: BorderRadius.circular(
                    ScreenUtil.verticalScale(1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Container(
                      height: ScreenUtil.verticalScale(7.8),
                      // width: ScreenUtil.verticalScale(7.8),
                      margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(1)),
                      decoration: BoxDecoration(
                        color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.backOffSetColor :*/
                            AppColors.greyColor,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil.verticalScale(1),
                        ),
                      ),
                      child: Container(
                        // color: Colors.red,
                        child: Image.asset(
                          height: ScreenUtil.verticalScale(4),
                          width: ScreenUtil.verticalScale(4),
                          "assets/img/restday.png",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "Rest Day",
                      style: TextStyle(
                          color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/ Colors.black,
                          fontSize: ScreenUtil.verticalScale(1.5),
                          fontWeight: FontWeight.bold,
                          height: 1),
                    ),
                    // SizedBox(
                    //   width: 6,
                    // ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget pumpDayRestday(MonthProvider monthProvider, String dataId, int index, bool isRestDay, DayDataModel dayData) {
    return Builder(builder: (context) {
      DayHistoryModel? matchingElement = monthProvider.allDayHistoryModel
          .firstWhere((element) => element.dataId == dataId && element.type!.contains("Pump Day"), orElse: () => DayHistoryModel());

      return Slidable(
        enabled: (matchingElement.type ?? "").contains("Pump Day") &&
            monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek &&
            ((monthProvider.allSplitDayHistoryModel
                    .any((e) => (e.status == Status.completed || e.status == Status.skipped) && e.dataId == dataId) ==
                false)),
        endActionPane: ActionPane(
          extentRatio: 0.22,
          motion: const ScrollMotion(),
          children: [
            Container(
              color: Colors.white,
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
                            if (monthProvider.weekStatuses[mainIndex!] != WeekType.currentWeek) return;
                            await Future.delayed(Duration(milliseconds: 300)).then(
                              (v) async {
                                monthProvider.changeIsPumpDay(false);
                                monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
                                monthProvider.overviewCurrentDay = index + 1;
                                monthProvider.dayDataModel = dayData;
                                monthProvider.weekDataModel = weekDataModel;
                                await deletePumpDayData();
                              },
                            );
                          },
                          icon: Icons.swap_horiz,
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(0),
                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
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
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
          child: Container(
            margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.1)),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 0.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
              color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor :*/ Colors.grey[50],
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: ScreenUtil.verticalScale(7.8),
                  width: ScreenUtil.verticalScale(7.8),
                  margin: EdgeInsets.all(ScreenUtil.verticalScale(1)),
                  decoration: BoxDecoration(
                    color: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                        ? AppColors.greyColor
                        : (monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek && monthProvider.allSplitDayHistoryModel.isEmpty) ||
                                monthProvider.allSplitDayHistoryModel.any((e) => e.status == Status.skipped && e.dataId == dataId)
                            ? AppColors.skipDayColor
                            : monthProvider.allSplitDayHistoryModel.any((e) => e.status == Status.completed && e.dataId == dataId)
                                ? Colors.green
                                : monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek
                                    ? AppColors.greyColor
                                    : AppColors.skipDayColor,
                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
                    child: Center(
                      child: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                          ? Icon(Icons.hourglass_top, color: Colors.black, size: 25)
                          : monthProvider.allSplitDayHistoryModel.any((e) => (e.status == Status.completed) && e.dataId == dataId)
                              ? Icon(
                                  Icons.check,
                                  size: 25,
                                  color: Colors.white,
                                )
                              : monthProvider.allSplitDayHistoryModel.any((e) => (e.status == Status.skipped) && e.dataId == dataId) ||
                                      monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek
                                  ? Icon(
                                      Icons.close,
                                      size: 25,
                                      color: Colors.white,
                                    )
                                  : Image.asset(
                                      (matchingElement.type ?? "").contains("Pump Day")
                                          ? "assets/img/pumpday.png"
                                          : "assets/img/restday.png",
                                      color: Colors.black,
                                    ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: InkWell(
                      onTap: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                          ? null
                          : () =>
                              continueWorkoutOnTap(isRestDay, dataId, index, dayData, context, mainIndex!, weekDataModel!.idList![index]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(builder: (context) {
                            return Text(
                              (matchingElement.type ?? "").contains("Pump Day")
                                  ? "${matchingElement.title}"
                                  : weekDataModel!
                                      .restDayList?[int.parse(weekDataModel!.dayList![index].toString().split(" ").toList().last) - 1],
                              style: TextStyle(
                                  color: /*monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white :*/ Colors.black,
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            );
                          }),
                          Spacer(),
                          monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek &&
                                  (matchingElement.type ?? "").contains("Pump Day")
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.verticalScale(1.2),
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
                                    color: AppColors.blackColor,
                                    size: ScreenUtil.verticalScale(3),
                                  ),
                                ) /*Theme(
                                  data: ThemeData(popupMenuTheme: PopupMenuThemeData(color: Colors.white)),
                                  child: PopupMenuButton(
                                    icon: Icon(
                                      Icons.more_horiz,
                                      color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : Colors.black,
                                    ),
                                    itemBuilder: (context) {
                                      return [
                                        if (monthProvider.allSplitDayHistoryModel.any(
                                                (e) => (e.status != Status.skipped && e.status != Status.completed) && e.dataId == dataId) ||
                                            monthProvider.allSplitDayHistoryModel.where((e) => e.dataId == dataId).isEmpty) ...[
                                          PopupMenuItem(
                                            child: Text("Mark Skip"),
                                          ),
                                          PopupMenuItem(
                                            child: Text("Mark Complete"),
                                          ),
                                          PopupMenuItem(
                                            onTap: () async {
                                              if (monthProvider.weekStatuses[mainIndex!] != WeekType.currentWeek) return;
                                              await Future.delayed(Duration(milliseconds: 300)).then(
                                                (v) async {
                                                  monthProvider.changeIsPumpDay(false);
                                                  monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
                                                  monthProvider.overviewCurrentDay = index + 1;
                                                  monthProvider.dayDataModel = dayData;
                                                  monthProvider.weekDataModel = weekDataModel;
                                                  await deletePumpDayData();
                                                },
                                              );
                                            },
                                            child: Text("Swap to Rest Day"),
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  bool isRestPumpOption(bool isRestDay, MonthProvider monthProvider, String dataId) {
    return ((isRestDay && monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek && monthProvider.isPumpDayAvailable) &&
            (monthProvider.allDayHistoryModel.any(
                    (element) => (element.status != Status.skipped && element.status != Status.completed && (dataId == element.dataId))) ||
                (!monthProvider.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId)))) ||
        ((isRestDay && monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek) &&
            (monthProvider.allDayHistoryModel.any((element) => ((element.status == Status.started) && dataId == element.dataId))));
  }

  Future<void> continueWorkoutOnTap(
      bool isRestDay, String dataId, int index, DayDataModel dayData, BuildContext context, int weekIndex, String dayId) async {
    DayHistoryModel? matchingElement = monthProvider!.allDayHistoryModel
        .firstWhere((element) => element.dataId == dataId && element.type!.contains("Pump Day"), orElse: () => DayHistoryModel());

    bool isRestDayForPastWeek =
        monthProvider!.weekStatuses[mainIndex!] == WeekType.pastWeek && (!(matchingElement.title ?? "").contains("Pump Day"));
    bool isPumpDay = (isRestDay &&
            monthProvider!.allDayHistoryModel.any((element) => element.dataId == dataId && element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allDayHistoryModel.any((element) => element.dataId == dataId && element.type != "Rest Day"))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allDayHistoryModel
                .any((element) => element.dataId == dataId && element.type == "Rest Day" && element.status == ""))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (!monthProvider!.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId)));

    monthProvider?.changeIsPumpDay(isRestDayForPastWeek ? !isRestDayForPastWeek : isPumpDay);

    if (isPumpDay) {
      final dataList = monthProvider?.dayHistoryModel
          .where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty)
          .toList();

      if (dataList!.isNotEmpty) {
        int index1 = monthProvider!.pumpDays
            .indexWhere((el1) => dataList.any((e1) => (e1.dayId == dayId && e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider?.updatePumpDayData(monthProvider!.pumpDays[index1]);
        } else {
          int index1 =
              monthProvider!.pumpDays.indexWhere((el1) => dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
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
    monthProvider?.weekDataModel = weekDataModel;
    monthProvider?.updateIsPastWeek(monthProvider!.weekStatuses[mainIndex!] == WeekType.pastWeek);

    final dayIndex = monthProvider!.overviewCurrentDay;
    int nextWorkOutIndex = monthProvider!.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? int.parse(monthProvider!.weekDataModel!.dayList![dayIndex - 1].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
        : 0;
    String currentDayTitle = monthProvider!.weekDataModel!.dayList![dayIndex - 1].toString().contains("Workout")
        ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider!.weekDataModel!.dayList![dayIndex - 1];

    final isCompletedOrSkipped = (monthProvider!.allSplitDayHistoryModel
        .any((element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId));

    if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay) && isCompletedOrSkipped) {
      return;
    } else if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay) && !isCompletedOrSkipped) {
      if (monthProvider?.weekStatuses[mainIndex!] != WeekType.currentWeek) return;
      AnimatedDialog.showAnimatedDialog(
        context: context,
        pageBuilder: (c1, anim1, anim2) => skipWorkoutDialog(context, c1),
      );
    } else {
      if (monthProvider!.isPumpDay) {
        if ((monthProvider!.allSplitDayHistoryModel
                .any((element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId)) ==
            false) {
          _saveDayData(
              type: "Pump Day - ${monthProvider!.pumpDayModel?.id}", status: Status.started, title: monthProvider!.pumpDayModel?.title);
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today').then(
            (value) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await monthProvider?.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider?.dayHistoryModel.any((element) => element.dataId == dataId)) == false) {
          _saveDayData(status: Status.started, type: 'Workout Day');
        }
        if (!context.mounted) return;
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
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFFFFFF),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)).copyWith(top: ScreenUtil.verticalScale(2.5)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ScreenUtil.verticalScale(2)),
                    Text(
                      "Rest Day",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil.verticalScale(2.4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(1)),
                      child: Text(
                        "Would you like to choose today as a\nrest day?",
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
                                await _saveDayData(status: Status.completed, type: 'Rest Day', endDate: true).then(
                                  (value) {
                                    monthProvider?.onInit(context: context, isEnabled: false);
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
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(c1).pop();
                      },
                    ),
                    SizedBox(width: ScreenUtil.horizontalScale(2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  deletePumpDayData() async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";
    await DatabaseHelper().deleteSingleData(id: dataId, tableName: DatabaseHelper.dayStatus);
    ApiRepo.deleteDayStatus(body: {
      "dateId": dataId,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
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

  Future<void> _saveDayData({required String status, required String type, String? title, bool endDate = false}) async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    if (status == Status.completed) {
      ApiRepo.addDayStatusList(body: {"date": "${DateTime.now().toUtc()}", "status": Status.completed});
    }

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
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": endDate ? "${DateTime.now().toUtc()}" : "",
    };

    DayHistoryModel? matchingElement =
        monthProvider?.dayHistoryModel.firstWhere((element) => element.dataId == dataId, orElse: () => DayHistoryModel());

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : (endDate ? "${DateTime.now().toUtc()}" : ""),
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
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : (endDate ? "${DateTime.now().toUtc()}" : ""),
      "dataId": dataId
    };

    if (matchingElement?.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);

      await DatabaseHelper().updateData(tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);

      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider?.fetchAllDayStatusLocalData();

    monthProvider?.findWeekStatuses();
    monthProvider?.fetchToday();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }
}
