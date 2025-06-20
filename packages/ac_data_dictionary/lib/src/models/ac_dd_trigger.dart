import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
@AcReflectable()
class AcDDTrigger {
  static const String KEY_ROW_OPERATION = "row_operation";
  static const String KEY_TABLE_NAME = "table_name";
  static const String KEY_TRIGGER_CODE = "trigger_code";
  static const String KEY_TRIGGER_EXECUTION = "trigger_execution";
  static const String KEY_TRIGGER_NAME = "trigger_name";

  @AcBindJsonProperty(key: AcDDTrigger.KEY_ROW_OPERATION)
  String rowOperation = "";

  @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_EXECUTION)
  String triggerExecution = "";

  @AcBindJsonProperty(key: AcDDTrigger.KEY_TABLE_NAME)
  String tableName = "";

  @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_NAME)
  String triggerName = "";

  @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_CODE)
  String triggerCode = "";

  static AcDDTrigger instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDTrigger();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  static AcDDTrigger getInstance(String triggerName, {String dataDictionaryName = "default"}) {
    final result = AcDDTrigger();
    final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName:dataDictionaryName);

    if (acDataDictionary.triggers.containsKey(triggerName)) {
      result.fromJson(jsonData: acDataDictionary.triggers[triggerName]);
    }

    return result;
  }

  static String getDropTriggerStatement({required String triggerName, String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    return 'DROP TRIGGER IF EXISTS $triggerName;';
  }

  String getCreateTriggerStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = '';
    if ([AcEnumSqlDatabaseType.MYSQL,AcEnumSqlDatabaseType.SQLITE].contains(databaseType)) {
      result = 'CREATE TRIGGER $triggerName $triggerExecution $rowOperation ON $tableName FOR EACH ROW BEGIN $triggerCode END;';
    }
    return result;
  }

  AcDDTrigger fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
