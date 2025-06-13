import 'dart:convert';

import 'package:bbb/components/app_alert_dialog.dart';
import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String image;

  const ResetPasswordScreen({super.key, required this.image});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailInputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DataProvider? dataProvider;

  bool isLoading = false;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

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
            description: "Please enter your email address to receive a password reset email.",
          );
        },
      );
    }
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
                Utils.appImage(
                  media,
                  // dataProvider?.screenBackgroundResponse?.imageForgot ?? "",
                  image: dataProvider!.cachedImageMap["imageForgot"],
                  imageKey: "imageForgot",
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
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              top: ScreenUtil.horizontalScale(50),
              child: Container(
                // height: 120,
                height: 150,
                width: media.width,
                decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('assets/img/bbb-logo.png'), fit: BoxFit.fitHeight, opacity: 1),
                ),
              ),
            ),
            Positioned(
                bottom: -0.7,
                child: Column(
                  children: [
                    Column(
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
                                  height: ScreenUtil.verticalScale(2),
                                ),
                                Text(
                                  // 'Enter your email to receive a password reset mail',
                                  "Enter your email address below. We’ll send you a mail to reset password.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ScreenUtil.verticalScale(1.65),
                                    height: 1.5,
                                    color: Color(0xff6f6f6f),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(2.5),
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
                                SizedBox(
                                  height: ScreenUtil.horizontalScale(7),
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
                                  height: ScreenUtil.verticalScale(4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
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
