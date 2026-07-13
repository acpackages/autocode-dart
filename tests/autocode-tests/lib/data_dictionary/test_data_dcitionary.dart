import 'dart:convert';
import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

testDataDictionary() async {
  var dataDictionaryFile = File('../assets/data_dictionary.json');
  if (dataDictionaryFile.existsSync()) {
    var dataDictionaryJson = jsonDecode(dataDictionaryFile.readAsStringSync());
    AcDataDictionary.registerDataDictionary(jsonData: dataDictionaryJson);
    AcDataDictionary dataDictionary= AcDataDictionary.getInstance();
    print("Tables : ${dataDictionary.tables.length}, Views : ${dataDictionary.views.length}, Triggers : ${dataDictionary.triggers.length}, Stored procedures : ${dataDictionary.storedProcedures.length}, Functions : ${dataDictionary.functions.length}");
    print("Schema init result : ");
    print(dataDictionary.toString());
  } else {
    print(
      "Could not find data dictionary json file at location : ${dataDictionaryFile.absolute}",
    );
  }
}
