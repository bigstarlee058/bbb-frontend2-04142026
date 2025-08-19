import 'dart:io';

import 'package:bbb/components/common_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatDouble(double value) {
    final rounded = double.parse(value.toStringAsFixed(2));
    final formatted = (rounded % 1 == 0)
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(2);
    return formatted;
  }

  static double convertCmToInch(double cm) {
    return cm / 2.54;
  }

  static double convertFeetInchesToCm(int feet, double inches) {
    double totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  static String convertInchToCm(double inch) {
    return formatDouble(inch * 2.54);
  }

  static DateTime formattedDate(String date) {
    try {
      DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime utcTime = format.parseUtc(date);
      return utcTime.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  static BorderRadius buttonRadius = BorderRadius.circular(20);

  static RoundedRectangleBorder buttonStyle =
      RoundedRectangleBorder(borderRadius: buttonRadius);

  static appImage(Size media,
      {bool? isImage,
      String? image,
      Widget? child,
      required String imageKey,
      bool? val}) {
    String? url = image!.startsWith('https://storage.cloud.google.com/')
        ? image.replaceFirst('https://storage.cloud.google.com/',
            'https://storage.googleapis.com/')
        : image;
    return isImage == true
        ? Stack(
            children: [
              Image.asset(
                'assets/img/back 1.png',
                height: media.height / 1.8,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              child ?? SizedBox(),
            ],
          )
        : val == true
            ? Center(
                child: Container(
                  height: media.height / 1,
                  width: media.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: child,
                ),
              )
            : appShimmerImage(
                color: Colors.transparent,
                networkImageUrl: url,
                fit: BoxFit.cover,
                height: media.height,
                width: media.width,
                borderRadius: BorderRadius.circular(0),
                child: child,
              );
  }

  static appFileImage(Size media,
      {FileImage? image, Widget? child, required String imageKey}) {
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

void showBottomAlert(BuildContext context, String msg) {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20.0,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry.remove();
  });
}
