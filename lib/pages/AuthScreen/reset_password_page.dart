import 'dart:convert';

import 'package:bbb/components/app_alert_dialog.dart';
import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/utils/cache_image_manager.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String image;

  const ResetPasswordScreen({super.key, required this.image});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailInputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  resetPassword(String emailAddress) async {
    if (emailAddress.isNotEmpty) {
      if (AppConstants.emailRegex.hasMatch(emailAddress)) {
        var response = await http.post(
          Uri.parse('https://bbbdev1.wpenginepowered.com/wp-json/custom/v1/send-password-reset'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': emailAddress,
          }),
        );

        if (response.statusCode == 200) {
          // Assuming the API returns 200 for a successful operation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AppAlertDialog(
                title: "Success",
                description: "Please check your email inbox for the password reset email.",
              );
            },
          );
        } else {
          // Handle error or unsuccessful operation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: "Error",
                description: "Failed to send reset email: ${response.body}",
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AppAlertDialog(
              title: "Warning",
              description: "Invalid email format",
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AppAlertDialog(
            title: "Warning",
            description: "Please input your email address",
          );
        },
      );
    }
  }

  String image = '';
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.image == "") {
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
      body: Form(
        key: _formKey,
        child: Stack(
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
                          ? CachedNetworkImageProvider(
                              image.startsWith('https://storage.cloud.google.com/')
                                  ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                                  : image,
                              cacheManager: CustomCacheManager())
                          // NetworkImage(
                          //         image.startsWith('https://storage.cloud.google.com/')
                          //             ? image.replaceFirst('https://storage.cloud.google.com/', 'https://storage.googleapis.com/')
                          //             : image,
                          //       )
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
                          margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(23)),
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
                bottom: -0.7,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(4.4)),
                        child: Column(
                          children: [
                            SizedBox(
                              height: ScreenUtil.verticalScale(3.2),
                            ),
                            Text(
                              'Reset your password',
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(3.32),
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(3.2),
                            ),
                            AppTextFormField(
                              hintText: 'Your Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {},
                              // validator: (value) {
                              //   return value!.isEmpty
                              //       ? 'Please, Enter Email Address'
                              //       : AppConstants.emailRegex.hasMatch(value)
                              //           ? null
                              //           : 'Invalid Email Address';
                              // },
                              controller: emailInputController,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: IconButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                      const Size(48, 48),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.email,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(14.2),
                            ),
                            ButtonWidget(
                              text: 'Send a request',
                              textColor: Colors.white,
                              color: AppColors.primaryColor,
                              onPress: () {
                                if (_formKey.currentState?.validate() == true) {
                                  resetPassword(emailInputController.text);
                                }
                              },
                              isLoading: isLoading,
                            ),
                            SizedBox(
                              height: ScreenUtil.horizontalScale(16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
        // Stack(
        //   children: [
        //     Stack(
        //       children: [
        //         Container(
        //           width: media.width,
        //           height: media.height / 3.5,
        //           decoration: const BoxDecoration(
        //             color: Colors.white,
        //           ),
        //         ),
        //         Container(
        //           width: media.width,
        //           height: media.height,
        //           decoration: BoxDecoration(
        //             image: DecorationImage(image: AssetImage('assets/img/back.jpg'), fit: BoxFit.cover, opacity: 1),
        //             borderRadius: BorderRadius.only(
        //               bottomRight: Radius.circular(ScreenUtil.verticalScale(8)),
        //             ),
        //           ),
        //         ),
        //         SafeArea(
        //           child: Container(
        //             margin: EdgeInsets.only(top: ScreenUtil.horizontalScale(25)),
        //             width: media.width,
        //             height: media.height / 7,
        //             decoration: const BoxDecoration(
        //               image: DecorationImage(image: AssetImage('assets/img/bbb-logo.png'), fit: BoxFit.fitHeight, opacity: 1),
        //             ),
        //           ),
        //         ),
        //         BackArrowWidget(onPress: () => {Navigator.pop(context)})
        //       ],
        //     ),
        //     // Align(
        //     //   alignment: Alignment.bottomCenter,
        //     //   child: Container(
        //     //     width: media.width,
        //     //     height: media.height / 3,
        //     //     decoration: BoxDecoration(
        //     //       image: DecorationImage(image: AssetImage('assets/img/back.jpg'), fit: BoxFit.cover, opacity: 1),
        //     //       borderRadius: BorderRadius.only(
        //     //         bottomRight: Radius.circular(ScreenUtil.verticalScale(8)),
        //     //       ),
        //     //     ),
        //     //   ),
        //     // ),
        //     Align(
        //       alignment: Alignment.bottomCenter,
        //       child: Container(
        //         width: media.width,
        //         height: media.height / 2,
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(ScreenUtil.verticalScale(7)),
        //           ),
        //         ),
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(horizontal: ScreenUtil.verticalScale(4.4)),
        //           child: Column(
        //             children: [
        //               SizedBox(
        //                 height: ScreenUtil.verticalScale(3.2),
        //               ),
        //               Text(
        //                 'Reset your password',
        //                 style: TextStyle(
        //                   fontSize: ScreenUtil.verticalScale(3.32),
        //                   color: AppColors.primaryColor,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //               const SizedBox(
        //                 height: 20,
        //               ),
        //               AppTextFormField(
        //                 hintText: 'Your Email',
        //                 keyboardType: TextInputType.emailAddress,
        //                 textInputAction: TextInputAction.next,
        //                 onChanged: (value) {},
        //                 // validator: (value) {
        //                 //   return value!.isEmpty
        //                 //       ? 'Please, Enter Email Address'
        //                 //       : AppConstants.emailRegex.hasMatch(value)
        //                 //           ? null
        //                 //           : 'Invalid Email Address';
        //                 // },
        //                 controller: emailInputController,
        //                 suffixIcon: Padding(
        //                   padding: const EdgeInsets.only(right: 15),
        //                   child: IconButton(
        //                     onPressed: () {},
        //                     style: ButtonStyle(
        //                       minimumSize: WidgetStateProperty.all(
        //                         const Size(48, 48),
        //                       ),
        //                     ),
        //                     icon: const Icon(
        //                       Icons.person,
        //                       color: Color(0XFFd9d9d9),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               const SizedBox(
        //                 height: 10,
        //               ),
        //               SizedBox(height: ScreenUtil.verticalScale(2)),
        //               ButtonWidget(
        //                 text: 'Send a request',
        //                 textColor: Colors.white,
        //                 color: AppColors.primaryColor,
        //                 onPress: () {
        //                   if (_formKey.currentState?.validate() == true) {
        //                     resetPassword(emailInputController.text);
        //                   }
        //                 },
        //                 isLoading: isLoading,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
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

  overlayState.insert(overlayEntry); //In here I changed the code ?.

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
