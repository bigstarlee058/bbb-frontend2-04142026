import 'dart:developer';

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
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
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

    dataProvider?.getAllAchievement(false);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        if (dataProvider!.openDaySinceJoin) {
          final itemList = dataProvider!.achievementList
              .where((element) => element.title == "Days since joining")
              .toList();

          if (itemList.isNotEmpty) {
            final item = itemList.first;
            final data1 = item.achievements
                ?.where((element) => element.achieved == false)
                .toList();

            Achievement? data2;
            if ((data1 != null && data1.isEmpty)) {
              data2 = item.achievements?.last;
            } else {
              int? index = item.achievements?.indexWhere((element) =>
                  element.achievementAchievementId?.achievementIdId ==
                  data1?.first.achievementAchievementId?.achievementIdId);
              data2 = item.achievements?[index == 0 ? 0 : (index ?? 0) - 1];
            }

            int? index = item.achievements?.indexWhere(
              (element) =>
                  element.achievementAchievementId?.achievementIdId ==
                  data2?.achievementAchievementId?.achievementIdId,
            );

            await Future.delayed(Duration(milliseconds: 100)).then(
              (value) {
                AnimatedDialog.showAnimatedDialog(
                  context: context,
                  pageBuilder: (c1, anim1, anim2) => ShareAchievementNewDialog(
                      item: item,
                      achievements: item.achievements ?? [],
                      currentPage: index == 0
                          ? 0
                          : ((index! + 1) == (item.achievements?.length ?? 0))
                              ? index
                              : index + 1),
                );
              },
            );
          }
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        dataProvider?.updateOpenDaySinceJoin(false);
      },
    );
    super.dispose();
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
                        Consumer<DataProvider>(builder: (context, value, c) {
                          return AppImage.imageAchievement(value
                              // media,
                              // // dataProvider?.screenBackgroundResponse?.imageAchievement ?? "",
                              // image: dataProvider!.allImageList
                              //     .where((element) =>
                              //         element["key"] == "imageAchievement")
                              //     .first["image"],
                              // // image:
                              // //     dataProvider!.cachedImageMap["imageAchievement"],
                              // imageKey: "imageAchievement",
                              );
                        }),
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
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
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
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                      ),
                    ),
                    child: Container(
                      width: media.width,
                      margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(7))
                          .copyWith(bottom: ScreenUtil.verticalScale(3.2)),
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          top: ScreenUtil.verticalScale(1.5),
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.01,
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
    final data1 = item.achievements
        ?.where((element) => element.achieved == false)
        .toList();
    // var data2 = (data1 != null && data1.isEmpty) ? item.achievements?.last : data1?.first;

    Achievement? data2;
    if ((data1 != null && data1.isEmpty)) {
      data2 = item.achievements?.last;
    } else {
      int? index = item.achievements?.indexWhere((element) =>
          element.achievementAchievementId?.achievementIdId ==
          data1?.first.achievementAchievementId?.achievementIdId);
      data2 = item.achievements?[index == 0 ? 0 : (index ?? 0) - 1];
    }
    return GestureDetector(
      onTap: () {
        int? index = item.achievements?.indexWhere(
          (element) =>
              element.achievementAchievementId?.achievementIdId ==
              data2?.achievementAchievementId?.achievementIdId,
        );
        AnimatedDialog.showAnimatedDialog(
          context: context,
          pageBuilder: (c1, anim1, anim2) => ShareAchievementNewDialog(
            item: item,
            achievements: item.achievements ?? [],
            currentPage: index == 0
                ? 0
                : ((index! + 1) == (item.achievements?.length ?? 0))
                    ? index
                    : index + 1,
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
                  child: Builder(
                    builder: (context) {
                      String url = data2?.achieved == true
                          ? (data2?.achievementAchievementId?.image ?? "")
                          : (item.thumbnail ?? "");
                      return appShimmerImage(
                        color: Colors.transparent,
                        height: ScreenUtil.verticalScale(12),
                        width: ScreenUtil.verticalScale(12),
                        networkImageUrl:
                            url.startsWith('https://storage.cloud.google.com/')
                                ? url.replaceFirst(
                                    'https://storage.cloud.google.com/',
                                    'https://storage.googleapis.com/')
                                : url,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            ScreenUtil.verticalScale(500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Container(
                //   height: ScreenUtil.verticalScale(12),
                //   width: ScreenUtil.verticalScale(12),
                //   decoration: BoxDecoration(
                //     color: (data1?.isEmpty ?? false) ? Color(0xFFAADDAA).withValues(alpha: 0.8) : Colors.transparent,
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(ScreenUtil.verticalScale(500)),
                //     ),
                //   ),
                //   child: Icon(
                //     Icons.check,
                //     color: (data1?.isEmpty ?? false) ? Colors.white : Colors.transparent,
                //     size: 30,
                //   ),
                // )
              ],
            ),
            SizedBox(height: 10),
            Text(
              data2?.achievementAchievementId?.title ?? "",
              maxLines: 2,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.6),
                color: Theme.of(context).textTheme.bodyLarge?.color,
                // color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "${(data1 != null && data1.isEmpty) ? item.achievements?.length : (item.achievements!.length - (data1?.length ?? 0))} out of ${item.achievements?.length}",
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: ScreenUtil.verticalScale(1.4),
                // color: item["isArchived"]! == true ? AppColors.primaryColor : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
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
