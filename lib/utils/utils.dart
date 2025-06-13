import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static DateTime formattedDate(String date) {
    String utcTimeString = date;
    DateTime utcTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseUtc(utcTimeString);
    DateTime localTime = utcTime.toLocal();
    return localTime;
  }

  static BorderRadius buttonRadius = BorderRadius.circular(20);

  static RoundedRectangleBorder buttonStyle = RoundedRectangleBorder(borderRadius: buttonRadius);

  static appImage(Size media, {FileImage? image, Widget? child, required String imageKey}) {
    return Center(
      child: Container(
        height: media.height / 1,
        width: media.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image ??
                const AssetImage(
                  'assets/img/back.jpg',
                ),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1);
  }
}

class NoBottomBounceScrollPhysics extends BouncingScrollPhysics {
  const NoBottomBounceScrollPhysics({super.parent});

  @override
  NoBottomBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoBottomBounceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value > position.pixels && value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }

    return super.applyBoundaryConditions(position, value);
  }
}
