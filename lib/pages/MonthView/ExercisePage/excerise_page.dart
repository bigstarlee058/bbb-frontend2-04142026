import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/middleware/audio_manager.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/models/MonthResponseModel/circuit_model.dart';
import 'package:bbb/models/MonthResponseModel/exercise_history_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_set_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/payload_model.dart';
import 'package:bbb/pages/MonthView/ExercisePage/add_notes.dart';
import 'package:bbb/pages/MonthView/ExercisePage/exercise_set_card.dart';
import 'package:bbb/pages/MonthView/ExercisePage/exercise_tutorial.dart';
import 'package:bbb/pages/MonthView/TodayPage/equipment_section.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with TickerProviderStateMixin {
  MonthProvider? monthProvider;
  bool loading = false;
  bool videoLoader = false;
  bool videoNotInitialized = false;
  bool isZoom = false;
  late final ProgressBarController _controller;
  int exerciseIndex = 0;
  String exerciseDesc = "";
  String exerciseName = "";
  int setCount = 0;
  int isExercise = 0;
  String tempSetAddress = "";
  bool tempSetAddressLoader = false;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Size? videoSize;

  String? argument;
  bool isCurrentDayCompleted = false;
  bool isCurrentDaySkipped = false;
  bool isCurrentExerciseCompleted = false;
  bool isCurrentExerciseSkipped = false;
  bool isEditable = false;
  bool isMute = true;
  late final ProgressBarController _controller1;

  /// EXERCISE TUTORIAL

  DataProvider? dataProvider1;
  bool loading1 = false;
  bool videoNotInitialized1 = false;
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController1;
  late Size videoSize1;

  muteUnMute() async {
    isMute = !isMute;

    _videoPlayerController.setVolume(isMute ? 1 : 0);
    setState(() {});
    await preferences.setBool(SharedPreference.isMute, isMute);
  }

  Future<void> fetchTutorialData() async {
    setState(() {
      loading1 = true;
      loading = true;
    });
    await dataProvider1?.fetchTutorialData().then(
      (value) async {
        if (dataProvider1!.tutorialData.files.isNotEmpty) {
          await initializeVideo1(dataProvider1?.tutorialData.files[0]['link']);
        } else {
          loading1 = false;
          videoNotInitialized1 = true;
          setState(() {});
        }
      },
    );
  }

  Future<void> initializeVideo1(String url) async {
    try {
      _videoPlayerController1 = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoPlayerController1.initialize();

      _chewieController1 = ChewieController(
        videoPlayerController: _videoPlayerController1,
        autoPlay: false,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController1.value.aspectRatio,
      );

      if (_chewieController1 != null && _chewieController1!.videoPlayerController.value.isInitialized) {
        videoSize1 = calculateVideoSize1(aspectRatio: _chewieController1!.aspectRatio!, context: context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }

      _videoPlayerController1.addListener(() async {
        final bool isFinished =
            _videoPlayerController.value.position >= _videoPlayerController.value.duration && !_videoPlayerController.value.isPlaying;
        if (isFinished) {
          showControlsOnTapOfPause();
        }
        if (_videoPlayerController1.value.position >= _videoPlayerController1.value.duration) {
          AudioManager.abandonAudioFocus();
        } else {
          AudioManager.requestAudioFocus();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      });

      _controller1 = ProgressBarController(
        vsync: this,
        barAnimationDuration: const Duration(milliseconds: 300),
        thumbAnimationDuration: const Duration(milliseconds: 200),
        waitingDuration: const Duration(milliseconds: 1800),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => loading1 = false);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            videoNotInitialized1 = true;
            loading1 = false;
          });
        }
      });
      debugPrint("VIDEO NOT INITIALIZED: $e");
    }
  }

  Size calculateVideoSize1({required BuildContext context, required double aspectRatio}) {
    double maxWidth = ScreenUtil.horizontalScale(90);
    double calculatedHeight = maxWidth / aspectRatio;
    return Size(maxWidth, calculatedHeight);
  }

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    dataProvider1 = Provider.of<DataProvider>(context, listen: false);

    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) async {
      await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "YES");
      await preferences.putInt(SharedPreference.fromNotification, 0);
      await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "YES");
      await preferences.clearValue(SharedPreference.fromNotification);
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String isChecked = preferences.getString(SharedPreference.exerciseTutorial) ?? "";
      if (isChecked != "true") {
        await fetchTutorialData().then(
          (value) async {
            argument = ModalRoute.of(context)?.settings.arguments as String?;
            setState(() => loading = true);
            if (argument != "Exercise") {
              await fromNotification().then((value) => clearNotificationAndNavigateExercise());
            } else {
              await fetchExercise().then((value) => clearNotificationAndNavigateExercise());
            }
          },
        );
      } else {
        argument = ModalRoute.of(context)?.settings.arguments as String?;
        setState(() => loading = true);
        if (argument != "Exercise") {
          await fromNotification().then(
            (value) => clearNotificationAndNavigateExercise(),
          );
        } else {
          await fetchExercise().then(
            (value) => clearNotificationAndNavigateExercise(),
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => monthProvider?.fetchExerciseHistroy());

    super.initState();
  }

  clearNotificationAndNavigateExercise() async {
    String isChecked = preferences.getString(SharedPreference.exerciseTutorial) ?? "";
    await Future.delayed(Duration(seconds: 2)).then(
      (value) async => await NotificationService.clearNotification(10).then(
        (value) {
          if (isChecked != "true") {
            if (_chewieController1 != null && !loading1) {
              tutorialVideo(context);
            }
          }
        },
      ),
    );
  }

  Future<void> fromNotification() async {
    setState(() {
      loading = true;
    });
    await monthProvider?.onInit(context);
    String rawTempData = preferences.getString(SharedPreference.payload) ?? "";
    if (rawTempData.isEmpty) {
      log('Error: rawTempData is empty.');
      return;
    }
    final payloadModel = PayloadModel.fromJson(jsonDecode(rawTempData));

    monthProvider!.weekDataModel = monthProvider!.monthDataModel!.weeks![payloadModel.weekIndex! - 1];
    int? index = monthProvider!.weekDataModel!.idList?.indexWhere((element) {
      return element == monthProvider?.todayTitleId;
    });

    final dayIndex = int.parse((monthProvider!.weekDataModel!.dayList?[index ?? 0]
                .toString()
                .replaceAll("Workout", "")
                .replaceAll("Rest", "")
                .replaceAll("Day", "")
                .replaceAll(" ", "") ??
            "0")) -
        1;
    DayDataModel dayData = "${monthProvider!.weekDataModel?.dayList![index ?? 0] ?? ""}".toString().contains("Workout")
        ? monthProvider!.weekDataModel!.days![dayIndex]
        : DayDataModel();
    monthProvider!.dayDataModel = dayData;
    monthProvider!.isPumpDay = payloadModel.isPumpday!;
    monthProvider!.isCircuit = payloadModel.isCircuit!;
    monthProvider!.circuitIndex = payloadModel.circuitIndex!;
    monthProvider!.week = payloadModel.weekIndex;
    monthProvider!.currentWeek = payloadModel.weekIndex!;
    monthProvider!.overviewCurrentDay = payloadModel.dayIndex!;
    monthProvider!.overviewCurrentWeek = payloadModel.weekIndex!;
    monthProvider!.selectedExIndex = payloadModel.exerciseIndex!;

    isCurrentDayCompleted = monthProvider?.dayHistoryDetails?.status == Status.completed;
    isCurrentDaySkipped = monthProvider?.dayHistoryDetails?.status == Status.skipped || monthProvider?.dayHistoryDetails == null;
    if (monthProvider!.isPumpDay) {
      await monthProvider?.fetchDayStatusLocalData();

      // final data = monthProvider!.monthDataModel!.weeks![payloadModel.weekIndex! - 1].dayList![payloadModel.dayIndex! - 1];

      String split =
          monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

      String dataId =
          "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

      // await monthProvider?.checkForPumpDay(data);

      if (monthProvider!.allDayHistoryModel.any((element) => element.dataId == dataId && element.type!.contains("Pump Day"))) {
        // monthProvider?.changeIsPumpDay(true);
        // monthProvider?.changeValue(['Start Workout', 'Swap To Rest Day'], "Start Workout");
      }
      monthProvider!.selectedExercise = monthProvider!.pumpDayModel!.exercises![payloadModel.exerciseIndex!];
    } else {
      monthProvider!.selectedExercise = dayData.exercises![payloadModel.exerciseIndex!];
    }

    await fetchExercise(
      exerciseIndex: payloadModel.exerciseIndex!,
      isPumpDay: payloadModel.isPumpday!,
      isCircuit: payloadModel.isCircuit!,
      exerciseId: payloadModel.exerciseId!,
      circuitIndex: payloadModel.circuitIndex!,
    );
    final data = {"status": "Completed", "dataId": payloadModel.dataId};
    ApiRepo.updateExerciseHistory(body: data);
    await DatabaseHelper().updateSingleValue(
        tableName: DatabaseHelper.exerciseHistory, id: payloadModel.dataId, columnName: 'status', newValue: Status.completed);
    await monthProvider?.fetchExerciseHistoryLocalData();

    NotificationService.clearNotification(10);
    setState(() {});
  }

  List values = [];
  Timer? _hideControlsTimer;

  Future<void> fetchExercise({String? exerciseId, int? exerciseIndex, bool? isPumpDay, bool? isCircuit, String? circuitIndex}) async {
    if (monthProvider?.isWarmup == false) {
      await monthProvider?.fetchCurrentExercise(exerciseId ?? monthProvider!.selectedExercise!.exerciseId.toString());
      isExercise = 1;
      this.exerciseIndex = exerciseIndex ?? monthProvider!.selectedExIndex;

      // if (monthProvider!.exerciseDetailModel!.files!.isNotEmpty) {
      //   initializeVideo(monthProvider!.exerciseDetailModel!.files!.first.link!);
      // } else {
      //   loading = false;
      //   videoNotInitialized = false;
      // }
      if (monthProvider!.exerciseDetailModel != null) {
        exerciseDesc = monthProvider!.exerciseDetailModel?.description ?? "";
        exerciseName = monthProvider!.exerciseDetailModel?.title ?? "";
      }
    } else {
      await monthProvider!.fetchWarmUp(monthProvider!.warmupId).then(
        (value) {
          exerciseDesc = monthProvider!.warmUpModel?.description ?? "";
          exerciseName = monthProvider!.warmUpModel?.title ?? "";
        },
      );

      // if (monthProvider!.warmUpModel!.files!.isNotEmpty) {
      //   initializeVideo(monthProvider!.warmUpModel!.files!.first.link!);
      // } else {
      //   loading = false;
      //   videoNotInitialized = false;
      // }
    }

    monthProvider?.fetchExerciseHistoryLocalData();
    monthProvider?.fetchExerciseStatusLocalData();

    if (monthProvider?.isWarmup == false) {
      if (monthProvider?.exerciseDetailModel != null) {
        String exId = (isPumpDay ?? monthProvider!.isPumpDay) && (isCircuit ?? monthProvider!.isCircuit)
            ? "${monthProvider?.exerciseDetailModel?.sId.toString()}-${(circuitIndex ?? monthProvider?.circuitIndex)}"
            : monthProvider!.exerciseDetailModel!.sId.toString();

        String split =
            monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

        String dataId =
            "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$exId";

        fetchExtraSetLocalData(dataId);

        await monthProvider?.fetchExerciseSingleExerciseLocalData(dataId);
        isCurrentDayCompleted = monthProvider?.dayHistoryDetails?.status == Status.completed;
        isCurrentDaySkipped = monthProvider?.dayHistoryDetails?.status == Status.skipped || monthProvider?.dayHistoryDetails == null;
        isCurrentExerciseCompleted = monthProvider?.exerciseHistoryDetails?.status == Status.completed;
        isCurrentExerciseSkipped = monthProvider?.exerciseHistoryDetails?.status == Status.skipped;
        isEditable = !(isCurrentDayCompleted || isCurrentDaySkipped);
        findIsAtLeastOnSet();
      }
    }
    setState(() => loading = false);
    videoInitialize();
  }

  bool videoNotAvailable = false;

  videoInitialize() {
    try {
      setState(() => videoLoader = true);
      if (monthProvider?.isWarmup == false) {
        if (monthProvider!.exerciseDetailModel!.files!.isNotEmpty) {
          initializeVideo(monthProvider!.exerciseDetailModel!.files!.first.link!);
        } else {
          videoNotAvailable = true;
          videoNotInitialized = false;
          setState(() => videoLoader = false);
        }
      } else {
        if (monthProvider!.warmUpModel!.files!.isNotEmpty) {
          initializeVideo(monthProvider!.warmUpModel!.files!.first.link!);
        } else {
          videoNotAvailable = true;
          videoNotInitialized = false;
          setState(() => videoLoader = false);
        }
      }
    } catch (e) {
      log('EXERCISE PAGE :::::::::::::::::: $e');
    }
  }

  List<ExtraSetModel> extraSetModel = [];

  fetchExtraSetLocalData(String dataId) async {
    final data =
        await DatabaseHelper().getDataFromTable(tableName: DatabaseHelper.extraSetHistory, where: 'dataId', id: "EXTRA-ADDED$dataId");
    if (data.isNotEmpty) {
      extraSetModel = List<ExtraSetModel>.from(json.decode(jsonEncode(data)).map((x) => ExtraSetModel.fromJson(x)));
    } else {
      extraSetModel = [];
    }
    if (!mounted) return;
    setState(() {});
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
        autoPlay: false,
        looping: true,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
      bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
      _videoPlayerController.setVolume(rawData ? 1 : 0);
      isMute = rawData;
      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
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

      _controller = ProgressBarController(
        vsync: this,
        barAnimationDuration: const Duration(milliseconds: 300),
        thumbAnimationDuration: const Duration(milliseconds: 200),
        waitingDuration: const Duration(milliseconds: 1800),
      );

      setState(() {
        videoLoader = false;
      });
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            videoNotAvailable = true;
            videoNotInitialized = true;
            videoLoader = false;
          });
        }
      });
      debugPrint("VIDEO NOT INITIALIZED: $e");
    }
  }

  bool showControls = true;
  bool isFullscreen = false;

  void hideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showControls = false);
      }
    });
  }

  // void showControlsOnTap() {
  //   setState(() {
  //     showControls = !showControls;
  //   });
  //   _hideControlsTimer?.cancel();
  // }

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

  Size calculateVideoSize({required BuildContext context, required double aspectRatio}) {
    final screenSize = MediaQuery.of(context).size;

    double maxWidth = screenSize.width;
    double maxHeight = screenSize.height;

    double calculatedHeight = maxWidth / aspectRatio;

    if (calculatedHeight > maxHeight) {
      calculatedHeight = maxHeight;
      maxWidth = maxHeight * aspectRatio;
    }

    return Size(maxWidth, calculatedHeight);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      monthProvider?.updateExpandedItem("0:0");
      await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "NO");
      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        _chewieController?.dispose();
        _videoPlayerController.dispose();
      }
      AudioManager.abandonAudioFocus();
      monthProvider?.clearWarmupModel();
      _controller.dispose();

      await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "NO");
    });

    super.dispose();
  }

  findIsAtLeastOnSet() {
    if (monthProvider?.selectedExercise?.extra?.isNotEmpty ?? false) {
      for (var element in monthProvider!.selectedExercise!.extra!) {
        final extraItem = element;
        count = int.parse(extraItem.sets.toString()) + (extraItem.type == 3 ? (extraSetModel.length) : 0);
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  int count = 0;
  int warmUpIndex = 0;
  int backOffIndex = 0;
  int workingIndex = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    warmUpIndex = 0;
    backOffIndex = 0;
    workingIndex = 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: loading &&
              ((isExercise == 1
                      ? (monthProvider?.exerciseDetailModel?.files?.isNotEmpty ?? false) && !videoNotInitialized && videoSize != null
                      : (monthProvider?.warmUpModel?.files?.isNotEmpty ?? false) && !videoNotInitialized && videoSize != null) ==
                  false)
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : (isExercise == 1 && monthProvider!.exerciseDetailModel == null) || (isExercise == 0 && monthProvider?.warmUpModel == null)
              ? Column(
                  children: [
                    backButton(media, context),
                    Expanded(
                      child: Center(
                        child: Text(
                          "No data found!",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Stack(
                    clipBehavior: Clip.none,
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
                                    /// VIDEO SECTION

                                    videoSection(media),

                                    /// BACK BUTTON

                                    backButton(media, context),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// PLAY PAUSE REWIND CONTROL

                          playPauseControl(),

                          /// VIDEO PROGRESS

                          videoProgress(media, context),
                        ],
                      ),

                      /// MAIN CONTENT

                      Container(
                        margin: EdgeInsets.only(
                            top: ((isExercise == 1
                                        ? (monthProvider?.exerciseDetailModel?.files?.isNotEmpty ?? false) &&
                                            !videoNotInitialized &&
                                            videoSize != null
                                        : (monthProvider?.warmUpModel?.files?.isNotEmpty ?? false) &&
                                            !videoNotInitialized &&
                                            videoSize != null)
                                    ? videoSize!.height
                                    : videoNotAvailable
                                        ? media.height * 0.4
                                        : media.height * 0.835) -
                                media.height * 0.121),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            mainContent(media),
                            Positioned(
                              top: -((media.height / 3.995)),
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
                                      decoration: const BoxDecoration(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
      bottomNavigationBar: warmupButton(context),
    );
  }

  Widget backButton(Size media, BuildContext context) => Container(
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
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // HapticFeedBack.buttonClick();
                        Navigator.pop(context);
                      },
                      iconSize: ScreenUtil.verticalScale(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget videoProgress(Size media, BuildContext context) => videoSize != null
      ? Positioned(
          bottom: media.height * 0.09,
          left: 10,
          right: 10,
          child: !videoNotInitialized && _chewieController?.videoPlayerController.value.isInitialized == true
              ? Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
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
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6), left: 20, right: 20),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: ProgressBar(
                    //           collapsedBufferedBarColor: Colors.white,
                    //           expandedBufferedBarColor: Colors.white,
                    //           buffered: Duration(
                    //               seconds: _videoPlayerController.value.buffered.isEmpty
                    //                   ? 0
                    //                   : _videoPlayerController.value.buffered.first.end.inSeconds),
                    //           controller: _controller,
                    //           progress: Duration(seconds: _videoPlayerController.value.position.inSeconds),
                    //           total: Duration(seconds: _videoPlayerController.value.duration.inSeconds),
                    //           onChanged: (value) {
                    //             _videoPlayerController.seekTo(Duration(seconds: value.inSeconds));
                    //           },
                    //           onSeek: (Duration value) {},
                    //           onChangeStart: (value) {
                    //             setState(() => isZoom = true);
                    //           },
                    //           onChangeEnd: (value) {
                    //             setState(() => isZoom = false);
                    //           },
                    //         ),
                    //       ),
                    //       // Expanded(
                    //       //   child: SliderTheme(
                    //       //     data: SliderTheme.of(context).copyWith(
                    //       //       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                    //       //       trackHeight: isZoom ? 7 : 4,
                    //       //       trackShape: RectangularSliderTrackShape(),
                    //       //       overlayShape: SliderComponentShape.noOverlay,
                    //       //     ),
                    //       //     child: Slider(
                    //       //       activeColor: Colors.red,
                    //       //       value: _videoPlayerController.value.position.inSeconds.toDouble(),
                    //       //       max: _videoPlayerController.value.duration.inSeconds.toDouble(),
                    //       //       onChangeStart: (value) {
                    //       //         setState(() => isZoom = true);
                    //       //       },
                    //       //       onChangeEnd: (value) {
                    //       //         setState(() => isZoom = false);
                    //       //       },
                    //       //       onChanged: (value) {
                    //       //         _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                    //       //       },
                    //       //     ),
                    //       //   ),
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                  ],
                )
              : const SizedBox(),
        )
      : const SizedBox();

  Widget playPauseControl() => videoSize != null
      ? Positioned(
          bottom: videoSize!.height / 2,
          left: 10,
          right: 10,
          child: AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: showControls
                ? Row(
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
                  )
                : const SizedBox(),
          ),
        )
      : const SizedBox();

  Widget videoSection(Size media) => Container(
        color: Colors.black,
        child: (isExercise == 1
                ? (monthProvider?.exerciseDetailModel?.files?.isNotEmpty ?? false) && !videoNotInitialized && videoSize != null
                : (monthProvider?.warmUpModel?.files?.isNotEmpty ?? false) && !videoNotInitialized && videoSize != null)
            ? Stack(
                children: [
                  SizedBox(
                    height: videoSize?.height,
                    width: videoSize?.width,
                    child: Chewie(
                      controller: _chewieController!,
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 1500),
                    curve: Curves.fastOutSlowIn,
                    height: videoSize?.height,
                    width: videoSize?.width,
                    color: showControls ? Colors.black38 : Colors.transparent,
                  ),
                  // Container(
                  //   color: showControls ? Colors.black38 : Colors.transparent,
                  //   height: videoSize?.height,
                  //   width: videoSize?.width,
                  // ),
                ],
              )
            : Container(
                height: videoNotAvailable ? media.height * 0.4 : media.height * 0.835,
                color: Colors.black12,
                child: videoNotAvailable
                    ? const Center(
                        child: Text(
                          'No Video Available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(bottom: media.height * 0.1),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )

                // appShimmerImage(
                //         height: videoNotAvailable ? media.height * 0.4 : media.height * 0.8,
                //         width: double.infinity,
                //         isBlur: true,
                //         networkImageUrl:
                //             isExercise == 1 ? monthProvider?.exerciseDetailModel?.thumbnail ?? "" : monthProvider?.warmUpModel?.thumbnail ?? "",
                //         fit: BoxFit.fill,
                //       ),
                ),
      );

  Widget warmupButton(BuildContext context) {
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";
    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-${monthProvider!.warmUpModel?.id.toString()}";

    return isExercise == 1
        ? const SizedBox(height: 0, width: 0)
        : loading || monthProvider?.warmUpModel == null
            ? const SizedBox(
                height: 0,
                width: 0,
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(30, 16, 30, 35),
                child: monthProvider!.exerciseHistoryModel.any(
                  (element) => element.dataId == dataId && element.status == Status.completed,
                )
                    ? ButtonWidget(
                        text: "Completed",
                        textColor: Colors.white,
                        onPress: null,
                        color: AppColors.primaryColor,
                        isLoading: false,
                      )
                    : ButtonWidget(
                        text: "Mark Complete",
                        textColor: Colors.white,
                        onPress: () async {
                          await _saveExerciseData(
                            status: Status.completed,
                            id: monthProvider!.warmUpModel!.id.toString(),
                            type: "Warmup",
                          );

                          Navigator.pop(context);
                        },
                        color: AppColors.primaryColor,
                        isLoading: false,
                      ),
              );
  }

  Widget mainContent(Size media) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50))),
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: media.height * 0.018,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 10),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        !monthProvider!.isWarmup
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/exerciseHistory",
                                    arguments: {
                                      'exerciseName': exerciseName,
                                      'exerciseIndex': exerciseIndex,
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.insert_chart_outlined_sharp,
                                  color: AppColors.primaryColor,
                                  size: 30,
                                ),
                              )
                            : SizedBox(),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.white,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return const AddNoteBottomSheet();
                              },
                            );
                          },
                          child: const Icon(Icons.edit, color: AppColors.primaryColor, size: 30),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            guideLineText(),
            if (isExercise == 1)
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Html(
                        data: exerciseDesc,
                        style: {
                          "p.fancy": Style(
                            padding: HtmlPaddings.zero,
                            color: Colors.black,
                            textAlign: TextAlign.left,
                          ),
                        },
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Text(
                    //     exerciseDesc,
                    //     style: const TextStyle(
                    //       color: Colors.black,
                    //     ),
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 15,
                    ),
                    Builder(
                      builder: (context) {
                        final dataHistory = monthProvider!.historyDataModel
                            .where((element) => element.status == Status.completed && element.type != "1")
                            .toList();

                        if (dataHistory.isNotEmpty) {
                          dataHistory.sort((a, b) {
                            int indexComparison = a.index!.compareTo(b.index!);
                            if (indexComparison == 0) {
                              return a.subIndex!.compareTo(b.subIndex!);
                            }
                            return indexComparison;
                          });
                        }

                        List mainIndexList = [];
                        List subIndexList = [];

                        return ListView.builder(
                          itemCount: monthProvider?.selectedExercise?.extra?.length ?? 0,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final extraItem = monthProvider?.selectedExercise!.extra![index];
                            setCount = int.parse(extraItem!.sets.toString()) + (extraItem.type == 3 ? (extraSetModel.length) : 0);
                            return ListView.builder(
                              itemCount: setCount,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, countIndex) {
                                bool isTimerRunning = monthProvider!.timerAddress ==
                                    "$index-$countIndex-$exerciseIndex-${monthProvider?.overviewCurrentWeek}-${monthProvider?.overviewCurrentDay}";
                                if (extraItem.type == 1) warmUpIndex++;
                                if (extraItem.type == 2) backOffIndex++;
                                if (extraItem.type == 3) workingIndex++;

                                if (extraItem.type != 1) {
                                  mainIndexList.add(index);
                                  subIndexList.add(countIndex);
                                }

                                int lastDataMainIndex = dataHistory.isNotEmpty
                                    ? (dataHistory.last.index ?? 0)
                                    : mainIndexList.isEmpty
                                        ? 0
                                        : mainIndexList.first;
                                int lastDataSubIndex = dataHistory.isNotEmpty
                                    ? (dataHistory.last.subIndex ?? 0)
                                    : subIndexList.isEmpty
                                        ? 0
                                        : subIndexList.first;

                                if (dataHistory.isNotEmpty) {
                                  if (lastDataSubIndex ==
                                      ((monthProvider!.selectedExercise!.extra![lastDataMainIndex].sets! - 1) +
                                          (monthProvider!.selectedExercise!.extra![lastDataMainIndex].type == 3
                                              ? (extraSetModel.length)
                                              : 0))) {
                                    lastDataMainIndex += 1;
                                    if (lastDataMainIndex == (monthProvider!.selectedExercise!.extra!.length) &&
                                        lastDataSubIndex == (setCount - 1)) {
                                    } else {
                                      lastDataSubIndex = 0;
                                    }
                                  } else {
                                    lastDataSubIndex += 1;
                                  }
                                }
                                int totalSets = 0;

                                if (monthProvider?.selectedExercise!.extra!.isNotEmpty ?? false) {
                                  for (var element in monthProvider!.selectedExercise!.extra!) {
                                    if (element.type != 1) {
                                      totalSets += int.parse(element.sets.toString());
                                    }
                                  }
                                }
                                for (var element in extraSetModel) {
                                  if (element.type != 1) {
                                    totalSets += int.parse(element.sets.toString());
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: ExerciseSetCard(
                                    totalRIRSet: totalSets,
                                    extraSetLength: extraSetModel.length,
                                    setCount: setCount,
                                    isFromNotification:
                                        (lastDataMainIndex == index && lastDataSubIndex == countIndex) && argument != "Exercise",
                                    countIndex: countIndex,
                                    completed: exerciseIndex ==
                                            int.parse((monthProvider!.currentExpandedItem.split(":").toList().length > 2
                                                ? monthProvider!.currentExpandedItem.split(":").toList()[2]
                                                : "-1"))
                                        ? isTimerRunning
                                        : false,
                                    available: (isCurrentDaySkipped ||
                                                isCurrentDayCompleted ||
                                                isCurrentExerciseSkipped ||
                                                isCurrentExerciseCompleted) ==
                                            true
                                        ? true
                                        : extraItem.type == 1
                                            ? true
                                            : ((extraItem.type == 3 &&
                                                            monthProvider?.selectedExercise!.extra!.any((element) => element.type == 2) ==
                                                                true &&
                                                            dataHistory.any(
                                                              (element) => element.type == "2" && element.status == Status.completed,
                                                            ))
                                                        ? (int.parse(extraItem.sets.toString()) - 1) < countIndex
                                                        : false) ==
                                                    true
                                                ? true
                                                : (lastDataMainIndex == index && lastDataSubIndex == countIndex),
                                    isEditable: isEditable,
                                    makeRefresh: () {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    extraDataModel: extraItem,
                                    color: extraItem.type == 3
                                        ? const Color.fromARGB(255, 248, 248, 248)
                                        : extraItem.type == 2
                                            ? AppColors.backOffSetColor
                                            : AppColors.warmupColor,
                                    exerciseName: exerciseName,
                                    title: extraItem.type == 1
                                        ? "Warmup Set"
                                        : extraItem.type == 2
                                            ? "Back-Off Set"
                                            : "Working Set",
                                    isOpened: isTimerRunning
                                        ? true
                                        : index == 0 && countIndex == 0
                                            ? true
                                            : false,
                                    index: index,
                                    subIndex: List.generate(
                                      extraItem.type == 1
                                          ? monthProvider!.selectedWarmUpSetTotal
                                          : extraItem.type == 2
                                              ? monthProvider!.selectedBackOffSetTotal
                                              : monthProvider!.selectedWorkingSetTotal,
                                      (index) => index,
                                    )[extraItem.type == 1
                                        ? warmUpIndex - 1
                                        : extraItem.type == 2
                                            ? backOffIndex - 1
                                            : workingIndex - 1],
                                    set: int.parse(extraItem.sets.toString()),
                                    weight: int.parse(extraItem.weight.toString()),
                                    reps: int.parse(extraItem.reps.toString()),
                                    repsInReverse: 100,
                                    load: int.parse(extraItem.load == null ? "0" : extraItem.load.toString()),
                                    type: int.parse(extraItem.type.toString()),
                                    restDuration: int.parse(extraItem.rest.toString()),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    count != 0 && !isCurrentDaySkipped && !isCurrentDayCompleted
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: TextButton(
                              onPressed: () async {
                                setState(() => tempSetAddressLoader = true);
                                final data = monthProvider?.selectedExercise!.extra!.where((element) => element.type == 3);
                                if (data!.isNotEmpty) {
                                  tempSetAddress = monthProvider!.currentExpandedItem;
                                  monthProvider?.addSetCountInWorkingSet();
                                  _addExtraSet(data.first);
                                  await Future.delayed(Duration(milliseconds: 200));
                                }
                                setState(() => tempSetAddressLoader = false);
                              },
                              child: IntrinsicWidth(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.grey.shade600,
                                      size: ScreenUtil.verticalScale(3),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Add Set",
                                      style: TextStyle(
                                        fontSize: ScreenUtil.verticalScale(2),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                    Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 40), width: media.width, color: Colors.black12),
                    if (isCurrentDayCompleted || isCurrentDaySkipped) ...[
                      const SizedBox(height: 40),
                      ButtonWidget(
                        text: isCurrentExerciseCompleted ? "Completed" : "Skipped",
                        textColor: Colors.white,
                        onPress: null,
                        color: AppColors.primaryColor,
                        isLoading: false,
                      )
                    ] else ...[
                      const SizedBox(height: 30),
                      Consumer<MonthProvider>(
                        builder: (context, monthProvider, child) {
                          return monthProvider.exerciseHistoryDetails?.status == Status.skipped
                              ? const SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ButtonWidget(
                                      text: monthProvider.exerciseHistoryDetails?.status == Status.completed
                                          ? "Save"
                                          : monthProvider.isLastExercise
                                              ? "Finish"
                                              : /*monthProvider.isPumpDay && monthProvider.isCircuit
                                                            ? "Finish"
                                                            :*/
                                              "Finish & Next",
                                      textColor: Colors.white,
                                      onPress: () async {
                                        HapticFeedBack.buttonClick();
                                        int count = 0;
                                        await _saveExerciseData(
                                            status: Status.completed,
                                            id: monthProvider.isPumpDay && monthProvider.isCircuit
                                                ? "${monthProvider.exerciseDetailModel!.sId.toString()}-${monthProvider.circuitIndex}"
                                                : monthProvider.exerciseDetailModel!.sId.toString(),
                                            type: monthProvider.isCircuit ? "Circuit - ${monthProvider.circuitIndex}" : "Exercise");

                                        WidgetsBinding.instance.addPostFrameCallback(
                                          (timeStamp) async {
                                            String split = monthProvider
                                                    .monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first
                                                    .toString()
                                                    .split(" ")[1] ??
                                                "";
                                            /*if (isCurrentExerciseCompleted) {
                                                        Navigator.pop(context);
                                                        return;
                                                      } else*/
                                            if (monthProvider.isPumpDay && monthProvider.isCircuit) {
                                              List<String> indexList = monthProvider.circuitIndex.split(":");

                                              int circuitIndex = int.parse(indexList[0]);
                                              int circuitRound = int.parse(indexList[1]);
                                              int exerciseIndex = int.parse(indexList[2]);

                                              var circuitExercises = monthProvider.pumpDayModel!.circuits![circuitIndex].circuitExercises!;
                                              List<ExerciseHistoryModel> completedExerciseCurrentRound =
                                                  monthProvider.exerciseHistoryModel.where(
                                                (element) {
                                                  return element.type!.contains("Circuit - $circuitIndex:$circuitRound");
                                                },
                                              ).toList();

                                              if (completedExerciseCurrentRound.length == circuitExercises.length) {
                                                circuitRound = circuitRound + 1;
                                                exerciseIndex = 0;
                                              } else {
                                                exerciseIndex = exerciseIndex + 1;
                                                if (exerciseIndex == circuitExercises.length) {
                                                  Navigator.pop(context);
                                                  return;
                                                }
                                              }

                                              if (circuitRound > monthProvider.pumpDayModel!.circuits![circuitIndex].round!) {
                                                Navigator.pop(context);
                                                return;
                                              }

                                              monthProvider.updateIsCircuit(true);
                                              monthProvider.updateCircuit("$circuitIndex:$circuitRound:$exerciseIndex", circuitIndex);
                                              String dataId =
                                                  "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${circuitExercises[exerciseIndex].exerciseId}-${monthProvider.circuitIndex}";
                                              monthProvider.setSelectedExercise(circuitExercises[exerciseIndex], exerciseIndex);
                                              monthProvider.updateWarmUp(false, "");
                                              monthProvider.updateIsLastExercise(false);
                                              Navigator.pop(context);
                                              await Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
                                              monthProvider.fetchExerciseSingleExerciseLocalData(dataId);
                                            } else {
                                              for (var element in monthProvider.exerciseHistoryModel) {
                                                if (element.status.toString() == Status.completed) {
                                                  count++;
                                                }
                                              }
                                              List<ExerciseDataModel> exerciseList = [];

                                              exerciseList.addAll(monthProvider.dayDataModel!.exercises!
                                                  .where((element) => element.formats!.contains(monthProvider.equipmentType)));

                                              if (exerciseList.length != count &&
                                                  exerciseList.length != monthProvider.selectedExIndex + 1) {
                                                Navigator.pop(context);

                                                await Future.delayed(const Duration(milliseconds: 100));

                                                int skipIndex = monthProvider.selectedExIndex + 1;
                                                for (int i = skipIndex; i < exerciseList.length; i++) {
                                                  var elementI = exerciseList[i];
                                                  String dataId =
                                                      "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${elementI.exerciseId}";
                                                  bool val = monthProvider.exerciseHistoryModel
                                                      .any((element) => element.dataId == dataId && element.status == Status.completed);
                                                  if (val == false) {
                                                    monthProvider.setSelectedExercise(elementI, i);
                                                    monthProvider.updateWarmUp(false, "");

                                                    bool isLast = i ==
                                                        exerciseList
                                                            .indexWhere((element) => element.exerciseId == exerciseList.last.exerciseId);
                                                    monthProvider.updateIsLastExercise(isLast);

                                                    await Navigator.pushNamed(context, '/exercise', arguments: "Exercise");
                                                    break;
                                                  }
                                                }
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            }
                                          },
                                        );
                                      },
                                      color: AppColors.primaryColor,
                                      isLoading: false),
                                );
                        },
                      ),
                      const SizedBox(height: 10),
                      Consumer<MonthProvider>(
                        builder: (context, monthProvider, child) {
                          return ButtonWidget(
                            text: monthProvider.exerciseHistoryDetails?.status == Status.skipped ? "Unskip?" : "Skip the exercise",
                            textColor: const Color(0xFFFFFFFF),
                            color: AppColors.skipDayColor,
                            onPress: () async {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (timeStamp) async {
                                  HapticFeedBack.buttonClick();
                                  final status = monthProvider.exerciseHistoryDetails?.status;
                                  await _saveExerciseData(
                                    status: monthProvider.exerciseHistoryDetails?.status == Status.skipped ? "" : "Skipped",
                                    id: monthProvider.isPumpDay && monthProvider.isCircuit
                                        ? "${monthProvider.exerciseDetailModel!.sId.toString()}-${monthProvider.circuitIndex}"
                                        : monthProvider.exerciseDetailModel!.sId.toString(),
                                    type: monthProvider.isPumpDay && monthProvider.isCircuit
                                        ? "Circuit - ${monthProvider.circuitIndex}"
                                        : "Exercise",
                                  );
                                  if (status != Status.skipped) {
                                    Navigator.pop(context);
                                  }
                                },
                              );
                            },
                            isLoading: false,
                          );
                        },
                      ),
                    ],
                    const EquipmentSection(),
                  ],
                ),
              )
            else
              const SizedBox()
          ],
        ),
      );

  Future<dynamic> tutorialVideo(BuildContext context) => showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 25),
            child: ExerciseTutorialScreen(
              controller: _controller1,
              loading: loading1,
              dataProvider: dataProvider1!,
              chewieController: _chewieController1!,
              videoNotInitialized: videoNotInitialized1,
              videoPlayerController: _videoPlayerController1,
              videoSize: videoSize1,
            ),
          );
        },
      ).then(
        (value) {
          if (_chewieController1 != null) {
            _chewieController1!.dispose();
          }
          _videoPlayerController1.dispose();
          AudioManager.abandonAudioFocus();
        },
      );

  Widget guideLineText() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: isExercise == 1
                  ? (monthProvider!.selectedExercise!.guide == "" || monthProvider!.selectedExercise!.guide == null)
                      ? SizedBox()
                      : Container(
                          margin: EdgeInsets.only(top: 5, bottom: 15),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(254, 233, 232, 1.0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text(
                            "${monthProvider!.selectedExercise!.guide}",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        )
                  : (monthProvider?.warmUpModel?.description ?? "") == ""
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 35),
                          child: Text(
                            monthProvider?.warmUpModel?.description ?? "",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
            ),
          ),
        ],
      );

  double calculateHeight(double width, double aspectRatio) => width / aspectRatio;

  Future<void> _addExtraSet(ExtraDataModel extra) async {
    String exId = monthProvider!.isPumpDay && monthProvider!.isCircuit
        ? "${monthProvider?.exerciseDetailModel!.sId.toString()}-${monthProvider?.circuitIndex}"
        : monthProvider!.exerciseDetailModel!.sId.toString();
    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$exId";

    final data = {
      "sets": 1,
      "reps": extra.reps,
      "weight": extra.weight,
      "rest": extra.reps,
      "load": extra.load,
      "type": extra.type,
      "extraId": "EXTRA-ADDED",
      "date": "${DateTime.now().toUtc()}",
      "dataId": "EXTRA-ADDED$dataId",
    };
    final apiReqBody = {
      "sets": 1,
      "reps": "${extra.reps}",
      "weight": "${extra.weight}",
      "rest": "${extra.reps}",
      "load": "${extra.load}",
      "type": "${extra.type}",
      "extraId": "EXTRA-ADDED",
      "date": "${DateTime.now().toUtc()}",
      "dataId": "EXTRA-ADDED$dataId",
    };
    ApiRepo.addExtraSet(body: apiReqBody);
    await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.extraSetHistory);

    await fetchExtraSetLocalData(dataId);
  }

  Future<void> _saveExerciseData({required String status, required String id, required String type}) async {
    await monthProvider?.fetchExerciseHistoryLocalData();
    await monthProvider?.fetchCircuitModelLocalData();

    String split =
        monthProvider?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first.toString().split(" ")[1] ?? "";

    if (monthProvider!.isPumpDay && monthProvider!.isCircuit) {
      String exId = monthProvider?.pumpDayModel!.circuits?[monthProvider!.circuitsIndex].id ?? "";

      String dataId1 =
          "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$exId";

      final data2 = {
        "dataId": dataId1,
        "lastExerciseCount": 1,
        "lastRound": monthProvider?.pumpDayModel!.circuits?[monthProvider!.circuitsIndex].circuitExercises?.length == 1 ? 2 : 1,
        "exerciseCountList": monthProvider?.pumpDayModel!.circuits?[monthProvider!.circuitsIndex].circuitExercises?.length == 1
            ? ""
            : monthProvider!.exerciseDetailModel!.sId.toString(),
      };

      if (monthProvider!.circuitModel.isNotEmpty) {
        CircuitModel? matchingElement =
            monthProvider?.circuitModel.firstWhere((element) => element.dataId == dataId1, orElse: () => CircuitModel());

        if (matchingElement?.id != null) {
          if (!matchingElement!.exerciseCountList!.contains(monthProvider!.exerciseDetailModel!.sId.toString())) {
            Map<String, dynamic> data3;

            if (monthProvider?.pumpDayModel!.circuits?[monthProvider!.circuitsIndex].circuitExercises?.length == 1) {
              data3 = {
                "lastExerciseCount": 1,
                "lastRound": (matchingElement.lastRound! + 1),
                "exerciseCountList": "",
              };
            } else if (monthProvider?.pumpDayModel!.circuits?[monthProvider!.circuitsIndex].circuitExercises?.length ==
                (matchingElement.lastExerciseCount! + 1)) {
              data3 = {
                "dataId": dataId1,
                "lastExerciseCount": 0,
                "lastRound": (matchingElement.lastRound! + 1),
                "exerciseCountList": "",
              };
            } else {
              data3 = {
                "dataId": dataId1,
                "lastExerciseCount":
                    matchingElement.exerciseCountList.toString().replaceAll("-", "").isEmpty ? 1 : (matchingElement.lastExerciseCount! + 1),
                "lastRound": matchingElement.lastRound,
                "exerciseCountList": "${matchingElement.exerciseCountList}-${monthProvider!.exerciseDetailModel!.sId.toString()}",
              };
            }

            await DatabaseHelper().updateData(data: data3, tableName: DatabaseHelper.circuitManager, id: dataId1);
          }
        } else {
          await DatabaseHelper().insertData(data: data2, tableName: DatabaseHelper.circuitManager);
        }
      } else {
        await DatabaseHelper().insertData(data: data2, tableName: DatabaseHelper.circuitManager);
      }
    }

    double totalWeight = 0;
    double totalRIR = 0;
    double totalSet = 0;

    if (status == Status.completed) {
      totalWeight = 0;
      if (monthProvider?.historyDataModel != null) {
        for (var i = 0; i < monthProvider!.historyDataModel.length; i++) {
          final element = monthProvider!.historyDataModel[i];
          final weight = double.parse(element.weight.toString());
          final reps = double.parse(element.reps.toString());
          final effort = double.parse(element.effort.toString().replaceAll("+", ""));
          final cal = weight * (reps + (effort == 100 ? 0 : effort));
          totalWeight += cal;
          totalRIR += (effort == 100 ? 0 : effort);
        }
      }

      final data = monthProvider!.historyDataModel.where((element) => element.type != "1");
      if (data.isNotEmpty) {
        totalSet = double.parse(data.first.totalSet.toString());
      }
    }

    await monthProvider?.fetchCircuitModelLocalData();

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}-$id";

    final data = {
      "dataId": dataId,
      "exerciseId": id.toString(),
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "totalWeight": totalWeight.toString(),
      "totalRIR": totalRIR.toString(),
      "totalSet": totalSet.toString(),
    };

    final data1 = {
      "status": status,
      "type": type,
      "totalWeight": totalWeight.toString(),
      "totalRIR": totalRIR.toString(),
      "totalSet": totalSet.toString(),
    };

    final apiReqBody = {
      "status": status,
      "type": type,
      "totalWeight": totalWeight.toString(),
      "totalRIR": totalRIR.toString(),
      "totalSet": totalSet.toString(),
      "dataId": dataId,
    };

    if (monthProvider!.exerciseHistoryModel.isNotEmpty) {
      if (monthProvider!.exerciseHistoryModel.any((element) => element.dataId == dataId)) {
        ApiRepo.updateExerciseStatus(body: apiReqBody);
        await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseStatus, id: dataId);
      } else {
        ApiRepo.addExerciseStatus(body: data);
        await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
      }
    } else {
      ApiRepo.addExerciseStatus(body: data);
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
    }

    await monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.updateDayData();
    monthProvider?.fetchExerciseHistoryLocalData();
    monthProvider?.fetchExerciseSingleExerciseLocalData(dataId);
    monthProvider?.getLiftedWeightGraphData();

    if (status == Status.completed && type == "Exercise") {
      // monthProvider?.exerciseCompletedApi();
    }
  }
}
