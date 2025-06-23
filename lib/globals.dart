library globals;

import 'dart:io';

import 'package:intl/intl.dart';


String thb  = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'THB').currencySymbol;