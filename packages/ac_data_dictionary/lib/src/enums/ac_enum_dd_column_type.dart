/* AcDoc({
  "description": "Enumeration of column types used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDColumnType {
  /* AcDoc({"description": "Auto-incrementing numeric field."}) */
  autoIncrement("auto_increment"),

  /* AcDoc({"description": "Automatically generated unique identifier in a specific format."}) */
  autoNumber("auto_number"),

  /* AcDoc({"description": "Binary Large Object for storing binary data."}) */
  blob("blob"),

  /* AcDoc({"description": "Date-only field (YYYY-MM-DD)."}) */
  date("date"),

  /* AcDoc({"description": "Date and time field."}) */
  datetime("datetime"),

  /* AcDoc({"description": "Double-precision floating point number."}) */
  double_("double"),

  /* AcDoc({"description": "Field that stores encrypted data."}) */
  encrypted("encrypted"),

  /* AcDoc({"description": "Integer numeric field."}) */
  integer("integer"),

  /* AcDoc({"description": "JSON structured data field."}) */
  json("json"),

  /* AcDoc({"description": "JSON representing media data, such as images or video metadata."}) */
  mediaJson("media_json"),

  /* AcDoc({"description": "Field to store user passwords, typically hashed."}) */
  password("password"),

  /* AcDoc({"description": "Textual string field."}) */
  string("string"),

  /* AcDoc({"description": "Long form text field."}) */
  text("text"),

  /* AcDoc({"description": "Time-only field (HH:MM:SS)."}) */
  time("time"),

  /* AcDoc({"description": "Timestamp with automatic time tracking."}) */
  timestamp("timestamp"),

  /* AcDoc({"description": "Field representing a computed value via user-defined logic."}) */
  userDefinedFunction("user_defined_function"),

  /* AcDoc({"description": "Universally Unique Identifier field."}) */
  uuid("uuid");

  /* AcDoc({"description": "The string representation of the column type."}) */
  final String value;

  /* AcDoc({"description": "Constructor assigning a string value to the enum."}) */
  const AcEnumDDColumnType(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumDDColumnType? fromValue(String value) {
    try {
      return AcEnumDDColumnType.values.firstWhere((e) => e.value == value);
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

  /* AcDoc({"description": "Returns the column type as a string."}) */
  @override
  String toString() => value;
}
