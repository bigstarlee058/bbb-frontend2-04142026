import 'dart:convert';
import 'dart:developer';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/theme_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getOffering();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
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

  // void _handleLogout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isLoggedIn', false);
  //   await prefs.clear();
  //   await preferences.clearPrefs();
  //   await DatabaseHelper().clearAllTables();
  //   await preferences.clearPrefs();
  //   context.read<MonthProvider>().clearAllValues();
  //   dataProvider?.achievementList = [];
  //   Navigator.of(context).pushNamedAndRemoveUntil(
  //     AppRoutes.onBoardingScreen,
  //     (Route<dynamic> route) {
  //       log("ROUTE NAME ${route.settings.name}");
  //       return route.settings.name == AppRoutes.onBoardingScreen;
  //     },
  //   );
  //
  //   Navigator.pushNamed(context, AppRoutes.loginScreen);
  // }

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await loginStatus(isLoggedIn);

    // await dataProvider?.fetchAppVersion();
    //
    // PackageInfo version = await getCurrentAppVersion();
    //
    // if (Platform.isIOS) {
    //   if (version.version ==
    //       (dataProvider?.newVersionModel?.latestVersion ?? "")) {
    //     await loginStatus(isLoggedIn);
    //   } else {
    //     if (mounted) {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => VersionUpdateScreen(),
    //         ),
    //       );
    //     }
    //   }
    // } else {
    //   await loginStatus(isLoggedIn);
    // }
  }

  Future<void> loginStatus(bool isLoggedIn) async {
    dataProvider?.getAppBGs();
    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await _initializeFetchData().then(
          (value) async {
            dataProvider?.getAllAchievement(true);
            dataProvider?.fetchFeaturedChalleng();
            if (monthProvider?.monthDataModel == null) {
              if (mounted) {
                await monthProvider?.onInit(context: context);
                await userData.fetchUserInfo(context).then((value) async {
                  bool isFirstTime = userData.user["createdAt"] ==
                          userData.user["updatedAt"] ||
                      (userData.user["detail"] == null ||
                          !userData.user["detail"].containsKey('bodyfat'));

                  await preferences.setBool(
                      SharedPreference.isFirstTime, isFirstTime);

                  bool isAppUser =
                      userData.user["singuptype"] != "web" ? true : false;
                  log('isAppUser==========>>>>>$isAppUser');
                  if (/*Platform.isIOS &&*/ isAppUser) {
                    try {
                      Map<String, dynamic> subscriptionData =
                          userData.user["subscription"];
                      DateTime now = DateTime.now().toUtc();
                      DateTime? endDate = (subscriptionData["end_date"] ?? "")
                              .toString()
                              .isEmpty
                          ? null
                          : DateTime.parse(subscriptionData["end_date"]);

                      if (endDate == null || (now.isAfter(endDate))) {
                        await _updateSubscriptionData(
                          type: "",
                          endDate: "",
                          startDate: "",
                          status: "free_user",
                        );
                      }
                    } catch (e) {
                      debugPrint("Error fetching subscription: $e");
                    }
                  }

                  if (/*Platform.isIOS &&*/ isAppUser) {
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
                  } else if (/*Platform.isIOS &&*/ !isAppUser) {
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
                });
              }
            }
          },
        ),
      );
    } else {
      await Future.delayed(Duration(milliseconds: 2500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
    }
  }

  Future<void> getOffering() async {
    try {
      await Purchases.getOfferings();
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
        "price": "",
        "purchase_date": startDate,
        "end_date": endDate,
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
        await userData.fetchUserInfo(context);
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
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

/*
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/theme_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (Platform.isIOS) {
          getOffering();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
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

  // void _handleLogout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isLoggedIn', false);
  //   await prefs.clear();
  //   await preferences.clearPrefs();
  //   await DatabaseHelper().clearAllTables();
  //   await preferences.clearPrefs();
  //   context.read<MonthProvider>().clearAllValues();
  //   dataProvider?.achievementList = [];
  //   Navigator.of(context).pushNamedAndRemoveUntil(
  //     AppRoutes.onBoardingScreen,
  //     (Route<dynamic> route) {
  //       log("ROUTE NAME ${route.settings.name}");
  //       return route.settings.name == AppRoutes.onBoardingScreen;
  //     },
  //   );
  //
  //   Navigator.pushNamed(context, AppRoutes.loginScreen);
  // }

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await loginStatus(isLoggedIn);

    // await dataProvider?.fetchAppVersion();
    //
    // PackageInfo version = await getCurrentAppVersion();
    //
    // if (Platform.isIOS) {
    //   if (version.version ==
    //       (dataProvider?.newVersionModel?.latestVersion ?? "")) {
    //     await loginStatus(isLoggedIn);
    //   } else {
    //     if (mounted) {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => VersionUpdateScreen(),
    //         ),
    //       );
    //     }
    //   }
    // } else {
    //   await loginStatus(isLoggedIn);
    // }
  }

  Future<void> loginStatus(bool isLoggedIn) async {
    dataProvider?.getAppBGs();
    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await _initializeFetchData().then(
          (value) async {
            dataProvider?.getAllAchievement(true);
            dataProvider?.fetchFeaturedChalleng();
            if (monthProvider?.monthDataModel == null) {
              if (mounted) {
                await monthProvider?.onInit(context: context);
                await userData.fetchUserInfo(context).then((value) async {
                  bool isFirstTime = userData.user["createdAt"] ==
                          userData.user["updatedAt"] ||
                      (userData.user["detail"] == null ||
                          !userData.user["detail"].containsKey('bodyfat'));

                  await preferences.setBool(
                      SharedPreference.isFirstTime, isFirstTime);

                  bool isAppUser =
                      userData.user["singuptype"] != "web" ? true : false;
                  if (Platform.isIOS && isAppUser) {
                    try {
                      Map<String, dynamic> subscriptionData =
                          userData.user["subscription"];
                      DateTime now = DateTime.now().toUtc();
                      DateTime? endDate = (subscriptionData["end_date"] ?? "")
                              .toString()
                              .isEmpty
                          ? null
                          : DateTime.parse(subscriptionData["end_date"]);

                      if (endDate == null || (now.isAfter(endDate))) {
                        await _updateSubscriptionData(
                          type: "",
                          endDate: "",
                          startDate: "",
                          status: "free_user",
                        );
                      }
                    } catch (e) {
                      debugPrint("Error fetching subscription: $e");
                    }
                  }
                  if (Platform.isIOS && isAppUser) {
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
                                  builder: (context) =>
                                      const SubscriptionPayWall(),
                                ),
                              );
                            }
                          }
                        }
                      },
                    );
                  } else if (Platform.isIOS && !isAppUser) {
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
                });
              }
            }
          },
        ),
      );
    } else {
      await Future.delayed(Duration(milliseconds: 2500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
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
            } else if (package.storeProduct.identifier ==
                "yearly_membership_1y_289") {
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
        await userData.fetchUserInfo(context);
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
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
*/

/// WEB VALIDATION

/*import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/IntroScreen/profile_boarding_screen.dart';
import 'package:bbb/pages/IntroScreen/version_update_screen.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/theme_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SubscriptionPage/woo_subscription_pay_wall.dart';

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
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
        if (Platform.isIOS) {
          getOffering();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async {
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

  // void _handleLogout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isLoggedIn', false);
  //   await prefs.clear();
  //   await preferences.clearPrefs();
  //   await DatabaseHelper().clearAllTables();
  //   await preferences.clearPrefs();
  //   context.read<MonthProvider>().clearAllValues();
  //   dataProvider?.achievementList = [];
  //   Navigator.of(context).pushNamedAndRemoveUntil(
  //     AppRoutes.onBoardingScreen,
  //     (Route<dynamic> route) {
  //       log("ROUTE NAME ${route.settings.name}");
  //       return route.settings.name == AppRoutes.onBoardingScreen;
  //     },
  //   );
  //
  //   Navigator.pushNamed(context, AppRoutes.loginScreen);
  // }

  Future<PackageInfo> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await loginStatus(isLoggedIn);

    // await dataProvider?.fetchAppVersion();
    //
    // PackageInfo version = await getCurrentAppVersion();
    //
    // if (Platform.isIOS) {
    //   if (version.version ==
    //       (dataProvider?.newVersionModel?.latestVersion ?? "")) {
    //     await loginStatus(isLoggedIn);
    //   } else {
    //     if (mounted) {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => VersionUpdateScreen(),
    //         ),
    //       );
    //     }
    //   }
    // } else {
    //   await loginStatus(isLoggedIn);
    // }
  }

  Future<void> loginStatus(bool isLoggedIn) async {
    if (isLoggedIn) {
      dataProvider?.getAppBGs();
      WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) async => await _initializeFetchData().then(
              (value) async {
            dataProvider?.getAllAchievement(true);
            dataProvider?.fetchFeaturedChalleng();
            if (monthProvider?.monthDataModel == null) {
              if (mounted) {
                await monthProvider?.onInit(context: context).then(
                      (value) async {
                    await userData.fetchUserInfo().then(
                          (value) async {
                        bool isFirstTime = userData.user["createdAt"] ==
                            userData.user["updatedAt"] ||
                            (userData.user["detail"] == null ||
                                !userData.user["detail"]
                                    .containsKey('bodyfat'));

                        await preferences.setBool(
                            SharedPreference.isFirstTime, isFirstTime);

                        bool isAppUser =
                        userData.user["singuptype"] != "web" ? true : false;
                        if (Platform.isIOS && isAppUser) {
                          try {
                            Map<String, dynamic> subscriptionData =
                            userData.user["subscription"];
                            DateTime now = DateTime.now().toUtc();
                            DateTime? endDate = (subscriptionData["end_date"] ??
                                "")
                                .toString()
                                .isEmpty
                                ? null
                                : DateTime.parse(subscriptionData["end_date"]);

                            if (endDate == null || (now.isAfter(endDate))) {
                              await _updateSubscriptionData(
                                type: "",
                                endDate: "",
                                startDate: "",
                                status: "free_user",
                              );
                            }
                          } catch (e) {
                            debugPrint("Error fetching subscription: $e");
                          }
                        }

                        if (Platform.isIOS && isAppUser) {
                          await userData.fetchUserInfo().then(
                                (value) async {
                              Map<String, dynamic> subscriptionData =
                              userData.user["subscription"];

                              if (subscriptionData[
                              "user_subscription_status"] !=
                                  "free_user") {
                                if (isFirstTime) {
                                  if (mounted) {
                                    await Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileBoardingScreen(
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
                                if (isFirstTime) {
                                  if (mounted) {
                                    await Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileBoardingScreen(
                                                welcomeDescription: '',
                                                welcomeImageUrl: '',
                                              ),
                                        ),
                                            (route) => false).then(
                                          (value) async {
                                        await preferences.setBool(
                                            SharedPreference.isFirstTime,
                                            false);
                                      },
                                    );
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
                              }
                            },
                          );
                        } else if (Platform.isIOS && !isAppUser) {
                          Map<String, dynamic> subscriptionData =
                          userData.user["subscription"];

                          DateTime? endDate =
                          subscriptionData["end_date"].toString().isEmpty
                              ? null
                              : DateTime.parse(
                              subscriptionData["end_date"] ?? "");

                          DateTime now = await NTP.now();

                          if (subscriptionData["user_subscription_status"] ==
                              "free_user" ||
                              (endDate != null && now.isAfter(endDate))) {
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const WooSubscriptionPayWall(),
                                ),
                              );
                            }
                          } else {
                            if (isFirstTime) {
                              if (mounted) {
                                await Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileBoardingScreen(
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
                                        welcomeDescription: '',
                                        welcomeImageUrl: ''),
                                  ),
                                );
                                await isFromNotification();
                              }
                            }
                            await isFromNotification();
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
                                      welcomeDescription: '',
                                      welcomeImageUrl: ''),
                                ),
                              );
                              await isFromNotification();
                            }
                          }
                        }
                      },
                    );
                  },
                );
              }
            }
          },
        ),
      );
    } else {
      await dataProvider?.getAppBGs();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
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
            } else if (package.storeProduct.identifier ==
                "yearly_membership_1y_289") {
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

      Uri url =
      Uri.parse('${AppConstants.serverUrl}/api/users/update_subscription');
      String? userIdToken = await getAuthToken();
      log('userIdToken==========>>>>>$userIdToken');

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
}*/
