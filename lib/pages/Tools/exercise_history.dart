import 'package:bbb/providers/exercise_history_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
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
  late ExerciseHistoryProvider exerciseHistoryProvider;
  late UserDataProvider? userData;
  String exerciseName = '';
  int exerciseIndex = 0;
  List<dynamic> exerciseHistoryData = [];
  List<FlSpot> chartData = [];
  List<String> dateLabels = [];
  int maxWeight = 0;
  int totalWeight = 0;
  int selectedFilterIndex = 1;

  @override
  void initState() {
    super.initState();
    exerciseHistoryProvider = Provider.of(context,listen: false);
    exerciseHistoryProvider.getFilteredHistory();
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use ModalRoute and other context-dependent logic here
    if (ModalRoute.of(context)?.settings.arguments != null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      exerciseName = args['exerciseName'];
      exerciseIndex = args['exerciseIndex'];
    }
    userData = Provider.of<UserDataProvider>(context, listen: false);
    _loadValue();    
  }

  Future<void> _loadValue() async {
    exerciseHistoryData = await userData!.getExerciseData(exerciseName, selectedFilterIndex);
    Map<String, Map<String, double>> groupedData = {};
    for (var data in exerciseHistoryData) {
      double weight = double.tryParse(data['weight'].toString()) ?? 0.0;
      int reps = int.tryParse(data['reps'].toString()) ?? 0;
      int repsInReverse = int.tryParse(data['repsInReverse'].toString()) ?? 0;
      DateTime date = DateTime.parse(data['date']);
      String formattedDate = DateFormat('MM/dd').format(date);
      if (!groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate] = {
          'totalWeight': 0.0,
          'totalReps': 0.0,
          'totalRIR': 0.0,
        };
      }
      groupedData[formattedDate]!['totalWeight'] =
          groupedData[formattedDate]!['totalWeight']! + weight;
      groupedData[formattedDate]!['totalReps'] =
          groupedData[formattedDate]!['totalReps']! + reps.toDouble();
      groupedData[formattedDate]!['totalRIR'] =
          groupedData[formattedDate]!['totalRIR']! + repsInReverse.toDouble();
    }
    chartData = [];
    dateLabels = [];
    int index = 0;
    groupedData.forEach((date, totals) {
      double totalWeightForDate = totals['totalWeight']!;
      double totalReps = totals['totalReps']!;
      double totalRIR = totals['totalRIR']!;
      double oneRmSession =
          totalWeightForDate * (1 + (totalReps + totalRIR) / 30);
      chartData.add(FlSpot(index.toDouble(), oneRmSession));
      dateLabels.add(date);
      index++;
    });
    totalWeight = chartData.fold(0, (sum, spot) => sum + spot.y.toInt());
    maxWeight = chartData.fold(0, (max, spot) => spot.y > max ? spot.y.toInt() : max);
    setState(() {});
  }

  void _onFilterSelected(int index) {
    setState(() {
      selectedFilterIndex = index;
      debugPrint('Selected filter index: $selectedFilterIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Height of your custom AppBar
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Arrow Button
                // BackArrowWidget(
                //   onPress: () => Navigator.pop(context),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: SafeArea(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: ScreenUtil.horizontalScale(4),
                        ),
                        decoration:  const BoxDecoration(
                          color: Color(0XFFd18a9b), // Make sure color is correct
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: ScreenUtil.horizontalScale(10), // Size of the circle
                          height: ScreenUtil.horizontalScale(10),
                          child: IconButton(
                            padding: EdgeInsets.zero, // Removes the default padding
                            icon: Icon(
                              Icons.keyboard_arrow_left,
                              color: Colors.white,
                              size: ScreenUtil.verticalScale(4), // Adjust size using ScreenUtil
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      )),
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
      body: WorkoutHistoryScreen(exerciseName: exerciseName, dateLabels: dateLabels, chartData: chartData, exerciseHistoryData: exerciseHistoryData, totalWeight: totalWeight, maxWeight: maxWeight, onFilterSelected: _onFilterSelected,),
    );
  }
}


// ignore: must_be_immutable
class WorkoutHistoryScreen extends StatefulWidget {
  final String exerciseName;
  List<FlSpot> chartData = [];
  List<String> dateLabels = [];
  List<dynamic> exerciseHistoryData = [];
  int maxWeight = 0;
  int totalWeight = 0;
  final ValueChanged<int> onFilterSelected;
  WorkoutHistoryScreen({
    super.key,
    required this.exerciseName,
    required this.dateLabels, 
    required this.chartData,
    required this.exerciseHistoryData,
    required this.totalWeight,
    required this.maxWeight,
    required this.onFilterSelected,
  });
  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}
class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  int selectedIndex = 1;
  commonPadding(){
    return const EdgeInsets.fromLTRB(16, 0, 16, 0);
  }


  @override
  Widget build(BuildContext context) {
    Provider.of<UserDataProvider>(context);
    final exercise = Provider.of<ExerciseHistoryProvider>(context);
    
    debugPrint("this is history chart ${widget.chartData}");
    debugPrint("this is history chart ${widget.dateLabels}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: commonPadding(),
            child: Center(
              child: Text(
                widget.exerciseName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          widget.exerciseHistoryData.isEmpty ?           
          Padding(
            padding: commonPadding(),
            child: const Center(
              child: Text(
                "No data available.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ) :
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
                      isSelected: selectedIndex == 0,
                      onPressed: () {
                        setState(() {
                          selectedIndex = 0;
                          widget.onFilterSelected(0); // Notify the parent
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    FilterButton(
                      label: "3M",
                      isSelected: selectedIndex == 1,
                      onPressed: () {
                        setState(() {
                          selectedIndex = 1;
                          widget.onFilterSelected(1); // Notify the parent
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    FilterButton(
                      label: "1Y",
                      isSelected: selectedIndex == 2,
                      onPressed: () {
                        setState(() {
                          selectedIndex = 2;
                          widget.onFilterSelected(2); // Notify the parent
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          widget.exerciseHistoryData.isEmpty ? const SizedBox.shrink() :
          Padding(
            padding: commonPadding(),
            child: SizedBox(
              height: ScreenUtil.verticalScale(18),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: (widget.maxWeight / 5).ceilToDouble(),
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey, // Set color of horizontal lines
                        strokeWidth: 0.5, // Set thickness of lines
                        dashArray: [5, 5], // Optional: Dash pattern for lines
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // Add space for left titles
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toString(), // Customize the formatting as needed
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < widget.dateLabels.length) {
                            return Text(
                              widget.dateLabels[index],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide right titles
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide top titles
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
                  // minX: 1, // Shift X-axis starting point
                  // maxX: widget.chartData.isNotEmpty ? widget.chartData.length.toDouble() : 1.0, // Dynamic maxX
                  minY: 0, // Keep Y-axis starting at 0
                  maxY: (widget.maxWeight * 1.2).ceilToDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.chartData,
                      isCurved: false,
                      barWidth: .5,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          widget.exerciseHistoryData.isEmpty ? const SizedBox.shrink() :
          Padding(
            padding: commonPadding(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Total Lifted
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.totalWeight} lbs',
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
                // Right Column: 1 Rep Max
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.maxWeight} lbs',
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
          widget.exerciseHistoryData.isEmpty ? const SizedBox.shrink() :
          Expanded(
            // child: exercise.filteredData.isEmpty ? const Center(child: Text('No History Available', style: TextStyle(
            //   fontSize: 16,
            //   fontWeight: FontWeight.normal,
            // ),),) :  ListView.builder(
            child: exercise.filteredData.isEmpty ? const Center(child: Text('', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),),) :  
            ListView.builder(
              itemCount: exercise.filteredData.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.1),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Side: Workout Date
                            Expanded(
                              flex: 1, // Adjust flex if needed
                              child: Text(
                                exercise.filteredData[index]['date'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            // Right Side: Workout Details
                            Expanded(
                              flex: 2, // Adjust flex if needed
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: (exercise.filteredData[index]['data'] as List)
                                    .map((set) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            // Reps
                                            TextSpan(
                                              text: '${set['reps']}',
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
                                            // Weight
                                            TextSpan(
                                              text: '${set['weight']}lbs',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' @RIR ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                            // RPE
                                            TextSpan(
                                              text: '${set['rir']}',
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
                                ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index <  exercise.filteredData.length - 1)
                        const Padding(
                          padding:  EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child:  Divider(
                            thickness: .1,
                            color: Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
    double buttonWidth = MediaQuery.of(context).size.width / 7;
    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryColor : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
        ),
        onPressed: onPressed, // Use the passed callback
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
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
