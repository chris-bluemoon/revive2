import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(int amount) async {
    try {
      print('StripeService: Starting payment for amount: $amount THB');
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, "THB");

      print(
          'StripeService: Payment intent client secret received: ${paymentIntentClientSecret != null ? "Yes" : "No"}');

      if (paymentIntentClientSecret == null) {
        print('StripeService: Payment intent creation failed');
        return false;
      }

      print('StripeService: Initializing payment sheet');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentClientSecret,
              paymentMethodOrder: ["promptpay"],
              customFlow: true,
              merchantDisplayName: "REVIVE"));

      print('StripeService: Processing payment');
      return await _processPayment();
    } catch (e) {
      print('StripeService: Error in makePayment: $e');
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
