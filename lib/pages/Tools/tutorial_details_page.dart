import 'dart:async';

import 'package:bbb/components/video_full_screen.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/models/tutorial_model.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class TutorialDetailsPage extends StatefulWidget {
  const TutorialDetailsPage({super.key, required this.tutorialModel});
  final TutorialModel tutorialModel;
  @override
  State<TutorialDetailsPage> createState() => _TutorialDetailsPageState();
}

class _TutorialDetailsPageState extends State<TutorialDetailsPage>
    with TickerProviderStateMixin {
  bool loading = false;
  bool videoNotInitialized = false;
  bool isZoom = false;
  String tutorialDesc = "";
  DataProvider? dataProvider;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Size? videoSize;
  Timer? hideControlsTimer;
  late final ProgressBarController _controller;
  bool isMute = true;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    fetchTutorialData();
    super.initState();
  }

  void fetchTutorialData() async {
    setState(() => loading = true);
    await dataProvider?.getTutorialDetails(id: widget.tutorialModel.id ?? "");
    if (dataProvider!.tutorialDataModel!.files!.isNotEmpty) {
      initializeVideo(dataProvider!.tutorialDataModel!.files![0].link ?? "");
    } else {
      loading = false;
      videoNotInitialized = true;
      setState(() {});
    }
    tutorialDesc = dataProvider!.tutorialDataModel?.description ?? "";
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

    // fallback to last buffered range or zero
    return buffered.isNotEmpty ? buffered.last.end : Duration.zero;
  }

  // Future<void> initializeVideo(String url) async {
  //   if (hasClosedPopup) return;
  //   try {
  //     _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url),
  //         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
  //
  //     await _videoPlayerController.initialize();
  //     if (hasClosedPopup || !mounted) {
  //       await _videoPlayerController.dispose();
  //       return;
  //     }
  //
  //     await _videoPlayerController.setLooping(true);
  //     AudioManager.requestAudioFocus();
  //
  //     _chewieController = ChewieController(
  //       videoPlayerController: _videoPlayerController,
  //       autoPlay: true,
  //       looping: true,
  //       showControls: false,
  //       aspectRatio: _videoPlayerController.value.aspectRatio,
  //     );
  //     bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
  //     _videoPlayerController.setVolume(rawData ? 1 : 0);
  //     isMute = rawData;
  //     if (!hasClosedPopup &&
  //         _chewieController != null &&
  //         _chewieController!.videoPlayerController.value.isInitialized) {
  //       hideControls();
  //       videoSize = calculateVideoSize(
  //           aspectRatio: _chewieController!.aspectRatio!, context: context);
  //       setState(() {});
  //     }
  //
  //     _videoPlayerController.addListener(() async {
  //       if (hasClosedPopup || !mounted) return;
  //       final position = _videoPlayerController.value.position;
  //       final duration = _videoPlayerController.value.duration;
  //       final bool isFinished =
  //           position >= duration && !_videoPlayerController.value.isPlaying;
  //       if (isFinished) {
  //         showControlsOnTapOfPause();
  //       }
  //       if (duration != null && position >= duration) {
  //         AudioManager.abandonAudioFocus();
  //         if (Platform.isIOS) {
  //           _videoPlayerController.seekTo(Duration.zero);
  //           _videoPlayerController.play();
  //         }
  //       } else {
  //         AudioManager.requestAudioFocus();
  //       }
  //
  //       videoProgressValue.value = position;
  //       setState(() {});
  //     });
  //     _controller = ProgressBarController(
  //       vsync: this,
  //       barAnimationDuration: const Duration(milliseconds: 300),
  //       thumbAnimationDuration: const Duration(milliseconds: 200),
  //       waitingDuration: const Duration(milliseconds: 1800),
  //     );
  //
  //     if (!hasClosedPopup && mounted) {
  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (!hasClosedPopup) {
  //       setState(() {
  //         videoNotInitialized = true;
  //         loading = false;
  //       });
  //     }
  //
  //     debugPrint("VIDEO NOT INITIALIZED: $e");
  //   }
  // }

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

      bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
      isMute = rawData;
      await _videoPlayerController.setVolume(rawData ? 1 : 0);

      final isPlaying = _videoPlayerController.value.isPlaying;

      if (isPlaying && isMute == false) {
        await AudioManager.requestAudioFocus();
      } else {
        await AudioManager.abandonAudioFocus();
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      await _videoPlayerController.setLooping(false);

      if (_videoPlayerController.value.volume == 0) {
        await AudioManager.abandonAudioFocus().then((value) async {
          await Future.delayed(Duration(milliseconds: 20));
          return _videoPlayerController.play();
        });
      }

      if (mounted &&
          !hasClosedPopup &&
          _chewieController != null &&
          _chewieController!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize = calculateVideoSize(
            aspectRatio: _chewieController!.aspectRatio!, context: context);
        setState(() {});
      }

      _videoPlayerController.addListener(() async {
        if (!mounted) return;

        final isPlaying = _videoPlayerController.value.isPlaying;
        if (isPlaying && isMute == true) {
          await AudioManager.requestAudioFocus();
        }

        _onVideoTick();
        setState(() {});
      });

      // _videoPlayerController.addListener(() async {
      //   if (hasClosedPopup || !mounted) return;
      //   final position = _videoPlayerController.value.position;
      //   final duration = _videoPlayerController.value.duration;
      //   final bool isFinished =
      //       position >= duration && !_videoPlayerController.value.isPlaying;
      //   if (isFinished) {
      //     showControlsOnTapOfPause();
      //   }
      //   if (duration != null && position >= duration) {
      //     AudioManager.abandonAudioFocus();
      //     if (Platform.isIOS) {
      //       _videoPlayerController.seekTo(Duration.zero);
      //       _videoPlayerController.play();
      //     }
      //   } else {
      //     AudioManager.requestAudioFocus();
      //   }
      //
      //   videoProgressValue.value = position;
      //   setState(() {});
      // });
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

  bool _restarting = false;

  void _onVideoTick() async {
    final v = _videoPlayerController.value;
    if (!v.isInitialized) return;

    final pos = v.position;
    final dur = v.duration;

    videoProgressValue.value = pos;

    if (dur == null || _restarting) return;

    const epsilon = Duration(milliseconds: 120);
    if (pos >= dur - epsilon) {
      _restarting = true;

      if (isMute == true) {
        AudioManager.requestAudioFocus();
      }

      await _videoPlayerController.pause();
      await _videoPlayerController.seekTo(Duration.zero);
      await _videoPlayerController.setVolume(isMute ? 1 : 0);
      await _videoPlayerController.play();
      _restarting = false;
    }
  }

  bool showControls = true;
  bool isFullscreen = false;

  // muteUnMute() async {
  //   isMute = !isMute;
  //
  //   _videoPlayerController.setVolume(isMute ? 1 : 0);
  //   setState(() {});
  //   await preferences.setBool(SharedPreference.isMute, isMute);
  // }

  muteUnMute() async {
    isMute = !isMute;

    _videoPlayerController.setVolume(isMute ? 1 : 0);
    setState(() {});

    if (_videoPlayerController.value.volume == 0) {
      final videoPlay = _videoPlayerController.value.isPlaying;

      await AudioManager.abandonAudioFocus().then((value) async {
        await Future.delayed(Duration(milliseconds: 20));
        if (videoPlay) {
          return _videoPlayerController.play();
        }
      });
    }

    setState(() {});
    await preferences.setBool(SharedPreference.isMute, isMute);
  }

  void hideControls() {
    hideControlsTimer?.cancel();
    hideControlsTimer = Timer(const Duration(seconds: 4), () {
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
    hideControlsTimer?.cancel();
    setState(() => showControls = true);
  }

  // void toggleFullscreen() {
  //   setState(() {
  //     isFullscreen = !isFullscreen;
  //   });
  //   if (isFullscreen) {
  //     SystemChrome.setPreferredOrientations(
  //         [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  //   } else {
  //     SystemChrome.setPreferredOrientations(
  //         [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //   }
  // }

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
              videoSize: videoSize!,
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

  bool hasClosedPopup = false;
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
    hideControlsTimer?.cancel();

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
        borderRadius: BorderRadius.circular(27),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: videoSize == null
                      ? ScreenUtil.horizontalScale(86.5)
                      : videoSize?.width ?? 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).cardColor,
                ),
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor),
                      )
                    : SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
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
                                        dataProvider!.tutorialDataModel!.files!
                                                    .isNotEmpty &&
                                                !videoNotInitialized
                                            ? Stack(
                                                children: [
                                                  SizedBox(
                                                    height: videoSize?.height,
                                                    width: videoSize?.width,
                                                    child: Chewie(
                                                      controller:
                                                          _chewieController!,
                                                    ),
                                                  ),

                                                  AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 1300),
                                                    curve: Curves.easeInOut,
                                                    height: videoSize?.height,
                                                    width: videoSize?.width,
                                                    color: showControls
                                                        ? Colors.black38
                                                        : Colors.transparent,
                                                  ),

                                                  // Container(
                                                  //   color: showControls ? Colors.black38 : Colors.transparent,
                                                  //   height: videoSize.height,
                                                  //   width: videoSize.width,
                                                  // ),
                                                ],
                                              )
                                            : Container(
                                                height:
                                                    ScreenUtil.verticalScale(
                                                        40),
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
                                videoNotInitialized
                                    ? const SizedBox()
                                    : Positioned(
                                        bottom: videoSize!.height / 2,
                                        left: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            showControlsOnTap();
                                          },
                                          child: AnimatedOpacity(
                                            opacity: showControls ? 1.0 : 0.0,
                                            duration: const Duration(
                                                milliseconds: 800),
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
                                                          _videoPlayerController
                                                              .seekTo(
                                                            _videoPlayerController
                                                                    .value
                                                                    .position -
                                                                const Duration(
                                                                    seconds:
                                                                        10),
                                                          );
                                                          _controller.forward();
                                                        }
                                                      : null,
                                                ),
                                                IconButton(
                                                  iconSize: 60,
                                                  icon: Icon(
                                                    _videoPlayerController
                                                            .value.isPlaying
                                                        ? Icons
                                                            .pause_circle_filled
                                                        : Icons
                                                            .play_circle_filled,
                                                    color: Colors.white70,
                                                  ),
                                                  onPressed: showControls
                                                      ? () async {
                                                          if (_videoPlayerController
                                                              .value
                                                              .isPlaying) {
                                                            _videoPlayerController
                                                                .pause();
                                                            setState(() {});
                                                            showControlsOnTapOfPause();

                                                            await Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        100));
                                                            await AudioManager
                                                                .abandonAudioFocus();
                                                            setState(() {});
                                                          } else {
                                                            _videoPlayerController
                                                                .play();
                                                            setState(() {});
                                                            hideControls();
                                                            await Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        100));

                                                            if (_videoPlayerController
                                                                    .value
                                                                    .volume >
                                                                0) {
                                                              await AudioManager
                                                                  .requestAudioFocus();
                                                            }
                                                            setState(() {});
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
                                                          _videoPlayerController
                                                              .seekTo(
                                                            _videoPlayerController
                                                                    .value
                                                                    .position +
                                                                const Duration(
                                                                    seconds:
                                                                        10),
                                                          );
                                                          _controller.forward();
                                                        }
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  bottom: ScreenUtil.verticalScale(1),
                                  left: 10,
                                  right: 10,
                                  child: !videoNotInitialized &&
                                          _chewieController!
                                                  .videoPlayerController
                                                  .value
                                                  .isInitialized ==
                                              true
                                      ? Column(
                                          children: [
                                            // Container(
                                            //   margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
                                            //   child: Row(
                                            //     children: [
                                            //       Flexible(
                                            //         child: VideoProgressIndicator(
                                            //           _videoPlayerController,
                                            //           allowScrubbing: true,
                                            //           colors: const VideoProgressColors(
                                            //             playedColor: Colors.red,
                                            //             bufferedColor: Colors.white,
                                            //             backgroundColor: Colors.black26,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),

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
                                                      GestureDetector(
                                                        onTap: () {
                                                          showControlsOnTap();
                                                        },
                                                        child: AnimatedOpacity(
                                                          opacity: showControls
                                                              ? 1.0
                                                              : 0.0,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      800),
                                                          curve:
                                                              Curves.easeInOut,
                                                          child: Row(
                                                            children: [
                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap:
                                                                    showControls
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
                                                              SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap:
                                                                    showControls
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
                            tutorialDesc.isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(5),
                                      vertical: 18,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      tutorialDesc,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize:
                                            ScreenUtil.verticalScale(1.75),
                                        height: 1.5,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
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
