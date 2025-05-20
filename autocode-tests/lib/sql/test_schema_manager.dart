import 'dart:convert';
import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

testSchemaManager() async {
  var dataDictionaryFile = File('assets/data_dictionary.json');
  if(dataDictionaryFile.existsSync()){
    var dataDictionaryJson = jsonDecode(dataDictionaryFile.readAsStringSync());
    AcDataDictionary.registerDataDictionary(jsonData: dataDictionaryJson);
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.MYSQL;
    AcSqlConnection sqlConnection = AcSqlConnection.instanceFromJson(jsonData: {
      AcSqlConnection.KEY_CONNECTION_USERNAME:"root",
      AcSqlConnection.KEY_CONNECTION_PASSWORD:"",
      AcSqlConnection.KEY_CONNECTION_HOSTNAME:"localhost",
      AcSqlConnection.KEY_CONNECTION_PORT:3306,
      AcSqlConnection.KEY_CONNECTION_DATABASE:"acsm_test_dart",
    });
    AcSqlDatabase.sqlConnection = sqlConnection;
    var schemaManager = AcSqlDbSchemaManager();
    var schemaInitResult = await schemaManager.initDatabase();
    print("Schema init result : ");
    print(schemaInitResult);
  }
  else{
    print("Could not find data dictionary json file at location : ${dataDictionaryFile.absolute}");
  }
}