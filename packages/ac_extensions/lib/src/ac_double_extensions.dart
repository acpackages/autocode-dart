import 'dart:core';
import 'dart:math';
import 'package:intl/intl.dart';
extension AcDoubleExtensions on double {
  bool get isEven => this % 1 == 0 && toInt().isEven;
  bool get isOdd => this % 1 == 0 && toInt().isOdd;

  String formatWith(String pattern) {
    if (pattern == AcDoubleFormat.display) {
      pattern = "#,##0.00";
    }
    return NumberFormat(pattern).format(this);
  }

  double roundToDecimals([int decimals = 2]) {
    final mod = pow(10.0, decimals);
    return (this * mod).round().toDouble() / mod;
  }
}

class AcDoubleFormat {
  static const display = 'DISPLAY';
}