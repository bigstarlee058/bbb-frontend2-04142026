// import 'dart:developer';
//
// import 'package:bbb/utils/screen_util.dart';
// import 'package:bbb/values/app_colors.dart';
// import 'package:flutter/material.dart';
//
// class StepProgressBar extends StatelessWidget {
//   final double progress;
//   final double? progress1;
//   final int totalSteps;
//   final double? stepHeight;
//   final void Function(int)? onStepTap;
//
//   const StepProgressBar({
//     super.key,
//     required this.progress,
//     this.totalSteps = 4,
//     this.stepHeight,
//     this.onStepTap,
//     this.progress1,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final totalWidth = constraints.maxWidth;
//         final spacing = 6;
//         final stepWidth =
//             (totalWidth - ((totalSteps - 1) * spacing)) / totalSteps;
//
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Row(
//             children: List.generate(totalSteps, (index) {
//               double fillPercent = (progress - index).clamp(0.0, 1.0);
//               double fillPercent1 = ((progress1 ?? 1) - index).clamp(0.0, 1.0);
//               return Padding(
//                 padding: EdgeInsets.symmetric(horizontal: spacing / 4),
//                 child: Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         if (onStepTap != null) {
//                           onStepTap!(index);
//                         }
//                       },
//                       child: Container(
//                         width: stepWidth,
//                         height: stepHeight ?? ScreenUtil.verticalScale(0.8),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFF2F2F2),
//                           borderRadius: index == 0
//                               ? const BorderRadius.horizontal(
//                                   left: Radius.circular(18))
//                               : index == totalSteps - 1
//                                   ? const BorderRadius.horizontal(
//                                       right: Radius.circular(18))
//                                   : BorderRadius.zero,
//                         ),
//                       ),
//                     ),
//                     if (fillPercent > 0)
//                       ShaderMask(
//                         shaderCallback: (Rect bounds) {
//                           return LinearGradient(
//                             colors: [
//                               AppColors.backOffSetColor1,
//                               AppColors.primaryColor
//                             ],
//                             begin: Alignment.centerLeft,
//                             end: Alignment.centerRight,
//                           ).createShader(Rect.fromLTWH(
//                             -index * (stepWidth + spacing),
//                             0,
//                             totalWidth,
//                             10,
//                           ));
//                         },
//                         blendMode: BlendMode.srcIn,
//                         child: GestureDetector(
//                           onTap: () {
//                             if (onStepTap != null) {
//                               onStepTap!(index);
//                             }
//                           },
//                           child: Container(
//                             width: stepWidth * fillPercent,
//                             height: stepHeight ?? ScreenUtil.verticalScale(0.8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: index == 0
//                                   ? const BorderRadius.horizontal(
//                                       left: Radius.circular(18))
//                                   : index == totalSteps - 1
//                                       ? const BorderRadius.horizontal(
//                                           right: Radius.circular(18))
//                                       : BorderRadius.zero,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final double progress;
  final double? progress1; // Current active slide (e.g., currentPage + 1)
  final int totalSteps;
  final double? stepHeight;
  final void Function(int)? onStepTap;

  const StepProgressBar({
    super.key,
    required this.progress,
    this.totalSteps = 4,
    this.stepHeight,
    this.onStepTap,
    this.progress1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const spacing = 6.0;
        final stepWidth =
            (totalWidth - ((totalSteps - 1) * spacing)) / totalSteps;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: List.generate(totalSteps, (index) {
              double fillPercent = (progress - index).clamp(0.0, 1.0);

              bool isCurrentStep = index + 1 == (progress1?.toInt() ?? 0);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 4),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (onStepTap != null) {
                          onStepTap!(index);
                        }
                      },
                      child: Container(
                        width: stepWidth,
                        height: stepHeight ?? ScreenUtil.verticalScale(0.8),
                        decoration: BoxDecoration(
                          color: isCurrentStep
                              ? Colors.grey.shade400
                              : Colors.grey.shade200,
                          borderRadius: index == 0
                              ? const BorderRadius.horizontal(
                                  left: Radius.circular(18))
                              : index == totalSteps - 1
                                  ? const BorderRadius.horizontal(
                                      right: Radius.circular(18))
                                  : BorderRadius.zero,
                        ),
                      ),
                    ),
                    if (fillPercent > 0)
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: isCurrentStep
                                ? [
                                    AppColors.backOffSetColor1
                                        .withOpacity(0.99),
                                    AppColors.primaryColor.withOpacity(0.99)
                                  ]
                                : [
                                    AppColors.backOffSetColor1.withOpacity(0.8),
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(Rect.fromLTWH(
                            -index * (stepWidth + spacing),
                            0,
                            totalWidth,
                            10,
                          ));
                        },
                        blendMode: BlendMode.srcIn,
                        child: GestureDetector(
                          onTap: () {
                            if (onStepTap != null) {
                              onStepTap!(index);
                            }
                          },
                          child: Container(
                            width: stepWidth * fillPercent,
                            height: stepHeight ?? ScreenUtil.verticalScale(0.8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: index == 0
                                  ? const BorderRadius.horizontal(
                                      left: Radius.circular(18))
                                  : index == totalSteps - 1
                                      ? const BorderRadius.horizontal(
                                          right: Radius.circular(18))
                                      : BorderRadius.zero,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
