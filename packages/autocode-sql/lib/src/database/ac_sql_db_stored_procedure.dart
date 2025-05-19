import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbStoredProcedure extends AcSqlDbBase {
  late AcDDStoredProcedure acDDStoredProcedure;
  String storedProcedureName = "";

  AcSqlDbStoredProcedure({required String storedProcedureName, String dataDictionaryName = "default"})
      : super(dataDictionaryName: "default") {
    storedProcedureName = storedProcedureName;
    acDDStoredProcedure = AcDataDictionary.getStoredProcedure(
      storedProcedureName: storedProcedureName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}