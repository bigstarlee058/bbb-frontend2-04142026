import 'dart:developer';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataProvider? dataProvider;
  late UserDataProvider userData;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await dataProvider?.getAppBGs().then(
      (value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          await userData.fetchUserInfo();

          // Map<String, dynamic> subscriptionData = userData.user["subscription"];
          // DateTime? startTime = (subscriptionData["purchase_date"] == "" ||
          //         subscriptionData["purchase_date"] == null)
          //     ? null
          //     : DateTime.parse(subscriptionData["purchase_date"]);
          // DateTime? endTime = (subscriptionData["end_date"] == "" ||
          //         subscriptionData["end_date"] == null)
          //     ? null
          //     : DateTime.parse(subscriptionData["end_date"]);
          // DateTime now = await NTP.now();
          // if (subscriptionData["user_subscription_status"] != "free_user" &&
          //     startTime != null &&
          //     endTime != null &&
          //     now.isAfter(startTime) &&
          //     now.isBefore(endTime)) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
            ),
          );
          await isFromNotification();
          // } else {
          //   await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => SubscriptionPayWall(),
          //       ));
          // }
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      },
    );
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/img/logo.png"),
          ),
        ],
      ),
    );
  }
}
