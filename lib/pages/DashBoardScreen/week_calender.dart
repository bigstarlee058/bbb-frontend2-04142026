import 'dart:developer';

import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class WeekCalender extends StatefulWidget {
  const WeekCalender(
      {super.key, required this.monthProvider, required this.userData});
  final MonthProvider monthProvider;
  final UserDataProvider userData;

  @override
  State<WeekCalender> createState() => _WeekCalenderState();
}

class _WeekCalenderState extends State<WeekCalender> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    _focusedDay = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5.5)),
      child: SizedBox(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: TableCalendar(
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: ScreenUtil.verticalScale(4.55),
            daysOfWeekHeight: ScreenUtil.verticalScale(4.55),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color),
              weekendStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            headerStyle: HeaderStyle(
              headerPadding: const EdgeInsets.only(bottom: 2),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 20, color: AppColors.primaryColor),
              rightChevronIcon: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 20, color: AppColors.primaryColor),
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM().format(date),
              titleTextStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
            headerVisible: false,
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: 14.0),
              weekendTextStyle: TextStyle(fontSize: 14.0),
              outsideTextStyle: TextStyle(fontSize: 14.0),
            ),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                return _buildNormalDay(day);
              },
              todayBuilder: (context, day, focusedDay) => _buildDayState(day),
              outsideBuilder: (context, date, _) {
                return _buildDayState(date);
              },
              defaultBuilder: (context, date, _) {
                return _buildDayState(date);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildDayState(DateTime date) {
    final nowUtc = DateTime.now();
    String accountCreatedDate = widget.userData.userData["createdAt"];
    DateTime targetDate = DateTime.parse(accountCreatedDate).toLocal();
    DateTime futureDay =
        DateTime(nowUtc.year, nowUtc.month, nowUtc.day).add(Duration(days: 1));
    DateTime today = DateTime(date.year, date.month, date.day);

    if (today.isBefore(futureDay)) {
      if (targetDate.subtract(Duration(days: 1)).isBefore(date)) {
        if (widget.monthProvider.monthLocalDataModel.isNotEmpty) {
          DateTime oldestStartDate = widget.monthProvider.monthLocalDataModel
              .map(
                (e) => DateFormat("dd-MM-yyyy").parse(
                  DateFormat("dd-MM-yyyy").format(
                    Utils.formattedDate(e.monthStartDate!),
                  ),
                ),
              )
              .reduce((a, b) => a.isBefore(b) ? a : b);
          List<DayHistoryModel> data = widget.monthProvider.decodedDataAll();
          bool isCurrentDay = date.year == nowUtc.year &&
              date.month == nowUtc.month &&
              date.day == nowUtc.day;

          if (data.isEmpty) {
            if (isCurrentDay) {
              return _buildCurrentWorkoutDay(date);
            } else if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
              return _buildCustomDayCircle(date, Colors.blue);
            }
          }

          DateTime futureDay = DateTime(nowUtc.year, nowUtc.month, nowUtc.day)
              .add(Duration(days: 1));

          if (date.isBefore(futureDay)) {
            // if (widget.monthProvider.dayStatusList.isNotEmpty) {
            //   for (var day in data) {
            //     final workoutDate = day.date;
            //     DateTime localTime = Utils.formattedDate("$workoutDate");
            //     if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
            //       if (day.status == Status.completed) {
            //         return _buildCustomDayCircle(date, AppColors.primaryColor);
            //       } else if (day.status == Status.skipped) {
            //         return _buildCustomDayCircle(date, Colors.blue);
            //       }
            //     }
            //   }
            // }

            for (var day in data) {
              final workoutDate = day.endTime!;

              DateTime localTime = Utils.formattedDate("$workoutDate");

              if ((localTime.day == date.day &&
                  localTime.month == date.month &&
                  localTime.year == date.year)) {
                if (day.status == Status.completed) {
                  return _buildCustomDayCircle(date, AppColors.primaryColor);
                } else if (day.status == Status.skipped) {
                  return _buildCustomDayCircle(date, Colors.blue);
                }
              }
            }
          }

          if (isCurrentDay) {
            for (var day in data) {
              final workoutDate = day.endTime!;
              DateTime localTime = Utils.formattedDate("$workoutDate");
              if ((localTime.day == date.day &&
                  localTime.month == date.month &&
                  localTime.year == date.year)) {
                if (day.status == Status.completed) {
                  return _buildCustomDayCircle(date, AppColors.primaryColor);
                } else if (day.status == Status.skipped) {
                  return _buildCustomDayCircle(date, Colors.blue);
                }
              }
              return _buildCurrentWorkoutDay(date);
            }
          }
          if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
            if (DateTime(futureDay.year, futureDay.month, futureDay.day) !=
                DateTime(date.year, date.month, date.day)) {
              return _buildCustomDayCircle(date, Colors.blue);
            }
          } else {
            return _buildNormalDay(date);
          }
        } else {
          final nowUtc = DateTime.now();
          bool isCurrentDay = date.year == nowUtc.year &&
              date.month == nowUtc.month &&
              date.day == nowUtc.day;
          if (isCurrentDay) {
            return _buildCurrentWorkoutDay(date);
          } else {
            return _buildNormalDay(date);
          }
        }
      }
    }

    return _buildNormalDay(date);
  }

  Widget _buildCustomDayCircle(DateTime date, Color circleColor) {
    bool isCurrentDay = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        isCurrentDay
            ? Positioned(
                top: -ScreenUtil.verticalScale(4.05),
                bottom: 1,
                right: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.backOffSetColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Builder(
                    builder: (context) {
                      final text = DateFormat.E().format(date);
                      return Container(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.verticalScale(0.65)),
                        child: Text(
                          textAlign: TextAlign.center,
                          text,
                          style: TextStyle(fontSize: 14.0, color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
              )
            : SizedBox(),
        isCurrentDay
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(ScreenUtil.horizontalScale(0.2)),
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(0.92)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
                margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(0.92)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildCurrentWorkoutDay(DateTime date) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -ScreenUtil.verticalScale(4.05),
          bottom: 1,
          right: 0,
          left: 0,
          child: Container(
              decoration: BoxDecoration(
                  color: AppColors.backOffSetColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Builder(
                builder: (context) {
                  final text = DateFormat.E().format(date);
                  return Container(
                    padding:
                        EdgeInsets.only(top: ScreenUtil.verticalScale(0.65)),
                    child: Text(
                      textAlign: TextAlign.center,
                      text,
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                    ),
                  );
                },
              )),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
          margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(0.92)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Text(
            '${date.day}',
            style: const TextStyle(
              fontSize: 14.0,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalDay(DateTime date) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
      margin: EdgeInsets.only(bottom: ScreenUtil.verticalScale(0.92)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Text(
        '${date.day}',
        style: TextStyle(
          fontSize: 14.0,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
