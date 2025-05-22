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
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ChooseEquipmentDialog extends StatefulWidget {
  const ChooseEquipmentDialog({super.key});

  @override
  State<ChooseEquipmentDialog> createState() => _ChooseEquipmentDialogState();
}

class _ChooseEquipmentDialogState extends State<ChooseEquipmentDialog> with TickerProviderStateMixin {
  bool loading = false;
  bool isZoom = false;

  bool videoNotInitialized = false;
  String tutorialDesc = "";
  String tutorialTitle = "";
  DataProvider? dataProvider;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late Size videoSize;
  Timer? _hideControlsTimer;
  bool isMute = true;
  late final ProgressBarController _controller;
  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    fetchTutorialData();
    super.initState();
  }

  void fetchTutorialData() async {
    setState(() {
      loading = true;
    });

    if (dataProvider?.getChooseEquipmentModel == null) {
      await dataProvider?.getChooseEquipmentData();
    }
    if (dataProvider!.getChooseEquipmentModel!.files!.isNotEmpty) {
      initializeVideo(dataProvider!.getChooseEquipmentModel!.files![0].link ?? "");
    } else {
      loading = false;
      videoNotInitialized = true;
      setState(() {});
    }

    tutorialDesc = dataProvider!.getChooseEquipmentModel?.description ?? "";
    tutorialTitle = dataProvider!.getChooseEquipmentModel?.title ?? "";
  }

  final ValueNotifier<Duration> videoProgressValue = ValueNotifier(Duration.zero);
  Duration getBufferedPosition() {
    final position = _videoPlayerController.value.position;
    final buffered = _videoPlayerController.value.buffered;

    for (final range in buffered) {
      if (range.start <= position && position <= range.end) {
        return range.end;
      }
    }

    // fallback to last buffered range or zero
    return buffered.isNotEmpty ? buffered.last.end : Duration.zero;
  }

  Future<void> initializeVideo(String url) async {
    try {
      // Initialize the video player controller
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

      await _videoPlayerController.initialize().then(
        (value) {
          AudioManager.requestAudioFocus();
        },
      );
      // Initialize the ChewieController with custom controls
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        // Disable default controls// Use custom controls here
      );
      bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
      _videoPlayerController.setVolume(rawData ? 1 : 0);
      isMute = rawData;
      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!, context: context);
        setState(() {});
      }
      // _videoPlayerController.addListener(() async {
      //   final bool isFinished =
      //       _videoPlayerController.value.position >= _videoPlayerController.value.duration && !_videoPlayerController.value.isPlaying;
      //   if (isFinished) {
      //     showControlsOnTapOfPause();
      //   }
      //   if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
      //     AudioManager.abandonAudioFocus();
      //   } else {
      //     AudioManager.requestAudioFocus();
      //   }
      //   setState(() {});
      // });
      _videoPlayerController.addListener(() async {
        final position = _videoPlayerController.value.position;
        final duration = _videoPlayerController.value.duration;
        final bool isFinished = position >= duration && !_videoPlayerController.value.isPlaying;
        if (isFinished) {
          showControlsOnTapOfPause();
        }
        if (duration != null && position >= duration) {
          AudioManager.abandonAudioFocus();
        } else {
          AudioManager.requestAudioFocus();
        }

        videoProgressValue.value = position;
      });
      _controller = ProgressBarController(
        vsync: this,
        barAnimationDuration: const Duration(milliseconds: 300),
        thumbAnimationDuration: const Duration(milliseconds: 200),
        waitingDuration: const Duration(milliseconds: 1800),
      );
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        videoNotInitialized = true;
        loading = false;
      });
      debugPrint("VIDEO NOT INITIALIZED: $e");
    }
  }

  bool showControls = true;
  bool isFullscreen = false;

  muteUnMute() async {
    isMute = !isMute;

    _videoPlayerController.setVolume(isMute ? 1 : 0);
    setState(() {});
    await preferences.setBool(SharedPreference.isMute, isMute);
  }

  void hideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showControls = false);
      }
    });
  }

  void showControlsOnTap() {
    setState(() => showControls = !showControls);
    if (_videoPlayerController.value.isPlaying) {
      hideControls();
    }
  }

  void showControlsOnTapOfPause() {
    _hideControlsTimer?.cancel();
    setState(() => showControls = true);
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
    if (isFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  Size calculateVideoSize({
    required BuildContext context,
    required double aspectRatio, // Aspect ratio of the video (width/height)
  }) {
    // Maximum allowable width and height based on screen dimensions
    double maxWidth = ScreenUtil.horizontalScale(90);

    // Calculate height dynamically based on width and aspect ratio
    double calculatedHeight = maxWidth / aspectRatio;

    return Size(maxWidth, calculatedHeight);
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    _videoPlayerController.dispose();
    AudioManager.abandonAudioFocus();
    _controller.dispose();

    super.dispose();
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
          child: loading
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
                              showControlsOnTap();
                            },
                            child: Column(
                              children: [
                                dataProvider!.getChooseEquipmentModel!.files!.isNotEmpty && !videoNotInitialized
                                    ? Stack(
                                        children: [
                                          SizedBox(
                                            height: videoSize.height - 18,
                                            width: videoSize.width - 6,
                                            child: Center(
                                              child: Chewie(
                                                controller: _chewieController!,
                                              ),
                                            ),
                                          ),

                                          AnimatedContainer(
                                            duration: Duration(milliseconds: 1700),
                                            curve: Curves.easeInOut,
                                            color: showControls ? Colors.black38 : Colors.transparent,
                                            height: videoSize.height - 18,
                                            width: videoSize.width - 6,
                                          ),

                                          // Container(
                                          //   color: showControls ? Colors.black38 : Colors.transparent,
                                          //   height: videoSize.height - 18,
                                          //   width: videoSize.width - 6,
                                          // ),
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
                          videoNotInitialized
                              ? const SizedBox()
                              : Positioned(
                                  bottom: videoSize.height / 2.25,
                                  left: 15,
                                  right: 15,
                                  child: Visibility(
                                    visible: showControls,
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
                                            _videoPlayerController.seekTo(
                                              _videoPlayerController.value.position - const Duration(seconds: 10),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          iconSize: 60,
                                          icon: Icon(
                                            _videoPlayerController.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_videoPlayerController.value.isPlaying) {
                                                _videoPlayerController.pause();
                                                showControlsOnTapOfPause();
                                                AudioManager.abandonAudioFocus();
                                              } else {
                                                _videoPlayerController.play();
                                                hideControls();
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
                                            _videoPlayerController.seekTo(
                                              _videoPlayerController.value.position + const Duration(seconds: 10),
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
                            child: !videoNotInitialized && _chewieController?.videoPlayerController.value.isInitialized == true
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
                                                      onTap: showControls
                                                          ? () {
                                                              muteUnMute();
                                                            }
                                                          : null,
                                                      child: Icon(
                                                        isMute ? Icons.volume_up : Icons.volume_off,
                                                        color: !showControls ? Colors.transparent : Colors.white70,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: ScreenUtil.verticalScale(1)),
                                            // ProgressBar(
                                            //   collapsedBufferedBarColor: Colors.white,
                                            //   expandedBufferedBarColor: Colors.white,
                                            //   buffered: Duration(
                                            //       seconds: _videoPlayerController.value.buffered.isEmpty
                                            //           ? 0
                                            //           : _videoPlayerController.value.buffered.first.end.inSeconds),
                                            //   controller: _controller,
                                            //   progress: Duration(seconds: _videoPlayerController.value.position.inSeconds),
                                            //   total: Duration(seconds: _videoPlayerController.value.duration.inSeconds),
                                            //   onChanged: (value) {
                                            //     _videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                                            //   },
                                            //   onSeek: (Duration value) {},
                                            //   onChangeStart: (value) {
                                            //     setState(() => isZoom = true);
                                            //   },
                                            //   onChangeEnd: (value) {
                                            //     setState(() => isZoom = false);
                                            //   },
                                            // ),
                                            ValueListenableBuilder<Duration>(
                                              valueListenable: videoProgressValue,
                                              builder: (context, progress, _) {
                                                return ProgressBar(
                                                  collapsedBufferedBarColor: Colors.white,
                                                  expandedBufferedBarColor: Colors.white,
                                                  buffered: getBufferedPosition(),
                                                  controller: _controller,
                                                  progress: progress,
                                                  total: Duration(
                                                    seconds: _videoPlayerController.value.duration.inSeconds,
                                                  ),
                                                  onChanged: (value) {
                                                    _videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                                                  },
                                                  onSeek: (value) {},
                                                  onChangeStart: (value) {
                                                    isZoom = true;
                                                  },
                                                  onChangeEnd: (value) {
                                                    isZoom = false;
                                                  },
                                                );
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
                                      //             trackHeight: isZoom ? 7 : 4,
                                      //             trackShape: RectangularSliderTrackShape(),
                                      //             overlayShape: SliderComponentShape.noOverlay,
                                      //           ),
                                      //           child: Slider(
                                      //             activeColor: Colors.red,
                                      //             value: _videoPlayerController.value.position.inSeconds.toDouble(),
                                      //             max: _videoPlayerController.value.duration.inSeconds.toDouble(),
                                      //             onChangeStart: (value) {
                                      //               setState(() => isZoom = true);
                                      //             },
                                      //             onChangeEnd: (value) {
                                      //               setState(() => isZoom = false);
                                      //             },
                                      //             onChanged: (value) {
                                      //               _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
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
                            left: ScreenUtil.horizontalScale(5), right: ScreenUtil.horizontalScale(5), top: 15.0, bottom: 10.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                tutorialTitle,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(2.2),
                                  height: 1.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              tutorialDesc,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(1.7),
                                height: 1.5,
                                color: Color(0xff6f6f6f),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtil.verticalScale(1.2)),
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
