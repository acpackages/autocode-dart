import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a single condition for a query or filter.",
  "description": "This class defines a single logical comparison, such as `column_name = 'value'`, used within data dictionary definitions. It is typically used to specify conditions for triggers, views, or filtered relationships.",
  "example": "// Represents the condition: WHERE status = 'active'\nfinal condition = AcDDCondition.instanceFromJson(jsonData: {\n  'column_name': 'status',\n  'operator': 'equals',\n  'value': 'active'\n});"
}) */
@AcReflectable()
class AcDDConfig {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.

  static const String keyInsertTimestampColumnKey = 'insertTimestampColumnKey';
  static const String keyUpdateTimestampColumnKey = 'updateTimestampColumnKey';
  static const String keyDeleteTimestampColumnKey = 'deleteTimestampColumnKey';
  static const String keySoftDeleteRows = 'softDeleteRows';

  @AcBindJsonProperty(key: keySoftDeleteRows)
  bool softDeleteRows = false;

  @AcBindJsonProperty(key: keyInsertTimestampColumnKey)
  String insertTimestampColumnKey = '';

  @AcBindJsonProperty(key: keyUpdateTimestampColumnKey)
  String updateTimestampColumnKey = '';

  @AcBindJsonProperty(key: keyDeleteTimestampColumnKey)
  String deleteTimestampColumnKey = '';

  /* AcDoc({
    "summary": "Creates a new, empty instance of a data dictionary condition."
  }) */
  AcDDConfig();

}

var acDDConfig = AcDDConfig();