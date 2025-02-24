import 'dart:async';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ExerciseTutorialScreen extends StatefulWidget {
  const ExerciseTutorialScreen({super.key});

  @override
  State<ExerciseTutorialScreen> createState() => _ExerciseTutorialScreenState();
}

class _ExerciseTutorialScreenState extends State<ExerciseTutorialScreen> {
  bool loading1 = false;
  bool videoNotInitialized1 = false;
  String tutorialDesc1 = "";
  DataProvider? dataProvider1;
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController1;
  late Size videoSize1;
  Timer? _hideControlsTimer1;
  bool dontShowAgain1 = false;

  @override
  void initState() {
    dataProvider1 = Provider.of<DataProvider>(context, listen: false);
    fetchTutorialData();
    super.initState();
  }

  updateDonTShowAgain(value) async {
    dontShowAgain1 = value;
    if (value == true) {
      await preferences.putString(SharedPreference.exerciseTutorial, value.toString());
    }
    setState(() {});
  }

  void fetchTutorialData() async {
    setState(() {
      loading1 = true;
    });
    await dataProvider1?.fetchTutorialData();
    if (dataProvider1!.tutorialData.files.isNotEmpty) {
      initializeVideo(dataProvider1?.tutorialData.files[0]['link']);
    } else {
      loading1 = false;
      videoNotInitialized1 = true;
      setState(() {});
    }

    tutorialDesc1 = dataProvider1?.tutorialData.description ?? "";
  }

  Future<void> initializeVideo(String url) async {
    try {
      // Initialize the video player controller
      _videoPlayerController1 = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController1.initialize();

      // Initialize the ChewieController with custom controls
      _chewieController1 = ChewieController(
        videoPlayerController: _videoPlayerController1,
        autoPlay: true,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController1.value.aspectRatio,
        // Disable default controls// Use custom controls here
      );

      if (_chewieController1 != null && _chewieController1!.videoPlayerController.value.isInitialized) {
        hideControls();
        videoSize1 = calculateVideoSize(aspectRatio: _chewieController1!.aspectRatio!, context: context);
        setState(() {});
      }

      setState(() {
        loading1 = false;
      });
    } catch (e) {
      setState(() {
        videoNotInitialized1 = true;
        loading1 = false;
      });
      debugPrint("VIDEO NOT INITIALIZED: $e");
    }
  }

  bool showControls = true;
  bool isFullscreen = false;

  void hideControls() {
    _hideControlsTimer1 = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void showControlsOnTap() {
    setState(() {
      showControls = !showControls;
    });
    _hideControlsTimer1?.cancel(); // Cancel any active timer
    // hideControls(); // Start the timer again to hide the controls after 3 seconds
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
    // Maximum allowable width and height based on screen dimensions
    double maxWidth = ScreenUtil.horizontalScale(90);

    // Calculate height dynamically based on width and aspect ratio
    double calculatedHeight = maxWidth / aspectRatio;

    return Size(maxWidth, calculatedHeight);
  }

  @override
  void dispose() {
    if (_chewieController1 != null) {
      _chewieController1!.dispose();
    }
    _videoPlayerController1.dispose();
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
          child: loading1
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: ScreenUtil.verticalScale(1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(width: ScreenUtil.horizontalScale(2)),
                        ],
                      ),
                      SizedBox(height: ScreenUtil.verticalScale(0.5)),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showControlsOnTap();
                            },
                            child: Column(
                              children: [
                                dataProvider1!.tutorialData.files.isNotEmpty && !videoNotInitialized1
                                    ? SizedBox(
                                        height: videoSize1.height - 18,
                                        width: videoSize1.width - 6,
                                        child: Center(
                                          child: Chewie(
                                            controller: _chewieController1!,
                                          ),
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
                          videoNotInitialized1
                              ? const SizedBox()
                              : Positioned(
                                  bottom: videoSize1.height / 2.5,
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
                                            _videoPlayerController1.seekTo(
                                              _videoPlayerController1.value.position - const Duration(seconds: 10),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          iconSize: 60,
                                          icon: Icon(
                                            _videoPlayerController1.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_videoPlayerController1.value.isPlaying) {
                                                _videoPlayerController1.pause();
                                              } else {
                                                _videoPlayerController1.play();
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
                                            _videoPlayerController1.seekTo(
                                              _videoPlayerController1.value.position + const Duration(seconds: 10),
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
                            child: !videoNotInitialized1 && _chewieController1!.videoPlayerController.value.isInitialized == true
                                ? Container(
                                    margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: VideoProgressIndicator(
                                            _videoPlayerController1,
                                            allowScrubbing: true,
                                            colors: const VideoProgressColors(
                                              playedColor: Colors.red,
                                              bufferedColor: Colors.white,
                                              backgroundColor: Colors.black26,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenUtil.horizontalScale(5), right: ScreenUtil.horizontalScale(5), top: 15.0, bottom: 10.0),
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Text(
                            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
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
                              style: const TextStyle(
                                fontSize: 16,
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
                ),
        ),
      ),
    );
  }
}
