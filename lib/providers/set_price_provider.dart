import 'package:flutter/material.dart';

class SetPriceProvider with ChangeNotifier {
  final dailyPriceController = TextEditingController();
  final price3Controller = TextEditingController();
  final price5Controller = TextEditingController();
  final price7Controller = TextEditingController();
  final price14Controller = TextEditingController();
  final minimalRentalPeriodController = TextEditingController();

  bool isCompleteForm = false;
  
  // Flags to track if prices have been manually set by user
  bool _price3ManuallySet = false;
  bool _price5ManuallySet = false;
  bool _price7ManuallySet = false;
  bool _price14ManuallySet = false;
  
  // Getters for the flags
  bool get price3ManuallySet => _price3ManuallySet;
  bool get price5ManuallySet => _price5ManuallySet;
  bool get price7ManuallySet => _price7ManuallySet;
  bool get price14ManuallySet => _price14ManuallySet;
  
  // Methods to mark prices as manually set
  void markWeeklyPriceAsManual() {
    _price3ManuallySet = true;
  }
  
  void markMonthlyPriceAsManual() {
    _price5ManuallySet = true;
  }
  
  void markPrice7AsManual() {
    _price7ManuallySet = true;
  }
  
  void markPrice14AsManual() {
    _price14ManuallySet = true;
  }
  
  // Methods to reset manual flags
  void resetManualFlags() {
    _price3ManuallySet = false;
    _price5ManuallySet = false;
    _price7ManuallySet = false;
    _price14ManuallySet = false;
  }
  
  /// Clear all form controllers and reset form state
  void clearAllFields() {
    dailyPriceController.clear();
    price3Controller.clear();
    price5Controller.clear();
    price7Controller.clear();
    price14Controller.clear();
    minimalRentalPeriodController.clear();
    isCompleteForm = false;
    
    // Reset manual edit flags
    resetManualFlags();
    
    notifyListeners();
  }
  
  void checkFormComplete() {
    if (dailyPriceController.text.isNotEmpty &&
        price3Controller.text.isNotEmpty &&
        price5Controller.text.isNotEmpty &&
        minimalRentalPeriodController.text.isNotEmpty) {
      isCompleteForm = true;
    } else {
      isCompleteForm = false;
    }
    notifyListeners();
  }
}
