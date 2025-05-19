import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbView extends AcSqlDbBase {
  String viewName = '';
  late AcDDView acDDView;

  AcSqlDbView({required String viewName,String dataDictionaryName = 'default'}) : super(dataDictionaryName: dataDictionaryName) {
    viewName = viewName;
    acDDView = AcDataDictionary.getView(
      viewName: viewName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
