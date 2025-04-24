import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  final String image;

  const ConfirmationScreen({super.key, required this.image});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String image = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async => updateImage());

    super.initState();
  }

  updateImage() async {
    if (widget.image == "") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      image = prefs.getString("login_image") ?? '';
    } else {
      image = widget.image;
    }
    setState(() {});
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
              Container(
                height: media.height / 1.6,
                width: media.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: image.isNotEmpty
                        ? NetworkImage(
                            image.startsWith('https://storage.cloud.google.com/')
                                ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                : image,
                          )
                        : const AssetImage('assets/img/card.png'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(15)),
                        height: media.height / 7,
                        width: media.width,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/img/bbb-logo.png'), fit: BoxFit.fitHeight, opacity: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              bottom: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipPath(
                    clipper: DiagonalClipper(),
                    child: Container(
                      height: media.height / 9.8,
                      width: media.width / 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: media.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(1)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(6)),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Lottie.asset('assets/img/mail.json'),
                                Positioned(
                                  bottom: -ScreenUtil.verticalScale(6),
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Text(
                                        'CONFIRM YOUR EMAIL',
                                        style: GoogleFonts.bebasNeue(color: AppColors.primaryColor, fontSize: ScreenUtil.verticalScale(4)),
                                      ),
                                      Text(
                                        'A verification email has been sent to your inbox. Please click the link in the email to confirm your account.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                            color: Colors.grey.shade600, fontSize: ScreenUtil.verticalScale(1.8)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil.horizontalScale(29.5),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(4)),
                            child: ButtonWidget(
                              text: "Back to Login",
                              textColor: Colors.white,
                              onPress: () {},
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
                  ),
                ],
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
