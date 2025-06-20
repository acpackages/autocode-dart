import 'dart:core';
import 'dart:math';
import 'package:intl/intl.dart';
extension AcDoubleExtensions on double{

  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;

  String format(String format){
    if(format=="DISPLAY"){
      format = "#,##0.00";
    }
    var numberFormat = NumberFormat(format);
    return numberFormat.format(this);
  }

  double round([int decimals = 2]) {
    num mod = pow(10.0, decimals);
    return ((this * mod).round().toDouble() / mod);
  }
}