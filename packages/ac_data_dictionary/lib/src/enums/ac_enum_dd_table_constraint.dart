import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of table-level properties supported in the data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumDDTableConstraint {
  compositePrimaryKey("COMPOSITE_PRIMARY_KEY"),
  compositeUniqueKey("COMPOSITE_UNIQUE_KEY"),

  /* AcDoc({"description": "Unknown property."}) */
  unknown("unknown");

  /* AcDoc({"description": "The string representation of the table property."}) */
  final String value;

  /* AcDoc({"description": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumDDTableConstraint(this.value);

  /* AcDoc({
    "description": "Returns the enum constant matching the provided string.",
    "params": [{"name": "value", "description": "The string to convert to an enum."}],
    "returns": "The matching enum constant, or null if not found."
  }) */
  static AcEnumDDTableConstraint? fromValue(String value) {
    try {
      return AcEnumDDTableConstraint.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks whether the enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare."}],
    "returns": "true if the string matches the enum's value, false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the enum's string representation."}) */
  @override
  String toString() => value;
}
