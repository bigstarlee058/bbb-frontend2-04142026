import 'dart:ui';

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
  return appShimmerImage(
    height: height,
    width: width,
    networkImageUrl: networkImageUrl.startsWith('https://storage.cloud.google.com/')
        ? networkImageUrl.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
        : networkImageUrl,
    fit: BoxFit.cover,
    borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
    child: child,
  );

  // Container(
  //   height: height,
  //   width: width,
  //   decoration: BoxDecoration(
  //     borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
  //     image: DecorationImage(
  //       image: networkImageUrl.isNotEmpty
  //           ? NetworkImage(
  //               networkImageUrl.startsWith('https://storage.cloud.google.com/')
  //                   ? networkImageUrl.replaceFirst(
  //                       'https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
  //                   : networkImageUrl,
  //             )
  //           : AssetImage(errorImageUrl ?? 'assets/img/card.png'),
  //       fit: fit,
  //     ),
  //   ),
  //   child: child,
  // );
}

Widget appShimmerImage(
    {required String networkImageUrl,
    double? height,
    double? width,
    BoxFit? fit,
    BorderRadiusGeometry? borderRadius,
    Widget? child,
    Color? color,
    bool? isBlur}) {
  return CachedNetworkImage(
    imageUrl: networkImageUrl.startsWith('https://storage.cloud.google.com/')
        ? networkImageUrl.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
        : networkImageUrl,
    height: height,
    width: width,
    fit: fit,
    placeholder: (context, url) {
      return Shimmer.fromColors(
        baseColor: color ?? Colors.grey.withValues(alpha: 0.35),
        highlightColor: color ?? Colors.grey.withValues(alpha: 0.2),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: color ?? AppColors.primaryColor,
            borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
          ),
        ),
      );
    },
    errorWidget: (context, url, error) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
          image: DecorationImage(image: AssetImage("assets/img/library_placeholder.png"), fit: fit),
        ),
      );
    },
    imageBuilder: (context,
            imageProvider) => /*true
        ? Shimmer.fromColors(
            baseColor: color ?? Colors.grey.withValues(alpha: 0.35),
            highlightColor: color ?? Colors.grey.withValues(alpha: 0.2),
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: color ?? AppColors.primaryColor,
                borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(ScreenUtil.verticalScale(5))),
              ),
            ),
          )
        :*/
        isBlur ?? false
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Image(
                        height: height,
                        image: imageProvider,
                        fit: fit,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: height! * 0.12,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Container(
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
