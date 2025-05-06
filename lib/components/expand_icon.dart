// library;
//
// import 'dart:math' as math;
//
// import 'package:bbb/utils/screen_util.dart';
// import 'package:flutter/material.dart';
//
// class ExpandIcon extends StatefulWidget {
//   const ExpandIcon({
//     super.key,
//     this.isExpanded = false,
//     this.size = 24.0,
//     required this.onPressed,
//     this.padding = const EdgeInsets.all(8.0),
//     this.color,
//     this.iconColor,
//   });
//
//   final bool isExpanded;
//   final double size;
//   final ValueChanged<bool>? onPressed;
//   final EdgeInsetsGeometry padding;
//   final Color? color;
//   final Color? iconColor;
//
//   @override
//   State<ExpandIcon> createState() => _ExpandIconState();
// }
//
// class _ExpandIconState extends State<ExpandIcon> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _iconTurns;
//
//   static final Animatable<double> _iconTurnTween = Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.fastOutSlowIn));
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(duration: kThemeAnimationDuration, vsync: this);
//     _iconTurns = _controller.drive(_iconTurnTween);
//     if (widget.isExpanded) {
//       _controller.value = math.pi;
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didUpdateWidget(ExpandIcon oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isExpanded != oldWidget.isExpanded) {
//       if (widget.isExpanded) {
//         _controller.forward();
//       } else {
//         _controller.reverse();
//       }
//     }
//   }
//
//   void _handlePressed() {
//     widget.onPressed?.call(widget.isExpanded);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     assert(debugCheckHasMaterial(context));
//     assert(debugCheckHasMaterialLocalizations(context));
//     final MaterialLocalizations localizations = MaterialLocalizations.of(context);
//     final String onTapHint = widget.isExpanded ? localizations.expandedIconTapHint : localizations.collapsedIconTapHint;
//
//     return Semantics(
//       onTapHint: widget.onPressed == null ? null : onTapHint,
//       child: Container(
//         margin: EdgeInsets.only(right: ScreenUtil.horizontalScale(3)),
//         padding: EdgeInsets.all(ScreenUtil.verticalScale(0.4)),
//         decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
//         child: GestureDetector(
//           onTap: widget.onPressed == null ? null : _handlePressed,
//           child: RotationTransition(
//             turns: _iconTurns,
//             child: Icon(
//               Icons.expand_more,
//               color: widget.iconColor,
//               size: ScreenUtil.verticalScale(3.1),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

library;

import 'dart:math' as math;

import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

class ExpandIcon extends StatefulWidget {
  const ExpandIcon({
    super.key,
    this.isExpanded = false,
    this.size = 24.0,
    required this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
    this.color,
    this.iconColor,
  });

  final bool isExpanded;
  final double size;
  final ValueChanged<bool>? onPressed;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? iconColor;

  @override
  State<ExpandIcon> createState() => _ExpandIconState();
}

class _ExpandIconState extends State<ExpandIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  static final Animatable<double> _iconTurnTween = Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.fastOutSlowIn));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kThemeAnimationDuration, vsync: this);
    _iconTurns = _controller.drive(_iconTurnTween);
    if (widget.isExpanded) {
      _controller.value = math.pi;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handlePressed() {
    widget.onPressed?.call(widget.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String onTapHint = widget.isExpanded ? localizations.expandedIconTapHint : localizations.collapsedIconTapHint;

    return Semantics(
      onTapHint: widget.onPressed == null ? null : onTapHint,
      child: GestureDetector(
        onTap: widget.onPressed == null ? null : _handlePressed,
        child: RotationTransition(
          turns: _iconTurns,
          child: Icon(
            Icons.expand_more,
            color: widget.color ?? Colors.grey.withValues(alpha: 600),
            size: ScreenUtil.verticalScale(3.1),
          ),
        ),
      ),
    );
  }
}
