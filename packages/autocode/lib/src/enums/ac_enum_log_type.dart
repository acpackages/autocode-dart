/* AcDoc({
  "description": "Enumeration of different log output types supported in the system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumLogType {
  /* AcDoc({"description": "Logs output to the system console."}) */
  console('CONSOLE'),

  /* AcDoc({"description": "Logs output using Dart's print statement. 'print' is a reserved keyword, so 'print_' is used."}) */
  print_('PRINT'),

  /* AcDoc({"description": "Logs output to HTML content, useful in web environments."}) */
  html('HTML'),

  /* AcDoc({"description": "Logs output to a SQLite database for persistent storage."}) */
  sqlite('SQLITE'),

  /* AcDoc({"description": "Logs output to plain text format, typically in a file."}) */
  text('TEXT');

  /* AcDoc({"description": "The string representation of the log output type."}) */
  final String value;

  /* AcDoc({"description": "Constructor that sets the string value for the log output type."}) */
  const AcEnumLogType(this.value);

  /* AcDoc({
    "description": "Finds the log type enum that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum or null if no match."
  }) */
  static AcEnumLogType? fromValue(String value) {
    try {
      return AcEnumLogType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's string value is equal to another string.",
    "params": [{"name": "other", "description": "The string to compare."}],
    "returns": "true if equal, false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the log type as a string."}) */
  @override
  String toString() => value;
}
