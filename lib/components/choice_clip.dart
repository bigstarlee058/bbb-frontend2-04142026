import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class ChoiceChip1 extends StatelessWidget {
  const ChoiceChip1({super.key, required this.label, this.labelStyle, this.onSelected, required this.selected, required this.width});

  const ChoiceChip1.elevated(
      {super.key, required this.label, required this.width, this.labelStyle, this.onSelected, required this.selected});

  final String label;
  final double width;
  final bool selected;
  final void Function()? onSelected;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        color: !selected ? Colors.white : AppColors.primaryColor,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        width: width,
        height: ScreenUtil.verticalScale(6.6),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: selected
                ? [
                    Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      label,
                      style: labelStyle,
                    )
                  ]
                : [
                    Text(
                      label,
                      style: labelStyle,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
