import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';

class AcWebDataDictionaryUtils {
  static String getTableNameForApiPath({required AcDDTable acDDTable}){
    String result = acDDTable.getPluralName();
    return result.toKebabCase();
  }
}