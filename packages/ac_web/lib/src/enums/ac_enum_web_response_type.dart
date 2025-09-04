/* AcDoc({
  "description": "Enumeration of different types of web responses supported by the Ac platform.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumWebResponseType {
  /* AcDoc({"description": "Indicates a downloadable file response."}) */
  download("DOWNLOAD"),

  /* AcDoc({"description": "Indicates a file response type, typically binary or large file transfers."}) */
  file("FILE"),

  /* AcDoc({"description": "Response that returns HTML content."}) */
  html("HTML"),

  /* AcDoc({"description": "Response formatted as JSON."}) */
  json("JSON"),

  /* AcDoc({"description": "Response that redirects the user to another URL."}) */
  redirect("REDIRECT"),

  /* AcDoc({"description": "Raw, unformatted response output."}) */
  raw("RAW"),

  /* AcDoc({"description": "Plain text response."}) */
  text("TEXT"),

  /* AcDoc({"description": "Response that returns a rendered view/template."}) */
  view("VIEW");

  /* AcDoc({"description": "The string value associated with the web response type."}) */
  final String value;

  /* AcDoc({"description": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumWebResponseType(this.value);

  /* AcDoc({
    "description": "Returns the enum constant matching the provided string.",
    "params": [{"name": "value", "description": "The string to convert to an enum."}],
    "returns": "The matching enum constant, or null if not found."
  }) */
  static AcEnumWebResponseType? fromValue(String value) {
    try {
      return AcEnumWebResponseType.values.firstWhere((e) => e.value == value);
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
