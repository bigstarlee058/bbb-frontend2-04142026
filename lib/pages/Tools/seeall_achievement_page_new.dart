import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/share_achievement_new_dialog.dart';
import 'package:bbb/models/get_all_achivements.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/clip_path.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/screen_util.dart';

class SeeAllAchievementPage extends StatefulWidget {
  const SeeAllAchievementPage({super.key});

  @override
  State<SeeAllAchievementPage> createState() => _SeeAllAchievementPageState();
}

class _SeeAllAchievementPageState extends State<SeeAllAchievementPage> {
  late MainPageProvider mainPageProvider;
  DataProvider? dataProvider;

  MonthProvider? monthProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    super.initState();
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
                        Utils.appImage(
                          media,
                          // dataProvider?.screenBackgroundResponse?.imageAchievement ?? "",
                          dataProvider!.cachedImageMap["imageAchievement"],

                          imageKey: "imageAchievement",
                        ),
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
                        SizedBox(
                          height: media.height / 2.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                                  surfaceTintColor: Colors.transparent,
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
                                      fontSize: ScreenUtil.horizontalScale(5.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(
                                          routeString: '/equipmentLibrary'),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(5),
                                  ),
                                  height: media.height * 0.097,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: ScreenUtil.horizontalScale(50),
                                        child: Text(
                                          "Here's a look at your\nachievements",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                ScreenUtil.verticalScale(2),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
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
                    constraints: BoxConstraints(
                      minHeight: (media.height -
                          (media.height / 8) -
                          (media.height * 0.12)),
                    ),
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Container(
                      width: media.width,
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(7)),
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          top: ScreenUtil.verticalScale(3),
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: dataProvider?.achievementList.length,
                        itemBuilder: (context, index) {
                          return _buildGridItem(
                              dataProvider!.achievementList[index], index);
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

  Widget _buildGridItem(AchievementModel item, int index) {
    return GestureDetector(
      onTap: () {
        AnimatedDialog.showAnimatedDialog(
          context: context,
          pageBuilder: (c1, anim1, anim2) => ShareAchievementNewDialog(
            achievements: item.achievements ?? [],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(
                    height: ScreenUtil.verticalScale(12),
                    width: ScreenUtil.verticalScale(12),
                    child: appShimmerImage(
                      height: ScreenUtil.verticalScale(12),
                      width: ScreenUtil.verticalScale(12),
                      networkImageUrl:
                          "${item.achievements?.first.achievementAchievementId?.image}"
                                  .startsWith(
                                      'https://storage.cloud.google.com/')
                              ? item.achievements?.first
                                      .achievementAchievementId?.image ??
                                  "".replaceFirst(
                                      'https://storage.cloud.google.com/',
                                      'https://storage.googleapis.com/')
                              : item.achievements?.first
                                      .achievementAchievementId?.image ??
                                  "unknown",
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil.verticalScale(500)),
                      ),
                    )),
                Container(
                  height: ScreenUtil.verticalScale(12),
                  width: ScreenUtil.verticalScale(12),
                  decoration: BoxDecoration(
                    color: item.achievements!
                            .any((element) => element.achieved != false)
                        ? Color(0xFFAADDAA).withValues(alpha: 0.8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil.verticalScale(500)),
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: item.achievements!
                            .any((element) => element.achieved != false)
                        ? Colors.white
                        : Colors.transparent,
                    size: 30,
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Text(
              item.title ?? "",
              maxLines: 2,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.7),
                // color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // SizedBox(height: 1),
            // Flexible(
            //   child: Text(
            //     item.description ?? "",
            //     maxLines: 1,
            //     textAlign: TextAlign.center,
            //     overflow: TextOverflow.visible,
            //     style: TextStyle(
            //       fontSize: ScreenUtil.verticalScale(1.5),
            //       // color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );

    // return GestureDetector(
    //   onTap: () {
    //     if (item["isArchived"]! == true) {
    //       AnimatedDialog.showAnimatedDialog(
    //         context: context,
    //         pageBuilder: (c1, anim1, anim2) => ShareAchievementDialog(
    //             title: item["title"]!, imagePath: item["image"]!, subtitle: item["subtitle"]!, time: item["time"], count: 4, length: 4),
    //       );
    //     }
    //   },
    //   child: Container(
    //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         SizedBox(
    //           height: ScreenUtil.verticalScale(12),
    //           width: ScreenUtil.verticalScale(12),
    //           child: SvgPicture.asset(
    //             item["image"]!,
    //             colorFilter: ColorFilter.mode(item["isArchived"]! == true ? AppColors.primaryColor : Colors.grey, BlendMode.srcIn),
    //             fit: BoxFit.contain,
    //           ),
    //         ),
    //         SizedBox(height: 5),
    //         Text(
    //           item["title"]!,
    //           maxLines: 1,
    //           textAlign: TextAlign.center,
    //           overflow: TextOverflow.ellipsis,
    //           style: TextStyle(
    //             fontSize: ScreenUtil.verticalScale(1.8),
    //             color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         SizedBox(height: 1),
    //         Flexible(
    //           child: Text(
    //             item["subtitle"]!,
    //             maxLines: 1,
    //             textAlign: TextAlign.center,
    //             overflow: TextOverflow.visible,
    //             style: TextStyle(
    //               fontSize: ScreenUtil.verticalScale(1.5),
    //               color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
