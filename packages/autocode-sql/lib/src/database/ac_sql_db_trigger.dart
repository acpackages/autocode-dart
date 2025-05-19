import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbTrigger extends AcSqlDbBase {
  late AcDDTrigger acDDTrigger;
  String triggerName = '';

  AcSqlDbTrigger({required String triggerName,String dataDictionaryName = 'default'}) : super(dataDictionaryName: dataDictionaryName) {
    triggerName = triggerName;
    acDDTrigger = AcDataDictionary.getTrigger(
      triggerName: triggerName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }


}