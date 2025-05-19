import 'dart:core';
import 'package:intl/intl.dart';
extension AcIntegerExtensions on int{

  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;

  String format(String format){
    if(format=="DISPLAY"){
      format = "#,##0";
    }
    var numberFormat = NumberFormat(format);
    return numberFormat.format(this);
  }
}