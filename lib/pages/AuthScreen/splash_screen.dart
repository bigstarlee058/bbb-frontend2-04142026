import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/SubscriptionPage/subscription_pay_wall.dart';
import 'package:bbb/pages/SubscriptionPage/woo_subscription_pay_wall.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
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
  late UserDataProvider userData;

  @override
  void initState() {
    super.initState();
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

  Future<void> _checkLoginStatus() async {
    // await dataProvider?.getAppBGs().then(
    //   (value) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      dataProvider?.getAppBGs();

      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async => await _initializeFetchData().then(
          (value) async {
            dataProvider?.getAllAchievement(true);

            if (monthProvider?.monthDataModel == null) {
              if (mounted) {
                await monthProvider?.onInit(context: context).then(
                  (value) async {
                    await userData.fetchUserInfo().then(
                      (value) async {
                        bool isAppUser =
                            userData.user["singuptype"] != "web" ? true : false;

                        if (Platform.isIOS && isAppUser) {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.getCustomerInfo();
                            if (customerInfo.entitlements.active.isNotEmpty) {
                              customerInfo.entitlements.active
                                  .forEach((key, entitlement) async {
                                final latestPurchaseDate =
                                    customerInfo.allPurchaseDates;
                                final identifier =
                                    entitlement.productIdentifier;

                                await _updateSubscriptionData(
                                  type: identifier,
                                  endDate: entitlement.expirationDate ?? "",
                                  startDate:
                                      latestPurchaseDate[identifier] ?? "",
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
                              debugPrint("No active subscriptions found.");
                            }
                          } catch (e) {
                            debugPrint("Error fetching subscription: $e");
                          }
                        }

                        if (Platform.isIOS && isAppUser) {
                          Map<String, dynamic> subscriptionData =
                              userData.user["subscription"];

                          if (subscriptionData["user_subscription_status"] !=
                              "free_user") {
                            if (mounted) {
                              await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainPage(
                                      welcomeDescription: '',
                                      welcomeImageUrl: ''),
                                ),
                              );
                            }
                            await isFromNotification();
                          } else {
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionPayWall(),
                                ),
                              );
                            }
                          }
                        } else if (Platform.isIOS && !isAppUser) {
                          // Map<String, dynamic> subscriptionData =
                          //     userData.user["subscription"];
                          //
                          // DateTime? endDate =
                          //     subscriptionData["end_date"].toString().isEmpty
                          //         ? null
                          //         : DateTime.parse(subscriptionData["end_date"] ?? "");
                          //
                          // DateTime now = await NTP.now();
                          //
                          // if (subscriptionData["user_subscription_status"] ==
                          //         "free_user" ||
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
                          //     await Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => const MainPage(
                          //             welcomeDescription: '', welcomeImageUrl: ''),
                          //       ),
                          //     );
                          //   }
                          //   await isFromNotification();
                          // }

                          if (mounted) {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainPage(
                                    welcomeDescription: '',
                                    welcomeImageUrl: ''),
                              ),
                            );
                          }
                          await isFromNotification();
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
                          }
                          await isFromNotification();
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
    //   },
    // );
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
      backgroundColor: Colors.white,
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
