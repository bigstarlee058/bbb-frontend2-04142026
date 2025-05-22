import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomRadarChart extends StatelessWidget {
  final List<String> features = ["Squat", "HipThrust", "Bench", "Deadlift", "Press", "Chinup"];

  final List<List<double>> data = [
    [20, 60, 22, 28, 60, 50],
    [40, 72, 35, 36, 74, 70],
  ];

  final List<List<String>> dataDates = [
    ["2025-05-01", "2025-05-02", "2025-05-03", "2025-05-04", "2025-05-05", "2025-05-06"],
    ["2025-06-01", "2025-06-02", "2025-06-03", "2025-06-04", "2025-06-05", "2025-06-06"],
  ];

  CustomRadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: RadarChart(
          ticks: List.generate(10, (index) => 10 * (index + 1)),
          features: features,
          data: data,
          dataDates: dataDates,
          outlineColor: Colors.grey.shade400,
          axisColor: Colors.grey.shade400,
          graphColors: [
            Colors.pink.shade100,
            Colors.pink.shade800.withOpacity(0.5),
          ],
        ),
      ),
    );
  }
}

const defaultGraphColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.brown,
  Colors.cyan,
];

class RadarChart extends StatefulWidget {
  final List<int> ticks;
  final List<String> features;
  final List<List<num>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;
  final int sides;
  final List<List<String>> dataDates;

  const RadarChart({
    super.key,
    required this.ticks,
    required this.features,
    required this.data,
    required this.dataDates,
    this.reverseAxis = false,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.featuresTextStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.outlineColor = Colors.black,
    this.axisColor = Colors.grey,
    this.graphColors = defaultGraphColors,
    this.sides = 0,
  });

  @override
  State<RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
  double fraction = 0;
  late Animation<double> animation;
  late AnimationController animationController;
  Offset? _tooltipPosition;
  String? _tooltipText;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ))
      ..addListener(() {
        setState(() {
          fraction = animation.value;
        });
      });

    animationController.forward();
  }

  @override
  void didUpdateWidget(RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);

              double closestDistance = double.infinity;
              Offset? closestPoint;
              String? closestTooltipText;

              final centerX = box.size.width / 2;
              final centerY = box.size.height / 2;
              final radius = math.min(centerX, centerY) * 0.8;
              final angleIncrement = 2 * math.pi / widget.features.length;

              for (int i = 0; i < widget.data.length; i++) {
                for (int j = 0; j < widget.data[i].length; j++) {
                  final scaled = radius * widget.data[i][j] * fraction / widget.ticks.last.toDouble();
                  final angle = angleIncrement * j - math.pi / 2;
                  final x = centerX + scaled * math.cos(angle);
                  final y = centerY + scaled * math.sin(angle);
                  final distance = (localPosition - Offset(x, y)).distance;

                  if (distance < 15 && distance < closestDistance) {
                    closestDistance = distance;
                    closestPoint = Offset(x, y);
                    closestTooltipText = "${widget.data[i][j]}%\n${widget.dataDates[i][j]}";
                  }
                }
              }

              setState(() {
                _tooltipPosition = closestPoint;
                _tooltipText = closestTooltipText;
              });
            },
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: RadarChartPainter(
                widget.ticks,
                widget.features,
                widget.data,
                widget.reverseAxis,
                widget.ticksTextStyle,
                widget.featuresTextStyle,
                widget.outlineColor,
                widget.axisColor,
                widget.graphColors,
                widget.sides,
                fraction,
              ),
            ),
          ),
          if (_tooltipPosition != null && _tooltipText != null)
            Positioned(
              left: _tooltipPosition!.dx - 30,
              top: _tooltipPosition!.dy - 30,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _tooltipText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class RadarChartPainter extends CustomPainter {
  final List<int> ticks;
  final List<String> features;
  final List<List<num>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;
  final int sides;
  final double fraction;

  RadarChartPainter(
    this.ticks,
    this.features,
    this.data,
    this.reverseAxis,
    this.ticksTextStyle,
    this.featuresTextStyle,
    this.outlineColor,
    this.axisColor,
    this.graphColors,
    this.sides,
    this.fraction,
  );

  Path variablePath(Size size, double radius, int sides) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final angle = 2 * math.pi / (sides == 0 ? features.length : sides);

    if (sides < 3) {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    } else {
      for (int i = 0; i <= sides; i++) {
        final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
        final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) * 0.8;
    final tickRadius = radius / ticks.length;

    final axisPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke;

    final angle = 2 * math.pi / features.length;

    // Draw static grid lines
    for (int i = 1; i <= ticks.length; i++) {
      final path = variablePath(size, tickRadius * i, sides);
      canvas.drawPath(path, axisPaint);
    }

    // Animate only tick values
    for (int i = 1; i <= ticks.length; i++) {
      final tick = ticks[reverseAxis ? ticks.length - i : i - 1];
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$tick',
          style: ticksTextStyle.copyWith(
            color: ticksTextStyle.color?.withOpacity(fraction),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 38,
          center.dy - tickRadius * i - textPainter.height + 15,
        ),
      );
    }

    // Draw axis lines and feature labels
    for (int i = 0; i < features.length; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), axisPaint);

      final tp = TextPainter(
        text: TextSpan(text: features[i], style: featuresTextStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = x < center.dx ? x - tp.width : x;
      final dy = y < center.dy ? y - tp.height : y;
      tp.paint(canvas, Offset(dx, dy));
    }

    for (int d = 0; d < data.length; d++) {
      final graph = data[d];
      final path = Path();

      for (int i = 0; i < graph.length; i++) {
        final value = graph[i] * fraction;
        final scaled = value * radius / ticks.last.toDouble();
        final x = center.dx + scaled * math.cos(angle * i - math.pi / 2);
        final y = center.dy + scaled * math.sin(angle * i - math.pi / 2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      final fillPaint = Paint()
        ..color = graphColors[d % graphColors.length].withOpacity(0.3)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = graphColors[d % graphColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);

      for (int i = 0; i < graph.length; i++) {
        final value = graph[i] * fraction;
        final scaled = value * radius / ticks.last.toDouble();
        final x = center.dx + scaled * math.cos(angle * i - math.pi / 2);
        final y = center.dy + scaled * math.sin(angle * i - math.pi / 2);
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = graphColors[d % graphColors.length],
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) => true;
}
