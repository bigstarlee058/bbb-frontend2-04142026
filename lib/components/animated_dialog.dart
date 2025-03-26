import 'dart:io';

import 'package:flutter/material.dart';

class AnimatedDialog {
  static Future<T?> showAnimatedDialog<T extends Object?>({
    required BuildContext context,
    required WidgetBuilder builder,
    Curve curve = Curves.linear,
    Alignment alignment = Alignment.center,
    Color? barrierColor,
    Axis? axis = Axis.horizontal,
  }) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = Theme.of(context);
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        final Widget pageChild = Builder(builder: builder);
        return SafeArea(
          top: false,
          child: Builder(builder: (BuildContext context) {
            return Theme(data: theme, child: pageChild);
          }),
        );
      },
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: Duration(milliseconds: Platform.isIOS ? 200 : 300),
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          alignment: alignment,
          scale: CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.00,
              0.50,
              curve: curve,
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
