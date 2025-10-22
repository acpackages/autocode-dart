import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a database table definition from a data dictionary.",
  "description": "This class models a table, including its name, a list of its columns (`AcDDTableColumn`), and a list of its special properties (`AcDDTableProperty`). It serves as the primary object for table-level operations and for generating SQL statements related to the table.",
  "example": "// 1. Retrieve a table definition from the data dictionary.\nfinal userTable = AcDDTable.getInstance(tableName: 'users');\n\n// 2. Get the name of the primary key column.\nfinal pk = userTable.getPrimaryKeyColumnName();\nprint('Primary Key for users is: \$pk');\n\n// 3. Generate the CREATE TABLE statement.\nfinal createSql = userTable.getCreateTableStatement();\nprint(createSql);"
}) */
@AcReflectable()
class AcDDTable {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyTableColumns = "tableColumns";
  static const String keyTableName = "tableName";
  static const String keyTableProperties = "tableProperties";

  /* AcDoc({
    "summary": "A list of column objects belonging to this table."
  }) */
  @AcBindJsonProperty(key: keyTableColumns)
  List<AcDDTableColumn> tableColumns = [];

  /* AcDoc({
    "summary": "The name of the database table."
  }) */
  @AcBindJsonProperty(key: keyTableName)
  String tableName = "";

  /* AcDoc({
    "summary": "A list of special properties or metadata for this table."
  }) */
  @AcBindJsonProperty(key: keyTableProperties)
  List<AcDDTableProperty> tableProperties = [];

  /* AcDoc({
    "summary": "Creates a new, empty instance of a table definition."
  }) */
  AcDDTable();

