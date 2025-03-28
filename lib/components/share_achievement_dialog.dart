import 'dart:io';

import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareAchievementDialog extends StatelessWidget {
  ShareAchievementDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.time,
  });
  final String imagePath;
  final String title;
  final String subtitle;
  final DateTime time;
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: ScreenUtil.verticalScale(1)),
                      SvgPicture.asset(
                        height: ScreenUtil.verticalScale(16),
                        imagePath,
                        colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: ScreenUtil.verticalScale(3)),
                      Text(
                        title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil.verticalScale(2), color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: ScreenUtil.verticalScale(1.6), color: AppColors.blackColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm a').format(time),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil.verticalScale(1.6), color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                    padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)).copyWith(top: ScreenUtil.verticalScale(2.5)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ScreenUtil.verticalScale(3)),
                        SvgPicture.asset(
                          height: ScreenUtil.verticalScale(16),
                          imagePath,
                          colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: ScreenUtil.verticalScale(3)),
                        Text(
                          title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: ScreenUtil.verticalScale(2), color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(1.6), color: AppColors.blackColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy hh:mm a').format(time),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: ScreenUtil.verticalScale(1.6), color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: ScreenUtil.verticalScale(3)),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await screenshotController.capture(delay: Duration(milliseconds: 200)).then(
                                        (image) async {
                                          if (image == null) return;
                                          final directory = await getTemporaryDirectory();
                                          final imagePath = File('${directory.path}/screenshot.png');
                                          await imagePath.writeAsBytes(image);
                                          await Share.shareXFiles([XFile(imagePath.path)], text: 'Check this out!');
                                        },
                                      );
                                    } catch (e) {
                                      debugPrint('Error capturing and sharing screenshot: $e');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(1.7)),
                                  ),
                                  child: Text(
                                    "Share",
                                    style:
                                        TextStyle(fontSize: ScreenUtil.verticalScale(2), fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(width: ScreenUtil.horizontalScale(2)),
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
