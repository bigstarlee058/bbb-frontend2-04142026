import 'dart:async';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SliderVideoPage extends StatefulWidget {
  final String videoUrl;

  const SliderVideoPage({super.key, required this.videoUrl});

  @override
  State<SliderVideoPage> createState() => _SliderVideoPageState();
}

class _SliderVideoPageState extends State<SliderVideoPage> {
  bool loading = false;
  bool videoNotInitialized = false;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late Size videoSize;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    fetchTutorialData();
    super.initState();
  }

  void fetchTutorialData() async {
    setState(() {
      loading = true;
    });
    if (widget.videoUrl.isNotEmpty) {
      initializeVideo(widget.videoUrl);
    } else {
      loading = false;
      videoNotInitialized = true;
      setState(() {});
    }
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
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!);
        setState(() {});
      }
      _videoPlayerController.addListener(() async {
        if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
          AudioManager.abandonAudioFocus();
        } else {
          AudioManager.requestAudioFocus();
        }
        setState(() {});
      });

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

  void hideControls() {
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        showControls = false;
      });
    });
  }

  void showControlsOnTap() {
    setState(() {
      showControls = !showControls;
    });
    _hideControlsTimer?.cancel();
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
                            widget.videoUrl.isNotEmpty && !videoNotInitialized
                                ? SizedBox(
                                    height: videoSize.height,
                                    width: videoSize.width,
                                    child: Chewie(
                                      controller: _chewieController!,
                                    ),
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
                                    AudioManager.abandonAudioFocus();
                                  } else {
                                    _videoPlayerController.play();
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
                                  margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                                            trackHeight: isZoom ? 7 : 4,
                                            trackShape: RectangularSliderTrackShape(),
                                            overlayShape: SliderComponentShape.noOverlay,
                                          ),
                                          child: Slider(
                                            activeColor: Colors.red,
                                            value: _videoPlayerController.value.position.inSeconds.toDouble(),
                                            max: _videoPlayerController.value.duration.inSeconds.toDouble(),
                                            onChangeStart: (value) {
                                              setState(() => isZoom = true);
                                            },
                                            onChangeEnd: (value) {
                                              setState(() => isZoom = false);
                                            },
                                            onChanged: (value) {
                                              _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
