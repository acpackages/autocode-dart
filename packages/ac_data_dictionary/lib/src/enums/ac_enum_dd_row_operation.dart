import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of operations that can be performed on a row within the data dictionary system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumDDRowOperation {
  /* AcDoc({"description": "Operation representing the deletion of a row."}) */
  delete("DELETE"),

  /* AcDoc({"description": "Operation representing the formatting of a row's content or structure."}) */
  format("FORMAT"),

  /* AcDoc({"description": "Operation representing the insertion of a new row."}) */
  insert("INSERT"),

  /* AcDoc({"description": "Operation representing the saving of a row's state."}) */
  save("SAVE"),

  /* AcDoc({"description": "Operation representing the selection or retrieval of a row."}) */
  select("SELECT"),

  /* AcDoc({"description": "Operation representing the update of existing row data."}) */
  update("UPDATE"),

  /* AcDoc({"description": "Unknown or undefined row operation."}) */
  unknown("UNKNOWN");

  /* AcDoc({"description": "The string representation of the row operation."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum."}) */
  const AcEnumDDRowOperation(this.value);

  /* AcDoc({
    "description": "Returns the enum constant that matches the provided string value.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum constant, or null if no match is found."
  }) */
  static AcEnumDDRowOperation? fromValue(String value) {
    try {
      return AcEnumDDRowOperation.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks whether this enum's value is equal to the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the values are equal, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the string representation of the row operation."}) */
  @override
  String toString() => value;

  dynamic toJson() {
    return value;
  }
}
