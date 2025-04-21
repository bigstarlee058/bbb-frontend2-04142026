import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class ProgramPhasesWidget extends StatelessWidget {
  const ProgramPhasesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return Column(
      children: [
        Container(
          height: media.height / 1.8,
          width: media.width,
          color: Colors.white, // Set the outside background color to white
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Top white section
              Positioned(
                top: -ScreenUtil.verticalScale(2.8),
                left: 0,
                right: 0,
                height: media.height / 8, // Adjust height of white top section
                child: Container(
                  width: ScreenUtil.horizontalScale(60),
                  margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(7), top: ScreenUtil.verticalScale(0)),
                  child: Text(
                    "Program Phases",
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: ScreenUtil.horizontalScale(5.2),
                        fontWeight: FontWeight.bold,
                        height: 1.35),
                  ),
                ),
              ),

              // // Bottom white section
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   height: media.height / 8, // Adjust height of white bottom section
              //   child: Container(
              //     color: Colors.white,
              //   ),
              // ),
              // // Middle image section with clip path
              Positioned.fill(
                top: -ScreenUtil.verticalScale(2.6),
                child: ClipPath(
                  clipper: MiddleClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/img/pp_4.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Centered content over the image
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        bottom: ScreenUtil.verticalScale(10),
                        left: ScreenUtil.horizontalScale(18),
                        right: ScreenUtil.horizontalScale(18),
                      ),
                      child: ButtonWidget(
                        text: 'Learn More',
                        textColor: Colors.white,
                        color: AppColors.primaryColor,
                        onPress: () {
                          // Navigator.pushNamed(context, '/joinChallenge');
                        },
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: ScreenUtil.horizontalScale(60),
                  margin: EdgeInsets.only(left: ScreenUtil.horizontalScale(7), top: ScreenUtil.verticalScale(0)),
                  child: Text(
                    "Member Spotlight",
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: ScreenUtil.horizontalScale(5.2),
                        fontWeight: FontWeight.bold,
                        height: 1.35),
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
