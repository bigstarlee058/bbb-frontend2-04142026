import 'dart:developer';

import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
    this.onTap,
    this.autofillHints,
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
  final void Function()? onTap;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onChanged: onChanged,
      autofocus: autofocus ?? false,
      validator: validator,
      obscureText: obscureText ?? false,
      onEditingComplete: onEditingComplete,
      maxLines: maxLines,
      expands: expands,
      textAlignVertical: textAlignVertical,
      enableInteractiveSelection: true,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: autofillHints,
      textCapitalization: TextCapitalization.none,
      enableIMEPersonalizedLearning: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
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
        fillColor: Theme.of(context).cardColor,
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
      cursorColor: Theme.of(context).textTheme.bodySmall?.color,
      cursorWidth: 0.5,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        decoration: TextDecoration.none,
        fontSize: ScreenUtil.verticalScale(1.82),
      ),
    );
  }
}
