import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of supported condition operators used for filtering or querying data.",
  "author": "AcDocs System",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumConditionOperator {
  /* AcDoc({"description": "Represents a value that falls between two bounds (inclusive or exclusive depending on implementation)."}) */
  between('BETWEEN'),

  /* AcDoc({"description": "Checks if a string contains a specified substring."}) */
  contains('CONTAINS'),

  /* AcDoc({"description": "Checks if a string ends with a specified substring."}) */
  endsWith('ENDS_WITH'),

  /* AcDoc({"description": "Checks if a value is equal to the specified operand."}) */
  equalTo('EQUAL_TO'),

  /* AcDoc({"description": "Checks if a value is greater than the specified operand."}) */
  greaterThan('GREATER_THAN'),

  /* AcDoc({"description": "Checks if a value is greater than or equal to the specified operand."}) */
  greaterThanEqualTo('GREATER_THAN_EQUAL_TO'),

  /* AcDoc({"description": "Checks if a value is present in the given list of values."}) */
  in_('IN'),

  /* AcDoc({"description": "Checks if a value is an empty collection, string, or null."}) */
  isEmpty('IS_EMPTY'),
  isNotEmpty('IS_NOT_EMPTY'),

  /* AcDoc({"description": "Checks if a value is not null."}) */
  isNotNull('IS_NOT_NULL'),

  /* AcDoc({"description": "Checks if a value is null."}) */
  isNull('IS_NULL'),

  /* AcDoc({"description": "Checks if a value is less than the specified operand."}) */
  lessThan('LESS_THAN'),

  /* AcDoc({"description": "Checks if a value is less than or equal to the specified operand."}) */
  lessThanEqualTo('LESS_THAN_EQUAL_TO'),

  notContains('NOT_CONTAINS'),
  /* AcDoc({"description": "Checks if a value is not in the given list of values."}) */
  notIn('NOT_IN'),

  /* AcDoc({"description": "Checks if a value is not equal to the specified operand."}) */
  notEqualTo('NOT_EQUAL_TO'),

  /* AcDoc({"description": "Checks if a string starts with a specified substring."}) */
  startsWith('STARTS_WITH'),

  /* AcDoc({"description": "Unknown operator."}) */
  unknown('UNKNOWN');

  /* AcDoc({"description": "The string representation used for matching operator types."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string identifier to the enum constant."}) */
  const AcEnumConditionOperator(this.value);

  /* AcDoc({
    "description": "Returns the enum constant corresponding to the given string value.",
    "params": [{"name": "value", "description": "String value to match against operator names."}],
    "returns": "The matching AcEnumConditionOperator constant or null if not found."
  }) */

  static AcEnumConditionOperator fromValue(String value) {
    return AcEnumConditionOperator.values.firstWhere((e) =>
        e.value.equalsIgnoreCase(value),
        orElse: () => AcEnumConditionOperator.unknown);
  }

  /* AcDoc({
    "description": "Checks if the current operator's value matches the given string.",
    "params": [{"name": "other", "description": "The value to compare to this operator."}],
    "returns": "true if the value matches; otherwise, false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({
    "description": "Returns the string representation of the condition operator.",
    "returns": "String value of the condition operator."
  }) */
  @override
  String toString() => value;

  dynamic toJson() {
    return value;
  }
}
