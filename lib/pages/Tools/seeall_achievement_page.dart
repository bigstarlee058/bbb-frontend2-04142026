import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/share_achievement_dialog.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/screen_util.dart';

class SeeAllAchievementPage extends StatefulWidget {
  const SeeAllAchievementPage({super.key});

  @override
  State<SeeAllAchievementPage> createState() => _SeeAllAchievementPageState();
}

class _SeeAllAchievementPageState extends State<SeeAllAchievementPage> {
  late MainPageProvider mainPageProvider;

  MonthProvider? monthProvider;
  final List<Map<String, String>> items = [
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "Breaking the Ice",
      "subtitle": "Your First Workout Finished"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "I Got This",
      "subtitle": "First Week Finished"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "I'm Determined ",
      "subtitle": "First Month Finished"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "3 in a Row",
      "subtitle": "Achieved the streak of 3"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "7 in a Row",
      "subtitle": "Achieved the streak of 7"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "14 in a Row",
      "subtitle": "Achieved the Streak of 14"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "30 in a row",
      "subtitle": "Achieved teh streak of 30"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "250k Monster",
      "subtitle": "Total Weight Lifted > 250k lbs"
    },
    {
      "image": "assets/img/verified (1).svg",
      "active_image": "assets/img/verified (1).svg",
      "title": "500k Monster",
      "subtitle": "Total Weight Lifted > 500k lbs"
    },
  ];

  @override
  void initState() {
    super.initState();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
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
                          height: media.height / 2.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  centerTitle: true,
                                  backgroundColor: Colors.transparent,
                                  leading: BackArrowWidget(
                                    onPress: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  title: Text(
                                    'Achievements',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(routeString: '/equipmentLibrary'),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Here's a look at your\nachievements",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.verticalScale(1.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 4.59,
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
                  margin: EdgeInsets.only(top: media.height / 4.6),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                      ),
                    ),
                    child: Container(
                      width: media.width,
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(4)),
                      child: GridView.builder(
                        padding: EdgeInsets.only(top: ScreenUtil.verticalScale(3)),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: ScreenUtil.horizontalScale(1),
                            mainAxisSpacing: ScreenUtil.horizontalScale(1),
                            childAspectRatio: 0.8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildGridItem(items[index], index);
                        },
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

  Widget _buildGridItem(Map<String, String> item, int index) {
    return GestureDetector(
      onTap: () {
        AnimatedDialog.showAnimatedDialog(
          context: context,
          builder: (BuildContext context) => ShareAchievementDialog(
            title: item["title"]!,
            imagePath: item["image"]!,
            subtitle: item["subtitle"]!,
            time: DateTime.now(),
          ),
          curve: Curves.fastOutSlowIn,
        );
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: ScreenUtil.verticalScale(9),
              width: ScreenUtil.verticalScale(9),
              child: SvgPicture.asset(
                item["image"]!,
                colorFilter: ColorFilter.mode(index == 0 ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 5),
            Text(
              item["title"]!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.45),
                color: index == 0 ? AppColors.primaryColor : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1),
            Flexible(
              child: Text(
                item["subtitle"]!,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.1),
                  color: index == 0 ? AppColors.primaryColor : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
