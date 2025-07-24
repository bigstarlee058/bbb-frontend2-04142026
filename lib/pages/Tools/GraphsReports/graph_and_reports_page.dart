import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/custom_radar.dart';
import 'package:bbb/pages/Tools/GraphsReports/Charts/report_weight_lifted.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GraphAndReportsPage extends StatefulWidget {
  const GraphAndReportsPage({super.key});

  @override
  State<GraphAndReportsPage> createState() => _GraphAndReportsPageState();
}

class _GraphAndReportsPageState extends State<GraphAndReportsPage> {
  DataProvider? dataProvider;
  // List<ExerciseLibrary> _filteredExercises = [];
  late MainPageProvider mainPageProvider;
  ScrollController scrollController = ScrollController();

  List<String> items = [];
  List<String> filteredItems = [];
  bool isDropdownOpen = false;

  MonthProvider? monthProvider;
  bool loader = false;
  @override
  void initState() {
    super.initState();
    monthProvider = Provider.of<MonthProvider>(context, listen: false);

    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => filterRadarChartData(),
    );
    // dataProvider?.fetchAdminData().then((_) {
    //   setState(() {
    //     _filteredExercises = dataProvider!.adminExercises;
    //     items = _filteredExercises.map((exercise) => exercise.title).toList();
    //   });
    // }).catchError((error) {
    //   debugPrint('Error fetching admin exercises: $error');
    // });
  }

  // Future<void> filterRadarChartData() async {
  //   final exerciseMap = {
  //     "Back Squat": "67941affde5cb7e685b6250d",
  //     "Barbell Bench Press": "67658618b4bdd7fee53c62a0",
  //     "Conventional Deadlift": "67f6092ec86cd04c9a31a21e",
  //     "Weighted Chin-Up": "67fbebb2be021a74cbd96ba7",
  //     "Barbell Hip Thrust": "67658533b4bdd7fee53c5566",
  //   };
  //
  //   Map<String, int> maxOneRMMap = {};
  //
  //   final allDataFutures = exerciseMap.entries.map((entry) async {
  //     final name = entry.key;
  //     final id = entry.value;
  //
  //     List<ExerciseHistoryDataModel> history =
  //         await ApiRepo.fetchExerciseForTheExercise(id);
  //
  //     final Map<String, ExerciseHistoryDataModel> highestByDate = {};
  //
  //     for (final item in history) {
  //       final dateStr = item.date;
  //       final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
  //       final dayKey = DateFormat('yyyy-MM-dd').format(date);
  //
  //       final reps = int.tryParse(item.reps ?? "0") ?? 0;
  //       final weight = double.tryParse(item.weight ?? "0") ?? 0;
  //       final load = reps * weight;
  //
  //       final existing = highestByDate[dayKey];
  //       final existingLoad = (int.tryParse(existing?.reps ?? "0") ?? 0) *
  //           (double.tryParse(existing?.weight ?? "0") ?? 0);
  //
  //       if (!highestByDate.containsKey(dayKey) || load > existingLoad) {
  //         highestByDate[dayKey] = item;
  //       }
  //     }
  //
  //     double maxOneRM = 0.0;
  //
  //     for (final data in highestByDate.values) {
  //       final weight = double.tryParse(data.weight ?? "0") ?? 0;
  //       final reps = int.tryParse(data.reps ?? "0") ?? 0;
  //       final effort = int.tryParse(data.effort ?? "0") ?? 100;
  //
  //       if (weight == 0 || reps == 0) continue;
  //
  //       final rir = (effort == 100) ? 0.0 : effort.toDouble();
  //       final oneRM = weight * (0.025 * (reps + rir)) + 1;
  //
  //       if (oneRM > maxOneRM) maxOneRM = oneRM;
  //     }
  //
  //     maxOneRMMap[name] = (maxOneRM.toInt());
  //   });
  //   await Future.wait(allDataFutures);
  // }

  Future<void> filterRadarChartData() async {
    loader = true;
    setState(() {});
    valueList = [];
    final exerciseMap = {
      "Back Squat": "67941affde5cb7e685b6250d",
      "Barbell Bench Press": "67658618b4bdd7fee53c62a0",
      "Conventional Deadlift": "67f6092ec86cd04c9a31a21e",
      "Weighted Chin-Up": "67fbebb2be021a74cbd96ba7",
      "Barbell Hip Thrust": "67658533b4bdd7fee53c5566"
    };
    final List<String> features = [
      "Back Squat",
      "Barbell\nBench Press",
      "Conventional\nDeadlift",
      "Weighted\nChin-Up",
      "Barbell\nHip Thrust",
      "Chinup"
    ];

    Map<String, Map<String, dynamic>> percentageMap = {};

    final allDataFutures = exerciseMap.entries.map((entry) async {
      final name = entry.key;
      final id = entry.value;

      List<ExerciseHistoryDataModel> history =
          await ApiRepo.fetchExerciseForTheExercise(id);

      history.sort((a, b) {
        final da = DateTime.tryParse(a.date ?? '') ?? DateTime(1970);
        final db = DateTime.tryParse(b.date ?? '') ?? DateTime(1970);
        return da.compareTo(db);
      });

      double? baseOneRM;
      String? baseDate;
      double? latestOneRM;
      String? latestDate;

      final Map<String, ExerciseHistoryDataModel> highestByDate = {};

      for (final item in history) {
        final dateStr = item.date;
        final date = DateTime.parse("${dateStr ?? DateTime.now()}");
        final dayKey = DateFormat('MM-dd-yyyy').format(date);

        final reps = int.tryParse(item.reps ?? "0") ?? 0;
        final weight = double.tryParse(item.weight ?? "0") ?? 0;
        final load = reps * weight;

        if (!highestByDate.containsKey(dayKey) ||
            (load) >
                (int.tryParse(highestByDate[dayKey]!.reps ?? "0") ?? 0) *
                    (double.tryParse(highestByDate[dayKey]!.weight ?? "0") ??
                        0)) {
          highestByDate[dayKey] = item;
        }
      }
      final data1 = highestByDate.values.toList();

      for (final item in data1) {
        final weight = double.tryParse(item.weight ?? "0") ?? 0;
        final reps = int.tryParse(item.reps ?? "0") ?? 0;
        final effort = int.tryParse(item.effort ?? "0") ?? 100;

        if (weight == 0 || reps == 0) continue;

        final rir = (effort == 100) ? 0.0 : effort.toDouble();
        final oneRM = weight * ((0.025 * (reps + rir)) + 1);

        if (oneRM <= 1) continue;

        if (baseOneRM == null) {
          baseOneRM = oneRM;
          baseDate = item.date;
        }
        latestOneRM = oneRM;
        latestDate = item.date;
      }

      double percentage = 0;
      if (baseOneRM != null && latestOneRM != null && baseOneRM > 0) {
        percentage = (latestOneRM / baseOneRM) * 100;
      }

      percentageMap[name] = {
        "oldest_1RM": baseOneRM ?? 0,
        "oldest_date": baseDate ?? "",
        "latest_1RM": latestOneRM ?? 0,
        "latest_date": latestDate ?? "",
        "percentage": percentage
      };
    });

    await Future.wait(allDataFutures);

    final data = features.map((feature) {
      final key = feature.replaceAll("\n", " ");
      return (percentageMap[key] ??
          {
            "oldest_1RM": 0.0,
            "oldest_date": "",
            "latest_1RM": 0.0,
            "latest_date": "",
            "percentage": 0.0
          });
    }).toList();

    for (var element in data) {
      valueList.add(
          double.parse("${element["percentage"].toStringAsFixed(0) ?? 0}"));
      dateHighest.add(element["latest_date"] == null ||
              element["latest_date"].toString().isEmpty
          ? ""
          : DateFormat("MM/dd/yyyy")
              .format(DateTime.parse(element["latest_date"])));
      dateOld.add(element["oldest_date"] == null ||
              element["oldest_date"].toString().isEmpty
          ? ""
          : DateFormat("MM/dd/yyyy")
              .format(DateTime.parse(element["oldest_date"])));
    }
    setState(() {
      loader = false;
    });
  }

  void scrollToMiddle() {
    if (monthProvider?.graphType == "Weight" ||
        monthProvider?.graphType == "RIR") {
      final middleOffset = scrollController.position.maxScrollExtent /
          (monthProvider?.graphType == "Weight"
              ? 3
              : monthProvider?.graphType == "RIR"
                  ? 1.5
                  : 1);

      scrollController.animateTo(
        middleOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<double> valueList = [];
  List<String> dateOld = [];
  List<String> dateHighest = [];

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      monthProvider?.getLiftedWeightGraphData();
      monthProvider?.updateGraphType("");
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          filterRadarChartData();
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppImage.imageGraphs(),
            Container(
              margin: EdgeInsets.only(
                  top: Platform.isAndroid
                      ? media.height / 8.5
                      : media.height / 7),
              child: Container(
                width: media.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  ),
                ),
                child: loader
                    ? SizedBox(
                        height: media.height -
                            (Platform.isAndroid
                                ? media.height / 8.5
                                : media.height / 7),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          /// EXERCISE COMPLETED

                          // SizedBox(height: ScreenUtil.horizontalScale(7)),
                          // Container(
                          //   margin: EdgeInsets.symmetric(
                          //     vertical: ScreenUtil.verticalScale(1.5),
                          //     horizontal: ScreenUtil.horizontalScale(8),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         "Exercises Completed",
                          //         style: TextStyle(
                          //           color: AppColors.primaryColor,
                          //           fontSize: ScreenUtil.verticalScale(2.3),
                          //           fontWeight: FontWeight.w700,
                          //         ),
                          //       ),
                          //       Container(
                          //         height: ScreenUtil.verticalScale(4),
                          //         decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.circular(
                          //             ScreenUtil.verticalScale(2),
                          //           ),
                          //         ),
                          //         child: Consumer<MonthProvider>(
                          //           builder: (context, monthProvider, child) {
                          //             return DropdownButtonHideUnderline(
                          //               child: DropdownButton(
                          //                 value: monthProvider
                          //                     .reportExerciseCompletedWeek,
                          //                 items: [
                          //                   "Week 1",
                          //                   "Week 2",
                          //                   "Week 3",
                          //                   "Week 4"
                          //                 ]
                          //                     .map(
                          //                       (name) => DropdownMenuItem(
                          //                         value: name,
                          //                         child: Text(
                          //                           name,
                          //                           style: TextStyle(
                          //                             color: const Color(0xA09F9F9F),
                          //                             fontSize:
                          //                                 ScreenUtil.horizontalScale(
                          //                               3,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     )
                          //                     .toList(),
                          //                 onChanged: monthProvider
                          //                     .changeWeekExerciseCompleted,
                          //                 icon: Icon(
                          //                   Icons.expand_more,
                          //                   color: const Color(0xA09F9F9F),
                          //                   size: ScreenUtil.verticalScale(3),
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
                          //   margin: EdgeInsets.symmetric(
                          //     horizontal: ScreenUtil.horizontalScale(8),
                          //   ),
                          // child: const ReportExerciseCompletedGraph(),
                          // ),

                          /// WEIGHT LIFTED

                          SizedBox(height: ScreenUtil.horizontalScale(4)),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: ScreenUtil.verticalScale(1.5),
                                horizontal: ScreenUtil.horizontalScale(8)),
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
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil.verticalScale(2)),
                                  ),
                                  child: Consumer<MonthProvider>(
                                    builder: (context, monthProvider, child) {
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          value:
                                              monthProvider.reportWeightLifted,
                                          items: [
                                            "Week 1",
                                            "Week 2",
                                            "Week 3",
                                            "Week 4"
                                          ]
                                              .map(
                                                (name) => DropdownMenuItem(
                                                  value: name,
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xA09F9F9F),
                                                      fontSize: ScreenUtil
                                                          .verticalScale(1.5),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: monthProvider
                                              .changeWeekWeightLifted,
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
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(8)),
                              child: const ReportWeightLiftedGraph()),

                          /// AVERAGE RIR

                          // SizedBox(height: ScreenUtil.horizontalScale(4)),
                          // Container(
                          //   margin: EdgeInsets.symmetric(
                          //       vertical: ScreenUtil.verticalScale(1.5),
                          //       horizontal: ScreenUtil.horizontalScale(8)),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         "Average RIR",
                          //         style: TextStyle(
                          //           color: AppColors.primaryColor,
                          //           fontSize: ScreenUtil.verticalScale(2.3),
                          //           fontWeight: FontWeight.w700,
                          //         ),
                          //       ),
                          //       Container(
                          //         height: ScreenUtil.verticalScale(4),
                          //         decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.circular(
                          //               ScreenUtil.verticalScale(2)),
                          //         ),
                          //         child: Consumer<MonthProvider>(
                          //           builder: (context, monthProvider, child) {
                          //             return DropdownButtonHideUnderline(
                          //               child: DropdownButton(
                          //                 value: monthProvider.reportAverageRIRWeek,
                          //                 items: [
                          //                   "Week 1",
                          //                   "Week 2",
                          //                   "Week 3",
                          //                   "Week 4"
                          //                 ]
                          //                     .map(
                          //                       (name) => DropdownMenuItem(
                          //                         value: name,
                          //                         child: Text(
                          //                           name,
                          //                           style: TextStyle(
                          //                             color: const Color(0xA09F9F9F),
                          //                             fontSize:
                          //                                 ScreenUtil.verticalScale(
                          //                                     1.5),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     )
                          //                     .toList(),
                          //                 onChanged:
                          //                     monthProvider.changeWeekWeightLifted,
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
                          //     margin: EdgeInsets.symmetric(
                          //         horizontal: ScreenUtil.horizontalScale(8)),
                          //     child: const ReportAverageRIRGraph()),

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

                          SizedBox(height: ScreenUtil.horizontalScale(2)),
                          Container(
                            margin: EdgeInsets.only(
                              left: ScreenUtil.horizontalScale(2),
                              right: ScreenUtil.horizontalScale(5),
                            ),
                            // height: 400,
                            child: CustomRadarChart(
                                valueList: valueList,
                                dateHighest: dateHighest,
                                dateOld: dateOld),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(8),
                                vertical: 35),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        left: ScreenUtil.horizontalScale(3),
                                        right: ScreenUtil.horizontalScale(5),
                                        top: ScreenUtil.verticalScale(2),
                                        bottom: ScreenUtil.verticalScale(2),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Total Weight\nLifted',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                                fontSize:
                                                    ScreenUtil.horizontalScale(
                                                        3.6)),
                                          ),
                                          const SizedBox(height: 10),
                                          Consumer<MonthProvider>(
                                            builder: (context, monthProvider,
                                                child) {
                                              return Text(
                                                "${NumberFormat.decimalPattern('en_US').format(monthProvider.totalWeightLiftedInAWeek.toInt())}lbs",

                                                // '${monthProvider.totalWeightLiftedInAWeek.toStringAsFixed(0)} lbs',
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFFDD1166),
                                                  fontSize: ScreenUtil
                                                      .horizontalScale(4),
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
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Total completed\nExercises',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize:
                                                  ScreenUtil.horizontalScale(
                                                      3.6),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Consumer<MonthProvider>(
                                            builder: (context, monthProvider,
                                                child) {
                                              return Text(
                                                monthProvider
                                                    .totalExerciseCompletedInAWeek
                                                    .toStringAsFixed(0),
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFFDD1166),
                                                  fontSize: ScreenUtil
                                                      .horizontalScale(4),
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
                            AppBar(
                              toolbarHeight: ScreenUtil.verticalScale(5.1),
                              surfaceTintColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              centerTitle: true,
                              leading: BackArrowWidget(
                                onPress: () {
                                  Navigator.pop(context);
                                },
                              ),
                              title: Text(
                                'Graphs & Reports',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil.horizontalScale(5.5),
                                ),
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: const CommonStreakWithNotification(
                                      routeString: '/exerciseLibrary'),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(7)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Column(children: [
                                  //   SizedBox(
                                  //     height: ScreenUtil.verticalScale(0.6),
                                  //   ),
                                  //   Container(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal:
                                  //           ScreenUtil.horizontalScale(5),
                                  //     ),
                                  //     height: media.height * 0.08,
                                  //     child: Column(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.center,
                                  //       children: [
                                  //         Text(
                                  //           "Here's some fun graphs for you",
                                  //           style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontSize:
                                  //                 ScreenUtil.verticalScale(2),
                                  //           ),
                                  //           textAlign: TextAlign.center,
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ]),
                                  // SizedBox(
                                  //   height: media.height * 0.01,
                                  // ),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //     horizontal: ScreenUtil.horizontalScale(3),
                                  //     vertical: ScreenUtil.horizontalScale(1),
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.white,
                                  //     borderRadius: BorderRadius.circular(
                                  //         ScreenUtil.verticalScale(4)),
                                  //     boxShadow: const [
                                  //       BoxShadow(
                                  //         color: Colors.black12,
                                  //         spreadRadius: 2,
                                  //         blurRadius: 10,
                                  //         offset: Offset(0, 1),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   child: Column(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: [
                                  //       SearchExerciseField(
                                  //         controller: _controller,
                                  //         onChanged: _filterItems,
                                  //       ),
                                  //       if (isDropdownOpen)
                                  //         Column(
                                  //           children: [
                                  //             ListView(
                                  //               shrinkWrap:
                                  //                   true, // Allows ListView to take only the space it needs
                                  //               physics:
                                  //                   const AlwaysScrollableScrollPhysics(), // Disable scrolling if needed
                                  //               children:
                                  //                   filteredItems.map((item) {
                                  //                 return ListTile(
                                  //                   title: Text(
                                  //                     item,
                                  //                     style: const TextStyle(
                                  //                         fontSize:
                                  //                             16), // Adjust font size as needed
                                  //                     maxLines:
                                  //                         3, // Limit to 3 lines; adjust as needed
                                  //                     overflow: TextOverflow
                                  //                         .ellipsis, // Show ellipsis if text is too long
                                  //                   ),
                                  //                   onTap: () =>
                                  //                       _selectItem(item),
                                  //                 );
                                  //               }).toList(),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Platform.isAndroid
                          ? media.height / 8.39
                          : media.height / 6.99,
                      width: media.width,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: Container(
                            height: media.height / 11,
                            width: media.width / 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
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
    );
  }
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

  const SearchExerciseField(
      {super.key, required this.onChanged, required this.controller});

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
