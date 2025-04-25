import 'package:bbb/models/SyncDataResponseModel/exercise_history_data_model.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => await fetchData().then((value) => _loadValue()));
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
    Map<String, Map<String, double>> groupedData = {};
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(Duration(
        days: selectedFilterIndex == 0
            ? 27
            : selectedFilterIndex == 1
                ? 83
                : 364));

    historyDataModel = monthProvider!.exerciseHistroy.where((item) {
      DateTime itemDate = DateTime.parse(item.date ?? "${DateTime.now()}");
      return itemDate.isAfter(startDate) && itemDate.isBefore(today);
    }).toList();

    historyDataModel.sort((a, b) => DateTime.parse(a.date ?? "").compareTo(DateTime.parse(b.date ?? "")));

    setState(() {});
    if (historyDataModel.isEmpty) {
      isLoading = false;
      setState(() {});
      return;
    }

    for (var data in historyDataModel) {
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
      double oneRmSession = weight * (1 + (reps + rir) / 30);
      groupedData[formattedDate]!['oneRmSession'] = groupedData[formattedDate]!['oneRmSession']! + oneRmSession;
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
      chartData.add(FlSpot(index.toDouble(), double.parse(oneRmSession.toStringAsFixed(2))));
      dateLabels.add(date);
      index++;
    });
    totalWeight = chartData.fold(0, (sum, spot) => sum + spot.y.toInt());
    maxWeight = chartData.fold(0, (max, spot) => spot.y > max ? spot.y.toInt() : max);
    isLoading = false;
    filterData();
    setState(() {});
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
  filterData() {
    finalData = [];
    groupedData = <String, List<ExerciseHistoryDataModel>>{};
    for (var item in historyDataModel) {
      final date = DateFormat("dd/MM/yyyy").format(DateTime.parse(item.date!));
      if (groupedData.containsKey(date)) {
        groupedData[date]!.add(item);
      } else {
        groupedData[date] = [item];
      }
    }
    finalData = groupedData.entries.map((entry) {
      return {
        "date": entry.key,
        "data": entry.value,
      };
    }).toList();

    finalData.sort((b, a) => DateFormat("dd/MM/yyyy").parse(a["date"]).compareTo(DateFormat("dd/MM/yyyy").parse(b["date"])));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
                      margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(4)),
                      decoration: const BoxDecoration(color: Color(0XFFd18a9b), shape: BoxShape.circle),
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
                style: const TextStyle(
                  fontSize: 20,
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
              Padding(
                padding: commonPadding(),
                child: const Center(
                  child: Text(
                    "No data available.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Padding(
                padding: commonPadding(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '1-Rep Max History',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        FilterButton(
                          label: "1M",
                          isSelected: selectedFilterIndex == 0,
                          onPressed: () => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _onFilterSelected(0)),
                        ),
                        const SizedBox(width: 5),
                        FilterButton(
                          label: "3M",
                          isSelected: selectedFilterIndex == 1,
                          onPressed: () => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _onFilterSelected(1)),
                        ),
                        const SizedBox(width: 5),
                        FilterButton(
                          label: "1Y",
                          isSelected: selectedFilterIndex == 2,
                          onPressed: () => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _onFilterSelected(2)),
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
                    child: maxWeight != 0
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
                                    horizontalInterval: (maxWeight / 5).ceilToDouble(),
                                    getDrawingHorizontalLine: (value) {
                                      return const FlLine(color: Colors.grey, strokeWidth: 0.5, dashArray: [5, 5]);
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toString(),
                                            style: const TextStyle(fontSize: 10),
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
                                          if (index >= 0 && index < dateLabels.length) {
                                            return Text(
                                              dateLabels[index],
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    border: const Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      left: BorderSide.none,
                                      bottom: BorderSide(width: .5),
                                    ),
                                  ),
                                  minY: 0,
                                  maxY: (maxWeight * 1.5).ceilToDouble(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartData,
                                      isCurved: false,
                                      barWidth: .5,
                                      color: AppColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
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
                              style: const TextStyle(
                                fontSize: 16,
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
                              style: const TextStyle(
                                fontSize: 16,
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
            historyDataModel.isEmpty || finalData.isEmpty
                ? const SizedBox.shrink()
                : Expanded(
                    child: ListView.builder(
                      itemCount: finalData.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: .1),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        DateFormat("MMM dd, yyyy").format(DateFormat("dd/MM/yyyy").parse(finalData[index]["date"])),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(
                                          finalData[index]["data"].length,
                                          (index1) {
                                            ExerciseHistoryDataModel data = finalData[index]["data"][index1];
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Wrap(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '${data.reps}',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const TextSpan(
                                                          text: ' × ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '${data.weight}lbs',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' @ ${data.load}% ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '| RIR ${data.effort == "100" ? "0" : data.effort}',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ]
        ],
      ),
    );
  }

  commonPadding() => const EdgeInsets.fromLTRB(16, 0, 16, 0);
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
    double buttonWidth = MediaQuery.of(context).size.width / 7;
    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
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
