import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SettingSection extends StatefulWidget {
  const SettingSection({super.key, required this.monthProvider});
  final MonthProvider monthProvider;
  @override
  State<SettingSection> createState() => _SettingSectionState();
}

class _SettingSectionState extends State<SettingSection> {
  int splitIndex = 0;
  int equipments = 0;
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    String split = widget.monthProvider.splitType ?? "split3";
    String equipment = widget.monthProvider.equipmentType;
    splitIndex = split == "split3"
        ? 0
        : split == "split4"
            ? 1
            : 2;
    equipments = equipment == "A"
        ? 0
        : equipment == "B"
            ? 1
            : 2;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await fetchTutorialData());
    super.initState();
  }

  updateSplitIndex(int index) {
    splitIndex = index;
    setState(() {});
  }

  updateEquipments(int index) {
    equipments = index;
    setState(() {});
  }

  // bool loading1 = false;
  // bool videoNotInitialized1 = false;
  // late VideoPlayerController _videoPlayerController1;
  // ChewieController? _chewieController1;
  // late Size videoSize1;
  //
  // Future<void> fetchTutorialData() async {
  //   setState(() {
  //     loading1 = true;
  //   });
  //   await dataProvider?.fetchTutorialData().then(
  //     (value) async {
  //       if (dataProvider!.tutorialData.files.isNotEmpty) {
  //         await initializeVideo1(dataProvider?.tutorialData.files[0]['link']);
  //         await initializeVideo2(dataProvider?.tutorialData.files[0]['link']);
  //       } else {
  //         loading1 = false;
  //         videoNotInitialized1 = true;
  //         loading2 = false;
  //         videoNotInitialized2 = true;
  //         setState(() {});
  //       }
  //     },
  //   );
  // }
  //
  // Future<void> initializeVideo1(String url) async {
  //   try {
  //     _videoPlayerController1 =
  //         VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
  //     await _videoPlayerController1.initialize();
  //     _chewieController1 = ChewieController(
  //       videoPlayerController: _videoPlayerController1,
  //       autoPlay: false,
  //       looping: false,
  //       showControls: false,
  //       aspectRatio: _videoPlayerController1.value.aspectRatio,
  //     );
  //
  //     if (_chewieController1 != null && _chewieController1!.videoPlayerController.value.isInitialized) {
  //       videoSize1 = calculateVideoSize1(aspectRatio: _chewieController1!.aspectRatio!, context: context);
  //       setState(() {});
  //     }
  //
  //     setState(() => loading1 = false);
  //   } catch (e) {
  //     setState(() {
  //       videoNotInitialized1 = true;
  //       loading1 = false;
  //     });
  //     debugPrint("VIDEO NOT INITIALIZED: $e");
  //   }
  // }
  //
  // Size calculateVideoSize1({required BuildContext context, required double aspectRatio}) {
  //   double maxWidth = ScreenUtil.horizontalScale(90);
  //   double calculatedHeight = maxWidth / aspectRatio;
  //   return Size(maxWidth, calculatedHeight);
  // }
  //
  // bool loading2 = false;
  // bool videoNotInitialized2 = false;
  // late VideoPlayerController _videoPlayerController2;
  // ChewieController? _chewieController2;
  // late Size videoSize2;
  //
  // Future<void> initializeVideo2(String url) async {
  //   try {
  //     _videoPlayerController2 =
  //         VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
  //     await _videoPlayerController2.initialize();
  //     _chewieController2 = ChewieController(
  //       videoPlayerController: _videoPlayerController2,
  //       autoPlay: false,
  //       looping: false,
  //       showControls: false,
  //       aspectRatio: _videoPlayerController2.value.aspectRatio,
  //     );
  //
  //     if (_chewieController2 != null && _chewieController2!.videoPlayerController.value.isInitialized) {
  //       videoSize1 = calculateVideoSize2(aspectRatio: _chewieController2!.aspectRatio!, context: context);
  //       setState(() {});
  //     }
  //
  //     setState(() => loading1 = false);
  //   } catch (e) {
  //     setState(() {
  //       videoNotInitialized2 = true;
  //       loading1 = false;
  //     });
  //     debugPrint("VIDEO NOT INITIALIZED: $e");
  //   }
  // }
  //
  // Size calculateVideoSize2({required BuildContext context, required double aspectRatio}) {
  //   double maxWidth = ScreenUtil.horizontalScale(90);
  //   double calculatedHeight = maxWidth / aspectRatio;
  //   return Size(maxWidth, calculatedHeight);
  // }
  // Future<dynamic> chooseWorkoutDay(BuildContext context) => showDialog(
  //       barrierDismissible: true,
  //       context: context,
  //       builder: (context) {
  //         return Dialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           insetPadding: EdgeInsets.symmetric(horizontal: 25),
  //           child: ChooseWorkoutDayDialog(
  //             loading: loading1,
  //             dataProvider: dataProvider!,
  //             chewieController: _chewieController1!,
  //             videoNotInitialized: videoNotInitialized1,
  //             videoPlayerController: _videoPlayerController1,
  //             videoSize: videoSize1,
  //           ),
  //         );
  //       },
  //     ).then(
  //       (value) {
  //         if (_chewieController1 != null) {
  //           _chewieController1!.dispose();
  //         }
  //         _videoPlayerController1.dispose();
  //         AudioManager.abandonAudioFocus();
  //       },
  //     );
  //
  // Future<dynamic> chooseEquipment(BuildContext context) => showDialog(
  //       barrierDismissible: true,
  //       context: context,
  //       builder: (context) {
  //         return Dialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           insetPadding: EdgeInsets.symmetric(horizontal: 25),
  //           child: ChooseEquipmentDialog(
  //             loading: loading2,
  //             dataProvider: dataProvider!,
  //             chewieController: _chewieController2!,
  //             videoNotInitialized: videoNotInitialized2,
  //             videoPlayerController: _videoPlayerController2,
  //             videoSize: videoSize2,
  //           ),
  //         );
  //       },
  //     ).then(
  //       (value) {
  //         if (_chewieController2 != null) {
  //           _chewieController2!.dispose();
  //         }
  //         _videoPlayerController2.dispose();
  //         AudioManager.abandonAudioFocus();
  //       },
  //     );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil.horizontalScale(3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choose workout day split',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: const Color(0xBB888888),
                    fontSize: ScreenUtil.verticalScale(1.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // chooseWorkoutDay(context);
                  },
                  child: Center(
                    child: Icon(
                      Icons.info,
                      size: ScreenUtil.verticalScale(2.3),
                      color: const Color(0xBB888888),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Consumer<MonthProvider>(
            builder: (context, value, child) {
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "3",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "3 Days per Week",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateSplitIndex(0),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: splitIndex == 0 ? AppColors.primaryColor : Colors.transparent,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "4",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "4 Days per Week",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateSplitIndex(1),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              color: splitIndex == 1 ? AppColors.primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "5",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "5 Days per Week",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateSplitIndex(2),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              color: splitIndex == 2 ? AppColors.primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Consumer<MonthProvider>(
          //   builder: (context, value, child) => SelectDropdown1(
          //     onChange: (String newValue) async {
          //       await value.changeDaySplit(newValue);
          //       await value.filterWorkouts();
          //       await value.updateLocalData();
          //       await value.checkForPumpDay();
          //       await value.manageStreak();
          //       await value.getLiftedWeightGraphData();
          //     },
          //   ),
          // ),
          const SizedBox(height: 25),
          Container(
            margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(3)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choose equipment availability',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: const Color(0xBB888888),
                    fontSize: ScreenUtil.verticalScale(1.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // chooseEquipment(context);
                  },
                  child: Center(
                    child: Icon(
                      Icons.info,
                      size: ScreenUtil.verticalScale(2.3),
                      color: const Color(0xBB888888),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          Consumer<MonthProvider>(
            builder: (context, value, child) {
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "A",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Fully equipped gym",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateEquipments(0),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              color: equipments == 0 ? AppColors.primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "B",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Home gym",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateEquipments(1),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              color: equipments == 1 ? AppColors.primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.25)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: ScreenUtil.verticalScale(2),
                          child: Text(
                            "C",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil.verticalScale(2.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Dumbbells and bands",
                          style: TextStyle(
                            color: const Color(0xBB888888),
                            fontSize: ScreenUtil.verticalScale(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => updateEquipments(2),
                          child: Container(
                            height: ScreenUtil.verticalScale(4),
                            width: ScreenUtil.verticalScale(4),
                            decoration: BoxDecoration(
                              color: equipments == 2 ? AppColors.primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.done,
                                size: ScreenUtil.verticalScale(2.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Consumer<MonthProvider>(
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: ButtonWidget(
                  text: "Save",
                  textColor: Colors.white,
                  color: AppColors.primaryColor,
                  onPress: () async {
                    value.updateSettingLoader(true);

                    String newValue1 = splitIndex == 0
                        ? "3"
                        : splitIndex == 1
                            ? "4"
                            : "5";

                    String newValue2 = equipments == 0
                        ? "A"
                        : equipments == 1
                            ? "B"
                            : "C";

                    await value.changeDaySplit(newValue1);
                    value.changeEquipmentType(newValue2);
                    await value.filterWorkouts();

                    await value.updateLocalData();

                    await Future.delayed(Duration(seconds: 1)).then(
                      (v) {
                        value.updateSettingLoader(false);
                      },
                    );

                    Fluttertoast.showToast(
                      msg: "Saved successfully!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP_RIGHT,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    await value.checkForPumpDay();
                    await value.manageStreak();
                    await value.getLiftedWeightGraphData();
                  },
                  isLoading: value.settingLoader,
                ),
              );
            },
          ),

          // Consumer<MonthProvider>(
          //   builder: (context, value, child) => SelectDropdown(
          //     onChange: (String newValue) async {
          //       value.changeEquipmentType(newValue);
          //       await value.filterWorkouts();
          //       await value.updateLocalData();
          //     },
          //   ),
          // ),

          SizedBox(height: ScreenUtil.verticalScale(10))
        ],
      ),
    );
  }
}
