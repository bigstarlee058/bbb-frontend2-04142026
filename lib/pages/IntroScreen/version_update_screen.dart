import 'dart:io';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionUpdateScreen extends StatefulWidget {
  const VersionUpdateScreen({super.key});

  @override
  State<VersionUpdateScreen> createState() => _VersionUpdateScreenState();
}

class _VersionUpdateScreenState extends State<VersionUpdateScreen> {
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    preferences.setBool(SharedPreference.isUpdatePopUP, true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: Platform.isIOS
          ? dataProvider!.newVersionModel!.ios!.forceUpdate! == false
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: SizedBox(),
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil.horizontalScale(2.5)),
                        decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding:
                              EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                          child: Icon(
                              size: ScreenUtil.verticalScale(2.5),
                              Icons.close,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8)
                  ],
                )
              : AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: SizedBox(),
                )
          : dataProvider!.newVersionModel!.android!.forceUpdate! == false
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: SizedBox(),
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil.horizontalScale(2.5)),
                        decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding:
                              EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                          child: Icon(
                              size: ScreenUtil.verticalScale(2.5),
                              Icons.close,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8)
                  ],
                )
              : AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: SizedBox(),
                ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          margin:
              EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(8)),
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage("assets/icons/app_icon.jpg"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil.verticalScale(2),
                ).copyWith(right: ScreenUtil.horizontalScale(5)),
                child: Text(
                  "New version available",
                  style: GoogleFonts.plusJakartaSans(
                    height: 1.2,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: ScreenUtil.verticalScale(3.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                dataProvider?.newVersionModel?.updateMessage ??
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                style: GoogleFonts.plusJakartaSans(
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: ScreenUtil.verticalScale(2),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil.verticalScale(6)),
                child: ButtonWidget(
                    text: "Update Now",
                    textColor: Colors.white,
                    color: AppColors.primaryColor,
                    onPress: () async {
                      await _launchURL(Platform.isAndroid
                          ? "https://play.google.com/store/apps/details?id=com.bootybybret.app"
                          : "https://apps.apple.com/us/app/booty-by-bret/id6746472250");
                    },
                    isLoading: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
