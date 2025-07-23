import 'dart:developer';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/pump_day_model.dart';
import 'package:bbb/pages/MonthView/TodayPage/slider_video_page.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class VideoSlider extends StatefulWidget {
  final DayDataModel dayDataModel;
  const VideoSlider({super.key, required this.dayDataModel});

  @override
  State<VideoSlider> createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider> {
  int currentVideoIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    getCount();
    super.initState();
  }

  List<Map<String, dynamic>> videoData = [];

  getCount() {
    if (widget.dayDataModel.vimeoId!.isNotEmpty) {
      videoData.add({
        "image": widget.dayDataModel.thumbnailOne,
        "vimeo": widget.dayDataModel.vimeoId,
      });
    }

    if (widget.dayDataModel.vimeoId2!.isNotEmpty) {
      videoData.add({
        "image": widget.dayDataModel.thumbnailTwo,
        "vimeo": widget.dayDataModel.vimeoId2,
      });
    }

    if (widget.dayDataModel.vimeoId3!.isNotEmpty) {
      videoData.add({
        "image": widget.dayDataModel.thumbnailThree,
        "vimeo": widget.dayDataModel.vimeoId3,
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return videoData.isEmpty
        ? SizedBox()
        : Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(4)),
                ),
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: pageController,
                    itemCount: videoData.length,
                    onPageChanged: (v) {
                      currentVideoIndex = v;
                      setState(() {});
                    },
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.verticalScale(3)),
                      child: videoData[index]["image"].toString().isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(4)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/img/pp_4.png"),
                                ),
                              ),
                              child: IconButton(
                                iconSize: 60,
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  AnimatedDialog.showAnimatedDialog(
                                      context: context,
                                      pageBuilder: (c1, anim1, anim2) =>
                                          SliderVideoPage(
                                              videoUrl: videoData[index]
                                                  ["vimeo"]));
                                },
                              ),
                            )
                          : appShimmerImage(
                              networkImageUrl: videoData[index]["image"]
                                      .startsWith(
                                          'https://storage.cloud.google.com/')
                                  ? videoData[index]["image"].replaceFirst(
                                      'https://storage.cloud.google.com/',
                                      'https://storage.googleapis.com/')
                                  : videoData[index]["image"],
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil.verticalScale(4)),
                              fit: BoxFit.cover,
                              child: IconButton(
                                iconSize: 60,
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  AnimatedDialog.showAnimatedDialog(
                                      context: context,
                                      pageBuilder: (c1, anim1, anim2) =>
                                          SliderVideoPage(
                                              videoUrl: videoData[index]
                                                  ["vimeo"]));
                                },
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: ScreenUtil.horizontalScale(2),
              ),
              videoData.isEmpty || videoData.length == 1
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        videoData.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentVideoIndex == index
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          );
  }
}

class PumpVideoSlider extends StatefulWidget {
  final PumpDayModel pumpDayModel;
  const PumpVideoSlider({super.key, required this.pumpDayModel});

  @override
  State<PumpVideoSlider> createState() => _PumpVideoSliderState();
}

class _PumpVideoSliderState extends State<PumpVideoSlider> {
  int currentVideoIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    getCount();
    super.initState();
  }

  List<Map<String, dynamic>> videoData = [];

  getCount() {
    if (widget.pumpDayModel.vimeoId!.isNotEmpty) {
      videoData.add({
        "image": widget.pumpDayModel.thumbnailOne,
        "vimeo": widget.pumpDayModel.vimeoId,
      });
    }

    if (widget.pumpDayModel.vimeoId2!.isNotEmpty) {
      videoData.add({
        "image": widget.pumpDayModel.thumbnailTwo,
        "vimeo": widget.pumpDayModel.vimeoId2,
      });
    }

    if (widget.pumpDayModel.vimeoId3!.isNotEmpty) {
      videoData.add({
        "image": widget.pumpDayModel.thumbnailThree,
        "vimeo": widget.pumpDayModel.vimeoId3,
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return videoData.isEmpty
        ? SizedBox()
        : Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(4)),
                ),
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: pageController,
                    itemCount: videoData.length,
                    onPageChanged: (v) {
                      currentVideoIndex = v;
                      setState(() {});
                    },
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.verticalScale(3)),
                      child: videoData[index]["image"].toString().isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil.verticalScale(4)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/img/pp_4.png"),
                                ),
                              ),
                              child: IconButton(
                                iconSize: 60,
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  AnimatedDialog.showAnimatedDialog(
                                      context: context,
                                      pageBuilder: (c1, anim1, anim2) =>
                                          SliderVideoPage(
                                              videoUrl: videoData[index]
                                                  ["vimeo"]));
                                },
                              ),
                            )
                          : appShimmerImage(
                              networkImageUrl: videoData[index]["image"]
                                      .startsWith(
                                          'https://storage.cloud.google.com/')
                                  ? videoData[index]["image"].replaceFirst(
                                      'https://storage.cloud.google.com/',
                                      'https://storage.googleapis.com/')
                                  : videoData[index]["image"],
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil.verticalScale(4)),
                              fit: BoxFit.cover,
                              child: IconButton(
                                iconSize: 60,
                                icon: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  AnimatedDialog.showAnimatedDialog(
                                      context: context,
                                      pageBuilder: (c1, anim1, anim2) =>
                                          SliderVideoPage(
                                              videoUrl: videoData[index]
                                                  ["vimeo"]));
                                },
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: ScreenUtil.horizontalScale(2),
              ),
              videoData.isEmpty || videoData.length == 1
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        videoData.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentVideoIndex == index
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          );
  }
}
