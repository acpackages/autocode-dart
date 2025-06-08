import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbFunction extends AcSqlDbBase {
  late AcDDFunction acDDFunction;
  String functionName = "";

  AcSqlDbFunction({
    required String functionName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: dataDictionaryName) {
    functionName = functionName;
    acDDFunction =
        AcDataDictionary.getFunction(
          functionName: functionName,
          dataDictionaryName: dataDictionaryName,
        )!;
  }
}
