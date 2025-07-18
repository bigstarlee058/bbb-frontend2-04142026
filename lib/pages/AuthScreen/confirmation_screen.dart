import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatefulWidget {
  final String image;

  const ConfirmationScreen({super.key, required this.image});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  DataProvider? dataProvider;
  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              AppImage.imageEmailConfirm(
                // media,
                // image: dataProvider!.allImageList
                //     .where((element) => element["key"] == "imageEmailConfirm")
                //     .first["image"],
                // // image: dataProvider!.cachedImageMap["imageEmailConfirm"],
                // imageKey: "imageEmailConfirm",
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        child: BackArrowWidget(onPress: () {
                          Navigator.pop(context);
                        }),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: ScreenUtil.horizontalScale(28),
            child: Container(
              height: 120,
              width: media.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/img/bbb-logo.png'),
                    fit: BoxFit.fitHeight,
                    opacity: 1),
              ),
            ),
          ),
          Positioned(
              bottom: -1.3,
              child: Container(
                width: media.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil.verticalScale(8))),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: 0,
                      top: -(media.height / 9.8) + 0.3,
                      child: ClipPath(
                        clipper: DiagonalClipper(),
                        child: Container(
                          height: media.height / 9.8,
                          width: media.width / 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(1)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.verticalScale(3)),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Lottie.asset('assets/img/mail.json'),
                                Positioned(
                                  bottom: -ScreenUtil.verticalScale(5.5),
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Text(
                                        'CONFIRM YOUR EMAIL',
                                        style: TextStyle(
                                          fontSize:
                                              ScreenUtil.verticalScale(3.32),
                                          color: AppColors.primaryColor,
                                          height: 1.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ScreenUtil.verticalScale(3)),
                                        child: Text(
                                          'A verification email has been sent to your inbox. Please click the link in the email to confirm your account.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                ScreenUtil.verticalScale(1.7),
                                            height: 1.5,
                                            color: Color(0xff6f6f6f),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.horizontalScale(23),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.verticalScale(4)),
                            child: ButtonWidget(
                              text: "Back to Login",
                              textColor: Colors.white,
                              onPress: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              color: AppColors.primaryColor,
                              isLoading: false,
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.horizontalScale(15.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

void showBottomAlert(BuildContext context, String msg) {
  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20.0,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
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
  );

  overlayState.insert(overlayEntry);

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
