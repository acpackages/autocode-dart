import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDFunction {
  static const String KEY_FUNCTION_NAME = "function_name";
  static const String KEY_FUNCTION_CODE = "function_code";

  @AcBindJsonProperty(key: KEY_FUNCTION_NAME)
  String functionName = "";

  @AcBindJsonProperty(key: KEY_FUNCTION_CODE)
  String functionCode = "";

  AcDDFunction();

  factory AcDDFunction.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDFunction();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  factory AcDDFunction.getInstance({required String functionName, String dataDictionaryName = "default"}) {
    final result = AcDDFunction();
    final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName:dataDictionaryName);
    if (acDataDictionary.functions.containsKey(functionName)) {
      result.fromJson(jsonData:acDataDictionary.functions[functionName]);
    }
    return result;
  }

  static String getDropFunctionStatement({required String functionName, String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = "DROP FUNCTION IF EXISTS $functionName;";
    return result;
  }

  AcDDFunction fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance:this, jsonData:jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance:this);
  }



  String getCreateFunctionStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = functionCode;
    return result;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
