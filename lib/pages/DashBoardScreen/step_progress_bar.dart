import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final double progress;
  final int totalSteps;
  const StepProgressBar({
    super.key,
    required this.progress,
    this.totalSteps = 4,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final spacing = 6;
        final stepWidth = (totalWidth - ((totalSteps - 1) * spacing)) / totalSteps;
        final progressWidth = (progress / totalSteps) * totalWidth;

        return Row(
          children: List.generate(totalSteps, (index) {
            double fillPercent = (progress - index).clamp(0.0, 1.0);
            final stepOffset = index * (stepWidth + spacing);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 3),
              child: Stack(
                children: [
                  Container(
                    width: stepWidth,
                    height: ScreenUtil.verticalScale(0.8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: index == 0
                          ? BorderRadius.horizontal(left: Radius.circular(20))
                          : index == 3
                              ? BorderRadius.horizontal(right: Radius.circular(20))
                              : BorderRadius.zero,
                    ),
                  ),
                  if (fillPercent > 0)
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [AppColors.backOffSetColor1, AppColors.primaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          Rect.fromLTWH(-stepOffset, 0, progressWidth, 10),
                        );
                      },
                      blendMode: BlendMode.srcIn,
                      child: Container(
                        width: stepWidth * fillPercent,
                        height: ScreenUtil.verticalScale(0.8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: index == 0
                              ? BorderRadius.horizontal(left: Radius.circular(20))
                              : index == 3
                                  ? BorderRadius.horizontal(right: Radius.circular(20))
                                  : BorderRadius.zero,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
