import 'package:flutter/material.dart';

class SetPriceProvider with ChangeNotifier {
  final dailyPriceController = TextEditingController();
  final weeklyPriceController = TextEditingController();
  final monthlyPriceController = TextEditingController();
  final minimalRentalPeriodController = TextEditingController();

  bool isCompleteForm = false;
  
  // Flags to track if prices have been manually set by user
  bool _weeklyPriceManuallySet = false;
  bool _monthlyPriceManuallySet = false;
  bool _price7ManuallySet = false;
  bool _price14ManuallySet = false;
  
  // Getters for the flags
  bool get weeklyPriceManuallySet => _weeklyPriceManuallySet;
  bool get monthlyPriceManuallySet => _monthlyPriceManuallySet;
  bool get price7ManuallySet => _price7ManuallySet;
  bool get price14ManuallySet => _price14ManuallySet;
  
  // Methods to mark prices as manually set
  void markWeeklyPriceAsManual() {
    _weeklyPriceManuallySet = true;
  }
  
  void markMonthlyPriceAsManual() {
    _monthlyPriceManuallySet = true;
  }
  
  void markPrice7AsManual() {
    _price7ManuallySet = true;
  }
  
  void markPrice14AsManual() {
    _price14ManuallySet = true;
  }
  
  // Methods to reset manual flags
  void resetManualFlags() {
    _weeklyPriceManuallySet = false;
    _monthlyPriceManuallySet = false;
    _price7ManuallySet = false;
    _price14ManuallySet = false;
  }
  
  /// Clear all form controllers and reset form state
  void clearAllFields() {
    dailyPriceController.clear();
    weeklyPriceController.clear();
    monthlyPriceController.clear();
    minimalRentalPeriodController.clear();
    isCompleteForm = false;
    
    // Reset manual edit flags
    resetManualFlags();
    
    notifyListeners();
  }
  
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
