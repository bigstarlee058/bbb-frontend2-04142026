import 'package:flutter/material.dart';

class AnimatedDialog {
  static Future<T?> showAnimatedDialog<T extends Object?>(
      {required Widget Function(BuildContext, Animation<double>, Animation<double>) pageBuilder, required BuildContext context}) {
    return showGeneralDialog(
      context: context,
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
            opacity: anim1, child: ScaleTransition(scale: CurvedAnimation(parent: anim1, curve: Curves.fastOutSlowIn), child: child));
      },
      pageBuilder: pageBuilder,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      // curve: Curves.fastOutSlowIn,
    );
  }
}
