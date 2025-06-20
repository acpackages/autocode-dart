import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbRelationship extends AcSqlDbBase {
  late AcDDRelationship acDDRelationship;

  AcSqlDbRelationship({
    required AcDDRelationship acDDRelationship,
    super.dataDictionaryName,
  }) {
    acDDRelationship = acDDRelationship;
  }
}
