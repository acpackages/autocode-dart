/* AcDoc({
  "description": "Enumeration of webhook types supported by the Ac platform.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumWebHook {
  /* AcDoc({"description": "Triggered when a new AcWeb instance is created."}) */
  acWebCreated("AC_WEB_CREATED");

  /* AcDoc({"description": "The string value associated with the webhook type."}) */
  final String value;

  /* AcDoc({"description": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumWebHook(this.value);

  /* AcDoc({
    "description": "Returns the enum constant matching the provided string.",
    "params": [{"name": "value", "description": "The string to convert to an enum."}],
    "returns": "The matching enum constant, or null if not found."
  }) */
  static AcEnumWebHook? fromValue(String value) {
    try {
      return AcEnumWebHook.values.firstWhere((e) => e.value == value);
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
