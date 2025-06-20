import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbStoredProcedure extends AcSqlDbBase {
  late AcDDStoredProcedure acDDStoredProcedure;
  String storedProcedureName = "";

  AcSqlDbStoredProcedure({
    required String storedProcedureName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: "default") {
    storedProcedureName = storedProcedureName;
    acDDStoredProcedure =
        AcDataDictionary.getStoredProcedure(
          storedProcedureName: storedProcedureName,
          dataDictionaryName: dataDictionaryName,
        )!;
  }
}
