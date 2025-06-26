import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(int amount) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "THB");
      if (paymentIntentClientSecret == null) return false;

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: "REVIVE"));
      await _processPayment();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print(e.toString());
      // return e.toString();
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amount': amount,
      });
      if (result.data != null) {
        return result.data["clientSecret"];
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }
}
