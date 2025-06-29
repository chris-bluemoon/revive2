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
              customFlow: true,
              merchantDisplayName: "REVIVE"));
      return await _processPayment();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
      return true;
    } on StripeException catch (e) {
      print(e.toString());
      return false;
    } catch (e) {
      print(e.toString());
      return false;
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
