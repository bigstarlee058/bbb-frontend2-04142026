import 'dart:async';
import 'dart:developer';
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
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoIntroWidget extends StatefulWidget {
  final String vimeoId;

  const VideoIntroWidget({super.key, required this.vimeoId});

  @override
  State<VideoIntroWidget> createState() => _VideoIntroWidgetState();
}

class _VideoIntroWidgetState extends State<VideoIntroWidget>
    with TickerProviderStateMixin {
  bool loading = false;
  bool videoNotInitialized = false;
  String tutorialDesc = "";
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
    await dataProvider?.fetchTutorialData();
    if (dataProvider!.tutorialData.files.isNotEmpty) {
      initializeVideo(dataProvider?.tutorialData.files[0]['link']);
    } else {
      loading = false;
      videoNotInitialized = true;
      setState(() {});
    }

    tutorialDesc = dataProvider?.tutorialData.description ?? "";
  }

  final ValueNotifier<Duration> videoProgressValue =
      ValueNotifier(Duration.zero);
  Duration getBufferedPosition() {
    final position = _videoPlayerController.value.position;
    final buffered = _videoPlayerController.value.buffered;

    for (final range in buffered) {
      if (range.start <= position && position <= range.end) {
        return range.end;
      }
    }

    return buffered.isNotEmpty ? buffered.last.end : Duration.zero;
  }

  Future<void> initializeVideo(String url) async {
    if (hasClosedPopup) return;
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

      await _videoPlayerController.initialize();
      if (hasClosedPopup || !mounted) {
        await _videoPlayerController.dispose();
        return;
      }

      await _videoPlayerController.setLooping(true);
      AudioManager.requestAudioFocus();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
      bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
      _videoPlayerController.setVolume(rawData ? 1 : 0);
      isMute = rawData;
      if (!hasClosedPopup &&
          _chewieController != null &&
          _chewieController!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize = calculateVideoSize(
            aspectRatio: _chewieController!.aspectRatio!, context: context);
        setState(() {});
      }

      _videoPlayerController.addListener(() async {
        if (hasClosedPopup || !mounted) return;
        final position = _videoPlayerController.value.position;
        final duration = _videoPlayerController.value.duration;
        final bool isFinished =
            position >= duration && !_videoPlayerController.value.isPlaying;
        if (isFinished) {
          showControlsOnTapOfPause();
        }
        if (duration != null && position >= duration) {
          AudioManager.abandonAudioFocus();
          if (Platform.isIOS) {
            _videoPlayerController.seekTo(Duration.zero);
            _videoPlayerController.play();
          }
        } else {
          AudioManager.requestAudioFocus();
        }

        videoProgressValue.value = position;
        setState(() {});
      });
      _controller = ProgressBarController(
        vsync: this,
        barAnimationDuration: const Duration(milliseconds: 300),
        thumbAnimationDuration: const Duration(milliseconds: 200),
        waitingDuration: const Duration(milliseconds: 1800),
      );
      if (!hasClosedPopup && mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (!hasClosedPopup) {
        setState(() {
          videoNotInitialized = true;
          loading = false;
        });
      }

      debugPrint("VIDEO NOT INITIALIZED: $e");
    }
  }

  bool hasClosedPopup = false;

  bool isZoom = false;

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
    if (_videoPlayerController.value.isPlaying) {
      setState(() => showControls = !showControls);
      if (_videoPlayerController.value.isPlaying) {
        hideControls();
      }
    }
  }

  void showControlsOnTapOfPause() {
    _hideControlsTimer?.cancel();
    setState(() => showControls = true);
  }

  Future<void> toggleFullscreen() async {
    setState(() {
      isFullscreen = !isFullscreen;
    });
    if (isFullscreen) {
      final screenSize = MediaQuery.of(context).size;
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoFullScreenView(
              makeRefresh: () {
                setState(() {});
              },
              isFullscreen: isFullscreen,
              toggleFullscreen: toggleFullscreen,
              controller: _controller,
              isMute: isMute,
              changeZoom: changeZoom,
              chewieController: _chewieController!,
              hideControls: hideControls,
              isZoom: isZoom,
              media: screenSize,
              videoSize: videoSize,
              muteUnMute: muteUnMute,
              showControls: showControls,
              showControlsOnTap: showControlsOnTap,
              showControlsOnTapOfPause: showControlsOnTapOfPause,
              videoNotInitialized: videoNotInitialized,
              videoPlayerController: _videoPlayerController,
              videoProgressValue: videoProgressValue,
            ),
          ));
    }
  }

  changeZoom(value) {
    isZoom = value;
  }

  Size calculateVideoSize(
      {required BuildContext context, required double aspectRatio}) {
    double maxWidth = ScreenUtil.horizontalScale(86.5);
    double calculatedHeight = maxWidth / aspectRatio;
    return Size(maxWidth, calculatedHeight);
  }

  @override
  void dispose() {
    hasClosedPopup = true;

    try {
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
    } catch (_) {}

    try {
      _chewieController?.dispose();
    } catch (_) {}

    AudioManager.abandonAudioFocus();
    _hideControlsTimer?.cancel();

    // if (_chewieController != null) {
    //   _chewieController!.dispose();
    //   _videoPlayerController.dispose();
    //   AudioManager.abandonAudioFocus();
    // }

    super.dispose();
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
                  color: Theme.of(context).cardColor,
                ),
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showControlsOnTap();
                                },
                                child: Container(
                                  color: Colors.black,
                                  child: Column(
                                    children: [
                                      dataProvider!.tutorialData.files
                                                  .isNotEmpty &&
                                              !videoNotInitialized
                                          ? Stack(
                                              children: [
                                                SizedBox(
                                                  height: videoSize.height,
                                                  width: videoSize.width,
                                                  child: Chewie(
                                                    controller:
                                                        _chewieController!,
                                                  ),
                                                ),
                                                AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 1300),
                                                  curve: Curves.easeInOut,
                                                  color: showControls
                                                      ? Colors.black38
                                                      : Colors.transparent,
                                                  height: videoSize.height,
                                                  width: videoSize.width,
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
                              ),
                              Positioned(
                                bottom: videoSize.height / 2,
                                left: 10,
                                right: 10,
                                child: AnimatedOpacity(
                                  opacity: showControls ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 800),
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
                                        onPressed: showControls
                                            ? () {
                                                _videoPlayerController.seekTo(
                                                  _videoPlayerController
                                                          .value.position -
                                                      const Duration(
                                                          seconds: 10),
                                                );
                                                _controller.forward();
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        iconSize: 60,
                                        icon: Icon(
                                          _videoPlayerController.value.isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_filled,
                                          color: Colors.white70,
                                        ),
                                        onPressed: showControls
                                            ? () async {
                                                if (_videoPlayerController
                                                    .value.isPlaying) {
                                                  _videoPlayerController
                                                      .pause();
                                                  setState(() {});
                                                  showControlsOnTapOfPause();
                                                  await Future.delayed(Duration(
                                                          milliseconds: 100))
                                                      .then(
                                                    (value) {
                                                      AudioManager
                                                          .abandonAudioFocus();
                                                      setState(() {});
                                                    },
                                                  );
                                                } else {
                                                  _videoPlayerController.play();
                                                  setState(() {});
                                                  hideControls();

                                                  await Future.delayed(Duration(
                                                          milliseconds: 100))
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
                                        onPressed: showControls
                                            ? () {
                                                _videoPlayerController.seekTo(
                                                  _videoPlayerController
                                                          .value.position +
                                                      const Duration(
                                                          seconds: 10),
                                                );
                                                _controller.forward();
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
                                child: !videoNotInitialized &&
                                        _chewieController!.videoPlayerController
                                                .value.isInitialized ==
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
                                                      opacity: showControls
                                                          ? 1.0
                                                          : 0.0,
                                                      duration: const Duration(
                                                          milliseconds: 800),
                                                      child: Row(
                                                        children: [
                                                          Spacer(),
                                                          GestureDetector(
                                                            onTap: showControls
                                                                ? () {
                                                                    toggleFullscreen();
                                                                  }
                                                                : null,
                                                            child: Icon(
                                                              !isFullscreen
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
                                                            onTap: showControls
                                                                ? () {
                                                                    muteUnMute();
                                                                  }
                                                                : null,
                                                            child: Icon(
                                                              isMute
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
                                                ValueListenableBuilder<
                                                    Duration>(
                                                  valueListenable:
                                                      videoProgressValue,
                                                  builder:
                                                      (context, progress, _) {
                                                    return ProgressBar(
                                                      collapsedBufferedBarColor:
                                                          Colors.white,
                                                      expandedBufferedBarColor:
                                                          Colors.white,
                                                      buffered:
                                                          getBufferedPosition(),
                                                      controller: _controller,
                                                      progress: progress,
                                                      total: Duration(
                                                        seconds:
                                                            _videoPlayerController
                                                                .value
                                                                .duration
                                                                .inSeconds,
                                                      ),
                                                      onChanged: (value) {
                                                        _videoPlayerController
                                                            .seekTo(Duration(
                                                                seconds: value
                                                                    .inSeconds));
                                                      },
                                                      onSeek: (value) {},
                                                      onChangeStart: (value) {
                                                        _videoPlayerController
                                                            .pause();
                                                        isZoom = true;
                                                      },
                                                      onChangeEnd: (value) {
                                                        _videoPlayerController
                                                            .play();
                                                        isZoom = false;
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
                                        ],
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: ScreenUtil.verticalScale(2.5),
                              bottom: ScreenUtil.verticalScale(1.5),
                              left: ScreenUtil.horizontalScale(3),
                              right: ScreenUtil.horizontalScale(3),
                            ),
                            child: ButtonWidget(
                              text: "Continue Working Out",
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
                  hasClosedPopup = true;

                  try {
                    await _videoPlayerController.pause();
                    await _videoPlayerController.dispose();
                  } catch (_) {}

                  try {
                    _chewieController?.dispose();
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
