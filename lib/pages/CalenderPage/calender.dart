// import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
// import 'package:bbb/providers/data_provider.dart';
// import 'package:bbb/providers/month_provider.dart';
// import 'package:bbb/providers/user_data_provider.dart';
// import 'package:bbb/utils/screen_util.dart';
// import 'package:bbb/utils/utils.dart';
// import 'package:bbb/values/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// class CalendarWidget extends StatefulWidget {
//   const CalendarWidget({super.key});
//
//   @override
//   State<CalendarWidget> createState() => _CalendarWidgetState();
// }
//
// class _CalendarWidgetState extends State<CalendarWidget> {
//   UserDataProvider? userData;
//   DataProvider? dataProvider;
//
//   @override
//   void initState() {
//     super.initState();
//     dataProvider = Provider.of<DataProvider>(
//       context,
//       listen: false,
//     );
//
//     userData = Provider.of<UserDataProvider>(
//       context,
//       listen: false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(65, 15, 65, 10),
//             child: Text(
//               'Mark a day a complete every day to keep the perfect flame streak going.',
//               style: TextStyle(
//                 color: Colors.black.withValues(alpha: 0.5),
//                 fontSize: ScreenUtil.verticalScale(2.2),
//                 fontWeight: FontWeight.normal,
//                 height: 1.2,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const CustomCalendarWidget(),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomCalendarWidget extends StatefulWidget {
//   const CustomCalendarWidget({super.key});
//
//   @override
//   State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
// }
//
// class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
//   late DateTime _focusedDay;
//   DateTime? _selectedDay;
//   MonthProvider? monthProvider;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusedDay = DateTime.now();
//     monthProvider = Provider.of<MonthProvider>(context, listen: false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
//       child: Card(
//         color: Colors.grey.shade50,
//         elevation: 4,
//         shadowColor: Colors.black.withValues(alpha: 0.4),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: SizedBox(
//             child: SingleChildScrollView(
//               physics: NeverScrollableScrollPhysics(),
//               child: TableCalendar(
//                 startingDayOfWeek: StartingDayOfWeek.monday,
//                 availableGestures: AvailableGestures.horizontalSwipe,
//                 rowHeight: 40.0,
//                 daysOfWeekHeight: 20.0,
//                 firstDay: DateTime.utc(2020, 1, 1),
//                 lastDay: DateTime.utc(2030, 12, 31),
//                 focusedDay: _focusedDay,
//                 selectedDayPredicate: (day) {
//                   return isSameDay(_selectedDay, day);
//                 },
//                 headerStyle: HeaderStyle(
//                   headerPadding: const EdgeInsets.only(bottom: 10),
//                   formatButtonVisible: false,
//                   titleCentered: true,
//                   leftChevronIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.primaryColor),
//                   rightChevronIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppColors.primaryColor),
//                   titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
//                   titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
//                 ),
//                 calendarStyle: const CalendarStyle(
//                   defaultTextStyle: TextStyle(fontSize: 12.0),
//                   weekendTextStyle: TextStyle(fontSize: 12.0),
//                   outsideTextStyle: TextStyle(fontSize: 10.0),
//                 ),
//                 calendarBuilders: CalendarBuilders(
//                   todayBuilder: (context, day, focusedDay) => _buildDayState(day),
//                   outsideBuilder: (context, date, _) {
//                     return _buildDayState(date);
//                   },
//                   defaultBuilder: (context, date, _) {
//                     return _buildDayState(date);
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget? _buildDayState(DateTime date) {
//     final nowUtc = DateTime.now();
//     if (monthProvider!.monthLocalDataModel.isNotEmpty) {
//       DateTime oldestStartDate = monthProvider!.monthLocalDataModel
//           .map(
//             (e) => DateFormat("dd-MM-yyyy").parse(
//               DateFormat("dd-MM-yyyy").format(
//                 Utils.formattedDate(e.monthStartDate!),
//               ),
//             ),
//           )
//           .reduce((a, b) => a.isBefore(b) ? a : b);
//
//       List<DayHistoryModel> data = monthProvider!.decodedDataAll();
//
//       bool isCurrentDay = date.year == nowUtc.year && date.month == nowUtc.month && date.day == nowUtc.day;
//
//       if (data.isEmpty) {
//         if (isCurrentDay) {
//           return _buildCurrentWorkoutDay(date);
//         } else if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
//           return _buildCustomDayCircle(date, Colors.blue);
//         }
//       }
//
//       DateTime futureDay = DateTime(nowUtc.year, nowUtc.month, nowUtc.day).add(Duration(days: 1));
//
//       if (date.isBefore(futureDay)) {
//         if (monthProvider!.dayStatusList.isNotEmpty) {
//           for (var day in monthProvider!.dayStatusList) {
//             final workoutDate = day.date;
//             DateTime localTime = Utils.formattedDate("$workoutDate");
//             if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
//               if (day.status == Status.completed) {
//                 return _buildCustomDayCircle(date, AppColors.primaryColor);
//               } else if (day.status == Status.skipped) {
//                 return _buildCustomDayCircle(date, Colors.blue);
//               }
//             }
//           }
//         }
//
//         for (var day in data) {
//           final workoutDate = day.endTime!;
//
//           DateTime localTime = Utils.formattedDate("$workoutDate");
//
//           if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
//             if (day.status == Status.completed) {
//               return _buildCustomDayCircle(date, AppColors.primaryColor);
//             } else if (day.status == Status.skipped) {
//               return _buildCustomDayCircle(date, Colors.blue);
//             }
//           }
//         }
//       }
//
//       if (isCurrentDay) {
//         for (var day in data) {
//           final workoutDate = day.endTime!;
//           DateTime localTime = Utils.formattedDate("$workoutDate");
//           if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
//             if (day.status == Status.completed) {
//               return _buildCustomDayCircle(date, AppColors.primaryColor);
//             } else if (day.status == Status.skipped) {
//               return _buildCustomDayCircle(date, Colors.blue);
//             }
//           }
//           return _buildCurrentWorkoutDay(date);
//         }
//       }
//       if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
//         if (DateTime(futureDay.year, futureDay.month, futureDay.day) != DateTime(date.year, date.month, date.day)) {
//           return _buildCustomDayCircle(date, Colors.blue);
//         }
//       }
//     } else {
//       final nowUtc = DateTime.now();
//       bool isCurrentDay = date.year == nowUtc.year && date.month == nowUtc.month && date.day == nowUtc.day;
//       if (isCurrentDay) {
//         return _buildCurrentWorkoutDay(date);
//       } else {
//         return _buildNormalDay(date);
//       }
//     }
//
//     return null;
//   }
//
//   Widget _buildNormalDay(DateTime date) {
//     return Container(
//       alignment: Alignment.center,
//       padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
//       child: Text(
//         '${date.day}',
//         style: const TextStyle(
//           fontSize: 14.0,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomDayCircle(DateTime date, Color circleColor) {
//     return Container(
//       alignment: Alignment.center,
//       width: 28.0,
//       height: 28.0,
//       margin: const EdgeInsets.only(bottom: 6),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: circleColor,
//       ),
//       child: Text(
//         '${date.day}',
//         style: const TextStyle(
//           fontSize: 14.0,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentWorkoutDay(DateTime date) {
//     return Container(
//       alignment: Alignment.center,
//       width: 28.0,
//       height: 28.0,
//       margin: const EdgeInsets.only(bottom: 6),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white,
//         border: Border.all(color: AppColors.primaryColor),
//       ),
//       child: Text(
//         '${date.day}', // Display the day number
//         style: const TextStyle(
//           fontSize: 14.0,
//           color: AppColors.primaryColor,
//         ),
//       ),
//     );
//   }
// }

import 'package:bbb/components/custom_table_calender.dart';
import 'package:bbb/models/MonthResponseModel/day_history_model.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  UserDataProvider? userData;
  DataProvider? dataProvider;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(
      context,
      listen: false,
    );

    userData = Provider.of<UserDataProvider>(
      context,
      listen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(65, 15, 65, 10),
            child: Text(
              'Mark a day a complete every day to keep the perfect flame streak going.',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: ScreenUtil.verticalScale(2.2),
                fontWeight: FontWeight.normal,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const CustomCalendarWidget(),
        ],
      ),
    );
  }
}

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({super.key});

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  MonthProvider? monthProvider;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //     padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
    // child: Card(
    // color: Colors.grey.shade50,
    // elevation: 4,
    // shadowColor: Colors.black.withValues(alpha: 0.4),
    // shape: RoundedRectangleBorder(
    // borderRadius: BorderRadius.circular(10.0),
    // ),
    // child: Padding(
    // padding: const EdgeInsets.symmetric(vertical: 8.0),
    // child: SingleChildScrollView(
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: CCTableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        rowHeight: ScreenUtil.verticalScale(5),
        daysOfWeekHeight: ScreenUtil.verticalScale(3),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        headerStyle: HeaderStyle(
            headerPadding: const EdgeInsets.only(bottom: 10),
            formatButtonVisible: false,
            titleCentered: false,
            leftChevronIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.primaryColor),
            rightChevronIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppColors.primaryColor),
            titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
            titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            decoration: BoxDecoration()),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(fontSize: 14.0),
          weekendTextStyle: TextStyle(fontSize: 14.0),
          outsideTextStyle: TextStyle(fontSize: 14.0, color: Colors.grey.shade500),
        ),
        onRangeSelected: (start, end, focusedDay) {},
        onDaySelected: null,
        calendarBuilders: CalendarBuilders(
          todayBuilder: (context, day, date) {
            return _buildDayState(date);
          },
          outsideBuilder: (context, day, date) {
            return _buildDayState(day);
          },
          defaultBuilder: (context, date, _) {
            return _buildDayState(date);
          },
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, int>? findDateIndex(DateTime targetDate, List<List<DayHistoryModel>> rangeList) {
    for (int outerIndex = 0; outerIndex < rangeList.length; outerIndex++) {
      for (int innerIndex = 0; innerIndex < rangeList[outerIndex].length; innerIndex++) {
        DateTime date = rangeList[outerIndex][innerIndex].endTime ?? rangeList[outerIndex][innerIndex].startTime!;
        if (date.year == targetDate.year && date.month == targetDate.month && date.day == targetDate.day) {
          return {
            'outerIndex': outerIndex,
            'innerIndex': innerIndex,
          };
        }
      }
    }
    return null;
  }

  List<List<DayHistoryModel>> groupCompletedByConsecutiveDates(List<DayHistoryModel> dataList) {
    List<DayHistoryModel> completedList = dataList.where((e) => e.status == Status.completed).toList();
    completedList.sort((a, b) {
      final aDate = a.endTime ?? a.startTime!;
      final bDate = b.endTime ?? b.startTime!;
      return DateTime(aDate.year, aDate.month, aDate.day).compareTo(DateTime(bDate.year, bDate.month, bDate.day));
    });

    List<List<DayHistoryModel>> grouped = [];
    List<DayHistoryModel> currentGroup = [];

    for (int i = 0; i < completedList.length; i++) {
      final current = completedList[i];
      final currentDate = current.endTime ?? current.startTime!;
      final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (currentGroup.isEmpty) {
        currentGroup.add(current);
      } else {
        final lastDate = currentGroup.last.endTime ?? currentGroup.last.startTime!;
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

        if (currentDay.difference(lastDay).inDays == 1) {
          currentGroup.add(current);
        } else {
          grouped.add(List<DayHistoryModel>.from(currentGroup));
          currentGroup = [current];
        }
      }
    }

    if (currentGroup.isNotEmpty) {
      grouped.add(currentGroup);
    }

    return grouped;
  }

  Widget? _buildDayState(DateTime date) {
    final nowUtc = DateTime.now();

    if (monthProvider!.monthLocalDataModel.isNotEmpty) {
      DateTime oldestStartDate = monthProvider!.monthLocalDataModel.map(
        (e) {
          return DateFormat("dd-MM-yyyy").parse(
            DateFormat("dd-MM-yyyy").format(
              Utils.formattedDate(e.monthStartDate!),
            ),
          );
        },
      ).reduce((a, b) => a.isBefore(b) ? a : b);
      List<DayHistoryModel> data = monthProvider!.decodedDataAll();
      final data11 = groupCompletedByConsecutiveDates(data);
      bool isCurrentDay = date.year == nowUtc.year && date.month == nowUtc.month && date.day == nowUtc.day;

      if (data11.isEmpty) {
        if (isCurrentDay) {
          return _buildCurrentWorkoutDay(date);
        } else if (oldestStartDate.isBefore(date) && nowUtc.isAfter(date)) {
          return _buildCustomDayCircle(date, Colors.blue);
        }
      }

      DateTime futureDay = DateTime(nowUtc.year, nowUtc.month, nowUtc.day).add(Duration(days: 1));

      if (date.isBefore(futureDay)) {
        // if (monthProvider!.dayStatusList.isNotEmpty) {
        //   for (var day in monthProvider!.dayStatusList) {
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
          if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
            final isCircle = data.any((d) => d.status == Status.skipped && _isSameDate(d.endTime ?? d.startTime!, date));
            final isRange = data11.any((d) => d.any((element) => _isSameDate(element.endTime ?? element.startTime!, date)));
            if (isCircle) {
              return Center(
                child: Container(
                  width: ScreenUtil.verticalScale(3.2),
                  height: ScreenUtil.verticalScale(3.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            } else if (isRange) {
              final size = MediaQuery.of(context).size.width;

              final data = findDateIndex(date, data11);
              return Stack(
                children: [
                  if (data11[data!["outerIndex"]!].length > 1 && data["innerIndex"] == 0)
                    Positioned(
                      top: ScreenUtil.verticalScale(0.7),
                      left: ScreenUtil.horizontalScale(size > 600 ? 4.5 : 3.5),
                      right: 0,
                      child: Container(
                        height: ScreenUtil.verticalScale(3.2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            right:
                                (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]) ? Radius.circular(20) : Radius.circular(0),
                            left: (data["innerIndex"] == 0) ? Radius.circular(20) : Radius.circular(0),
                          ),
                          color: AppColors.backOffSetColor,
                        ),
                      ),
                    ),
                  if (data11[data["outerIndex"]!].length > 1 && data11[data["outerIndex"]!].length - 1 == data["innerIndex"])
                    Positioned(
                      top: ScreenUtil.verticalScale(0.7),
                      right: ScreenUtil.horizontalScale(size > 600 ? 4.5 : 3.5),
                      left: 0,
                      child: Container(
                        height: ScreenUtil.verticalScale(3.2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            right:
                                (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]) ? Radius.circular(20) : Radius.circular(0),
                            left: (data["innerIndex"] == 0) ? Radius.circular(20) : Radius.circular(0),
                          ),
                          color: AppColors.backOffSetColor,
                        ),
                      ),
                    ),
                  Container(
                    height: ScreenUtil.verticalScale(3.2),
                    margin: EdgeInsets.symmetric(vertical: ScreenUtil.verticalScale(0.7)),
                    decoration: BoxDecoration(
                      color: ((data["innerIndex"] == 0) || (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]))
                          ? Colors.transparent
                          : AppColors.backOffSetColor,
                      borderRadius: BorderRadius.horizontal(
                        right: (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]) ? Radius.circular(20) : Radius.circular(0),
                        left: (data["innerIndex"] == 0) ? Radius.circular(20) : Radius.circular(0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          color: ((data["innerIndex"] == 0) || (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]))
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                              color: ((data["innerIndex"] == 0) || (data11[data["outerIndex"]!].length - 1 == data["innerIndex"]))
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text('${date.day}', style: TextStyle(color: Colors.black, fontSize: 14)),
              );
            }
          }
        }
      }

      if (isCurrentDay) {
        for (var day in data) {
          final workoutDate = day.endTime!;
          DateTime localTime = Utils.formattedDate("$workoutDate");
          if ((localTime.day == date.day && localTime.month == date.month && localTime.year == date.year)) {
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
        if (DateTime(futureDay.year, futureDay.month, futureDay.day) != DateTime(date.year, date.month, date.day)) {
          return _buildCustomDayCircle(date, Colors.blue);
        }
      }
    } else {
      final nowUtc = DateTime.now();
      bool isCurrentDay = date.year == nowUtc.year && date.month == nowUtc.month && date.day == nowUtc.day;
      if (isCurrentDay) {
        return _buildCurrentWorkoutDay(date);
      } else {
        return _buildNormalDay(date);
      }
    }

    return null;
  }

  Widget _buildNormalDay(DateTime date) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(ScreenUtil.horizontalScale(1)),
      child: Text(
        '${date.day}',
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCustomDayCircle(DateTime date, Color circleColor) {
    return Container(
      alignment: Alignment.center,
      width: ScreenUtil.verticalScale(3.2),
      height: ScreenUtil.verticalScale(3.2),
      margin: const EdgeInsets.only(bottom: 6),
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
    );
  }

  Widget _buildCurrentWorkoutDay(DateTime date) {
    return Container(
      alignment: Alignment.center,
      width: ScreenUtil.verticalScale(3.2),
      height: ScreenUtil.verticalScale(3.2),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Text(
        '${date.day}',
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

/// OLD TABLE CALENDER

// child: TableCalendar(
//   startingDayOfWeek: StartingDayOfWeek.monday,
//   availableGestures: AvailableGestures.horizontalSwipe,
//   rowHeight: 40.0,
//   daysOfWeekHeight: 20.0,
//   firstDay: DateTime.utc(2020, 1, 1),
//   lastDay: DateTime.utc(2030, 12, 31),
//   focusedDay: _focusedDay,
//   selectedDayPredicate: (day) {
//     return isSameDay(_selectedDay, day);
//   },
//   headerStyle: HeaderStyle(
//     headerPadding: const EdgeInsets.only(bottom: 10),
//     formatButtonVisible: false,
//     titleCentered: true,
//     leftChevronIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.primaryColor),
//     rightChevronIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: AppColors.primaryColor),
//     titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
//     titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
//   ),
//   calendarStyle: const CalendarStyle(
//     defaultTextStyle: TextStyle(fontSize: 12.0),
//     weekendTextStyle: TextStyle(fontSize: 12.0),
//     outsideTextStyle: TextStyle(fontSize: 10.0),
//   ),
//   calendarBuilders: CalendarBuilders(
//     todayBuilder: (context, day, focusedDay) => _buildDayState(day),
//     outsideBuilder: (context, date, _) {
//       return _buildDayState(date);
//     },
//     defaultBuilder: (context, date, _) {
//       return _buildDayState(date);
//     },
//   ),
// ),
