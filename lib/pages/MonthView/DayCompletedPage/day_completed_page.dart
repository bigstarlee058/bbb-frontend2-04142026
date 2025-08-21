import 'dart:io';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../localstorage/month_prefrence.dart';

class DayCompletedPage extends StatefulWidget {
  const DayCompletedPage({super.key, required this.dayTitle});
  final String dayTitle;

  @override
  State<DayCompletedPage> createState() => _DayCompletedPageState();
}

class _DayCompletedPageState extends State<DayCompletedPage> {
  MonthProvider? monthProvider;
  MainPageProvider? mainPageProvider;
  DateTime today = DateTime.now();
  List<DayHistoryModel> data = [];
  double totalWeight = 0;
  int exerciseCompleted = 0;
  double averageRIR = 0;
  String time = "";
  bool loader = true;
  bool isKg = true;
  bool isOnTap = false;
  List<String> getLast7DayNames() {
    List<String> dayNames = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dayName = DateFormat('EEE').format(date);
      dayNames.add(dayName);
    }
    return dayNames;
  }

  updateOnTap(bool value) {
    isOnTap = value;
    setState(() {});
  }

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => onInit());
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        isKg = await preferences.getBool(SharedPreference.isKG) ?? false;
      },
    );
    super.initState();
  }

  List<DateTime> dateList = [];
  List<String> formattedDates = [];
  List<String> last7Days = [];

  onInit() async {
    time = "";
    totalWeight = 0;
    exerciseCompleted = 0;
    averageRIR = 0;
    data = monthProvider!.decodedDataAll();
    DateTime oneWeekAgo = today.subtract(const Duration(days: 6));
    dateList =
        List.generate(7, (index) => oneWeekAgo.add(Duration(days: index)));
    formattedDates =
        dateList.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();
    last7Days = getLast7DayNames();

    DayHistoryModel? data1 = monthProvider?.allDayHistoryModel.firstWhere(
      (element) {
        String split = monthProvider?.monthDataModel
                ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
                .toString()
                .split(" ")[1] ??
            "";
        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id ?? monthProvider?.monthDataModel?.weeks?[(monthProvider?.overviewCurrentWeek)! - 1].id}-${monthProvider?.currentDayTitleId}";
        return element.dataId == dataId;
      },
    );

    if (data1 != null) {
      final startTime = data1.startTime!;
      final endTime = data1.endTime!;

      DateTime localStartTime = Utils.formattedDate("$startTime");
      DateTime localEndTime = Utils.formattedDate("$endTime");
      int duration = localEndTime.difference(localStartTime).inSeconds;
      time = formatDuration(duration);
      totalWeight = double.parse(data1.totalWeight ?? "0");
      exerciseCompleted = int.parse(data1.completedExercise ?? "0");
      averageRIR = double.parse(
          data1.averageRIR == "NaN" ? "0" : data1.averageRIR ?? "0");
    }

    setState(() {});
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '$hours Hour${hours < 1 ? "s" : ""}\n$minutes Minute${minutes < 1 ? "s" : ""}';
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return SafeArea(
      top: false,
      bottom: Platform.isAndroid ? true : false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            captureScreenShot(media),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: media.height,
                  width: media.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/back.jpg'),
                        fit: BoxFit.cover,
                        opacity: 1),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, '/streak-calendar');
                            },
                            icon: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(
                                      ScreenUtil.verticalScale(0.65)),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Consumer<MonthProvider>(
                                      builder: (context, monthProvider, child) {
                                    return Text(
                                      monthProvider.streak.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.verticalScale(0.8),
                                      ),
                                    );
                                  }),
                                ),
                                Icon(
                                  Icons.local_fire_department_outlined,
                                  color: Colors.white,
                                  size: ScreenUtil.verticalScale(3),
                                )
                              ],
                            ),
                          ),
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
                          SizedBox(height: ScreenUtil.verticalScale(5)),
                          Text(
                            'Congratulations!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.horizontalScale(8.5),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: ScreenUtil.verticalScale(1)),
                          Text(
                            'You completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(1.9),
                            ),
                          ),
                          SizedBox(height: ScreenUtil.verticalScale(0.8)),
                          Text(
                            "${ModalRoute.of(context)?.settings.arguments as String?}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.horizontalScale(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: media.height / 2.449,
                    width: media.width,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ClipPath(
                        clipper: DiagonalClipper(),
                        child: Container(
                          height: media.height / 11,
                          width: media.width / 6,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.verticalScale(3),
                              vertical: ScreenUtil.verticalScale(2.5)),
                          child: Column(
                            children: [
                              IconRow(
                                fromHomeScreen: false,
                                icons: List.generate(
                                  formattedDates.length,
                                  (index) => data.any((element) =>
                                          DateFormat('yyyy-MM-dd').format(
                                                  Utils.formattedDate(element
                                                      .endTime!
                                                      .toString())) ==
                                              formattedDates[index] &&
                                          element.status == Status.completed)
                                      ? IconDataWithDot(
                                          index: index,
                                          day: last7Days[6 - index],
                                          icon: Icons.check,
                                          iconColor: Colors.white,
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          showDot: true,
                                          dotColor: Colors.transparent)
                                      : IconDataWithDot(
                                          index: index,
                                          day: last7Days[6 - index],
                                          icon: Icons.close,
                                          iconColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          showDot: true,
                                          dotColor: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Here's an overview of your today's workout.",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: ScreenUtil.horizontalScale(3.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Now recover and get ready for tomorrow!",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: ScreenUtil.horizontalScale(3.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: ScreenUtil.verticalScale(2.5)),
                        GestureDetector(
                          onTap: () {
                            monthProvider?.updateGraphType("Exercise");
                            Navigator.pushNamed(context, '/graphAndReports');
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(8)),
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.verticalScale(4.1),
                                vertical: ScreenUtil.verticalScale(2)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
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
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Exercises Completed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                        fontSize: 16.5),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "$exerciseCompleted",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFDD1166),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(8),
                              vertical: ScreenUtil.verticalScale(2.5)),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // monthProvider?.updateGraphType("Weight");
                                    // Navigator.pushNamed(
                                    //     context, '/graphAndReports');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil.verticalScale(2)),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil.verticalScale(3)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Weight Lifted',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 16.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Builder(
                                          builder: (context) {
                                            final cValue = isKg
                                                ? Utils.formatDouble(
                                                    (totalWeight) * 0.45359237)
                                                : totalWeight;
                                            return Text(
                                              "${NumberFormat.decimalPattern('en_US').format(double.parse("$cValue"))}${isKg ? 'kg' : 'lbs'}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color(0xFFDD1166),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.horizontalScale(4.5)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // monthProvider?.updateGraphType("RIR");
                                    //
                                    // Navigator.pushNamed(
                                    //     context, '/graphAndReports');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil.verticalScale(2)),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil.verticalScale(3)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Streak Achieved',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 16.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Consumer<MonthProvider>(
                                            builder: (context, value, c) {
                                          return Text(
                                            "${value.streak}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Color(0xFFDD1166),
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(7)),
                          child: ButtonWidget(
                            text: "Back to Dashboard",
                            // textColor: const Color(0x40000000),
                            textColor: Colors.white,
                            onPress: () {
                              if (monthProvider!.isPumpDay) {
                                monthProvider?.checkForPumpDay();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                monthProvider?.checkForPumpDay();
                                mainPageProvider?.changeTab(0);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (route) => false);
                              }
                              // HapticFeedBack.buttonClick();

                              // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                            },
                            // color: const Color(0xC0FFFFFF),
                            color: AppColors.primaryColor,
                            isLoading: false,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(7))
                              .copyWith(
                                  bottom: ScreenUtil.verticalScale(3),
                                  top: ScreenUtil.verticalScale(1)),
                          child: GestureDetector(
                            onTap: isOnTap
                                ? null
                                : () async {
                                    HapticFeedBack.buttonClick();
                                    updateOnTap(true);
                                    try {
                                      await screenshotController
                                          .capture(
                                              delay:
                                                  Duration(milliseconds: 200))
                                          .then(
                                        (image) async {
                                          if (image == null) return;
                                          final directory =
                                              await getTemporaryDirectory();
                                          final imagePath = File(
                                              '${directory.path}/screenshot.png');
                                          await imagePath.writeAsBytes(image);
                                          await Share.shareXFiles([
                                            XFile(imagePath.path)
                                          ], text: 'I just completed ${ModalRoute.of(context)?.settings.arguments as String?} of Booty By Bret! Join me in the app at https://bootybybret.com')
                                              .then(
                                            (value) {
                                              updateOnTap(false);
                                            },
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      debugPrint(
                                          'Error capturing and sharing screenshot: $e');
                                    }
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil.verticalScale(1.7),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                borderRadius: Utils.buttonRadius,
                              ),
                              child: Center(
                                child: isOnTap
                                    ? SizedBox(
                                        width: ScreenUtil.verticalScale(3.2),
                                        height: ScreenUtil.verticalScale(3.2),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ))
                                    : Text(
                                        "Share",
                                        style: TextStyle(
                                          fontSize:
                                              ScreenUtil.verticalScale(2.2),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
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
    );
  }

  final myThemeData = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.red,
    ),
  );
  final ScreenshotController screenshotController = ScreenshotController();

  captureScreenShot(Size media) {
    return Screenshot(
      controller: screenshotController,
      child: SizedBox(
        height: media.height * 0.83,
        width: media.width,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: media.height,
                  width: media.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/back.jpg'),
                        fit: BoxFit.cover,
                        opacity: 1),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {},
                            icon: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(
                                      ScreenUtil.verticalScale(0.65)),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Consumer<MonthProvider>(
                                      builder: (context, monthProvider, child) {
                                    return Text(
                                      monthProvider.streak.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.verticalScale(0.8),
                                      ),
                                    );
                                  }),
                                ),
                                Icon(
                                  Icons.local_fire_department_outlined,
                                  color: Colors.white,
                                  size: ScreenUtil.verticalScale(3),
                                )
                              ],
                            ),
                          ),
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
                          SizedBox(height: ScreenUtil.verticalScale(6)),
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
                          SizedBox(height: ScreenUtil.verticalScale(0.8)),
                          Text(
                            "${ModalRoute.of(context)?.settings.arguments as String?}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.horizontalScale(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: media.height / 2.449,
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
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.verticalScale(3),
                              vertical: ScreenUtil.verticalScale(2.5)),
                          child: Column(
                            children: [
                              IconRow(
                                fromHomeScreen: false,
                                icons: List.generate(
                                  formattedDates.length,
                                  (index) => data.any((element) =>
                                          DateFormat('yyyy-MM-dd').format(
                                                  Utils.formattedDate(element
                                                      .endTime!
                                                      .toString())) ==
                                              formattedDates[index] &&
                                          element.status == Status.completed)
                                      ? IconDataWithDot(
                                          index: index,
                                          day: last7Days[6 - index],
                                          icon: Icons.check,
                                          iconColor: Colors.white,
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          showDot: true,
                                          dotColor: Colors.transparent)
                                      : IconDataWithDot(
                                          index: index,
                                          day: last7Days[6 - index],
                                          icon: Icons.close,
                                          iconColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          showDot: true,
                                          dotColor: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Here's an overview of your today's workout.",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: ScreenUtil.horizontalScale(3.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Now recover and get ready for tomorrow!",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: ScreenUtil.horizontalScale(3.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: ScreenUtil.verticalScale(2.5)),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(8)),
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.verticalScale(4.1),
                              vertical: ScreenUtil.verticalScale(2)),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
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
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Exercises Completed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                      fontSize: 16.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "$exerciseCompleted",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFDD1166),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(8),
                              vertical: ScreenUtil.verticalScale(2.5)),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // monthProvider?.updateGraphType("Weight");
                                    // Navigator.pushNamed(
                                    //     context, '/graphAndReports');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil.verticalScale(2)),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil.verticalScale(3)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Weight Lifted',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 16.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Builder(
                                          builder: (context) {
                                            final cValue = isKg
                                                ? Utils.formatDouble(
                                                    (totalWeight) * 0.45359237)
                                                : totalWeight;
                                            return Text(
                                              "${NumberFormat.decimalPattern('en_US').format(double.parse("$cValue"))}lbs",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color(0xFFDD1166),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.horizontalScale(4.5)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // monthProvider?.updateGraphType("RIR");
                                    // Navigator.pushNamed(
                                    //     context, '/graphAndReports');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil.verticalScale(2)),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil.verticalScale(3)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Streak Achieved',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 16.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Consumer<MonthProvider>(
                                          builder: (context, value, c) {
                                            return Text(
                                              "${value.streak}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Color(0xFFDD1166),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
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
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class IconRow extends StatelessWidget {
  final List<IconDataWithDot> icons;
  final bool fromHomeScreen;

  const IconRow({super.key, required this.icons, required this.fromHomeScreen});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Row(
      mainAxisAlignment: fromHomeScreen
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: icons
          .map(
            (iconData) => IconWithDot(iconData: iconData),
          )
          .toList(),
    );
  }
}

class IconDataWithDot {
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showDot;
  final Color? dotColor;
  final String? day;
  final int? index;

  IconDataWithDot({
    required this.icon,
    required this.day,
    required this.iconColor,
    required this.backgroundColor,
    required this.dotColor,
    required this.index,
    this.borderColor,
    this.showDot = false,
  });
}

class IconWithDot extends StatelessWidget {
  final IconDataWithDot iconData;

  const IconWithDot({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Container(
      padding: iconData.index == 6
          ? EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(2),
              vertical: ScreenUtil.verticalScale(1))
          : EdgeInsets.zero,
      decoration: iconData.index == 6
          ? BoxDecoration(
              color: AppColors.backOffSetColor,
              borderRadius: BorderRadius.circular(20))
          : BoxDecoration(),
      child: Column(
        children: [
          Text(
            iconData.day ?? "",
            style: TextStyle(
              color: iconData.index == 6
                  ? Colors.black
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Container(
            padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
            margin: EdgeInsets.only(top: ScreenUtil.verticalScale(1)),
            decoration: BoxDecoration(
              color: iconData.backgroundColor,
              shape: BoxShape.circle,
              border: iconData.borderColor != null
                  ? Border.all(color: iconData.borderColor!)
                  : null,
            ),
            child: iconData.icon != null
                ? Icon(
                    iconData.icon,
                    color: iconData.iconColor,
                    size: ScreenUtil.verticalScale(
                      2.75,
                    ),
                  )
                : Icon(
                    null,
                    size: ScreenUtil.verticalScale(
                      2.75,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
