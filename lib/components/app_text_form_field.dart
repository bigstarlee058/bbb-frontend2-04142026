import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.textInputAction,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    super.key,
    this.onChanged,
    this.validator,
    this.obscureText,
    this.suffixIcon,
    this.onEditingComplete,
    this.autofocus,
    this.focusNode,
    this.bottomPadding = 20,
    this.maxLines = 1,
    this.expands = false,
    this.textAlignVertical = TextAlignVertical.center,
  });

  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool? obscureText;
  final Widget? suffixIcon;
  final String hintText;
  final bool? autofocus;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final double? bottomPadding;
  final int? maxLines;
  final bool expands;
  final TextAlignVertical textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onChanged: onChanged,
          autofocus: autofocus ?? false,
          validator: validator,
          obscureText: obscureText ?? false,
          // obscuringCharacter: '*',
          onEditingComplete: onEditingComplete,
          maxLines: maxLines,
          expands: expands,
          textAlignVertical: textAlignVertical,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
              fontSize: ScreenUtil.verticalScale(1.82),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.052),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScreenUtil.verticalScale(1.85), horizontal: 20.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: Utils.buttonRadius,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: Utils.buttonRadius,
            ),
          ),
          cursorColor: Colors.black,
          cursorWidth: 0.5,
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: ScreenUtil.verticalScale(1.82),
          ),
        ),
      ],
    );
  }
}
