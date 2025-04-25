import 'dart:async';

import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/custom_prints.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../values/clip_path.dart';

class ExerciseLibraryDetailPage extends StatefulWidget {
  const ExerciseLibraryDetailPage({super.key});

  @override
  State<ExerciseLibraryDetailPage> createState() => _ExerciseLibraryDetailPageState();
}

class _ExerciseLibraryDetailPageState extends State<ExerciseLibraryDetailPage> {
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

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Size? videoSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    fetchExercise();
  }

  List values = [];
  Timer? _hideControlsTimer;

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
        autoPlay: false,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        // Disable default controls// Use custom controls here
      );

      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        // hideControls();
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
    _hideControlsTimer?.cancel(); // Cancel any active timer
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
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    AudioManager.abandonAudioFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
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
                                      dataProvider!.currentExerciseObj.files.isNotEmpty && !videoNotInitialized && videoSize != null
                                          ? SizedBox(
                                              height: videoSize!.height,
                                              width: videoSize!.width,
                                              child: Chewie(
                                                controller: _chewieController!,
                                              ),
                                            )
                                          : Container(
                                              height: media.height * 0.4,
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
                                Container(
                                  // height: media.height / 1.1,
                                  width: media.width,
                                  decoration: const BoxDecoration(),
                                  child: SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: ScreenUtil.horizontalScale(4),
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SizedBox(
                                              width: ScreenUtil.verticalScale(4.65),
                                              height: ScreenUtil.verticalScale(4.65),
                                              child: IconButton(
                                                padding: EdgeInsets.zero, // Removes the default padding
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_left,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  // HapticFeedBack.buttonClick();
                                                  Navigator.pop(context);
                                                },
                                                iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
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
                            )
                          : const SizedBox(),
                      videoSize != null
                          ? Positioned(
                              bottom: media.height * 0.09,
                              left: 10,
                              right: 10,
                              child: !videoNotInitialized && _chewieController!.videoPlayerController.value.isInitialized == true
                                  ? Column(
                                      children: [
                                        // Container(
                                        //   margin: EdgeInsets.only(bottom: media.height * 0.06, left: 20, right: 20),
                                        //   child: Row(
                                        //     children: [
                                        //       Flexible(
                                        //         child: VideoProgressIndicator(
                                        //           _videoPlayerController,
                                        //           allowScrubbing: true,
                                        //           colors: const VideoProgressColors(
                                        //             playedColor: AppColors.primaryColor,
                                        //             bufferedColor: Colors.white,
                                        //             backgroundColor: Colors.black26,
                                        //           ),
                                        //         ),
                                        //       )
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
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: media.height * 0.12,
                          width: media.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomCenter,
                                decoration:
                                    const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50))),
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: media.height * 0.032,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the content
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 5, right: 10),
                                            child: Text(
                                              exerciseName,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                height: 1.3,
                                                color: AppColors.primaryColor,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      // padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Consumer<UserDataProvider>(
                            builder: (context, userData, child) => Align(
                              alignment: Alignment.topLeft,
                              child:
                                  Text(exerciseDesc, style: const TextStyle(color: Colors.black, fontSize: 14), textAlign: TextAlign.left),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const EquipmentSection(),
                        ],
                      )),
                  const SizedBox(height: 50),
                ],
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
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: 0.7,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          width: media.width,
          color: Colors.black12,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Equipment used',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: TextStyle(
                  color: Colors.black54,
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
                          data.currentExerciseObj.usedEquipments[index].title,
                          data.currentExerciseObj.usedEquipments[index].description,
                          data.currentExerciseObj.usedEquipments[index].link,
                          data.currentExerciseObj.usedEquipments[0].thumbnail),
                      if (index < data.currentExerciseObj.usedEquipments.length - 1) const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget equipmentCard(String title, String description, String link, String image) {
    return GestureDetector(
      onTap: () {
        _launchURL(link); // Launch the external URL when tapped
      },
      child: Container(
        width: ScreenUtil.horizontalScale(100),
        height: ScreenUtil.verticalScale(11),
        margin: const EdgeInsets.symmetric(vertical: 10),
        // Padding around the background
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(7)),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: ScreenUtil.verticalScale(11),
              width: ScreenUtil.verticalScale(12),

              // Padding around the background
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                ),
                image: DecorationImage(
                  image: image.isNotEmpty
                      ? NetworkImage(image.startsWith('https://storage.cloud.google.com/')
                          ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                          : image)
                      : const AssetImage('assets/img/back.jpg'),
                  fit: BoxFit.cover,
                  opacity: 1,
                ),
              ),
            ),
            SizedBox(
              width: ScreenUtil.horizontalScale(2),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil.horizontalScale(40),
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.verticalScale(2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: ScreenUtil.horizontalScale(40),
                  child: Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.verticalScale(1.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: ScreenUtil.verticalScale(2.5),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: ScreenUtil.horizontalScale(6),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(
              width: ScreenUtil.horizontalScale(5),
            ),
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
