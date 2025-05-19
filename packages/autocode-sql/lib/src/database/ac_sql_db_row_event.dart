
import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcSqlDbRowEvent {
  late AcLogger logger;
  String tableName = '';
  String dataDictionaryName = 'default';
  late AcDDTable acDDTable;
  late AcDataDictionary acDataDictionary;
  String condition = '';
  String eventType = '';
  dynamic row;
  dynamic result;
  Map<String,dynamic> parameters = {};
  bool abortOperation = false;

  AcSqlDbRowEvent({required String tableName,String dataDictionaryName = 'default'}) {
    tableName = tableName;
    acDDTable = AcDataDictionary.getTable(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    )!;
    acDataDictionary = AcDataDictionary.getInstance();
  }

  Future<AcResult> execute() async {
    AcResult result = AcResult();
    result.setSuccess();
    return result;
  }
}
