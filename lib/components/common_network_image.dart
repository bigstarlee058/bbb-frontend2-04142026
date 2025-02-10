import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget appImage(
    {required String networkImageUrl,
    required String errorImageUrl,
    double? height,
    double? width,
    BoxFit? fit,
    BorderRadiusGeometry? borderRadius,
    Widget? child}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
      image: DecorationImage(
        image: networkImageUrl.isNotEmpty
            ? NetworkImage(
                networkImageUrl.startsWith('https://storage.cloud.google.com/')
                    ? networkImageUrl.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                    : networkImageUrl,
              )
            : AssetImage(errorImageUrl ?? 'assets/img/card.png'),
        fit: fit,
      ),
    ),
    child: child,
  );
}

Widget appShimmerImage(
    {required String networkImageUrl, double? height, double? width, BoxFit? fit, BorderRadiusGeometry? borderRadius, Widget? child}) {
  return CachedNetworkImage(
    imageUrl: networkImageUrl.startsWith('https://storage.cloud.google.com/')
        ? networkImageUrl.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
        : networkImageUrl,
    height: height,
    width: width,
    fit: fit,
    placeholder: (context, url) {
      return Shimmer.fromColors(
        baseColor: AppColors.primaryColor.withValues(alpha: 0.9),
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.7),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
          ),
        ),
      );
    },
    errorWidget: (context, url, error) {
      return networkImageUrl == ""
          ? Shimmer.fromColors(
              baseColor: AppColors.primaryColor.withValues(alpha: 0.9),
              highlightColor: AppColors.primaryColor.withValues(alpha: 0.7),
              child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
                ),
              ),
            )
          : Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
                image: DecorationImage(image: AssetImage("assets/img/warm-up-placeholder.png"), fit: fit),
              ),
            );
    },
    imageBuilder: (context, imageProvider) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
        image: DecorationImage(image: imageProvider, fit: fit),
      ),
      child: child,
    ),
  );
}
