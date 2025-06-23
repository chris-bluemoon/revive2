import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();
  Future<void> initPaymentSheet(BuildContext context,
      {required int amount}) async {
    try {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing payment...')),
      // );

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createPaymentIntent');

      final result = await callable.call({
        'email': "yenaythway77@mgail.com",
        'currency': 'THB',
        'amount': amount,
      });

      final data = result.data;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['paymentIntent'],
          merchantDisplayName: 'Stripe Demo',
          customerId: data['customerId'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          // style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  Future<void> makePayment(int amount) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "THB");
      if (paymentIntentClientSecret == null) return;
      Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              merchantDisplayName: "REVIVE"));
      await _processPayment();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processPayment() async {
    try {
      PaymentSheetPaymentOption? result =
          await Stripe.instance.presentPaymentSheet();
      print("result: $result");
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      // final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency
      };
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
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
