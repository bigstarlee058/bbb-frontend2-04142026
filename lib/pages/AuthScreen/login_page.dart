import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/components/animated_dialog.dart';
import 'package:bbb/components/app_text_form_field.dart';
import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/AuthScreen/reset_password_page.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/main_page_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_image.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:bbb/values/clip_path.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  StringBuffer realPassword = StringBuffer();

  DataProvider? dataProvider;
  MonthProvider? monthProvider;
  bool isObscure = false;
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
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) {
    //     if (Platform.isIOS) {
    //       getOffering();
    //     }
    //   },
    // );
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
    dataProvider?.monthProvider =
        Provider.of<MonthProvider>(context, listen: false);
    log('dataProvider != null==========>>>>>${dataProvider != null}');
    if (dataProvider != null) {
      await dataProvider?.fetchMonthWorkouts(3);
    } else {
      debugPrint("dataProvider is null");
    }
  }

  void signInUser(String emailAddress, String password) async {
    if (emailAddress.isEmpty || password.isEmpty) {
      showBottomAlert(context, 'Please fill out the inputs');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(
          // 'https://bbbdev1.wpenginepowered.com/wp-json/jwt-auth/v1/token');
          'https://app.bootybybret.com/wp-json/jwt-auth/v1/token');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'username': emailAddress,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        try {
          await successResponse(response);
          setState1();
        } catch (e) {
          setState1();
          log('e==========>>>>>$e');
        }
      } /*else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        String code = data['code'];
        setState1();
        if (mounted) {
          if (code.toString().contains("incorrect_password")) {
            showBottomAlert(context,
                'Login Failed. Please check your email and password and, if needed, click "Forgot Password" below');
          } else if (code.toString().contains("invalid_email")) {
            AnimatedDialog.showAnimatedDialog(
              context: context,
              pageBuilder: (c1, anim1, anim2) => userNotFound(context, c1),
            );
          } else {
            showBottomAlert(context,
                'Something went wrong. Please check your connection and try again.');
          }
        }
        return;
      }*/
      else {
        final url = Uri.parse(
            // 'https://bbbdev1.wpenginepowered.com/wp-json/jwt-auth/v1/token');
            'https://bbb-backend-0df15cf8d1d2.herokuapp.com/api/users/signin_mobile');

        final response1 = await http.post(
          url,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            'email': emailAddress,
            'password': password,
          },
        );
        log('response1==========>>>>>${response1.statusCode}');

        if (response1.statusCode == 200) {
          await successResponse(response1);
        } else {
          setState1();
          if (mounted) {
            showBottomAlert(context,
                'Login Failed. Please check your email and password and, if needed, click "Forgot Password" below');
          }
        }
      }
    } catch (e) {
      setState1();
      if (mounted) {
        showBottomAlert(context,
            'Something went wrong. Please check your connection and try again.');
      }
    }
  }

  void setState1() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  Widget userNotFound(BuildContext context, BuildContext c1) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: ScreenUtil.horizontalScale(6)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: ScreenUtil.verticalScale(2)),
                        Text(
                          "User Not found",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: ScreenUtil.verticalScale(2.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(1.5),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(2),
                              vertical: ScreenUtil.verticalScale(1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "1.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    style: TextStyle(
                                      height: 1.4,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                      fontSize: ScreenUtil.verticalScale(1.8),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            "If you're a legacy user please contact ",
                                      ),
                                      TextSpan(
                                        text: "support@bootybybret.zendesk.com",
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        // Optional: make it clickable
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse(
                                                "mailto:support@bootybybret.zendesk.com"));
                                          },
                                      ),
                                      const TextSpan(
                                        text:
                                            " for help with migrating your account from old website to new. Do not attempt to sign up through the app here directly.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil.horizontalScale(2)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "2.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontSize: ScreenUtil.verticalScale(1.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                      height: 1.4,
                                      fontSize: ScreenUtil.verticalScale(1.8),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            "If you're a new user, please sign up at ",
                                      ),
                                      TextSpan(
                                        text: "app.bootybybret.com",
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse(
                                                "https://app.bootybybret.com"));
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil.verticalScale(1.5),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.all(ScreenUtil.horizontalScale(2)),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
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
                                    "Return to Login",
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
                ],
              ),
            ),
          ),
          Positioned(
            right: -ScreenUtil.verticalScale(1.2),
            top: -ScreenUtil.verticalScale(1.2),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: Padding(
                    padding: EdgeInsets.all(ScreenUtil.verticalScale(0.7)),
                    child: Icon(
                        size: ScreenUtil.verticalScale(2.5),
                        Icons.close,
                        color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> successResponse(http.Response response) async {
    final data = json.decode(response.body);
    await _saveLoginState(true);
    String token = data['token'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);

    await userData.fetchUserInfo(context, isFromLogin: true);

    // if (userData.user["active"] == 0 &&
    //     !userData.user["subscription"].containsKey('subscription_type')) {
    //   showBottomAlert(context,
    //       'Email not verified!\nPlease open the Gmail app and click the verification link sent to your email to confirm your account.');
    //   setState1();
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setBool('isLoggedIn', false);
    //   await prefs.clear();
    //   await preferences.clearPrefs();
    //   return;
    // }

    context.read<MainPageProvider>().changeTab(0);
    bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    bool isAppUser = userData.user["singuptype"] != "web" ? true : false;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async => await _initializeFetchData().then(
        (value) async {
          bool isFirstTime =
              (userData.user["createdAt"] == userData.user["updatedAt"]) ||
                  (userData.user["detail"] == null) ||
                  !userData.user["detail"].containsKey('bodyfat');
          await preferences.setBool(SharedPreference.isFirstTime, isFirstTime);
          CustomerInfo customerInfo = await Purchases.getCustomerInfo();

          dataProvider?.getAllAchievement(true);
          if (monthProvider?.monthDataModel == null) {
            if (mounted) {
              await monthProvider?.onInit(context: context).then(
                (value) async {
                  if (isAppUser) {
                    try {
                      Map<String, dynamic> subscriptionData =
                          userData.user["subscription"];

                      if (subscriptionData["subscription_type"] ==
                              "yearly_membership_1y_289" ||
                          subscriptionData["subscription_type"] ==
                              "monthly_membership_1m_29") {
                        DateTime now = DateTime.now().toUtc();
                        DateTime? endDate = (subscriptionData["end_date"] ?? "")
                                .toString()
                                .isEmpty
                            ? null
                            : DateTime.parse(subscriptionData["end_date"]);
                        if (endDate == null || (now.isAfter(endDate))) {
                          await _updateSubscriptionData(
                            isPrice: true,
                            type: "",
                            endDate: "",
                            startDate: "",
                            status: "free_user",
                          );
                        }
                      } else {
                        final entitlements = customerInfo.entitlements.active;

                        if (entitlements.values.first.productIdentifier ==
                                "monthly_membership_1m_29" ||
                            entitlements.values.first.productIdentifier ==
                                "yearly_membership_1y_289") {
                          final String startDate =
                              customerInfo.allPurchaseDates[
                                      subscriptionData["subscription_type"]] ??
                                  DateTime.now().toUtc().toString();

                          final String endDate =
                              customerInfo.allExpirationDates[
                                  subscriptionData["subscription_type"]]!;
                          DateTime now = DateTime.now().toUtc();

                          if ((now.isAfter(DateTime.parse(endDate)))) {
                            await _updateSubscriptionData(
                              isPrice: true,
                              type: "",
                              endDate: "",
                              startDate: "",
                              status: "free_user",
                            );
                          } else {
                            await _updateSubscriptionData(
                              isPrice: false,
                              type: subscriptionData["subscription_type"],
                              endDate: endDate,
                              startDate: startDate,
                              status: "subscribed_user",
                            );
                          }
                        } else {
                          final entitlements = customerInfo.entitlements.active;
                          if (entitlements.isNotEmpty &&
                              entitlements.values.first.isActive) {
                            final entitlement = entitlements.values.first;
                            final String planId = entitlement.productIdentifier;
                            final String startDate =
                                entitlement.originalPurchaseDate;

                            final String endDate = entitlement.expirationDate!;

                            final String status = entitlement.isActive
                                ? "subscribed_user"
                                : "free_user";
                            DateTime now = DateTime.now().toUtc();
                            if ((now.isAfter(DateTime.parse(endDate)))) {
                              await _updateSubscriptionData(
                                isPrice: true,
                                type: "",
                                endDate: "",
                                startDate: "",
                                status: "free_user",
                              );
                            } else {
                              await _updateSubscriptionData(
                                isPrice: false,
                                type: planId,
                                endDate: endDate,
                                startDate: startDate,
                                status: status,
                              );
                            }
                          } else {
                            DateTime now = DateTime.now().toUtc();

                            DateTime? endDate = (subscriptionData["end_date"] ??
                                        "")
                                    .toString()
                                    .isEmpty
                                ? null
                                : DateTime.parse(subscriptionData["end_date"]);

                            if (endDate == null || (now.isAfter(endDate))) {
                              await _updateSubscriptionData(
                                isPrice: true,
                                type: "",
                                endDate: "",
                                startDate: "",
                                status: "free_user",
                              );
                            }
                          }
                        }
                      }
                    } catch (e) {
                      debugPrint("Error fetching subscription: $e");
                    }
                  }

                  // if (Platform.isIOS && isAppUser) {
                  //   try {
                  //     CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                  //     if (customerInfo.entitlements.active.isNotEmpty) {
                  //       customerInfo.entitlements.active.forEach((key, entitlement) async {
                  //         final latestPurchaseDate = customerInfo.allPurchaseDates;
                  //         final identifier = entitlement.productIdentifier;
                  //
                  //         await _updateSubscriptionData(
                  //           type: identifier,
                  //           endDate: entitlement.expirationDate ?? "",
                  //           startDate: latestPurchaseDate[identifier] ?? "",
                  //           status: "subscribed_user",
                  //         );
                  //       });
                  //     } else {
                  //       await _updateSubscriptionData(
                  //         type: "",
                  //         endDate: "",
                  //         startDate: "",
                  //         status: "free_user",
                  //       );
                  //     }
                  //   } catch (e) {
                  //     debugPrint("Error fetching subscription: $e");
                  //   }
                  // }

                  if (/*Platform.isIOS && */ isAppUser) {
                    await userData
                        .fetchUserInfo(context, isFromLogin: true)
                        .then(
                      (value) async {
                        Map<String, dynamic> subscriptionData =
                            userData.user["subscription"];

                        if (subscriptionData["user_subscription_status"] ==
                            "free_user") {
                          if (mounted) {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SubscriptionPayWall()),
                            );
                          }
                        } else {
                          if (isFirstTime) {
                            if (mounted) {
                              await Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileBoardingScreen(
                                      welcomeDescription: '',
                                      welcomeImageUrl: '',
                                    ),
                                  ),
                                  (route) => false).then(
                                (value) async {
                                  await preferences.setBool(
                                      SharedPreference.isFirstTime, false);
                                },
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
                                            welcomeImageUrl: dataProvider
                                                    ?.screenBackgroundModel
                                                    ?.vimeoId ??
                                                "",
                                          )),
                                  (route) => false);
                            }
                          }
                        }
                      },
                    );
                  } else if (/*Platform.isIOS && */ !isAppUser) {
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
                    setState1();
                    if (isFirstTime) {
                      if (mounted) {
                        await Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileBoardingScreen(
                                welcomeDescription: '',
                                welcomeImageUrl: '',
                              ),
                            ),
                            (route) => false).then(
                          (value) async {
                            await preferences.setBool(
                                SharedPreference.isFirstTime, false);
                          },
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
                                      welcomeImageUrl: dataProvider
                                              ?.screenBackgroundModel
                                              ?.vimeoId ??
                                          "",
                                    )),
                            (route) => false);
                      }
                    }
                  } else {
                    if (isFirstTime) {
                      if (mounted) {
                        await Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileBoardingScreen(
                                welcomeDescription: '',
                                welcomeImageUrl: '',
                              ),
                            ),
                            (route) => false).then(
                          (value) async {
                            await preferences.setBool(
                                SharedPreference.isFirstTime, false);
                          },
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
                                welcomeImageUrl: dataProvider
                                        ?.screenBackgroundModel?.vimeoId ??
                                    "",
                              ),
                            ),
                            (route) => false);
                      }
                    }
                    setState1();
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  void onPressCreateAccount() async {
    if (!isLoading) {
      Navigator.pushNamed(context, AppRoutes.registerScreen);
    }
  }

  String monthPrice = "";
  String yearPrice = "";

  // Future<void> getOffering() async {
  //   try {
  //     Offerings fetched = await Purchases.getOfferings();
  //     setState(() {
  //       for (var offeringItem in fetched.all.values) {
  //         for (var package in offeringItem.availablePackages) {
  //           if (package.storeProduct.identifier == "monthly_membership_1m_29") {
  //             monthPrice = package.storeProduct.priceString;
  //           } else if (package.storeProduct.identifier ==
  //               "yearly_membership_1y_289") {
  //             yearPrice = package.storeProduct.priceString;
  //           }
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     log("Failed to fetch offerings: $e");
  //   }
  // }

  Future<void> _updateSubscriptionData({
    required String status,
    required String type,
    required String startDate,
    required String endDate,
    required bool isPrice,
  }) async {
    try {
      final Map<String, String> queryParams = {
        "user_subscription_status": status,
        "subscription_type": type,
        "purchase_date": startDate,
        "end_date": endDate,
        if (isPrice) "price": "",
      };

      Uri url =
          Uri.parse('${AppConstants.serverUrl}/api/users/update_subscription');
      String? userIdToken = await getAuthToken();

      final response = await http.put(
        url,
        body: queryParams,
        headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        userData.user = jsonResponse;
        userData.getUserDataFromJson(jsonResponse);
        // await userData.fetchUserInfo(context);
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  String previousMasked = "";

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
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
                  return AppImage.imageLogin(
                    value,
                    // media,
                    // image: dataProvider!.allImageList
                    //     .where((element) => element["key"] == "imageLogin")
                    //     .first["image"],
                    // // dataProvider?.screenBackgroundResponse?.imageLogin ?? "",
                    // // image: dataProvider!.cachedImageMap["imageLogin"],
                    // imageKey: "imageLogin",
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
                }),
              ],
            ),
            Positioned(
              top: ScreenUtil.horizontalScale(42),
              child: Container(
                // height: 120,
                height: ScreenUtil.verticalScale(15),
                width: media.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/bbb-logo.png'),
                    fit: BoxFit.fitHeight,
                    opacity: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipPath(
                    clipper: DiagonalClipper(),
                    child: Container(
                      height: media.height / 9.8,
                      width: media.width / 6,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                  ),
                  Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          ScreenUtil.verticalScale(7),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
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
                                    hintText: 'Your Email',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    controller: emailController,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.email,
                                            color: Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: ScreenUtil.verticalScale(2.2)),
                                Container(
                                  key: _passwordFieldKey,
                                  child: AppTextFormField(
                                    hintText: 'Your Password',
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    controller: passwordController,
                                    obscureText: false,
                                    onChanged: (value) {
                                      if (isObscure) {
                                        if (value.length <
                                            previousMasked.length) {
                                          if (realPassword.isNotEmpty) {
                                            realPassword = StringBuffer(
                                              realPassword.toString().substring(
                                                  0, realPassword.length - 1),
                                            );
                                          }
                                        } else if (value.length >
                                            previousMasked.length) {
                                          final newChar =
                                              value[value.length - 1];
                                          realPassword.write(newChar);
                                        }

                                        final masked = List.generate(
                                                realPassword.length, (_) => "•")
                                            .join();
                                        previousMasked = masked;

                                        passwordController.value =
                                            TextEditingValue(
                                          text: masked,
                                          selection: TextSelection.collapsed(
                                              offset: masked.length),
                                        );
                                      } else {
                                        realPassword
                                          ..clear()
                                          ..write(value);
                                        previousMasked = value;
                                      }
                                    },
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: IconButton(
                                        onPressed: () {
                                          isObscure = !isObscure;
                                          if (isObscure) {
                                            final masked = List.generate(
                                                realPassword.length,
                                                (_) => "•").join();
                                            passwordController.value =
                                                TextEditingValue(
                                              text: masked,
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: masked.length),
                                            );
                                          } else {
                                            passwordController.value =
                                                TextEditingValue(
                                              text: realPassword.toString(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset:
                                                          realPassword.length),
                                            );
                                          }
                                          setState(() {});
                                        },
                                        style: ButtonStyle(
                                            minimumSize:
                                                WidgetStateProperty.all(
                                                    const Size(48, 48))),
                                        icon: Icon(
                                          isObscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.grey.shade400,
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
                                              builder: (ctx) =>
                                                  const ResetPasswordScreen(
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
                                    previousMasked = passwordController.text;
                                    if (_formKey.currentState?.validate() ==
                                        true) {
                                      signInUser(
                                        emailController.text,
                                        realPassword.toString(),
                                      );
                                    }
                                  },
                                  isLoading: isLoading,
                                ),
                                SizedBox(
                                  height: ScreenUtil.verticalScale(0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: ScreenUtil.verticalScale(1.5),
                                color: Color(0xff888888),
                              ),
                            ),
                            TextButton(
                              onPressed: onPressCreateAccount,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(65, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.center),
                              child: Text(
                                'Sign up for a new account',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil.verticalScale(1.5),
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
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
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
    ),
  );

  overlayState.insert(overlayEntry);

  // Remove the alert after 3 seconds
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry.remove();
  });
}
