import 'dart:async';
import 'dart:io';

import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/components/video_full_screen.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/custom_prints.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../values/clip_path.dart';

class ExerciseLibraryDetailPage extends StatefulWidget {
  const ExerciseLibraryDetailPage({super.key});

  @override
  State<ExerciseLibraryDetailPage> createState() =>
      _ExerciseLibraryDetailPageState();
}

class _ExerciseLibraryDetailPageState extends State<ExerciseLibraryDetailPage>
    with TickerProviderStateMixin {
  DataProvider? dataProvider;

  bool loading = false;
  bool videoNotInitialized = false;
  int exerciseIndex = 0;
  String exerciseDesc = "";
  var params = [];
  String exerciseId = "";
  String exerciseName = "";
  List<dynamic> exercises = [];
  var media;
  double height = 0.0;
  double useHeight = 0.0;
  bool isZoom = false;
  bool isMute = true;
  late final ProgressBarController _controller;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Size? videoSize;
  List values = [];
  Timer? _hideControlsTimer;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        fetchExercise();
      },
    );

    super.initState();
  }

  void fetchExercise() async {
    try {
      params = ModalRoute.of(context)!.settings.arguments as List<String>;
      exerciseId = params[0];
      exerciseName = params[1];
    } catch (e) {
      customPrintR("issue in parameter $e");
    }

    setState(() {
      loading = true;
    });
    await dataProvider?.fetchCurrentEx(exerciseId, "exercise 95");
    if (dataProvider!.currentExerciseObj.files.isNotEmpty) {
      initializeVideo(dataProvider?.currentExerciseObj.files[0]['link']);
    } else {
      loading = false;
      videoNotInitialized = false;
      setState(() {});
    }

    exerciseDesc = dataProvider?.currentExerciseObj.description ?? "";
  }

  final ValueNotifier<Duration> videoProgressValue =
      ValueNotifier(Duration.zero);
  Future<void> initializeVideo(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController.initialize();

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
        autoPlay: false,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      await _videoPlayerController.setLooping(false);

      if (mounted &&
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

      // _videoPlayerController.addListener(() {
      //   final position = _videoPlayerController.value.position;
      //   final duration = _videoPlayerController.value.duration;
      //
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
      //
      //   setState(() {});
      // });

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

  muteUnMute() async {
    isMute = !isMute;

    _videoPlayerController.setVolume(isMute ? 1 : 0);
    setState(() {});

    if (_videoPlayerController.value.volume == 0) {
      final videoPlay = _videoPlayerController.value.isPlaying;

      await AudioManager.abandonAudioFocus().then((value) async {
        await Future.delayed(Duration(milliseconds: 40));
        if (videoPlay) {
          return _videoPlayerController.play();
        }
      });
    }

    setState(() {});
    await preferences.setBool(SharedPreference.isMute, isMute);
  }

  void hideControls() {
    if (_videoPlayerController.value.isPlaying) {
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => showControls = false);
        }
      });
    }
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

  Size calculateVideoSize({
    required BuildContext context,
    required double aspectRatio, // Aspect ratio of the video (width/height)
  }) {
    final screenSize = MediaQuery.of(context).size;

    // Maximum allowable width and height based on screen dimensions
    double maxWidth = screenSize.width;
    double maxHeight = screenSize.height;

    // Calculate height dynamically based on width and aspect ratio
    double calculatedHeight = maxWidth / aspectRatio;

    // If calculated height exceeds maxHeight, adjust width instead
    if (calculatedHeight > maxHeight) {
      calculatedHeight = maxHeight;
      maxWidth = maxHeight * aspectRatio;
    }

    return Size(maxWidth, calculatedHeight);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (_chewieController != null &&
          _chewieController!.videoPlayerController.value.isInitialized) {
        _chewieController?.dispose();
        _videoPlayerController.dispose();
      }
      AudioManager.abandonAudioFocus();
      _controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Stack(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.loose,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showControlsOnTap();
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.black,
                                      child: Column(
                                        children: [
                                          dataProvider!.currentExerciseObj.files
                                                      .isNotEmpty &&
                                                  !videoNotInitialized &&
                                                  videoSize != null
                                              ? Stack(
                                                  children: [
                                                    SizedBox(
                                                      height: videoSize!.height,
                                                      width: videoSize!.width,
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
                                                      height: videoSize?.height,
                                                      width: videoSize?.width,
                                                    ),
                                                  ],
                                                )
                                              : appShimmerImage(
                                                  width: media.width,
                                                  height: (dataProvider
                                                                  ?.currentExerciseObj
                                                                  .videoThumbnail ??
                                                              "")
                                                          .isNotEmpty
                                                      ? media.height * 0.835
                                                      : media.width,
                                                  networkImageUrl: (dataProvider
                                                                  ?.currentExerciseObj
                                                                  .videoThumbnail ??
                                                              "")
                                                          .isNotEmpty
                                                      ? (dataProvider
                                                              ?.currentExerciseObj
                                                              .videoThumbnail ??
                                                          "")
                                                      : dataProvider
                                                              ?.currentExerciseObj
                                                              .thumbnail ??
                                                          "",
                                                  fit: BoxFit.cover,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(ScreenUtil
                                                        .horizontalScale(1)),
                                                  ),
                                                )
                                          // Container(
                                          //     height: media.height * 0.4,
                                          //     color: Colors.black12,
                                          //     child: const Center(
                                          //         child: Text(
                                          //       'No Video Available',
                                          //       style: TextStyle(
                                          //           color: Colors.white),
                                          //     )),
                                          //   ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // height: media.height / 1.1,
                                      width: media.width,
                                      decoration: const BoxDecoration(),
                                      child: SafeArea(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: ScreenUtil
                                                      .horizontalScale(4),
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0XFFd18a9b),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: SizedBox(
                                                  width:
                                                      ScreenUtil.verticalScale(
                                                          4.65),
                                                  height:
                                                      ScreenUtil.verticalScale(
                                                          4.65),
                                                  child: IconButton(
                                                    padding: EdgeInsets
                                                        .zero, // Removes the default padding
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_left,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      // HapticFeedBack.buttonClick();
                                                      Navigator.pop(context);
                                                    },
                                                    iconSize: ScreenUtil
                                                        .verticalScale(
                                                            4), // Icon size remains the same
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          videoSize != null
                              ? Positioned(
                                  bottom: videoSize!.height / 2,
                                  left: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      showControlsOnTap();
                                    },
                                    child: AnimatedOpacity(
                                      opacity: showControls ? 1.0 : 0.0,
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
                                            onPressed: showControls
                                                ? () {
                                                    _videoPlayerController
                                                        .seekTo(
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
                                              _videoPlayerController
                                                      .value.isPlaying
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
                                                              .value.volume >
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
                                )
                              : const SizedBox(),
                          videoSize != null
                              ? Positioned(
                                  bottom: media.height * 0.09,
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
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      ScreenUtil.verticalScale(
                                                          4),
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
                                                  SizedBox(
                                                      height: ScreenUtil
                                                          .verticalScale(2.2)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                )
                              : const SizedBox(),
                          Positioned(
                            bottom: media.height * 0.12,
                            right: 0,
                            child: SizedBox(
                              height: media.height / 3.99,
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
                          ),
                          // Positioned(
                          //   bottom: 0,
                          //   child: Container(
                          //     height: media.height * 0.12,
                          //     width: media.width,
                          //     decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.only(
                          //         topLeft:
                          //             Radius.circular(ScreenUtil.verticalScale(7)),
                          //       ),
                          //     ),
                          //     child: Column(
                          //       children: [
                          //         Container(
                          //           alignment: Alignment.bottomCenter,
                          //           decoration: const BoxDecoration(
                          //               color: Colors.white,
                          //               borderRadius: BorderRadius.only(
                          //                   topLeft: Radius.circular(50))),
                          //           padding:
                          //               const EdgeInsets.symmetric(horizontal: 30),
                          //           child: Column(
                          //             mainAxisAlignment: MainAxisAlignment.end,
                          //             children: [
                          //               SizedBox(
                          //                 height: media.height * 0.032,
                          //               ),
                          //               Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.spaceBetween,
                          //                 crossAxisAlignment: CrossAxisAlignment
                          //                     .center, // Vertically center the content
                          //                 children: [
                          //                   Expanded(
                          //                     child: Padding(
                          //                       padding: const EdgeInsets.only(
                          //                           top: 5, right: 10),
                          //                       child: Text(
                          //                         exerciseName,
                          //                         maxLines: 2,
                          //                         style: const TextStyle(
                          //                           height: 1.3,
                          //                           color: AppColors.primaryColor,
                          //                           fontSize: 25,
                          //                           fontWeight: FontWeight.bold,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ],
                          //               )
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50))),
                        margin: EdgeInsets.only(
                            top: videoSize == null
                                ? ((dataProvider?.currentExerciseObj
                                                    .videoThumbnail ??
                                                "")
                                            .isNotEmpty
                                        ? media.height * 0.835
                                        : media.width) -
                                    media.height * 0.12
                                : videoSize!.height - media.height * 0.12),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: media.height * 0.018,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, right: 10),
                                        child: Text(
                                          exerciseName,
                                          maxLines: 2,
                                          style: TextStyle(
                                            height: 1.3,
                                            color: AppColors.primaryColor,
                                            fontSize:
                                                ScreenUtil.verticalScale(2.8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Html(
                                data: exerciseDesc,
                                style: {
                                  "body": Style(
                                    padding: HtmlPaddings.zero,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.color,
                                  ),
                                  "p": Style(
                                    padding: HtmlPaddings.zero,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.color,
                                  ),
                                },
                                // style: {
                                //   "p.fancy": Style(
                                //     padding: HtmlPaddings.zero,
                                //     color: Colors.black,
                                //   ),
                                // },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5)
                                  .copyWith(
                                      bottom: ScreenUtil.verticalScale(.5)),
                              child: const EquipmentSection(),
                            ),
                          ],
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

class EquipmentSection extends StatefulWidget {
  const EquipmentSection({super.key});

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
  bool isDarkMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final raw4 = await preferences.getBool(SharedPreference.isDarkMode);
        isDarkMode = raw4 ?? false;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Consumer<DataProvider>(builder: (context, data, child) {
      return data.currentExerciseObj.usedEquipments.isEmpty
          ? SizedBox()
          : Column(
              children: [
                Container(
                  height: 0.7,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  width: media.width,
                  color: Colors.black12,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse equipment used with this exercise below',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: ScreenUtil.verticalScale(2.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Consumer<DataProvider>(
                  builder: (context, data, child) {
                    if (data.currentExerciseObj.usedEquipments.isNotEmpty) {
                      return Column(
                        children: List.generate(
                          data.currentExerciseObj.usedEquipments.length,
                          (index) => Column(
                            children: [
                              equipmentCard(
                                  data.currentExerciseObj.usedEquipments[index]
                                      .title,
                                  data.currentExerciseObj.usedEquipments[index]
                                      .description,
                                  data.currentExerciseObj.usedEquipments[index]
                                      .link,
                                  data.currentExerciseObj.usedEquipments[0]
                                      .thumbnail),
                              if (index <
                                  data.currentExerciseObj.usedEquipments
                                          .length -
                                      1)
                                const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(3.2),
                ),
              ],
            );
    });
  }

  Widget equipmentCard(
      String title, String description, String link, String image) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          disabledBackgroundColor: const Color(0xFFF3F3F3),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil.verticalScale(12)),
            ),
            side: const BorderSide(color: Color(0x12000000), width: 0.5),
          ),
          surfaceTintColor: Colors.transparent,
          overlayColor: Colors.grey.shade400,
          padding: EdgeInsets.zero),
      onPressed: () {
        _launchURL(link); // Launch the external URL when tapped
      },
      child: Container(
        width: ScreenUtil.horizontalScale(100),
        height: ScreenUtil.verticalScale(11),

        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(7)),
          ),
        ),
        child: Row(
          children: [
            appShimmerImage(
              height: ScreenUtil.verticalScale(11),
              width: ScreenUtil.verticalScale(12),
              networkImageUrl:
                  image.startsWith('https://storage.cloud.google.com/')
                      ? image.replaceFirst('https://storage.cloud.google.com/',
                          'https://storage.googleapis.com/')
                      : image,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: ScreenUtil.verticalScale(2),
                      fontWeight: FontWeight.bold,
                    ),
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                  ),
                  // SizedBox(height: ScreenUtil.verticalScale(1)),
                  // Text(
                  //   description,
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: ScreenUtil.verticalScale(1.7),
                  //   ),
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                ],
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: null,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.all(ScreenUtil.verticalScale(0.85)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/shopping-bag.svg",
                  height: ScreenUtil.verticalScale(2.3),
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 15),
          ],
        ), // Ensure the background takes up all available space
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
