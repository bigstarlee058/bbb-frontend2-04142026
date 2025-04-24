import 'package:bbb/pages/Tools/GraphsReports/Charts/custom_radar.dart';
import 'package:flutter/material.dart';

class CustomRadarChart extends StatelessWidget {
  final List<String> ticks = ['0', '50', '100', '150', '200', '250', '300', '350', '400'];
  final List<String> features = ["Squat", "HipThrust", "Bench", "Deadlift", "Press", "Chinup"];

  final List<List<double>> data = [
    [250, 300, 220, 280, 100, 150],
    [300, 350, 250, 300, 120, 180],
  ];

  CustomRadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FileRadarChart(
      ticks: const [0, 50, 100, 150, 200, 250, 300, 350, 400],
      features: features,
      data: data,
      reverseAxis: false,
      outlineColor: Colors.grey,
      graphColors: [
        Colors.pink.shade200,
        Colors.pink.shade900.withValues(alpha: 0.5),
      ],
    );
  }
}
