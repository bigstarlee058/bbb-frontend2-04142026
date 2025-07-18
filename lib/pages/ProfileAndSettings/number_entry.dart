import 'dart:developer';
import 'dart:io';

import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberEntry extends StatefulWidget {
  const NumberEntry({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    required this.focusNode,
    this.zeroPadding,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final FocusNode focusNode;
  final bool? zeroPadding;

  @override
  State<NumberEntry> createState() => _NumberEntryState();
}

class _NumberEntryState extends State<NumberEntry> {
  late final TextInputFormatter _suffixFormatter;

  @override
  void initState() {
    super.initState();

    _suffixFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
      final suffix = widget.suffix;
      String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }
      final newText = '$digits$suffix';

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    });

    // Add suffix when field gains focus
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        final suffix = widget.suffix;
        String text = widget.controller.text;

        // Remove existing suffix and non-digits
        if (text.endsWith(suffix)) {
          text = text.substring(0, text.length - suffix.length);
        }
        text = text.replaceAll(RegExp(r'\D'), '');

        // Re-add suffix
        widget.controller.value = TextEditingValue(
          text: '$text$suffix',
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            ScreenUtil.horizontalScale(widget.zeroPadding == true ? 0 : 7.5),
        vertical: ScreenUtil.verticalScale(0.8),
      ),
      height: ScreenUtil.verticalScale(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          SizedBox(
            width: ScreenUtil.horizontalScale(34.5),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.95),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Input field
          Container(
            width: ScreenUtil.horizontalScale(50.5),
            height: ScreenUtil.verticalScale(6),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.horizontalScale(1),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.052),
              borderRadius: Utils.buttonRadius,
            ),
            child: Center(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: /*Platform.isAndroid
                    ?*/
                    TextInputType.number
                /*  : const TextInputType.numberWithOptions(
                        decimal: false, signed: true)*/
                ,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.95),
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Enter here",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: ScreenUtil.verticalScale(1.95),
                  ),
                  counterText: "",
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  _suffixFormatter,
                ],
                onTap: () {
                  if (!widget.controller.text.endsWith(widget.suffix)) {
                    widget.controller.text = widget.suffix;
                    widget.controller.selection =
                        const TextSelection.collapsed(offset: 0);
                  }
                },
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                  if (widget.controller.text
                      .replaceAll(widget.suffix, "")
                      .isEmpty) {
                    widget.controller.clear();
                  }
                },
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                  if (widget.controller.text
                      .replaceAll(widget.suffix, "")
                      .isEmpty) {
                    widget.controller.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';
//
// import 'package:bbb/utils/screen_util.dart';
// import 'package:bbb/utils/utils.dart';
// import 'package:bbb/values/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keyboard_actions/keyboard_actions.dart';
//
// class NumberEntry extends StatefulWidget {
//   const NumberEntry({
//     super.key,
//     required this.label,
//     required this.controller,
//     required this.suffix,
//     required this.focusNode,
//   });
//
//   final String label;
//   final TextEditingController controller;
//   final String suffix;
//   final FocusNode focusNode;
//
//   @override
//   State<NumberEntry> createState() => _NumberEntryState();
// }
//
// class _NumberEntryState extends State<NumberEntry> {
//   void _appendKgIfNeeded(TextEditingController controller, hint) {
//     String text = controller.text.trim();
//     if (text.isNotEmpty && !text.toLowerCase().endsWith("$hint")) {
//       setState(() {
//         controller.text = "$text$hint";
//         controller.selection = TextSelection.fromPosition(
//           TextPosition(offset: controller.text.length),
//         );
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     widget.focusNode.addListener(() {
//       if (!widget.focusNode.hasFocus) {
//         _appendKgIfNeeded(widget.controller, widget.suffix);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     widget.focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: ScreenUtil.horizontalScale(7.5),
//         vertical: ScreenUtil.verticalScale(0.8),
//       ),
//       height: ScreenUtil.verticalScale(6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: ScreenUtil.horizontalScale(34.5),
//             child: Text(
//               widget.label,
//               style: TextStyle(
//                 fontSize: ScreenUtil.verticalScale(1.95),
//                 color: AppColors.primaryColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Container(
//             width: ScreenUtil.horizontalScale(50.5),
//             height: ScreenUtil.verticalScale(6),
//             padding:
//                 EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(1)),
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.052),
//               borderRadius: Utils.buttonRadius,
//             ),
//             child: Center(
//               child: TextField(
//                 style: TextStyle(
//                   fontSize: ScreenUtil.verticalScale(1.95),
//                   color: Colors.black,
//                 ),
//                 controller: widget.controller,
//                 keyboardType: Platform.isAndroid
//                     ? TextInputType.number
//                     : const TextInputType.numberWithOptions(
//                         decimal: false, signed: true),
//                 textInputAction: TextInputAction.done,
//                 onSubmitted: (_) {
//                   FocusScope.of(context).unfocus();
//                 },
//                 textAlign: TextAlign.center,
//                 focusNode: widget.focusNode,
//                 maxLength: 4,
//                 onEditingComplete: () {
//                   widget.controller.text.replaceAll(widget.suffix, "");
//                   if (!widget.controller.text.contains(widget.suffix)) {
//                     widget.controller.text =
//                         '${widget.controller.text}${widget.suffix}';
//                   }
//                 },
//                 decoration: InputDecoration(
//                   counterText: "",
//                   hintText: "Enter here",
//                   hintStyle: TextStyle(
//                     color: Colors.grey.shade700,
//                     fontSize: ScreenUtil.verticalScale(1.95),
//                   ),
//                   // suffix: !focusNode.hasFocus && controller.text.isEmpty
//                   //     ? SizedBox()
//                   //     : Text(
//                   //         suffix,
//                   //         style: TextStyle(
//                   //           fontSize: ScreenUtil.verticalScale(1.95),
//                   //           color: Colors.black,
//                   //         ),
//                   //       ),
//
//                   border: InputBorder.none,
//                   isCollapsed: true,
//                   contentPadding: EdgeInsets.zero,
//                 ),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   TextInputFormatter.withFunction((oldValue, newValue) {
//                     String newText = newValue.text;
//                     if (newText.isNotEmpty) {
//                       newText = newText.replaceFirst(RegExp(r'^0+'), '');
//                     }
//                     return TextEditingValue(
//                       text: newText,
//                       selection:
//                           TextSelection.collapsed(offset: newText.length),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
