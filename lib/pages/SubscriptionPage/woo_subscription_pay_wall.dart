import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WooSubscriptionPayWall extends StatefulWidget {
  const WooSubscriptionPayWall({super.key});

  @override
  State<WooSubscriptionPayWall> createState() => _WooSubscriptionPayWallState();
}

class _WooSubscriptionPayWallState extends State<WooSubscriptionPayWall> {
  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  DataProvider? dataProvider;
  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  void _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();
    await DatabaseHelper().clearAllTables();
    await preferences.clearPrefs();
    context.read<MonthProvider>().clearAllValues();
    dataProvider?.achievementList = [];
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onBoardingScreen,
      (Route<dynamic> route) {
        log("ROUTE NAME ${route.settings.name}");
        return route.settings.name == AppRoutes.onBoardingScreen;
      },
    );

    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/img/back.jpg',
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Utils.appImage(
            MediaQuery.of(context).size,
            imageKey: '',
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: BackArrowWidget(onPress: () {
                      _handleLogout(context);
                    }),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 3.3,
            child: Image.asset(
              'assets/img/logo1.png',
              height: 80,
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 1.45),
            padding: EdgeInsets.all(ScreenUtil.horizontalScale(5))
                .copyWith(bottom: ScreenUtil.verticalScale(3.2)),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil.verticalScale(1)),
                  child: Center(
                    child: Text(
                      "Your subscription is inactive",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.verticalScale(2.4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil.verticalScale(1.5)),
                Expanded(
                  child: _feature(
                      "It appears your subscription is either expired or inactive, please use the link below to renew or activate your subscription."),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    color: AppColors.primaryColor,
                    text: "My Account",
                    textColor: Colors.white,
                    isLoading: false,
                    onPress: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? token = prefs.getString('authToken');

                      Uri url = Uri.parse(
                          'https://app.bootybybret.com/?token=$token');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil.verticalScale(1.7),
                )),
          ),
        ],
      ),
    );
  }

  Widget _planOption({
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ScreenUtil.verticalScale(1.2),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF8B2D40) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFFF8E6EC) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: !selected
                              ? Colors.grey.shade300
                              : AppColors.primaryColor),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Icon(Icons.check_circle,
                        color: !selected ? Colors.white : Color(0xFF8B2D40),
                        size: 18),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: ScreenUtil.verticalScale(1.8),
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2D40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.verticalScale(1.2),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil.verticalScale(0.5)),
            Text("Full access for just $price",
                style: TextStyle(fontSize: ScreenUtil.verticalScale(1.5))),
          ],
        ),
      ),
    );
  }
}
