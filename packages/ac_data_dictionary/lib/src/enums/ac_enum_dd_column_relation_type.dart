/* AcDoc({
  "description": "Enumeration of column relation types used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDColumnRelationType {
  /* AcDoc({"description": "Indicates the relation can be of any type (source or destination)."}) */
  any("ANY"),

  /* AcDoc({"description": "Specifies the relation as a source in the schema."}) */
  source("SOURCE"),

  /* AcDoc({"description": "Specifies the relation as a destination in the schema."}) */
  destination("DESTINATION");

  /* AcDoc({"description": "The string representation of the relation type."}) */
  final String value;

  /* AcDoc({"description": "Constructor assigning a string value to the enum."}) */
  const AcEnumDDColumnRelationType(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumDDColumnRelationType? fromValue(String value) {
    try {
      return AcEnumDDColumnRelationType.values.firstWhere(
        (e) => e.value == value,
      );
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

  /* AcDoc({"description": "Returns the column relation type as a string."}) */
  @override
  String toString() => value;
}
