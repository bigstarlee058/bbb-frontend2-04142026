import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VersionUpdateScreen extends StatefulWidget {
  const VersionUpdateScreen({super.key});

  @override
  State<VersionUpdateScreen> createState() => _VersionUpdateScreenState();
}

class _VersionUpdateScreenState extends State<VersionUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Container(
                height: ScreenUtil.verticalScale(10),
                width: ScreenUtil.verticalScale(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                    ),
                  ],
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage("assets/icons/app_icon.jpg"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil.verticalScale(2),
                ),
                child: Text(
                  "New version available",
                  style: GoogleFonts.plusJakartaSans(
                    height: 1.2,
                    color: Colors.black,
                    fontSize: ScreenUtil.verticalScale(3.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                style: GoogleFonts.plusJakartaSans(
                  height: 1.5,
                  color: Colors.black,
                  fontSize: ScreenUtil.verticalScale(2),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6)),
                child: ButtonWidget(
                    text: "Update Now", textColor: Colors.white, color: AppColors.primaryColor, onPress: () {}, isLoading: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
