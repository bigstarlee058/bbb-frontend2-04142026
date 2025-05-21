import 'package:bbb/utils/cache_image_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  static appImage(Size media, String image, {Widget? child, required String imageKey, bool? isDark}) {
    return Container(
      height: media.height / 1,
      width: media.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            isDark == true ? 'assets/img/back_dark.jpg' : 'assets/img/back.jpg',
          ),
        ),
      ),
      child: Center(
        child: Container(
          height: media.height / 1,
          width: media.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: image.isNotEmpty
                  ? CachedNetworkImageProvider(
                      cacheKey: imageKey,
                      image.startsWith('https://storage.cloud.google.com/')
                          ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                          : image,
                      cacheManager: CustomCacheManager(),
                    )
                  : const AssetImage('assets/img/back.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        ),
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
