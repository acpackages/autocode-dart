/* AcDoc({
  "summary": "Enumeration of primitive data types used in API specifications.",
  "description": "This enumeration provides the set of primitive data types recognized by the OpenAPI specification. These types are used to define the structure of properties in schemas, parameters, and other parts of an API definition.",
  "example": "final schemaType = AcEnumApiDataType.object;\nprint(schemaType.value); // Outputs: 'object'"
}) */
enum AcEnumApiDataType {
  /* AcDoc({"summary": "Represents an array or list of items."}) */
  array("array"),

  /* AcDoc({"summary": "Represents a boolean value (true or false)."}) */
  boolean("boolean"),

  /* AcDoc({"summary": "Represents an integer number (no fractions)."}) */
  integer("integer"),

  /* AcDoc({"summary": "Represents a generic object or key-value map."}) */
  object("object"),

  /* AcDoc({"summary": "Represents a string of characters."}) */
  string("string"),

  /* AcDoc({"summary": "Represents any number, including integers and floating-point numbers."}) */
  number("number");

  /* AcDoc({"summary": "The string value associated with the API data type."}) */
  final String value;

  /* AcDoc({"summary": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumApiDataType(this.value);

  /* AcDoc({
    "summary": "Returns the enum constant matching the provided string value.",
    "params": [{"name": "value", "description": "The string value to convert to an enum."}],
    "returns": "The matching enum constant, or null if no match is found.",
    "returns_type": "AcEnumApiDataType?"
  }) */
  static AcEnumApiDataType? fromValue(String value) {
    try {
      return AcEnumApiDataType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "summary": "Checks whether the enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare against."}],
    "returns": "True if the string matches the enum's value, otherwise false.",
    "returns_type": "bool"
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({
    "summary": "Returns the enum's string representation.",
    "returns": "The raw string value of the enum.",
    "returns_type": "String"
  }) */
  @override
  String toString() => value;
}