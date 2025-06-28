import 'package:intl/intl.dart';

extension AcIntegerExtensions on int {
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;

  String formatWith(String pattern) {
    if (pattern == AcIntFormat.display) {
      pattern = "#,##0";
    }
    return NumberFormat(pattern).format(this);
  }
}

class AcIntFormat {
  static const display = 'DISPLAY';
}
