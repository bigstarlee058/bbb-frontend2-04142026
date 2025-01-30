// import 'dart:async';
// import 'dart:developer';
//
// import 'package:bbb/components/button_widget.dart';
// import 'package:bbb/components/warmup_card.dart';
// import 'package:bbb/pages/ExerciseView/widgets/4_2_add_notes.dart';
// import 'package:bbb/pages/ExerciseView/widgets/back_off_card.dart';
// import 'package:bbb/pages/ExerciseView/widgets/equipment_section.dart';
// import 'package:bbb/pages/ExerciseView/widgets/normal_set_card.dart';
// import 'package:bbb/pages/ExerciseView/widgets/notes_slideout.dart';
// import 'package:bbb/providers/data_provider.dart';
// import 'package:bbb/providers/user_data_provider.dart';
// import 'package:bbb/utils/custom_prints.dart';
// import 'package:bbb/utils/screen_util.dart';
// import 'package:bbb/values/app_colors.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:bbb/models/day.dart';
// import 'package:bbb/models/dayexercise.dart';
// import 'package:bbb/models/week.dart';
//
// import '../../middleware/notification_service.dart';
// import '../../providers/exercise_history_provider.dart';
// import '../../providers/weekly_graph_provider.dart';
// import '../../values/app_constants.dart';
// import '../../values/clip_path.dart';
//
// class ExercisePage extends StatefulWidget {
//   const ExercisePage({super.key});
//
//   @override
//   State<ExercisePage> createState() => _ExercisePageState();
// }
//
// class _ExercisePageState extends State<ExercisePage> {
//   DataProvider? dataProvider;
//   UserDataProvider? userData;
//
//   bool loading = false;
//   bool videoNotInitialized = false;
//   int weight = 20;
//   int reps = 5;
//   int sets = 5;
//   int rest = 20;
//   int exerciseIndex = 0;
//   String exerciseDesc = "";
//   var params = [];
//   String exerciseName = "";
//   int isExercise = 0;
//   List<dynamic> exercises = [];
//
//   // VimeoPlayer? vimeoPlayer;
//   var media;
//   double height = 0.0;
//   double useHeight = 0.0;
//   final GlobalKey _containerKey = GlobalKey();
//
//   // Size? _containerSize;
//   int globalIndex = 0;
//
//   late WeeklyGraphProvider weeklyGraphProvider;
//
//   late ExerciseHistoryProvider exerciseHistoryProvider;
//
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   Size? videoSize;
//
//   String timerAddress = '';
//
//   @override
//   void initState() {
//     dataProvider = Provider.of<DataProvider>(context, listen: false);
//     userData = Provider.of<UserDataProvider>(context, listen: false);
//     log('exerciseIndex :::::::::::::::::: ${exerciseIndex}');
//     NotificationService.clearNotification();
//     weeklyGraphProvider = Provider.of<WeeklyGraphProvider>(context, listen: false);
//     exerciseHistoryProvider = Provider.of<ExerciseHistoryProvider>(context, listen: false);
//     exerciseHistoryProvider.getExercise();
//     exerciseHistoryProvider.updateId(userData!.currentExercise.id);
//     userData!.fetchTimerAddress();
//
//     fetchExercise();
//     userData!.getTodayHistoryData();
//     try {
//       debugPrint("this is exercise page ${userData?.currentExercise.id}");
//
//       weight = userData?.currentExercise.weight as int;
//       reps = userData?.currentExercise.reps as int;
//       sets = userData?.currentExercise.sets as int;
//       rest = userData?.currentExercise.rest as int;
//       // exerciseIndex = userData?.currentExercise.id as int;
//
//       if (userData!.currentDayObj.warmups.isNotEmpty) {
//         userData?.fetchWarmUp(userData!.currentDayObj.warmups[0].id);
//       }
//       indexOfWarmupBackOffNormal();
//     } catch (e) {
//       debugPrint('The late variable has not been initialized.');
//     }
//     userData?.todayHistoryCreated(exerciseIndex);
//     getExercises();
//     super.initState();
//   }
//
//   void getExercises() {
//     Week firstWeek = dataProvider?.workout?.weeks[userData!.currentWeek - 1] as Week;
//
//     if (firstWeek.days.length > userData!.currentDay) {
//       Day firstDay = firstWeek.days[userData!.currentDay - 1];
//       exercises = firstDay.exercises
//           .where((dynamic exercise) => (exercise as DayExercise).formats.contains(userData?.selectedExerciseFormatAlternate))
//           .toList();
//     } else {
//       exercises = [];
//     }
//   }
//
//   List values = [];
//   Timer? _hideControlsTimer;
//
//   void fetchExercise() async {
//     setState(() {
//       loading = true;
//     });
//     await userData?.fetchCurrentEx(userData!.currentExercise.id, "exercise 95");
//     if (userData!.currentExerciseObj.files.isNotEmpty) {
//       initializeVideo(userData?.currentExerciseObj.files[0]['link']);
//     } else {
//       loading = false;
//       videoNotInitialized = false;
//       setState(() {});
//     }
//
//     exerciseDesc = userData?.currentExerciseObj.description ?? "";
//   }
//
//   Future<void> initializeVideo(String url) async {
//     try {
//       // Initialize the video player controller
//       _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
//       await _videoPlayerController.initialize();
//
//       // Initialize the ChewieController with custom controls
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: false,
//         looping: false,
//         showControls: false,
//         aspectRatio: _videoPlayerController.value.aspectRatio,
//         // Disable default controls// Use custom controls here
//       );
//
//       if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
//         // hideControls();
//         videoSize = calculateVideoSize(aspectRatio: _chewieController!.aspectRatio!, context: context);
//         setState(() {});
//       }
//
//       setState(() {
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         videoNotInitialized = true;
//         loading = false;
//       });
//       debugPrint("VIDEO NOT INITIALIZED: $e");
//     }
//   }
//
//   bool showControls = true;
//   bool isFullscreen = false;
//
//   void hideControls() {
//     _hideControlsTimer = Timer(const Duration(seconds: 5), () {
//       setState(() {
//         showControls = false;
//       });
//     });
//   }
//
//   void showControlsOnTap() {
//     setState(() {
//       showControls = !showControls;
//     });
//     _hideControlsTimer?.cancel(); // Cancel any active timer
//     // hideControls(); // Start the timer again to hide the controls after 3 seconds
//   }
//
//   void toggleFullscreen() {
//     setState(() {
//       isFullscreen = !isFullscreen;
//     });
//     if (isFullscreen) {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
//     } else {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//     }
//   }
//
//   Size calculateVideoSize({
//     required BuildContext context,
//     required double aspectRatio, // Aspect ratio of the video (width/height)
//   }) {
//     final screenSize = MediaQuery.of(context).size;
//
//     // Maximum allowable width and height based on screen dimensions
//     double maxWidth = screenSize.width;
//     double maxHeight = screenSize.height;
//
//     // Calculate height dynamically based on width and aspect ratio
//     double calculatedHeight = maxWidth / aspectRatio;
//
//     // If calculated height exceeds maxHeight, adjust width instead
//     if (calculatedHeight > maxHeight) {
//       calculatedHeight = maxHeight;
//       maxWidth = maxHeight * aspectRatio;
//     }
//
//     return Size(maxWidth, calculatedHeight);
//   }
//
//   int wmInd = -1; // Starting index of warmup
//   int bckInd = -1; // Starting index of backoff
//   int normInd = -1; // Starting index of normal
//
//   void indexOfWarmupBackOffNormal() {
//     var extraList = userData?.currentDayObj.exercises[exerciseIndex].extra;
//     debugPrint("this is exercise page ${extraList}");
//     // Check if extraList is valid and not empty
//     if (extraList != null && extraList.isNotEmpty) {
//       for (int i = 0; i < extraList.length; i++) {
//         final extraItem = extraList[i];
//         int type = int.tryParse(extraItem['type'].toString()) ?? -1;
//
//         if ((type == 1 || extraItem['type'] == 1) && wmInd == -1) {
//           setState(() {
//             wmInd = i;
//           });
//         } else if ((type == 2 || extraItem['type'] == 2) && bckInd == -1) {
//           setState(() {
//             bckInd = i;
//           });
//         } else if ((type == 3 || extraItem['type'] == 3) && normInd == -1) {
//           setState(() {
//             normInd = i;
//           }); // Assign index of the first normal type
//         }
//
//         // If all indices are assigned, exit early
//         if (wmInd != -1 && bckInd != -1 && normInd != -1) {
//           break;
//         }
//       }
//     }
//
//     // Debugging output
//     customPrintB('Warmup Index: $wmInd');
//     customPrintB('Backoff Index: $bckInd');
//     customPrintB('Normal Index: $normInd');
//   }
//
//   @override
//   void dispose() {
//     _chewieController!.dispose();
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     media = MediaQuery.of(context).size;
//     ScreenUtil.init(context);
//
//     try {
//       params = ModalRoute.of(context)!.settings.arguments as List<String>;
//       exerciseName = params[0];
//       isExercise = int.parse(params[1]);
//       exerciseIndex = int.parse(params[2]);
//       log('exerciseIndex ::::::::::::::::::11 ${exerciseIndex}');
//     } catch (e) {
//       customPrintR("issue in parameter $e");
//     }
//
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       body: loading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primaryColor,
//               ),
//             )
//           : SingleChildScrollView(
//               physics: const ClampingScrollPhysics(),
//               child: Column(
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     fit: StackFit.loose,
//                     children: [
//                       Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               showControlsOnTap();
//                             },
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   color: Colors.black,
//                                   child: Column(
//                                     children: [
//                                       userData!.currentExerciseObj.files.isNotEmpty && !videoNotInitialized && videoSize != null
//                                           ? SizedBox(
//                                               height: videoSize!.height,
//                                               width: videoSize!.width,
//                                               child: Chewie(
//                                                 controller: _chewieController!,
//                                               ),
//                                             )
//                                           : Container(
//                                               height: media.height * 0.4,
//                                               color: Colors.black12,
//                                               child: const Center(
//                                                   child: Text(
//                                                 'No Video Available',
//                                                 style: TextStyle(color: Colors.white),
//                                               )),
//                                             ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   // height: media.height / 1.1,
//                                   width: media.width,
//                                   decoration: const BoxDecoration(),
//                                   child: SafeArea(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(right: 10),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             margin: EdgeInsets.only(
//                                               left: ScreenUtil.horizontalScale(4),
//                                             ),
//                                             decoration: const BoxDecoration(
//                                               color: Color(0XFFd18a9b),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: SizedBox(
//                                               width: ScreenUtil.horizontalScale(10), // Size of the circle
//                                               height: ScreenUtil.horizontalScale(10),
//                                               child: IconButton(
//                                                 padding: EdgeInsets.zero, // Removes the default padding
//                                                 icon: const Icon(
//                                                   Icons.keyboard_arrow_left,
//                                                   color: Colors.white,
//                                                 ),
//                                                 onPressed: () => Navigator.pop(context),
//                                                 iconSize: ScreenUtil.verticalScale(4), // Icon size remains the same
//                                               ),
//                                             ),
//                                           ),
//                                           // Container(
//                                           //   height: 40,
//                                           //   width: 40,
//                                           //   margin: const EdgeInsets.only(
//                                           //     left: 12,
//                                           //     right: 12,
//                                           //   ),
//                                           //   decoration: BoxDecoration(
//                                           //     color:
//                                           //         Colors.grey.withOpacity(0.9),
//                                           //     shape: BoxShape.circle,
//                                           //   ),
//                                           //   child: IconButton(
//                                           //     padding: EdgeInsets
//                                           //         .zero, // Removes the default padding
//                                           //     icon: const Icon(
//                                           //       Icons.keyboard_arrow_left,
//                                           //       color: Colors.white,
//                                           //     ),
//                                           //     onPressed: () =>
//                                           //         Navigator.pop(context),
//                                           //     iconSize: ScreenUtil.verticalScale(
//                                           //         4), // Icon size remains the same
//                                           //   ),
//                                           // ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       videoSize != null
//                           ? Positioned(
//                               bottom: videoSize!.height / 2,
//                               left: 10,
//                               right: 10,
//                               child: Visibility(
//                                 visible: showControls,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                   children: [
//                                     // Skip backward button
//                                     IconButton(
//                                       iconSize: 40,
//                                       icon: const Icon(
//                                         Icons.replay_10,
//                                         color: Colors.white70,
//                                       ),
//                                       onPressed: () {
//                                         _videoPlayerController.seekTo(
//                                           _videoPlayerController.value.position - const Duration(seconds: 10),
//                                         );
//                                       },
//                                     ),
//                                     IconButton(
//                                       iconSize: 60,
//                                       icon: Icon(
//                                         _videoPlayerController.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
//                                         color: Colors.white70,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           if (_videoPlayerController.value.isPlaying) {
//                                             _videoPlayerController.pause();
//                                           } else {
//                                             _videoPlayerController.play();
//                                             hideControls();
//                                           }
//                                         });
//                                       },
//                                     ),
//                                     // Skip forward button
//                                     IconButton(
//                                       iconSize: 40,
//                                       icon: const Icon(
//                                         Icons.forward_10,
//                                         color: Colors.white70,
//                                       ),
//                                       onPressed: () {
//                                         _videoPlayerController.seekTo(
//                                           _videoPlayerController.value.position + const Duration(seconds: 10),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : const SizedBox(),
//                       videoSize != null
//                           ? Positioned(
//                               bottom: media.height * 0.09,
//                               left: 10,
//                               right: 10,
//                               child: !videoNotInitialized && _chewieController!.videoPlayerController.value.isInitialized == true
//                                   ? Container(
//                                       margin: EdgeInsets.only(bottom: media.height * 0.06, left: 20, right: 20),
//                                       child: Row(
//                                         children: [
//                                           Flexible(
//                                             child: VideoProgressIndicator(
//                                               _videoPlayerController,
//                                               allowScrubbing: true,
//                                               colors: const VideoProgressColors(
//                                                 playedColor: AppColors.primaryColor,
//                                                 bufferedColor: Colors.white,
//                                                 backgroundColor: Colors.black26,
//                                               ),
//                                             ),
//                                           )
//                                         ],
//                                       ))
//                                   : const SizedBox(),
//                             )
//                           : const SizedBox(),
//                       Positioned(
//                         bottom: media.height * 0.12,
//                         right: 0,
//                         child: SizedBox(
//                           height: media.height / 3.99,
//                           width: media.width,
//                           child: Align(
//                             alignment: Alignment.bottomRight,
//                             child: ClipPath(
//                               clipper: DiagonalClipper(),
//                               child: Container(
//                                 height: media.height / 11,
//                                 width: media.width / 6,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         child: Container(
//                           key: _containerKey,
//                           height: media.height * 0.12,
//                           width: media.width,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(70),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Container(
//                                 alignment: Alignment.bottomCenter,
//                                 decoration:
//                                     const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50))),
//                                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     SizedBox(
//                                       height: media.height * 0.018,
//                                     ),
//                                     //
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the content
//                                       children: [
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(top: 8, right: 10),
//                                             child: Text(
//                                               exerciseName,
//                                               maxLines: 2,
//                                               style: const TextStyle(
//                                                 height: 1.3,
//                                                 color: AppColors.primaryColor,
//                                                 fontSize: 25,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Navigator.pushNamed(
//                                                   context,
//                                                   "/exerciseHistory",
//                                                   arguments: {
//                                                     'exerciseName': exerciseName,
//                                                     'exerciseIndex': exerciseIndex,
//                                                   },
//                                                 );
//                                               },
//                                               child: const Icon(
//                                                 Icons.insert_chart_outlined_sharp,
//                                                 color: AppColors.primaryColor,
//                                                 size: 30,
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               height: 5,
//                                             ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 showModalBottomSheet(
//                                                   backgroundColor: Colors.white,
//                                                   context: context,
//                                                   isScrollControlled: true,
//                                                   builder: (BuildContext context) {
//                                                     return AddNoteBottomSheet();
//                                                   },
//                                                 );
//                                               },
//                                               child: const Icon(
//                                                 Icons.edit,
//                                                 color: AppColors.primaryColor,
//                                                 size: 30,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 30),
//                     // padding: const EdgeInsets.only(top: 40),
//                     child: Column(
//                       children: [
//                         const SizedBox(
//                           height: 5,
//                         ),
//
//                         ///Guideline Section
//                         guideLineText(),
//                         const SizedBox(
//                           height: 15,
//                         ),
//
//                         isExercise == 1
//                             ? Column(
//                                 children: [
//                                   Consumer<UserDataProvider>(
//                                       builder: (context, userData, child) => Align(
//                                             alignment: Alignment.topLeft,
//                                             child: Text(
//                                               exerciseDesc,
//                                               style: const TextStyle(
//                                                 color: Colors.black,
//                                               ),
//                                               textAlign: TextAlign.left,
//                                             ),
//                                           )),
//
//                                   const SizedBox(
//                                     height: 15,
//                                   ),
//
//                                   ///warmup card section
//                                   Consumer<UserDataProvider>(
//                                     builder: (context, userData, child) {
//                                       log('userData?.isEditExercise :::::::::::::::::: ${userData.isEditExercise}');
//
//                                       var extraList = userData.currentDayObj.exercises[exerciseIndex].extra;
//                                       if (extraList != null && extraList.isNotEmpty) {
//                                         List<Widget> warmupCards = [];
//                                         for (int i = 0; i < extraList.length; i++) {
//                                           final extraItem = extraList[i];
//                                           if (int.parse(extraItem['type'].toString()) == 1 || extraItem['type'] == 1) {
//                                             int setCount = int.parse(extraItem['sets'].toString());
//                                             for (int setIndex = 0; setIndex < setCount; setIndex++) {
//                                               bool isTimerRunning = userData.timerAddress == "$i-$setIndex-$exerciseIndex";
//
//                                               log('userData.timerAddress :::::::::::::::::: ${userData.timerAddress}');
//                                               log('isTimerRunning :::::::::::::::::: ${isTimerRunning}');
//
//                                               warmupCards.add(WarmupCard(
//                                                 isTimerRunning: isTimerRunning,
//                                                 exerciseName: exerciseName,
//                                                 title: "Warmup Set",
//                                                 isOpened: isTimerRunning
//                                                     ? true
//                                                     : i == 0 && setIndex == 0
//                                                         ? true
//                                                         : false,
//                                                 index: i,
//                                                 subIndex: setIndex,
//                                                 exercise: exerciseIndex,
//                                                 set: int.parse(extraItem['sets'].toString()),
//                                                 weight: int.parse(extraItem['weight'].toString()),
//                                                 reps: int.parse(extraItem['reps'].toString()),
//                                                 repsInReverse: 100,
//                                                 load: int.parse(extraItem['load'] == null || extraItem['load'] == ""
//                                                     ? "0"
//                                                     : extraItem['load'].toString()),
//                                                 type: int.parse(extraItem['type'].toString()),
//                                                 restDuration: int.parse(extraItem['rest'].toString()),
//                                               ));
//                                               // Add a gap after each WarmupCard
//                                               warmupCards.add(const SizedBox(height: 20)); // Add gap after every card except the last one
//                                             }
//                                           }
//                                         }
//                                         // Return Column with all the matching WarmupCard widgets
//                                         return Column(
//                                           children: warmupCards,
//                                         );
//                                       }
//                                       // Return an empty widget if no matching type is found
//                                       return const SizedBox(height: 0);
//                                     },
//                                   ),
//                                   // const SizedBox(height: 15),
//
//                                   ///normal card section
//                                   Consumer<UserDataProvider>(
//                                     builder: (context, userData, child) {
//                                       // Ensure `userData` and necessary properties are not null
//                                       if (userData.currentDayObj.exercises[exerciseIndex].extra.isNotEmpty ?? false) {
//                                         List<Widget> exerciseSetCards = [];
//
//                                         // Loop through all extra items
//                                         for (int i = 0; i < userData.currentDayObj.exercises[exerciseIndex].extra.length; i++) {
//                                           final extraItem = userData.currentDayObj.exercises[exerciseIndex].extra[i];
//
//                                           // Check if the type is 2
//                                           if (int.parse(extraItem['type'].toString()) == 3) {
//                                             int setCount = int.parse(extraItem['sets'].toString());
//
//                                             // Generate ExerciseSetCard widgets for the number of sets
//                                             for (int setIndex = 0; setIndex < setCount; setIndex++) {
//                                               bool isTimerRunning = userData.timerAddress == "$i-$setIndex-$exerciseIndex";
//                                               exerciseSetCards.add(ExerciseSetCard(
//                                                 isTimerRunning: isTimerRunning,
//                                                 type: int.parse(extraItem['type'].toString()),
//                                                 exerciseName: exerciseName,
//                                                 title: "Normal Set",
//                                                 isOpened: false,
//                                                 index: i,
//                                                 subIndex: setIndex,
//                                                 exercise: exerciseIndex,
//                                                 set: setIndex + 1,
//                                                 weight: int.parse(extraItem['weight'].toString()),
//                                                 reps: int.parse(extraItem['reps'].toString()),
//                                                 repsInReverse: 100,
//                                                 // Default value or parse as needed
//                                                 load: int.parse(extraItem['load']?.toString() ?? "0"),
//                                                 restDuration: int.parse(extraItem['rest'].toString()),
//                                               ));
//
//                                               // Add a gap between the cards
//                                               exerciseSetCards.add(const SizedBox(height: 20));
//                                             }
//                                           }
//                                         }
//
//                                         // Return Column with all the matching BackOffSetCard widgets and gaps
//                                         return Column(
//                                           children: exerciseSetCards,
//                                         );
//                                       }
//
//                                       // Return an empty widget if no matching type is found
//                                       return const SizedBox(height: 0);
//                                     },
//                                   ),
//                                   // const SizedBox(height: 20),
//
//                                   ///back-off card section
//                                   Consumer<UserDataProvider>(
//                                     builder: (context, userData, child) {
//                                       // Ensure `userData` and necessary properties are not null
//                                       if (userData.currentDayObj.exercises[exerciseIndex].extra.isNotEmpty ?? false) {
//                                         List<Widget> backOffSetCards = [];
//
//                                         // Loop through all extra items
//                                         for (int i = 0; i < userData.currentDayObj.exercises[exerciseIndex].extra.length; i++) {
//                                           final extraItem = userData.currentDayObj.exercises[exerciseIndex].extra[i];
//
//                                           // Check if the type is 2
//                                           if (int.parse(extraItem['type'].toString()) == 2) {
//                                             int setCount = int.parse(extraItem['sets'].toString());
//
//                                             // Generate ExerciseSetCard widgets for the number of sets
//                                             for (int setIndex = 0; setIndex < setCount; setIndex++) {
//                                               bool isTimerRunning = userData.timerAddress == "$i-$setIndex-$exerciseIndex";
//                                               backOffSetCards.add(BackOffSetCard(
//                                                 isTimerRunning: isTimerRunning,
//                                                 exerciseName: exerciseName,
//                                                 title: "Back-Off Set",
//                                                 isOpened: false,
//                                                 index: i,
//                                                 subIndex: setIndex,
//                                                 exercise: exerciseIndex,
//                                                 set: int.parse(extraItem['sets'].toString()),
//                                                 weight: int.parse(extraItem['weight'].toString()),
//                                                 reps: int.parse(extraItem['reps'].toString()),
//                                                 repsInReverse: 100,
//                                                 //int.parse(extraItem['repsInReverse'].toString()),  // by default non selected
//                                                 load: int.parse(extraItem['load'] == null || extraItem['load'] == ""
//                                                     ? "0"
//                                                     : extraItem['load'].toString()),
//                                                 type: int.parse(extraItem['type'].toString()),
//                                                 restDuration: int.parse(extraItem['rest'].toString()),
//                                               ));
//                                               // Add a SizedBox for gap between cards
//                                               backOffSetCards.add(const SizedBox(height: 20));
//                                             }
//                                           }
//                                         }
//
//                                         // Return Column with all the matching BackOffSetCard widgets and gaps
//                                         return Column(
//                                           children: backOffSetCards,
//                                         );
//                                       }
//
//                                       // Return an empty widget if no matching type is found
//                                       return const SizedBox(height: 0);
//                                     },
//                                   ),
//
//                                   const SizedBox(height: 20),
//                                   InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         userData?.addCurrentExerciseData(exerciseIndex, weight, reps);
//                                         sets = sets + 1;
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(35), // Matches the container's border radius
//                                     child: Container(
//                                       height: 70,
//                                       width: 70,
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             AppColors.primaryColor.withOpacity(0.9),
//                                             AppColors.primaryColor.withOpacity(0.7),
//                                           ],
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomRight,
//                                         ),
//                                         borderRadius: BorderRadius.circular(35),
//                                       ),
//                                       child: const Icon(
//                                         Icons.add,
//                                         color: Colors.white,
//                                         size: 45,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 40),
//                                   Container(
//                                     height: 0.5,
//                                     margin: const EdgeInsets.symmetric(horizontal: 40),
//                                     width: media.width,
//                                     color: Colors.black12,
//                                   ),
//                                   const SizedBox(height: 40),
//                                   ButtonWidget(
//                                     text: "Finish & Next",
//                                     textColor: Colors.white,
//                                     onPress: () {
//                                       userData!.setShowTimerIndex(-1, -1, -1);
//
//                                       int count = 0;
//                                       userData!.exerciseHistory.forEach(
//                                         (element) {
//                                           if (element['state'].toString() == "finished") {
//                                             count++;
//                                           }
//                                         },
//                                       );
//                                       log('count :::::::::::::::::: ${count}');
//                                       log('exercises.length :::::::::::::::::: ${exercises.length}');
//                                       userData?.updateOrAddExerciseHistory(AppConstants.STATE_FINISHED);
//                                       weeklyGraphProvider.markExerciseCompleted();
//
//                                       userData?.storeTodayDataInMainExerciseHistoryData();
//                                       // userData?.notifyListeners();
//                                       // Navigator.pushNamed(context, '/today');
//                                       //Navigator.pop(context);
//
//                                       if (exercises.length != count) {
//                                         Navigator.pop(context);
//
//                                         var ind = 0;
//
//                                         userData!.exerciseHistory.sort(
//                                           (a, b) {
//                                             return int.parse(a['exerciseIndex'].toString())
//                                                 .compareTo(int.parse(b['exerciseIndex'].toString()));
//                                           },
//                                         );
//                                         setState(() {});
//                                         log(' userData!.exerciseHistory :::::::::::::::::: ${userData!.exerciseHistory}');
//
//                                         for (var element in userData!.exerciseHistory) {
//                                           var i = 0;
//                                           if (element['state'].toString() == "finished") {
//                                             i = int.parse(element['exerciseIndex']) + 1;
//                                             ind = i;
//                                           } else if (element['state'].toString() == "started") {
//                                             i = int.parse(element['exerciseIndex']);
//                                             ind = i;
//                                           } else {
//                                             i = int.parse(element['exerciseIndex']) + 1;
//                                             ind = i;
//                                           }
//                                         }
//                                         log('ind ::::::::::::::::::final ${ind}');
//                                         userData?.currentExIndex = ind;
//
//                                         userData?.updateCurrentExercise(exercises[ind - 1] as DayExercise);
//
//                                         Navigator.pushNamed(context, '/exercise', arguments: [
//                                           exercises[ind - 1]!.name.isEmpty ? 'Exercise ${ind + 1}' : exercises[ind - 1]!.name as String,
//                                           '1',
//                                           (ind - 1).toString(),
//                                         ]);
//                                         userData?.updateOrAddExerciseHistory(AppConstants.STATE_STARTED);
//                                       } else {
//                                         Navigator.pop(context);
//                                       }
//                                     },
//                                     color: AppColors.primaryColor,
//                                     isLoading: false,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   ButtonWidget(
//                                     text: "Skip the exercise",
//                                     textColor: const Color(0xFFFFFFFF),
//                                     color: AppColors.skipDayColor,
//                                     onPress: () {
//                                       userData?.updateOrAddExerciseHistory(AppConstants.STATE_SKIPPED);
//                                       Navigator.pushNamed(context, '/today');
//                                     },
//                                     isLoading: false,
//                                   ),
//                                   const EquipmentSection(),
//                                 ],
//                               )
//                             : const SizedBox(),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 50,
//                   ),
//                 ],
//               ),
//             ),
//       bottomNavigationBar: isExercise == 1
//           ? const SizedBox(height: 0, width: 0)
//           : loading
//               ? const SizedBox(
//                   height: 0,
//                   width: 0,
//                 )
//               : Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
//                   child: ButtonWidget(
//                     text: "Mark Complete",
//                     textColor: Colors.white,
//                     onPress: () {
//                       // userData?.updateOrAddDayHistory(AppConstants.STATE_FINISHED);
//                       // userData?.finishCurrentExercise();
//                       // tempData?.completeCurrentExercise();
//                       userData?.finishCurrentWarmUp();
//                       Navigator.pushNamed(context, '/today');
//                     },
//                     color: AppColors.primaryColor,
//                     isLoading: false,
//                   ),
//                 ),
//     );
//   }
//
//   Row guideLineText() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Consumer<UserDataProvider>(
//             builder: (context, userData, child) => Align(
//               alignment: Alignment.topLeft,
//               child: isExercise == 1
//                   ? Container(
//                       decoration: BoxDecoration(
//                         color: const Color.fromRGBO(254, 233, 232, 1.0),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//                       child: Text(
//                         (userData.currentExercise.guide == ""
//                             ? "Exercise GuideLines will be displayed here."
//                             : userData.currentExercise.guide.toString()),
//                         style: const TextStyle(
//                           color: Colors.black,
//                         ),
//                         textAlign: TextAlign.left,
//                       ),
//                     )
//                   : Text(
//                       (userData.currentWarmup.description == ""
//                           ? "Warm-Up GuideLines will be displayed here."
//                           : userData.currentWarmup.description.toString()),
//                       style: const TextStyle(
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.left,
//                     ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   double calculateHeight(double width, double aspectRatio) {
//     return width / aspectRatio;
//   }
// }
