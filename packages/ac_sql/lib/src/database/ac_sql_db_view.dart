import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbView extends AcSqlDbBase {
  String viewName = '';
  late AcDDView acDDView;

  AcSqlDbView({required String viewName, String dataDictionaryName = 'default'})
    : super(dataDictionaryName: dataDictionaryName) {
    viewName = viewName;
    acDDView =
        AcDataDictionary.getView(
          viewName: viewName,
          dataDictionaryName: dataDictionaryName,
        )!;
  }
}
