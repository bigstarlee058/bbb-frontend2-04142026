import 'dart:async';

import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/pages/DashBoardScreen/dashboard_page.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/month_view_new.dart';
import 'package:bbb/pages/ProfileAndSettings/profile_settings_page.dart';
import 'package:bbb/pages/Tools/tools_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/date_notifier.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/main_page_provider.dart';
import '../providers/user_data_provider.dart';

class MainPage extends StatefulWidget {
  final bool showWelcomeModal;
  final String welcomeDescription;
  final String welcomeImageUrl;
  final bool isComeFromOnBoarding;
  const MainPage({
    super.key,
    this.showWelcomeModal = false,
    required this.welcomeDescription,
    required this.welcomeImageUrl,
    this.isComeFromOnBoarding = false,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late UserDataProvider userData;
  late DataProvider? dataProvider;
  late MainPageProvider mainPageProvider;
  late MonthProvider monthProvider;

  late List<Widget> _pages;
  Timer? _timer;

  DateTime _currentDate = DateTime.now();
  final DateStreamNotifier _dateNotifier = DateStreamNotifier();
  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    _dateNotifier.stream.listen((newDate) {
      if (_currentDate.day != newDate.day) {
        setState(() {
          _currentDate = newDate;
          monthProvider.onInit(context: context, isEnabled: false);
        });
      }
    });
    userData = Provider.of<UserDataProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await userData.fetchUserInfo();
        if (userData.user != null && !widget.isComeFromOnBoarding) {
          if (userData.user["detail"] == null ||
              userData.user["detail"]['dob'] == null ||
              userData.user["detail"]["weight"] == null) {
            if (mounted) {
              await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileBoardingScreen(
                      welcomeDescription: widget.welcomeDescription,
                      welcomeImageUrl: widget.welcomeImageUrl,
                    ),
                  ),
                  (route) => false);
            }
          }
          return;
        } else {
          if (widget.showWelcomeModal || widget.welcomeDescription.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _showWelcomeModal();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasSeenWelcome', true);
            });
          }
        }
      },
    );

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) async => await monthProvider.updateOnInitMethods(),
    // );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async => await _initializeFetchData().then(
        (value) async {
          if (monthProvider.monthDataModel == null) {
            if (mounted) {
              await monthProvider.onInit(context: context);
            }
          }
        },
      ),
    );

    _startPeriodicUpdate();
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) async {
    //     String rawMonthId = preferences.getString(SharedPreference.monthId) ?? "";
    //     String rawTempData = preferences.getString("${SplitType.split3}-$rawMonthId") ?? "";
    //     String rawTempRestDay = preferences.getString("REST-$rawMonthId") ?? "";
    //     if (rawTempData.isEmpty || rawTempRestDay.isEmpty) {
    //       await _initializeFetchData().then(
    //         (value) async {
    //           if (monthProvider.monthDataModel == null) {
    //             await monthProvider.onInit(context);
    //           }
    //         },
    //       );
    //     } else {
    //       if (monthProvider.monthDataModel == null) {
    //         await monthProvider.onInit(context);
    //       }
    //     }
    //   },
    // );

    _pages = [
      const DashboardPage(),
      const MonthViewNew(),
      const ToolsPage(),
      const ProfileSettingsPage(),
    ];
  }

  Future<void> _initializeData() async {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider?.fetchCheckoutPoint();
    if (dataProvider?.equipmentCheckpointState == true) {
      Fluttertoast.showToast(
        msg: "New Equipment Data updated!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      dataProvider?.equipmentCheckpointState = false;
    }
    if (dataProvider?.bonusCheckpointState == true) {
      Fluttertoast.showToast(
        msg: "New Bonus data updated!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      dataProvider?.bonusCheckpointState = false;
    }
    if (dataProvider?.workoutCheckpointState == true) {
      Fluttertoast.showToast(
        msg: "New Workout data updated!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _initializeFetchData();
      dataProvider?.workoutCheckpointState = false;
    }
  }

  Future<void> _initializeFetchData() async {
    debugPrint("this  is initial state func");
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider?.monthProvider = Provider.of<MonthProvider>(context, listen: false);
    if (dataProvider != null) {
      await dataProvider?.fetchMonthWorkouts(3);
    } else {
      debugPrint("dataProvider is null");
    }
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _initializeData();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showWelcomeModal() {
    Navigator.pushNamed(context, '/watchtutorial', arguments: {"buttontext": "Go to Dashboard"});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Consumer<MainPageProvider>(
        builder: (context, value, child) => Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          bottomNavigationBar: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: mainPageProvider.selectedPage != 0
                        ? () {
                            HapticFeedBack.buttonClick();
                            mainPageProvider.changeTab(0);
                          }
                        : null,
                    icon: Consumer<UserDataProvider>(
                      builder: (context, userData, child) => SvgPicture.asset(
                        'assets/img/1-home.svg',
                        colorFilter: ColorFilter.mode(
                            value.selectedPage == 0 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                        width: ScreenUtil.horizontalScale(8.5),
                        height: ScreenUtil.horizontalScale(8.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: mainPageProvider.selectedPage != 1
                        ? () {
                            HapticFeedBack.buttonClick();
                            mainPageProvider.changeTab(1);
                            monthProvider.updateIsOnMonthPage(true);
                            monthProvider.updateScrollToRestDay(false);
                          }
                        : null,
                    icon: Consumer<UserDataProvider>(
                      builder: (context, userData, child) => SvgPicture.asset(
                        'assets/img/2-calendar.svg',
                        colorFilter: ColorFilter.mode(
                            value.selectedPage == 1 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                        width: ScreenUtil.horizontalScale(8.5),
                        height: ScreenUtil.horizontalScale(8.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: mainPageProvider.selectedPage != 2
                        ? () {
                            HapticFeedBack.buttonClick();
                            mainPageProvider.changeTab(2);
                          }
                        : null,
                    icon: Consumer<UserDataProvider>(
                      builder: (context, userData, child) => SvgPicture.asset(
                        'assets/img/3-statistics.svg',
                        colorFilter: ColorFilter.mode(
                            value.selectedPage == 2 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                        width: ScreenUtil.horizontalScale(8.5),
                        height: ScreenUtil.horizontalScale(8.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: mainPageProvider.selectedPage != 3
                        ? () {
                            HapticFeedBack.buttonClick();
                            mainPageProvider.changeTab(3);
                          }
                        : null,
                    icon: Consumer<UserDataProvider>(
                      builder: (context, userData, child) => SvgPicture.asset(
                        'assets/img/4-account.svg',
                        colorFilter: ColorFilter.mode(
                            value.selectedPage == 3 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                        width: ScreenUtil.horizontalScale(9),
                        height: ScreenUtil.horizontalScale(9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: _pages[value.selectedPage],
        ),
      ),
    );
  }
}
