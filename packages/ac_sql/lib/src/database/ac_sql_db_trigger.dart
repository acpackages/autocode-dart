import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbTrigger extends AcSqlDbBase {
  late AcDDTrigger acDDTrigger;
  String triggerName = '';

  AcSqlDbTrigger({
    required String triggerName,
    String dataDictionaryName = 'default',
  }) : super(dataDictionaryName: dataDictionaryName) {
    triggerName = triggerName;
    acDDTrigger =
        AcDataDictionary.getTrigger(
          triggerName: triggerName,
          dataDictionaryName: dataDictionaryName,
        )!;
  }
}
