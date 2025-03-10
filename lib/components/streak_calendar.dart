import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
// import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/calender.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class StreakCalendarPage extends StatefulWidget {
  const StreakCalendarPage({super.key});

  @override
  State<StreakCalendarPage> createState() => _StreakCalendarPageState();
}

class _StreakCalendarPageState extends State<StreakCalendarPage> {
  MonthProvider? monthProvider;
  late MainPageProvider mainPageProvider;

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    ScreenUtil.init(context);

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => monthProvider?.manageStreak(),
      // ),
      // backgroundColor: const Color.fromARGB(255, 52, 11, 11),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: media.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  child: FittedBox(
                    child: Container(
                      height: media.height / 2,
                      width: media.width,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/back.jpg'),
                          fit: BoxFit.cover,
                          opacity: 1,
                        ),
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          height: media.height / 1.8,
                          width: media.width,
                          child: Column(
                            children: [
                              Row(
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
                                          // HapticFeedBack.buttonClick();
                                          Navigator.pop(context);
                                        },
                                        iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "Streaks",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.verticalScale(3),
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      right: ScreenUtil.horizontalScale(4),
                                    ),
                                    child: SizedBox(
                                      width: ScreenUtil.horizontalScale(10),
                                      height: ScreenUtil.horizontalScale(10),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: media.height / 4.9,
                                width: media.width,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Your Current Streak',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil.verticalScale(2.5),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.7),
                                        ),
                                        padding: EdgeInsets.all(("${context.watch<MonthProvider>().streak}").length > 3
                                            ? 19
                                            : ("${context.watch<MonthProvider>().streak}").length > 2
                                                ? 10
                                                : ("${context.watch<MonthProvider>().streak}").length > 1
                                                    ? 5
                                                    : 2),
                                        child: Center(
                                          child: Text(
                                            '${context.watch<MonthProvider>().streak}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.verticalScale(2.6),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      SizedBox(
                        height: media.height / 3.70,
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
                      Container(
                        width: media.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(6)),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: ScreenUtil.verticalScale(4),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(ScreenUtil.horizontalScale(14), 1, ScreenUtil.horizontalScale(14), 0),
                              child: Text(
                                'Mark a day a complete every day to keep the perfect flame streak going.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ScreenUtil.verticalScale(1.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(2),
                            ),
                            const CustomCalendarWidget(),
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 25.0, //
                                horizontal: ScreenUtil.horizontalScale(10),
                              ),
                              child: Consumer<MonthProvider>(
                                builder: (context, monthProvider, child) {
                                  return ButtonWidget(
                                    text: monthProvider.todayTitleId.isEmpty ? "Completed" : "Start Your Workout",
                                    textColor: Colors.white,
                                    onPress:
                                        monthProvider.todayTitleId.isEmpty ? () {} : () => continueWorkoutOnTap(monthProvider, context),
                                    color: monthProvider.todayTitleId.isEmpty ? Colors.green : AppColors.primaryColor,
                                    isLoading: false,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(10))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil.horizontalScale(15),
                vertical: ScreenUtil.verticalScale(2),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.verticalScale(1),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Consumer<MainPageProvider>(builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          value.changeTab(0);
                        },
                        icon: SvgPicture.asset(
                          'assets/img/1-home.svg',
                          colorFilter: ColorFilter.mode(value.selectedPage == 0 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(8.5),
                          height: ScreenUtil.horizontalScale(8.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          value.changeTab(1);
                        },
                        icon: SvgPicture.asset(
                          'assets/img/2-calendar.svg',
                          colorFilter: ColorFilter.mode(value.selectedPage == 1 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(8.5),
                          height: ScreenUtil.horizontalScale(8.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          value.changeTab(2);
                        },
                        icon: SvgPicture.asset(
                          'assets/img/3-statistics.svg',
                          colorFilter: ColorFilter.mode(value.selectedPage == 2 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(8.5),
                          height: ScreenUtil.horizontalScale(8.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          value.changeTab(3);
                        },
                        icon: SvgPicture.asset(
                          'assets/img/4-account.svg',
                          colorFilter: ColorFilter.mode(value.selectedPage == 3 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                          width: ScreenUtil.horizontalScale(9),
                          height: ScreenUtil.horizontalScale(9),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  void continueWorkoutOnTap(MonthProvider monthProvider, BuildContext context) {
    HapticFeedBack.buttonClick();
    int? index = monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].idList?.indexWhere(
      (element) => element == monthProvider.todayTitleId,
    );

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
    DayDataModel dayData =
        "${monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].dayList![index ?? 0] ?? ""}".toString().contains("Workout")
            ? monthProvider.monthDataModel!.weeks![(monthProvider.week ?? 1) - 1].days![dayIndex]
            : DayDataModel();

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
      monthProvider.updatePumpDayData(monthProvider.pumpDays[
          int.parse(monthProvider.monthDataModel!.weeks![monthProvider.week! - 1].dayList![index ?? 0].toString().split(" ").last) - 1]);
    }

    monthProvider.overviewCurrentWeek = monthProvider.week ?? 1;
    monthProvider.overviewCurrentDay = ((index ?? 1) + 1);
    monthProvider.dayDataModel = dayData;
    monthProvider.alternateEquipmentType = monthProvider.equipmentType;
    monthProvider.weekDataModel = monthProvider.monthDataModel!.weeks![(monthProvider.week ?? 1) - 1];
    monthProvider.updateIsPastWeek(monthProvider.weekStatuses[(monthProvider.week ?? 1) - 1] == WeekType.pastWeek);
    Navigator.pop(context);
    Navigator.pushNamed(context, '/dayOverview');
  }
}
