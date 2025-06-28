/* AcDoc({
  "summary": "Enumeration of standard data formats used in API specifications.",
  "description": "This enumeration provides a set of common data format strings, often used in OpenAPI/Swagger schemas to specify the format of a primitive type (e.g., a string with a 'date-time' format or an integer with an 'int64' format).",
  "example": "final format = AcEnumApiDataFormat.dateTime;\nprint(format.value); // Outputs: 'date-time'"
}) */
enum AcEnumApiDataFormat {
  /* AcDoc({"summary": "Represents a base64-encoded string."}) */
  byte("byte"),

  /* AcDoc({"summary": "Represents any sequence of octets (binary data)."}) */
  binary("binary"),

  /* AcDoc({"summary": "Represents a full date, as defined by RFC3339."}) */
  date("date"),

  /* AcDoc({"summary": "Represents a date and time, as defined by RFC3339."}) */
  datetime("date-time"),

  /* AcDoc({"summary": "Represents a password string, often hinted for masking in UIs."}) */
  password("password"),

  /* AcDoc({"summary": "Represents a single-precision floating-point number."}) */
  float("float"),

  /* AcDoc({"summary": "Represents a double-precision floating-point number."}) */
  double_("double"),

  /* AcDoc({"summary": "Represents a 32-bit signed integer."}) */
  int32("int32"),

  /* AcDoc({"summary": "Represents a 64-bit signed integer."}) */
  int64("int64");

  /* AcDoc({"summary": "The string value associated with the data format type."}) */
  final String value;

  /* AcDoc({"summary": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumApiDataFormat(this.value);

  /* AcDoc({
    "summary": "Returns the enum constant matching the provided string value.",
    "params": [{"name": "value", "description": "The string value to convert to an enum."}],
    "returns": "The matching enum constant, or null if no match is found.",
    "returns_type": "AcEnumApiDataFormat?"
  }) */
  static AcEnumApiDataFormat? fromValue(String value) {
    try {
      return AcEnumApiDataFormat.values.firstWhere((e) => e.value == value);
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