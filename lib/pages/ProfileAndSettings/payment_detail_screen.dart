import 'dart:developer';

import 'package:bbb/components/back_arrow_widget.dart';
import 'package:bbb/providers/data_provider.dart';
import 'package:bbb/providers/user_data_provider.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/utils/utils.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentDetailScreen extends StatefulWidget {
  const PaymentDetailScreen({super.key});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  Offerings? offering;
  String monthPrice = "";
  String yearPrice = "";
  DataProvider? dataProvider;
  UserDataProvider? userDataProvider;
  String? selectedPackage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
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
            } else if (package.storeProduct.identifier == "yearly_membership_1y_289") {
              yearPrice = package.storeProduct.priceString;
            }
          }
        }
        selectedPackage = userDataProvider?.user["subscription"]["subscription_type"];
      });
    } catch (e) {
      log("Failed to fetch offerings: $e");
    }
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
                      Navigator.pop(context);
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
                        "Subscription Details for get the full Booty by Bret Monthly Programming",
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
                              selected: selectedPackage == "monthly_membership_1m_29",
                              onTap: () {},
                            ),
                            SizedBox(height: ScreenUtil.verticalScale(1.5)),
                            _planOption(
                              title: "Annual",
                              price: yearPrice,
                              selected: selectedPackage == "yearly_membership_1y_289",
                              onTap: () {},
                              badge: "20% OFF",
                            ),
                          ],
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
          ScreenUtil.verticalScale(2),
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
                selected
                    ? Container(
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: !selected ? Colors.grey.shade300 : AppColors.primaryColor),
                            shape: BoxShape.circle),
                        child: Center(
                          child:
                              Icon(Icons.check_circle, color: !selected ? Colors.white : Color(0xFF8B2D40), size: 18),
                        ),
                      )
                    : SizedBox(),
                Text(
                  title,
                  style: TextStyle(fontSize: ScreenUtil.verticalScale(1.8), fontWeight: FontWeight.bold),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    margin: EdgeInsets.only(left: 10),
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
                Spacer(),
                selected
                    ? Text(
                        "Active",
                        style: TextStyle(fontSize: ScreenUtil.verticalScale(1.8), fontWeight: FontWeight.w500),
                      )
                    : SizedBox()
              ],
            ),
            SizedBox(height: ScreenUtil.verticalScale(1)),
            Text("Full access for just $price/${badge != null ? "year" : "month"}",
                style: TextStyle(fontSize: ScreenUtil.verticalScale(1.5))),
          ],
        ),
      ),
    );
  }
}
