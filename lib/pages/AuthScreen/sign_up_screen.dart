import 'dart:convert';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/pages/AuthScreen/confirmation_screen.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  final String image;

  const SignupPage({super.key, required this.image});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  DataProvider? dataProvider;

  bool isObscure = true;
  bool isLoading = false;

  String image = '';

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) async => updateImage());

    super.initState();
  }

  updateImage() async {
    if (widget.image == "") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      image = prefs.getString("login_image") ?? '';
    } else {
      image = widget.image;
    }
    setState(() {});
  }

  void signInUser(String emailAddress, String password, String userName,
      String lastName) async {
    if (emailAddress.isEmpty ||
        password.isEmpty ||
        userName.isEmpty ||
        lastName.isEmpty) {
      showBottomAlert(context, 'Please fill out the inputs');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse('${AppConstants.serverUrl}/api/users/signup_user');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'firstName': userName,
          'lastName': lastName,
          'email': emailAddress,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String message = data['message'];

        if (message == "User registered") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ConfirmationScreen()));

          // Navigator.pop(context);
          // await loginUser(emailAddress, password);
          // showBottomAlert(context,
          //     'Signup successfully with $emailAddress please login here.');
        } else {
          showBottomAlert(context, 'Failed to signup');
        }
      } else {
        showBottomAlert(context, 'Signup failed');
      }
    } catch (e) {
      showBottomAlert(context, 'An error occurred');
    } finally {
      setState(() {
        isLoading = false;
      });
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
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Consumer<DataProvider>(builder: (context, value, c) {
                  return AppImage.imageSignup(
                    value,
                    // media,
                    // image: dataProvider!.allImageList
                    //     .where((element) => element["key"] == "imageSignup")
                    //     .first["image"],
                    // // dataProvider?.screenBackgroundResponse?.imageSignup ?? "",
                    // // image: dataProvider!.cachedImageMap["imageSignup"],
                    // imageKey: "imageSignup",
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
              top: ScreenUtil.horizontalScale(29),
              child: Container(
                height: ScreenUtil.verticalScale(15),
                // height: 120,
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
                bottom: -1.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipPath(
                      clipper: DiagonalClipper(),
                      child: Container(
                        height: media.height / 9.8,
                        width: media.width / 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    Container(
                      width: media.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(ScreenUtil.verticalScale(8))),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil.verticalScale(4.4)),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: ScreenUtil.verticalScale(3.2),
                              ),
                              Text(
                                'Sign up',
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
                                hintText: 'First Name',
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {},
                                controller: fNameController,
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
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              AppTextFormField(
                                hintText: 'Last Name',
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {},
                                controller: lNameController,
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
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              AppTextFormField(
                                hintText: 'Your Email',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {},
                                controller: emailController,
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
                              SizedBox(height: 20),
                              AppTextFormField(
                                hintText: 'Your Password',
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                onChanged: (value) {},
                                controller: passwordController,
                                obscureText: isObscure,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscure = !isObscure;
                                      });
                                    },
                                    style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                        const Size(48, 48),
                                      ),
                                    ),
                                    icon: Icon(
                                      isObscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil.horizontalScale(9),
                              ),
                              ButtonWidget(
                                text: 'Sign up',
                                textColor: Colors.white,
                                color: AppColors.primaryColor,
                                onPress: () {
                                  if (_formKey.currentState?.validate() ==
                                      true) {
                                    signInUser(
                                      emailController.text,
                                      passwordController.text,
                                      fNameController.text,
                                      lNameController.text,
                                    );
                                  }
                                  return;
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (ctx) =>
                                  //         const ConfirmationScreen(image: ""),
                                  //   ),
                                  // );
                                },
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff888888),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(65, 30),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        alignment: Alignment.center),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil.horizontalScale(7.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
