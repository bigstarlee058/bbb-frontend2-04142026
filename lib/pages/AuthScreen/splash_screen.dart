// import 'package:bbb/providers/video_image_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   VideoImageProvider? videoImageProvider;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     videoImageProvider = Provider.of<VideoImageProvider>(context, listen: false);
//
//     onInit();
//     super.initState();
//   }
//
//   onInit() async {
//     await Future.delayed(Duration(seconds: 3)).then(
//       (value) {
//         Navigator.pushNamed(context, '/onboarding');
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Image.asset("assets/img/logo.png"),
//       ),
//     );
//   }
// }
