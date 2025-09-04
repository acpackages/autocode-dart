import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of column types used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumDDColumnType {
  /* AcDoc({"description": "Auto-incrementing numeric field."}) */
  autoIncrement("AUTO_INCREMENT"),

  /* AcDoc({"description": "Automatically generated unique identifier in a specific format."}) */
  autoNumber("AUTO_NUMBER"),
  autoIndex("AUTO_INDEX"),

  /* AcDoc({"description": "Binary Large Object for storing binary data."}) */
  blob("BLOB"),

  /* AcDoc({"description": "Date-only field (YYYY-MM-DD)."}) */
  date("DATE"),

  /* AcDoc({"description": "Date and time field."}) */
  datetime("DATETIME"),

  /* AcDoc({"description": "Double-precision floating point number."}) */
  double_("DOUBLE"),

  /* AcDoc({"description": "Field that stores encrypted data."}) */
  encrypted("ENCRYPTED"),

  /* AcDoc({"description": "Integer numeric field."}) */
  integer("INTEGER"),

  /* AcDoc({"description": "JSON structured data field."}) */
  json("JSON"),

  /* AcDoc({"description": "Field to store user passwords, typically hashed."}) */
  password("PASSWORD"),

  /* AcDoc({"description": "Textual string field."}) */
  string("STRING"),

  /* AcDoc({"description": "Long form text field."}) */
  text("TEXT"),

  /* AcDoc({"description": "Time-only field (HH:MM:SS)."}) */
  time("TIME"),

  /* AcDoc({"description": "Timestamp with automatic time tracking."}) */
  timestamp("TIMESTAMP"),

  /* AcDoc({"description": "Field representing a computed value via user-defined logic."}) */
  unknown("UNKNOWN"),

  /* AcDoc({"description": "Universally Unique Identifier field."}) */
  uuid("UUID"),

  yesNo("YES_NO");

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
