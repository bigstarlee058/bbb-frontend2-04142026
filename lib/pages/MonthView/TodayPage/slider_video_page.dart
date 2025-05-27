import 'dart:async';

import 'package:bbb/components/back_arrow_widget.dart';
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

class SliderVideoPage extends StatefulWidget {
  final String videoUrl;

  const SliderVideoPage({super.key, required this.videoUrl});

  @override
  State<SliderVideoPage> createState() => _SliderVideoPageState();
}

class _SliderVideoPageState extends State<SliderVideoPage> with TickerProviderStateMixin {
  bool loading = false;
  bool videoNotInitialized = false;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late Size videoSize;
  Timer? _hideControlsTimer;
  bool isMute = true;
  DataProvider? dataProvider;

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
    await dataProvider?.getVideoUsingVimeo(widget.videoUrl);
    if (dataProvider!.videoModel!.files!.isNotEmpty) {
      initializeVideo(dataProvider!.videoModel!.files![0].link ?? "");
    } else {
      loading = false;
      videoNotInitialized = true;
      setState(() {});
    }
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
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));

      await _videoPlayerController.initialize().then(
        (value) {
          AudioManager.requestAudioFocus();
        },
      );

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
      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!);
        setState(() {});
      }

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

  Size calculateVideoSize({required double aspectRatio}) {
    double maxWidth = ScreenUtil.horizontalScale(100);
    double maxHeight = ScreenUtil.verticalScale(70);
    double calculatedHeight = maxWidth / aspectRatio;
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
    _controller.dispose();

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
          : widget.videoUrl.isEmpty || dataProvider!.videoModel!.files!.isEmpty
              ? Column(
                  children: [
                    AppBar(
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      leading: BackArrowWidget(
                        onPress: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Video not available!",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
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
                                dataProvider!.videoModel!.files!.isNotEmpty && !videoNotInitialized
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
                                            duration: Duration(milliseconds: 1700),
                                            curve: Curves.easeInOut,
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
                          child: AnimatedOpacity(
                            opacity: showControls ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
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
                                                  _videoPlayerController.pause();
                                                  isZoom = true;
                                                },
                                                onChangeEnd: (value) {
                                                  _videoPlayerController.play();
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
                    Container(
                      margin: EdgeInsets.only(
                        bottom: ScreenUtil.verticalScale(4),
                        left: ScreenUtil.horizontalScale(10),
                        right: ScreenUtil.horizontalScale(10),
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
    );
  }
}
