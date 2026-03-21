import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_mirrors/ac_mirrors.dart';

@AcReflectable()
class AcSqlEventCallback {
  final AcEnumDDRowEvent event;
  const AcSqlEventCallback({required this.event});
}
