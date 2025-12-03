import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_mirrors/ac_mirrors.dart';

import '../../autocode.dart';

/* AcDoc({
  "description": "Enumeration representing logical operators used in conditional expressions.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumLogicalOperator {
  /* AcDoc({"description": "Logical AND operator."}) */
  and('AND'),

  /* AcDoc({"description": "Logical OR operator."}) */
  or('OR'),

  /* AcDoc({"description": "Unknown operator."}) */
  unknown('UNKNOWN');

  /* AcDoc({"description": "The string representation of the logical operator."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum variant."}) */
  const AcEnumLogicalOperator(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumLogicalOperator fromValue(String value) {
    return AcEnumLogicalOperator.values.firstWhere((e) =>
        e.value.equalsIgnoreCase(value),
        orElse: () => AcEnumLogicalOperator.unknown);
  }
  /* AcDoc({
    "description": "Checks if this enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the string matches, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the logical operator as a string."}) */
  @override
  String toString() => value;

  dynamic toJson() {
    return value;
  }
}
