import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/custom/expansion_panel.dart' as com;
import 'package:bbb/middleware/notification_service.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/choose_equipment_popup.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/choose_workoutday_popup.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localstorage/month_prefrence.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool? isSwitchOn = true;
  bool? isHapticFeedbackOn = true;
  bool isMute = true;
  late MainPageProvider mainPageProvider;
  late MonthProvider monthProvider;
  DataProvider? dataProvider;
  final ScrollController _scrollController = ScrollController();
  bool isSplit = false;
  bool isEquipment = false;
  bool isScreenAwake = false;
  int curExpandedIdx = 0;

  @override
  void initState() {
    onInit();
    super.initState();
  }

  bool loader = false;
  onInit() async {
    loader = true;
    setState(() {});
    getSwitch();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    String split = monthProvider.splitType ?? "split3";
    String equipment = monthProvider.equipmentType;
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
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await dataProvider?.fetchTutorialData());

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await Future.delayed(Duration(milliseconds: 1));
        loader = false;
        setState(() {});
      },
    );
  }

  int splitIndex = 0;

  updateSplitIndex(int index) async {
    splitIndex = index;
    setState(() {});

    String newValue1 = splitIndex == 0
        ? "3"
        : splitIndex == 1
            ? "4"
            : "5";

    await monthProvider.changeDaySplit(newValue1);
    await monthProvider.filterWorkouts();
    await monthProvider.updateLocalData();
    await monthProvider.checkForPumpDay();
    await monthProvider.manageStreak();
    await monthProvider.getLiftedWeightGraphData();
  }

  int equipments = 0;

  updateEquipments(int index) async {
    equipments = index;
    setState(() {});

    String newValue2 = equipments == 0
        ? "A"
        : equipments == 1
            ? "B"
            : "C";
    monthProvider.changeEquipmentType(newValue2);
  }

  Future<void> getSwitch() async {
    final raw1 = await preferences.getBool(SharedPreference.notificationSwitch);
    final raw2 = await preferences.getBool(SharedPreference.isHapticFeedbackOn);
    final raw3 = await preferences.getBool(SharedPreference.isScreenAwake);
    bool rawData = await preferences.getBool(SharedPreference.isMute) ?? true;
    if (raw1 != null) {
      isSwitchOn = raw1;
    } else {
      await preferences.setBool(
          SharedPreference.notificationSwitch, isSwitchOn ?? false);
    }

    if (raw3 != null) {
      isScreenAwake = raw3;
    } else {
      await preferences.setBool(SharedPreference.isScreenAwake, isScreenAwake);
    }

    if (raw2 != null) {
      isHapticFeedbackOn = raw2;
    } else {
      await preferences.setBool(
          SharedPreference.isHapticFeedbackOn, isHapticFeedbackOn ?? false);
    }
    isMute = rawData;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    AppImage.imageSetting(
                        // media,
                        // image: dataProvider!.allImageList
                        //     .where(
                        //         (element) => element["key"] == "imageSetting")
                        //     .first["image"],
                        // // image: dataProvider!.cachedImageMap["imageSetting"],
                        // imageKey: "imageSetting",
                        ),
                    SizedBox(
                      height: media.height / 1.5,
                      width: media.width,
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBar(
                              toolbarHeight: ScreenUtil.verticalScale(5.1),
                              surfaceTintColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              centerTitle: true,
                              leading: BackArrowWidget(
                                onPress: () {
                                  Navigator.pop(context);
                                },
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: const CommonStreakWithNotification(
                                      routeString: '/exerciseLibrary'),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(10),
                                  vertical: ScreenUtil.verticalScale(10)),
                              child: Center(
                                child: Text(
                                  'Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.horizontalScale(8),
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: media.height / 2.64,
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
                Container(
                  margin: EdgeInsets.only(top: media.height / 2.65),
                  width: media.width,
                  constraints: BoxConstraints(
                    minHeight: (media.height - media.height / 2.65),
                  ),
                  // height: ScreenUtil.verticalScale((media.height - media.height / 2)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                    ),
                  ),
                  child: loader
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil.horizontalScale(6),
                                right: ScreenUtil.horizontalScale(6),
                                top: ScreenUtil.verticalScale(2),
                              ),
                              height: ScreenUtil.verticalScale(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Enable notifications?",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Consumer<MonthProvider>(
                                    builder: (context, monthDataModel, child) {
                                      return Switch(
                                        value: isSwitchOn ??
                                            false, // Boolean value
                                        onChanged: (bool value) async {
                                          setState(() {
                                            isSwitchOn = value; // Update state
                                          });
                                          await preferences.setBool(
                                              SharedPreference
                                                  .notificationSwitch,
                                              isSwitchOn ?? false);
                                          if (isSwitchOn == true) {
                                            await NotificationService
                                                .scheduleMonthlyReminder(
                                                    20,
                                                    monthDataModel.endTime ??
                                                        DateTime.now().toUtc());
                                            await NotificationService
                                                .scheduleWeekReminder(
                                                    30,
                                                    monthDataModel.endTime ??
                                                        DateTime.now().toUtc());
                                          } else {
                                            await NotificationService
                                                .clearScheduledNotification();
                                          }
                                        },
                                        activeColor: AppColors.primaryColor,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil.horizontalScale(7),
                                  0,
                                  ScreenUtil.horizontalScale(7),
                                  0),
                              child: Divider(
                                thickness: 0.3,
                                height: 0,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil.horizontalScale(6),
                                right: ScreenUtil.horizontalScale(6),
                              ),
                              height: ScreenUtil.verticalScale(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Mute videos globally?",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Consumer<MonthProvider>(
                                    builder: (context, monthDataModel, child) {
                                      return Switch(
                                        value: !isMute,
                                        onChanged: (bool value) async {
                                          isMute = !isMute;

                                          setState(() {});
                                          await preferences.setBool(
                                              SharedPreference.isMute, isMute);
                                        },
                                        activeColor: AppColors.primaryColor,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil.horizontalScale(7),
                                  0,
                                  ScreenUtil.horizontalScale(7),
                                  0),
                              child: Divider(
                                thickness: 0.3,
                                height: 0,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil.horizontalScale(6),
                                right: ScreenUtil.horizontalScale(6),
                              ),
                              height: ScreenUtil.verticalScale(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Haptic feedback?",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Consumer<MonthProvider>(
                                    builder: (context, monthDataModel, child) {
                                      return Switch(
                                        value: isHapticFeedbackOn ??
                                            false, // Boolean value

                                        onChanged: (bool value) async {
                                          setState(() {
                                            isHapticFeedbackOn = value;
                                          });

                                          await preferences.setBool(
                                              SharedPreference
                                                  .isHapticFeedbackOn,
                                              isHapticFeedbackOn ?? false);

                                          if (value == true) {
                                            HapticFeedBack.buttonClick();
                                          }
                                        },
                                        activeColor: AppColors.primaryColor,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil.horizontalScale(7),
                                  0,
                                  ScreenUtil.horizontalScale(7),
                                  0),
                              child: Divider(
                                thickness: 0.3,
                                height: 0,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: ScreenUtil.horizontalScale(6),
                                right: ScreenUtil.horizontalScale(6),
                              ),
                              height: ScreenUtil.verticalScale(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Keep awake during workout",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.verticalScale(2.2),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Consumer<MonthProvider>(
                                    builder: (context, monthDataModel, child) {
                                      return Switch(
                                        value: isScreenAwake, // Boolean value

                                        onChanged: (bool value) async {
                                          setState(() {
                                            isScreenAwake = value;
                                          });

                                          await preferences.setBool(
                                              SharedPreference.isScreenAwake,
                                              isScreenAwake);
                                        },
                                        activeColor: AppColors.primaryColor,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil.horizontalScale(7),
                                  0,
                                  ScreenUtil.horizontalScale(7),
                                  0),
                              child: Divider(
                                thickness: 0.3,
                                height: 0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(3),
                                  vertical: ScreenUtil.verticalScale(2.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Theme(
                                    data: ThemeData().copyWith(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil.verticalScale(0)),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right:
                                                ScreenUtil.horizontalScale(3)),
                                        child: com.ExpansionPanelList(
                                          sidePadding: false,
                                          animationDuration:
                                              Duration(milliseconds: 300),
                                          expandIconColor:
                                              AppColors.primaryColor,
                                          materialGapSize: 10,
                                          expandedHeaderPadding:
                                              EdgeInsets.zero,
                                          expansionCallback:
                                              (panelIndex, isExpanded) {
                                            setState(() {
                                              isSplit = isExpanded;
                                              curExpandedIdx =
                                                  isExpanded ? 0 : -1;
                                            });

                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                if (_scrollController
                                                    .hasClients) {
                                                  _scrollController.animateTo(
                                                    _scrollController.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    curve: Curves.easeOut,
                                                  );
                                                }
                                              });
                                            });
                                          },
                                          elevation: 0,
                                          children: [
                                            com.ExpansionPanel(
                                                backgroundColor: Colors.white,
                                                isExpanded: isSplit,
                                                canTapOnHeader: true,
                                                headerBuilder:
                                                    (context, isExpanded) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil
                                                            .horizontalScale(
                                                                0)),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: ScreenUtil
                                                                .horizontalScale(
                                                                    3),
                                                          ),
                                                          child: Text(
                                                            'Default split',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              fontSize: ScreenUtil
                                                                  .verticalScale(
                                                                      2.2),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 14),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                body: Consumer<MonthProvider>(
                                                  builder:
                                                      (context, value, child) {
                                                    return Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: ScreenUtil
                                                                .horizontalScale(
                                                                    3),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                'Choose workout frequency',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color(
                                                                      0xBB888888),
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          1.7),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 4),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  AnimatedDialog
                                                                      .showAnimatedDialog(
                                                                    context:
                                                                        context,
                                                                    pageBuilder: (c1,
                                                                            anim1,
                                                                            anim2) =>
                                                                        ChooseWorkoutDayDialog(),
                                                                  );
                                                                  // showDialog(
                                                                  //   barrierDismissible: true,
                                                                  //   context: context,
                                                                  //   builder: (context) {
                                                                  //     return Dialog(
                                                                  //       shape: RoundedRectangleBorder(
                                                                  //         borderRadius: BorderRadius.circular(20),
                                                                  //       ),
                                                                  //       insetPadding: EdgeInsets.symmetric(
                                                                  //           horizontal: ScreenUtil.horizontalScale(5)),
                                                                  //       child: ChooseWorkoutDayDialog(),
                                                                  //     );
                                                                  //   },
                                                                  // );
                                                                },
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons.info,
                                                                    size: ScreenUtil
                                                                        .verticalScale(
                                                                            2.3),
                                                                    color: const Color(
                                                                        0xBB888888),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      0.3)),
                                                          padding: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      1.25)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    ScreenUtil
                                                                        .verticalScale(
                                                                            5)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: AppColors
                                                                    .greyColor,
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                radius: ScreenUtil
                                                                    .verticalScale(
                                                                        2),
                                                                child: Text(
                                                                  "3",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                "3 days per week",
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color(
                                                                      0xBB888888),
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          1.8),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    updateSplitIndex(
                                                                        0),
                                                                child:
                                                                    Container(
                                                                  height: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  width: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: splitIndex ==
                                                                            0
                                                                        ? AppColors
                                                                            .primaryColor
                                                                        : Colors
                                                                            .transparent,
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .primaryColor),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .done,
                                                                      size: ScreenUtil
                                                                          .verticalScale(
                                                                              2.5),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      0.3)),
                                                          padding: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      1.25)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    ScreenUtil
                                                                        .verticalScale(
                                                                            5)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: AppColors
                                                                    .greyColor,
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                radius: ScreenUtil
                                                                    .verticalScale(
                                                                        2),
                                                                child: Text(
                                                                  "4",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                "4 days per week",
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color(
                                                                      0xBB888888),
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          1.8),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    updateSplitIndex(
                                                                        1),
                                                                child:
                                                                    Container(
                                                                  height: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  width: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: splitIndex ==
                                                                            1
                                                                        ? AppColors
                                                                            .primaryColor
                                                                        : Colors
                                                                            .transparent,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .primaryColor),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .done,
                                                                      size: ScreenUtil
                                                                          .verticalScale(
                                                                              2.5),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      0.3)),
                                                          padding: EdgeInsets
                                                              .all(ScreenUtil
                                                                  .verticalScale(
                                                                      1.25)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    ScreenUtil
                                                                        .verticalScale(
                                                                            5)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: AppColors
                                                                    .greyColor,
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                radius: ScreenUtil
                                                                    .verticalScale(
                                                                        2),
                                                                child: Text(
                                                                  "5",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                "5 days per week",
                                                                style:
                                                                    TextStyle(
                                                                  color: const Color(
                                                                      0xBB888888),
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          1.8),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    updateSplitIndex(
                                                                        2),
                                                                child:
                                                                    Container(
                                                                  height: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  width: ScreenUtil
                                                                      .verticalScale(
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: splitIndex ==
                                                                            2
                                                                        ? AppColors
                                                                            .primaryColor
                                                                        : Colors
                                                                            .transparent,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .primaryColor),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .done,
                                                                      size: ScreenUtil
                                                                          .verticalScale(
                                                                              2.5),
                                                                      color: Colors
                                                                          .white,
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
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil.horizontalScale(3),
                                        0,
                                        ScreenUtil.horizontalScale(3),
                                        0),
                                    child: Divider(
                                      thickness: 0.3,
                                      height: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Theme(
                                    data: ThemeData().copyWith(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil.verticalScale(0)),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right:
                                                ScreenUtil.horizontalScale(3)),
                                        child: com.ExpansionPanelList(
                                          sidePadding: false,
                                          animationDuration:
                                              Duration(milliseconds: 300),
                                          expandIconColor:
                                              AppColors.primaryColor,
                                          materialGapSize: 10,
                                          expandedHeaderPadding:
                                              EdgeInsets.zero,
                                          expansionCallback:
                                              (panelIndex, isExpanded) {
                                            setState(() {
                                              isEquipment = isExpanded;
                                              curExpandedIdx =
                                                  isExpanded ? 0 : -1;
                                            });

                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                if (_scrollController
                                                    .hasClients) {
                                                  _scrollController.animateTo(
                                                    _scrollController.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    curve: Curves.easeOut,
                                                  );
                                                }
                                              });
                                            });
                                          },
                                          elevation: 0,
                                          children: [
                                            com.ExpansionPanel(
                                              backgroundColor: Colors.white,
                                              isExpanded: isEquipment,
                                              canTapOnHeader: true,
                                              headerBuilder:
                                                  (context, isExpanded) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      left: ScreenUtil
                                                          .horizontalScale(0)),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          left: ScreenUtil
                                                              .horizontalScale(
                                                                  3),
                                                        ),
                                                        child: Text(
                                                          'Default equipment',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .primaryColor,
                                                            fontSize: ScreenUtil
                                                                .verticalScale(
                                                                    2.2),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      SizedBox(width: 4),
                                                    ],
                                                  ),
                                                );
                                              },
                                              body: Consumer<MonthProvider>(
                                                builder:
                                                    (context, value, child) {
                                                  return Column(
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          left: ScreenUtil
                                                              .horizontalScale(
                                                                  3),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Choose equipment availability',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xBB888888),
                                                                fontSize: ScreenUtil
                                                                    .verticalScale(
                                                                        1.7),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            SizedBox(width: 4),
                                                            GestureDetector(
                                                              onTap: () {
                                                                AnimatedDialog
                                                                    .showAnimatedDialog(
                                                                  context:
                                                                      context,
                                                                  pageBuilder: (c1,
                                                                          anim1,
                                                                          anim2) =>
                                                                      ChooseEquipmentDialog(),
                                                                );

                                                                // showDialog(
                                                                //   barrierDismissible: true,
                                                                //   context: context,
                                                                //   builder: (context) {
                                                                //     return Dialog(
                                                                //       shape: RoundedRectangleBorder(
                                                                //         borderRadius: BorderRadius.circular(20),
                                                                //       ),
                                                                //       insetPadding:
                                                                //           EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5)),
                                                                //       child: ChooseEquipmentDialog(),
                                                                //     );
                                                                //   },
                                                                // );
                                                              },
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.info,
                                                                  size: ScreenUtil
                                                                      .verticalScale(
                                                                          2.3),
                                                                  color: const Color(
                                                                      0xBB888888),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    0.3)),
                                                        padding: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    1.25)),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius
                                                              .circular(ScreenUtil
                                                                  .verticalScale(
                                                                      5)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .greyColor,
                                                              blurRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryColor,
                                                              radius: ScreenUtil
                                                                  .verticalScale(
                                                                      2),
                                                              child: Text(
                                                                "A",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          2.5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              "Fully equipped gym",
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xBB888888),
                                                                fontSize: ScreenUtil
                                                                    .verticalScale(
                                                                        1.8),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  updateEquipments(
                                                                      0),
                                                              child: Container(
                                                                height: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                width: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: equipments ==
                                                                          0
                                                                      ? AppColors
                                                                          .primaryColor
                                                                      : Colors
                                                                          .transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .primaryColor),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons.done,
                                                                    size: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    0.3)),
                                                        padding: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    1.25)),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius
                                                              .circular(ScreenUtil
                                                                  .verticalScale(
                                                                      5)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .greyColor,
                                                              blurRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryColor,
                                                              radius: ScreenUtil
                                                                  .verticalScale(
                                                                      2),
                                                              child: Text(
                                                                "B",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          2.5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              "Home gym",
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xBB888888),
                                                                fontSize: ScreenUtil
                                                                    .verticalScale(
                                                                        1.8),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  updateEquipments(
                                                                      1),
                                                              child: Container(
                                                                height: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                width: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: equipments ==
                                                                          1
                                                                      ? AppColors
                                                                          .primaryColor
                                                                      : Colors
                                                                          .transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .primaryColor),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons.done,
                                                                    size: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    0.3)),
                                                        padding: EdgeInsets.all(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    1.25)),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius
                                                              .circular(ScreenUtil
                                                                  .verticalScale(
                                                                      5)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .greyColor,
                                                              blurRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryColor,
                                                              radius: ScreenUtil
                                                                  .verticalScale(
                                                                      2),
                                                              child: Text(
                                                                "C",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: ScreenUtil
                                                                      .verticalScale(
                                                                          2.5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              "Dumbbells and bands",
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xBB888888),
                                                                fontSize: ScreenUtil
                                                                    .verticalScale(
                                                                        1.8),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  updateEquipments(
                                                                      2),
                                                              child: Container(
                                                                height: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                width: ScreenUtil
                                                                    .verticalScale(
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: equipments ==
                                                                          2
                                                                      ? AppColors
                                                                          .primaryColor
                                                                      : Colors
                                                                          .transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: AppColors
                                                                          .primaryColor),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    Icons.done,
                                                                    size: ScreenUtil
                                                                        .verticalScale(
                                                                            2.5),
                                                                    color: Colors
                                                                        .white,
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
                                            )
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
