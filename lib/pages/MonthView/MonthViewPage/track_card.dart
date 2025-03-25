import 'package:bbb/components/expansion_panel.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:google_fonts/google_fonts.dart';
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
    _isExpanded = (mainIndex! + 1) == monthProvider?.week ? true : false;
    dayDataList = weekDataModel!.days!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthProvider>(
      builder: (context, monthProvider, child) {
        return Container(
          child: monthProvider.weekStatuses.isEmpty ? SizedBox() : filterViewList(monthProvider),
        );
      },
    );
  }

  Widget filterViewList(MonthProvider monthProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Theme(
            data: ThemeData().copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
              child: ExpansionPanelList(
                animationDuration: Duration(milliseconds: 300),
                expandIconColor: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : AppColors.primaryColor,
                materialGapSize: 10,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (panelIndex, isExpanded) {
                  setState(() {
                    _isExpanded = isExpanded;
                    curExpandedIdx = isExpanded ? 0 : -1;
                  });
                },
                elevation: 1,
                children: [expansionPanel(monthProvider)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanel expansionPanel(MonthProvider monthProvider) {
    return ExpansionPanel(
      highlightColor: monthProvider.weekStatuses[mainIndex!] != WeekType.pastWeek ? Colors.white : AppColors.primaryColor,
      isExpanded: _isExpanded,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(5),
            vertical: ScreenUtil.verticalScale(0.5),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title != "" ? widget.title : "Week",
                  style: GoogleFonts.plusJakartaSans(
                    color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : AppColors.primaryColor,
                    fontSize: ScreenUtil.verticalScale(2),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(width: ScreenUtil.verticalScale(3)),
              if (!_isExpanded)
                Builder(
                  builder: (context) {
                    String split = monthProvider.monthDataModel?.weeks?[mainIndex!].idList?.first.toString().split(" ")[1] ?? "";
                    return Text(
                      '${split.toString().replaceAll("split", "")} workouts',
                      style: GoogleFonts.plusJakartaSans(
                        color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : Colors.black38,
                        fontSize: ScreenUtil.verticalScale(1.5),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              const SizedBox(width: 3),
            ],
          ),
        );
      },
      backgroundColor: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? AppColors.primaryColor : Colors.grey[100],
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil.horizontalScale(3.8),
          vertical: ScreenUtil.verticalScale(0.5),
        ),
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
                    weekDataModel?.description?.trim() ?? "",
                    style: TextStyle(
                        fontSize: ScreenUtil.verticalScale(1.7),
                        color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : const Color(0xFF888888)),
                  ),
                  SizedBox(
                    height: ScreenUtil.verticalScale(weekDataModel!.description!.isEmpty ? 0 : 3),
                  ),
                  ListView.builder(
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
                      DayDataModel dayData =
                          weekDataModel!.dayList![index].toString().contains("Workout") ? dayDataList[dayIndex] : DayDataModel();
                      bool isRestDay = weekDataModel?.dayList?[index].contains("Rest Day");

                      final exerciseDetails = isRestDay ? null : dayData.exercises!;

                      int? exerciseCount = 0;
                      if (exerciseDetails != null && monthProvider.allRemovedExercise.isNotEmpty) {
                        String split = monthProvider.monthDataModel?.weeks?[mainIndex!].idList?.first.toString().split(" ")[1] ?? "";

                        String dataId1 =
                            "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].id}-${monthProvider.monthDataModel?.weeks?[mainIndex!].idList![index]}";

                        List<String> matchingExerciseIds = monthProvider.allRemovedExercise
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

                      String split = monthProvider.monthDataModel?.weeks?[mainIndex!].idList?.first.toString().split(" ")[1] ?? "";

                      String dataId =
                          "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel!.weeks![mainIndex!].id}-${weekDataModel!.idList![index]}";

                      int nextWorkOutIndex = weekDataModel!.dayList![index].toString().contains("Workout")
                          ? int.parse(weekDataModel!.dayList![index].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
                          : 0;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              if (index != 0)
                                DottedDashedLine(
                                  height: 15,
                                  width: 0,
                                  dashColor: Colors.grey.withValues(alpha: 0.5),
                                  axis: Axis.vertical,
                                )
                              else
                                const SizedBox(
                                  height: 15,
                                ),
                              Consumer<MonthProvider>(
                                builder: (context, value, child) {
                                  return (value.weekStatuses[mainIndex!] == WeekType.pastWeek && value.allSplitDayHistoryModel.isEmpty) ||
                                          value.allSplitDayHistoryModel
                                              .any((element) => element.status == Status.skipped && element.dataId == dataId)
                                      ? skipped()
                                      : value.weekStatuses[mainIndex!] == WeekType.futureWeek
                                          ? future()
                                          : value.allSplitDayHistoryModel
                                                  .any((element) => element.status == Status.completed && element.dataId == dataId)
                                              ? completed()
                                              : value.weekStatuses[mainIndex!] == WeekType.currentWeek
                                                  ? value.todayTitleId == (value.monthDataModel!.weeks![mainIndex!].idList?[index])
                                                      ? today()
                                                      : nonToday()
                                                  : skipped();
                                },
                              ),
                              if (index != 6)
                                DottedDashedLine(
                                  height: 15,
                                  width: 0,
                                  dashColor: Colors.grey.withValues(alpha: 0.5),
                                  axis: Axis.vertical,
                                )
                              else
                                const SizedBox(
                                  height: 15,
                                )
                            ],
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: InkWell(
                                onTap: monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek
                                    ? null
                                    : () => continueWorkoutOnTap(
                                        isRestDay, dataId, index, dayData, context, mainIndex!, weekDataModel!.idList![index]),
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
                                              DayHistoryModel? matchingElement = monthProvider.allDayHistoryModel.firstWhere(
                                                (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                                orElse: () => DayHistoryModel(),
                                              );

                                              return isRestPumpOption(isRestDay, monthProvider, dataId)
                                                  ? pumpRestSelection(
                                                      index, dayData, context, weekDataModel!.idList![index], dataId, monthProvider)
                                                  : Text(
                                                      !isRestDay
                                                          ? weekDataModel!.days![nextWorkOutIndex].title
                                                          : (matchingElement.type ?? "").contains("Pump Day")
                                                              ? matchingElement.title
                                                              : weekDataModel!.dayList![index],
                                                      style: TextStyle(
                                                          color: monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek
                                                              ? Colors.white
                                                              : AppColors.primaryColor,
                                                          fontSize: ScreenUtil.verticalScale(2),
                                                          fontWeight: FontWeight.bold,
                                                          height: 1),
                                                    );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (!isRestDay) ...[
                                          Text(
                                            exerciseCount! > 1 ? '$exerciseCount Exercises' : " $exerciseCount Exercise",
                                            style: TextStyle(
                                              fontSize: ScreenUtil.verticalScale(1.4),
                                              color:
                                                  monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek ? Colors.white : Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    Builder(builder: (context) {
                                      DayHistoryModel? matchingElement = monthProvider.allDayHistoryModel.firstWhere(
                                        (element) => element.dataId == dataId && element.type!.contains("Pump Day"),
                                        orElse: () => DayHistoryModel(),
                                      );
                                      return monthProvider.weekStatuses[mainIndex!] == WeekType.futureWeek ||
                                              (!isRestPumpOption(isRestDay, monthProvider, dataId) &&
                                                  isRestDay &&
                                                  !(matchingElement.type ?? "").contains("Pump Day"))
                                          ? SizedBox()
                                          : Container(
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
                                            );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isRestPumpOption(bool isRestDay, MonthProvider monthProvider, String dataId) {
    return (isRestDay && monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek && monthProvider.isPumpDayAvailable) &&
            (monthProvider.allDayHistoryModel.any(
                    (element) => (element.status != Status.skipped && element.status != Status.completed && (dataId == element.dataId))) ||
                (!monthProvider.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId))) ||
        (isRestDay && monthProvider.weekStatuses[mainIndex!] == WeekType.currentWeek) &&
            (monthProvider.allDayHistoryModel.any((element) => ((element.status == Status.started) && dataId == element.dataId)));
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
    monthProvider?.alternateEquipmentType = monthProvider!.equipmentType;
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
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (c1) {
          return skipWorkoutDialog(context, c1);
        },
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

  Widget pumpRestSelection(
    int index,
    DayDataModel dayData,
    BuildContext context,
    String dayId,
    String dataId,
    MonthProvider monthProvider,
  ) {
    return Row(
      children: [
        GestureDetector(
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
            monthProvider.alternateEquipmentType = monthProvider.equipmentType;
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
          child: Container(
            width: 85,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.9)),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: AppColors.primaryColor),
            child: Center(
              child: Text(
                "Pump Day",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.5),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.verticalScale(1),
          ),
          child: Text(
            "Or",
            style: TextStyle(
              fontSize: ScreenUtil.verticalScale(1.4),
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            monthProvider.changeIsPumpDay(false);
            monthProvider.overviewCurrentWeek = widget.weekIndex + 1;
            monthProvider.overviewCurrentDay = index + 1;
            monthProvider.dayDataModel = dayData;
            monthProvider.alternateEquipmentType = monthProvider.equipmentType;
            monthProvider.weekDataModel = weekDataModel;
            monthProvider.updateIsPastWeek(monthProvider.weekStatuses[mainIndex!] == WeekType.pastWeek);
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (c1) {
                return skipWorkoutDialog(context, c1);
              },
            );
          },
          child: Container(
            width: 90,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.9)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                "Rest Day",
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.5),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
                        "Would you like to mark the rest day complete or skip?",
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
                                await _saveDayData(status: Status.skipped, type: 'Rest Day', endDate: true).then(
                                  (value) {
                                    monthProvider?.onInit(isEnabled: false);
                                  },
                                );
                                if (!c1.mounted) return;
                                Navigator.of(c1).pop();
                                await monthProvider?.checkForPumpDay();
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
                                "Skip day",
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(2),
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
                                await _saveDayData(status: Status.completed, type: 'Rest Day', endDate: true).then(
                                  (value) {
                                    monthProvider?.onInit(isEnabled: false);
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
                                "Mark complete",
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

  today() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  nonToday() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  skipped() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.close, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  completed() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  future() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        height: ScreenUtil.verticalScale(3.4),
        width: ScreenUtil.verticalScale(3.4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.hourglass_top, color: Colors.black38, size: 20)),
      ),
    );
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

    DayHistoryModel? matchingElement = monthProvider?.dayHistoryModel.firstWhere(
      (element) => element.dataId == dataId,
      orElse: () => DayHistoryModel(),
    );

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
