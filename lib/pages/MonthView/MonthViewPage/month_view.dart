import 'dart:developer';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/month_view_setting_dialog.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/IntroScreen/video_intro_page.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/information_section.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/setting_section.dart';
import 'package:bbb/providers/date_notifier.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/providers/scroll_provider.dart';
import 'package:bbb/routes/fade_page_route.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'sections/schedule_section.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  MonthProvider? monthProvider;
  ScrollProvider? scrollProvider;
  final DateStreamNotifier _dateNotifier = DateStreamNotifier();
  DateTime _currentDate = DateTime.now();
  late ProgramInfoProvider provider;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    scrollProvider = Provider.of<ScrollProvider>(context, listen: false);
    provider = context.read<ProgramInfoProvider>();
    provider.getProgramInfo(context);

    monthProvider?.mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    _dateNotifier.stream.listen((newDate) {
      if (_currentDate.day != newDate.day) {
        setState(() {
          _currentDate = newDate;
          monthProvider?.onInit(context, isEnabled: false);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToMiddle();
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        String monthId = preferences.getString(SharedPreference.monthSettingDone) ?? "";

        monthProvider?.monthLocalDataModel.sort((a, b) =>
            DateTime.parse(b.monthStartDate ?? "${DateTime.now()}").compareTo(DateTime.parse(a.monthStartDate ?? "${DateTime.now()}")));
        bool alreadySetUp = (monthId == (monthProvider!.monthDataModel?.id ?? ""));
        if (!alreadySetUp && monthProvider!.isOnMonthPage) {
          openSettingDialog();
        }
      },
    );

    super.initState();
  }

  void scrollToMiddle() {
    if (monthProvider!.scrollToRestDay) {
      final middleOffset = scrollController.position.maxScrollExtent /
          ((monthProvider?.week) == 1
              ? 1.66
              : (monthProvider?.week) == 2
                  ? 1.51
                  : (monthProvider?.week) == 3
                      ? 1.37
                      : 1.255);
      scrollController.animateTo(
        middleOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  openSettingDialog() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => AnimatedDialog.showAnimatedDialog(
        context: context, pageBuilder: (c1, anim1, anim2) => MonthSettingDialog(monthProvider: monthProvider!)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        monthProvider?.updateSelectedSection(0);
        monthProvider?.updateIsOnMonthPage(false);
        monthProvider?.updateScrollToRestDay(false);
      },
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          WidgetsBinding.instance.scheduleFrameCallback(
            (timeStamp) {
              scrollProvider?.updateOffSet1(notification.metrics.pixels);
            },
          );
          return true;
        },
        child: Stack(
          children: [
            Consumer<ScrollProvider>(builder: (context, scrollProvider, child) {
              return Opacity(
                opacity: scrollProvider.scrollOffset1 <= 0.0 ? 1 : 0,
                child: Container(
                  height: media.height / 1,
                  width: media.width,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/img/back.jpg'),
                      fit: BoxFit.cover,
                      opacity: 1,
                    ),
                  ),
                ),
              );
            }),
            Consumer<ScrollProvider>(
              builder: (context, scrollProvider, child) {
                return scrollProvider.scrollOffset1 <= 0.0
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: media.height / 2,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Consumer<ScrollProvider>(
                                  builder: (context, scrollProvider, child) {
                                    return AppBar(
                                      toolbarHeight: ScreenUtil.verticalScale(5.1),
                                      surfaceTintColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      centerTitle: true,
                                      leading: BackArrowWidget(
                                        onPress: () {
                                          monthProvider?.mainPageProvider.changeTab(0);
                                        },
                                      ),
                                      actions: [
                                        Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: const CommonStreakWithNotification(routeString: "month"))
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox();
              },
            ),
            RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async => await monthProvider?.onInit(context, isEnabled: false),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                controller: scrollController,
                physics: BouncingScrollPhysics(),
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
                                    opacity: scrollProvider.scrollOffset1 > 0.0 ? 1 : 0,
                                    child: Container(
                                      height: media.height / 1,
                                      width: media.width,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        image: DecorationImage(image: AssetImage('assets/img/back.jpg'), fit: BoxFit.cover, opacity: 1),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SafeArea(
                                child: Column(
                                  children: [
                                    Consumer<ScrollProvider>(
                                      builder: (context, scrollProvider, child) {
                                        return Column(
                                          children: [
                                            scrollProvider.scrollOffset1 >= 0.0
                                                ? AppBar(
                                                    toolbarHeight: ScreenUtil.verticalScale(5.1),
                                                    surfaceTintColor: Colors.transparent,
                                                    backgroundColor: Colors.transparent,
                                                    leading: BackArrowWidget(
                                                      onPress: () {
                                                        monthProvider?.mainPageProvider.changeTab(0);
                                                      },
                                                    ),
                                                    actions: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 10),
                                                        child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
                                                      )
                                                    ],
                                                  )
                                                : SizedBox(),
                                            SizedBox(
                                              height: scrollProvider.scrollOffset1 >= 0.0 ? 0 : ScreenUtil.verticalScale(5.1),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SafeArea(
                                    child: Consumer<MonthProvider>(
                                      builder: (context, monthProvider, child) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: ScreenUtil.verticalScale(6),
                                            ),
                                            Column(
                                              children: [
                                                monthProvider.startTime != null && monthProvider.endTime != null
                                                    ? Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            monthProvider.startTime == null || monthProvider.startTime.toString() == ""
                                                                ? ""
                                                                : DateFormat('MM/dd').format(monthProvider.startTime!),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: ScreenUtil.verticalScale(2),
                                                            ),
                                                          ),
                                                          Text(
                                                            monthProvider.endTime == null || monthProvider.endTime.toString() == ""
                                                                ? ""
                                                                : DateFormat(' - MM/dd').format(monthProvider.endTime!),
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: ScreenUtil.verticalScale(2),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                                // Padding(
                                                //   padding: const EdgeInsets.symmetric(vertical: 5),
                                                //   child: Text(
                                                //     monthProvider.monthDataModel?.title ?? "",
                                                //     textAlign: TextAlign.center,
                                                //     style: TextStyle(
                                                //       color: Colors.white,
                                                //       fontSize: ScreenUtil.horizontalScale(6.5),
                                                //       fontWeight: FontWeight.bold,
                                                //     ),
                                                //   ),
                                                // ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil.horizontalScale(2),
                                                    right: ScreenUtil.horizontalScale(8),
                                                  ),
                                                  child: SizedBox(
                                                    height: media.height / 7.5,
                                                    child: Center(
                                                      child: Image.asset("assets/img/month_hero1.png"),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil.horizontalScale(16),
                                                  ),
                                                  child: ButtonWidget(
                                                    text: "Watch Video Intro",
                                                    color: Colors.white,
                                                    onPress: () {
                                                      Navigator.of(context).push(
                                                        FadePageRoute(
                                                          page: const VideoIntroWidget(
                                                            vimeoId: '953289606',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    textColor: AppColors.primaryColor,
                                                    isLoading: false,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              // Container(
                              //   alignment: Alignment.center,
                              //   margin: EdgeInsets.symmetric(
                              //     vertical: ScreenUtil.verticalScale(33),
                              //   ),
                              //   child: InkWell(
                              //     onTap: () {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) => const ProgramInfoView(),
                              //         ),
                              //       );
                              //     },
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: [
                              //         Text(
                              //           "View Program Info",
                              //           style: TextStyle(
                              //             decorationColor: Colors.white,
                              //             color: Colors.white,
                              //             fontSize: ScreenUtil.verticalScale(2.2),
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
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
                        ],
                      ),
                      Container(
                        width: media.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                          ),
                        ),
                        margin: EdgeInsets.only(top: media.height / 2.55),
                        child: Column(
                          children: [
                            SizedBox(
                              height: media.height * 0.12,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6),
                                  vertical: ScreenUtil.verticalScale(2.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<MonthProvider>(builder: (context, controller, child) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          3,
                                          (index) => Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                controller.updateSelectedSection(index);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(2.2)),
                                                margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                                                decoration: BoxDecoration(
                                                    color:
                                                        index == controller.selectedSection ? AppColors.primaryColor : AppColors.greyColor,
                                                    borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5.5))),
                                                child: Center(
                                                  child: Text(
                                                    index == 0
                                                        ? "Schedule"
                                                        : index == 1
                                                            ? "Options"
                                                            : "Information",
                                                    style: TextStyle(
                                                      color: index == controller.selectedSection ? Colors.white : Colors.black,
                                                      fontSize: ScreenUtil.verticalScale(1.75),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            Consumer<MonthProvider>(
                              builder: (context, monthProvider, child) {
                                return Container(
                                  color: Colors.white,
                                  constraints: BoxConstraints(
                                    minHeight: (media.height - (media.height / 2.55) - (media.height * 0.12)),
                                  ),
                                  child: Column(
                                    children: [
                                      if (!monthProvider.loader) ...[
                                        Visibility(
                                            visible: monthProvider.selectedSection == 0,
                                            child: ScheduleSection(
                                                monthProvider: monthProvider, onPress: () => continueWorkoutOnTap(context))),
                                        Visibility(
                                            visible: monthProvider.selectedSection == 1,
                                            child: SettingSection(monthProvider: monthProvider)),
                                        Visibility(
                                            visible: monthProvider.selectedSection == 2,
                                            child: InformationSection(programInfoProvider: provider)),
                                      ]
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> continueWorkoutOnTap(BuildContext context) async {
    HapticFeedBack.buttonClick();
    int? index = monthProvider!.monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].idList
        ?.indexWhere((element) => element == monthProvider!.todayTitleId);

    final dayIndex = int.parse((monthProvider!.monthDataModel?.weeks![(monthProvider!.week ?? 1) - 1].dayList?[index ?? 0]
                .toString()
                .replaceAll("Workout", "")
                .replaceAll("Rest", "")
                .replaceAll("Day", "")
                .replaceAll(" ", "") ??
            "0")) -
        1;

    DayDataModel dayData =
        "${monthProvider!.monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].dayList![index ?? 0] ?? ""}".toString().contains("Workout")
            ? monthProvider!.monthDataModel!.weeks![(monthProvider!.week ?? 1) - 1].days![dayIndex]
            : DayDataModel();

    bool isRestDay = monthProvider!.monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].dayList?[index ?? 0].contains("Rest Day");

    String split = monthProvider?.monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.monthDataModel!.weeks![(monthProvider!.week ?? 1) - 1].id}-${monthProvider!.todayTitleId}";

    bool isPumpDay = (isRestDay &&
            monthProvider!.allDayHistoryModel.any((element) => element.dataId == dataId && element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            (monthProvider!.isPumpDayAvailable &&
                (monthProvider!.allDayHistoryModel.any((element) => element.dataId == dataId && element.type != "Rest Day")))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allDayHistoryModel
                .any((element) => element.dataId == dataId && element.type == "Rest Day" && element.status == ""))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (!monthProvider!.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId)));

    monthProvider?.changeIsPumpDay(isPumpDay);
    log('isPumpDay :::::::::::::::::: ${isPumpDay}');
    if (isPumpDay) {
      final dataList = monthProvider?.dayHistoryModel
          .where((element) => element.type?.contains("Pump Day") == true && element.status != Status.empty)
          .toList();

      if (dataList!.isNotEmpty) {
        int index1 = monthProvider!.pumpDays.indexWhere((el1) =>
            dataList.any((e1) => (e1.dayId == monthProvider!.todayTitleId && e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider!.updatePumpDayData(monthProvider!.pumpDays[index1]);
        } else {
          int index1 =
              monthProvider!.pumpDays.indexWhere((el1) => dataList.any((e1) => e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
          monthProvider!.updatePumpDayData(monthProvider!.pumpDays[index == -1
              ? 0
              : index1 == 0
                  ? 1
                  : 0]);
        }
      } else {
        monthProvider!.updatePumpDayData(monthProvider!.pumpDays[0]);
      }
      // monthProvider?.updatePumpDayData(monthProvider!.pumpDays[
      //     int.parse(monthProvider!.monthDataModel!.weeks![monthProvider!.week! - 1].dayList![index ?? 0].toString().split(" ").last) - 1]);
    }
    monthProvider!.overviewCurrentWeek = monthProvider!.week ?? 1;
    monthProvider!.overviewCurrentDay = ((index ?? 1) + 1);
    monthProvider!.dayDataModel = dayData;
    // monthProvider!.alternateEquipmentType = monthProvider!.equipmentType;
    monthProvider!.weekDataModel = monthProvider!.monthDataModel!.weeks![(monthProvider!.week ?? 1) - 1];
    monthProvider?.updateIsPastWeek(monthProvider!.weekStatuses[(monthProvider!.week ?? 1) - 1] == WeekType.pastWeek);

    final dayIndex1 = monthProvider!.overviewCurrentDay;

    int nextWorkOutIndex = monthProvider!.weekDataModel!.dayList![dayIndex1 - 1].toString().contains("Workout")
        ? int.parse(monthProvider!.weekDataModel!.dayList![dayIndex1 - 1].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
        : 0;
    String currentDayTitle = monthProvider!.weekDataModel!.dayList![dayIndex1 - 1].toString().contains("Workout")
        ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider!.weekDataModel!.dayList![dayIndex1 - 1];
    // if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay)) {
    //   Navigator.pushNamed(context, '/dayOverview');
    // }

    final isCompletedOrSkipped = (monthProvider?.allSplitDayHistoryModel
        .any((element) => (element.status == Status.completed || element.status == Status.skipped) && element.dataId == dataId));
    if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay) && isCompletedOrSkipped!) {
      return;
    } else if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay) && !isCompletedOrSkipped!) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      context.read<MainPageProvider>().changeTab(1);
      monthProvider?.updateIsOnMonthPage(false);
      monthProvider?.updateScrollToRestDay(true);
      _completeRestDay(status: Status.completed, type: 'Rest Day', endDate: true).then(
        (value) {
          monthProvider?.onInit(context, isEnabled: false);
        },
      );
      await monthProvider?.checkForPumpDay();
      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (c1) {
      //     return skipWorkoutDialog(context, c1);
      //   },
      // );
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
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await monthProvider!.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider!.dayHistoryModel.any((element) => element.dataId == dataId)) == false) {
          _saveDayData(status: Status.started, type: 'Workout Day');
        }
        if (!context.mounted) return;
        await Navigator.pushNamed(context, '/today');
      }
    }
    // Navigator.pushNamed(context, '/dayOverview');
  }

  Future<void> _saveDayData({required String status, required String type, String? title}) async {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

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
      "endTime": "",
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
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
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
      "endTime": (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
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

  // Widget skipWorkoutDialog(BuildContext context, BuildContext c1) {
  //   return Dialog(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(20),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           color: const Color(0xFFFFFFFF),
  //         ),
  //         child: Stack(
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)).copyWith(top: ScreenUtil.verticalScale(2.5)),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   SizedBox(height: ScreenUtil.verticalScale(2)),
  //                   Text(
  //                     "Rest Day",
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: ScreenUtil.verticalScale(2.4),
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(1)),
  //                     child: Text(
  //                       "Would you like to mark the rest day complete or skip?",
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         color: Colors.black,
  //                         fontSize: ScreenUtil.verticalScale(2),
  //                         fontWeight: FontWeight.normal,
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: ElevatedButton(
  //                             onPressed: () async {
  //                               await _saveDayData(status: Status.skipped, type: 'Rest Day');
  //                               if (!c1.mounted) return;
  //                               Navigator.of(c1).pop();
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(15),
  //                               ),
  //                               backgroundColor: AppColors.skipDayColor,
  //                               padding: EdgeInsets.symmetric(
  //                                 vertical: ScreenUtil.verticalScale(1.7),
  //                               ),
  //                             ),
  //                             child: Text(
  //                               "Skip day",
  //                               style: TextStyle(
  //                                 fontSize: ScreenUtil.verticalScale(2),
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: ScreenUtil.horizontalScale(3)),
  //                         Expanded(
  //                           child: ElevatedButton(
  //                             onPressed: () async {
  //                               await _saveDayData(status: Status.completed, type: 'Rest Day');
  //                               if (!c1.mounted) return;
  //                               Navigator.of(c1).pop();
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(15),
  //                               ),
  //                               backgroundColor: AppColors.primaryColor,
  //                               padding: EdgeInsets.symmetric(
  //                                 vertical: ScreenUtil.verticalScale(1.7),
  //                               ),
  //                             ),
  //                             child: Text(
  //                               "Mark complete",
  //                               style: TextStyle(
  //                                 fontSize: ScreenUtil.verticalScale(2),
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.close),
  //                     onPressed: () {
  //                       Navigator.of(c1).pop();
  //                     },
  //                   ),
  //                   SizedBox(width: ScreenUtil.horizontalScale(2)),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _completeRestDay({required String status, required String type, String? title, bool endDate = false}) async {
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
