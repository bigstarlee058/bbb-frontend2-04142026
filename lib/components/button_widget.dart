import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    required this.text,
    required this.textColor,
    required this.color,
    required this.onPress,
    required this.isLoading,
    this.fontSize,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Function()? onPress;
  final bool isLoading;
  final double? fontSize;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    // var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          shape: Utils.buttonStyle,
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil.verticalScale(1.7),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                // height: 16,
                width: ScreenUtil.verticalScale(3.2),
                height: ScreenUtil.verticalScale(3.2),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(widget.fontSize ?? 2.2),
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
      ),
    );
  }
}
