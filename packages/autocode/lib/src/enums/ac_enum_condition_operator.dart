/* AcDoc({
  "description": "Enumeration of supported condition operators used for filtering or querying data.",
  "author": "AcDocs System",
  "type": "development"
}) */
enum AcEnumConditionOperator {
  /* AcDoc({"description": "Represents a value that falls between two bounds (inclusive or exclusive depending on implementation)."}) */
  between('between'),

  /* AcDoc({"description": "Checks if a string contains a specified substring."}) */
  contains('contains'),

  /* AcDoc({"description": "Checks if a string ends with a specified substring."}) */
  endsWith('ends_with'),

  /* AcDoc({"description": "Checks if a value is equal to the specified operand."}) */
  equalTo('equal_to'),

  /* AcDoc({"description": "Checks if a value is greater than the specified operand."}) */
  greaterThan('greater_than'),

  /* AcDoc({"description": "Checks if a value is greater than or equal to the specified operand."}) */
  greaterThanEqualTo('greater_than_equal_to'),

  /* AcDoc({"description": "Checks if a value is present in the given list of values."}) */
  in_('in'),

  /* AcDoc({"description": "Checks if a value is an empty collection, string, or null."}) */
  isEmpty('is_empty'),

  /* AcDoc({"description": "Checks if a value is not null."}) */
  isNotNull('is_not_null'),

  /* AcDoc({"description": "Checks if a value is null."}) */
  isNull('is_null'),

  /* AcDoc({"description": "Checks if a value is less than the specified operand."}) */
  lessThan('less_than'),

  /* AcDoc({"description": "Checks if a value is less than or equal to the specified operand."}) */
  lessThanEqualTo('less_than_equal_to'),

  /* AcDoc({"description": "Checks if a value is not in the given list of values."}) */
  notIn('not_in'),

  /* AcDoc({"description": "Checks if a value is not equal to the specified operand."}) */
  notEqualTo('not_equal_to'),

  /* AcDoc({"description": "Checks if a string starts with a specified substring."}) */
  startsWith('starts_with'),

  /* AcDoc({"description": "Unknown operator."}) */
  unknown('unknown');

  /* AcDoc({"description": "The string representation used for matching operator types."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string identifier to the enum constant."}) */
  const AcEnumConditionOperator(this.value);

  /* AcDoc({
    "description": "Returns the enum constant corresponding to the given string value.",
    "params": [{"name": "value", "description": "String value to match against operator names."}],
    "returns": "The matching AcEnumConditionOperator constant or null if not found."
  }) */
  static AcEnumConditionOperator? fromValue(String value) {
    try {
      return AcEnumConditionOperator.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
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
}
