import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataProvider? dataProvider;
  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await dataProvider?.getAppBGs().then(
      (value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
            ),
          );
          await isFromNotification();
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
