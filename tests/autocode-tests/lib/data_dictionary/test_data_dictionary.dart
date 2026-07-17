import 'dart:convert';
import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

import 'internal_data_dictionary.dart';

testDataDictionary() async {
  var dataDictionaryFile = File('../assets/data_dictionary.json');
  if (dataDictionaryFile.existsSync()) {
    var dataDictionaryJson = jsonDecode(dataDictionaryFile.readAsStringSync());
    AcDataDictionary.registerDataDictionary(jsonData: dataDictionaryJson);
    AcDataDictionary dataDictionary= AcDataDictionary.getInstance();
    AcDDTable tblSaleInvoice = dataDictionary.tables['act_sale_invoices']!;
    print(tblSaleInvoice.toString());
    print(tblSaleInvoice.getPluralName());
    print("Tables : ${dataDictionary.tables.keys.length}, Views : ${dataDictionary.views.length}, Triggers : ${dataDictionary.triggers.length}, Stored procedures : ${dataDictionary.storedProcedures.length}, Functions : ${dataDictionary.functions.length}");
    var jsonFile = File('data_dictionary_output.json');
    if(jsonFile.existsSync()){
      jsonFile.createSync(recursive: true);
    }
    jsonFile.writeAsStringSync(dataDictionary.toString());
    // print(dataDictionary.toString());
  } else {
    print(
      "Could not find data dictionary json file at location : ${dataDictionaryFile.absolute}",
    );
  }
}
