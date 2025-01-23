import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/activity_line_chart.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/icon_row_with_dot.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/weekly_graph_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbb/providers/user_data_provider.dart';

import '../../providers/exercise_history_provider.dart';

class DayCompletedPage extends StatefulWidget {
  const DayCompletedPage({super.key});

  @override
  State<DayCompletedPage> createState() => _DayCompletedPageState();
}

class _DayCompletedPageState extends State<DayCompletedPage> {
  UserDataProvider? userData;
  late int totalWeight = 0;
  late String time = "";




  late ExerciseHistoryProvider exerciseHistoryProvider;
  late WeeklyGraphProvider weeklyGraphProvider;

  @override
  void initState() {
    exerciseHistoryProvider = Provider.of(context,listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    weeklyGraphProvider = Provider.of<WeeklyGraphProvider>(context, listen: false);
    loadTime();
    super.initState();
  }


  var data;

  loadTime(){
    String  tempTime  = weeklyGraphProvider.weeklyProgress[6]['exercise_completed'][weeklyGraphProvider.splitIndex]['workout_time'];
    List<String> parts = tempTime.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    time = "$hours hours,\n$minutes minutes";
    setState(() {
    });
  }

  loadStreak(){

    Map<String, Map<String, dynamic>> uniqueEntries = {};

    for (var entry in userData!.streaksData) {
      // Parse the full datetime
      DateTime dateTime = DateTime.parse(entry['date']);
      // Extract just the date part as a string (e.g., "2024-12-07")
      String dateOnly = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

      // Update the map with the most recent entry for the date
      if (!uniqueEntries.containsKey(dateOnly) || DateTime.parse(entry['date']).isAfter(DateTime.parse(uniqueEntries[dateOnly]!['date']))) {
        uniqueEntries[dateOnly] = entry;
      }
    }

    // Convert the map back to a list
    List<Map<String, dynamic>> filteredEntries = uniqueEntries.values.toList();



    DateTime latestDate = DateTime.parse(filteredEntries.last['date']);

    // Generate the last 7 days starting from the latest date
    List<DateTime> last7Days = List.generate(7, (index) => latestDate.subtract(Duration(days: index)));

    // Extract the date parts from filteredEntries
    Set<String> filteredDateStrings = filteredEntries
        .map((entry) => "${DateTime.parse(entry['date']).year}-${DateTime.parse(entry['date']).month.toString().padLeft(2, '0')}-${DateTime.parse(entry['date']).day.toString().padLeft(2, '0')}")
        .toSet();

    // Generate the result list with missing dates marked as "skipped"
    List<Map<String, dynamic>> result = last7Days.map((date) {
      String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (filteredDateStrings.contains(dateStr)) {
        return filteredEntries.firstWhere((entry) => entry['date'].startsWith(dateStr));
      } else {
        return {
          "date": date.toIso8601String(),
          "status": "skipped",
          "selectedDaySplit": weeklyGraphProvider.splitIndex,
        };
      }
    }).toList();

    // Sort the result to ensure the most recent date is last
    result.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    // Ensure the most recent date is always last
    Map<String, dynamic> lastEntry = filteredEntries.last;
    result.removeWhere((entry) => entry['date'] == lastEntry['date']);
    result.add(lastEntry);

    // Print the result
    print(jsonEncode(result));

    
    data = result;
    setState(() {
    });

    log('userData!.streaksData==========>>>>>${result}');
  }

  // Future<void> _loadValue() async {
  //   // Use listen: false here
  //   totalWeight = await userData!.calculateTotalWeightForDay(); // Awaiting the Future<int>
  //   setState(() {}); // Update the state to reflect changes
  // }

  @override
  Widget build(BuildContext context) {
    final currentDay = ModalRoute.of(context)!.settings.arguments ?? 0;


    final mainPageProvider = context.watch<MainPageProvider>();

    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    loadStreak();

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
                        Container(
                          height: media.height / 2,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Container(
                                      //   margin: EdgeInsets.only(
                                      //     left:ScreenUtil.horizontalScale(4),
                                      //   ),
                                      //   decoration: const BoxDecoration(
                                      //     color:Color(0XFFd18a9b),
                                      //     shape: BoxShape.circle,
                                      //   ),
                                      //   child: SizedBox(
                                      //     width: ScreenUtil.horizontalScale(10), // Size of the circle
                                      //     height:ScreenUtil.horizontalScale(10),
                                      //     child: IconButton(
                                      //       padding: EdgeInsets.zero, // Removes the default padding
                                      //       icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white,),
                                      //       onPressed: () => Navigator.pop(context),
                                      //       iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
                                      //     ),
                                      //   ),
                                      // ),
                                      CommonStreakWithNotification()
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: ScreenUtil.horizontalScale(10)),
                                      Text(
                                        'Congratulations!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.horizontalScale(8.5),
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'You completed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.verticalScale(2),
                                        ),
                                      ),
                                      Text(
                                        "Week ${userData!.currentWeek}, Day ${userData!.currentDay}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                          ScreenUtil.verticalScale(3),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 2.79,
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
                  margin: EdgeInsets.only(top: media.height / 2.8),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: media.height / 19),
                      child: Column(
                        children: [
                           IconRowWithDot(data: data),
                          SizedBox(height: ScreenUtil.horizontalScale(6)),
                          Text(
                            "Here's an overview of your today's workout.",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: ScreenUtil.horizontalScale(3.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Now recover and get ready for tomorrow!",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: ScreenUtil.horizontalScale(3.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: ScreenUtil.horizontalScale(3)),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(ScreenUtil.verticalScale(2)),
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
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.bolt,
                                              color: Colors.black38,
                                              size: ScreenUtil.horizontalScale(5),
                                            ),
                                            Text(
                                              "Today's Activity",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: ScreenUtil.horizontalScale(3.3),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: ScreenUtil.horizontalScale(2)),
                                        const ActivityLineChart(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil.verticalScale(3.5),
                                        vertical: ScreenUtil.verticalScale(2),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(ScreenUtil.verticalScale(3)),
                                        ),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Time Spent',
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            time, // Display totalWeight
                                            style: const TextStyle(
                                              color: Color(0xFFDD1166),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),                                                 
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ScreenUtil.verticalScale(3.5),
                                        vertical: ScreenUtil.verticalScale(2),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            ScreenUtil.verticalScale(3),
                                          ),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child:  Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Weight Lifted',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${exerciseHistoryProvider.history[exerciseHistoryProvider.today]['totalWeightLifted']} Lbs',
                                            style: const TextStyle(
                                              color: Color(0xFFDD1166),
                                              fontSize: 20,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                           Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(7)),
                            child: ButtonWidget(
                              text: "Back to Dashboard",
                              textColor: const Color(0x40000000),
                              onPress: () {
                                mainPageProvider.changeTab(0);
                                Navigator.pushNamed(context, '/home');
                              },
                              color: const Color(0xC0FFFFFF),
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(7)),
                            child: ButtonWidget(
                              text: "Next Workout",
                              textColor: Colors.white,
                              onPress: () {
                                Navigator.pushNamed(context, '/home');
                              },
                              color: AppColors.primaryColor,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black54),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: media.width / 1.4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}