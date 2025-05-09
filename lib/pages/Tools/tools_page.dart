import 'dart:io';

import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/tools_page_button.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final List<Map<String, String>> items = [
    {
      "image": "assets/img/verified (1).svg",
    },
  ];
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
                          height: media.height / 1,
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
                          height: media.height / 4,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1), surfaceTintColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  centerTitle: true,
                                  // leading: BackArrowWidget(
                                  //   onPress: () {
                                  //     // HapticFeedBack.buttonClick();
                                  //     // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                  //     // mainPageProvider.changeTab(2);
                                  //     Navigator.pop(context);
                                  //   },
                                  // ),
                                  leading: SizedBox(),
                                  title: Text(
                                    'Tools',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(routeString: '/exerciseLibrary'),
                                    )
                                  ],
                                ),
                                // Container(
                                //   margin: const EdgeInsets.only(right: 10, bottom: 0),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       SizedBox(
                                //         height: 15,
                                //         width: media.width / 5,
                                //       ),
                                //       Padding(
                                //         padding: EdgeInsets.only(
                                //           top: ScreenUtil.verticalScale(1),
                                //         ),
                                //         child: Row(
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             Text(
                                //               'Tools',
                                //               style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: ScreenUtil.verticalScale(2.5),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       const CommonStreakWithNotification(routeString: "tool"),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Platform.isAndroid ? media.height / 8.39 : media.height / 6.99,
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
                  margin: EdgeInsets.only(top: Platform.isAndroid ? media.height / 8.5 : media.height / 7),
                  child: Container(
                    width: media.width,
                    constraints: BoxConstraints(minHeight: (media.height - (Platform.isAndroid ? media.height / 8.5 : media.height / 7))),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: media.width,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(55),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(6),
                              vertical: ScreenUtil.verticalScale(3),
                            ),
                            child: Column(
                              children: [
                                const ToolsPageButton(
                                  title: 'Exercise Library',
                                  icon: 'assets/icons/exercise_library.svg',
                                  url: '/exerciseLibrary',
                                ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(1.3),
                                ),
                                const ToolsPageButton(
                                  title: 'Graphs & Reports',
                                  icon: 'assets/icons/graphs.svg',
                                  url: '/graphAndReports',
                                ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(1.3),
                                ),
                                const ToolsPageButton(
                                  title: 'Achievements',
                                  icon: 'assets/img/verified (1).svg',
                                  url: '/seeAllAchievementPage',
                                ),

                                /// TEMP HIDE
                                // SizedBox(
                                //   height: ScreenUtil.verticalScale(1.3),
                                // ),
                                // const ToolsPageButton(
                                //   title: 'Nutrition Calculator',
                                //   icon: 'assets/icons/nutrition.svg',
                                //   url: '/nutritionCalculator',
                                // ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(1.3),
                                ),
                                const ToolsPageButton(
                                  title: 'Apparel & Equipment',
                                  icon: 'assets/icons/apparel.svg',
                                  url: '/equipmentLibrary',
                                ),

                                SizedBox(
                                  height: ScreenUtil.verticalScale(1.3),
                                ),
                                const ToolsPageButton(
                                  title: 'FAQs',
                                  icon: 'assets/icons/faqs.svg',
                                  url: '/faqs',
                                ),

                                /// TEMP HIDE
                                // SizedBox(
                                //   height: ScreenUtil.verticalScale(1.3),
                                // ),
                                // const ToolsPageButton(
                                //   title: 'Bonuses',
                                //   icon: 'assets/icons/bonuses.svg',
                                //   url: '/bonusLibrary',
                                // ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(12),
                                ),
                              ],
                            ),
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
