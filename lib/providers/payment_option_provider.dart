import 'package:flutter/material.dart';
import 'package:revivals/services/stripe_sevice.dart';

class PaymentOptionProvider extends ChangeNotifier {
  String _selectedPaymentMethod = "Card";
  int amount = 0;
  bool paymentSuccess = false;

  String get selectedPaymentMethod => _selectedPaymentMethod;

  void setPaymentMethod(String? method) {
    if (method != null) {
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  Future<bool> card() async {
    print("Card payment selected");
    paymentSuccess = await StripeService.instance.makeCardPayment(amount);
    notifyListeners();
    return paymentSuccess;
  }

  Future<bool> promptPay() async {
    print("PromptPay payment selected");

    notifyListeners();
    return paymentSuccess;
  }

  Future<bool> trueMoney() async {
    print("TrueMoney payment selected");
    paymentSuccess = false; // Replace with actual logic
    notifyListeners();
    return paymentSuccess;
  }

  Future<bool> linePay() async {
    print("Line Pay payment selected");
    paymentSuccess = false; // Replace with actual logic
    notifyListeners();
    return paymentSuccess;
  }

  Future<bool> makePayment() async {
    if (amount <= 0) {
      print("Amount is not set");
      return false;
    }
    switch (_selectedPaymentMethod) {
      case "Card":
        return await card();
      case "PromptPay":
        return await promptPay();
      case "TrueMoney":
        return await trueMoney();
      case "Line Pay":
        return await linePay();
      default:
        return await card();
    }
  }
}
