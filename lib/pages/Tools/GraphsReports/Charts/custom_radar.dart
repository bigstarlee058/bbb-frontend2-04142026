import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

const defaultGraphColors = [
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.orange,
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

  const RadarChart({
    super.key,
    required this.ticks,
    required this.features,
    required this.data,
    this.reverseAxis = false,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.featuresTextStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.outlineColor = Colors.black,
    this.axisColor = Colors.grey,
    this.graphColors = defaultGraphColors,
    this.sides = 0,
  });

  factory RadarChart.light({
    required List<int> ticks,
    required List<String> features,
    required List<List<num>> data,
    bool reverseAxis = false,
    bool useSides = false,
  }) {
    return RadarChart(ticks: ticks, features: features, data: data, reverseAxis: reverseAxis, sides: useSides ? features.length : 0);
  }

  factory RadarChart.dark({
    required List<int> ticks,
    required List<String> features,
    required List<List<num>> data,
    bool reverseAxis = false,
    bool useSides = false,
  }) {
    return RadarChart(
        ticks: ticks,
        features: features,
        data: data,
        featuresTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
        outlineColor: Colors.white,
        axisColor: Colors.grey,
        reverseAxis: reverseAxis,
        sides: useSides ? features.length : 0);
  }

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
  double fraction = 0;
  late Animation<double> animation;
  late AnimationController animationController;
  Offset? _tooltipPosition;
  String? _tooltipValue;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);

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
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            final RenderBox referenceBox = context.findRenderObject() as RenderBox;
            final Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
            final centerX = referenceBox.size.width / 2;
            final centerY = referenceBox.size.height / 2;
            final radius = math.min(centerX, centerY) * 0.8;
            final angleIncrement = 2 * math.pi / widget.features.length;

            for (int i = 0; i < widget.data.length; i++) {
              for (int j = 0; j < widget.data[i].length; j++) {
                final scaledPoint = radius * widget.data[i][j] / widget.ticks.last;
                final angle = angleIncrement * j;
                final x = centerX + scaledPoint * math.cos(angle);
                final y = centerY + scaledPoint * math.sin(angle);

                final distance = math.sqrt(math.pow(localPosition.dx - x, 2) + math.pow(localPosition.dy - y, 2));
                if (distance <= 10) {
                  setState(() {
                    _tooltipPosition = localPosition;
                    _tooltipValue = widget.data[i][j].toString();
                  });
                  return;
                }
              }
            }
            setState(() {
              _tooltipPosition = null;
              _tooltipValue = null;
            });
          },
          child: CustomPaint(
            size: Size(double.infinity, double.infinity),
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
        if (_tooltipPosition != null && _tooltipValue != null)
          Positioned(
            left: _tooltipPosition!.dx - 15,
            top: _tooltipPosition!.dy - 25,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _tooltipValue!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
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
    final angle = 2 * math.pi / sides;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i);
      final y = center.dy + radius * math.sin(angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / ticks.last;
    final angle = (2 * math.pi) / features.length;

    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawPath(variablePath(size, radius, sides), outlinePaint);

    var tickDistance = radius / (ticks.length);
    var tickLabels = reverseAxis ? ticks.reversed.toList() : ticks;

    // Paint the top circle line darker
    if (sides == 0) {
      var topCirclePaint = Paint()
        ..color = Colors.black // Darker color for the top circle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;
      canvas.drawCircle(centerOffset, radius, topCirclePaint);
    } else {
      var topPolygonPaint = Paint()
        ..color = Colors.black // Darker color for the top polygon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;
      canvas.drawPath(variablePath(size, radius, sides), topPolygonPaint);
    }

    if (reverseAxis) {
      TextPainter(
        text: TextSpan(text: tickLabels[0].toString(), style: ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas, Offset(centerX, centerY - ticksTextStyle.fontSize!));
    }

    tickLabels.sublist(reverseAxis ? 1 : 0, reverseAxis ? ticks.length : ticks.length - 1).asMap().forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      if (sides == 0) {
        // Circular grid
        canvas.drawCircle(centerOffset, tickRadius, ticksPaint);
      } else {
        // Polygonal grid
        canvas.drawPath(variablePath(size, tickRadius, sides), ticksPaint);
      }

      var x = centerX + tickRadius;
      var y = centerY;

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: tick.toString(),
          style: ticksTextStyle.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: ticksTextStyle.fontSize! * 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);

      double labelX = x + 8;
      double labelY = y - ticksTextStyle.fontSize! / 4;

      double verticalSpacing = -10;
      labelY -= verticalSpacing;
      canvas.save();

      canvas.translate(labelX, labelY);
      canvas.rotate(math.pi / 2);
      textPainter.paint(canvas, Offset(0, 0));
      canvas.restore();
    });

    // Painting the axis for each given feature
    features.asMap().forEach((index, feature) {
      var xAngle = math.cos(angle * index);
      var yAngle = math.sin(angle * index);

      var featureOffset = Offset(centerX + radius * xAngle, centerY + radius * yAngle);

      // Draw the line from the center to the feature
      Paint currentAxisPaint = ticksPaint;
      if (index == 0) {
        // Make the right side horizontal line darker
        currentAxisPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..isAntiAlias = true;
      }
      canvas.drawLine(centerOffset, featureOffset, currentAxisPaint);

      var labelYOffset = yAngle < 0 ? -featuresTextStyle.fontSize! : 0;
      var labelXOffset = xAngle < 0 ? -60 : 0;

      TextPainter(
        text: TextSpan(text: feature, style: featuresTextStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(
          canvas,
          Offset(featureOffset.dx + labelXOffset, featureOffset.dy + labelYOffset),
        );
    });

    // Painting each graph
    data.asMap().forEach((index, graph) {
      var graphPaint = Paint()
        ..color = graphColors[index % graphColors.length].withOpacity(0.3)
        ..style = PaintingStyle.fill;

      var graphOutlinePaint = Paint()
        ..color = graphColors[index % graphColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      var path = Path();
      for (int i = 0; i < features.length; i++) {
        var scaledPoint = scale * graph[i] * fraction;
        var xAngle = math.cos(angle * i);
        var yAngle = math.sin(angle * i);
        var x = centerX + scaledPoint * xAngle;
        var y = centerY + scaledPoint * yAngle;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // Draw dark points
        var pointPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
      path.close();

      // Create dashed path
      Path dashedPath = dashPath(
        path,
        dashArray: CircularIntervalList<double>(<double>[5, 5]),
      );

      canvas.drawPath(path, graphPaint); // Draw the filled path
      canvas.drawPath(dashedPath, graphOutlinePaint); // Draw the dashed outline
    });
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
