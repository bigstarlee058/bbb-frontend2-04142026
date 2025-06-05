import 'dart:convert';
import 'dart:developer';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_ui_flutter/views/paywall_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPayWall extends StatefulWidget {
  const SubscriptionPayWall({super.key});

  @override
  State<SubscriptionPayWall> createState() => _SubscriptionPayWallState();
}

class _SubscriptionPayWallState extends State<SubscriptionPayWall> {
  Offerings? offering;
  String monthPrice = "";
  String yearPrice = "";
  UserDataProvider? userDataProvider;

  @override
  void initState() {
    super.initState();
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOffering();
    });
    // showPaywall();
  }

  Future<void> getOffering() async {
    String tempData = preferences.getString(SharedPreference.offerings) ?? "";
    debugPrint("$tempData");
    offering =
        tempData.isNotEmpty ? Offerings.fromJson(jsonDecode(tempData)) : null;

    if (offering != null) {
      for (var offeringItem in offering!.all.values) {
        for (var package in offeringItem.availablePackages) {
          if (package.storeProduct.identifier == "monthly_membership") {
            monthPrice = package.storeProduct.priceString;
          } else if (package.storeProduct.identifier == "yearly_membership") {
            yearPrice = package.storeProduct.priceString;
          }
        }
      }
    }
    setState(() {});
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
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
        "price": type == "monthly_membership" ? monthPrice : yearPrice,
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
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
          ),
        );
        await isFromNotification();

        final jsonResponse = jsonDecode(response.body);

        userDataProvider?.user = jsonResponse;

        await userDataProvider?.fetchUserInfo();
      }
    } catch (e) {
      log("issue in month view loading => $e");
    }
  }

  Future<void> isFromNotification() async {
    int? status = preferences.getInt(SharedPreference.fromNotification);
    if (status == 1) {
      await Navigator.pushNamed(context, '/exercise');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: offering == null
            ? const SizedBox()
            : PaywallView(
                onPurchaseCompleted: (CustomerInfo customerInfo,
                    StoreTransaction transaction) async {
                  if (!mounted) return;

                  await _updateSubscriptionData(
                    type: transaction.productIdentifier,
                    endDate:
                        (transaction.productIdentifier == "monthly_membership"
                                ? customerInfo
                                    .allExpirationDates["monthly_membership"]
                                : customerInfo
                                    .allExpirationDates["yearly_membership"]) ??
                            "",
                    startDate: transaction.purchaseDate,
                    status: "subscribed_user",
                  );
                },
              ));
  }
}

// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:bbb/localstorage/month_prefrence.dart';
// import 'package:bbb/main.dart';
// import 'package:bbb/pages/main_page.dart';
// import 'package:bbb/providers/user_data_provider.dart';
// import 'package:bbb/values/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ntp/ntp.dart';
// import 'package:provider/provider.dart';
// import 'package:purchases_flutter/models/offerings_wrapper.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:purchases_ui_flutter/views/paywall_view.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SubscriptionPayWall extends StatefulWidget {
//   const SubscriptionPayWall({super.key});
//
//   @override
//   State<SubscriptionPayWall> createState() => _SubscriptionPayWallState();
// }
//
// class _SubscriptionPayWallState extends State<SubscriptionPayWall> {
//   Offerings? offering;
//   String monthPrice = "";
//   String yearPrice = "";
//   UserDataProvider? userDataProvider;
//   getOffering() async {
//     String tempData = preferences.getString(SharedPreference.offerings) ?? "";
//     print("$tempData");
//     offering =
//         tempData.isNotEmpty ? Offerings.fromJson(jsonDecode(tempData)) : null;
//     if (offering != null) {
//       for (var offering in offering!.all.values) {
//         for (var package in offering.availablePackages) {
//           if (package.storeProduct.identifier == "monthly_membership") {
//             monthPrice = package.storeProduct.priceString;
//           }
//           if (package.storeProduct.identifier == "yearly_membership") {
//             yearPrice = package.storeProduct.priceString;
//           }
//         }
//       }
//     }
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getOffering();
//       waitLoader();
//     });
//   }
//
//   Future<String?> getAuthToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authToken = prefs.getString('authToken');
//     return authToken;
//   }
//
//   Future<void> _updateSubscriptionData({
//     required String status,
//     required String type,
//     required String startDate,
//     required String endDate,
//   }) async {
//     try {
//       final Map<String, String> queryParams = {
//         "user_subscription_status": status,
//         "subscription_type": type,
//         "price": type == "monthly_membership" ? monthPrice : yearPrice,
//         "purchase_date": startDate,
//         "end_date": endDate
//       };
//       Uri url =
//           Uri.parse('${AppConstants.serverUrl}/api/users/update_subscription');
//       String? userIdToken = await getAuthToken();
//       final response = await http.put(
//         url,
//         body: queryParams,
//         headers: <String, String>{'AUTH_TOKEN': userIdToken ?? ""},
//       );
//       log('response :::::::::::::::::: ${response.body}');
//       if (response.statusCode == 200) {
//         await userDataProvider?.fetchUserInfo();
//         DateTime now = await NTP.now();
//         Map<String, dynamic> subscriptionData =
//             userDataProvider?.user["subscription"];
//         log('subscriptionData :::::::::::::::::: $subscriptionData');
//
//         DateTime? startTime = (subscriptionData["purchase_date"] == "" ||
//                 subscriptionData["purchase_date"] == null)
//             ? null
//             : DateTime.parse(subscriptionData["purchase_date"]);
//         DateTime? endTime = (subscriptionData["end_date"] == "" ||
//                 subscriptionData["end_date"] == null)
//             ? null
//             : DateTime.parse(subscriptionData["end_date"]);
//
//         if (subscriptionData["user_subscription_status"] == "free_user" ||
//             (startTime != null &&
//                 endTime != null &&
//                 (now.isAfter(startTime) && now.isBefore(endTime)))) {
//         } else {}
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
//           ),
//         );
//         await isFromNotification();
//       }
//     } catch (e) {
//       log("issue in month view loading=> $e");
//     }
//   }
//
//   isFromNotification() async {
//     int? status = preferences.getInt(SharedPreference.fromNotification);
//     if (status == 1) {
//       await Navigator.pushNamed(context, '/exercise');
//     }
//   }
//
//   waitLoader() {
//     Future.delayed(Duration(milliseconds: 1)).then(
//       (value) {
//         setState(() {});
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (mounted) {
//       setState(() {});
//     }
//     return Scaffold(
//       body: offering == null
//           ? SizedBox()
//           : PaywallView(
//               // offering: Offering(identifier, serverDescription, metadata, availablePackages),
//               key: UniqueKey(),
//               onPurchaseCompleted: (customerInfo, storeTransaction) async {
//                 if (!mounted) return;
//                 await _updateSubscriptionData(
//                   type: storeTransaction.productIdentifier,
//                   endDate: (storeTransaction.productIdentifier ==
//                               "monthly_membership"
//                           ? customerInfo
//                               .allExpirationDates["monthly_membership"]
//                           : customerInfo
//                               .allExpirationDates["yearly_membership"]) ??
//                       "",
//                   startDate: storeTransaction.purchaseDate,
//                   status: "subscribed_user",
//                 );
//               },
//             ),
//     );
//   }
//
// }
