import 'package:ac_mirrors/ac_mirrors.dart';

@AcReflectable()
class AcSqlEventHandler {
  final String tableName;
  const AcSqlEventHandler({required this.tableName});
}
