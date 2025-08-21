import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SetPasswordScreen extends StatefulWidget {
  final String token;
  const SetPasswordScreen({super.key, required this.token});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DataProvider? dataProvider;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    cPasswordController.dispose();
    super.dispose();
  }

  bool loader = false;

  resetPassword(String password, String cPassword) async {
    try {
      if (password.isNotEmpty && cPassword.isNotEmpty) {
        if (password.trim() == cPassword.trim()) {
          loader = true;
          setState(() {});
          Uri url =
              Uri.parse('${AppConstants.serverUrl}/api/users/reset_password');

          var response = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'password': password.trim(),
              'confirmPassword': cPassword.trim(),
              'token': widget.token
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            String msg = data['message'].toString();
            showBottomAlert(context, msg);
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            final data = jsonDecode(response.body);
            showBottomAlert(
                context, "Reset password failed : ${data["message"]}");
          }
        } else {
          showBottomAlert(
            context,
            "Password and confirm password do not match.",
          );
        }
      } else {
        showBottomAlert(
          context,
          "Please enter password and confirm password.",
        );
      }
    } catch (e) {
      log('e==========>>>>>$e');
    } finally {
      loader = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid ? true : false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Consumer<DataProvider>(builder: (context, value, c) {
                    return AppImage.imageForgot(
                      value,
                      // media,
                      // image: dataProvider!.allImageList
                      //     .where((element) => element["key"] == "imageForgot")
                      //     .first["image"],
                      // // dataProvider?.screenBackgroundResponse?.imageForgot ?? "",
                      // // image: dataProvider!.cachedImageMap["imageForgot"],
                      // imageKey: "imageForgot",
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
                    );
                  })
                ],
              ),
              Positioned(
                top: ScreenUtil.horizontalScale(50),
                child: Container(
                  // height: 120,
                  height: ScreenUtil.verticalScale(15),
                  width: media.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/bbb-logo.png'),
                        fit: BoxFit.fitHeight,
                        opacity: 1),
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
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                          Container(
                            width: media.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    ScreenUtil.verticalScale(7)),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.verticalScale(4.4)),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: ScreenUtil.verticalScale(3.2),
                                  ),
                                  Text(
                                    'Set your password',
                                    style: TextStyle(
                                      fontSize: ScreenUtil.verticalScale(3.32),
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil.verticalScale(2.5),
                                  ),
                                  AppTextFormField(
                                    hintText: 'Password',
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) {},
                                    controller: passwordController,
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
                                    height: ScreenUtil.verticalScale(2),
                                  ),
                                  AppTextFormField(
                                    hintText: 'Confirm Password',
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (value) {},
                                    // validator: (value) {
                                    //   return value!.isEmpty
                                    //       ? 'Please, Enter Email Address'
                                    //       : AppConstants.emailRegex.hasMatch(value)
                                    //           ? null
                                    //           : 'Invalid Email Address';
                                    // },
                                    controller: cPasswordController,
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
                                    text: 'Set Password',
                                    textColor: Colors.white,
                                    color: AppColors.primaryColor,
                                    onPress: loader
                                        ? () {}
                                        : () {
                                            if (_formKey.currentState
                                                    ?.validate() ==
                                                true) {
                                              resetPassword(
                                                passwordController.text,
                                                cPasswordController.text,
                                              );
                                            }
                                          },
                                    isLoading: loader,
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
      ),
    );
  }
}
