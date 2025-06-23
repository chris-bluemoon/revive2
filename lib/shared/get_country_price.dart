import 'dart:io';

import 'package:intl/intl.dart';

double sgdthb = 25.76;
String symbol = '?';
String thb  = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'THB').currencySymbol;

String getCurrencySymbol (String country) {
  switch (country) {
    case 'SINGAPORE':
      symbol = '\$';
      break;
      case 'BANGKOK':
        symbol = thb ;
    }

  return symbol;
}
String convertFromTHB (int value, String country) {

  double convertedCurrency = 0;
  int roundedFinalValue = 0;


  switch (country) {
    case 'SINGAPORE':
      convertedCurrency = (value / sgdthb);
      // roundedFinalValue = (convertedCurrency ~/ 5) * 5;
      roundedFinalValue = (convertedCurrency / 5).ceil() * 5;
      break;
  }
  //
  //
  return roundedFinalValue.toString();
}