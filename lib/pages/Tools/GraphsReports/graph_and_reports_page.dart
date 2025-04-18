import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/exerciselibrary.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_exercise_completed.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_weight_lifted.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/screen_util.dart';

class GraphAndReportsPage extends StatefulWidget {
  const GraphAndReportsPage({super.key});

  @override
  State<GraphAndReportsPage> createState() => _GraphAndReportsPageState();
}

class _GraphAndReportsPageState extends State<GraphAndReportsPage> {
  DataProvider? dataProvider;
  List<ExerciseLibrary> _filteredExercises = [];
  late MainPageProvider mainPageProvider;

  final TextEditingController _controller = TextEditingController();
  List<String> items = [];
  List<String> filteredItems = [];
  bool isDropdownOpen = false;

  MonthProvider? monthProvider;

  @override
  void initState() {
    super.initState();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    dataProvider?.fetchAdminData().then((_) {
      setState(() {
        _filteredExercises = dataProvider!.adminExercises;
        items = _filteredExercises.map((exercise) => exercise.title).toList();
      });
    }).catchError((error) {
      debugPrint('Error fetching admin exercises: $error');
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = items.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
      isDropdownOpen = query.isNotEmpty && filteredItems.isNotEmpty;
    });
  }

  void _selectItem(String item) {
    _controller.text = item;
    setState(() {
      isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
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
                Container(
                  margin: EdgeInsets.only(top: media.height / 3.2),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                      ),
                    ),
                    child: Column(
                      children: [
                        /// EXERCISE COMPLETED

                        SizedBox(height: ScreenUtil.horizontalScale(7)),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: ScreenUtil.verticalScale(1.5),
                            horizontal: ScreenUtil.horizontalScale(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Exercises Completed",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil.verticalScale(2.3),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                height: ScreenUtil.verticalScale(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(2),
                                  ),
                                ),
                                child: Consumer<MonthProvider>(
                                  builder: (context, monthProvider, child) {
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: monthProvider.reportExerciseCompletedWeek,
                                        items: ["Week 1", "Week 2", "Week 3", "Week 4"]
                                            .map(
                                              (name) => DropdownMenuItem(
                                                value: name,
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    color: const Color(0xA09F9F9F),
                                                    fontSize: ScreenUtil.horizontalScale(
                                                      3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: monthProvider.changeWeekExerciseCompleted,
                                        icon: Icon(
                                          Icons.expand_more,
                                          color: const Color(0xA09F9F9F),
                                          size: ScreenUtil.verticalScale(3),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ScreenUtil.horizontalScale(2)),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(8),
                          ),
                          // child: BarChartWidget(),
                          child: const ReportExerciseCompletedGraph(),
                        ),

                        /// WEIGHT LIFTED

                        SizedBox(height: ScreenUtil.horizontalScale(4)),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(1.5), horizontal: ScreenUtil.horizontalScale(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Weight Lifted",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil.verticalScale(2.3),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                height: ScreenUtil.verticalScale(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(2)),
                                ),
                                child: Consumer<MonthProvider>(
                                  builder: (context, monthProvider, child) {
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: monthProvider.reportWeightLifted,
                                        items: ["Week 1", "Week 2", "Week 3", "Week 4"]
                                            .map(
                                              (name) => DropdownMenuItem(
                                                value: name,
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    color: const Color(0xA09F9F9F),
                                                    fontSize: ScreenUtil.verticalScale(1.5),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: monthProvider.changeWeekWeightLifted,
                                        icon: const Icon(
                                          Icons.expand_more,
                                          color: Color(0xA09F9F9F),
                                          size: 25,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ScreenUtil.horizontalScale(2)),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
                            child: const ReportWeightLiftedGraph()),

                        /// TIME SPENT

                        // SizedBox(height: ScreenUtil.horizontalScale(4)),
                        // Container(
                        //   margin: EdgeInsets.symmetric(
                        //     vertical: ScreenUtil.verticalScale(1.5),
                        //     horizontal: ScreenUtil.horizontalScale(8),
                        //   ),
                        //   width: media.width,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(
                        //         'Time Spent',
                        //         style: TextStyle(
                        //           color: AppColors.primaryColor,
                        //           fontSize: ScreenUtil.horizontalScale(5),
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       Container(
                        //         height: ScreenUtil.verticalScale(4),
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(2)),
                        //         ),
                        //         child: Consumer<MonthProvider>(
                        //           builder: (context, monthProvider, child) {
                        //             return DropdownButtonHideUnderline(
                        //               child: DropdownButton(
                        //                 value: monthProvider.reportTimeSpent,
                        //                 items: ["Week 1", "Week 2", "Week 3", "Week 4"]
                        //                     .map((name) => DropdownMenuItem(
                        //                           value: name,
                        //                           child: Text(
                        //                             name,
                        //                             style: TextStyle(
                        //                               color: const Color(0xA09F9F9F),
                        //                               fontSize: ScreenUtil.verticalScale(1.5),
                        //                             ),
                        //                           ),
                        //                         ))
                        //                     .toList(),
                        //                 onChanged: monthProvider.changeWeekTimeSpent,
                        //                 icon: const Icon(
                        //                   Icons.expand_more,
                        //                   color: Color(0xA09F9F9F),
                        //                   size: 25,
                        //                 ),
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: ScreenUtil.horizontalScale(2)),
                        // Container(
                        //   margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
                        //   child: const ReportTimeSpentGraph()
                        // ),

                        /// BOTTOM CONTAINERS

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8), vertical: 35),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil.horizontalScale(3),
                                      right: ScreenUtil.horizontalScale(5),
                                      top: ScreenUtil.verticalScale(2),
                                      bottom: ScreenUtil.verticalScale(2),
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Total Weight\nLifted',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black54, fontSize: ScreenUtil.horizontalScale(3.6)),
                                        ),
                                        const SizedBox(height: 10),
                                        Consumer<MonthProvider>(
                                          builder: (context, monthProvider, child) {
                                            return Text(
                                              '${monthProvider.totalWeightLiftedInAWeek.toStringAsFixed(0)} lbs',
                                              style: TextStyle(
                                                color: const Color(0xFFDD1166),
                                                fontSize: ScreenUtil.horizontalScale(4.5),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil.horizontalScale(3),
                                      right: ScreenUtil.horizontalScale(5),
                                      top: ScreenUtil.verticalScale(2),
                                      bottom: ScreenUtil.verticalScale(2),
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Total completed\nExercises',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: ScreenUtil.horizontalScale(3.6),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Consumer<MonthProvider>(
                                          builder: (context, monthProvider, child) {
                                            return Text(
                                              monthProvider.totalExerciseCompletedInAWeek.toStringAsFixed(0),
                                              style: TextStyle(
                                                color: const Color(0xFFDD1166),
                                                fontSize: ScreenUtil.horizontalScale(4.5),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height * 0.02,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: media.height / 2,
                          width: media.width,
                        ),
                        SizedBox(
                          height: media.height,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SafeArea(
                                        child: SizedBox(width: ScreenUtil.horizontalScale(10)),
                                      ),
                                      // BackArrowWidget(
                                      //   onPress: () {
                                      //     // HapticFeedBack.buttonClick();
                                      //     // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                      //     // mainPageProvider.changeTab(2);
                                      //     Navigator.pop(context);
                                      //   },
                                      // ),
                                      Container(
                                        margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(8), top: ScreenUtil.horizontalScale(8)),
                                        child: Consumer<UserDataProvider>(builder: (context, userData, child) {
                                          return Text(
                                            // 'Hi, Nick',
                                            'Hi ${userData.userName}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.horizontalScale(5.5),
                                            ),
                                          );
                                        }),
                                      ),
                                      const CommonStreakWithNotification(routeString: '/graphAndReports')
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(7)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(children: [
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: media.width * 0.4,
                                          child: Text(
                                            "Here's some fun graphs for you",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.horizontalScale(4.5),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          height: ScreenUtil.horizontalScale(4),
                                        ),
                                      ]),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(3),
                                          vertical: ScreenUtil.horizontalScale(1),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SearchExerciseField(
                                              controller: _controller,
                                              onChanged: _filterItems,
                                            ),
                                            if (isDropdownOpen)
                                              Column(
                                                children: [
                                                  ListView(
                                                    shrinkWrap: true, // Allows ListView to take only the space it needs
                                                    physics: const AlwaysScrollableScrollPhysics(), // Disable scrolling if needed
                                                    children: filteredItems.map((item) {
                                                      return ListTile(
                                                        title: Text(
                                                          item,
                                                          style: const TextStyle(fontSize: 16), // Adjust font size as needed
                                                          maxLines: 3, // Limit to 3 lines; adjust as needed
                                                          overflow: TextOverflow.ellipsis, // Show ellipsis if text is too long
                                                        ),
                                                        onTap: () => _selectItem(item),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 3.19,
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
              ],
            ),
          ),
          Positioned(
            left: 0,
            child: BackArrowWidget(
              onPress: () {
                // HapticFeedBack.buttonClick();
                // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                // mainPageProvider.changeTab(2);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> continueWorkoutOnTap(MonthProvider monthProvider, BuildContext context) async {
    HapticFeedBack.buttonClick();
    int? index = monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].idList
        ?.indexWhere((element) => element == monthProvider.todayTitleId);

    String split = monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].id}-${monthProvider.todayTitleId}";

    final dayIndex = int.parse((monthProvider.monthDataModel?.weeks![(monthProvider.week ?? 1) - 1].dayList?[index ?? 0]
                .toString()
                .replaceAll("Workout", "")
                .replaceAll("Rest", "")
                .replaceAll("Day", "")
                .replaceAll(" ", "") ??
            "0")) -
        1;

    bool isRestDay =
        "${monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].dayList![index ?? 0] ?? ""}".toString().contains("Rest Day");

    bool isPumpDay = (isRestDay &&
            monthProvider.allDayHistoryModel.any((element) => element.dataId == dataId && element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            (monthProvider.isPumpDayAvailable &&
                (monthProvider.allDayHistoryModel.any((element) => element.dataId == dataId && element.type != "Rest Day")))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (monthProvider.allDayHistoryModel
                .any((element) => element.dataId == dataId && element.type == "Rest Day" && element.status == ""))) ||
        (isRestDay &&
            monthProvider.isPumpDayAvailable &&
            (!monthProvider.allDayHistoryModel.map((e) => e.dataId).toList().contains(dataId)));

    monthProvider.changeIsPumpDay(isPumpDay);
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

      // monthProvider.updatePumpDayData(monthProvider.pumpDays[
      //     int.parse(monthProvider.monthDataModel!.weeks![monthProvider.week! - 1].dayList![index ?? 0].toString().split(" ").last) - 1]);
    }

    DayDataModel dayData =
        "${monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].dayList![index ?? 0] ?? ""}".toString().contains("Workout")
            ? monthProvider.monthDataModel!.weeks![(monthProvider.week ?? 1) - 1].days![dayIndex]
            : DayDataModel();

    monthProvider.overviewCurrentWeek = monthProvider.week ?? 1;
    monthProvider.overviewCurrentDay = ((index ?? 1) + 1);
    monthProvider.dayDataModel = dayData;
    // monthProvider.alternateEquipmentType = monthProvider.equipmentType;
    monthProvider.weekDataModel = monthProvider.monthDataModel!.weeks![(monthProvider.week ?? 1) - 1];
    monthProvider.updateIsPastWeek(monthProvider.weekStatuses[(monthProvider.week ?? 1) - 1] == WeekType.pastWeek);
    Navigator.pop(context);

    final dayIndex1 = monthProvider.overviewCurrentDay;

    int nextWorkOutIndex = monthProvider.weekDataModel!.dayList![dayIndex1 - 1].toString().contains("Workout")
        ? int.parse(monthProvider.weekDataModel!.dayList![dayIndex1 - 1].toString().replaceAll("Day ", "").replaceAll(" Workout", "")) - 1
        : 0;
    String currentDayTitle = monthProvider.weekDataModel!.dayList![dayIndex1 - 1].toString().contains("Workout")
        ? monthProvider.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider.weekDataModel!.dayList![dayIndex1 - 1];
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
}

class SearchExerciseField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  final TextEditingController controller;

  void _selectAllText() {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  const SearchExerciseField({super.key, required this.onChanged, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(3),
        vertical: ScreenUtil.horizontalScale(1),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
      ),
      child: TextField(
        controller: controller,
        onTap: _selectAllText,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'All Exercises',
          hintStyle: TextStyle(
            color: Colors.black45,
            fontSize: ScreenUtil.verticalScale(2),
          ),
          suffixIcon: Icon(
            Icons.search,
            size: ScreenUtil.verticalScale(4),
            color: Colors.grey[300],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(2),
          ),
        ),
      ),
    );
  }
}
