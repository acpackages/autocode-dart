import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a single column within a database view definition.",
  "description": "This class models a column as it appears in a view, including its name, data type, its original source table and column, and any specific properties. This is distinct from a table column as it represents a column in a result set of a query.",
  "example": "// Example of a view column 'user_name' derived from the 'users' table.\n final viewColumn = AcDDViewColumn.instanceFromJson(jsonData: {\n  'column_name': 'user_name',\n  'column_type': 'text',\n  'column_source': 'table',\n  'column_source_name': 'users.name'\n});"
}) */
@AcReflectable()
class AcDDViewColumn {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyColumnName = "columnName";
  static const String keyColumnProperties = "columnProperties";
  static const String keyColumnType = "columnType";
  static const String keyColumnValue = "columnValue";
  static const String keyColumnSource = "columnSource";
  static const String keyColumnSourceName = "columnSourceName";
  static const String keyColumnSourceOriginalColumn = "columnSourceOriginalColumn";

  /* AcDoc({"summary": "The name of the column as it appears in the view."}) */
  @AcBindJsonProperty(key: keyColumnName)
  String columnName = "";

  /* AcDoc({
    "summary": "A map of properties that define the view column's behavior.",
    "description": "Contains key-value pairs for metadata specific to this column in the context of the view."
  }) */
  @AcBindJsonProperty(key: keyColumnProperties)
  Map<String, AcDDTableColumnProperty> columnProperties = {};

  /* AcDoc({
    "summary": "The data type of the column as a string (e.g., 'text', 'integer')."
  }) */
  @AcBindJsonProperty(key: keyColumnType)
  AcEnumDDColumnType columnType = AcEnumDDColumnType.unknown;

  /* AcDoc({"summary": "The current value of the column, used when this object represents a specific record's data."}) */
  @AcBindJsonProperty(key: keyColumnValue)
  dynamic columnValue;

  /* AcDoc({
    "summary": "The type of the source for this column's data (e.g., 'table')."
  }) */
  @AcBindJsonProperty(key: keyColumnSource)
  String columnSource = "";

  /* AcDoc({
    "summary": "The original source of the data (e.g., 'users.name')."
  }) */
  @AcBindJsonProperty(key: keyColumnSourceName)
  String columnSourceName = "";

  @AcBindJsonProperty(key: keyColumnSourceOriginalColumn)
  String columnSourceOriginalColumn = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a view column definition."
  }) */
  AcDDViewColumn();

  factory AcDDViewColumn.getInstance({
    required String viewName,
    required String columnName,
    String dataDictionaryName = 'default',
  }) {
    return AcDataDictionary.getViewColumn(
      viewName: viewName,
      columnName: columnName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }

  /* AcDoc({
    "summary": "Creates a new AcDDViewColumn instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the view column."}
    ],
    "returns": "A new, populated AcDDViewColumn instance.",
    "returns_type": "AcDDViewColumn"
  }) */
  factory AcDDViewColumn.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDViewColumn();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `columnProperties` map before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the view column's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDViewColumn"
  }) */
  AcDDViewColumn fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyColumnProperties) && json[keyColumnProperties] is Map) {
      jsonData[keyColumnProperties].forEach((key, value) {
        if(key is AcEnumDDColumnProperty){
          columnProperties[key.value] = AcDDTableColumnProperty.instanceFromJson(
            jsonData: value,
          );
        }
        else{
          columnProperties[key] = AcDDTableColumnProperty.instanceFromJson(
            jsonData: value,
          );
        }

      });
      json.remove(keyColumnProperties);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  String getColumnTitle() {
    // Check if we have an explicitly set column title in properties
    if (columnProperties.containsKey(AcEnumDDColumnProperty.columnTitle.value)) {
      final propertyValue = columnProperties[AcEnumDDColumnProperty.columnTitle.value]?.propertyValue;
      if (propertyValue != null) {
        return propertyValue;
      }
      return columnName;
    }

    // For table source
    if (columnSource == 'table') {
      if (columnSourceName.isNotEmpty && columnSourceOriginalColumn.isNotEmpty) {
        final ddTableColumn = AcDDTableColumn.getInstance(
          tableName: columnSourceName,
          columnName: columnSourceOriginalColumn,
        );

        return ddTableColumn.getColumnTitle();
      }
    }

    // For view source
    else if (columnSource == 'view') {
      if (columnSourceName.isNotEmpty && columnSourceOriginalColumn.isNotEmpty) {
        final ddViewColumn = AcDDViewColumn.getInstance(
          viewName: columnSourceName,
          columnName: columnSourceOriginalColumn,
        );
        return ddViewColumn.getColumnTitle();
      }
    }

    // Fallback
    return columnName;
  }

  /* AcDoc({"summary": "Checks if the column should be included in default search queries."}) */
  bool isUseForRowLikeFilter() {

    // 1. Check explicit property first
    final explicitProp = columnProperties[AcEnumDDColumnProperty.useForRowLikeFilter.value]?.propertyValue;

    if (explicitProp == true) {
      return true;
    }

    // 2. No explicit true → check source column

    if (columnSource == 'table') {
      if (columnSourceName.isNotEmpty && columnSourceOriginalColumn.isNotEmpty) {
        final ddTableColumn = AcDataDictionary.getTableColumn(
          tableName: columnSourceName,
          columnName: columnSourceOriginalColumn,
        );

        if(ddTableColumn != null){
          final result = ddTableColumn.isUseForRowLikeFilter();
          return result;
        }
      } else {
      }
    }
    else if (columnSource == 'view') {
      if (columnSourceName.isNotEmpty && columnSourceOriginalColumn.isNotEmpty) {
        final ddViewColumn = AcDataDictionary.getViewColumn(
          viewName: columnSourceName,
          columnName: columnSourceOriginalColumn,
        );

        if(ddViewColumn != null){
          final result = ddViewColumn.isUseForRowLikeFilter();
          return result;
        }

      } else {
      }
    }
    else {
    }

    return false;
  }

  /* AcDoc({
    "summary": "Serializes the current view column instance to a JSON map.",
    "returns": "A JSON map representation of the view column.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the view column.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}