import 'dart:convert';
import 'dart:developer';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/components/button_widget.dart';
import 'package:bbb/localstorage/month_database.dart';
import 'package:bbb/localstorage/month_prefrence.dart';
import 'package:bbb/pages/main_page.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/month_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:bbb/values/app_constants.dart';
import 'package:bbb/values/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  DataProvider? dataProvider;
  Package? selectedPackage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    dataProvider = Provider.of<DataProvider>(context, listen: false);
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
            } else if (package.storeProduct.identifier == "yearly_membership_1y_289") {
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

      Uri url = Uri.parse('${AppConstants.serverUrl}/api/users/update_subscription');
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
            builder: (context) => const MainPage(welcomeDescription: '', welcomeImageUrl: ''),
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
    Purchases.setLogLevel(LogLevel.debug);

    if (selectedPackage == null) return;

    setState(() => isLoading = true);

    try {
      final CustomerInfo customerInfo = await Purchases.purchasePackage(selectedPackage!);

      // final DateTime now = await NTP.now();
      // log(' customerInfo.allExpirationDates==========>>>>>${customerInfo.activeSubscriptions}');
      // final entitlementId = selectedPackage!.storeProduct.identifier;
      // final expirationDate = customerInfo.allExpirationDates[entitlementId] ?? customerInfo.latestExpirationDate;

      final entitlements = customerInfo.entitlements.active;

      if (entitlements.isNotEmpty) {
        final entitlement = entitlements.values.first;
        final String planId = entitlement.productIdentifier;
        final String startDate = entitlement.originalPurchaseDate;
        final String endDate =
            DateTime.parse(startDate).add(Duration(days: planId == "monthly_membership_1m_29" ? 28 : 365)).toString();
        final String status = entitlement.isActive ? "subscribed_user" : "free_user";

        await _updateSubscriptionData(
          type: planId,
          endDate: endDate,
          startDate: startDate,
          status: status,
        );
      } else {
        debugPrint('Entitlement not act ive or expiration date missing.');
        if (mounted) showBottomAlert(context, "Subscription not activated. Please try again.");
      }
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint("❕Purchase cancelled by user.");
        if (mounted) showBottomAlert(context, "Purchase cancelled.");
      } else {
        debugPrint("RevenueCat error: ${e.code} - ${e.message}");
        if (mounted) showBottomAlert(context, "Purchase failed: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      if (mounted) showBottomAlert(context, "Purchase failed: Please try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.clear();
    await preferences.clearPrefs();
    await DatabaseHelper().clearAllTables();
    await preferences.clearPrefs();
    context.read<MonthProvider>().clearAllValues();
    dataProvider?.achievementList = [];
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onBoardingScreen,
      (Route<dynamic> route) {
        log("ROUTE NAME ${route.settings.name}");
        return route.settings.name == AppRoutes.onBoardingScreen;
      },
    );

    Navigator.pushNamed(context, AppRoutes.loginScreen);
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
          Utils.appImage(
            MediaQuery.of(context).size,
            imageKey: '',
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: BackArrowWidget(onPress: () {
                      _handleLogout(context);
                    }),
                  ),
                ),
              ],
            ),
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.2),
            padding: EdgeInsets.all(ScreenUtil.horizontalScale(5)).copyWith(bottom: ScreenUtil.verticalScale(3.2)),
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
                              selected: selectedPackage?.storeProduct.identifier == "monthly_membership_1m_29",
                              onTap: () {
                                setState(() {
                                  selectedPackage = offering!.current?.availablePackages
                                      .firstWhere((p) => p.storeProduct.identifier == "monthly_membership_1m_29");
                                });
                              },
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(1)),
                            _planOption(
                              title: "Annual",
                              price: yearPrice,
                              selected: selectedPackage?.storeProduct.identifier == "yearly_membership_1y_289",
                              onTap: () {
                                setState(() {
                                  selectedPackage = offering!.current?.availablePackages
                                      .firstWhere((p) => p.storeProduct.identifier == "yearly_membership_1y_289");
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
                      border: Border.all(color: !selected ? Colors.grey.shade300 : AppColors.primaryColor),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Icon(Icons.check_circle, color: !selected ? Colors.white : Color(0xFF8B2D40), size: 18),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(fontSize: ScreenUtil.verticalScale(1.8), fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2D40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                          color: Colors.white, fontSize: ScreenUtil.verticalScale(1.2), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil.verticalScale(0.5)),
            Text("Full access for just $price/${badge != null ? "year" : "month"}",
                style: TextStyle(fontSize: ScreenUtil.verticalScale(1.5))),
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
