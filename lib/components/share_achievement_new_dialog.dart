import 'dart:io';

import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/get_all_achivements.dart';
import 'package:bbb/pages/DashBoardScreen/step_progress_bar.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareAchievementNewDialog extends StatefulWidget {
  const ShareAchievementNewDialog({
    super.key,
    required this.achievements,
  });
  final List<Achievement> achievements;

  @override
  State<ShareAchievementNewDialog> createState() =>
      _ShareAchievementNewDialogState();
}

class _ShareAchievementNewDialogState extends State<ShareAchievementNewDialog> {
  final ScreenshotController screenshotController = ScreenshotController();

  final TextEditingController textEditingController = TextEditingController();
  final PageController pageController = PageController();
  final PageController pageController1 = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  width: ScreenUtil.verticalScale(38),
                  height: ScreenUtil.verticalScale(38),
                  child: PageView.builder(
                    controller: pageController1,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.achievements.length,
                    onPageChanged: (index) {},
                    itemBuilder: (context, index) {
                      var data = widget.achievements[currentPage];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.horizontalScale(1)),
                        child: SizedBox(
                          height: ScreenUtil.verticalScale(38),
                          width: ScreenUtil.horizontalScale(38),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: ScreenUtil.verticalScale(1)),
                              appShimmerImage(
                                height: ScreenUtil.verticalScale(18),
                                width: ScreenUtil.verticalScale(18),
                                networkImageUrl: data
                                        .achievementAchievementId!.image!
                                        .startsWith(
                                            'https://storage.cloud.google.com/')
                                    ? data.achievementAchievementId!.image!
                                        .replaceFirst(
                                            'https://storage.cloud.google.com/',
                                            'https://storage.googleapis.com/')
                                    : data.achievementAchievementId!.image!,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      ScreenUtil.verticalScale(500)),
                                ),
                              ),
                              SizedBox(height: ScreenUtil.verticalScale(3)),
                              Text(
                                data.achievementAchievementId!.title ?? "",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(2),
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  data.achievementAchievementId!.description ??
                                      "",
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: ScreenUtil.verticalScale(1.6),
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                data.achievedDate!.isEmpty &&
                                        data.achieved == false
                                    ? "Not archived yet"
                                    : DateFormat('MM/dd/yyyy hh:mm a').format(
                                        Utils.formattedDate(
                                            data.achievedDate.toString())),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.6),
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFFFFFF),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil.horizontalScale(2))
                        .copyWith(top: ScreenUtil.verticalScale(5)),
                    child: SizedBox(
                      height: ScreenUtil.verticalScale(45),
                      child: PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.achievements.length,
                        controller: pageController,
                        itemBuilder: (context, index) {
                          var data = widget.achievements[index];

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(1)),
                            child: SizedBox(
                              height: ScreenUtil.verticalScale(45),
                              width: ScreenUtil.horizontalScale(45),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: ScreenUtil.verticalScale(3)),
                                  Stack(
                                    children: [
                                      appShimmerImage(
                                        height: ScreenUtil.verticalScale(18),
                                        width: ScreenUtil.verticalScale(18),
                                        networkImageUrl: data
                                                .achievementAchievementId!
                                                .image!
                                                .startsWith(
                                                    'https://storage.cloud.google.com/')
                                            ? data.achievementAchievementId!
                                                .image!
                                                .replaceFirst(
                                                    'https://storage.cloud.google.com/',
                                                    'https://storage.googleapis.com/')
                                            : data.achievementAchievementId!
                                                .image!,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              ScreenUtil.verticalScale(500)),
                                        ),
                                      ),
                                      Container(
                                        height: ScreenUtil.verticalScale(18),
                                        width: ScreenUtil.verticalScale(18),
                                        decoration: BoxDecoration(
                                          color: data.achieved == true
                                              ? Color(0xFFAADDAA)
                                                  .withValues(alpha: 0.8)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                ScreenUtil.verticalScale(500)),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: data.achieved == true
                                              ? Colors.white
                                              : Colors.transparent,
                                          size: 30,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: ScreenUtil.verticalScale(3)),
                                  Text(
                                    data.achievementAchievementId!.title ?? "",
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(2),
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      data.achievementAchievementId!
                                              .description ??
                                          "",
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: ScreenUtil.verticalScale(1.6),
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    data.achievedDate!.isEmpty &&
                                            data.achieved == false
                                        ? "Not archived yet"
                                        : DateFormat('MM/dd/yyyy hh:mm a')
                                            .format(Utils.formattedDate(
                                                data.achievedDate.toString())),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(1.6),
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil.verticalScale(3)),
                                  Padding(
                                    padding: EdgeInsets.all(
                                        ScreenUtil.horizontalScale(2)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                await screenshotController
                                                    .capture(
                                                        delay: Duration(
                                                            milliseconds: 200))
                                                    .then(
                                                  (image) async {
                                                    if (image == null) return;
                                                    final directory =
                                                        await getTemporaryDirectory();
                                                    final imagePath = File(
                                                        '${directory.path}/screenshot.png');
                                                    await imagePath
                                                        .writeAsBytes(image);
                                                    await Share.shareXFiles([
                                                      XFile(imagePath.path)
                                                    ], text: 'Check this out!');
                                                  },
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                    'Error capturing and sharing screenshot: $e');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      ScreenUtil.verticalScale(
                                                          1.7)),
                                            ),
                                            child: Text(
                                              "Share",
                                              style: TextStyle(
                                                fontSize:
                                                    ScreenUtil.verticalScale(2),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil.verticalScale(0.5),
                      right: ScreenUtil.verticalScale(2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ScreenUtil.verticalScale(1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.verticalScale(2)),
                                child: StepProgressBar(
                                  stepHeight: ScreenUtil.verticalScale(1.5),
                                  onStepTap: (int index) {
                                    setState(() {
                                      currentPage = index;
                                    });

                                    if (pageController.hasClients) {
                                      pageController.animateToPage(
                                        index,
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                      );
                                      pageController1.animateToPage(
                                        index,
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                      );
                                    } else {
                                      debugPrint(
                                          'PageController has no clients yet.');
                                    }
                                  },
                                  totalSteps: widget.achievements.length,
                                  progress: (currentPage + 1).toDouble(),
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100))),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                      size: 24,
                                      Icons.close,
                                      color: Colors.white),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
