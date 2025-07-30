import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/collection_grid.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturedCollectionWidget extends StatelessWidget {
  const FeaturedCollectionWidget({super.key});
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Column(
      children: [
        SizedBox(
          height: media.height / 1.68,
          width: media.width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: -ScreenUtil.verticalScale(2.5),
                child: ClipPath(
                  clipper: MiddleClipper(),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                  ),
                ),
              ),
              Positioned(
                top: ScreenUtil.verticalScale(6.2),
                left: 0,
                right: 0,
                child: Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    return (dataProvider.collectionsData.isNotEmpty)
                        ? Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: ScreenUtil.horizontalScale(7),
                                    right: ScreenUtil.horizontalScale(7),
                                    bottom: ScreenUtil.verticalScale(2)),
                                width: media.width,
                                child: Center(
                                  child: Text(
                                    "Featured Collections",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: ScreenUtil.horizontalScale(5),
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              CarouselSlider.builder(
                                itemCount: dataProvider.collectionsData.length,
                                options: CarouselOptions(
                                  height: ScreenUtil.verticalScale(38),
                                  viewportFraction: 0.65,
                                  enlargeCenterPage: true,
                                  enlargeFactor: 0.4,
                                  enableInfiniteScroll: true,
                                  autoPlay: false,
                                  onPageChanged: (index, reason) {},
                                  scrollDirection: Axis.horizontal,
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  return CollectionGrid(
                                      collection:
                                          dataProvider.collectionsData[index]);
                                },
                              ),
                            ],
                          )
                        : SizedBox(height: ScreenUtil.verticalScale(5));
                  },
                ),
              ),
              Positioned(
                bottom: ScreenUtil.verticalScale(.3),
                left: 0,
                right: 0,
                child: SizedBox(
                  width: ScreenUtil.horizontalScale(60),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Meet Our Team",
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: ScreenUtil.horizontalScale(5),
                          fontWeight: FontWeight.w800,
                          height: 1.35),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MiddleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height * 0.2);

    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.1, // Control point
      size.width * 0.15, size.height * 0.1, // End point
    );

    path.lineTo(size.width * 0.85, size.height * 0.1);

    path.quadraticBezierTo(
      size.width * 0.95, size.height * 0.1, // Control point
      size.width, size.height * 0, // End point
    );

    path.lineTo(size.width, size.height * 0.8);

    path.quadraticBezierTo(
      size.width * 0.95, size.height * 0.9, // Control point
      size.width * 0.85, size.height * 0.9, // End point
    );

    path.lineTo(size.width * 0.15, size.height * 0.9);

    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.9, // Control point
      0, size.height * 1, // End point
    );

    path.lineTo(0, size.height * 0.2);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
