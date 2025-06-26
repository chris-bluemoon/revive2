import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> makePayment(BuildContext context, int amount) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "THB");
      if (paymentIntentClientSecret == null) return;

      Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: "REVIVE"));
      await _processPayment();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      // final Dio dio = Dio();
      // Map<String, dynamic> data = {
      //   "amount": _calculateAmount(amount),
      //   "currency": currency
      // };
      // var response = await dio.post("https://api.stripe.com/v1/payment_intents",
      // data: data,
      // options: Options(
      //   contentType: Headers.formUrlEncodedContentType,
      //   headers: {
      //     "Authorization": "Bearer $stripeSecretkey",
      //     "Content-Type": 'application/x-www-form-urlencoded'
      //   },
      // ));
      // if (response.data != null) {
      //   // print(response.data);
      //   return response.data["client_secret"];
      // }

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
