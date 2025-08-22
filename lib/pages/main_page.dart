import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/DashBoardScreen/dashboard_page.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/month_view.dart';
import 'package:bbb/pages/ProfileAndSettings/profile_settings_page.dart';
import 'package:bbb/pages/Tools/tools_page.dart';
import 'package:bbb/pages/WatchTutorial/watch_tutorial.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/date_notifier.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/main_page_provider.dart';
import '../providers/user_data_provider.dart';
import 'IntroScreen/version_update_screen.dart';

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

  Timer? _timer;

  DateTime _currentDate = DateTime.now();
  final DateStreamNotifier _dateNotifier = DateStreamNotifier();

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  // Future<bool> navigateAppVersion() async {
  //   PackageInfo version = await getCurrentAppVersion();
  //
  //   await Future.delayed(Duration(milliseconds: 200));
  //   if (Platform.isIOS) {
  //     if (version.version !=
  //         (dataProvider?.newVersionModel?.ios?.version ?? "")) {
  //       if (dataProvider!.newVersionModel!.ios!.forceUpdate == true) {
  //         if (mounted) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => VersionUpdateScreen(),
  //             ),
  //           );
  //         }
  //       } else {
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => VersionUpdateScreen(),
  //             ),
  //           );
  //         }
  //       }
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else if (Platform.isAndroid) {
  //     if (version.version !=
  //         (dataProvider?.newVersionModel?.android?.version ?? "")) {
  //       if (dataProvider!.newVersionModel!.android!.forceUpdate == true) {
  //         if (mounted) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => VersionUpdateScreen(),
  //             ),
  //           );
  //         }
  //       } else {
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => VersionUpdateScreen(),
  //             ),
  //           );
  //         }
  //       }
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  Future<bool> navigateAppVersion() async {
    final bool isIOS = Platform.isIOS;
    final bool isPopupEnable = isIOS
        ? (dataProvider?.newVersionModel?.ios?.showPopUp ?? false)
        : (dataProvider?.newVersionModel?.android?.showPopUp ?? false);

    if (isPopupEnable == false) return false;

    final PackageInfo version = await getCurrentAppVersion();
    await Future.delayed(const Duration(milliseconds: 200));

    final String currentVersion = version.version;

    final String? requiredVersion = isIOS
        ? dataProvider?.newVersionModel?.ios?.version
        : dataProvider?.newVersionModel?.android?.version;
    final bool forceUpdate = isIOS
        ? (dataProvider?.newVersionModel?.ios?.forceUpdate ?? false)
        : (dataProvider?.newVersionModel?.android?.forceUpdate ?? false);

    bool shouldShowPopup =
        _isLowerVersion(currentVersion, requiredVersion ?? "");

    if (!shouldShowPopup) return false;

    // if (currentVersion == (requiredVersion ?? "")) return false;

    if (mounted) {
      final route = MaterialPageRoute(builder: (_) => VersionUpdateScreen());
      forceUpdate
          ? await Navigator.pushReplacement(context, route)
              .then((value) => showInitialDialog())
          : await Navigator.push(context, route)
              .then((value) => showInitialDialog());
    }
    return true;
  }

  bool _isLowerVersion(String current, String required) {
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> requiredParts =
        required.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < requiredParts.length; i++) {
      int currentVal = i < currentParts.length ? currentParts[i] : 0;
      int requiredVal = requiredParts[i];
      if (currentVal < requiredVal) return true;
      if (currentVal > requiredVal) return false;
    }
    return false;
  }

  void showInitialDialog() {
    if (widget.showWelcomeModal || widget.welcomeDescription.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _showWelcomeModal();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenWelcome', true);
      });
    }
  }

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

    /// UPDATE POP-UP

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      bool isUpdatePopUP =
          await preferences.getBool(SharedPreference.isUpdatePopUP) ?? false;

      final bool isIOS = Platform.isIOS;
      final bool isPopupEnable = isIOS
          ? (dataProvider?.newVersionModel?.ios?.showPopUp ?? false)
          : (dataProvider?.newVersionModel?.android?.showPopUp ?? false);

      if (isUpdatePopUP == false && isPopupEnable == true) {
        bool versionScreenOpened = await navigateAppVersion();
        if (!versionScreenOpened) {
          showInitialDialog();
        }
      } else {
        showInitialDialog();
      }
    });

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

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _startPeriodicUpdate();
      },
    );

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
    dataProvider?.monthProvider =
        Provider.of<MonthProvider>(context, listen: false);
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
        if (!mounted) return;
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
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        AnimatedDialog.showAnimatedDialog(
          context: context,
          pageBuilder: (c1, anim1, anim2) => WatchTutorial(),
        );
      },
    );

    // Navigator.pushNamed(context, '/watchtutorial',
    //     arguments: {"buttontext": "Go to Dashboard"});
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const MonthView(),
    const ToolsPage(),
    const ProfileSettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Container(
      height: ScreenUtil.verticalScale(100),
      width: ScreenUtil.horizontalScale(100),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: AnnotatedRegion(
          value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light),
          child: Consumer<MainPageProvider>(
            builder: (context, value, child) => Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              bottomNavigationBar: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.horizontalScale(15),
                  vertical: ScreenUtil.verticalScale(Platform.isIOS ? 2.5 : 1),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.verticalScale(1),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(ScreenUtil.verticalScale(5)),
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
                          builder: (context, userData, child) =>
                              SvgPicture.asset(
                            'assets/img/1-home.svg',
                            colorFilter: ColorFilter.mode(
                                value.selectedPage == 0
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn),
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
                          builder: (context, userData, child) =>
                              SvgPicture.asset(
                            'assets/img/2-calendar.svg',
                            colorFilter: ColorFilter.mode(
                                value.selectedPage == 1
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn),
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
                          builder: (context, userData, child) =>
                              SvgPicture.asset(
                            'assets/img/3-statistics.svg',
                            colorFilter: ColorFilter.mode(
                                value.selectedPage == 2
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn),
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
                          builder: (context, userData, child) =>
                              SvgPicture.asset(
                            'assets/img/4-account.svg',
                            colorFilter: ColorFilter.mode(
                                value.selectedPage == 3
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn),
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
        ),
      ),
    );
  }
}
