import 'package:bbb/components/button_widget.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/track_card.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleSectionNew extends StatelessWidget {
  const ScheduleSectionNew({super.key, required this.monthProvider, this.onPress, required this.pageController});
  final PageController pageController;
  final MonthProvider monthProvider;
  final dynamic Function()? onPress;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Consumer<MonthProvider>(
      builder: (context, value, child) {
        return SizedBox(
          height: ScreenUtil.verticalScale((/*value.isCurrentMonth == "Current" ? 50 :*/ 50) + (value.weekExpandedHeight).toDouble()),
          child: PageView.builder(
            reverse: true,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (int v) {
              // value.updateCurrentMonthIndex(v);
              // value.fetchPastMonth(value.monthLocalDataModel[v], context);
            },
            controller: pageController,
            itemCount: value.monthLocalDataModel.length,
            itemBuilder: (context, index) {
              if (value.switchMonthLoader) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil.verticalScale(15)),
                    child: Align(alignment: Alignment.topCenter, child: CircularProgressIndicator()),
                  ),
                );
              }

              if (value.week == null || value.week! > 4) return const SizedBox();
              String split = value.week == 0
                  ? "${value.splitType}"
                  : value.monthDataModel?.weeks?[value.week! - 1].idList?.first.toString().split(" ")[1] ?? "";
              return value.isFilterLoading
                  ? Container(constraints: BoxConstraints(minHeight: (media.height - (media.height / 2.55) - (media.height * 0.12))))
                  : value.weeksDataList.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: value.weeksDataList.length,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    WeeklyTrackCard(
                                      index: index,
                                      monthProvider: value,
                                      pumpDayIds: value.weeksDataList[index].pumpDayIds!,
                                      title:
                                          value.weeksDataList[index].title == "" ? "Week ${index + 1}" : value.weeksDataList[index].title!,
                                      thisWeek: ((index + 1) == value.week),
                                      restDayId: value.weeksDataList[index].restdayId!,
                                      weekIndex: index,
                                      isOpened: false,
                                      isCompleted: false,
                                      startDate: (value.startTime ?? DateTime.now()).add(Duration(days: index * 7)),
                                      cardData: value.weeksDataList[index],
                                      daySplit: split,
                                      expandedVal: (index + 1) == value.week ? true : false,
                                      completedWeek: index + 1,
                                    ),
                                    SizedBox(height: ScreenUtil.verticalScale(1.5)),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(2.4)),
                            value.week == 0 || value.isCurrentMonth != "Current"
                                ? SizedBox()
                                : Container(
                                    height: ScreenUtil.verticalScale(6.6),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.horizontalScale(9),
                                    ),
                                    child: Consumer<MonthProvider>(
                                      builder: (context, monthProvider, child) {
                                        String split = monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].idList?.first
                                                .toString()
                                                .split(" ")[1] ??
                                            "";
                                        String dataId =
                                            "$split-${monthProvider.monthDataModel?.id}-${monthProvider.monthDataModel?.weeks?[(monthProvider.week ?? 1) - 1].id}-${monthProvider.todayTitleId}";

                                        final data = monthProvider.allDayHistoryModel.where((element) => element.dataId == dataId);
                                        String status = "";
                                        String title = "";
                                        if (data.isNotEmpty) {
                                          status = data.first.status ?? "";
                                          title = data.first.title ?? "";
                                        }

                                        return ButtonWidget(
                                          text: monthProvider.todayTitleId.isEmpty
                                              ? "Completed"
                                              : (!title.contains("Pump Day") &&
                                                      !monthProvider.isPumpDayAvailable &&
                                                      monthProvider.todayTitleId.contains("Rest Day"))
                                                  ? "Mark Complete"
                                                  : status == Status.started
                                                      ? 'Continue Your Workout'
                                                      : 'Start Your Workout',
                                          textColor: Colors.white,
                                          onPress: monthProvider.todayTitleId.isEmpty ? () {} : () => onPress!(),
                                          color: monthProvider.todayTitleId.isEmpty ? Colors.green : AppColors.primaryColor,
                                          isLoading: false,
                                        );
                                      },
                                    ),
                                  ),
                            SizedBox(height: ScreenUtil.verticalScale(15))
                          ],
                        )
                      : Container(
                          constraints: BoxConstraints(minHeight: (media.height - (media.height / 2.55) - (media.height * 0.12))),
                          child: const Center(
                            child: Text("No workout data available"),
                          ),
                        );
            },
          ),
        );
      },
    );
  }
}
