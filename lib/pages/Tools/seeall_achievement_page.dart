import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
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
    {"image": "assets/img/verified (1).svg", "text": "Road to Fitness", "description": 'Your First Workout'},
    {"image": "assets/img/verified (1).svg", "text": "Sprint Boost", "description": "Speed Training"},
    {"image": "assets/img/verified (1).svg", "text": "Summit Strength", "description": "Your Climbing Guide"},
    {"image": "assets/img/verified (1).svg", "text": "Core Power", "description": "Ab Workout Challenge"},
    {"image": "assets/img/verified (1).svg", "text": "Sprint Boost", "description": "Speed Training"},
    {"image": "assets/img/verified (1).svg", "text": "Yoga Zen", "description": "Mindful Yoga Journey"},
    {"image": "assets/img/verified (1).svg", "text": "Summit Strength", "description": "Your Climbing Guide"},
    {"image": "assets/img/verified (1).svg", "text": "Core Power", "description": "Ab Workout Challenge"},
    {"image": "assets/img/verified (1).svg", "text": "Sprint Boost", "description": "Speed Training"},
    {"image": "assets/img/verified (1).svg", "text": "Road to Fitness", "description": "Your First Workout"},
    {"image": "assets/img/verified (1).svg", "text": "Core Power", "description": "Ab Workout Challenge"},
    {"image": "assets/img/verified (1).svg", "text": "Sprint Boost", "description": "Speed Training"},
    {"image": "assets/img/verified (1).svg", "text": "Yoga Zen", "description": "Mindful Yoga Journey"},
    {"image": "assets/img/verified (1).svg", "text": "Summit Strength", "description": "Your Climbing Guide"},
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
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: media.height / 3.2),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.horizontalScale(15)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: media.width,
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)).copyWith(bottom: 50),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 columns
                              crossAxisSpacing: 12, // Space between columns
                              mainAxisSpacing: 34, // Space between rows
                              childAspectRatio: 0.8, // Adjust height ratio
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _buildGridItem(items[index], index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: media.height / 2,
                          width: media.width,
                        ),
                        SizedBox(
                          height: media.height,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      BackArrowWidget(
                                        onPress: () {
                                          if (mainPageProvider.selectedPage == 0) {
                                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                            mainPageProvider.changeTab(0);
                                          } else {
                                            // HapticFeedBack.buttonClick();
                                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                            mainPageProvider.changeTab(2);
                                          }
                                        },
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(8), top: ScreenUtil.horizontalScale(25)),
                                        child: Consumer<UserDataProvider>(builder: (context, userData, child) {
                                          return Text(
                                            // 'Hi, Nick',
                                            'Achievement',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.horizontalScale(5.5),
                                            ),
                                          );
                                        }),
                                      ),
                                      const CommonStreakWithNotification(routeString: '/graphAndReports')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.height / 3.19,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(Map<String, String> item, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents extra space
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Container (Fixed size)
          SizedBox(
            height: 70, // Reduce height for better spacing
            width: 70,
            child: SvgPicture.asset(
              item["image"]!,
              color: index == 1 ? AppColors.primaryColor : Colors.grey,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 5),

          // Title
          Text(
            item["text"]!,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),

          // Description (Fixes Cut-Off Issue)
          Flexible(
            child: Text(
              item["description"]!,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible, // Ensures it is readable
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
