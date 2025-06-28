import 'dart:convert';
import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

void main() async {
  await testSchemaManager();
}

testSchemaManager() async {
  var dataDictionaryFile = File('../../tests/data_dictionary.json');
  if (dataDictionaryFile.existsSync()) {
    var dataDictionaryJson = jsonDecode(dataDictionaryFile.readAsStringSync());
    AcDataDictionary.registerDataDictionary(jsonData: dataDictionaryJson);
    AcSqlDatabase.databaseType = AcEnumSqlDatabaseType.mysql;
    AcSqlConnection sqlConnection = AcSqlConnection.instanceFromJson(
      jsonData: {
        AcSqlConnection.keyUsername: "root",
        AcSqlConnection.keyPassword: "",
        AcSqlConnection.keyHostname: "localhost",
        AcSqlConnection.keyPort: 3306,
        AcSqlConnection.keyDatabase: "dart_db_schema_test",
      },
    );
    AcSqlDatabase.sqlConnection = sqlConnection;
    var schemaManager = AcSqlDbSchemaManager();
    var schemaInitResult = await schemaManager.initDatabase();
    print("Schema init result : ");
    print(schemaInitResult);
  } else {
    print(
      "Could not find data dictionary json file at location : ${dataDictionaryFile.absolute}",
    );
  }
}
