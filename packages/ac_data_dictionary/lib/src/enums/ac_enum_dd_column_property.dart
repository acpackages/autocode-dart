/* AcDoc({
  "description": "Enumeration of column properties used in a data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDColumnProperty {
  /* AcDoc({"description": "Marks the column as auto-incrementing."}) */
  autoIncrement("auto_increment"),

  /* AcDoc({"description": "Specifies the length of the auto-generated number."}) */
  autoNumberLength("auto_number_length"),

  /* AcDoc({"description": "Specifies a prefix for auto-generated numbers."}) */
  autoNumberPrefix("auto_number_prefix"),

  /* AcDoc({"description": "Indicates if the column value should be checked when computing auto number for row."}) */
  checkInAutoNumber("check_in_auto_number"),

  /* AcDoc({"description": "Indicates if the column value should be checked when computing while modifying row."}) */
  checkInModify("check_in_modify"),

  /* AcDoc({"description": "Indicates if the column value should be checked when saving row."}) */
  checkInSave("check_in_save"),

  /* AcDoc({"description": "Defines a user-friendly title for the column."}) */
  columnTitle("column_title"),

  /* AcDoc({"description": "Specifies a default value for the column."}) */
  defaultValue("default_value"),

  /* AcDoc({"description": "Declares the column as a foreign key."}) */
  foreignKey("foreign_key"),

  /* AcDoc({"description": "Specifies a special format for the column (e.g., date, JSON)."}) */
  format("format"),

  /* AcDoc({"description": "Enables SELECT DISTINCT on this column in apis."}) */
  isSelectDistinct("is_select_distinct"),

  /* AcDoc({"description": "Marks the column to be included in search queries."}) */
  inSearchQuery("in_search_query"),

  /* AcDoc({"description": "Indicates that the column cannot have null values."}) */
  notNull("not_null"),

  /* AcDoc({"description": "Additional notes or comments for the column."}) */
  remarks("remarks"),

  /* AcDoc({"description": "Marks the column as required (non-optional) in inputs."}) */
  required("required"),

  /* AcDoc({"description": "Declares the column as a primary key."}) */
  primaryKey("primary_key"),

  /* AcDoc({"description": "List of select option values for a column in input."}) */
  selectOptions("select_options"),

  /* AcDoc({"description": "Indicates if the column value should be nullified before deletion."}) */
  setNullBeforeDelete("set_null_before_delete"),

  /* AcDoc({"description": "Specifies the size or length of the column value."}) */
  size("size"),

  /* AcDoc({"description": "Marks the column as having a unique key constraint."}) */
  uniqueKey("unique_key"),

  /* AcDoc({"description": "Unknown property"}) */
  unknown("unknown");

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
