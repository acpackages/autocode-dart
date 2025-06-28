/* AcDoc({
  "description": "Enumeration of common CSS units used for defining dimensions in styles.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumCssUnit {
  /* AcDoc({"description": "Pixels - relative to the screen resolution."}) */
  px('px'),

  /* AcDoc({"description": "Centimeters - absolute length unit."}) */
  cm('cm'),

  /* AcDoc({"description": "Millimeters - absolute length unit."}) */
  mm('mm'),

  /* AcDoc({"description": "Inches - absolute length unit."}) */
  inch('in'),

  /* AcDoc({"description": "Points - 1/72 of an inch."}) */
  pt('pt'),

  /* AcDoc({"description": "Picas - 1 pica equals 12 points."}) */
  pc('pc');

  /* AcDoc({"description": "The string representation of the CSS unit (e.g., 'px', 'cm')."}) */
  final String value;

  /* AcDoc({"description": "Constructor that initializes the enum with a string value."}) */
  const AcEnumCssUnit(this.value);

  /* AcDoc({
    "description": "Retrieves the enum constant from the given string value.",
    "params": [{"name": "value", "description": "String value corresponding to a CSS unit."}],
    "returns": "The matching AcEnumCssUnit or null if no match is found."
  }) */
  static AcEnumCssUnit? fromValue(String value) {
    try {
      return AcEnumCssUnit.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if the enum's value matches the given string.",
    "params": [{"name": "other", "description": "The string to compare with the enum value."}],
    "returns": "true if matched; false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({
    "description": "Returns the CSS unit as a string.",
    "returns": "The string value of the CSS unit."
  }) */
  @override
  String toString() => value;
}
