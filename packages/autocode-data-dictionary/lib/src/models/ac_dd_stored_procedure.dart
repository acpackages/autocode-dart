import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDStoredProcedure {
  static const String KEY_STORED_PROCEDURE_NAME = "stored_procedure_name";
  static const String KEY_STORED_PROCEDURE_CODE = "stored_procedure_code";

  @AcBindJsonProperty(key: AcDDStoredProcedure.KEY_STORED_PROCEDURE_NAME)
  String storedProcedureName = "";

  @AcBindJsonProperty(key: AcDDStoredProcedure.KEY_STORED_PROCEDURE_CODE)
  String storedProcedureCode = "";

  static AcDDStoredProcedure instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDStoredProcedure();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  static AcDDStoredProcedure getInstance({required String storedProcedureName, String dataDictionaryName = "default"}) {
    final result = AcDDStoredProcedure();
    final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName: dataDictionaryName);

    if (acDataDictionary.storedProcedures.containsKey(storedProcedureName)) {
      result.fromJson(jsonData: acDataDictionary.storedProcedures[storedProcedureName]);
    }
    return result;
  }

  static String getDropStoredProcedureStatement({required String storedProcedureName,String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = "DROP PROCEDURE IF EXISTS $storedProcedureName;";
    return result;
  }

  AcDDStoredProcedure fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  String getCreateStoredProcedureStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = storedProcedureCode;
    return result;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
