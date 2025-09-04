import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of different string case styles, useful for naming conventions and formatting.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumStringCase {
  /* AcDoc({"description": "camelCase style (e.g., myVariableName)."}) */
  camel('CAMEL'),

  /* AcDoc({"description": "camel_snake style (e.g., my_variableName)."}) */
  camelSnake('CAMEL_SNAKE'),

  /* AcDoc({"description": "Capitalized words (e.g., My Variable Name)."}) */
  capital('CAPITAL'),

  /* AcDoc({"description": "Capitalized words with underscores (e.g., My_Variable_Name)."}) */
  capitalSnake('CAPITAL_SNAKE'),

  /* AcDoc({"description": "COBOL style with hyphens and uppercase (e.g., MY-VARIABLE-NAME)."}) */
  cobol('COBOL'),

  /* AcDoc({"description": "Dot separated lower case (e.g., my.variable.name)."}) */
  dot('DOT'),

  /* AcDoc({"description": "kebab-case style (e.g., my-variable-name)."}) */
  kebab('KEBAB'),

  /* AcDoc({"description": "Lowercase style (e.g., myvariablename)."}) */
  lower('LOWER'),

  /* AcDoc({"description": "PascalCase style (e.g., MyVariableName)."}) */
  pascal('PASCAL'),

  /* AcDoc({"description": "Pascal case with underscores (e.g., My_Variable_Name)."}) */
  pascalSnake('PASCAL_SNAKE'),

  /* AcDoc({"description": "SCREAMING_SNAKE_CASE style (e.g., MY_VARIABLE_NAME)."}) */
  screamingSnake('SCREAMING_SNAKE'),

  /* AcDoc({"description": "Sentence case (e.g., My variable name)."}) */
  sentence('SENTENCE'),

  /* AcDoc({"description": "snake_case style (e.g., my_variable_name)."}) */
  snake('SNAKE'),

  /* AcDoc({"description": "Train-Case style (e.g., My-Variable-Name)."}) */
  train('TRAIN'),

  /* AcDoc({"description": "UPPERCASE style (e.g., MYVARIABLENAME)."}) */
  upper('UPPER');

  /* AcDoc({"description": "The string representation of the case style."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to each enum variant."}) */
  const AcEnumStringCase(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumStringCase? fromValue(String value) {
    try {
      return AcEnumStringCase.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the string matches, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the string case style as a string."}) */
  @override
  String toString() => value;
}
