import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class CustomPaywall extends StatefulWidget {
  const CustomPaywall({super.key});

  @override
  State<CustomPaywall> createState() => _CustomPaywallState();
}

class _CustomPaywallState extends State<CustomPaywall> {
  Package? monthlyPackage;
  Package? annualPackage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        monthlyPackage = offerings.current?.monthly;
        annualPackage = offerings.current?.annual;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading offerings: $e");
    }
  }

  Future<void> _purchase(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.active.isNotEmpty) {
        debugPrint("Purchase successful!");
        // Navigate or update state
      }
    } catch (e) {
      debugPrint("Purchase failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const CircularProgressIndicator();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Subscribe now to access the full Booty by Bret Monthly Programming",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("✅ Up to 5 workouts/week"),
            const Text("✅ Comprehensive Exercise Library"),
            const Text("✅ Community Support Group"),
            const SizedBox(height: 30),

            // Subscription buttons
            if (monthlyPackage != null)
              ElevatedButton(
                onPressed: () => _purchase(monthlyPackage!),
                child: Text(
                    "Monthly - ${monthlyPackage!.storeProduct.priceString}"),
              ),
            if (annualPackage != null)
              ElevatedButton(
                onPressed: () => _purchase(annualPackage!),
                child: Text(
                    "Annual - ${annualPackage!.storeProduct.priceString} (10% OFF)"),
              ),
          ],
        ),
      ),
    );
  }
}
