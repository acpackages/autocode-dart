enum AcEnumSortOrder {
  ascending("ASC"),
  descending("DESC"),
  none("NONE");

  /* AcDoc({"description": "The string representation of the SQL database type."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum variant."}) */
  const AcEnumSortOrder(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumSortOrder? fromValue(String value) {
    try {
      return AcEnumSortOrder.values.firstWhere((e) => e.value == value);
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

  /* AcDoc({"description": "Returns the SQL database type as a string."}) */
  @override
  String toString() => value;
}
