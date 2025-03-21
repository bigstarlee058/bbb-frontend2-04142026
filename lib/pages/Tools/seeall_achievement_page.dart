import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
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
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
    {"image": "assets/img/verified (1).svg"},
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
                                SizedBox(
                                  width: media.width * 0.4,
                                  child: Text(
                                    "Here's a look at your achievements",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.horizontalScale(4.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
                    child: Column(
                      children: [
                        Container(
                          width: media.width,
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)).copyWith(bottom: 50),
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 20, childAspectRatio: 0.8),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Container(color: Colors.transparent, child: _buildGridItem(items[index], index));
                            },
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

  Widget _buildGridItem(Map<String, String> item, int index) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: SvgPicture.asset(
              item["image"]!,
              color: index == 1 ? AppColors.primaryColor : Colors.grey,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Lorem ipsum",
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: index == 1 ? AppColors.primaryColor : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Flexible(
            child: Text(
              "Lorem ipsum dolor",
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 11,
                color: index == 1 ? AppColors.primaryColor : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
