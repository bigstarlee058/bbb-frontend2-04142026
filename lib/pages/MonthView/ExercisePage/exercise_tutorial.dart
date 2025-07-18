import 'dart:async';

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
import 'package:video_player/video_player.dart';

class ExerciseTutorialScreen extends StatefulWidget {
  ExerciseTutorialScreen({
    super.key,
    required this.loading,
    required this.dataProvider,
    required this.videoNotInitialized,
    required this.videoPlayerController,
    required this.chewieController,
    required this.videoSize,
    required this.controller,
    required this.videoProgressValue,
    required this.hasClosedPopup,
  });

  final bool loading;
  final DataProvider dataProvider;
  final bool videoNotInitialized;
  final VideoPlayerController videoPlayerController;
  final ChewieController chewieController;
  final Size videoSize;
  final ProgressBarController controller;
  final ValueNotifier<Duration> videoProgressValue;
  bool hasClosedPopup;

  @override
  State<ExerciseTutorialScreen> createState() => _ExerciseTutorialScreenState();
}

class _ExerciseTutorialScreenState extends State<ExerciseTutorialScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        bool rawData =
            await preferences.getBool(SharedPreference.isMute) ?? true;
        widget.videoPlayerController.setVolume(rawData ? 1 : 0);
        isMute1 = rawData;
      },
    );
    widget.videoPlayerController.play();
    widget.videoPlayerController.addListener(() {
      widget.videoProgressValue.value =
          widget.videoPlayerController.value.position;
      setState(() {});
    });
    hideControls1();
    super.initState();
  }

  Timer? _hideControlsTimer1;
  bool showControls1 = true;
  bool isFullscreen1 = false;
  bool dontShowAgain1 = false;
  bool isZoom1 = false;
  bool isMute1 = true;

  muteUnMute1() {
    isMute1 = !isMute1;
    widget.videoPlayerController.setVolume(isMute1 ? 1 : 0);
    setState(() {});
  }

  void hideControls1() {
    _hideControlsTimer1?.cancel();
    _hideControlsTimer1 = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showControls1 = false);
      }
    });
  }

  void showControlsOnTap1() {
    setState(() => showControls1 = !showControls1);
    if (widget.videoPlayerController.value.isPlaying) {
      hideControls1();
    }
  }

  void showControlsOnTapOfPause1() {
    _hideControlsTimer1?.cancel();
    setState(() => showControls1 = true);
  }

  // void toggleFullscreen1() {
  //   setState(() {
  //     isFullscreen1 = !isFullscreen1;
  //   });
  //   if (isFullscreen1) {
  //     SystemChrome.setPreferredOrientations(
  //         [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  //   } else {
  //     SystemChrome.setPreferredOrientations(
  //         [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //   }
  // }

  Future<void> toggleFullscreen() async {
    setState(() {
      isFullscreen1 = !isFullscreen1;
    });
    if (isFullscreen1) {
      final screenSize = MediaQuery.of(context).size;
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoFullScreenView(
              makeRefresh: () {
                setState(() {});
              },
              isFullscreen: isFullscreen1,
              toggleFullscreen: toggleFullscreen,
              controller: widget.controller,
              isMute: isMute1,
              changeZoom: changeZoom,
              chewieController: widget.chewieController,
              hideControls: hideControls1,
              isZoom: isZoom1,
              media: screenSize,
              videoSize: widget.videoSize,
              muteUnMute: muteUnMute1,
              showControls: showControls1,
              showControlsOnTap: showControlsOnTap1,
              showControlsOnTapOfPause: showControlsOnTapOfPause1,
              videoNotInitialized: widget.videoNotInitialized,
              videoPlayerController: widget.videoPlayerController,
              videoProgressValue: widget.videoProgressValue,
            ),
          ));
    }
  }

  changeZoom(value) {
    isZoom1 = value;
  }

  updateDonTShowAgain(value) async {
    dontShowAgain1 = value;
    if (value == true) {
      await preferences.putString(
          SharedPreference.exerciseTutorial, value.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6.7)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.825),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFFFFFFF),
                ),
                child: widget.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // SizedBox(height: ScreenUtil.verticalScale(4.5)),
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showControlsOnTap1();
                                  },
                                  child: Column(
                                    children: [
                                      widget.dataProvider.tutorialData.files
                                                  .isNotEmpty &&
                                              !widget.videoNotInitialized
                                          ? Stack(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      widget.videoSize.height,
                                                  width: widget.videoSize.width,
                                                  child: Chewie(
                                                    controller:
                                                        widget.chewieController,
                                                  ),
                                                ),
                                                AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 1300),
                                                  curve: Curves.easeInOut,
                                                  color: showControls1
                                                      ? Colors.black38
                                                      : Colors.transparent,
                                                  height:
                                                      widget.videoSize.height,
                                                  width: widget.videoSize.width,
                                                ),
                                              ],
                                            )
                                          : Container(
                                              height:
                                                  ScreenUtil.verticalScale(40),
                                              color: Colors.black12,
                                              child: const Center(
                                                  child: Text(
                                                'No Video Available',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                            ),
                                    ],
                                  ),
                                ),
                                widget.videoNotInitialized
                                    ? const SizedBox()
                                    : Positioned(
                                        bottom: widget.videoSize.height / 2,
                                        left: 10,
                                        right: 10,
                                        child: AnimatedOpacity(
                                          opacity: showControls1 ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 800),
                                          curve: Curves.easeInOut,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // Skip backward button
                                              IconButton(
                                                iconSize: 40,
                                                icon: const Icon(
                                                  Icons.replay_10,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: showControls1
                                                    ? () {
                                                        widget
                                                            .videoPlayerController
                                                            .seekTo(
                                                          widget
                                                                  .videoPlayerController
                                                                  .value
                                                                  .position -
                                                              const Duration(
                                                                  seconds: 10),
                                                        );
                                                        widget.controller
                                                            .forward();
                                                      }
                                                    : null,
                                              ),
                                              IconButton(
                                                iconSize: 60,
                                                icon: Icon(
                                                  widget.videoPlayerController
                                                          .value.isPlaying
                                                      ? Icons
                                                          .pause_circle_filled
                                                      : Icons
                                                          .play_circle_filled,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: showControls1
                                                    ? () async {
                                                        if (widget
                                                            .videoPlayerController
                                                            .value
                                                            .isPlaying) {
                                                          widget
                                                              .videoPlayerController
                                                              .pause();
                                                          setState(() {});
                                                          showControlsOnTapOfPause1();

                                                          await Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          100))
                                                              .then(
                                                            (value) {
                                                              AudioManager
                                                                  .abandonAudioFocus();
                                                              setState(() {});
                                                            },
                                                          );
                                                        } else {
                                                          widget
                                                              .videoPlayerController
                                                              .play();
                                                          setState(() {});
                                                          hideControls1();

                                                          await Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          100))
                                                              .then(
                                                            (value) {
                                                              AudioManager
                                                                  .requestAudioFocus();
                                                              setState(() {});
                                                            },
                                                          );
                                                        }
                                                      }
                                                    : null,
                                              ),
                                              // Skip forward button
                                              IconButton(
                                                iconSize: 40,
                                                icon: const Icon(
                                                  Icons.forward_10,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: showControls1
                                                    ? () {
                                                        widget
                                                            .videoPlayerController
                                                            .seekTo(
                                                          widget
                                                                  .videoPlayerController
                                                                  .value
                                                                  .position +
                                                              const Duration(
                                                                  seconds: 10),
                                                        );
                                                        widget.controller
                                                            .forward();
                                                      }
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  bottom: ScreenUtil.verticalScale(1),
                                  left: 10,
                                  right: 10,
                                  child: !widget.videoNotInitialized &&
                                          widget
                                                  .chewieController
                                                  .videoPlayerController
                                                  .value
                                                  .isInitialized ==
                                              true
                                      ? Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      ScreenUtil.verticalScale(
                                                          1.3),
                                                  left: 20,
                                                  right: 20),
                                              child: Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                          height: ScreenUtil
                                                              .verticalScale(
                                                                  0.8)),
                                                      AnimatedOpacity(
                                                        opacity: showControls1
                                                            ? 1.0
                                                            : 0.0,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    800),
                                                        curve: Curves.easeInOut,
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap:
                                                                  showControls1
                                                                      ? () {
                                                                          toggleFullscreen();
                                                                        }
                                                                      : null,
                                                              child: Icon(
                                                                !isFullscreen1
                                                                    ? Icons
                                                                        .fullscreen
                                                                    : Icons
                                                                        .fullscreen_exit,
                                                                color: Colors
                                                                    .white70,
                                                                size: 28,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            GestureDetector(
                                                              onTap:
                                                                  showControls1
                                                                      ? () {
                                                                          muteUnMute1();
                                                                        }
                                                                      : null,
                                                              child: Icon(
                                                                isMute1
                                                                    ? Icons
                                                                        .volume_up
                                                                    : Icons
                                                                        .volume_off,
                                                                color: Colors
                                                                    .white70,
                                                                size: 28,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: ScreenUtil
                                                          .verticalScale(1)),
                                                  // ProgressBar(
                                                  //   collapsedBufferedBarColor: Colors.white,
                                                  //   expandedBufferedBarColor: Colors.white,
                                                  //   buffered: Duration(
                                                  //       seconds: value.videoPlayerController.value.buffered.isEmpty
                                                  //           ? 0
                                                  //           : value.videoPlayerController.value.buffered.first.end.inSeconds),
                                                  //   controller: value.controller,
                                                  //   progress: Duration(seconds: value.videoPlayerController.value.position.inSeconds),
                                                  //   total: Duration(seconds: value.videoPlayerController.value.duration.inSeconds),
                                                  //   onChanged: (value) {
                                                  //     value.videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                                                  //   },
                                                  //   onSeek: (Duration value) {},
                                                  //   onChangeStart: (value) {
                                                  //     setState(() => isZoom1 = true);
                                                  //   },
                                                  //   onChangeEnd: (value) {
                                                  //     setState(() => isZoom1 = false);
                                                  //   },
                                                  // ),
                                                  ValueListenableBuilder<
                                                      Duration>(
                                                    valueListenable: widget
                                                        .videoProgressValue,
                                                    builder:
                                                        (context, progress, _) {
                                                      return ProgressBar(
                                                        collapsedBufferedBarColor:
                                                            Colors.white,
                                                        expandedBufferedBarColor:
                                                            Colors.white,
                                                        buffered: Duration(
                                                            seconds: widget
                                                                    .videoPlayerController
                                                                    .value
                                                                    .buffered
                                                                    .isEmpty
                                                                ? 0
                                                                : widget
                                                                    .videoPlayerController
                                                                    .value
                                                                    .buffered
                                                                    .first
                                                                    .end
                                                                    .inSeconds),
                                                        controller:
                                                            widget.controller,
                                                        progress: progress,
                                                        total: Duration(
                                                          seconds: widget
                                                              .videoPlayerController
                                                              .value
                                                              .duration
                                                              .inSeconds,
                                                        ),
                                                        onChanged: (v) {
                                                          widget
                                                              .videoPlayerController
                                                              .seekTo(Duration(
                                                                  seconds: v
                                                                      .inSeconds));
                                                        },
                                                        onSeek: (v) {},
                                                        onChangeStart: (v) {
                                                          isZoom1 = true;
                                                        },
                                                        onChangeEnd: (v) {
                                                          isZoom1 = false;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                      height: ScreenUtil
                                                          .verticalScale(2.2)),
                                                ],
                                              ),
                                            ),
                                            // Container(
                                            //   margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
                                            //   child: Row(
                                            //     children: [
                                            //       Expanded(
                                            //         child: SliderTheme(
                                            //           data: SliderTheme.of(context).copyWith(
                                            //             thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                                            //             trackHeight: isZoom1 ? 7 : 4,
                                            //             trackShape: RectangularSliderTrackShape(),
                                            //             overlayShape: SliderComponentShape.noOverlay,
                                            //           ),
                                            //           child: Slider(
                                            //             activeColor: Colors.red,
                                            //             value: value.videoPlayerController.value.position.inSeconds.toDouble(),
                                            //             max: value.videoPlayerController.value.duration.inSeconds.toDouble(),
                                            //             onChangeStart: (value) {
                                            //               setState(() => isZoom1 = true);
                                            //             },
                                            //             onChangeEnd: (value) {
                                            //               setState(() => isZoom1 = false);
                                            //             },
                                            //             onChanged: (value) {
                                            //               value.videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                                            //               setState(() {});
                                            //             },
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil.horizontalScale(5),
                                  right: ScreenUtil.horizontalScale(5),
                                  top: 15.0,
                                  bottom: 5.0),
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Lorem Ipsum is simply dummy text of the printing and industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(1.75),
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(3),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    activeColor: AppColors.primaryColor,
                                    value: dontShowAgain1,
                                    onChanged: (v) async {
                                      await updateDonTShowAgain(v);
                                    },
                                  ),
                                  Text(
                                    "Do not show again.",
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(1.8),
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(1)),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: ScreenUtil.verticalScale(3),
                                left: ScreenUtil.horizontalScale(5),
                                right: ScreenUtil.horizontalScale(5),
                              ),
                              child: ButtonWidget(
                                text: "Close",
                                textColor: Colors.white,
                                onPress: () {
                                  Navigator.pop(context);
                                },
                                color: AppColors.primaryColor,
                                isLoading: false,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  widget.hasClosedPopup = true;

                  try {
                    await widget.videoPlayerController.pause();
                    await widget.videoPlayerController.dispose();
                  } catch (_) {}

                  try {
                    widget.chewieController.dispose();
                  } catch (_) {}

                  if (mounted) Navigator.of(context).pop();

                  AudioManager.abandonAudioFocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
