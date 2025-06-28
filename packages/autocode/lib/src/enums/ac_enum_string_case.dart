/* AcDoc({
  "description": "Enumeration of different string case styles, useful for naming conventions and formatting.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumStringCase {
  /* AcDoc({"description": "camelCase style (e.g., myVariableName)."}) */
  camel('camel'),

  /* AcDoc({"description": "camel_snake style (e.g., my_variableName)."}) */
  camelSnake('camel_snake'),

  /* AcDoc({"description": "Capitalized words (e.g., My Variable Name)."}) */
  capital('capital'),

  /* AcDoc({"description": "Capitalized words with underscores (e.g., My_Variable_Name)."}) */
  capitalSnake('capital_snake'),

  /* AcDoc({"description": "COBOL style with hyphens and uppercase (e.g., MY-VARIABLE-NAME)."}) */
  cobol('cobol'),

  /* AcDoc({"description": "Dot separated lower case (e.g., my.variable.name)."}) */
  dot('dot'),

  /* AcDoc({"description": "kebab-case style (e.g., my-variable-name)."}) */
  kebab('kebab'),

  /* AcDoc({"description": "Lowercase style (e.g., myvariablename)."}) */
  lower('lower'),

  /* AcDoc({"description": "PascalCase style (e.g., MyVariableName)."}) */
  pascal('pascal'),

  /* AcDoc({"description": "Pascal case with underscores (e.g., My_Variable_Name)."}) */
  pascalSnake('pascal_snake'),

  /* AcDoc({"description": "SCREAMING_SNAKE_CASE style (e.g., MY_VARIABLE_NAME)."}) */
  screamingSnake('screaming_snake'),

  /* AcDoc({"description": "Sentence case (e.g., My variable name)."}) */
  sentence('sentence'),

  /* AcDoc({"description": "snake_case style (e.g., my_variable_name)."}) */
  snake('snake'),

  /* AcDoc({"description": "Train-Case style (e.g., My-Variable-Name)."}) */
  train('train'),

  /* AcDoc({"description": "UPPERCASE style (e.g., MYVARIABLENAME)."}) */
  upper('upper');

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
