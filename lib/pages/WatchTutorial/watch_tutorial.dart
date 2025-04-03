import 'dart:async';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class WatchTutorial extends StatefulWidget {
  const WatchTutorial({super.key});

  @override
  State<WatchTutorial> createState() => _WatchTutorialState();
}

class _WatchTutorialState extends State<WatchTutorial> {
  bool loading = false;
  bool videoNotInitialized = false;
  bool isZoom = false;
  String tutorialDesc = "";
  DataProvider? dataProvider;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late Size videoSize;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    fetchTutorialData();
    super.initState();
  }

  void fetchTutorialData() async {
    setState(() => loading = true);
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
        videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!, context: context);
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
      setState(() => loading = false);
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

  void hideControls() {
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => showControls = false);
      }
    });
  }

  void showControlsOnTap() {
    setState(() => showControls = !showControls);
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

  Size calculateVideoSize({required BuildContext context, required double aspectRatio}) {
    double maxWidth = ScreenUtil.horizontalScale(90);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: ScreenUtil.verticalScale(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: ScreenUtil.horizontalScale(3)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil.verticalScale(2)),
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
                      videoNotInitialized
                          ? const SizedBox()
                          : Positioned(
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
                                        setState(
                                          () {
                                            if (_videoPlayerController.value.isPlaying) {
                                              _videoPlayerController.pause();
                                              AudioManager.abandonAudioFocus();
                                            } else {
                                              _videoPlayerController.play();
                                              AudioManager.requestAudioFocus();
                                            }
                                          },
                                        );
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
                  SizedBox(height: ScreenUtil.verticalScale(2)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5), vertical: ScreenUtil.horizontalScale(1.5)),
                    child: ButtonWidget(
                      text: "Watch the App Tutorial",
                      textColor: Colors.white,
                      onPress: () async {
                        if (_videoPlayerController.value.isPlaying) {
                          _videoPlayerController.pause();
                        }
                        await Navigator.pushNamed(context, '/appTutorialScreen');
                      },
                      color: AppColors.primaryColor,
                      isLoading: false,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil.horizontalScale(5), right: ScreenUtil.horizontalScale(5), top: 15.0, bottom: 10.0),
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Text(tutorialDesc,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              )))),
                  SizedBox(height: ScreenUtil.verticalScale(1.5)),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: ScreenUtil.verticalScale(4),
                      left: ScreenUtil.horizontalScale(10),
                      right: ScreenUtil.horizontalScale(10),
                    ),
                    child: Column(
                      children: [
                        // ButtonWidget(
                        //   text: "Watch the App Tutorial",
                        //   textColor: Colors.white,
                        //   onPress: () {
                        //     if (_videoPlayerController.value.isPlaying) {
                        //       _videoPlayerController.pause();
                        //     }
                        //     Navigator.pushNamed(context, '/appTutorialScreen');
                        //   },
                        //   color: AppColors.primaryColor,
                        //   isLoading: false,
                        // ),
                        // const SizedBox(height: 16),
                        // ButtonWidget(
                        //   text: args["buttontext"],
                        //   textColor: Colors.white,
                        //   onPress: () {
                        //     Navigator.pop(context);
                        //   },
                        //   color: AppColors.primaryColor,
                        //   isLoading: false,
                        // ),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Back",
                              style: TextStyle(fontSize: 18, color: AppColors.primaryColor),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
