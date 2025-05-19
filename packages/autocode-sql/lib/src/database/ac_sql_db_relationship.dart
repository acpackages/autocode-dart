import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbRelationship extends AcSqlDbBase {
  late AcDDRelationship acDDRelationship;

  AcSqlDbRelationship({required AcDDRelationship acDDRelationship, super.dataDictionaryName}) {
    acDDRelationship = acDDRelationship;
  }

}