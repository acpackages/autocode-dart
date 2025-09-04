import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of row-level events used in data dictionary lifecycle hooks.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumDDRowEvent {
  /* AcDoc({"description": "Event triggered after a delete operation."}) */
  afterDelete("AFTER_DELETE"),

  /* AcDoc({"description": "Event triggered after formatting the row."}) */
  afterFormat("AFTER_FORMAT"),

  /* AcDoc({"description": "Event triggered after a new row is inserted."}) */
  afterInsert("AFTER_INSERT"),

  /* AcDoc({"description": "Event triggered after modifications are made to the row."}) */
  afterModify("AFTER_MODIFY"),

  /* AcDoc({"description": "Event triggered after a row is saved."}) */
  afterSave("AFTER_SAVE"),

  /* AcDoc({"description": "Event triggered after a row is updated."}) */
  afterUpdate("AFTER_UPDATE"),

  /* AcDoc({"description": "Event triggered before a delete operation."}) */
  beforeDelete("BEFORE_DELETE"),

  /* AcDoc({"description": "Event triggered before formatting the row."}) */
  beforeFormat("BEFORE_FORMAT"),

  /* AcDoc({"description": "Event triggered before a new row is inserted."}) */
  beforeInsert("BEFORE_INSERT"),

  /* AcDoc({"description": "Event triggered before modifying a row."}) */
  beforeModify("BEFORE_MODIFY"),

  /* AcDoc({"description": "Event triggered before saving a row."}) */
  beforeSave("BEFORE_SAVE"),

  /* AcDoc({"description": "Event triggered before a row is updated."}) */
  beforeUpdate("BEFORE_UPDATE"),

  /* AcDoc({"description": "Unknown or unclassified row event."}) */
  unknown("UNKNOWN");

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
