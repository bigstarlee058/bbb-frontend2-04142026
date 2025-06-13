import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/setting_section.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localstorage/month_prefrence.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool? isSwitchOn = true;
  bool? isHapticFeedbackOn = true;
  late MainPageProvider mainPageProvider;
  late MonthProvider monthProvider;
  DataProvider? dataProvider;

  @override
  void initState() {
    getSwitch();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    super.initState();
  }

  Future<void> getSwitch() async {
    final raw1 = await preferences.getBool(SharedPreference.notificationSwitch);
    final raw2 = await preferences.getBool(SharedPreference.isHapticFeedbackOn);
    if (raw1 != null) {
      isSwitchOn = raw1;
    } else {
      await preferences.setBool(SharedPreference.notificationSwitch, isSwitchOn ?? false);
    }
    if (raw2 != null) {
      isHapticFeedbackOn = raw2;
    } else {
      await preferences.setBool(SharedPreference.isHapticFeedbackOn, isHapticFeedbackOn ?? false);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        // physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        // Container(
                        //   height: media.height / 1,
                        //   width: media.width,
                        //   decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //       image: AssetImage('assets/img/back.jpg'),
                        //       fit: BoxFit.cover,
                        //       opacity: 1,
                        //     ),
                        //   ),
                        // ),
                        Utils.appImage(
                          media,
                          // dataProvider?.screenBackgroundResponse?.imageSetting ?? "",
                          image: dataProvider!.cachedImageMap["imageSetting"],

                          imageKey: "imageSetting",
                        ),
                        SizedBox(
                          height: media.height / 1.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                                  surfaceTintColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  centerTitle: true,
                                  leading: BackArrowWidget(
                                    onPress: () {
                                      // HapticFeedBack.buttonClick();
                                      // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                      // mainPageProvider.changeTab(2);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
                                    )
                                  ],
                                ),
                                // Container(
                                //   margin: EdgeInsets.only(
                                //     right: ScreenUtil.horizontalScale(3),
                                //   ),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       BackArrowWidget(
                                //         onPress: () {
                                //           // HapticFeedBack.buttonClick();
                                //           // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                //           // mainPageProvider.changeTab(3);
                                //           Navigator.pop(context);
                                //         },
                                //       ),
                                //       const CommonStreakWithNotification(routeString: '/myprofile')
                                //     ],
                                //   ),
                                // ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(10),
                                      vertical: ScreenUtil.verticalScale(10)),
                                  child: Center(
                                    child: Text(
                                      'Settings',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.horizontalScale(8),
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 2.64,
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
                  margin: EdgeInsets.only(top: media.height / 2.65),
                  width: media.width,
                  constraints: BoxConstraints(
                    minHeight: (media.height - (media.height / 4) - (media.height * 0.12)),
                  ),
                  // height: ScreenUtil.verticalScale((media.height - media.height / 2)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: ScreenUtil.verticalScale(3.5)),
                      // _buildProfileField(
                      //   context: context,
                      //   label: "Units of measurement",
                      //   isFirstSelected: isSelected,
                      //   onFirstTap: () {
                      //     setState(() {
                      //       isSelected = true;
                      //     });
                      //   },
                      //   onSecondTap: () {
                      //     setState(() {
                      //       isSelected = false;
                      //     });
                      //   },
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      //   child: Divider(
                      //     thickness: 0.3,
                      //     height: 0,
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.only(
                          left: ScreenUtil.horizontalScale(6),
                          right: ScreenUtil.horizontalScale(6),
                          top: ScreenUtil.verticalScale(2),
                        ),
                        height: ScreenUtil.verticalScale(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Enable notifications?",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Consumer<MonthProvider>(builder: (context, monthDataModel, child) {
                              return Switch(
                                value: isSwitchOn ?? false, // Boolean value
                                onChanged: (bool value) async {
                                  setState(() {
                                    isSwitchOn = value; // Update state
                                  });
                                  await preferences.setBool(SharedPreference.notificationSwitch, isSwitchOn ?? false);
                                  if (isSwitchOn == true) {
                                    await NotificationService.scheduleMonthlyReminder(
                                        20, monthDataModel.endTime ?? DateTime.now().toUtc());
                                    await NotificationService.scheduleWeekReminder(
                                        30, monthDataModel.endTime ?? DateTime.now().toUtc());
                                  } else {
                                    await NotificationService.clearScheduledNotification();
                                  }
                                },
                                activeColor: AppColors.primaryColor,
                              );
                            }),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(ScreenUtil.horizontalScale(7), 0, ScreenUtil.horizontalScale(7), 0),
                        child: Divider(
                          thickness: 0.3,
                          height: 0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: ScreenUtil.horizontalScale(6),
                          right: ScreenUtil.horizontalScale(6),
                          bottom: ScreenUtil.verticalScale(0.8),
                        ),
                        height: ScreenUtil.verticalScale(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Haptic Feedback?",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Consumer<MonthProvider>(
                              builder: (context, monthDataModel, child) {
                                return Switch(
                                  value: isHapticFeedbackOn ?? false, // Boolean value
                                  onChanged: (bool value) async {
                                    setState(() {
                                      isHapticFeedbackOn = value; // Update state
                                    });
                                    await preferences.setBool(
                                        SharedPreference.isHapticFeedbackOn, isHapticFeedbackOn ?? false);
                                  },
                                  activeColor: AppColors.primaryColor,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(ScreenUtil.horizontalScale(7), 0, ScreenUtil.horizontalScale(7), 0),
                        child: Divider(
                          thickness: 0.3,
                          height: 0,
                        ),
                      ),
                      SettingSection(
                        monthProvider: monthProvider,
                        isSetting: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Profile Field for Birthday and Other Text Inputs

// Dropdown Field for Gender, Location, etc.
}
