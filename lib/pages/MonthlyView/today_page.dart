import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/day.dart';
import 'package:bbb/models/dayexercise.dart';
import 'package:bbb/models/week.dart';
import 'package:bbb/pages/video_intro_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/weekly_graph_provider.dart';
import 'package:bbb/utils/convert_util.dart';
import 'package:bbb/utils/custom_prints.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bbb/components/common_streak_with_notification.dart';

// import 'package:http/http.dart' as http;

import '../../providers/user_data_provider.dart';
import '../../routes/fade_page_route.dart';
import '../../values/app_constants.dart';
import 'circuits_view.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final today = DateTime.now();
  DataProvider? dataProvider;
  UserDataProvider? userData;
  late int week;
  late int day;

  bool isToday = true;
  bool isThisWeek = true;
  bool isNextWeek = false;
  bool isCompleted = false;
  bool isSkipped = false;
  List<dynamic> exercises = [];
  List<dynamic> relatedExercises = [];

  late WeeklyGraphProvider weeklyGraphProvider;

  int totalWarmups = 0;
  String _searchQuery = "";

  bool isPumpDay = false;

  @override
  void initState() {
    weeklyGraphProvider = Provider.of<WeeklyGraphProvider>(context, listen: false);

    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );
    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );

    userData?.fetchAllExercise();
    isCompleted = (userData!.dayHistory).any((element) =>
        ('${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}') ==
        ('${userData!.currentMonth} ${userData!.currentWeek} ${userData!.selectedDaySplit} ${userData!.currentDay} ${AppConstants.STATE_FINISHED}'));

    isSkipped = (userData!.dayHistory).any((element) =>
        ('${element['monthIndex']} ${element['weekIndex']} ${element['daySplit']} ${element['dayIndex']} ${element['state']}') ==
        ('${userData!.currentMonth} ${userData!.currentWeek} ${userData!.selectedDaySplit} ${userData!.currentDay} ${AppConstants.STATE_SKIPPED}'));

    setCurrentDayObj();
    customPrintB("isCompleted      $isCompleted");
    super.initState();
  }

  void _applyFilters(searchQuery) {
    setState(() {
      userData?.fetchAllFilterEx(searchQuery);
    });
  }

  void setCurrentDayObj() {
    DateTime? startTime;
    if (dataProvider?.workout?.startDate != null) {
      startTime = dataProvider!.workout!.startDate == "" ? DateTime.now() : DateTime.parse(dataProvider!.workout!.startDate!);
    } else {
      startTime = DateTime.now();
    }
    int dayDelta = today.difference(startTime).inDays;
    week = (dayDelta ~/ 7);
    day = dayDelta % 7;
    debugPrint("this is today page ${userData?.currentDay}");
    debugPrint("this is today page ${userData?.nextDayIndex}");
    exercises = userData!.currentDayObj.exercises
        .where((dynamic exercise) => (exercise as DayExercise).formats.contains(userData?.selectedExerciseFormatAlternate))
        .toList();
    totalWarmups = userData!.currentDayObj.warmups.length;

    // if (dataProvider!.workout.weeks.length >= userData!.currentWeek) {
    //   Week firstWeek =
    //       dataProvider?.workout?.weeks[userData!.currentWeek - 1] as Week;

    //   if (firstWeek.days.length > userData!.currentDay) {
    //     Day firstDay = firstWeek.days[userData!.currentDay - 1];
    //     userData?.currentDayObj = firstDay;
    //     exercises = firstDay.exercises
    //         .where((dynamic exercise) => (exercise as DayExercise)
    //             .formats
    //             .contains(userData?.selectedExerciseFormatAlternate))
    //         .toList();
    //     totalWarmups = firstDay.warmups.length;
    //   } else {
    //     exercises = [];
    //   }
    // } else {
    //   exercises = [];
    // }
    // Day firstDay =
    //     dataProvider!.selectWeekBasedOnSplit[userData!.currentDay - 1];
    // userData?.currentDayObj = firstDay;
    // totalWarmups = firstDay.warmups.length;

    // exercises = firstDay.exercises
    //     .where(
    //         (dynamic exercise) => (exercise as DayExercise).formats.contains(userData?.selectedExerciseFormatAlternate))
    //     .toList();

    isToday = ((week + 1 == userData!.currentWeek) && (day + 1 == userData!.currentDay));
    isThisWeek = (week + 1 == userData!.currentWeek);
    isNextWeek = (week + 1 > userData!.currentWeek);
  }

  void fetchWarmupData() {
    log('isPumpDay ::::::::::::::::::111 ${isPumpDay}');

    if (userData!.currentDayObj.warmups.isNotEmpty && !isPumpDay) {
      userData?.fetchWarmUp(userData!.currentDayObj.warmups[0].id);
    } else {
      userData?.fetchWarmUp(dataProvider!.pumpDayModel!.warmups![0].id!);
    }
  }

  void setExerciseToCompleted(int exerciseIndex) {
    userData?.isEditExercise = false;
    userData?.currentExIndex = exerciseIndex + 1;
    userData?.updateCurrentExercise(exercises[exerciseIndex] as DayExercise);
    userData?.notifyListeners();
    Navigator.pushNamed(context, '/exercise', arguments: [
      exercises[exerciseIndex]!.name.isEmpty ? 'Exercise ${exerciseIndex + 1}' : exercises[exerciseIndex]!.name as String,
      '1',
      exerciseIndex.toString(),
      //"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    ]);
    // Navigator.pushNamed(context, '/exercise', arguments: exercises[exerciseIndex]?.name ?? "Exercise $exerciseIndex");
    userData?.updateOrAddExerciseHistory(AppConstants.STATE_STARTED);
  }

  void setExerciseEdit(int exerciseIndex) {
    userData?.isEditExercise = true;
    userData?.currentExIndex = exerciseIndex + 1;
    log('exercises[exerciseIndex] :::::::::::::::::: ${exercises[exerciseIndex]}');
    userData?.updateCurrentExercise(exercises[exerciseIndex] as DayExercise);
    userData?.notifyListeners();
    Navigator.pushNamed(context, '/exercise', arguments: [
      exercises[exerciseIndex]!.name.isEmpty ? 'Exercise ${exerciseIndex + 1}' : exercises[exerciseIndex]!.name as String,
      '1',
      exerciseIndex.toString(),
      //"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    ]);
  }

  ///New extra
  void setExerciseExtraToCompleted(int exerciseIndex, int mainExcI) {
    userData?.updateCurrentExercise(exercises[mainExcI] as DayExercise);
    userData?.currentExIndex = exerciseIndex + 1;

    userData?.notifyListeners();
    Navigator.pushNamed(context, '/exercise', arguments: [
      exercises[mainExcI]!.name.isEmpty ? 'Exercise ${mainExcI + 1}' : exercises[mainExcI]!.name as String,
      '1',
      mainExcI.toString(),
      //"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    ]);
    // Navigator.pushNamed(context, '/exercise', arguments: exercises[exerciseIndex]?.name ?? "Exercise $exerciseIndex");
    userData?.updateOrAddExerciseHistory(AppConstants.STATE_STARTED);
  }

  Future<void> showRelatedExerciseDialog(int selectedIndex, dynamic exercise, bool addModal) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        var media = MediaQuery.of(context).size;
        int? selectExerciseSwapIndex;
        bool showFindMore = false;

        // Pagination variables
        int itemsPerPage = 5;
        int currentPageRelated = 0;
        int currentPageAll = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            List<Widget> buildExerciseList(List exercises, int currentPage, bool isAll) {
              int startIndex = currentPage * itemsPerPage + (!isAll ? 0 : userData!.currentRelatedExercises.length);
              int endIndex = (startIndex + itemsPerPage) > exercises.length + (!isAll ? 0 : userData!.currentRelatedExercises.length)
                  ? exercises.length + (!isAll ? 0 : userData!.currentRelatedExercises.length)
                  : startIndex + itemsPerPage;

              return [
                for (int i = startIndex; i < endIndex; i++) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectExerciseSwapIndex = i;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(width: ScreenUtil.horizontalScale(5)),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: ScreenUtil.horizontalScale(10),
                                height: ScreenUtil.horizontalScale(10),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/img/card.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(ScreenUtil.horizontalScale(1)),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenUtil.horizontalScale(2)),
                              Flexible(
                                  child: Text(
                                exercises[i - (!isAll ? 0 : userData!.currentRelatedExercises.length)].title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil.verticalScale(2),
                                ),
                              )),
                              SizedBox(width: ScreenUtil.horizontalScale(2)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(
                            ScreenUtil.verticalScale(1),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                            color: selectExerciseSwapIndex == i ? AppColors.primaryColor : Colors.white,
                          ),
                          child: selectExerciseSwapIndex == i
                              ? Icon(
                                  Icons.check,
                                  size: ScreenUtil.verticalScale(2),
                                  color: Colors.white,
                                )
                              : Icon(
                                  null,
                                  size: ScreenUtil.verticalScale(2),
                                ),
                        ),
                        SizedBox(width: ScreenUtil.horizontalScale(5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ];
            }

            Widget _buildPaginationControls(int currentPage, int totalItems, Function(int) onPageChange) {
              int totalPages = (totalItems / itemsPerPage).ceil();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)), // Add horizontal padding here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: currentPage > 0 ? () => onPageChange(0) : null,
                      icon: const Icon(Icons.first_page),
                    ),
                    IconButton(
                      onPressed: currentPage > 0 ? () => onPageChange(currentPage - 1) : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text('Page ${currentPage + 1} of $totalPages'),
                    IconButton(
                      onPressed: (currentPage + 1) < totalPages ? () => onPageChange(currentPage + 1) : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                    IconButton(
                      onPressed: (currentPage + 1) < totalPages ? () => onPageChange(totalPages - 1) : null,
                      icon: const Icon(Icons.last_page),
                    ),
                  ],
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(0),
              child: SizedBox(
                width: ScreenUtil.horizontalScale(96),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ScreenUtil.verticalScale(65),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!addModal) ...[
                          Container(
                            width: media.width,
                            padding: const EdgeInsets.all(24),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Select Related Exercise',
                                style: TextStyle(
                                  fontSize: ScreenUtil.horizontalScale(5.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          Consumer<UserDataProvider>(
                            builder: (context, userData, child) => userData.currentRelatedExercises.isNotEmpty
                                ? Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: ScreenUtil.verticalScale(60),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: buildExerciseList(userData.currentRelatedExercises, currentPageRelated, false),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                          Container(
                            width: media.width,
                            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Or select from the list:',
                                style: TextStyle(
                                  fontSize: ScreenUtil.horizontalScale(5.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SearchEquipmentField(
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query; // Update the search query
                                currentPageAll = 0;
                                _applyFilters(query); // Reset pagination when searching
                              });
                            },
                          ),
                          Consumer<UserDataProvider>(
                            builder: (context, userData, child) => userData.allFilterExercises.isNotEmpty
                                ? Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: ScreenUtil.verticalScale(60),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: buildExerciseList(userData.allFilterExercises, currentPageAll, true),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Pagination controls for all exercises
                                      _buildPaginationControls(
                                        currentPageAll,
                                        userData.allFilterExercises.length,
                                        (page) {
                                          setState(() {
                                            currentPageAll = page;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                        ] else ...[
                          Container(
                            width: media.width,
                            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Select from the list:',
                                style: TextStyle(
                                  fontSize: ScreenUtil.horizontalScale(5.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SearchEquipmentField(
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query; // Update the search query
                                currentPageAll = 0;
                                _applyFilters(query); // Reset pagination when searching
                              });
                            },
                          ),
                          Consumer<UserDataProvider>(
                            builder: (context, userData, child) => userData.allFilterExercises.isNotEmpty
                                ? Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: ScreenUtil.verticalScale(60),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: buildExerciseList(userData.allFilterExercises, currentPageAll, false),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Pagination controls for all exercises
                                      _buildPaginationControls(
                                        currentPageAll,
                                        userData.allFilterExercises.length,
                                        (page) {
                                          setState(() {
                                            currentPageAll = page;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                        ],
                        // ignore: dead_code
                        if (showFindMore) ...[
                          const SizedBox(height: 10), // Space before the text box
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.search, color: Colors.black), // Non-clickable icon
                                const SizedBox(width: 8), // Space between icon & text field
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Type to find more...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        // Logic to load more items or search
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10), // Space after the text box
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: const Color(0xFFDDDDDD),
                                  shadowColor: Colors.grey,
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: selectExerciseSwapIndex != null &&
                                        !((!addModal &&
                                                selectExerciseSwapIndex! < userData!.currentRelatedExercises.length &&
                                                userData!.currentDayObj.exercises.any((exerciseData) =>
                                                    exerciseData.id == userData!.currentRelatedExercises[selectExerciseSwapIndex!].id)) ||
                                            (!addModal &&
                                                selectExerciseSwapIndex! >= userData!.currentRelatedExercises.length &&
                                                userData!.currentDayObj.exercises.any((exerciseData) =>
                                                    exerciseData.id ==
                                                    userData!
                                                        .allFilterExercises[
                                                            selectExerciseSwapIndex! - userData!.currentRelatedExercises.length]
                                                        .id)) ||
                                            (addModal &&
                                                userData!.currentDayObj.exercises.any((exerciseData) =>
                                                    exerciseData.id == userData!.allFilterExercises[selectExerciseSwapIndex!].id)))
                                    ? () {
                                        // Your logic for swap or add
                                        if (!addModal) {
                                          if (selectExerciseSwapIndex! < userData!.currentRelatedExercises.length) {
                                            dataProvider?.swapExerciseById(
                                                userData!.currentWeek,
                                                userData!.currentDay,
                                                selectedIndex,
                                                exercise.id,
                                                userData!.currentRelatedExercises[selectExerciseSwapIndex!].title,
                                                userData!.currentRelatedExercises[selectExerciseSwapIndex!].id);
                                          } else {
                                            dataProvider?.swapExerciseById(
                                                userData!.currentWeek,
                                                userData!.currentDay,
                                                selectedIndex,
                                                exercise.id,
                                                userData!
                                                    .allFilterExercises[
                                                        selectExerciseSwapIndex! - userData!.currentRelatedExercises.length!]
                                                    .title,
                                                userData!
                                                    .allFilterExercises[
                                                        selectExerciseSwapIndex! - userData!.currentRelatedExercises.length!]
                                                    .id);
                                          }

                                          userData?.removeExerciseDataById(selectedIndex);
                                        } else {
                                          // Add logic
                                          if (exercises.isNotEmpty) {
                                            DayExercise newDayExercise = DayExercise(
                                                id: userData?.allFilterExercises[selectExerciseSwapIndex!].id ?? "",
                                                id_: "",
                                                typeId: exercises[0].typeId ?? 1,
                                                name: userData?.allFilterExercises[selectExerciseSwapIndex!].title ??
                                                    "Exercise ${exercises.length + 1}",
                                                guide: exercises[0].guide ?? "",
                                                sets: exercises[0].sets ?? 0,
                                                reps: exercises[0].reps ?? 0,
                                                rest: exercises[0].rest ?? 0,
                                                weight: exercises[0].weight ?? 0,
                                                // weight: "",
                                                duration: exercises[0].duration ?? "",
                                                formats: exercises[0].formats ?? [],
                                                extra: exercises[0].extra ?? []);

                                            debugPrint(selectExerciseSwapIndex.toString());

                                            debugPrint(userData?.allFilterExercises[selectExerciseSwapIndex!].id);

                                            dataProvider?.addExerciseById(userData!.currentWeek, userData!.currentDay, newDayExercise);
                                          } else {
                                            DayExercise newDayExercise = DayExercise(
                                                id: userData?.allFilterExercises[selectExerciseSwapIndex!].id ?? "",
                                                id_: "",
                                                typeId: userData!.currentDay,
                                                name: userData?.allFilterExercises[selectExerciseSwapIndex!].title ??
                                                    "Exercise ${exercises.length + 1}",
                                                guide: "",
                                                sets: 5,
                                                reps: 10,
                                                rest: 3,
                                                weight: 30,
                                                // weight: "",
                                                duration: "15",
                                                formats: ["A", "B", "C"],
                                                extra: []

                                                ///
                                                );

                                            debugPrint(userData?.allFilterExercises[selectExerciseSwapIndex!].id);

                                            dataProvider?.addExerciseById(userData!.currentWeek, userData!.currentDay, newDayExercise);
                                          }
                                        }
                                        setCurrentDayObj();
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                  shadowColor: Colors.grey,
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(12), vertical: 12),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                child: const Text('Confirm'),
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
          },
        );
      },
    );
  }

  void removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  @override
  void didChangeDependencies() {
    var contact = ModalRoute.of(context)?.settings.arguments;

    if (contact != null) {
      contact as Map;
      isPumpDay = contact['isPumpDay'] as bool;
      setState(() {});
    }
    fetchWarmupData();
    log('isPumpDay :::::::::::::::::: ${isPumpDay}');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final mainPageProvider = context.watch<MainPageProvider>();
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: media.height / 2,
                          width: media.width,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/back.jpg'),
                              fit: BoxFit.cover,
                              opacity: 1,
                            ),
                          ),
                        ),
                        Container(
                          height: media.height / 3,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Container(
                                  width: ScreenUtil.horizontalScale(100),
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: ScreenUtil.horizontalScale(10), // Size of the circle
                                            height: ScreenUtil.horizontalScale(10),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Color(0XFFd18a9b),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: Icon(
                                                  Icons.keyboard_arrow_left,
                                                  color: Colors.white,
                                                  size: ScreenUtil.verticalScale(4), // Adjust size if necessary
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        'Day ${userData?.currentDay}, Option ${userData!.selectedExerciseFormatAlternate}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil.horizontalScale(5.8),
                                        ),
                                      ),
                                      const CommonStreakWithNotification(),
                                    ],
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(3)),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(10),
                                  ),
                                  child: ButtonWidget(
                                    text: "Watch Video Intro",
                                    color: const Color(0xEEFFFFFF),
                                    onPress: () {
                                      Navigator.of(context).push(
                                        FadePageRoute(
                                          page: const VideoIntroWidget(vimeoId: '953289606'),
                                        ),
                                      );
                                    },
                                    textColor: AppColors.primaryColor,
                                    isLoading: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
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
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: media.height / 4),
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.horizontalScale(16)),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(8)),
                      child: Column(
                        children: [
                          // const IconRowWithDot(),
                          // SizedBox(
                          //   height: ScreenUtil.horizontalScale(2),
                          // ),
                          Consumer<UserDataProvider>(
                            builder: (context, value, child) => Container(
                              width: media.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(4),
                                vertical: ScreenUtil.verticalScale(2),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.verticalScale(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Warm-Up',
                                          style: TextStyle(
                                            fontSize: ScreenUtil.horizontalScale(6),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: media.width / 3.7,
                                              width: media.width / 3.7,
                                              decoration: BoxDecoration(
                                                // image: collection.photo.isNotEmpty
                                                //                                                 ? NetworkImage(
                                                //                                               collection.photo.startsWith('https://storage.cloud.google.com/')
                                                //                                                   ? collection.photo.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                                //                                                   : collection.photo,
                                                //                                             )
                                                //                                                 :  AssetImage('assets/img/warm-up-placeholder.png'),
                                                //                                             fit: BoxFit.cover,
                                                //                                           ),

                                                image: DecorationImage(
                                                    image: value.currentWarmup.thumbnail != ''
                                                        ? NetworkImage(
                                                            value.currentWarmup.thumbnail.startsWith('https://storage.cloud.google.com/')
                                                                ? value.currentWarmup.thumbnail.replaceFirst(
                                                                    'https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                                                : value.currentWarmup.thumbnail,
                                                          )
                                                        : AssetImage('assets/img/warm-up-placeholder.png')),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    ScreenUtil.verticalScale(1),
                                                  ),
                                                ),
                                              ),
                                              child: Consumer<UserDataProvider>(
                                                builder: (context, userData, child) => Container(
                                                  decoration: userData.exerciseHistory.any((history) =>
                                                          int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                          int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                          history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                          history['daySplit'].toString() == userData.selectedDaySplit &&
                                                          history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                          history['exerciseIndex'].toString() == "warmup" &&
                                                          history['state'].toString() == AppConstants.STATE_FINISHED)
                                                      ? BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              const Color(0xFFAADDAA).withOpacity(0.8),
                                                              const Color(0xFFAADDAA).withOpacity(0.8),
                                                            ],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                          ),
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(
                                                              ScreenUtil.verticalScale(1),
                                                            ),
                                                          ),
                                                        )
                                                      : !isThisWeek || isSkipped || isCompleted
                                                          ? BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  AppColors.secondColor.withOpacity(0.8),
                                                                  AppColors.secondColor.withOpacity(0.8),
                                                                ],
                                                                begin: Alignment.topCenter,
                                                                end: Alignment.bottomCenter,
                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                  ScreenUtil.verticalScale(1),
                                                                ),
                                                              ),
                                                            )
                                                          : BoxDecoration(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                  ScreenUtil.verticalScale(1),
                                                                ),
                                                              ),
                                                            ),
                                                  child: Icon(
                                                    userData.exerciseHistory.any((history) =>
                                                            int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                            int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                            history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                            history['daySplit'].toString() == userData.selectedDaySplit &&
                                                            history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                            history['exerciseIndex'].toString() == "warmup" &&
                                                            history['state'].toString() == AppConstants.STATE_FINISHED)
                                                        ? Icons.check
                                                        : Icons.close,
                                                    color: !isThisWeek ||
                                                            isSkipped ||
                                                            isCompleted ||
                                                            userData.exerciseHistory.any((history) =>
                                                                int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                                int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                                history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                                history['daySplit'].toString() == userData.selectedDaySplit &&
                                                                history['gymAccess'].toString() ==
                                                                    userData.selectedExerciseFormatAlternate &&
                                                                history['exerciseIndex'].toString() == "warmup" &&
                                                                history['state'].toString() == AppConstants.STATE_FINISHED)
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: media.width * 0.1,
                                            ),
                                            SizedBox(
                                              height: media.width / 3.7,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    height: ScreenUtil.horizontalScale(6.5),
                                                    width: ScreenUtil.horizontalScale(6.5),
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage('assets/img/deadline.png'),
                                                        fit: BoxFit.cover,
                                                        opacity: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    //  padding: EdgeInsets.symmetric(
                                                    //    horizontal: ScreenUtil
                                                    //        .horizontalScale(1),
                                                    //  ),
                                                    height: ScreenUtil.horizontalScale(6.2),
                                                    width: ScreenUtil.horizontalScale(6.2),
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage('assets/img/play.png'),
                                                        fit: BoxFit.cover,
                                                        opacity: 0.3,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: ScreenUtil.horizontalScale(6),
                                                    width: ScreenUtil.horizontalScale(6),
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage('assets/img/question.png'),
                                                        fit: BoxFit.cover,
                                                        opacity: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              height: media.width / 3.7,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${value.currentWarmup.length} Min',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: ScreenUtil.horizontalScale(4.5),
                                                    ),
                                                  ),
                                                  Text(
                                                    totalWarmups == 1 ? "1 Video" : '$totalWarmups Videos',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: ScreenUtil.horizontalScale(4.5),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Optional',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: ScreenUtil.horizontalScale(4.5),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(6),
                                      vertical: ScreenUtil.verticalScale(3),
                                    ),
                                    child: Consumer<UserDataProvider>(
                                      builder: (context, userData, child) => ButtonWidget(
                                        text: userData.exerciseHistory.any((history) =>
                                                    int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                    int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                    history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                    history['daySplit'].toString() == userData.selectedDaySplit &&
                                                    history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                    history['exerciseIndex'].toString() == "warmup") ||
                                                isCompleted
                                            ? "Completed"
                                            : ((isSkipped || !isThisWeek)
                                                ? (!isNextWeek && !isSkipped)
                                                    ? "Pending"
                                                    : "Skipped"
                                                : "Start the warm-up"),
                                        textColor: Colors.white,
                                        onPress: (!userData.exerciseHistory.any((history) =>
                                                    int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                    int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                    history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                    history['daySplit'].toString() == userData.selectedDaySplit &&
                                                    history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                    history['exerciseIndex'].toString() == "warmup") &&
                                                isThisWeek &&
                                                !isCompleted &&
                                                !isSkipped)
                                            ? () async {
                                                await userData.fetchCurrentEx(exercises[0].id, "today page 1360");

                                                Navigator.pushNamed(context, '/exercise', arguments: [
                                                  ('Warm-Up'),
                                                  '0',
                                                  '0',
                                                  "${value.currentWarmup.files[0]['link']}",
                                                  // '${userData.currentDayObj.warmups[0].file[0]}'
                                                ]);
                                              }
                                            : null,
                                        color: AppColors.primaryColor,
                                        isLoading: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: media.width,
                            margin: EdgeInsets.only(left: ScreenUtil.verticalScale(3)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's workout",
                                  style: TextStyle(
                                    fontSize: ScreenUtil.horizontalScale(5.5),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: media.height * 0.025,
                                ),
                                isPumpDay ? CircuitsView(circuit: dataProvider!.pumpDayModel!.circuits!) : const SizedBox(),
                                Consumer2<UserDataProvider, DataProvider>(
                                  builder: (context, userData, dataProvider, child) {
                                    if (userData.userName != "") {
                                      return Column(
                                        children: List.generate(
                                          exercises.length,
                                          (i) {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(right: ScreenUtil.verticalScale(3)),
                                                  child: WorkoutCard(
                                                    isCircuit: false,
                                                    isCompleted: (userData.exerciseHistory.any((history) =>
                                                        int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                        int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                        history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                        history['daySplit'].toString() == userData.selectedDaySplit &&
                                                        history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                        history['exerciseIndex'].toString() == (i + 1).toString() &&
                                                        history['state'].toString() == AppConstants.STATE_FINISHED)),
                                                    isSkipped: (!isThisWeek ||
                                                        isSkipped ||
                                                        isCompleted ||
                                                        userData.exerciseHistory.any((history) =>
                                                            int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                            int.parse((history['weekIndex']).toString()) == userData.currentWeek &&
                                                            history['dayIndex'].toString() == userData.currentDay.toString() &&
                                                            history['daySplit'].toString() == userData.selectedDaySplit &&
                                                            history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate &&
                                                            history['exerciseIndex'].toString() == (i + 1).toString() &&
                                                            history['state'].toString() == AppConstants.STATE_SKIPPED)),
                                                    exerciseIndex: i,
                                                    onComplete: () => setExerciseToCompleted(i),
                                                    onEdit: () => setExerciseEdit(i),
                                                    openSwapModal: () async {
                                                      debugPrint(exercises[i].id);
                                                      userData.notifyListeners();
                                                      await userData.fetchCurrentEx(exercises[i].id, "today page 1464");

                                                      await userData.fetchAllExercise();

                                                      showRelatedExerciseDialog(i, exercises[i], false);
                                                    },
                                                    exercise: exercises[i],
                                                    exerciseData: exercises[i].id,
                                                    name: exercises[i].name.isEmpty ? "Exercise ${i + 1}" : exercises[i].name,
                                                    onRemove: () => removeExercise(i),
                                                    // enabled: isThisWeek &&
                                                    //     !isCompleted &&
                                                    //     (!userData.exerciseHistory.any((history) =>
                                                    //         int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                                    //         int.parse((history['weekIndex']).toString()) ==
                                                    //             userData
                                                    //                 .currentWeek &&
                                                    //         history['dayIndex']
                                                    //                 .toString() ==
                                                    //             userData.currentDay
                                                    //                 .toString() &&
                                                    //         history['daySplit']
                                                    //                 .toString() ==
                                                    //             userData
                                                    //                 .selectedDaySplit &&
                                                    //         history['gymAccess']
                                                    //                 .toString() ==
                                                    //             userData
                                                    //                 .selectedExerciseFormatAlternate &&
                                                    //         history['exerciseIndex']
                                                    //                 .toString() ==
                                                    //             (i + 1)
                                                    //                 .toString() &&
                                                    //         history['state']
                                                    //                 .toString() ==
                                                    //             AppConstants
                                                    //                 .STATE_FINISHED)),

                                                    enabled: isThisWeek &&
                                                        !isCompleted &&
                                                        !isSkipped &&
                                                        !userData.exerciseHistory.any((history) {
                                                          final isCurrentMonth =
                                                              int.parse(history['monthIndex'].toString()) == userData.currentMonth;
                                                          final isCurrentWeek =
                                                              int.parse(history['weekIndex'].toString()) == userData.currentWeek;
                                                          final isCurrentDay =
                                                              history['dayIndex'].toString() == userData.currentDay.toString();
                                                          final isCurrentDaySplit =
                                                              history['daySplit'].toString() == userData.selectedDaySplit;
                                                          final isCurrentGymAccess =
                                                              history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate;
                                                          final isCurrentExercise =
                                                              history['exerciseIndex'].toString() == (i + 1).toString();
                                                          final isFinishedOrSkipped =
                                                              history['state'].toString() == AppConstants.STATE_FINISHED ||
                                                                  history['state'].toString() == AppConstants.STATE_SKIPPED;

                                                          return isCurrentMonth &&
                                                              isCurrentWeek &&
                                                              isCurrentDay &&
                                                              isCurrentDaySplit &&
                                                              isCurrentGymAccess &&
                                                              isCurrentExercise &&
                                                              isFinishedOrSkipped;
                                                        }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: ScreenUtil.verticalScale(3),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );

                                      ///===New approach
                                      // return Column(
                                      //   children:
                                      //     List.generate(
                                      //     exercises.length, // Loop through all exercises
                                      //     (exerciseI) => Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //   ...List.generate(
                                      //     exercises[exerciseI].extra.length,(i)
                                      //
                                      //   => Column(
                                      //     children: [
                                      //       (exercises[exerciseI].extra[i]['type']==3 || exercises[exerciseI].extra[i]['type']=="3")?
                                      //       WorkOutInExtraSection(
                                      //         isCompleted: //false,////!isThisWeek?true:false,
                                      //         (userData.exerciseHistory.any((history) =>
                                      //         int.parse((history['monthIndex']).toString()) ==
                                      //             userData.currentMonth &&
                                      //             int.parse(
                                      //                 (history['weekIndex'])
                                      //                     .toString()) ==
                                      //                 userData.currentWeek &&
                                      //             history['dayIndex'].toString() ==
                                      //                 userData.currentDay
                                      //                     .toString() &&
                                      //             history['daySplit'].toString() ==
                                      //                 userData
                                      //                     .selectedDaySplit &&
                                      //             history['gymAccess'].toString() ==
                                      //                 userData
                                      //                     .selectedExerciseFormatAlternate &&
                                      //             history['exerciseIndex']
                                      //                 .toString() ==
                                      //                 (i + 1).toString() &&
                                      //             history['state'].toString() ==
                                      //                 AppConstants
                                      //                     .STATE_FINISHED)),
                                      //         isSkipped: //true,//!isThisWeek?true:false,
                                      //         (!isThisWeek ||
                                      //             isSkipped ||
                                      //             isCompleted ||
                                      //             userData.exerciseHistory.any((history) =>
                                      //             int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                      //                 int.parse((history['weekIndex']).toString()) ==
                                      //                     userData
                                      //                         .currentWeek &&
                                      //                 history['dayIndex']
                                      //                     .toString() ==
                                      //                     userData.currentDay
                                      //                         .toString() &&
                                      //                 history['daySplit']
                                      //                     .toString() ==
                                      //                     userData
                                      //                         .selectedDaySplit &&
                                      //                 history['gymAccess']
                                      //                     .toString() ==
                                      //                     userData
                                      //                         .selectedExerciseFormatAlternate &&
                                      //                 history['exerciseIndex']
                                      //                     .toString() ==
                                      //                     (i + 1)
                                      //                         .toString() &&
                                      //                 history['state']
                                      //                     .toString() ==
                                      //                     AppConstants
                                      //                         .STATE_SKIPPED)),
                                      //         exerciseIndex: i,
                                      //         onComplete: () =>
                                      //             setExerciseExtraToCompleted(i,exerciseI),
                                      //         openSwapModal: () async {
                                      //           debugPrint(exercises[exerciseI].extra[i]['id']);
                                      //           userData.notifyListeners();
                                      //           await userData.fetchCurrentEx(
                                      //               exercises[exerciseI].extra[i]['id']);
                                      //           showRelatedExerciseDialog(
                                      //               i, exercises[exerciseI].extra[i], false);
                                      //         },
                                      //         extra: exercises[exerciseI].extra[i],
                                      //         exerciseData: "",//exercises[0].extra[i],
                                      //         name: exercises[exerciseI].name==null?
                                      //         "Exercise ${i + 1}":
                                      //         exercises[exerciseI].name.isEmpty
                                      //             ? "Exercise ${i + 1}"
                                      //             : exercises[exerciseI].name,
                                      //         onRemove: () =>
                                      //             removeExercise(i),
                                      //         // enabled: //false,//isThisWeek?true:false,
                                      //         // isThisWeek &&
                                      //         // !isCompleted &&
                                      //         // (!userData.exerciseHistory.any((history) =>
                                      //         // int.parse((history['monthIndex']).toString()) == userData.currentMonth &&
                                      //         //     int.parse((history['weekIndex']).toString()) ==
                                      //         //         userData
                                      //         //             .currentWeek &&
                                      //         //     history['dayIndex']
                                      //         //         .toString() ==
                                      //         //         userData.currentDay
                                      //         //             .toString() &&
                                      //         //     history['daySplit']
                                      //         //         .toString() ==
                                      //         //         userData
                                      //         //             .selectedDaySplit &&
                                      //         //     history['gymAccess']
                                      //         //         .toString() ==
                                      //         //         userData
                                      //         //             .selectedExerciseFormatAlternate &&
                                      //         //     history['exerciseIndex']
                                      //         //         .toString() ==
                                      //         //         (i + 1)
                                      //         //             .toString() &&
                                      //         //     history['state']
                                      //         //         .toString() ==
                                      //         //         AppConstants
                                      //         //             .STATE_FINISHED)),
                                      //         enabled: isThisWeek &&
                                      //             !isCompleted &&
                                      //             !userData.exerciseHistory.any((history) {
                                      //               final isCurrentMonth = int.parse(history['monthIndex'].toString()) == userData.currentMonth;
                                      //               final isCurrentWeek = int.parse(history['weekIndex'].toString()) == userData.currentWeek;
                                      //               final isCurrentDay = history['dayIndex'].toString() == userData.currentDay.toString();
                                      //               final isCurrentDaySplit = history['daySplit'].toString() == userData.selectedDaySplit;
                                      //               final isCurrentGymAccess = history['gymAccess'].toString() == userData.selectedExerciseFormatAlternate;
                                      //               final isCurrentExercise = history['exerciseIndex'].toString() == (i + 1).toString();
                                      //               final isFinishedOrSkipped = history['state'].toString() == AppConstants.STATE_FINISHED ||
                                      //                   history['state'].toString() == AppConstants.STATE_SKIPPED;
                                      //
                                      //               return isCurrentMonth &&
                                      //                   isCurrentWeek &&
                                      //                   isCurrentDay &&
                                      //                   isCurrentDaySplit &&
                                      //                   isCurrentGymAccess &&
                                      //                   isCurrentExercise &&
                                      //                   isFinishedOrSkipped;
                                      //             }),
                                      //
                                      //       ):SizedBox(),
                                      //       (exercises[exerciseI].extra[i]['type']==3 || exercises[exerciseI].extra[i]['type']=="3")?
                                      //       SizedBox(
                                      //         height:
                                      //         ScreenUtil.verticalScale(3),
                                      //       ):SizedBox(),
                                      //     ],
                                      //   ),
                                      //   ),]))
                                      // );
                                    } else {
                                      // Return something else if userName is empty
                                      return Container();
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenUtil.verticalScale(2)),
                          // isToday
                          // ? GestureDetector(
                          GestureDetector(
                            onTap: () async {
                              await userData?.fetchAllExercise();
                              showRelatedExerciseDialog(0, 0, true);
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                ScreenUtil.verticalScale(2),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF9B3651),
                                    const Color(0xFFDB4671).withOpacity(0.79),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: ScreenUtil.verticalScale(3.5),
                              ),
                            ),
                          ),
                          // : const SizedBox(),
                          // isToday
                          const SizedBox(height: 36),
                          // : const SizedBox(),
                          Container(
                            height: 1,
                            margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                            width: media.width * 0.75,
                            color: Colors.black12,
                          ),
                          const SizedBox(height: 36),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                            child: ButtonWidget(
                              text: isCompleted
                                  ? "Completed"
                                  : ((isSkipped || !isThisWeek)
                                      ? (!isNextWeek && !isSkipped)
                                          ? "Pending"
                                          : "Skipped"
                                      : "Finish the workout"),
                              textColor: Colors.white,
                              onPress: isThisWeek && !isCompleted && !isSkipped
                                  ? () {
                                      weeklyGraphProvider.stopTimer();
                                      userData?.finishCurrentDay();
                                      Navigator.pushNamed(
                                        context,
                                        '/dayCompleted',
                                        arguments: userData?.currentDay,
                                      );
                                    }
                                  : null,
                              color: AppColors.primaryColor,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(height: 14),

                          isThisWeek && !isCompleted && !isSkipped
                              ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(5)),
                                  child: ButtonWidget(
                                    text: "Skip the workout",
                                    textColor: Colors.white,
                                    onPress: () {
                                      userData?.updateOrAddDayHistory(AppConstants.STATE_SKIPPED);
                                      Navigator.pushNamed(context, '/home');
                                    },
                                    color: AppColors.skipDayColor,
                                    isLoading: false,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(
      {super.key,
      required this.isCompleted,
      required this.isSkipped,
      required this.exerciseIndex,
      this.onComplete,
      this.onEdit,
      required this.openSwapModal,
      required this.name,
      required this.exercise,
      required this.onRemove,
      required this.enabled,
      required this.exerciseData,
      required this.isCircuit});

  final bool isSkipped;
  final bool isCompleted;
  final int exerciseIndex;
  final onComplete;
  final onEdit;
  final openSwapModal;
  final String name;
  final DayExercise exercise;
  final VoidCallback onRemove;
  final bool enabled;
  final bool isCircuit;
  final String exerciseData;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  final today = DateTime.now();
  UserDataProvider? userData;
  DataProvider? dataProvider;
  String g_imageUrl = "";

  @override
  void initState() {
    super.initState();

    getTotalSets();
    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );
    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );
    _fetchExerciseData();
    // _fetchAndLoadImage();
  }

  num totalSets = 0;

  void getTotalSets() {
    if (widget.exercise.extra.isNotEmpty) {
      for (var element in widget.exercise.extra) {
        totalSets += int.parse(element['sets'].toString());
      }
    }
  }

  Future<void> _fetchExerciseData() async {
    await userData?.fetchCurrentEx(widget.exerciseData, "today page 1847");
    customPrintB("======================================");
    customPrintB(userData?.currentExerciseObj!.thumbnail);
    g_imageUrl = g_imageUrl = userData?.currentExerciseObj!.thumbnail ?? 'assets/img/placeholder.png';

    // for equipment userData?.currentExerciseObj?.usedEquipments[0].thumbnail
    customPrintR(g_imageUrl);
    customPrintB("======================================");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    // return FutureBuilder<ImageProvider>(
    // future: _fetchAndLoadImage(), // Use the combined future
    // builder: (context, snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return const Center(child: CircularProgressIndicator()); // Loading state
    //   } else if (snapshot.hasError || !snapshot.hasData) {
    //     return const Center(
    //       child: Text('Failed to load image'), // Error state
    //     );
    //   }

    return Slidable(
      endActionPane: widget.enabled
          ? ActionPane(
              extentRatio: 0.35,
              motion: const ScrollMotion(),
              children: [
                SizedBox(
                  width: ScreenUtil.horizontalScale(5),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(4),
                  width: ScreenUtil.verticalScale(4),
                  child: Row(
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          dataProvider?.removeExerciseById(userData!.currentWeek, userData!.currentDay, widget.exercise.id);
                          widget.onRemove();
                        },
                        icon: Icons.close,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: ScreenUtil.horizontalScale(5),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(4),
                  width: ScreenUtil.verticalScale(4),
                  child: Row(
                    children: [
                      SlidableAction(
                        onPressed: (context) => widget.openSwapModal(),
                        icon: Icons.swap_horiz,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          // color:  const Color(0xFFFDFDFD),//(0xFFFDFDFD),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(12)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Slightly darker shadow
              spreadRadius: 1, // Increase spread for a more noticeable shadow
              blurRadius: 15, // Increase blur for a softer shadow
              offset: const Offset(0, 5), // Position the shadow below the card
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.enabled ? widget.onComplete : widget.onEdit,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Color(0xFFF3F3F3),
            backgroundColor: Colors.white, //(0xFFF3F3F3), // Set to transparent
            elevation: 0, // Remove default elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
              side: const BorderSide(
                color: Color(0x12000000), // Border color
                width: 0.5, // Border width
              ),
            ),
            padding: EdgeInsets.zero, // Remove default padding
          ),
          child: Container(
            width: media.width,
            padding: EdgeInsets.only(right: ScreenUtil.verticalScale(2)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    appImage(
                      height: media.width / 4,
                      width: media.width / 4,
                      networkImageUrl: g_imageUrl ?? "",
                      errorImageUrl: 'assets/img/placeholder.png',
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                        bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                      ),
                      child: Container(
                        decoration: widget.isCompleted
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFAADDAA).withOpacity(0.8),
                                    const Color(0xFFAADDAA).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                ),
                              )
                            : widget.isSkipped
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondColor.withOpacity(0.8),
                                        AppColors.secondColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                    ),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                    ),
                                  ),
                        child: Icon(
                          widget.isCompleted ? Icons.check : Icons.close,
                          color: widget.isCompleted || widget.isSkipped ? Colors.white : Colors.transparent,
                          size: 30,
                        ),
                      ),
                    ),
                    // Container(
                    //   height: media.width / 4,
                    //   width: media.width / 4,
                    //   decoration: BoxDecoration(
                    //     image:  DecorationImage(
                    //       image: g_imageUrl != null
                    //           ? NetworkImage("https://storage.googleapis.com/bbb-app-d4b41.appspot.com/1732111461596_936.jpg") // Use NetworkImage to provide the image from URL
                    //           : AssetImage('assets/img/placeholder.png') as ImageProvider, // Use AssetImage as fallback
                    //       fit: BoxFit.contain,
                    //     ),
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                    //       bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                    //     ),
                    //   ),
                    //
                    //   child: Container(
                    //     decoration: widget.isCompleted
                    //         ? BoxDecoration(
                    //       gradient: LinearGradient(
                    //         colors: [
                    //           const Color(0xFFAADDAA).withOpacity(0.8),
                    //           const Color(0xFFAADDAA).withOpacity(0.8),
                    //         ],
                    //         begin: Alignment.topCenter,
                    //         end: Alignment.bottomCenter,
                    //       ),
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //         bottomLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //       ),
                    //     )
                    //         : widget.isSkipped
                    //         ? BoxDecoration(
                    //       gradient: LinearGradient(
                    //         colors: [
                    //           AppColors.secondColor.withOpacity(0.8),
                    //           AppColors.secondColor.withOpacity(0.8),
                    //         ],
                    //         begin: Alignment.topCenter,
                    //         end: Alignment.bottomCenter,
                    //       ),
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //         bottomLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //       ),
                    //     )
                    //         : BoxDecoration(
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //         bottomLeft: Radius.circular(
                    //             ScreenUtil.verticalScale(12)),
                    //       ),
                    //     ),
                    //     child: Icon(
                    //       widget.isCompleted ? Icons.check : Icons.close,
                    //       color: widget.isCompleted || widget.isSkipped
                    //           ? Colors.white
                    //           : Colors.transparent,
                    //       size: 30,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: media.width / 2.5,
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: widget.isCircuit ? ScreenUtil.horizontalScale(3) : ScreenUtil.horizontalScale(3.8),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon(
                            //   Icons.av_timer,
                            //   color: Colors.black26,
                            //   size: ScreenUtil.verticalScale(2),
                            // ),
                            // Text(
                            //   "",
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: ScreenUtil.verticalScale(1.5),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(0.5),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 2),
                              child: SvgPicture.asset(
                                "assets/icons/trend.svg",
                                color: Colors.grey,
                                width: 20,
                              ),
                            ),
                            Text(
                              "$totalSets sets",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: widget.isCircuit ? ScreenUtil.verticalScale(1.3) : ScreenUtil.verticalScale(1.5),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                if (widget.enabled) ...[
                  GestureDetector(
                    onTap: widget.enabled ? widget.onComplete : null,
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: ScreenUtil.verticalScale(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkOutInExtraSection extends StatefulWidget {
  const WorkOutInExtraSection(
      {super.key,
      required this.isCompleted,
      required this.isSkipped,
      required this.exerciseIndex,
      this.onComplete,
      required this.openSwapModal,
      required this.name,
      required this.extra,
      required this.onRemove,
      required this.enabled,
      required this.exerciseData});

  final bool isSkipped;
  final bool isCompleted;
  final int exerciseIndex;
  final onComplete;
  final openSwapModal;
  final String name;
  // final DayExercise exercise;
  final dynamic extra;
  final VoidCallback onRemove;
  final bool enabled;
  final String exerciseData;

  @override
  State<WorkOutInExtraSection> createState() => _WorkOutInExtraSectionState();
}

class _WorkOutInExtraSectionState extends State<WorkOutInExtraSection> {
  final today = DateTime.now();
  UserDataProvider? userData;
  DataProvider? dataProvider;
  String g_imageUrl = "";

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );

    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );
    _fetchExerciseData();
    // _fetchAndLoadImage();
  }

  Future<void> _fetchExerciseData() async {
    await userData?.fetchCurrentEx(widget.exerciseData, "today page 2253");

    g_imageUrl = g_imageUrl = userData?.currentExerciseObj.thumbnail ?? 'assets/img/img_1.png';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    // return FutureBuilder<ImageProvider>(
    // future: _fetchAndLoadImage(), // Use the combined future
    // builder: (context, snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return const Center(child: CircularProgressIndicator()); // Loading state
    //   } else if (snapshot.hasError || !snapshot.hasData) {
    //     return const Center(
    //       child: Text('Failed to load image'), // Error state
    //     );
    //   }
    return Slidable(
      endActionPane: widget.enabled
          ? ActionPane(
              extentRatio: 0.35,
              motion: const ScrollMotion(),
              children: [
                SizedBox(
                  width: ScreenUtil.horizontalScale(5),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(4),
                  width: ScreenUtil.verticalScale(4),
                  child: Row(
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          dataProvider?.removeExerciseById(userData!.currentWeek, userData!.currentDay, widget.extra['id']);
                          widget.onRemove();
                        },
                        icon: Icons.close,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: ScreenUtil.horizontalScale(5),
                ),
                SizedBox(
                  height: ScreenUtil.verticalScale(4),
                  width: ScreenUtil.verticalScale(4),
                  child: Row(
                    children: [
                      SlidableAction(
                        onPressed: (context) => widget.openSwapModal(),
                        icon: Icons.swap_horiz,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(0),
                        borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(3)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          // color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil.verticalScale(12)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Slightly darker shadow
              spreadRadius: 2, // Increase spread for a more noticeable shadow
              blurRadius: 15, // Increase blur for a softer shadow
              offset: const Offset(0, 5), // Position the shadow below the card
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.enabled ? widget.onComplete : null,
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.transparent, // Set to transparent
            backgroundColor: const Color(0xFFEDEDED),
            disabledBackgroundColor: const Color(0xFFEDEDED),
            elevation: 0, // Remove default elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
              side: const BorderSide(
                color: Color(0x12000000), // Border color
                width: 0.5, // Border width
              ),
            ),
            padding: EdgeInsets.zero, // Remove default padding
          ),
          child: Container(
            width: media.width,
            padding: EdgeInsets.only(right: ScreenUtil.verticalScale(2)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil.verticalScale(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      height: media.width / 4,
                      width: media.width / 4,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: g_imageUrl != null
                              ? NetworkImage(
                                  "https://storage.googleapis.com/bbb-app-d4b41.appspot.com/1732111461596_936.jpg") // Use NetworkImage to provide the image from URL
                              : AssetImage('assets/img/placeholder.png') as ImageProvider, // Use AssetImage as fallback
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                          bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                        ),
                      ),
                      child: Container(
                        decoration: widget.isCompleted
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFAADDAA).withOpacity(0.8),
                                    const Color(0xFFAADDAA).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                  bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                ),
                              )
                            : widget.isSkipped
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondColor.withOpacity(0.8),
                                        AppColors.secondColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                    ),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                      bottomLeft: Radius.circular(ScreenUtil.verticalScale(12)),
                                    ),
                                  ),
                        child: Icon(
                          widget.isCompleted ? Icons.check : Icons.close,
                          color: widget.isCompleted || widget.isSkipped ? Colors.white : Colors.transparent,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: media.width / 2.5,
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: ScreenUtil.horizontalScale(3.8),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon(
                            //   Icons.av_timer,
                            //   color: Colors.black26,
                            //   size: ScreenUtil.verticalScale(2),
                            // ),
                            // Text(
                            //   "",
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: ScreenUtil.verticalScale(1.5),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(0.5),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.black26,
                              size: ScreenUtil.verticalScale(2),
                            ),
                            Text(
                              "${widget.extra["sets"]} sets, ${widget.extra["reps"]} reps, "
                              // "${widget.exercise.rest} min "
                              "${formatSecondsToMinutes(widget.extra["rest"])}"
                              "rest",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil.verticalScale(1.5),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                if (widget.enabled) ...[
                  GestureDetector(
                    onTap: widget.enabled ? widget.onComplete : null,
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil.verticalScale(0.5)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: ScreenUtil.verticalScale(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchEquipmentField extends StatelessWidget {
  final ValueChanged<String> onChanged; // Add a callback for text change
  const SearchEquipmentField({super.key, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5), vertical: ScreenUtil.verticalScale(0.5)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.horizontalScale(3),
        vertical: ScreenUtil.horizontalScale(0.5),
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(6)),
          border: Border.all(color: AppColors.primaryColor, width: 1)),
      child: TextField(
        onChanged: onChanged, // Notify the parent of text changes
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search Exercise',
          hintStyle: TextStyle(
            color: Colors.black45,
            fontSize: ScreenUtil.verticalScale(2),
          ),
          suffixIcon: Icon(
            Icons.search,
            size: ScreenUtil.verticalScale(4),
            color: Colors.grey[300],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(2),
          ),
        ),
      ),
    );
  }
}
