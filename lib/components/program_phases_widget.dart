import 'package:bbb/components/button_widget.dart';
import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgramPhasesWidget extends StatelessWidget {
  const ProgramPhasesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Column(
      children: [
        SizedBox(
          height: media.height / 1.36,
          width: media.width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: -ScreenUtil.verticalScale(4),
                child: ClipPath(
                  clipper: MiddleClipper(),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                  ),
                ),
              ),
              Positioned(
                top: ScreenUtil.verticalScale(6),
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child:
                          Consumer<DataProvider>(builder: (context, value, c) {
                        return Text(
                          value.programPhaseModel?.phasesmaininfo?.title ??
                              "Periodization Cycle",
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: ScreenUtil.horizontalScale(5),
                              fontWeight: FontWeight.bold,
                              height: 1.35),
                        );
                      }),
                    ),
                    SizedBox(height: ScreenUtil.verticalScale(1.2)),
                    Consumer<DataProvider>(builder: (context, value, c) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.programPhaseScreen);
                        },
                        child: Container(
                          height: ScreenUtil.verticalScale(43),
                          margin: EdgeInsets.only(
                              bottom: ScreenUtil.verticalScale(0.8)),
                          child: value.programPhaseModel != null
                              ? value.programPhaseModel!.phasesmaininfo!
                                      .thumbnail!.isEmpty
                                  ? Image.asset(
                                      "assets/img/program-phase-1.png")
                                  : appShimmerImage(
                                      height: media.width / 4,
                                      width: media.width,
                                      networkImageUrl: value.programPhaseModel!
                                              .phasesmaininfo!.thumbnail!
                                              .startsWith(
                                                  'https://storage.cloud.google.com/')
                                          ? value.programPhaseModel!
                                              .phasesmaininfo!.thumbnail!
                                              .replaceFirst(
                                                  'https://storage.cloud.google.com/',
                                                  'https://storage.googleapis.com/')
                                          : value.programPhaseModel!
                                              .phasesmaininfo!.thumbnail!,
                                      fit: BoxFit.cover,
                                      color: Colors.transparent,
                                    )
                              : Image.asset("assets/img/program-phase-1.png"),
                        ),
                      );
                    }),
                    SizedBox(height: ScreenUtil.verticalScale(1.5)),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(18)),
                      child: ButtonWidget(
                        text: 'Learn More',
                        textColor: Colors.white,
                        color: AppColors.primaryColor,
                        onPress: () {
                          Navigator.pushNamed(
                              context, AppRoutes.programPhaseScreen);
                        },
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: ScreenUtil.verticalScale(2),
                left: 0,
                right: 0,
                child: SizedBox(
                  width: ScreenUtil.horizontalScale(60),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Member Spotlight",
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: ScreenUtil.horizontalScale(5),
                          fontWeight: FontWeight.bold,
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
