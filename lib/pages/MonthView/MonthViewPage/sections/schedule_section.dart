import 'package:bbb/components/button_widget.dart';
import 'package:bbb/pages/MonthView/MonthViewPage/track_card_newww.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key, required this.monthProvider, this.onPress});

  final MonthProvider monthProvider;
  final dynamic Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<MonthProvider>(
          builder: (context, value, child) {
            if (value.week == null || value.week! > 4) return const SizedBox();

            String split = value.monthDataModel?.weeks?[value.week! - 1].idList?.first.toString().split(" ")[1] ?? "";

            return value.isFilterLoading
                ? const SizedBox()
                : value.weeksDataList.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
                        child: Column(
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
                                    WeeklyTrackCardNew(
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
                                    const SizedBox(height: 15),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text("No workout data available"),
                      );
          },
        ),
        const SizedBox(height: 15),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(6.5),
          ),
          child: Consumer<MonthProvider>(
            builder: (context, value, child) => ButtonWidget(
              text: monthProvider.todayTitleId.isEmpty ? "Completed" : "Start Your Workout",
              textColor: Colors.white,
              onPress: monthProvider.todayTitleId.isEmpty ? () {} : () => onPress,
              color: monthProvider.todayTitleId.isEmpty ? Colors.green : AppColors.primaryColor,
              isLoading: false,
            ),
          ),
        ),
      ],
    );
  }
}
