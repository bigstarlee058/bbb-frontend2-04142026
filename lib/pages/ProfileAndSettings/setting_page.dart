import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
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
  @override
  void initState() {
    getSwitch();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
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
                        SizedBox(
                          height: media.height / 1.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    right: ScreenUtil.horizontalScale(3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      BackArrowWidget(
                                        onPress: () {
                                          // HapticFeedBack.buttonClick();
                                          // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                          // mainPageProvider.changeTab(3);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const CommonStreakWithNotification(routeString: '/myprofile')
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(10), vertical: ScreenUtil.verticalScale(10)),
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
                  margin: EdgeInsets.only(top: media.height / 2.65, bottom: ScreenUtil.verticalScale(15)),
                  width: media.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(6)),
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
                                    await NotificationService.scheduleMonthlyReminder(20, monthDataModel.endTime ?? DateTime.now().toUtc());
                                    await NotificationService.scheduleWeekReminder(30, monthDataModel.endTime ?? DateTime.now().toUtc());
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
                        padding: EdgeInsets.fromLTRB(ScreenUtil.horizontalScale(7), 0, ScreenUtil.horizontalScale(7), 0),
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
                                    await preferences.setBool(SharedPreference.isHapticFeedbackOn, isHapticFeedbackOn ?? false);
                                  },
                                  activeColor: AppColors.primaryColor,
                                );
                              },
                            ),
                          ],
                        ),
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
  Widget _buildProfileField({
    required BuildContext context,
    required String label,
    required bool isFirstSelected,
    required VoidCallback onFirstTap,
    required VoidCallback onSecondTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(9),
      ),
      height: ScreenUtil.verticalScale(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          _buildOption("lb/in", isFirstSelected, onFirstTap),
          SizedBox(width: 15),
          _buildOption("kg/cm", !isFirstSelected, onSecondTap),
        ],
      ),
    );
  }

  Widget _buildOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Ensure the whole area is clickable
      child: Column(
        children: [
          Container(
            width: 21, // Outer circle size
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 2), // Outer border
            ),
            child: Padding(
              padding: EdgeInsets.all(2), // Creates space between inner circle and border
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryColor : Colors.transparent, // Inner circle color
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

// Dropdown Field for Gender, Location, etc.
  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: ScreenUtil.verticalScale(0.8)),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.horizontalScale(1),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScreenUtil.verticalScale(5),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20888888),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                // Center the dropdown content
                child: DropdownButton<String>(
                  value: value,
                  dropdownColor: const Color.fromARGB(255, 252, 252, 252),
                  elevation: 12,
                  hint: Text(hint),
                  isDense: true,
                  isExpanded: true,
                  alignment: Alignment.center,
                  // Align the dropdown text to the center
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        // Center the individual items in dropdown
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  underline: Container(),
                ),

                // DropdownButton<String>(
                //   value: value,
                //   hint: Text(hint),
                //   isExpanded: true,
                //   alignment: Alignment.center, // Align the dropdown text to the center
                //   items: options.map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Center(
                //         // Center the individual items in dropdown
                //         child: Text(value),
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (String? newValue) {
                //     setState(() {
                //       value = newValue;
                //     });
                //   },
                //   underline: Container(),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
