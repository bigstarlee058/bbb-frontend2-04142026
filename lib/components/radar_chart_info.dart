import 'dart:async';
import 'dart:io';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/video_full_screen.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class RadarChartInfoDialog extends StatefulWidget {
  const RadarChartInfoDialog({super.key});

  @override
  State<RadarChartInfoDialog> createState() => _RadarChartInfoDialogState();
}

class _RadarChartInfoDialogState extends State<RadarChartInfoDialog>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: ScreenUtil.horizontalScale(5),
                        right: ScreenUtil.horizontalScale(5),
                        top: 15.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Text(
                              "6 Big Lifts Progress",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(2.5),
                                height: 1.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "These 6 core movements are used as a benchmark for your overall performance. Your first recorded 1-Rep Max will serve as your baseline and every subsequent 1-Rep Max will show against it as a measure of progress. Please check back in regularly to see how you're doing.",
                            style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(1.7),
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                        ),
                        SizedBox(height: 8)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                    child: Icon(
                        size: ScreenUtil.verticalScale(2.5),
                        Icons.close,
                        color: Colors.white),
                  ),
                ),
                onTap: () async {
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
