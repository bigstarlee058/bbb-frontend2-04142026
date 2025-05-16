import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

class BackArrowWidget extends StatelessWidget {
  const BackArrowWidget({super.key, required this.onPress});

  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil.horizontalScale(4),
      ),
      decoration: const BoxDecoration(
        color: Color(0XFFd18a9b), // Make sure color is correct
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: ScreenUtil.verticalScale(4.65),
        height: ScreenUtil.verticalScale(4.65),
        child: IconButton(
          padding: EdgeInsets.zero, // Removes the default padding
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
            size: ScreenUtil.verticalScale(4), // Adjust size using ScreenUtil
          ),
          onPressed: onPress,
        ),
      ),
    );
  }
}
