/* AcDoc({
  "description": "Enumeration of column properties used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDColumnProperty {
  /* AcDoc({"description": "Marks the column as auto-incrementing."}) */
  autoIncrement("AUTO_INCREMENT"),

  /* AcDoc({"description": "Specifies the length of the auto-generated number."}) */
  autoNumberLength("AUTO_NUMBER_LENGTH"),

  /* AcDoc({"description": "Specifies a prefix for auto-generated numbers."}) */
  autoNumberPrefix("AUTO_NUMBER_PREFIX"),

  /* AcDoc({"description": "Indicates if the column value should be checked when computing auto number for row."}) */
  checkInAutoNumber("CHECK_IN_AUTO_NUMBER"),

  /* AcDoc({"description": "Indicates if the column value should be checked when computing while modifying row."}) */
  checkInModify("CHECK_IN_MODIFY"),

  /* AcDoc({"description": "Indicates if the column value should be checked when saving row."}) */
  checkInSave("CHECK_IN_SAVE"),

  /* AcDoc({"description": "Defines a user-friendly title for the column."}) */
  columnTitle("COLUMN_TITLE"),

  /* AcDoc({"description": "Specifies a default value for the column."}) */
  defaultValue("DEFAULT_VALUE"),

  /* AcDoc({"description": "Declares the column as a foreign key."}) */
  foreignKey("FOREIGN_KEY"),

  /* AcDoc({"description": "Specifies a special format for the column (e.g., date, JSON)."}) */
  format("FORMAT"),

  /* AcDoc({"description": "Enables SELECT DISTINCT on this column in apis."}) */
  isSelectDistinct("IS_SELECT_DISTINCT"),

  /* AcDoc({"description": "Indicates that the column cannot have null values."}) */
  notNull("NOT_NULL"),

  /* AcDoc({"description": "Additional notes or comments for the column."}) */
  remarks("REMARKS"),

  /* AcDoc({"description": "Marks the column as required (non-optional) in inputs."}) */
  required("REQUIRED"),

  /* AcDoc({"description": "Declares the column as a primary key."}) */
  primaryKey("PRIMARY_KEY"),

  /* AcDoc({"description": "List of select option values for a column in input."}) */
  valueOptions("VALUE_OPTIONS"),

  /* AcDoc({"description": "Indicates if the column value should be nullified before deletion."}) */
  setNullBeforeDelete("SET_NULL_BEFORE_DELETE"),

  /* AcDoc({"description": "Specifies the size or length of the column value."}) */
  size("SIZE"),

  tags("TAGS"),

  /* AcDoc({"description": "Marks the column as having a unique key constraint."}) */
  uniqueKey("UNIQUE_KEY"),

  /* AcDoc({"description": "Unknown property"}) */
  unknown("unknown"),

  /* AcDoc({"description": "Marks the column to be included in search queries."}) */
  useForRowLikeFilter("USE_FOR_ROW_LIKE_FILTER");

  /* AcDoc({"description": "The string representation of the column property."}) */
  final String value;

  /* AcDoc({"description": "Constructor assigning a string value to the enum."}) */
  const AcEnumDDColumnProperty(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumDDColumnProperty? fromValue(String value) {
    try {
      return AcEnumDDColumnProperty.values.firstWhere((e) => e.value == value);
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

  /* AcDoc({"description": "Returns the column property as a string."}) */
  @override
  String toString() => value;
}
