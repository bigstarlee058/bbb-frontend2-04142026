import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/models/MonthResponseModel/circuit_model.dart';
import 'package:bbb/models/MonthResponseModel/extra_set_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/models/MonthResponseModel/payload_model.dart';
import 'package:bbb/pages/MonthView/ExercisePage/add_notes.dart';
import 'package:bbb/pages/MonthView/ExercisePage/exercise_set_card.dart';
import 'package:bbb/pages/MonthView/ExercisePage/exercise_tutorial.dart';
import 'package:bbb/pages/MonthView/TodayPage/equipment_section.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  MonthProvider? monthProvider;
  bool loading = false;
  bool videoNotInitialized = false;

  int exerciseIndex = 0;
  String exerciseDesc = "";
  String exerciseName = "";
  int setCount = 0;
  int isExercise = 0;

  final GlobalKey _containerKey = GlobalKey();

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Size? videoSize;

  String? argument;
  bool isCurrentDayCompleted = false;
  bool isCurrentDaySkipped = false;
  bool isCurrentExerciseCompleted = false;
  bool isCurrentExerciseSkipped = false;
  bool isEditable = false;

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) async => await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "YES"));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      argument = ModalRoute.of(context)?.settings.arguments as String?;

      setState(() {
        loading = true;
      });

      if (argument != "Exercise") {
        await fromNotification().then(
          (value) => clearNotificationAndNavigateExercise(),
        );
      } else {
        await fetchExercise().then(
          (value) => clearNotificationAndNavigateExercise(),
        );
      }
    });

    super.initState();
  }

  clearNotificationAndNavigateExercise() async {
    String isChecked = preferences.getString(SharedPreference.exerciseTutorial) ?? "";
    await Future.delayed(Duration(milliseconds: 700));
    NotificationService.clearNotification().then(
      (value) {
        if (isChecked != "true") {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 25),
              child: ExerciseTutorialScreen(),
            ),
          );
        }
      },
    );
  }

  Future<void> fromNotification() async {
    await monthProvider?.onInit();
    String rawTempData = preferences.getString(SharedPreference.payload) ?? "";
    PayloadModel payloadModel = PayloadModel.fromJson(jsonDecode(rawTempData));

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

    NotificationService.clearNotification();
  }

  List values = [];
  Timer? _hideControlsTimer;

  Future<void> fetchExercise({String? exerciseId, int? exerciseIndex, bool? isPumpDay, bool? isCircuit, String? circuitIndex}) async {
    if (monthProvider?.isWarmup == false) {
      setState(() {
        loading = true;
      });

      await monthProvider?.fetchCurrentExercise(exerciseId ?? monthProvider!.selectedExercise!.exerciseId.toString());

      isExercise = 1;
      exerciseIndex = exerciseIndex ?? monthProvider!.selectedExIndex;

      if (monthProvider!.exerciseDetailModel!.files!.isNotEmpty) {
        initializeVideo(monthProvider!.exerciseDetailModel!.files!.first.link!);
      } else {
        loading = false;
        videoNotInitialized = false;
      }
      exerciseDesc = monthProvider!.exerciseDetailModel!.description ?? "";
      exerciseName = monthProvider!.exerciseDetailModel!.title ?? "";
    } else {
      if (monthProvider!.warmUpModel!.files!.isNotEmpty) {
        initializeVideo(monthProvider!.warmUpModel!.files!.first.link!);
      } else {
        loading = false;
        videoNotInitialized = false;
      }
      exerciseDesc = monthProvider!.warmUpModel!.description ?? "";
      exerciseName = monthProvider!.warmUpModel!.title ?? "";
    }

    await monthProvider?.fetchExerciseHistoryLocalData();
    await monthProvider?.fetchExerciseStatusLocalData();

    if (monthProvider?.isWarmup == false) {
      String exId = (isPumpDay ?? monthProvider!.isPumpDay) && (isCircuit ?? monthProvider!.isCircuit)
          ? "${monthProvider?.exerciseDetailModel!.sId.toString()}-${(circuitIndex ?? monthProvider?.circuitIndex)}"
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
    setState(() {});
  }

  List<ExtraSetModel> extraSetModel = [];

  fetchExtraSetLocalData(String dataId) async {
    final data = await DatabaseHelper().getDataFromTable(tableName: DatabaseHelper.extraSetHistory, where: 'dataId', id: dataId);
    if (data.isNotEmpty) {
      extraSetModel = List<ExtraSetModel>.from(json.decode(jsonEncode(data)).map((x) => ExtraSetModel.fromJson(x)));
    } else {
      extraSetModel = [];
    }
    if (!context.mounted) return;
    setState(() {});
  }

  Future<void> initializeVideo(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        showControls: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
        videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!, context: context);
        setState(() {});
      }

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

  Size calculateVideoSize({
    required BuildContext context,
    required double aspectRatio,
  }) {
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
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) async => await preferences.putString(SharedPreference.inTheExerciseScreenOrNot, "NO"));
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  int count = 0;

  findIsAtLeastOnSet() {
    monthProvider?.selectedExercise?.extra?.forEach(
      (element) {
        final extraItem = element;
        count = int.parse(extraItem.sets.toString()) + (extraItem.type == 3 ? (extraSetModel.length) : 0);
      },
    );
    setState(() {});
  }

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
                                      (isExercise == 1
                                              ? (monthProvider?.exerciseDetailModel?.files?.isNotEmpty ?? false) &&
                                                  !videoNotInitialized &&
                                                  videoSize != null
                                              : (monthProvider?.warmUpModel?.files?.isNotEmpty ?? false) &&
                                                  !videoNotInitialized &&
                                                  videoSize != null)
                                          ? SizedBox(
                                              height: videoSize?.height,
                                              width: videoSize?.width,
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
                                                ),
                                              ),
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
                                              width: ScreenUtil.horizontalScale(10),
                                              height: ScreenUtil.horizontalScale(10),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_left,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                iconSize: ScreenUtil.verticalScale(4),
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
                                          } else {
                                            _videoPlayerController.play();
                                            hideControls();
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
                                ),
                              ),
                            )
                          : const SizedBox(),
                      videoSize != null
                          ? Positioned(
                              bottom: media.height * 0.09,
                              left: 10,
                              right: 10,
                              child: !videoNotInitialized && _chewieController?.videoPlayerController.value.isInitialized == true
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: media.height * 0.06, left: 20, right: 20),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: VideoProgressIndicator(
                                              _videoPlayerController,
                                              allowScrubbing: true,
                                              colors: const VideoProgressColors(
                                                playedColor: AppColors.primaryColor,
                                                bufferedColor: Colors.white,
                                                backgroundColor: Colors.black26,
                                              ),
                                            ),
                                          )
                                        ],
                                      ))
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
                          key: _containerKey,
                          height: media.height * 0.12,
                          width: media.width,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(70),
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
                        const SizedBox(
                          height: 10,
                        ),
                        guideLineText(),
                        const SizedBox(height: 15),
                        if (isExercise == 1)
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  exerciseDesc,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Builder(builder: (context) {
                                final dataHistory =
                                    monthProvider!.historyDataModel.where((element) => element.status == Status.completed).toList();

                                return ListView.builder(
                                  itemCount: monthProvider?.selectedExercise!.extra!.length,
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
                                        log('countIndex :::::::::::::::::: $countIndex');
                                        bool isTimerRunning = monthProvider!.timerAddress ==
                                            "$index-$countIndex-$exerciseIndex-${monthProvider?.overviewCurrentWeek}-${monthProvider?.overviewCurrentDay}";
                                        if (extraItem.type == 1) warmUpIndex++;
                                        if (extraItem.type == 2) backOffIndex++;
                                        if (extraItem.type == 3) workingIndex++;

                                        // String split = monthProvider
                                        //         ?.monthDataModel?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
                                        //         .toString()
                                        //         .split(" ")[1] ??
                                        //     "";
                                        // String ctId =
                                        //     "$split-${monthProvider?.selectedExercise?.id}-${monthProvider?.exerciseDetailModel?.sId}-$index-$countIndex-${monthProvider?.circuitIndex}";
                                        //
                                        // bool isCompleted() {
                                        //   final val = monthProvider!.historyDataModel.where((element) => element.dataId == ctId);
                                        //   bool val1 = false;
                                        //   if (val.isNotEmpty) {
                                        //     val1 = val.first.status == Status.completed;
                                        //   }
                                        //   return val1;
                                        // }

                                        int lastDataMainIndex = dataHistory.isNotEmpty ? (dataHistory.last.index ?? 0) : 0;
                                        int lastDataSubIndex = dataHistory.isNotEmpty ? dataHistory.last.subIndex ?? -1 : -1;
                                        if (lastDataSubIndex ==
                                            ((monthProvider!.selectedExercise!.extra![lastDataMainIndex].sets! - 1) +
                                                (monthProvider!.selectedExercise!.extra![lastDataMainIndex].type == 3
                                                    ? (extraSetModel.length)
                                                    : 0))) {
                                          lastDataMainIndex += 1;
                                          lastDataSubIndex = 0;
                                        } else {
                                          lastDataSubIndex += 1;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: ExerciseSetCard(
                                            countIndex: countIndex,
                                            available: (lastDataMainIndex == index && lastDataSubIndex == countIndex),
                                            isEditable: isEditable,
                                            makeRefresh: () {
                                              setState(() {});
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
                                            exercise: exerciseIndex,
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
                              }),
                              SizedBox(height: 20),
                              count != 0 && !isCurrentDaySkipped && !isCurrentDayCompleted
                                  ? Padding(
                                      padding: const EdgeInsets.only(bottom: 40),
                                      child: ButtonWidget(
                                        onPress: () async {
                                          final data = monthProvider?.selectedExercise!.extra!.where((element) => element.type == 3);
                                          if (data!.isNotEmpty) {
                                            monthProvider?.addSetCountInWorkingSet();
                                            _addExtraSet(data.first);
                                            await Future.delayed(Duration(milliseconds: 200));
                                          }
                                          setState(() {});
                                        },
                                        isLoading: false,
                                        color: Colors.grey,
                                        textColor: Colors.white,
                                        text: "Add Set",
                                      ),
                                    )
                                  : SizedBox(),
                              Container(
                                  height: 0.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  width: media.width,
                                  color: Colors.black12),
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
                                                      : monthProvider.isPumpDay && monthProvider.isCircuit
                                                          ? "Finish"
                                                          : "Finish & Next",
                                              textColor: Colors.white,
                                              onPress: () async {
                                                int count = 0;
                                                await _saveExerciseData(
                                                    status: Status.completed,
                                                    id: monthProvider.isPumpDay && monthProvider.isCircuit
                                                        ? "${monthProvider.exerciseDetailModel!.sId.toString()}-${monthProvider.circuitIndex}"
                                                        : monthProvider.exerciseDetailModel!.sId.toString(),
                                                    type: monthProvider.isCircuit ? "Circuit - ${monthProvider.circuitIndex}" : "Exercise");

                                                if (monthProvider.isPumpDay && monthProvider.isCircuit) {
                                                  Navigator.pop(context);
                                                } else {
                                                  for (var element in monthProvider.exerciseHistoryModel) {
                                                    if (element.status.toString() == Status.completed) {
                                                      count++;
                                                    }
                                                  }
                                                  String split = monthProvider
                                                          .monthDataModel?.weeks?[monthProvider.overviewCurrentWeek - 1].idList?.first
                                                          .toString()
                                                          .split(" ")[1] ??
                                                      "";

                                                  if (monthProvider.dayDataModel?.exercises?.length != count &&
                                                      monthProvider.dayDataModel?.exercises?.length != monthProvider.selectedExIndex + 1) {
                                                    Navigator.pop(context);

                                                    await Future.delayed(const Duration(milliseconds: 100));

                                                    int skipIndex = monthProvider.selectedExIndex + 1;
                                                    for (int i = skipIndex; i < monthProvider.dayDataModel!.exercises!.length; i++) {
                                                      var elementI = monthProvider.dayDataModel!.exercises![i];
                                                      String dataId =
                                                          "$split-${monthProvider.monthDataModel?.id}-${monthProvider.weekDataModel?.id}-${monthProvider.weekDataModel?.idList![monthProvider.overviewCurrentDay - 1]}-${elementI.exerciseId}";
                                                      bool val = monthProvider.exerciseHistoryModel
                                                          .any((element) => element.dataId == dataId && element.status == Status.completed);
                                                      if (val == false) {
                                                        monthProvider.setSelectedExercise(elementI, i);
                                                        monthProvider.updateWarmUp(false);

                                                        bool isLast = i ==
                                                            monthProvider.dayDataModel!.exercises?.indexWhere((element) =>
                                                                element.exerciseId ==
                                                                monthProvider.dayDataModel!.exercises?.last.exerciseId);
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
                                              color: AppColors.primaryColor,
                                              isLoading: false,
                                            ),
                                          );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Consumer<MonthProvider>(
                                  builder: (context, monthProvider, child) {
                                    return ButtonWidget(
                                      text:
                                          monthProvider.exerciseHistoryDetails?.status == Status.skipped ? "Unskip?" : "Skip the exercise",
                                      textColor: const Color(0xFFFFFFFF),
                                      color: AppColors.skipDayColor,
                                      onPress: () async {
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
                                      isLoading: false,
                                    );
                                  },
                                ),
                              ],
                              const EquipmentSection(),
                            ],
                          )
                        else
                          const SizedBox()
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: isExercise == 1
          ? const SizedBox(height: 0, width: 0)
          : loading
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
                  child: ButtonWidget(
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
                ),
    );
  }

  Row guideLineText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: isExercise == 1
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(254, 233, 232, 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(
                      (monthProvider!.selectedExercise!.guide == "" || monthProvider!.selectedExercise!.guide == null
                          ? "Exercise GuideLines will be displayed here."
                          : monthProvider!.selectedExercise!.guide.toString()),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                : Text(
                    (monthProvider?.warmUpModel?.description ?? "") == ""
                        ? "Warm-Up GuideLines will be displayed here."
                        : ((monthProvider?.warmUpModel?.description ?? "").toString()),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
          ),
        ),
      ],
    );
  }

  double calculateHeight(double width, double aspectRatio) {
    return width / aspectRatio;
  }

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
      "extraId": "",
      "date": "${DateTime.now().toUtc()}",
      "dataId": dataId,
    };
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

    if (status == Status.completed) {
      totalWeight = 0;
      monthProvider?.historyDataModel.forEach(
        (element) {
          final weight = double.parse(element.weight.toString());
          final reps = double.parse(element.reps.toString());
          final effort = double.parse(element.effort.toString().replaceAll("+", ""));
          final cal = weight * (reps + effort);
          totalWeight += cal;
        },
      );
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
    };

    final data1 = {
      "status": status,
      "type": type,
      "totalWeight": totalWeight.toString(),
    };

    if (monthProvider!.exerciseHistoryModel.isNotEmpty) {
      if (monthProvider!.exerciseHistoryModel.any((element) => element.dataId == dataId)) {
        await DatabaseHelper().updateData(data: data1, tableName: DatabaseHelper.exerciseStatus, id: dataId);
      } else {
        await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
      }
    } else {
      await DatabaseHelper().insertData(data: data, tableName: DatabaseHelper.exerciseStatus);
    }

    await monthProvider?.fetchExerciseStatusLocalData();
    await monthProvider?.updateDayData();
    monthProvider?.fetchExerciseHistoryLocalData();
    monthProvider?.fetchExerciseSingleExerciseLocalData(dataId);
    monthProvider?.getLiftedWeightGraphData();

    if (status == Status.completed && type == "Exercise") {
      monthProvider?.exerciseCompletedApi();
    }
  }
}