  /* AcDoc({
    "summary": "Creates a new AcDDTable instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the table."}
    ],
    "returns": "A new, populated AcDDTable instance.",
    "returns_type": "AcDDTable"
  }) */
  factory AcDDTable.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDTable();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the table.",
    "description": "Creates a standard `DROP TABLE IF EXISTS` statement. The `databaseType` parameter is included for future dialect-specific implementations but is not currently used.",
    "params": [
      {"name": "tableName", "description": "The name of the table to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the table.",
    "returns_type": "String"
  }) */
  static String getDropTableStatement({
    required String tableName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return "DROP TABLE IF EXISTS `$tableName`;";
  }

  /* AcDoc({
    "summary": "Gets a table definition from a registered data dictionary.",
    "description": "Looks up a table by its name within the specified data dictionary and returns a populated instance. If not found, an empty instance is returned.",
    "params": [
      {"name": "tableName", "description": "The name of the table to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDTable instance.",
    "returns_type": "AcDDTable"
  }) */
  factory AcDDTable.getInstance({
    required String tableName,
    String dataDictionaryName = "default",
  }) {
    final result = AcDataDictionary.getTable(tableName: tableName,dataDictionaryName: dataDictionaryName) ?? AcDDTable();
    return result;
  }

  /* AcDoc({
    "summary": "Finds a column in this table by its name.",
    "params": [
      {"name": "columnName", "description": "The name of the column to find."}
    ],
    "returns": "The `AcDDTableColumn` object if found, otherwise `null`.",
    "returns_type": "AcDDTableColumn?"
  }) */
  AcDDTableColumn? getColumn(String columnName) {
    // Use a try/catch or a loop to safely find the column without throwing an error.
    for (final column in tableColumns) {
      if (column.columnName == columnName) {
        return column;
      }
    }
    return null;
  }

  /* AcDoc({
    "summary": "Gets a list of all column names in this table.",
    "returns": "A list of strings representing the names of all columns.",
    "returns_type": "List<String>"
  }) */
  List<String> getColumnNames() {
    return tableColumns.map((column) => column.columnName).toList();
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the table.",
    "description": "Constructs a `CREATE TABLE IF NOT EXISTS` statement by assembling the definitions of all its columns.",
    "params": [
      {"name": "databaseType", "description": "The target SQL database type, passed to each column for dialect-specific definitions."}
    ],
    "returns": "A complete SQL string to create the table.",
    "returns_type": "String"
  }) */
  String getCreateTableStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    final columnDefinitions = tableColumns.map(
      (column) => column.getColumnDefinitionForStatement(
        databaseType: databaseType,
      ),
    ).where((def) => def.isNotEmpty).toList();
    for(var property in tableProperties){
      if(property.propertyName == AcEnumDDTableProperty.constraints){
        for(var constraint in property.propertyValue){
          if(constraint['type'] == AcEnumDDTableConstraint.compositeUniqueKey){
            columnDefinitions.add("UNIQUE (${constraint['value']})");
          }
        }
      }
    }
    for(var relationship in getForeignKeyRelationships()){
      String constraintString ="FOREIGN KEY (${relationship.destinationColumn}) REFERENCES ${relationship.sourceTable}(${relationship.sourceColumn})";
      if(relationship.cascadeDeleteDestination){
        constraintString+=" ON DELETE CASCADE";
      }
      columnDefinitions.add(constraintString);
    }
    return "CREATE TABLE IF NOT EXISTS $tableName (${columnDefinitions.join(", ")});";
  }

  /* AcDoc({
    "summary": "Gets the name of the primary key column.",
    "description": "Finds the primary key column and returns its name. If there is no primary key or multiple are defined, it returns the name of the first one found or an empty string.",
    "returns": "The name of the primary key column, or an empty string if not found.",
    "returns_type": "String"
  }) */
  String getPrimaryKeyColumnName() {
    return getPrimaryKeyColumn()?.columnName ?? '';
  }

  /* AcDoc({
    "summary": "Gets the primary key column object.",
    "description": "Finds and returns the first column marked as a primary key.",
    "returns": "The primary key `AcDDTableColumn` object, or `null` if none is found.",
    "returns_type": "AcDDTableColumn?"
  }) */
  AcDDTableColumn? getPrimaryKeyColumn() {
    final primaryKeyColumns = getPrimaryKeyColumns();
    return primaryKeyColumns.isNotEmpty ? primaryKeyColumns.first : null;
  }

  /* AcDoc({
    "summary": "Gets all columns that are part of the primary key.",
    "description": "Useful for tables with composite primary keys.",
    "returns": "A list of all columns marked as primary keys.",
    "returns_type": "List<AcDDTableColumn>"
  }) */
  List<AcDDTableColumn> getPrimaryKeyColumns() {
    return tableColumns.where((column) => column.isPrimaryKey()).toList();
  }

  /* AcDoc({
    "summary": "Gets the names of all columns designated for search queries.",
    "returns": "A list of column names.",
    "returns_type": "List<String>"
  }) */
  List<String> getSearchQueryColumnNames() {
    return getSearchQueryColumns().map((column) => column.columnName).toList();
  }

  /* AcDoc({
    "summary": "Gets all column objects designated for search queries.",
    "returns": "A list of columns marked for inclusion in searches.",
    "returns_type": "List<AcDDTableColumn>"
  }) */
  List<AcDDTableColumn> getSearchQueryColumns() {
    return tableColumns
        .where((column) => column.isUseForRowLikeFilter())
        .toList();
  }

  /* AcDoc({
    "summary": "Gets all columns that are foreign keys.",
    "returns": "A list of columns that have a foreign key relationship.",
    "returns_type": "List<AcDDTableColumn>"
  }) */
  List<AcDDTableColumn> getForeignKeyColumns() {
    return tableColumns.where((column) => column.isForeignKey()).toList();
  }

  List<AcDDRelationship> getForeignKeyRelationships() {
    final result = <AcDDRelationship>[];
    final acDataDictionary = AcDataDictionary.getInstance();
    for(var relationship in acDataDictionary.relationships){
      if(relationship[AcDDRelationship.keyDestinationTable] == tableName){
        result.add(AcDDRelationship.instanceFromJson(jsonData: relationship));
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Gets the plural form of the table name from its properties.",
    "returns": "The defined plural name, or the table name itself if not defined.",
    "returns_type": "String"
  }) */
  String getPluralName() {
    for (var property in tableProperties) {
      if (property.propertyName == AcEnumDDTableProperty.pluralName) {
        return property.propertyValue;
      }
    }
    return tableName;
  }

  /* AcDoc({
    "summary": "Gets the singular form of the table name from its properties.",
    "returns": "The defined singular name, or the table name itself if not defined.",
    "returns_type": "String"
  }) */
  String getSingularName() {
    for (var property in tableProperties) {
      if (property.propertyName == AcEnumDDTableProperty.singularName) {
        return property.propertyValue;
      }
    }
    return tableName;
  }

  /* AcDoc({
    "summary": "Gets all columns marked for 'SELECT DISTINCT' queries.",
    "returns": "A list of columns designated for distinct selection.",
    "returns_type": "List<AcDDTableColumn>"
  }) */
  List<AcDDTableColumn> getSelectDistinctColumns() {
    return tableColumns.where((column) => column.isSelectDistinct()).toList();
  }

  /* AcDoc({
    "summary": "Populates the instance from a JSON map.",
    "description": "This method manually deserializes the nested `tableColumns` and `tableProperties` lists before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the table's properties."}
    ],
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDTable"
  }) */
  AcDDTable fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (jsonData.containsKey(keyTableColumns) &&
        jsonData[keyTableColumns] is Map) {
      (json[keyTableColumns] as Map).forEach((columnName, columnData) {
        final column = AcDDTableColumn.instanceFromJson(jsonData: columnData);
        column.table = this;
        tableColumns.add(column);
      });
      json.remove(keyTableColumns);
    }

    if (json.containsKey(keyTableProperties) &&
        json[keyTableProperties] is Map) {
      (json[keyTableProperties] as Map).forEach((propertyName, propertyData) {
        tableProperties.add(
          AcDDTableProperty.instanceFromJson(jsonData: propertyData),
        );
      });
      json.remove(keyTableProperties);
    }

    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current table instance to a JSON map.",
    "returns": "A JSON map representation of the table.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the table.",
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
// class AcDDTable {
//   static const String KEY_TABLE_COLUMNS = "table_columns";
//   static const String KEY_TABLE_NAME = "table_name";
//   static const String KEY_TABLE_PROPERTIES = "table_properties";
//
//   @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_COLUMNS)
//   List<AcDDTableColumn> tableColumns = [];
//
//   @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_NAME)
//   String tableName = "";
//
//   @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_PROPERTIES)
//   List<AcDDTableProperty> tableProperties = [];
//
//   static AcDDTable instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDTable();
//     instance.fromJson(jsonData: jsonData);
//     return instance;
//   }
//
//   static String getDropTableStatement({required String tableName,AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     return "DROP TABLE IF EXISTS $tableName;";
//   }
//
//   static AcDDTable getInstance({
//     required String tableName,
//     String dataDictionaryName = "default",
//   }) {
//     final result = AcDDTable();
//     final acDataDictionary = AcDataDictionary.getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//
//     if (acDataDictionary.tables.containsKey(tableName)) {
//       result.fromJson(jsonData: acDataDictionary.tables[tableName]);
//     }
//
//     return result;
//   }
//
//   AcDDTableColumn? getColumn(String columnName) {
//     return tableColumns.firstWhere((column) => column.columnName == columnName);
//   }
//
//   List<String> getColumnNames() {
//     return tableColumns.map((column) => column.columnName).toList();
//   }
//
//   String getCreateTableStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     List<String> columnDefinitions = [];
//     for (final column in tableColumns) {
//       final columnDefinition = column.getColumnDefinitionForStatement(databaseType: databaseType);
//       if (columnDefinition != "") {
//         columnDefinitions.add(columnDefinition);
//       }
//     }
//     final result = "CREATE TABLE IF NOT EXISTS $tableName (${columnDefinitions.join(", ")});";
//     return result;
//   }
//
//   String getPrimaryKeyColumnName() {
//     final primaryKeyColumn = getPrimaryKeyColumn();
//     return primaryKeyColumn != null ? primaryKeyColumn.columnName : '';
//   }
//
//   AcDDTableColumn? getPrimaryKeyColumn() {
//     final primaryKeyColumns = getPrimaryKeyColumns();
//     return primaryKeyColumns.isNotEmpty ? primaryKeyColumns[0] : null;
//   }
//
//   List<AcDDTableColumn> getPrimaryKeyColumns() {
//     return tableColumns.where((column) => column.isPrimaryKey()).toList();
//   }
//
//   List<String> getSearchQueryColumnNames() {
//     return getSearchQueryColumns().map((column) => column.columnName).toList();
//   }
//
//   List<AcDDTableColumn> getSearchQueryColumns() {
//     return tableColumns.where((column) => column.isInSearchQuery()).toList();
//   }
//
//   List<AcDDTableColumn> getForeignKeyColumns() {
//     return tableColumns.where((column) => column.isForeignKey()).toList();
//   }
//
//   String getPluralName() {
//     String result = tableName;
//     for (var property in tableProperties) {
//       if (property.propertyName == AcEnumDDTableProperty.pluralName) {
//         result = property.propertyValue;
//       }
//     }
//     return result;
//   }
//
//   String getSingularName() {
//     String result = tableName;
//     for (var property in tableProperties) {
//       if (property.propertyName == AcEnumDDTableProperty.singularName) {
//         result = property.propertyValue;
//       }
//     }
//     return result;
//   }
//
//   List<AcDDTableColumn> getSelectDistinctColumns() {
//     return tableColumns.where((column) => column.isSelectDistinct()).toList();
//   }
//
//   AcDDTable fromJson({required Map<String, dynamic> jsonData}) {
//     Map<String,dynamic> json = Map.from(jsonData);
//     if (jsonData.containsKey(KEY_TABLE_COLUMNS) &&
//         jsonData[KEY_TABLE_COLUMNS] is Map) {
//       json[KEY_TABLE_COLUMNS].forEach((columnName, columnData) {
//         final column = AcDDTableColumn.instanceFromJson(jsonData: columnData);
//         column.table = this;
//         tableColumns.add(column);
//       });
//       json.remove(KEY_TABLE_COLUMNS);
//     }
//
//     if (json.containsKey(KEY_TABLE_PROPERTIES) &&
//         json[KEY_TABLE_PROPERTIES] is Map) {
//       json[KEY_TABLE_PROPERTIES].forEach((propertyName, propertyData) {
//         tableProperties.add(
//           AcDDTableProperty.instanceFromJson(jsonData: propertyData),
//         );
//       });
//       json.remove(KEY_TABLE_PROPERTIES);
//     }
//
//     AcJsonUtils.setInstancePropertiesFromJsonData(
//       instance: this,
//       jsonData: json,
//     );
//     return this;
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
