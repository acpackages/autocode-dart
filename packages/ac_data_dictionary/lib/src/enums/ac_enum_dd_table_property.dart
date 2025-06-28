/* AcDoc({
  "description": "Enumeration of table-level properties supported in the data dictionary schema.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumDDTableProperty {
  /* AcDoc({"description": "Specifies the default column(s) to order results by."}) */
  orderBy("order_by"),

  /* AcDoc({"description": "Defines index number of the table."}) */
  index_("index"),

  /* AcDoc({"description": "Specifies the plural form of the table's entity name."}) */
  pluralName("plural_name"),

  /* AcDoc({"description": "Defines columns to be used while performing search query in api."}) */
  selectQueryColumns("select_query_columns"),

  /* AcDoc({"description": "Specifies the SQL query used for data selection."}) */
  selectQuery("select_query"),

  /* AcDoc({"description": "Columns used for filtering requests in apis."}) */
  selectRequestColumns("select_request_columns"),

  /* AcDoc({"description": "The name of the view used for selection."}) */
  selectViewName("select_view_name"),

  /* AcDoc({"description": "Specifies the singular form of the table's entity name."}) */
  singularName("singular_name"),

  /* AcDoc({"description": "Extra filter columns to include in search queries."}) */
  additionalFilterColumns("additional_filter_columns"),

  /* AcDoc({"description": "Unknown property."}) */
  unknown("unknown");

  /* AcDoc({"description": "The string representation of the table property."}) */
  final String value;

  /* AcDoc({"description": "Constructor to assign a string value to each enum constant."}) */
  const AcEnumDDTableProperty(this.value);

  /* AcDoc({
    "description": "Returns the enum constant matching the provided string.",
    "params": [{"name": "value", "description": "The string to convert to an enum."}],
    "returns": "The matching enum constant, or null if not found."
  }) */
  static AcEnumDDTableProperty? fromValue(String value) {
    try {
      return AcEnumDDTableProperty.values.firstWhere((e) => e.value == value);
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
