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

class VideoIntroWidget extends StatefulWidget {
  final String vimeoId;

  const VideoIntroWidget({super.key, required this.vimeoId});

  @override
  _VideoIntroWidgetState createState() => _VideoIntroWidgetState();
}

class _VideoIntroWidgetState extends State<VideoIntroWidget> with TickerProviderStateMixin {
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
      _videoPlayerController.addListener(() async {
        final bool isFinished =
            _videoPlayerController.value.position >= _videoPlayerController.value.duration && !_videoPlayerController.value.isPlaying;
        if (isFinished) {
          showControlsOnTapOfPause();
        }
        if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
          AudioManager.abandonAudioFocus();
        } else {
          AudioManager.requestAudioFocus();
        }
        setState(() {});
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
    double maxWidth = ScreenUtil.horizontalScale(100);
    double maxHeight = ScreenUtil.verticalScale(70);

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
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    _videoPlayerController.dispose();
    AudioManager.abandonAudioFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : Column(
              children: [
                SizedBox(height: ScreenUtil.verticalScale(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ScreenUtil.horizontalScale(3),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
                Expanded(child: Container()),
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
                            dataProvider!.tutorialData.files.isNotEmpty && !videoNotInitialized
                                ? Stack(
                                    children: [
                                      SizedBox(
                                        height: videoSize.height,
                                        width: videoSize.width,
                                        child: Chewie(
                                          controller: _chewieController!,
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 1500),
                                        curve: Curves.fastOutSlowIn,
                                        color: showControls ? Colors.black38 : Colors.transparent,
                                        height: videoSize.height,
                                        width: videoSize.width,
                                      ),
                                      // Container(
                                      //   color: showControls ? Colors.black38 : Colors.transparent,
                                      //   height: videoSize.height,
                                      //   width: videoSize.width,
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
                    ),
                    Positioned(
                      bottom: videoSize.height / 2,
                      left: 10,
                      right: 10,
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
                      bottom: ScreenUtil.verticalScale(1),
                      left: 10,
                      right: 10,
                      child: !videoNotInitialized && _chewieController!.videoPlayerController.value.isInitialized == true
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
                                  margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(1.3), left: 20, right: 20),
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
                                      ProgressBar(
                                        collapsedBufferedBarColor: Colors.white,
                                        expandedBufferedBarColor: Colors.white,
                                        buffered: Duration(
                                            seconds: _videoPlayerController.value.buffered.isEmpty
                                                ? 0
                                                : _videoPlayerController.value.buffered.first.end.inSeconds),
                                        controller: _controller,
                                        progress: Duration(seconds: _videoPlayerController.value.position.inSeconds),
                                        total: Duration(seconds: _videoPlayerController.value.duration.inSeconds),
                                        onChanged: (value) {
                                          _videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                                        },
                                        onSeek: (Duration value) {},
                                        onChangeStart: (value) {
                                          setState(() => isZoom = true);
                                        },
                                        onChangeEnd: (value) {
                                          setState(() => isZoom = false);
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

                Expanded(child: Container()),
                // Button at the bottom
                Container(
                  margin: EdgeInsets.only(
                    top: ScreenUtil.verticalScale(2),
                    bottom: ScreenUtil.verticalScale(3),
                    left: ScreenUtil.horizontalScale(10),
                    right: ScreenUtil.horizontalScale(10),
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
    );
  }
}
