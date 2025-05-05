// import 'package:bbb/models/welcome_content_model.dart';
// import 'package:bbb/utils/cache_image_manager.dart';
// import 'package:bbb/values/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../pages/AuthScreen/login_page.dart';
//
// class VideoImageProvider extends ChangeNotifier {
//   late WelcomeContentModel welcomeContentModel;
//   bool isLoading = false;
//
//   void loadWelcomeContent(BuildContext context) async {
//     try {
//       isLoading = true;
//       notifyListeners();
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       final descriptionResponse = await http.get(
//         Uri.parse('${AppConstants.serverUrl}/api/screens/get_screens'), // replace with actual endpoint
//       );
//
//       if (descriptionResponse.statusCode == 200) {
//         welcomeContentModel = welcomeContentModelFromJson(descriptionResponse.body);
//         final image = CustomCacheManager().cacheImage(welcomeContentModel.imgUrl);
//         prefs.setString("login_image", welcomeContentModel.imgUrl);
//         // bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
//       } else {
//         showBottomAlert(context, 'Failed to load description');
//         debugPrint('this is login page ${descriptionResponse.statusCode}');
//       }
//     } catch (e) {
//       showBottomAlert(context, 'An error occurred');
//       debugPrint('this is login page $e');
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// }
