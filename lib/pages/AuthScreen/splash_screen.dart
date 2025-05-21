import 'package:bbb/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataProvider? dataProvider;
  bool isLoading = false;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    onInit();
    super.initState();
  }

  onInit() async {
    await dataProvider?.getAppBGs().then(
      (value) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      },
    );
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
