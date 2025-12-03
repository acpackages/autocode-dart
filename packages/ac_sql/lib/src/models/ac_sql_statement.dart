import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSqlStatement {
  static const String keySql = 'sql';
  static const String keyParameters = 'parameters';

  @AcBindJsonProperty(key: keySql)
  String sql = "";

  @AcBindJsonProperty(key: keyParameters)
  Map<String,dynamic> parameters =  Map.from({});

  AcSqlStatement();
  
  factory AcSqlStatement.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlStatement();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSqlStatement fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }


  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}