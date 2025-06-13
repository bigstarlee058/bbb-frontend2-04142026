import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/common_streak_with_notification.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/models/get_all_achivements.dart';
import 'package:bbb/pages/ProfileAndSettings/payment_detail_screen.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/user_data_provider.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  UserDataProvider? userData;
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(this.context, listen: false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    userData = Provider.of<UserDataProvider>(
      this.context,
      listen: false,
    );
    super.didChangeDependencies();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload to Firebase Storage
      File file = File(image.path);
      String fileName = basename(image.path);

      try {
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await storageRef.putFile(file);

        // Update the state with the image URL
        setState(() {});
      } catch (e) {
        log("Error uploading image: $e");
      }
    }
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
    // Navigator.popUntil(context, ModalRoute.withName(AppRoutes.onBoardingScreen));

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onBoardingScreen,
      (Route<dynamic> route) {
        log("ROUTE NAME ${route.settings.name}");
        return route.settings.name == AppRoutes.onBoardingScreen;
      },
    );

    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  toSupportPage() async {
    openUrl('https://bootybybret.com/pages/contact-us');
  }

  toTermsOfUsePage() async {
    openUrl('https://bootybybret.com/pages/terms-and-conditions');
  }

  toPrivacyPolicyPage() async {
    openUrl('https://bootybybret.com/pages/privacy-policy');
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _deleteAccount(context) async {
    Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/admin/${userData?.userData["id"]}');

    String? userIdToken = await getAuthToken();

    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'AUTH_TOKEN': userIdToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        _handleLogout(context);
        showBottomAlert(context, 'Your account deleted successfully');
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      throw Exception('Failed to delete account');
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return Scaffold(
      /// TEST VERSION AVAILABLE SCREEN
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(bottom: 75),
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: AppColors.primaryColor,
      //       shape: Utils.buttonStyle,
      //       padding: EdgeInsets.symmetric(
      //         vertical: ScreenUtil.verticalScale(1.7),
      //       ),
      //     ),
      //     child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 05),
      //       child: Text(
      //         "New Version Available",
      //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //       ),
      //     ),
      //     onPressed: () async {
      //       await Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => VersionUpdateScreen(),
      //         ),
      //       );
      //     },
      //   ),
      // ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        // Container(
                        //   height: media.height / 1,
                        //   width: media.width,
                        //   decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //       image: AssetImage('assets/img/back.jpg'),
                        //       fit: BoxFit.cover,
                        //       opacity: 1,
                        //     ),
                        //   ),
                        // ),
                        Utils.appImage(
                          media,
                          // dataProvider?.screenBackgroundResponse?.imageProfile ?? "",
                          image: dataProvider!.cachedImageMap["imageProfile"],

                          imageKey: "imageProfile",
                        ),
                        SizedBox(
                          height: media.height / 1.5,
                          width: media.width,
                          child: SafeArea(
                            child: Column(
                              children: [
                                AppBar(
                                  toolbarHeight: ScreenUtil.verticalScale(5.1),
                                  surfaceTintColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  leading: SizedBox(),
                                  centerTitle: true,
                                  title: Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil.verticalScale(2.5),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const CommonStreakWithNotification(routeString: "setting"),
                                    )
                                  ],
                                ),
                                Container(
                                  // color: Colors.red,
                                  height: media.height / 3,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil.horizontalScale(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: ScreenUtil.verticalScale(1),
                                      ),
                                      GestureDetector(
                                        onTap: _pickAndUploadImage,
                                        child: Consumer<UserDataProvider>(
                                          builder: (context, userData, child) {
                                            return userData.userData['detail'] != null &&
                                                    userData.userData['detail']['avatarUrl'] != null &&
                                                    userData.userData['detail']['avatarUrl'] != ""
                                                ? Container(
                                                    height: ScreenUtil.verticalScale(10.5),
                                                    width: ScreenUtil.verticalScale(10.5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.withValues(alpha: .9),
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(ScreenUtil.horizontalScale(12.5)),
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(ScreenUtil.horizontalScale(12.5)),
                                                        child: Image.network(
                                                          userData.userData['detail'] != null
                                                              ? userData.userData['detail']['avatarUrl']
                                                                      .startsWith('https://storage.cloud.google.com/')
                                                                  ? userData.userData['detail']['avatarUrl']
                                                                      .replaceFirst('https://storage.cloud.google.com/',
                                                                          'https://storage.googleapis.com/')
                                                                  : userData.userData['detail']['avatarUrl']
                                                              : "",
                                                          fit: BoxFit.cover,
                                                        )),
                                                  )
                                                : userData.userName != ""
                                                    ? Text(
                                                        userData.userName[0], // First character of the name
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.horizontalScale(12),
                                                          color: Colors.white, // Adjust size as needed
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : const SizedBox();
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.verticalScale(0.8),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) => userData.userName != ""
                                            ? Text(
                                                // 'Hi, Nick',
                                                userData.userName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.horizontalScale(6),
                                                  fontWeight: FontWeight.bold,
                                                  height: 1,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil.verticalScale(0.3),
                                      ),
                                      Consumer<UserDataProvider>(
                                        builder: (context, userData, child) => userData.userName != ""
                                            ? Text(
                                                userData.userEmail,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ScreenUtil.horizontalScale(3.5),
                                                  fontWeight: FontWeight.normal,
                                                  height: 1,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(5)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(context, "/seeAllAchievementPage");
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(ScreenUtil.verticalScale(1.4)),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.35),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: SvgPicture.asset(
                                                      "assets/img/verified (1).svg",
                                                      height: 22,
                                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                                    ),
                                                  ),
                                                  SizedBox(height: ScreenUtil.verticalScale(0.9)),
                                                  Builder(builder: (context) {
                                                    List<AchievementModel>? data = dataProvider?.achievementList
                                                        .where((element) =>
                                                            element.achievements!.any((e) => e.achieved == true))
                                                        .toList();

                                                    final achievements = data?.length;
                                                    return Column(
                                                      children: [
                                                        Text(
                                                          "$achievements",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: ScreenUtil.horizontalScale(3.2),
                                                            fontWeight: FontWeight.bold,
                                                            height: 1,
                                                          ),
                                                        ),
                                                        SizedBox(height: ScreenUtil.verticalScale(0.25)),
                                                        Text(
                                                          "Achievement${(achievements ?? 0) > 1 ? "s" : ""}",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: ScreenUtil.horizontalScale(3),
                                                            fontWeight: FontWeight.normal,
                                                            height: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(context, '/streak-calendar');
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(ScreenUtil.verticalScale(1.4)),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.35),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.local_fire_department_outlined,
                                                          color: Colors.white, size: 22),
                                                    ),
                                                    SizedBox(height: ScreenUtil.verticalScale(0.9)),
                                                    Builder(builder: (context) {
                                                      int streak = context.watch<MonthProvider>().streak;

                                                      return Column(
                                                        children: [
                                                          Text(
                                                            "$streak Day${streak > 1 ? "s" : ""}",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: ScreenUtil.horizontalScale(3.2),
                                                              fontWeight: FontWeight.bold,
                                                              height: 1,
                                                            ),
                                                          ),
                                                          SizedBox(height: ScreenUtil.verticalScale(0.25)),
                                                          Text(
                                                            "Streak${streak > 1 ? "s" : ""}",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: ScreenUtil.horizontalScale(3),
                                                              fontWeight: FontWeight.normal,
                                                              height: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    })
                                                  ],
                                                )),
                                            Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(ScreenUtil.verticalScale(1.4)),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.35),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.calendar_month, color: Colors.white, size: 22),
                                                ),
                                                SizedBox(height: ScreenUtil.verticalScale(0.9)),
                                                Builder(
                                                  builder: (context) {
                                                    String accountCreatedDate =
                                                        context.watch<UserDataProvider>().userData != null
                                                            ? context.watch<UserDataProvider>().userData["createdAt"]
                                                            : "";
                                                    DateTime targetDate = DateTime.parse(accountCreatedDate).toLocal();
                                                    DateTime today = DateTime.now();
                                                    int dayDifference = today.difference(targetDate).inDays;
                                                    return Column(
                                                      children: [
                                                        Text(
                                                          "$dayDifference Day${dayDifference > 1 ? "s" : ""}",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: ScreenUtil.horizontalScale(3.2),
                                                            fontWeight: FontWeight.bold,
                                                            height: 1,
                                                          ),
                                                        ),
                                                        SizedBox(height: ScreenUtil.verticalScale(0.25)),
                                                        Text(
                                                          "Since Joining",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: ScreenUtil.horizontalScale(3),
                                                            fontWeight: FontWeight.normal,
                                                            height: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: media.height / 2.28,
                    bottom: ScreenUtil.verticalScale(10),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: media.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil.horizontalScale(6),
                                vertical: ScreenUtil.verticalScale(3),
                              ),
                              child: Column(
                                children: [
                                  // settingsButton('Re-watch the tutorial', Icons.play_circle_outline,
                                  //     () => Navigator.pushNamed(context, '/watchtutorial', arguments: {"buttontext": "Back"})),
                                  // SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton(
                                      'My Profile', Icons.person, () => Navigator.pushNamed(context, '/myprofile')),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton(
                                      'Settings', Icons.settings, () => Navigator.pushNamed(context, '/SettingPage')),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton('Subscription', Icons.refresh, () async {
                                    bool isAppUser = userData?.user["singuptype"] != "web" ? true : false;
                                    if (isAppUser) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentDetailScreen(),
                                        ),
                                      );

                                      // await openAppSettings();
                                    } else {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String? token = prefs.getString('authToken');
                                      Uri url = Uri.parse('https://bbbdev1.wpenginepowered.com/?token=$token');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    }
                                  }),

                                  /// IF PUT BACK LANGUAGE SELECTION PART UNCOMMENT THIS

                                  // SizedBox(height: ScreenUtil.horizontalScale(4.5)),
                                  // settingsButton('Language', Icons.chat_bubble_outline, () => Navigator.pushNamed(context, '/languageScreen')),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton('Support', Icons.handshake, () => toSupportPage()),
                                  // SizedBox(
                                  //   height: ScreenUtil.horizontalScale(4.5),
                                  // ),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton('Terms of Use', Icons.description, () => toTermsOfUsePage()),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),
                                  settingsButton(
                                      'Privacy Policy', Icons.privacy_tip_rounded, () => toPrivacyPolicyPage()),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton('Delete Account', Icons.delete_sharp, () {
                                    AnimatedDialog.showAnimatedDialog(
                                      context: context,
                                      pageBuilder: (c1, anim1, anim2) => deleteAccount(context, c1),
                                    );
                                  }),
                                  SizedBox(height: ScreenUtil.verticalScale(2)),

                                  settingsButton('Log Out', Icons.logout, () => _handleLogout(context)),
                                  SizedBox(height: ScreenUtil.verticalScale(1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -(media.height / 2.25) + 0.3,
                        child: SizedBox(
                          height: media.height / 2.25,
                          width: media.width,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ClipPath(
                              clipper: DiagonalClipper(),
                              child: Container(
                                height: media.height / 11,
                                width: media.width / 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget deleteAccount(BuildContext context, BuildContext c1) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFFFFFF),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)).copyWith(top: ScreenUtil.verticalScale(2.5)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ScreenUtil.verticalScale(2)),
                    Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil.verticalScale(2.4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.horizontalScale(2), vertical: ScreenUtil.verticalScale(1)),
                      child: Text(
                        "Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil.verticalScale(2),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!c1.mounted) return;
                                Navigator.of(c1).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil.verticalScale(1.7),
                                ),
                                side: BorderSide(width: 2.0, color: AppColors.primaryColor),
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil.verticalScale(2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil.horizontalScale(2.5)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _deleteAccount(context);
                                if (!c1.mounted) return;
                                Navigator.of(c1).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil.verticalScale(1.7),
                                ),
                              ),
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  fontSize: ScreenUtil.verticalScale(2),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil.verticalScale(0.7)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(c1).pop();
                      },
                    ),
                    SizedBox(width: ScreenUtil.horizontalScale(2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsButton(String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyColor,
          borderRadius: BorderRadius.circular(ScreenUtil.verticalScale(4)),
        ),
        padding: EdgeInsets.all(
          ScreenUtil.verticalScale(1.5),
        ),
        // decoration: BoxDecoration(
        //   color: const Color(0xFFFAFAFA),
        //   borderRadius: BorderRadius.all(
        //     Radius.circular(
        //       ScreenUtil.verticalScale(7),
        //     ),
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: const Color(0xFF000000).withValues(alpha: 0.05),
        //       spreadRadius: 1,
        //       blurRadius: 3,
        //       offset: const Offset(0, 1),
        //     ),
        //   ],
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: ScreenUtil.verticalScale(3.8),
                ),
                SizedBox(
                  width: ScreenUtil.verticalScale(3),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: ScreenUtil.horizontalScale(4.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(ScreenUtil.verticalScale(0.3)),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: ScreenUtil.verticalScale(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
