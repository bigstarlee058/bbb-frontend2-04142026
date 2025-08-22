import 'dart:io';

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
  const ConfirmationScreen({super.key});

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

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Consumer<DataProvider>(builder: (context, value, c) {
                    return AppImage.imageEmailConfirm(
                      value,
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
                    );
                  })
                ],
              ),
              Positioned(
                top: ScreenUtil.horizontalScale(38),
                child: Container(
                  height: ScreenUtil.verticalScale(15),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
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
                                  Container(
                                      height: ScreenUtil.verticalScale(35)),
                                  Positioned(
                                    top: -ScreenUtil.verticalScale(2),
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                        child: Lottie.asset(
                                            'assets/img/mail.json',
                                            height:
                                                ScreenUtil.verticalScale(35))),
                                  ),
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
                                                ScreenUtil.verticalScale(3),
                                            color: AppColors.primaryColor,
                                            height: 1.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10),
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
                              height: ScreenUtil.horizontalScale(20),
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
                              height: Platform.isAndroid
                                  ? ScreenUtil.horizontalScale(4)
                                  : ScreenUtil.horizontalScale(10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
