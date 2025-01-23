import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/select_dropdown.dart';
import 'package:bbb/components/select_dropdown1.dart';
import 'package:bbb/components/weekly_track_card.dart';
import 'package:bbb/models/day.dart';
import 'package:bbb/pages/ProgramInfoView/program_info_view.dart';
import 'package:bbb/pages/video_intro_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/routes/fade_page_route.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/main_page_provider.dart';

class MonthlyViewPage extends StatefulWidget {
  const MonthlyViewPage({
    super.key,
  });

  @override
  State<MonthlyViewPage> createState() => _MonthlyViewPageState();
}

class _MonthlyViewPageState extends State<MonthlyViewPage> {
  final today = DateTime.now();
  DataProvider? dataProvider;
  UserDataProvider? userData;
  int? week;
  int? day;
  int currentWeek = 0;

  late MainPageProvider mainPageProvider;
  DateTime? startTime;
  DateTime? endTime;

  List<Day> cardDetails = [];

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);

    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );

    if (dataProvider?.workout.startDate != null && dataProvider?.workout.startDate != "") {
      startTime = DateTime.parse(dataProvider!.workout.startDate);
    } else {
      startTime = DateTime.now();
    }

    if (dataProvider?.workout.endDate != null && dataProvider?.workout.endDate != "") {
      endTime = DateTime.parse(dataProvider!.workout.endDate);
    }
    int dayDelta = today.difference(startTime!).inDays;
    week = (dayDelta ~/ 7) + 1;
    setState(() {
      currentWeek = week!;
    });

    day = dayDelta % 7 + 1;

    debugPrint("********************");
    debugPrint(week.toString());
    debugPrint(day.toString());

    // week = 1;
    // day = 6;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to filter workouts based on selected formats
  void filterWorkouts() async {
    dataProvider?.clearAll();
    await Future.delayed(const Duration(milliseconds: 50));
    dataProvider?.filter(userData!.selectedExerciseFormat, userData!.selectedDaySplit);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    // dataProvider?.loadMonthWorkouts();

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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: ScreenUtil.horizontalScale(4),
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0XFFd18a9b),
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
                                              mainPageProvider.changeTab(0);
                                            },
                                            iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
                                          ),
                                        ),
                                      ),
                                      const CommonStreakWithNotification()
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(8),
                                    vertical: ScreenUtil.verticalScale(2),
                                  ),
                                  height: media.height * 0.22,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Column(
                                          children: [
                                            startTime != null && endTime != null
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        startTime == null || startTime == "" ? "" : DateFormat('MM/dd').format(startTime!),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: ScreenUtil.verticalScale(2),
                                                        ),
                                                      ),
                                                      Text(
                                                        endTime == null || endTime == "" ? "" : DateFormat(' - MM/dd').format(endTime!),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: ScreenUtil.verticalScale(2),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            const SizedBox(height: 5),
                                            Text(
                                              dataProvider!.workout.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil.verticalScale(3),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Text(
                                      //   'Overview',
                                      //   style: TextStyle(
                                      //     color: Colors.white,
                                      //     fontSize:
                                      //         ScreenUtil.verticalScale(3.5),
                                      //     fontWeight: FontWeight.bold,
                                      //     height: 1.3,
                                      //   ),
                                      // ),
                                      const SizedBox(height: 10),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: ScreenUtil.horizontalScale(10),
                                        ),
                                        child: ButtonWidget(
                                          text: "Watch Video Intro",
                                          color: const Color(0xEEFFFFFF),
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
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                            vertical: ScreenUtil.verticalScale(33.5),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProgramInfoView(),
                                  ));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "View Program Info",
                                  style: TextStyle(
                                    decorationColor: Colors.white,
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(2.2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(8),
                            vertical: ScreenUtil.verticalScale(3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: ScreenUtil.horizontalScale(3),
                                ),
                                child: Text(
                                  'Choose workout day split',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xBB888888),
                                    fontSize: ScreenUtil.verticalScale(1.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              SelectDropdown1(
                                onChange: (String newValue) {
                                  userData?.changeDaySplit(newValue);
                                  filterWorkouts();
                                },
                              ),
                              const SizedBox(height: 32),
                              Container(
                                margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(3)),
                                child: Text(
                                  'Choose equipent availiability',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xBB888888),
                                    fontSize: ScreenUtil.verticalScale(1.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectDropdown(
                                onChange: (String newValue) {
                                  userData!.selectedExerciseFormat = newValue;
                                  userData?.notifyListeners();
                                  filterWorkouts();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<DataProvider>(
                          builder: (context, dataProvider, child) {
                            DateTime? startTime;
                            try {
                              if (dataProvider?.workout.startDate != null) {
                                startTime = DateTime.parse(dataProvider!.workout.startDate);
                              } else {
                                startTime = DateTime.now();
                              }
                            } catch (e) {
                              startTime = DateTime.now();
                            }

                            return dataProvider.workout != null
                                ? Container(
                                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ignore: unnecessary_null_comparison
                                        for (int i = 0; i < dataProvider.workout.weeks.length; i++) ...[
                                          WeeklyTrackCard(
                                              pumpDayIds: dataProvider.workout.weeks[i].pumpDayIds,
                                              title: dataProvider.workout.weeks[i].title == ""
                                                  ? "Week ${i + 1}"
                                                  : dataProvider.workout.weeks[i].title,
                                              // isOpened: i == 0,
                                              thisWeek: ((i + 1) == week),
                                              restDayId: dataProvider.workout.weeks[i].restdayId,
                                              weekIndex: i,
                                              isOpened: false,
                                              isCompleted: false,
                                              // startDate: DateTime.tryParse(dataProvider?.workout?.startDate ?? "") ?? DateTime.now()
                                              //     .add(Duration(days: i * 7)),
                                              startDate: DateTime.parse(dataProvider.workout.startDate).add(Duration(days: i * 7)),
                                              cardData: dataProvider.workout.weeks[i],
                                              daySplit: userData!.selectedDaySplit,
                                              expandedVal: (i + 1) == week ? true : false,
                                              completedWeek: i + 1,
                                              weekStatus: (i + 1) < currentWeek
                                                  ? 0 // Previous week
                                                  : (i + 1) == currentWeek
                                                      ? 1 // Current week
                                                      : 2 // Future week

                                              ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                        ],

                                        // Container(
                                        //   margin: EdgeInsets.symmetric(
                                        //     horizontal: ScreenUtil.horizontalScale(10),
                                        //   ),
                                        //   child: ButtonWidget(
                                        //     text: "Mark Month Complete",
                                        //     textColor: const Color(0x30000000),
                                        //     onPress: () {},
                                        //     color: const Color(0xC8FFFFFF),
                                        //     isLoading: false,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  )
                                : const Center(
                                    child: Text("No workout data available"),
                                  );
                          },
                        ),
                        const SizedBox(height: 15),
                        // Container(
                        //   margin: EdgeInsets.symmetric(
                        //     horizontal: ScreenUtil.horizontalScale(10),
                        //   ),
                        //   child: ButtonWidget(
                        //     text: "Mark Month Complete",
                        //     textColor: const Color(0x30000000),
                        //     onPress: () {},
                        //     color: const Color(0xC8FFFFFF),
                        //     isLoading: false,
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(5),
                          ),
                          child: ButtonWidget(
                            text: "Start Your Workout",
                            textColor: Colors.white,
                            onPress: () {
                              userData?.currentDay = userData!.nextDayIndex;
                              userData?.previousPage = 2;
                              userData?.notifyListeners();
                              Navigator.pushNamed(context, '/dayOverview');
                            },
                            color: AppColors.primaryColor,
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
      ),
    );
  }
}
