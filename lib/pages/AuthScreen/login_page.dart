import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/AuthScreen/reset_password_page.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  DataProvider? dataProvider;
  MonthProvider? monthProvider;
  bool isObscure = true;
  bool isLoading = false;
  ImageProvider? imageProvider;
  late UserDataProvider userData;

  late MainPageProvider mainPageProvider;

  @override
  void initState() {
    super.initState();
    mainPageProvider = Provider.of<MainPageProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (Platform.isIOS) {
          getOffering();
        }
      },
    );
    _scrollController = ScrollController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailFocusNode.addListener(() {
      _emailFocusNode.addListener(() {
        if (_emailFocusNode.hasFocus) {
          _scrollToField(_emailFieldKey);
        }
      });

      _passwordFocusNode.addListener(() {
        if (_passwordFocusNode.hasFocus) {
          _scrollToField(_passwordFieldKey);
        }
      });
    });
  }

  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();
  Future<void> _saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _initializeFetchData() async {
    debugPrint("this  is initial state func");
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider?.monthProvider = Provider.of<MonthProvider>(context, listen: false);
    if (dataProvider != null) {
      log('_initializeFetchData=========11111=========>>>>>${DateTime.now()}');
      await dataProvider?.fetchMonthWorkouts(3);
      log('_initializeFetchData=========22222=========>>>>>${DateTime.now()}');
    } else {
      debugPrint("dataProvider is null");
    }
  }

  void signInUser(String emailAddress, String password) async {
    log('responseData=========1111=========>>>>>${DateTime.now()}');

    if (emailAddress.isEmpty || password.isEmpty) {
      showBottomAlert(context, 'Please fill out the inputs');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse('https://bbbdev1.wpenginepowered.com/wp-json/jwt-auth/v1/token');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'username': emailAddress,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        log('responseData=========2222=========>>>>>${DateTime.now()}');

        final data = json.decode(response.body);
        await _saveLoginState(true);
        String token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        log('responseData=========3333=========>>>>>${DateTime.now()}');

        context.read<MainPageProvider>().changeTab(0);
        bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
        await userData.fetchUserInfo();
        bool isAppUser = userData.user["singuptype"] != "web" ? true : false;
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async => await _initializeFetchData().then(
            (value) async {
              log('responseData=========4444=========>>>>>${DateTime.now()}');

              dataProvider?.getAllAchievement(true);
              log('responseData=========5555=========>>>>>${DateTime.now()}');

              if (monthProvider?.monthDataModel == null) {
                if (mounted) {
                  await monthProvider?.onInit(context: context).then(
                    (value) async {
                      log('responseData=========6666=========>>>>>${DateTime.now()}');

                      if (Platform.isIOS && isAppUser) {
                        try {
                          CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                          if (customerInfo.entitlements.active.isNotEmpty) {
                            customerInfo.entitlements.active.forEach((key, entitlement) async {
                              final latestPurchaseDate = customerInfo.allPurchaseDates;
                              final identifier = entitlement.productIdentifier;

                              await _updateSubscriptionData(
                                type: identifier,
                                endDate: entitlement.expirationDate ?? "",
                                startDate: latestPurchaseDate[identifier] ?? "",
                                status: "subscribed_user",
                              );
                            });
                          } else {
                            await _updateSubscriptionData(
                              type: "",
                              endDate: "",
                              startDate: "",
                              status: "free_user",
                            );
                          }
                          await userData.fetchUserInfo();
                        } catch (e) {
                          debugPrint("Error fetching subscription: $e");
                        }
                      }

                      log('responseData=========7777=========>>>>>${DateTime.now()}');

                      Map<String, dynamic> subscriptionData = userData.user["subscription"];
                      if (Platform.isIOS && isAppUser) {
                        bool isFirstTime = userData.user["createdAt"] != userData.user["updatedAt"];

                        await preferences.setBool(SharedPreference.isFirstTime, isFirstTime);
                        bool isFirstTime1 = await preferences.getBool(SharedPreference.isFirstTime) ?? false;

                        if (subscriptionData["user_subscription_status"] == "free_user") {
                          if (mounted) {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SubscriptionPayWall()),
                            );
                          }
                        } else {
                          if (mounted) {
                            await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainPage(
                                          showWelcomeModal: !hasSeenWelcome,
                                          welcomeDescription: "",
                                          welcomeImageUrl: dataProvider?.screenBackgroundModel?.vimeoId ?? "",
                                        )),
                                (route) => false);
                          }
                        }
                      } else if (Platform.isIOS && !isAppUser) {
                        // DateTime? endDate = subscriptionData["end_date"].toString().isEmpty
                        //     ? null
                        //     : DateTime.parse(subscriptionData["end_date"] ?? "");
                        //
                        // DateTime now = await NTP.now();
                        //
                        // if (subscriptionData["user_subscription_status"] == "free_user" ||
                        //     (endDate != null && now.isAfter(endDate))) {
                        //   if (mounted) {
                        //     Navigator.pushReplacement(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const WooSubscriptionPayWall(),
                        //       ),
                        //     );
                        //   }
                        // } else {
                        //   if (mounted) {
                        //     await Navigator.pushAndRemoveUntil(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => MainPage(
                        //                 showWelcomeModal: !hasSeenWelcome,
                        //                 welcomeDescription:
                        //                     descriptionData['description'] ?? "",
                        //                 welcomeImageUrl: descriptionData['vimeoId'])),
                        //         (route) => false);
                        //   }
                        // }
                        WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) {
                            setState(() {
                              isLoading = false;
                            });
                          },
                        );

                        if (mounted) {
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage(
                                        showWelcomeModal: !hasSeenWelcome,
                                        welcomeDescription: "",
                                        welcomeImageUrl: dataProvider?.screenBackgroundModel?.vimeoId ?? "",
                                      )),
                              (route) => false);
                        }
                      } else {
                        if (mounted) {
                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainPage(
                                  showWelcomeModal: !hasSeenWelcome,
                                  welcomeDescription: "",
                                  welcomeImageUrl: dataProvider?.screenBackgroundModel?.vimeoId ?? "",
                                ),
                              ),
                              (route) => false);
                        }
                        WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) {
                            setState(() {
                              isLoading = false;
                            });
                          },
                        );
                      }
                    },
                  );
                }
              }
            },
          ),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            setState(() {
              isLoading = false;
            });
          },
        );
        if (mounted) {
          showBottomAlert(context, 'Login failed');
        }
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          setState(() {
            isLoading = false;
          });
        },
      );
      if (mounted) {
        showBottomAlert(context, 'User not found!');
      }
    }
  }

  void onPressCreateAccount() async {
    if (!isLoading) {
      Navigator.pushNamed(context, AppRoutes.registerScreen);
    }
  }

  String monthPrice = "";
  String yearPrice = "";

  Future<void> getOffering() async {
    try {
      Offerings fetched = await Purchases.getOfferings();
      setState(() {
        for (var offeringItem in fetched.all.values) {
          for (var package in offeringItem.availablePackages) {
            if (package.storeProduct.identifier == "monthly_membership_1m_29") {
              monthPrice = package.storeProduct.priceString;
            } else if (package.storeProduct.identifier == "yearly_membership_1y_289") {
              yearPrice = package.storeProduct.priceString;
            }
          }
        }
      });
    } catch (e) {
      log("Failed to fetch offerings: $e");
    }
  }

  Future<void> _updateSubscriptionData({
    required String status,
    required String type,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final Map<String, String> queryParams = {
        "user_subscription_status": status,
        "subscription_type": type,
        "price": type == ""
            ? ""
            : type == "monthly_membership_1m_29"
                ? monthPrice
                : yearPrice,
        "purchase_date": startDate,
        "end_date": endDate,
      };

      Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/update_subscription');
      String? userIdToken = await getAuthToken();

      final response = await http.put(
        url,
        body: queryParams,
        headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        userData.user = jsonResponse;
        await userData.fetchUserInfo();
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  late ScrollController _scrollController;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  // void _scrollToField() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 200),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  void _scrollToField(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _scrollToField(_emailFieldKey);

    _scrollToField(_passwordFieldKey);

    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Utils.appImage(
                  media,
                  // dataProvider?.screenBackgroundResponse?.imageLogin ?? "",
                  image: dataProvider!.cachedImageMap["imageLogin"],
                  imageKey: "imageLogin",
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
                ),
              ],
            ),
            Positioned(
              top: ScreenUtil.horizontalScale(42),
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
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil.verticalScale(42)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: ScreenUtil.verticalScale(3.2),
                            ),
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(3.32),
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(3.2),
                            ),
                            Container(
                              key: _emailFieldKey,
                              child: AppTextFormField(
                                onTap: () {
                                  _scrollToField(_emailFieldKey);
                                  setState(() {});
                                },
                                hintText: 'Your Email',
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                controller: emailController,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SizedBox(
                                    height: 48,
                                    width: 48,
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(Icons.email, color: Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(2.2)),
                            Container(
                              key: _passwordFieldKey,
                              child: AppTextFormField(
                                onTap: () {
                                  _scrollToField(_passwordFieldKey);
                                  setState(() {});
                                },
                                hintText: 'Your Password',
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                controller: passwordController,
                                obscureText: isObscure,
                                focusNode: _passwordFocusNode,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => isObscure = !isObscure);
                                      },
                                      child: Icon(
                                        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(1.5)),
                            Text.rich(TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFA51E22),
                                  ),
                                  text: "Forgot password?",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => const ResetPasswordScreen(
                                            image: '',
                                          ),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            )),
                            SizedBox(
                              height: ScreenUtil.verticalScale(4.2),
                            ),
                            ButtonWidget(
                              text: 'Sign in',
                              textColor: Colors.white,
                              color: AppColors.primaryColor,
                              onPress: () {
                                if (_formKey.currentState?.validate() == true) {
                                  signInUser(
                                    emailController.text,
                                    passwordController.text,
                                  );
                                }
                              },
                              isLoading: isLoading,
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(0.8),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff888888),
                                  ),
                                ),
                                TextButton(
                                  onPressed: onPressCreateAccount,
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(65, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.center),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.verticalScale(3.4),
                            ),
                          ],
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

  overlayState.insert(overlayEntry);

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
