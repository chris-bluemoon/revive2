import 'package:flutter/material.dart';

class SetPriceProvider with ChangeNotifier {
  final dailyPriceController = TextEditingController();
  final weeklyPriceController = TextEditingController();
  final monthlyPriceController = TextEditingController();
  final minimalRentalPeriodController = TextEditingController();

  bool isCompleteForm = false;
  void checkFormComplete() {
    if (dailyPriceController.text.isNotEmpty &&
        weeklyPriceController.text.isNotEmpty &&
        monthlyPriceController.text.isNotEmpty &&
        minimalRentalPeriodController.text.isNotEmpty) {
      isCompleteForm = true;
    } else {
      isCompleteForm = false;
    }
    notifyListeners();
  }
}
