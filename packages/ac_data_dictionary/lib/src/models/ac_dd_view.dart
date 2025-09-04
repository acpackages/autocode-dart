import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a database view definition from a data dictionary.",
  "description": "This class models a database view, containing its name, the underlying SELECT query that defines it, and a map of its resulting columns (`AcDDViewColumn`). It provides methods for generating SQL statements to create or drop the view.",
  "example": "// 1. Retrieve a view definition.\nfinal userView = AcDDView.getInstance('active_users_view');\n\n// 2. Generate the SQL to create the view.\nfinal createSql = userView.getCreateViewStatement();\nprint(createSql);"
}) */
@AcReflectable()
class AcDDView {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyViewName = "viewName";
  static const String keyViewColumns = "viewColumns";
  static const String keyViewQuery = "viewQuery";

  /* AcDoc({
    "summary": "The name of the database view."
  }) */
  @AcBindJsonProperty(key: keyViewName)
  String viewName = "";

  /* AcDoc({
    "summary": "The complete SELECT statement that defines the view's data."
  }) */
  @AcBindJsonProperty(key: keyViewQuery)
  String viewQuery = "";

  /* AcDoc({
    "summary": "A map of column names to their corresponding `AcDDViewColumn` definitions."
  }) */
  @AcBindJsonProperty(key: keyViewColumns)
  Map<String, AcDDViewColumn> viewColumns = {};

  /* AcDoc({
    "summary": "Creates a new, empty instance of a view definition."
  }) */
  AcDDView();

  /* AcDoc({
    "summary": "Creates a new AcDDView instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the view."}
    ],
    "returns": "A new, populated AcDDView instance.",
    "returns_type": "AcDDView"
  }) */
  factory AcDDView.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDView();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Gets a view definition from a registered data dictionary.",
    "description": "Looks up a view by its name within the specified data dictionary and returns a populated instance. If not found, an empty instance is returned.",
    "params": [
      {"name": "viewName", "description": "The name of the view to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDView instance.",
    "returns_type": "AcDDView"
  }) */
  factory AcDDView.getInstance(
    String viewName, {
    String dataDictionaryName = "default",
  }) {
    final result = AcDDView();
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );

    if (acDataDictionary.views.containsKey(viewName)) {
      result.fromJson(jsonData: acDataDictionary.views[viewName]);
    }

    return result;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `viewColumns` map before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the view's properties."}
    ],
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDView"
  }) */
  AcDDView fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyViewColumns) && json[keyViewColumns] is Map) {
      final columns = jsonData[keyViewColumns] as Map;
      columns.forEach((columnName, columnData) {
        viewColumns[columnName] = AcDDViewColumn.instanceFromJson(
          jsonData: columnData,
        );
      });
      json.remove(keyViewColumns);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the view.",
    "description": "Creates a standard `DROP VIEW IF EXISTS` statement. The `databaseType` parameter is included for future dialect-specific implementations but is not currently used.",
    "params": [
      {"name": "viewName", "description": "The name of the view to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the view.",
    "returns_type": "String"
  }) */
  static String getDropViewStatement({
    required String viewName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return 'DROP VIEW IF EXISTS $viewName;';
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the view.",
    "description": "Constructs a `CREATE VIEW` statement using the view's name and its underlying query. The `databaseType` parameter is included for future use but does not currently affect the output.",
    "params": [
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "The complete SQL string to create the view.",
    "returns_type": "String"
  }) */
  String getCreateViewStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return 'CREATE VIEW $viewName AS $viewQuery;';
  }

  /* AcDoc({
    "summary": "Serializes the current view instance to a JSON map.",
    "returns": "A JSON map representation of the view.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the view.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}

// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// @AcReflectable()
// class AcDDView {
//   static const String KEY_VIEW_NAME = "view_name";
//   static const String KEY_VIEW_COLUMNS = "view_columns";
//   static const String KEY_VIEW_QUERY = "view_query";
//
//   @AcBindJsonProperty(key: AcDDView.KEY_VIEW_NAME)
//   String viewName = "";
//
//   @AcBindJsonProperty(key: AcDDView.KEY_VIEW_QUERY)
//   String viewQuery = "";
//
//   @AcBindJsonProperty(key: AcDDView.KEY_VIEW_COLUMNS)
//   Map<String, AcDDViewColumn> viewColumns = {};
//
//   static AcDDView instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDView();
//     instance.fromJson(jsonData: jsonData);
//     return instance;
//   }
//
//   static AcDDView getInstance(
//     String viewName, {
//     String dataDictionaryName = "default",
//   }) {
//     final result = AcDDView();
//     final acDataDictionary = AcDataDictionary.getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//
//     if (acDataDictionary.views.containsKey(viewName)) {
//       result.fromJson(jsonData: acDataDictionary.views[viewName]);
//     }
//
//     return result;
//   }
//
//   AcDDView fromJson({required Map<String, dynamic> jsonData}) {
//     Map<String,dynamic> json = Map.from(jsonData);
//     if (json.containsKey(KEY_VIEW_COLUMNS) &&
//         json[KEY_VIEW_COLUMNS] is Map) {
//       final columns = jsonData[KEY_VIEW_COLUMNS] as Map;
//       columns.forEach((columnName, columnData) {
//         viewColumns[columnName] = AcDDViewColumn.instanceFromJson(
//           jsonData: columnData,
//         );
//       });
//       json.remove(KEY_VIEW_COLUMNS);
//     }
//     AcJsonUtils.setInstancePropertiesFromJsonData(
//       instance: this,
//       jsonData: json,
//     );
//     return this;
//   }
//
//   static String getDropViewStatement({required String viewName, AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     return 'DROP VIEW IF EXISTS $viewName;';
//   }
//
//   String getCreateViewStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     return 'CREATE VIEW $viewName AS $viewQuery;';
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance: this);
//   }
//
//   @override
//   String toString() {
//     return AcJsonUtils.prettyEncode(toJson());
//   }
// }
