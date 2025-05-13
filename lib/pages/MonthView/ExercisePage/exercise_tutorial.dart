import 'dart:async';

import 'package:bbb/components/button_widget.dart';
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
  const ExerciseTutorialScreen({
    super.key,
    required this.loading,
    required this.dataProvider,
    required this.videoNotInitialized,
    required this.videoPlayerController,
    required this.chewieController,
    required this.videoSize,
    required this.controller,
  });

  final bool loading;
  final DataProvider dataProvider;
  final bool videoNotInitialized;
  final VideoPlayerController videoPlayerController;
  final ChewieController chewieController;
  final Size videoSize;
  final ProgressBarController controller;
  @override
  State<ExerciseTutorialScreen> createState() => _ExerciseTutorialScreenState();
}

class _ExerciseTutorialScreenState extends State<ExerciseTutorialScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
        widget.videoPlayerController.setVolume(rawData ? 1 : 0);
        isMute1 = rawData;
      },
    );
    widget.videoPlayerController.play();
    widget.videoPlayerController.addListener(() {
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

  void toggleFullscreen1() {
    setState(() {
      isFullscreen1 = !isFullscreen1;
    });
    if (isFullscreen1) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  updateDonTShowAgain(value) async {
    dontShowAgain1 = value;
    if (value == true) {
      await preferences.putString(SharedPreference.exerciseTutorial, value.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
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
                      SizedBox(height: ScreenUtil.verticalScale(2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(width: ScreenUtil.horizontalScale(3)),
                        ],
                      ),
                      SizedBox(height: ScreenUtil.verticalScale(2)),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showControlsOnTap1();
                            },
                            child: Column(
                              children: [
                                widget.dataProvider.tutorialData.files.isNotEmpty && !widget.videoNotInitialized
                                    ? Stack(
                                        children: [
                                          SizedBox(
                                            height: widget.videoSize.height - 18,
                                            width: widget.videoSize.width - 6,
                                            child: Center(
                                              child: Chewie(
                                                controller: widget.chewieController,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            color: showControls1 ? Colors.black38 : Colors.transparent,
                                            height: widget.videoSize.height - 18,
                                            width: widget.videoSize.width - 6,
                                          ),
                                        ],
                                      )
                                    : Container(
                                        height: ScreenUtil.verticalScale(40),
                                        color: Colors.black12,
                                        child: const Center(
                                            child: Text(
                                          'No Video Available',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                              ],
                            ),
                          ),
                          widget.videoNotInitialized
                              ? const SizedBox()
                              : Positioned(
                                  bottom: widget.videoSize.height / 2.25,
                                  left: 15,
                                  right: 15,
                                  child: Visibility(
                                    visible: showControls1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        // Skip backward button
                                        IconButton(
                                          iconSize: 40,
                                          icon: const Icon(
                                            Icons.replay_10,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            widget.videoPlayerController.seekTo(
                                              widget.videoPlayerController.value.position - const Duration(seconds: 10),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          iconSize: 60,
                                          icon: Icon(
                                            widget.videoPlayerController.value.isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (widget.videoPlayerController.value.isPlaying) {
                                                widget.videoPlayerController.pause();
                                                showControlsOnTapOfPause1();

                                                AudioManager.abandonAudioFocus();
                                              } else {
                                                widget.videoPlayerController.play();
                                                hideControls1();

                                                AudioManager.requestAudioFocus();
                                              }
                                            });
                                          },
                                        ),
                                        // Skip forward button
                                        IconButton(
                                          iconSize: 40,
                                          icon: const Icon(
                                            Icons.forward_10,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            widget.videoPlayerController.seekTo(
                                              widget.videoPlayerController.value.position + const Duration(seconds: 10),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          Positioned(
                            bottom: -5,
                            left: 20,
                            right: 20,
                            child: !widget.videoNotInitialized && widget.chewieController.videoPlayerController.value.isInitialized == true
                                ? Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.3), left: 15, right: 15),
                                        child: Column(
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(height: ScreenUtil.verticalScale(0.8)),
                                                Row(
                                                  children: [
                                                    Spacer(),
                                                    GestureDetector(
                                                      onTap: showControls1
                                                          ? () {
                                                              muteUnMute1();
                                                            }
                                                          : null,
                                                      child: Icon(
                                                        isMute1 ? Icons.volume_up : Icons.volume_off,
                                                        color: !showControls1 ? Colors.transparent : Colors.white70,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: ScreenUtil.verticalScale(1)),
                                            ProgressBar(
                                              collapsedBufferedBarColor: Colors.white,
                                              expandedBufferedBarColor: Colors.white,
                                              buffered: Duration(
                                                  seconds: widget.videoPlayerController.value.buffered.isEmpty
                                                      ? 0
                                                      : widget.videoPlayerController.value.buffered.first.end.inSeconds),
                                              controller: widget.controller,
                                              progress: Duration(seconds: widget.videoPlayerController.value.position.inSeconds),
                                              total: Duration(seconds: widget.videoPlayerController.value.duration.inSeconds),
                                              onChanged: (value) {
                                                widget.videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                                              },
                                              onSeek: (Duration value) {},
                                              onChangeStart: (value) {
                                                setState(() => isZoom1 = true);
                                              },
                                              onChangeEnd: (value) {
                                                setState(() => isZoom1 = false);
                                              },
                                            ),
                                            SizedBox(height: ScreenUtil.verticalScale(2.2)),
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
                                      //             value: widget.videoPlayerController.value.position.inSeconds.toDouble(),
                                      //             max: widget.videoPlayerController.value.duration.inSeconds.toDouble(),
                                      //             onChangeStart: (value) {
                                      //               setState(() => isZoom1 = true);
                                      //             },
                                      //             onChangeEnd: (value) {
                                      //               setState(() => isZoom1 = false);
                                      //             },
                                      //             onChanged: (value) {
                                      //               widget.videoPlayerController.seekTo(Duration(seconds: value.toInt()));
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
                            left: ScreenUtil.horizontalScale(5), right: ScreenUtil.horizontalScale(5), top: 15.0, bottom: 5.0),
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
                              onChanged: (value) async {
                                await updateDonTShowAgain(value);
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
    );
  }
}
