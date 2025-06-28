/* AcDoc({
  "description": "Enumeration of row-level events used in data dictionary lifecycle hooks.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDRowEvent {
  /* AcDoc({"description": "Event triggered after a delete operation."}) */
  afterDelete("after_delete"),

  /* AcDoc({"description": "Event triggered after formatting the row."}) */
  afterFormat("after_format"),

  /* AcDoc({"description": "Event triggered after a new row is inserted."}) */
  afterInsert("after_insert"),

  /* AcDoc({"description": "Event triggered after modifications are made to the row."}) */
  afterModify("after_modify"),

  /* AcDoc({"description": "Event triggered after a row is saved."}) */
  afterSave("after_save"),

  /* AcDoc({"description": "Event triggered after a row is updated."}) */
  afterUpdate("after_update"),

  /* AcDoc({"description": "Event triggered before a delete operation."}) */
  beforeDelete("before_delete"),

  /* AcDoc({"description": "Event triggered before formatting the row."}) */
  beforeFormat("before_format"),

  /* AcDoc({"description": "Event triggered before a new row is inserted."}) */
  beforeInsert("before_insert"),

  /* AcDoc({"description": "Event triggered before modifying a row."}) */
  beforeModify("before_modify"),

  /* AcDoc({"description": "Event triggered before saving a row."}) */
  beforeSave("before_save"),

  /* AcDoc({"description": "Event triggered before a row is updated."}) */
  beforeUpdate("before_update"),

  /* AcDoc({"description": "Unknown or unclassified row event."}) */
  unknown("unknown");

  /* AcDoc({"description": "The string representation of the row event."}) */
  final String value;

  /* AcDoc({"description": "Constructor assigning a string value to the enum."}) */
  const AcEnumDDRowEvent(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumDDRowEvent? fromValue(String value) {
    try {
      return AcEnumDDRowEvent.values.firstWhere((e) => e.value == value);
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

  /* AcDoc({"description": "Returns the row event as a string."}) */
  @override
  String toString() => value;
}
