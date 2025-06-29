import 'dart:convert';
import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_web_on_jaguar/ac_web_on_jaguar.dart';

testWebOnJaguarAutoApi() async {
  var dataDictionaryFile = File('../assets/data_dictionary.json');
  if (dataDictionaryFile.existsSync()) {
    var dataDictionaryJson = jsonDecode(dataDictionaryFile.readAsStringSync());
    AcDataDictionary.registerDataDictionary(jsonData: dataDictionaryJson);
    AcWebOnJaguar acWeb = AcWebOnJaguar();
    AcDataDictionaryAutoApi acDataDictionaryAutoApi = AcDataDictionaryAutoApi(
      acWeb: acWeb,
    );
    acDataDictionaryAutoApi.urlPrefix = '/api';
    acDataDictionaryAutoApi.includeTable(tableName: 'accounts');
    acDataDictionaryAutoApi.includeTable(tableName: 'apis');
    acDataDictionaryAutoApi.includeTable(tableName: 'companies');
    acDataDictionaryAutoApi.generate();
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.mysql;
    AcSqlConnection sqlConnection = AcSqlConnection.instanceFromJson(
      jsonData: {
        AcSqlConnection.keyUsername: "root",
        AcSqlConnection.keyPassword: "",
        AcSqlConnection.keyHostname: "localhost",
        AcSqlConnection.keyPort: 3306,
        AcSqlConnection.keyDatabase: "unifi_tradeops",
      },
    );
    acWeb.port = 8081;
    acWeb.start();
    print(acWeb.acApiDoc);
    AcSqlDatabase.sqlConnection = sqlConnection;
    // print("Schema init result : ");
    // print(schemaInitResult);
  } else {
    print(
      "Could not find data dictionary json file at location : ${dataDictionaryFile.absolute}",
    );
  }
}
