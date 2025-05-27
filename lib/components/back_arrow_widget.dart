import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

class BackArrowWidget extends StatelessWidget {
  const BackArrowWidget({super.key, required this.onPress, this.position, this.bigSize});

  final Function() onPress;
  final double? position;
  final double? bigSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.only(
        left: ScreenUtil.horizontalScale(bigSize != null ? 3 : 4),
      ),
      decoration: BoxDecoration(
        color: (position ?? 0) > 25 ? Colors.transparent : Color(0XFFd18a9b),
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: ScreenUtil.verticalScale(bigSize ?? 4),
        height: ScreenUtil.verticalScale(bigSize ?? 4),
        child: GestureDetector(
          onTap: onPress,
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: ScreenUtil.verticalScale(3.3),
            ),
          ),
        ),
      ),
    );
  }
}
