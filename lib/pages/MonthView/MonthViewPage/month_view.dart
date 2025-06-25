import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/components/haptic_feedback%20.dart';
import 'package:bbb/components/month_view_setting_dialog.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/middleware/api/api_repo.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/models/MonthResponseModel/new_model.dart';
import 'package:bbb/pages/IntroScreen/video_intro_page.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/information_section.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/schedule_section.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/sections/setting_section.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/program_info_provider.dart';
import 'package:bbb/providers/scroll_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  MonthProvider? monthProvider;
  DataProvider? dataProvider;
  PageController pageController = PageController();
  ScrollProvider? scrollProvider;
  late ProgramInfoProvider provider;
  ScrollController scrollController = ScrollController();
  final GlobalKey optionKey = GlobalKey();

  bool _isPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      precacheImage(dataProvider!.cachedImageMap["imageMonthView"]!, context);
      _isPrecached = true;
    }
  }

  List<GlobalKey> keys = List.generate(4, (_) => GlobalKey());

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    scrollProvider = Provider.of<ScrollProvider>(context, listen: false);
    provider = context.read<ProgramInfoProvider>();
    provider.getProgramInfo();

    int index = monthProvider?.monthLocalDataModel.indexWhere(
          (element) => element.monthId == monthProvider?.monthDataModel?.id,
        ) ??
        0;

    pageController = PageController(initialPage: index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      monthProvider?.updateCurrentMonthIndex(index);
    });

    monthProvider?.mainPageProvider =
        Provider.of<MainPageProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        scrollToMiddle();
      },
    );

    // Add listener to handle scroll reset when weekExpandedHeight changes
    monthProvider?.addListener(() {
      if (monthProvider?.weekExpandedHeight == 0 &&
          scrollController.hasClients) {
        // Reset scroll when weekExpandedHeight is reset (usually when month changes)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients &&
              scrollController.position.pixels > 0) {
            scrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        String monthId =
            preferences.getString(SharedPreference.monthSettingDone) ?? "";

        monthProvider?.monthLocalDataModel.sort((a, b) =>
            DateTime.parse(b.monthStartDate ?? "${DateTime.now()}").compareTo(
                DateTime.parse(a.monthStartDate ?? "${DateTime.now()}")));
        bool alreadySetUp =
            (monthId == (monthProvider!.monthDataModel?.id ?? ""));
        if (!alreadySetUp && monthProvider!.isOnMonthPage) {
          openSettingDialog();
        }
      },
    );
    super.initState();
  }

  void scrollToMiddle() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (monthProvider!.scrollToRestDay) {
          Scrollable.ensureVisible(
            keys[(monthProvider?.week ?? 1) - 1].currentContext!,
            duration: Duration(milliseconds: 500),
          );
        }
      },
    );
  }

  openSettingDialog() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        AnimatedDialog.showAnimatedDialog(
            context: context,
            pageBuilder: (c1, anim1, anim2) =>
                MonthSettingDialog(monthProvider: monthProvider!)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => monthProvider?.onInit(isEnabled: false));
        monthProvider?.expandWeeks.clear();
        monthProvider?.updateSelectedSection(0);
        monthProvider?.updateWeekExpandedHeight(
            0, (monthProvider?.week ?? 1) - 1);
        monthProvider?.updateIsOnMonthPage(false);
        monthProvider?.updateIsCurrentMonth("Current");
        monthProvider?.updateScrollToRestDay(false);
      },
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => monthProvider?.findSplitTypeList(),
      // ),
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            WidgetsBinding.instance.scheduleFrameCallback(
              (timeStamp) {
                scrollProvider?.updateOffSet1(notification.metrics.pixels);
              },
            );
          }
          return true;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Utils.appImage(
              media,
              image: dataProvider!.cachedImageMap["imageMonthView"],
              imageKey: "imageMonthView",
            ),
            RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async {
                await monthProvider?.onInit(context: context, isEnabled: false);
                provider.getProgramInfo();
                await dataProvider?.getChooseWorkoutData();
                await dataProvider?.getChooseEquipmentData();
              },
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                controller: scrollController,
                physics: NoBottomBounceScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Consumer<MonthProvider>(
                                    builder: (context, monthProvider, child) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          top: ScreenUtil.verticalScale(4) +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height:
                                                  ScreenUtil.verticalScale(2.5),
                                            ),
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: ScreenUtil
                                                          .horizontalScale(10)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      monthProvider
                                                                  .currentMonthIndex <
                                                              monthProvider
                                                                      .monthLocalDataModel
                                                                      .length -
                                                                  1
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                if (monthProvider
                                                                        .currentMonthIndex <
                                                                    monthProvider
                                                                            .monthLocalDataModel
                                                                            .length -
                                                                        1) {
                                                                  monthProvider
                                                                      .updateCurrentMonthIndex(
                                                                          monthProvider.currentMonthIndex +
                                                                              1);

                                                                  monthProvider.fetchPastMonth(
                                                                      monthProvider
                                                                              .monthLocalDataModel[
                                                                          monthProvider
                                                                              .currentMonthIndex],
                                                                      context);

                                                                  pageController
                                                                      .animateToPage(
                                                                    monthProvider
                                                                        .currentMonthIndex,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    curve: Curves
                                                                        .ease,
                                                                  );

                                                                  // Reset scroll position when month changes
                                                                  WidgetsBinding
                                                                      .instance
                                                                      .addPostFrameCallback(
                                                                          (_) {
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                350),
                                                                        () {
                                                                      if (scrollController
                                                                          .hasClients) {
                                                                        scrollController
                                                                            .animateTo(
                                                                          0.0,
                                                                          duration:
                                                                              Duration(milliseconds: 300),
                                                                          curve:
                                                                              Curves.easeOut,
                                                                        );
                                                                      }
                                                                    });
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                width: ScreenUtil
                                                                    .horizontalScale(
                                                                        20),
                                                                padding: EdgeInsets
                                                                    .all(ScreenUtil
                                                                        .verticalScale(
                                                                            0.5)),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Previous",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          ScreenUtil.verticalScale(
                                                                              1.8),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: ScreenUtil
                                                                  .horizontalScale(
                                                                      20)),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                              vertical: ScreenUtil
                                                                  .verticalScale(
                                                                      0.5)),
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      ScreenUtil
                                                                          .horizontalScale(
                                                                              2)),
                                                          decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: monthProvider
                                                                          .startTime !=
                                                                      null &&
                                                                  monthProvider
                                                                          .endTime !=
                                                                      null
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      monthProvider.startTime == null ||
                                                                              monthProvider.startTime.toString() ==
                                                                                  ""
                                                                          ? ""
                                                                          : DateFormat('MM/dd')
                                                                              .format(monthProvider.startTime!),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            ScreenUtil.verticalScale(1.8),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      monthProvider.endTime == null ||
                                                                              monthProvider.endTime.toString() ==
                                                                                  ""
                                                                          ? ""
                                                                          : DateFormat(' - MM/dd')
                                                                              .format(monthProvider.endTime!),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            ScreenUtil.verticalScale(1.8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : const SizedBox(),
                                                        ),
                                                      ),
                                                      monthProvider
                                                                  .currentMonthIndex >
                                                              0
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                if (monthProvider
                                                                        .currentMonthIndex >
                                                                    0) {
                                                                  monthProvider
                                                                      .updateCurrentMonthIndex(
                                                                          monthProvider.currentMonthIndex -
                                                                              1);

                                                                  monthProvider.fetchPastMonth(
                                                                      monthProvider
                                                                              .monthLocalDataModel[
                                                                          monthProvider
                                                                              .currentMonthIndex],
                                                                      context);

                                                                  pageController
                                                                      .animateToPage(
                                                                    monthProvider
                                                                        .currentMonthIndex,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    curve: Curves
                                                                        .ease,
                                                                  );

                                                                  // Reset scroll position when month changes
                                                                  WidgetsBinding
                                                                      .instance
                                                                      .addPostFrameCallback(
                                                                          (_) {
                                                                    Future.delayed(
                                                                        Duration(
                                                                            milliseconds:
                                                                                350),
                                                                        () {
                                                                      if (scrollController
                                                                          .hasClients) {
                                                                        scrollController
                                                                            .animateTo(
                                                                          0.0,
                                                                          duration:
                                                                              Duration(milliseconds: 300),
                                                                          curve:
                                                                              Curves.easeOut,
                                                                        );
                                                                      }
                                                                    });
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                width: ScreenUtil
                                                                    .horizontalScale(
                                                                        20),
                                                                padding: EdgeInsets
                                                                    .all(ScreenUtil
                                                                        .verticalScale(
                                                                            0.5)),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Next",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          ScreenUtil.verticalScale(
                                                                              1.8),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: ScreenUtil
                                                                  .horizontalScale(
                                                                      20)),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil
                                                        .horizontalScale(2),
                                                    right: ScreenUtil
                                                        .horizontalScale(8),
                                                    top: ScreenUtil
                                                        .verticalScale(1),
                                                    bottom: ScreenUtil
                                                        .verticalScale(1),
                                                  ),
                                                  child: monthProvider
                                                              .monthTitleImage ==
                                                          null
                                                      ? SizedBox(
                                                          height: media.height /
                                                              7.5)
                                                      : SizedBox(
                                                          height: media.height /
                                                              7.5,
                                                          child: Center(
                                                            child:
                                                                Utils.appImage(
                                                              Size(
                                                                  media.width,
                                                                  media.height /
                                                                      7.5),
                                                              image: monthProvider
                                                                  .monthTitleImage,
                                                              imageKey: '',
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: ScreenUtil
                                                        .horizontalScale(16),
                                                  ),
                                                  child: ButtonWidget(
                                                    text: "Watch Video Intro",
                                                    color: Colors.white,
                                                    onPress: () {
                                                      AnimatedDialog
                                                          .showAnimatedDialog(
                                                        context: context,
                                                        pageBuilder: (c1, anim1,
                                                                anim2) =>
                                                            VideoIntroWidget(
                                                          vimeoId: '953289606',
                                                        ),
                                                      );
                                                    },
                                                    textColor:
                                                        AppColors.primaryColor,
                                                    isLoading: false,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: media.height / 3.229 +
                                    ScreenUtil.verticalScale(4) +
                                    MediaQuery.of(context).padding.top,
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
                        width: media.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ScreenUtil.verticalScale(7)),
                          ),
                        ),
                        margin: EdgeInsets.only(
                            top: media.height / 3.23 +
                                ScreenUtil.verticalScale(4) +
                                MediaQuery.of(context).padding.top),
                        child: Column(
                          children: [
                            SizedBox(
                              height: media.height * 0.12,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.horizontalScale(6),
                                  vertical: ScreenUtil.verticalScale(2.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<MonthProvider>(
                                        builder: (context, controller, child) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          3,
                                          (index) => Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                controller
                                                    .updateSelectedSection(
                                                        index);
                                                if (index == 1) {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 300),
                                                      () {
                                                    scrollController.animateTo(
                                                      scrollController.position
                                                              .maxScrollExtent /
                                                          1.07,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeOut,
                                                    );
                                                  });
                                                } else {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 300),
                                                      () {
                                                    scrollController.animateTo(
                                                      0.0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeOut,
                                                    );
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: ScreenUtil
                                                        .verticalScale(2.2)),
                                                margin: EdgeInsets.only(
                                                    left: index == 0 ? 0 : 8),
                                                decoration: BoxDecoration(
                                                    color: index ==
                                                            controller
                                                                .selectedSection
                                                        ? AppColors.primaryColor
                                                        : AppColors.greyColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            ScreenUtil
                                                                .verticalScale(
                                                                    5.5))),
                                                child: Center(
                                                  child: Text(
                                                    index == 0
                                                        ? "Program"
                                                        : index == 1
                                                            ? "Options"
                                                            // : "Information",
                                                            : "Microcycles",
                                                    style: TextStyle(
                                                      color: index ==
                                                              controller
                                                                  .selectedSection
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: ScreenUtil
                                                          .verticalScale(1.75),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            Consumer<MonthProvider>(
                              builder: (context, monthProvider, child) {
                                return Container(
                                  color: Colors.white,
                                  constraints: BoxConstraints(
                                    minHeight: (media.height -
                                        (media.height / 2.55) -
                                        (media.height * 0.12)),
                                  ),
                                  child: Column(
                                    children: [
                                      // if (!monthProvider.loader) ...[
                                      Visibility(
                                          visible:
                                              monthProvider.selectedSection ==
                                                  0,
                                          child: ScheduleSection(
                                              keys: keys,
                                              scrollToRestDay:
                                                  monthProvider.scrollToRestDay,
                                              scrollController:
                                                  scrollController,
                                              pageController: pageController,
                                              monthProvider: monthProvider,
                                              onPress: () =>
                                                  continueWorkoutOnTap(
                                                      context))),
                                      Visibility(
                                          visible:
                                              monthProvider.selectedSection ==
                                                  1,
                                          child: SettingSection(
                                            monthProvider: monthProvider,
                                            isSetting: false,
                                          )),
                                      Visibility(
                                          visible:
                                              monthProvider.selectedSection ==
                                                  2,
                                          child: InformationSection(
                                            monthProvider: monthProvider,
                                            programInfoProvider: provider,
                                            scrollController: scrollController,
                                          )),
                                      // ]
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer<ScrollProvider>(
              builder: (context, scrollValue, child) {
                double blurValue =
                    (scrollValue.scrollOffset1 / ScreenUtil.verticalScale(35))
                            .clamp(0, 1) *
                        5;
                double targetHeight = ScreenUtil.verticalScale(4.5);

                return ClipRRect(
                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                    child: Container(
                      color: Colors.black.withOpacity(
                          (scrollValue.scrollOffset1 /
                                      ScreenUtil.verticalScale(35))
                                  .clamp(0, 1) *
                              0.7),
                      height: targetHeight + MediaQuery.of(context).padding.top,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        child: AnimatedContainer(
                          margin: EdgeInsets.zero,
                          duration: Duration(milliseconds: 300),
                          height: targetHeight,
                          width: media.width,
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: BackArrowWidget(
                                  bigSize: 5.3,
                                  position: scrollValue.scrollOffset1,
                                  onPress: () {
                                    monthProvider?.mainPageProvider
                                        .changeTab(0);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CommonStreakWithNotification(
                                  routeString: '/month-view',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> continueWorkoutOnTap(BuildContext context) async {
    HapticFeedBack.buttonClick();
    int? index = monthProvider!
        .monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].idList
        ?.indexWhere((element) => element == monthProvider!.todayTitleId);

    final dayIndex = int.parse((monthProvider!.monthDataModel
                ?.weeks![(monthProvider!.week ?? 1) - 1].dayList?[index ?? 0]
                .toString()
                .replaceAll("Workout", "")
                .replaceAll("Rest", "")
                .replaceAll("Day", "")
                .replaceAll(" ", "") ??
            "0")) -
        1;

    DayDataModel dayData =
        "${monthProvider!.monthDataModel?.weeks?[(monthProvider!.week ?? 1) - 1].dayList![index ?? 0] ?? ""}"
                .toString()
                .contains("Workout")
            ? monthProvider!.monthDataModel!
                .weeks![(monthProvider!.week ?? 1) - 1].days![dayIndex]
            : DayDataModel();

    bool isRestDay = monthProvider!.monthDataModel
        ?.weeks?[(monthProvider!.week ?? 1) - 1].dayList?[index ?? 0]
        .contains("Rest Day");

    String split = monthProvider?.monthDataModel
            ?.weeks?[(monthProvider!.week ?? 1) - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.monthDataModel!.weeks![(monthProvider!.week ?? 1) - 1].id}-${monthProvider!.todayTitleId}";

    bool isPumpDay = (isRestDay &&
            monthProvider!.allDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type.toString().contains("Pump Day"))) ||
        (isRestDay &&
            (monthProvider!.isPumpDayAvailable &&
                (monthProvider!.allDayHistoryModel.any((element) =>
                    element.dataId == dataId &&
                    element.type != "Rest Day")))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (monthProvider!.allDayHistoryModel.any((element) =>
                element.dataId == dataId &&
                element.type == "Rest Day" &&
                element.status == ""))) ||
        (isRestDay &&
            monthProvider!.isPumpDayAvailable &&
            (!monthProvider!.allDayHistoryModel
                .map((e) => e.dataId)
                .toList()
                .contains(dataId)));

    monthProvider?.changeIsPumpDay(isPumpDay);
    if (isPumpDay) {
      final dataList = monthProvider?.dayHistoryModel
          .where((element) =>
              element.type?.contains("Pump Day") == true &&
              element.status != Status.empty)
          .toList();

      if (dataList!.isNotEmpty) {
        int index1 = monthProvider!.pumpDays.indexWhere((el1) => dataList.any(
            (e1) => (e1.dayId == monthProvider!.todayTitleId &&
                e1.type.toString().replaceAll("Pump Day - ", "") == el1.id)));
        if (index1 != -1) {
          monthProvider!.updatePumpDayData(monthProvider!.pumpDays[index1]);
        } else {
          int index1 = monthProvider!.pumpDays.indexWhere((el1) => dataList.any(
              (e1) =>
                  e1.type.toString().replaceAll("Pump Day - ", "") == el1.id));
          monthProvider!.updatePumpDayData(monthProvider!.pumpDays[index == -1
              ? 0
              : index1 == 0
                  ? 1
                  : 0]);
        }
      } else {
        monthProvider!.updatePumpDayData(monthProvider!.pumpDays[0]);
      }
      // monthProvider?.updatePumpDayData(monthProvider!.pumpDays[
      //     int.parse(monthProvider!.monthDataModel!.weeks![monthProvider!.week! - 1].dayList![index ?? 0].toString().split(" ").last) - 1]);
    }
    monthProvider!.overviewCurrentWeek = monthProvider!.week ?? 1;
    monthProvider!.overviewCurrentDay = ((index ?? 1) + 1);
    monthProvider!.dayDataModel = dayData;
    // monthProvider!.alternateEquipmentType = monthProvider!.equipmentType;
    monthProvider!.weekDataModel =
        monthProvider!.monthDataModel!.weeks![(monthProvider!.week ?? 1) - 1];
    monthProvider?.updateIsPastWeek(
        monthProvider!.weekStatuses[(monthProvider!.week ?? 1) - 1] ==
            WeekType.pastWeek);

    final dayIndex1 = monthProvider!.overviewCurrentDay;

    int nextWorkOutIndex = monthProvider!.weekDataModel!.dayList![dayIndex1 - 1]
            .toString()
            .contains("Workout")
        ? int.parse(monthProvider!.weekDataModel!.dayList![dayIndex1 - 1]
                .toString()
                .replaceAll("Day ", "")
                .replaceAll(" Workout", "")) -
            1
        : 0;
    String currentDayTitle = monthProvider!
            .weekDataModel!.dayList![dayIndex1 - 1]
            .toString()
            .contains("Workout")
        ? monthProvider!.weekDataModel!.days![nextWorkOutIndex].title ?? ""
        : monthProvider!.weekDataModel!.dayList![dayIndex1 - 1];
    // if (currentDayTitle.contains("Rest Day") && (!monthProvider!.isPumpDay)) {
    //   Navigator.pushNamed(context, '/dayOverview');
    // }

    final isCompletedOrSkipped = (monthProvider?.allSplitDayHistoryModel.any(
        (element) =>
            (element.status == Status.completed ||
                element.status == Status.skipped) &&
            element.dataId == dataId));
    if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider!.isPumpDay) &&
        isCompletedOrSkipped!) {
      return;
    } else if (currentDayTitle.contains("Rest Day") &&
        (!monthProvider!.isPumpDay) &&
        !isCompletedOrSkipped!) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      context.read<MainPageProvider>().changeTab(1);
      monthProvider?.updateIsOnMonthPage(false);
      monthProvider?.updateScrollToRestDay(true);
      _completeRestDay(
              status: Status.completed, type: 'Rest Day', endDate: true)
          .then(
        (value) {
          monthProvider?.onInit(context: context, isEnabled: false);
        },
      );
      await monthProvider?.checkForPumpDay();
      // showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (c1) {
      //     return skipWorkoutDialog(context, c1);
      //   },
      // );
    } else {
      if (monthProvider!.isPumpDay) {
        if ((monthProvider!.allSplitDayHistoryModel.any((element) =>
                (element.status == Status.completed ||
                    element.status == Status.skipped) &&
                element.dataId == dataId)) ==
            false) {
          _saveDayData(
              type: "Pump Day - ${monthProvider!.pumpDayModel?.id}",
              status: Status.started,
              title: monthProvider!.pumpDayModel?.title);
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today').then(
            (value) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) async => await monthProvider!.checkForPumpDay());
            },
          );
        } else {
          if (!context.mounted) return;
          await Navigator.pushNamed(context, '/today');
        }
      } else {
        if ((monthProvider!.dayHistoryModel
                .any((element) => element.dataId == dataId)) ==
            false) {
          _saveDayData(status: Status.started, type: 'Workout Day');
        }
        if (!context.mounted) return;
        await Navigator.pushNamed(context, '/today');
      }
    }
    // Navigator.pushNamed(context, '/dayOverview');
  }

  Future<void> _saveDayData(
      {required String status, required String type, String? title}) async {
    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider
          ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": "",
    };

    DayHistoryModel? matchingElement =
        monthProvider?.dayHistoryModel.firstWhere(
      (element) => element.dataId == dataId,
      orElse: () => DayHistoryModel(),
    );

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime":
          (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
    };

    final apiBody = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime":
          (status == Status.completed) ? "${DateTime.now().toUtc()}" : "",
      "dataId": dataId
    };

    if (matchingElement?.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);
      await DatabaseHelper().updateData(
          tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);
      await DatabaseHelper()
          .insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider?.fetchAllDayStatusLocalData();
    monthProvider?.findWeekStatuses();
    monthProvider?.fetchToday();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }

  Future<void> _completeRestDay(
      {required String status,
      required String type,
      String? title,
      bool endDate = false}) async {
    String split = monthProvider?.monthDataModel
            ?.weeks?[monthProvider!.overviewCurrentWeek - 1].idList?.first
            .toString()
            .split(" ")[1] ??
        "";

    String dataId =
        "$split-${monthProvider?.monthDataModel?.id}-${monthProvider?.weekDataModel?.id}-${monthProvider?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1]}";

    if (status == Status.completed) {
      ApiRepo.addDayStatusList(body: {
        "date": "${DateTime.now().toUtc()}",
        "status": Status.completed
      });
    }

    final data = {
      "title": title ?? "",
      "dataId": dataId,
      "monthId": monthProvider?.monthDataModel?.id,
      "weekId": monthProvider?.weekDataModel?.id,
      "dayId": monthProvider
          ?.weekDataModel?.idList![monthProvider!.overviewCurrentDay - 1],
      "split": split,
      "date": "${DateTime.now().toUtc()}",
      "status": status,
      "type": type,
      "startTime": "${DateTime.now().toUtc()}",
      "endTime": endDate ? "${DateTime.now().toUtc()}" : "",
    };

    DayHistoryModel? matchingElement = monthProvider?.dayHistoryModel
        .firstWhere((element) => element.dataId == dataId,
            orElse: () => DayHistoryModel());

    final data1 = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime": (status == Status.completed)
          ? "${DateTime.now().toUtc()}"
          : (endDate ? "${DateTime.now().toUtc()}" : ""),
    };

    final apiBody = {
      "title": title ?? "",
      "status": status,
      "type": type,
      "startTime": status == Status.empty
          ? ""
          : matchingElement?.startTime == null
              ? "${DateTime.now().toUtc()}"
              : matchingElement?.startTime.toString(),
      "endTime": (status == Status.completed)
          ? "${DateTime.now().toUtc()}"
          : (endDate ? "${DateTime.now().toUtc()}" : ""),
      "dataId": dataId
    };

    if (matchingElement?.id != null) {
      ApiRepo.updateDayStatus(body: apiBody);

      await DatabaseHelper().updateData(
          tableName: DatabaseHelper.dayStatus, id: dataId, data: data1);
    } else {
      ApiRepo.addDayStatus(body: data);

      await DatabaseHelper()
          .insertData(data: data, tableName: DatabaseHelper.dayStatus);
    }

    await monthProvider?.fetchAllDayStatusLocalData();
    monthProvider?.findWeekStatuses();
    monthProvider?.fetchToday();
    monthProvider?.manageStreak();
    monthProvider?.getLiftedWeightGraphData();
  }
}
