import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  Package? selectedPackage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => getOffering());
  }

  Future<void> getOffering() async {
    try {
      Offerings fetched = await Purchases.getOfferings();
      setState(() {
        offering = fetched;
        for (var offeringItem in offering!.all.values) {
          for (var package in offeringItem.availablePackages) {
            if (package.storeProduct.identifier == "monthly_membership_1m_29") {
              monthPrice = package.storeProduct.priceString;
            } else if (package.storeProduct.identifier ==
                "yearly_membership_1y_289") {
              yearPrice = package.storeProduct.priceString;
            }
          }
        }
        selectedPackage = offering!.current?.availablePackages.first;
      });
    } catch (e) {
      log("Failed to fetch offerings: $e");
    }
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
        "price": type == "monthly_membership_1m_29" ? monthPrice : yearPrice,
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
        userDataProvider?.user = jsonResponse;
        await userDataProvider?.fetchUserInfo();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
          ),
        );
        await isFromNotification();
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

  Future<void> _purchasePackage() async {
    if (selectedPackage == null) return;
    setState(() => isLoading = true);
    try {
      CustomerInfo customerInfo =
          await Purchases.purchasePackage(selectedPackage!);
      DateTime now = await NTP.now();

      await _updateSubscriptionData(
        type: selectedPackage!.storeProduct.identifier,
        endDate: (selectedPackage!.storeProduct.identifier ==
                    "monthly_membership_1m_29"
                ? customerInfo.allExpirationDates["monthly_membership_1m_29"]
                : customerInfo.allExpirationDates["yearly_membership"]) ??
            "",
        startDate: now.toString(),
        status: "subscribed_user",
      );
    } catch (e) {
      log("Purchase failed: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/img/back 1.png',
            height: MediaQuery.of(context).size.height / 1.8,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 5,
            child: Image.asset(
              'assets/img/logo1.png',
              height: 80,
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.2),
            padding: EdgeInsets.all(ScreenUtil.horizontalScale(5))
                .copyWith(bottom: ScreenUtil.verticalScale(3.2)),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: offering == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subscribe now to access the full Booty by Bret Monthly Programming",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.verticalScale(2.4),
                        ),
                      ),
                      SizedBox(height: ScreenUtil.verticalScale(1.5)),
                      _feature("Up to 5 workouts per week"),
                      _feature("Comprehensive Exercise Library"),
                      _feature("Community Support Group"),
                      SizedBox(height: ScreenUtil.verticalScale(1.8)),
                      if (monthPrice.isNotEmpty && yearPrice.isNotEmpty)
                        Column(
                          children: [
                            _planOption(
                              title: "Monthly",
                              price: monthPrice,
                              selected:
                                  selectedPackage?.storeProduct.identifier ==
                                      "monthly_membership_1m_29",
                              onTap: () {
                                setState(() {
                                  selectedPackage = offering!
                                      .current?.availablePackages
                                      .firstWhere((p) =>
                                          p.storeProduct.identifier ==
                                          "monthly_membership_1m_29");
                                });
                              },
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(1)),
                            _planOption(
                              title: "Annual",
                              price: yearPrice,
                              selected:
                                  selectedPackage?.storeProduct.identifier ==
                                      "yearly_membership_1y_289",
                              onTap: () {
                                setState(() {
                                  selectedPackage = offering!
                                      .current?.availablePackages
                                      .firstWhere((p) =>
                                          p.storeProduct.identifier ==
                                          "yearly_membership_1y_289");
                                });
                              },
                              badge: "20% OFF",
                            ),
                          ],
                        ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ButtonWidget(
                          color: AppColors.primaryColor,
                          text: "Continue",
                          textColor: Colors.white,
                          isLoading: isLoading,
                          onPress: isLoading ? () {} : _purchasePackage,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                fontSize: ScreenUtil.verticalScale(1.6),
              )),
        ],
      ),
    );
  }

  Widget _planOption({
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ScreenUtil.verticalScale(1.2),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF8B2D40) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFFF8E6EC) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: !selected
                              ? Colors.grey.shade300
                              : AppColors.primaryColor),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Icon(Icons.check_circle,
                        color: !selected ? Colors.white : Color(0xFF8B2D40),
                        size: 18),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: ScreenUtil.verticalScale(1.8),
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2D40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.verticalScale(1.2),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil.verticalScale(0.5)),
            Text(
                "Full access for just $price/${badge != null ? "year" : "month"}",
                style: TextStyle(fontSize: ScreenUtil.verticalScale(1.5))),
          ],
        ),
      ),
    );
  }
}
