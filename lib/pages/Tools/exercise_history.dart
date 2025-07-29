import 'dart:convert';
import 'dart:developer';

import 'package:bbb/custom/expansion_panel.dart';
import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:intl/intl.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';

import '../../utils/screen_util.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({super.key});
  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  List<FlSpot> chartData = [];
  List<String> dateLabels = [];
  int maxWeight = 0;
  int totalWeight = 0;
  int selectedFilterIndex = 0;
  List<ExerciseHistoryDataModel> historyDataModel = [];
  MonthProvider? monthProvider;
  bool isLoading = true;

  @override
  void initState() {
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await fetchData().then((value) => _loadValue()));
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      await monthProvider?.fetchExerciseHistroy();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadValue() async {
    await monthProvider?.fetchExerciseHistroy();
    monthProvider?.exerciseHistroy.sort((a, b) {
      if (a.date != null && b.date != null) {
        return DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!));
      }
      return 0;
    });
    Map<String, Map<String, double>> groupedData = {};
    DateTime today = DateTime.now();
    DateTime startDate = selectedFilterIndex == 3
        ? DateTime.parse(monthProvider!.exerciseHistroy.first.date!)
        : today.subtract(Duration(
            days: selectedFilterIndex == 0
                ? 27
                : selectedFilterIndex == 1
                    ? 82
                    : 363));

    historyDataModel = monthProvider!.exerciseHistroy.where((item) {
      DateTime itemDate = DateTime.parse(item.date ?? "${DateTime.now()}");
      return itemDate.isAfter(
              DateTime(startDate.year, startDate.month, startDate.day)) &&
          itemDate.isBefore(today);
    }).toList();

    historyDataModel.sort((a, b) =>
        DateTime.parse(a.date ?? "").compareTo(DateTime.parse(b.date ?? "")));

    setState(() {});
    if (historyDataModel.isEmpty) {
      isLoading = false;
      setState(() {});
      return;
    }
    totalWeight = 0;
    for (final item in historyDataModel) {
      final weight = double.tryParse(item.weight ?? '0') ?? 0;
      final reps = int.tryParse(item.reps ?? '0') ?? 0;
      // final effort = int.tryParse(item.effort ?? '0') ?? 0;

      final multiplier = reps /*+ (effort == 100 ? 0 : effort)*/;
      final setTotal = weight * multiplier;

      totalWeight += (setTotal.toInt());
    }

    final Map<String, ExerciseHistoryDataModel> highestByDate = {};

    for (final item in historyDataModel) {
      final dateStr = item.date;
      final date = DateTime.parse("${dateStr ?? DateTime.now()}");
      final dayKey = DateFormat('yyyy-MM-dd').format(date);

      final reps = int.tryParse(item.reps ?? "0") ?? 0;
      final weight = double.tryParse(item.weight ?? "0") ?? 0;
      final load = reps * weight;

      if (!highestByDate.containsKey(dayKey) ||
          (load) >
              (int.tryParse(highestByDate[dayKey]!.reps ?? "0") ?? 0) *
                  (double.tryParse(highestByDate[dayKey]!.weight ?? "0") ??
                      0)) {
        highestByDate[dayKey] = item;
      }
    }

    final data1 = highestByDate.values.toList();
    for (var data in data1) {
      double weight = double.tryParse(data.weight.toString()) ?? 0.0;
      int reps = int.tryParse(data.reps.toString()) ?? 0;
      int repsInReverse = int.tryParse(data.effort.toString()) ?? 0;
      DateTime date = DateTime.parse(data.date!);
      String formattedDate = DateFormat('dd/MM').format(date);
      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = {'oneRmSession': 0.0};
      }
      double rir = (repsInReverse == 100 ? 0 : repsInReverse.toDouble());
      // groupedData[formattedDate]!['totalWeight'] = groupedData[formattedDate]!['totalWeight']! + weight;
      // groupedData[formattedDate]!['totalReps'] = groupedData[formattedDate]!['totalReps']! + reps.toDouble();
      // groupedData[formattedDate]!['totalRIR'] =
      //     groupedData[formattedDate]!['totalRIR']! + (repsInReverse == 100 ? 0 : repsInReverse.toDouble());

      // double oneRmSession = weight * (1 + (reps + rir) / 30);

      double oneRmSession =
          weight * ((0.025 * (reps + rir)) + 1) /*+ (reps + rir) / 30)*/;
      groupedData[formattedDate]!['oneRmSession'] =
          groupedData[formattedDate]!['oneRmSession']! + oneRmSession;
      groupedData.removeWhere((key, value) =>
          (value["oneRmSession"] == 0.0 || value["oneRmSession"] == 1.0));
    }

    chartData = [];
    dateLabels = [];
    int index = 0;
    groupedData.forEach((date, totals) {
      // double totalWeightForDate = totals['totalWeight']!;
      // double totalReps = totals['totalReps']!;
      // double totalRIR = totals['totalRIR']!;
      // double oneRmSession = totalWeightForDate * (1 + (totalReps + totalRIR) / 30);
      double oneRmSession = totals['oneRmSession']!;
      chartData.add(FlSpot(
          index.toDouble(), double.parse(oneRmSession.toStringAsFixed(2))));
      dateLabels.add(date);
      index++;
    });
    // totalWeight = chartData.fold(0, (sum, spot) => sum + spot.y.toInt());
    maxWeight =
        chartData.fold(0, (max, spot) => spot.y > max ? spot.y.toInt() : max);

    maxWeight = roundToNiceMultiple(maxWeight);

    isLoading = false;
    filterData();
    setState(() {});
  }

  int roundToNiceMultiple(int maxWeight) {
    int value = maxWeight;

    while (true) {
      if (value % 3 == 0 && (value ~/ 3) % 5 == 0) {
        return value;
      }
      value++;
    }
  }

  Future<void> _onFilterSelected(int index) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      selectedFilterIndex = index;
      setState(() {});
      await _loadValue();
    });
  }

  var groupedData = <String, List<ExerciseHistoryDataModel>>{};

  List<Map<String, dynamic>> finalData = [];

  // filterData() {
  //   finalData = [];
  //   groupedData = <String, List<ExerciseHistoryDataModel>>{};
  //   for (var item in historyDataModel) {
  //     final date = DateFormat("dd/MM/yyyy").format(DateTime.parse(item.date!));
  //     if (groupedData.containsKey(date)) {
  //       groupedData[date]!.add(item);
  //     } else {
  //       groupedData[date] = [item];
  //     }
  //   }
  //   finalData = groupedData.entries.map((entry) {
  //     return {
  //       "date": entry.key,
  //       "data": entry.value,
  //     };
  //   }).toList();
  //
  //   finalData.sort((b, a) => DateFormat("dd/MM/yyyy").parse(a["date"]).compareTo(DateFormat("dd/MM/yyyy").parse(b["date"])));
  //   setState(() {});
  // }

  void filterData() {
    finalData = [];
    Map<String, Map<String, List<ExerciseHistoryDataModel>>>
        monthlyGroupedData = {};

    for (var item in historyDataModel) {
      final parsedDate = DateTime.tryParse(item.date ?? '');
      if (parsedDate == null) continue;

      final monthKey = DateFormat("MMM, yyyy").format(parsedDate);
      final dayKey = DateFormat("dd/MM/yyyy").format(parsedDate);

      if (!monthlyGroupedData.containsKey(monthKey)) {
        monthlyGroupedData[monthKey] = {};
      }

      if (!monthlyGroupedData[monthKey]!.containsKey(dayKey)) {
        monthlyGroupedData[monthKey]![dayKey] = [];
      }

      monthlyGroupedData[monthKey]![dayKey]!.add(item);
    }

    finalData = monthlyGroupedData.entries.map((monthEntry) {
      final dayDataList = monthEntry.value.entries.map((dayEntry) {
        return {
          "date": dayEntry.key,
          "data": dayEntry.value,
        };
      }).toList();

      dayDataList.sort((b, a) => DateFormat("dd/MM/yyyy")
          .parse(a["date"].toString())
          .compareTo(DateFormat("dd/MM/yyyy").parse(b["date"].toString())));

      return {
        "title": monthEntry.key,
        "data": dayDataList,
      };
    }).toList();

    finalData.sort((b, a) => DateFormat("MMM, yyyy")
        .parse(a["title"])
        .compareTo(DateFormat("MMM, yyyy").parse(b["title"])));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: SafeArea(
                    child: Container(
                      margin:
                          EdgeInsets.only(left: ScreenUtil.horizontalScale(4)),
                      decoration: const BoxDecoration(
                          color: Color(0XFFd18a9b), shape: BoxShape.circle),
                      child: SizedBox(
                        width: ScreenUtil.verticalScale(4.65),
                        height: ScreenUtil.verticalScale(4.65),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.white,
                            size: ScreenUtil.verticalScale(4),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                      child: Text(
                        "History",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil.horizontalScale(10)),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: commonPadding(),
            child: Center(
              child: Text(
                monthProvider?.selectedExercise?.name ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.labelLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            )
          else ...[
            if (historyDataModel.isEmpty)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil.horizontalScale(8)),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "No data available. Once you finish & save your first exercise, this page will show your history.",
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.labelLarge?.color),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: commonPadding(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1-Rep Max History',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.labelLarge?.color,
                      ),
                    ),
                    Row(
                      children: [
                        FilterButton(
                          label: "1M",
                          isSelected: selectedFilterIndex == 0,
                          onPressed: () => WidgetsBinding.instance
                              .addPostFrameCallback(
                                  (timeStamp) => _onFilterSelected(0)),
                        ),
                        const SizedBox(width: 6),
                        FilterButton(
                          label: "3M",
                          isSelected: selectedFilterIndex == 1,
                          onPressed: () => WidgetsBinding.instance
                              .addPostFrameCallback(
                                  (timeStamp) => _onFilterSelected(1)),
                        ),
                        const SizedBox(width: 6),
                        FilterButton(
                          label: "1Y",
                          isSelected: selectedFilterIndex == 2,
                          onPressed: () => WidgetsBinding.instance
                              .addPostFrameCallback(
                                  (timeStamp) => _onFilterSelected(2)),
                        ),
                        const SizedBox(width: 6),
                        FilterButton(
                          label: "All",
                          isSelected: selectedFilterIndex == 3,
                          onPressed: () => WidgetsBinding.instance
                              .addPostFrameCallback(
                                  (timeStamp) => _onFilterSelected(3)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            const SizedBox(height: 16),
            historyDataModel.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: commonPadding(),
                    child: Builder(
                      builder: (context) {
                        return maxWeight != 0
                            ? SizedBox(
                                height: ScreenUtil.verticalScale(18),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawHorizontalLine: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            (maxWeight / 5).ceilToDouble(),
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.color,
                                                strokeWidth: 1,
                                                dashArray: [5, 5]),
                                        getDrawingVerticalLine: (value) =>
                                            FlLine(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.color,
                                                strokeWidth: 1,
                                                dashArray: [5, 5]),
                                        // getDrawingHorizontalLine: (value) {
                                        //   return FlLine(
                                        //       color:
                                        //           Theme.of(context).canvasColor,
                                        //       strokeWidth: 0.5,
                                        //       dashArray: [5, 5]);
                                        // },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 45,
                                            interval: maxWeight / 3,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toStringAsFixed(0),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge
                                                      ?.color,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 20,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();
                                              if (index >= 0 &&
                                                  index < dateLabels.length) {
                                                return Text(
                                                  dateLabels[index],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.color,
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.symmetric(
                                          horizontal: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .color!,
                                          ),
                                          vertical: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .color!,
                                          ),
                                        ),
                                      ),
                                      minY: 0,
                                      maxY: maxWeight.toDouble(),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: chartData,
                                          isCurved: false,
                                          barWidth: .5,
                                          color: AppColors.primaryColor,
                                        ),
                                      ],
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          tooltipRoundedRadius: 8,
                                          getTooltipColor: (_) =>
                                              Colors.black87,
                                          tooltipMargin:
                                              150, // Distance above the point
                                          fitInsideHorizontally: true,
                                          fitInsideVertically: true,
                                          showOnTopOfTheChartBoxArea: true,
                                          getTooltipItems: (touchedSpots) {
                                            return touchedSpots
                                                .map((LineBarSpot touchedSpot) {
                                              final value = touchedSpot.y
                                                  .toStringAsFixed(0);
                                              return LineTooltipItem(
                                                '$value lbs',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList();
                                          },
                                        ),
                                        handleBuiltInTouches: true,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
                  ),
            const SizedBox(height: 25),
            historyDataModel.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: commonPadding(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalWeight lbs',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Lifted',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$maxWeight lbs',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '1 Rep Max',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 16),
            if (historyDataModel.isEmpty || finalData.isEmpty)
              const SizedBox.shrink()
            else
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: ScreenUtil.verticalScale(1.5)),
                  color: Theme.of(context).cardColor,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 7),
                    itemCount: finalData.length,
                    padding: EdgeInsets.zero,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, monthIndex) {
                      final monthGroup = finalData[monthIndex];
                      final String title = monthGroup["title"];
                      final List dayGroups = monthGroup["data"];
                      return buildExpansionTileItem(
                          monthGroup, title, dayGroups, monthIndex);
                    },
                  ),
                ),
              ),
          ]
        ],
      ),
    );
  }

  commonPadding() => const EdgeInsets.fromLTRB(16, 0, 16, 0);
  final Map<int, bool> _expandedStates = {0: true};

  Widget buildExpansionTileItem(monthGroup, title, dayGroups, index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(2)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionPanelList(
          dividerColor: Colors.transparent,
          sidePadding: false,
          animationDuration: Duration(milliseconds: 400),
          expandIconColor: Colors.grey.shade400,
          materialGapSize: 10,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              _expandedStates[index] = isExpanded;
            });
          },
          elevation: 0,
          children: [
            ExpansionPanel(
              isExpanded: _expandedStates[index] ?? false,
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: ScreenUtil.horizontalScale(4.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          border: DashedBorder(
                            spaceLength: 8,
                            strokeCap: StrokeCap.square,
                            dashLength: 1,
                            top: BorderSide(
                                color: Colors.grey.shade400, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                );
              },
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: EdgeInsets.only(
                    top: 15, right: ScreenUtil.verticalScale(1.25)),
                child: Column(
                  children: [
                    ...dayGroups.map<Widget>(
                      (dayGroup) {
                        final String date = dayGroup["date"];
                        final List exercises = dayGroup["data"];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  DateFormat("MMM dd, yyyy").format(
                                    DateFormat("dd/MM/yyyy").parse(date),
                                  ),
                                  style: TextStyle(
                                    fontSize: ScreenUtil.horizontalScale(3.5),
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.color,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ...List.generate(
                                      exercises.length,
                                      (index) {
                                        final data = exercises[index]
                                            as ExerciseHistoryDataModel;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Builder(builder: (context) {
                                            int result = int.parse(
                                                    data.reps ?? "0") *
                                                (int.parse(data.weight ?? "0"));

                                            return RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        'Set ${index + 1}: ${data.reps} Reps',
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil
                                                            .horizontalScale(
                                                                3.5),
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .labelLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  TextSpan(
                                                    text: ' × ',
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .horizontalScale(3),
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.color,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '${data.weight}lbs',
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil
                                                            .horizontalScale(
                                                                3.5),
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .labelLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '($result) @ ${data.load}% load',
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .horizontalScale(3.5),
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.color,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' | RIR ${data.effort == "100" ? "0" : data.effort}',
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil
                                                          .horizontalScale(3.5),
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

    // return Theme(
    //   data: Theme.of(context).copyWith(
    //     dividerColor: Colors.transparent,
    //     splashColor: Colors.transparent,
    //     highlightColor: Colors.transparent,
    //   ),
    //   child: ExpansionTile(
    //     tilePadding: EdgeInsets.symmetric(
    //       horizontal: ScreenUtil.horizontalScale(5),
    //       vertical: ScreenUtil.verticalScale(0.5),
    //     ),
    //     title: Row(
    //       children: [
    //         Expanded(
    //           child: Text(
    //             title,
    //             style: TextStyle(
    //               color: AppColors.primaryColor,
    //               fontSize: ScreenUtil.verticalScale(2),
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     initiallyExpanded: _expandedStates[index] ?? false,
    //     onExpansionChanged: (bool value) {
    //       setState(() {
    //         _expandedStates[index] = value;
    //       });
    //
    //       // if (value && index == dataProvider!.faQsModel.length - 1) {
    //       //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //       //     Future.delayed(const Duration(milliseconds: 200), () {
    //       //       if (_scrollController.hasClients) {
    //       //         _scrollController.animateTo(
    //       //           _scrollController.position.maxScrollExtent,
    //       //           duration: const Duration(milliseconds: 100),
    //       //           curve: Curves.easeOut,
    //       //         );
    //       //       }
    //       //     });
    //       //   });
    //       // }
    //       if (value) {
    //         WidgetsBinding.instance.addPostFrameCallback((_) {
    //           // _scrollToTile(index);
    //         });
    //       }
    //     },
    //     backgroundColor: Colors.grey.withValues(alpha: 0.05),
    //     collapsedBackgroundColor: Colors.grey.withValues(alpha: 0.05),
    //     childrenPadding: EdgeInsets.zero,
    //     clipBehavior: Clip.none,
    //     iconColor: AppColors.primaryColor,
    //     collapsedIconColor: Colors.white,
    //     trailing: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         InkWell(
    //           child: Container(
    //             padding: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
    //             decoration: BoxDecoration(
    //               shape: BoxShape.circle,
    //               border: Border.all(
    //                 color: AppColors.primaryColor,
    //                 width: 2,
    //               ),
    //               color: AppColors.primaryColor,
    //             ),
    //             child: Icon(
    //               _expandedStates[index] == true
    //                   ? Icons.keyboard_arrow_up_outlined
    //                   : Icons.keyboard_arrow_down_outlined,
    //               color: Colors.white,
    //               size: ScreenUtil.verticalScale(3),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     children: [
    //       Padding(
    //         padding: EdgeInsets.only(
    //             left: ScreenUtil.verticalScale(0.5),
    //             right: ScreenUtil.verticalScale(1)),
    //         child: Column(
    //           children: [
    //             ...dayGroups.map<Widget>((dayGroup) {
    //               final String date = dayGroup["date"];
    //               final List exercises = dayGroup["data"];
    //               return Padding(
    //                 padding:
    //                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16)
    //                         .copyWith(bottom: 25),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     SizedBox(
    //                       width: 100,
    //                       child: Text(
    //                         DateFormat("MMM dd, yyyy").format(
    //                           DateFormat("dd/MM/yyyy").parse(date),
    //                         ),
    //                         style: const TextStyle(
    //                           fontSize: 14,
    //                           fontWeight: FontWeight.normal,
    //                           color: Colors.black,
    //                         ),
    //                       ),
    //                     ),
    //                     Align(
    //                       alignment: Alignment.centerRight,
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.end,
    //                         children: [
    //                           ...exercises.map<Widget>(
    //                             (e) {
    //                               final data = e as ExerciseHistoryDataModel;
    //                               return Padding(
    //                                 padding: const EdgeInsets.only(bottom: 10),
    //                                 child: RichText(
    //                                   text: TextSpan(
    //                                     children: [
    //                                       TextSpan(
    //                                         text: '${data.reps}',
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: Colors.black,
    //                                             fontWeight: FontWeight.normal),
    //                                       ),
    //                                       const TextSpan(
    //                                         text: ' × ',
    //                                         style: TextStyle(
    //                                             fontSize: 14,
    //                                             color: Colors.black),
    //                                       ),
    //                                       TextSpan(
    //                                         text: '${data.weight}lbs',
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: Colors.black,
    //                                             fontWeight: FontWeight.bold),
    //                                       ),
    //                                       TextSpan(
    //                                         text: ' @ ${data.load}%',
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: Colors.black),
    //                                       ),
    //                                       TextSpan(
    //                                         text:
    //                                             ' | RIR ${data.effort == "100" ? "0" : data.effort}',
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: Colors.black),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               );
    //                             },
    //                           )
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             })
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 8.5;
    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? AppColors.primaryColor : Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.labelLarge?.color,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
