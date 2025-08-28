import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/IntroScreen/version_update_screen.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/theme_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataProvider? dataProvider;
  MonthProvider? monthProvider;
  ThemeProvider? themeProvider;
  late UserDataProvider userData;
  bool isDarkMode = false;
  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    userData = Provider.of<UserDataProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    monthProvider = Provider.of<MonthProvider>(context, listen: false);

    // _handleLogout(context);
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (timeStamp) {
    //     getOffering();
    //   },
    // );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await preferences.setBool(SharedPreference.isUpdatePopUP, false);

        final raw4 = await preferences.getBool(SharedPreference.isDarkMode);
        if (raw4 == null) {
          isDarkMode = false;
          await preferences.setBool(SharedPreference.isDarkMode, isDarkMode);
        } else {
          isDarkMode = raw4;
        }
        themeProvider?.toggleTheme(isDarkMode);
      },
    );
    _checkLoginStatus();
  }

  Future<void> _initializeFetchData() async {
    debugPrint("this  is initial state func");
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider?.monthProvider =
        Provider.of<MonthProvider>(context, listen: false);
    if (dataProvider != null) {
      await dataProvider?.fetchMonthWorkouts(3);
    } else {
      debugPrint("dataProvider is null");
    }
  }

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    try {
      await dataProvider?.fetchAppVersion();
    } catch (e) {
      log('e==========>>>>>$e');
    }
    await loginStatus(isLoggedIn);
  }

  Future<void> loginStatus(bool isLoggedIn) async {
    try {
      await dataProvider?.getAppBGs();
    } catch (e) {
      log('e==========>>>>>$e');
    }

    if (isLoggedIn) {
      // await Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ProfileBoardingScreen(
      //       welcomeDescription: '',
      //       welcomeImageUrl: '',
      //     ),
      //   ),
      //   (route) => false,
      // );

      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await _initializeFetchData().then(
          (value) async {
            if (monthProvider?.monthDataModel == null) {
              try {
                await userData.fetchUserInfo(context).then(
                  (value) async {
                    String token = await getAuthToken();

                    if (token.isEmpty) {
                      _handleLogout(context, sessionExpired);
                      return;
                    }

                    try {
                      dataProvider?.getAllAchievement(true);
                      dataProvider?.fetchFeaturedChalleng();
                    } catch (e) {
                      log('e==========>>>>>$e');
                    }

                    await monthProvider?.onInit(context: context);
                    bool isFirstTime = userData.user["createdAt"] ==
                            userData.user["updatedAt"] ||
                        (userData.user["detail"] == null ||
                            !userData.user["detail"].containsKey('bodyfat'));
                    CustomerInfo customerInfo =
                        await Purchases.getCustomerInfo();

                    await preferences.setBool(
                        SharedPreference.isFirstTime, isFirstTime);

                    bool isAppUser =
                        userData.user["singuptype"] != "web" ? true : false;

                    if (isAppUser) {
                      try {
                        Map<String, dynamic> subscriptionData =
                            userData.user["subscription"];

                        if (subscriptionData["subscription_type"] ==
                                "yearly_membership_1y_289" ||
                            subscriptionData["subscription_type"] ==
                                "monthly_membership_1m_29") {
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
                        } else {
                          final entitlements = customerInfo.entitlements.active;

                          if (entitlements.isNotEmpty) {
                            if (entitlements.values.first.productIdentifier ==
                                    "monthly_membership_1m_29" ||
                                entitlements.values.first.productIdentifier ==
                                    "yearly_membership_1y_289") {
                              DateTime now = DateTime.now().toUtc();
                              final String startDate = customerInfo
                                          .allPurchaseDates[
                                      subscriptionData["subscription_type"]] ??
                                  now.toString();

                              final String endDate =
                                  customerInfo.allExpirationDates[
                                      subscriptionData["subscription_type"]]!;

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
                              final entitlement = entitlements.values.first;

                              if (entitlements.isNotEmpty &&
                                  entitlement.isActive) {
                                final String planId =
                                    entitlement.productIdentifier;

                                final String startDate =
                                    entitlement.originalPurchaseDate;

                                final String endDate =
                                    entitlement.expirationDate!;

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
                                DateTime? endDate =
                                    (subscriptionData["end_date"] ?? "")
                                            .toString()
                                            .isEmpty
                                        ? null
                                        : DateTime.parse(
                                            subscriptionData["end_date"]);

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
                      } catch (e) {
                        debugPrint("Error fetching subscription: $e");
                      }
                    }

                    if (isAppUser) {
                      await userData.fetchUserInfo(context).then(
                        (value) async {
                          Map<String, dynamic> subscriptionData =
                              userData.user["subscription"];

                          if (subscriptionData["user_subscription_status"] !=
                              "free_user") {
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
                                  (route) => false,
                                ).then((value) async {
                                  await preferences.setBool(
                                      SharedPreference.isFirstTime, false);
                                });
                              }
                            } else {
                              if (mounted) {
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainPage(
                                      welcomeDescription: '',
                                      welcomeImageUrl: '',
                                    ),
                                  ),
                                );
                              }
                              await isFromNotification();
                            }
                          } else {
                            if (mounted) {
                              await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionPayWall(),
                                ),
                              );
                            }
                          }
                        },
                      );
                    } else if (!isAppUser) {
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
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(
                                  welcomeDescription: '', welcomeImageUrl: ''),
                            ),
                          );
                          await isFromNotification();
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
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(
                                  welcomeDescription: '', welcomeImageUrl: ''),
                            ),
                          );
                          await isFromNotification();
                        }
                      }
                    }
                  },
                );
              } catch (e) {
                if (mounted) {
                  _handleLogout(context, sessionExpired);
                  log('ERROR==========>>>>>$e');
                }
              }
            }
          },
        ),
      );
    } else {
      await Future.delayed(Duration(milliseconds: 2500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding').then(
          (value) {
            final bool isIOS = Platform.isIOS;
            final bool isPopupEnable = isIOS
                ? (dataProvider?.newVersionModel?.ios?.showPopUp ?? false)
                : (dataProvider?.newVersionModel?.android?.showPopUp ?? false);
            if (isPopupEnable == true) {
              navigateAppVersion();
            }
          },
        );
      }
    }
  }

  navigateAppVersion() async {
    final bool isIOS = Platform.isIOS;
    final bool isPopupEnable = isIOS
        ? (dataProvider?.newVersionModel?.ios?.showPopUp ?? false)
        : (dataProvider?.newVersionModel?.android?.showPopUp ?? false);

    if (isPopupEnable == false) return false;

    PackageInfo version = await getCurrentAppVersion();
    await Future.delayed(Duration(milliseconds: 200));

    final String currentVersion = version.version;

    final String? requiredVersion = isIOS
        ? dataProvider?.newVersionModel?.ios?.version
        : dataProvider?.newVersionModel?.android?.version;
    final bool forceUpdate = isIOS
        ? (dataProvider?.newVersionModel?.ios?.forceUpdate ?? false)
        : (dataProvider?.newVersionModel?.android?.forceUpdate ?? false);

    bool shouldShowPopup =
        _isLowerVersion(currentVersion, requiredVersion ?? "");

    if (!shouldShowPopup) return false;

    // if (currentVersion == (requiredVersion ?? "")) return false;

    if (mounted) {
      final route = MaterialPageRoute(builder: (_) => VersionUpdateScreen());
      forceUpdate
          ? await Navigator.pushReplacement(context, route)
          : await Navigator.push(context, route);
    }
  }

  bool _isLowerVersion(String current, String required) {
    List<int> currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> requiredParts =
        required.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < requiredParts.length; i++) {
      int currentVal = i < currentParts.length ? currentParts[i] : 0;
      int requiredVal = requiredParts[i];
      if (currentVal < requiredVal) return true;
      if (currentVal > requiredVal) return false;
    }
    return false;
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
    }
  }

  void _handleLogout(BuildContext context, String msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();
    await DatabaseHelper().clearAllTables();
    await preferences.clearPrefs();

    Navigator.pushNamed(context, AppRoutes.loginScreen);

    showBottomAlert(context, msg);
    await prefs.setBool('hasSeenWelcome', hasSeenWelcome);
  }

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
        headers: <String, String>{'AUTH_TOKEN': userIdToken},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        userData.user = jsonResponse["result"];
        userData.getUserDataFromJson(jsonResponse["result"]);
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/img/logo.png",
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}
