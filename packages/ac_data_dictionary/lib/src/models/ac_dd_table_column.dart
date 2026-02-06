import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

@AcReflectable()
/* AcDoc({
  "summary": "Represents a single column within a database table definition.",
  "description": "This class models all metadata for a column, including its name, data type, a default value, and a rich set of properties that define its behavior (e.g., primary key, auto-increment, nullability). It also provides methods to generate SQL definitions for the column.",
  "example": "// 1. Retrieve a column definition from a table.\nfinal userTable = AcDDTable.getInstance(tableName: 'users');\nfinal idColumn = userTable.getColumn('id');\n\n// 2. Check properties of the column.\nif (idColumn != null && idColumn.isPrimaryKey()) {\n  print('Column \"id\" is the primary key.');\n}\n\n// 3. Generate the SQL definition for the column.\nfinal definition = idColumn?.getColumnDefinitionForStatement(databaseType: AcEnumSqlDatabaseType.mysql);\nprint('SQL Definition: \$definition');"
}) */
class AcDDTableColumn {
  static const String keyColumnName = "columnName";
  static const String keyColumnProperties = "columnProperties";
  static const String keyColumnType = "columnType";
  static const String keyColumnValue = "columnValue";

  /* AcDoc({"summary": "The name of the database column."}) */
  @AcBindJsonProperty(key: AcDDTableColumn.keyColumnName)
  String columnName = "";

  /* AcDoc({
    "summary": "A map of properties that define the column's behavior and metadata.",
    "description": "Contains key-value pairs where the key is an `AcEnumDDColumnProperty` and the value is an `AcDDTableColumnProperty` object."
  }) */
  @AcBindJsonProperty(key: AcDDTableColumn.keyColumnProperties)
  Map<String, AcDDTableColumnProperty> columnProperties = {};

  /* AcDoc({"summary": "The data type of the column."}) */
  @AcBindJsonProperty(key: AcDDTableColumn.keyColumnType)
  AcEnumDDColumnType columnType = AcEnumDDColumnType.text;

  /* AcDoc({"summary": "The current value of the column, used when this object represents a specific record's data."}) */
  @AcBindJsonProperty(key: AcDDTableColumn.keyColumnValue)
  dynamic columnValue;

  /* AcDoc({
    "summary": "A back-reference to the parent table containing this column.",
    "description": "This is populated during the table's `fromJson` deserialization process."
  }) */
  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  /* AcDoc({"summary": "Creates a new, empty instance of a table column."}) */
  AcDDTable? table;

  /* AcDoc({
    "summary": "Gets a column definition from a registered data dictionary.",
    "description": "Looks up a column by its table and column name. Important: This method uses a force-unwrap (`!`) and will throw an error if the column is not found.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "columnName", "description": "The name of the column to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An `AcDDTableColumn` instance.",
    "returns_type": "AcDDTableColumn"
  }) */
  static AcDDTableColumn getInstance({
    required String tableName,
    required String columnName,
    String dataDictionaryName = "default",
  }) {
    return AcDataDictionary.getTableColumn(
      tableName: tableName,
      columnName: columnName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }

  /* AcDoc({
    "summary": "Creates a new AcDDTableColumn instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the column."}
    ],
    "returns": "A new, populated AcDDTableColumn instance.",
    "returns_type": "AcDDTableColumn"
  }) */
  static AcDDTableColumn instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDTableColumn();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the column from its table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to alter."},
      {"name": "columnName", "description": "The name of the column to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the column.",
    "returns_type": "String"
  }) */
  static String getDropColumnStatement({
    required String tableName,
    required String columnName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return "ALTER TABLE $tableName DROP COLUMN $columnName;";
  }

  /* AcDoc({"summary": "Checks if the column is configured for auto-numbering on check-in."}) */
  bool checkInAutoNumber() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.checkInAutoNumber.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.checkInAutoNumber.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is configured to be modifiable."}) */
  bool checkInModify() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.checkInModify.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.checkInModify.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is configured to be included in save operations."}) */
  bool checkInSave() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.checkInSave.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.checkInSave.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Gets the specified length for an auto-numbered value."}) */
  int getAutoNumberLength() {
    int result = 0;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.autoNumberLength.value,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.autoNumberLength.value]
              ?.propertyValue ??
          0;
    }
    return result;
  }

  /* AcDoc({"summary": "Gets the specified prefix for an auto-numbered value."}) */
  String getAutoNumberPrefix() {
    String result = "";
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.autoNumberPrefix.value,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.autoNumberPrefix.value]
              ?.propertyValue ??
          "";
    }
    return result;
  }

  /* AcDoc({"summary": "Calculates the length of the auto-number prefix."}) */
  int getAutoNumberPrefixLength() {
    return getAutoNumberPrefix().length;
  }

  /* AcDoc({"summary": "Gets the defined default value for the column."}) */
  dynamic getDefaultValue() {
    dynamic result;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.defaultValue.value,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.defaultValue.value]
              ?.propertyValue;
    }
    return result;
  }

  /* AcDoc({"summary": "Gets a list of specified formats for the column's value."}) */
  List<String> getColumnFormats() {
    List<String> result = [];
    if (columnProperties.containsKey(AcEnumDDColumnProperty.format.value)) {
      if(columnProperties[AcEnumDDColumnProperty.format.value]?.propertyValue is String){
        result = [columnProperties[AcEnumDDColumnProperty.format.value]?.propertyValue];
      }
      else{
        result = columnProperties[AcEnumDDColumnProperty.format.value]?.propertyValue ?? [];
      }

    }
    return result;
  }

  /* AcDoc({"summary": "Gets the display title for the column, falling back to the column name."}) */
  String getColumnTitle() {
    String result = columnName;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.columnTitle.value,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.columnTitle.value]
              ?.propertyValue ??
          columnName;
    }
    return result;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to add the column to a table.",
    "returns": "An `ALTER TABLE...ADD COLUMN` SQL string.",
    "returns_type": "String"
  }) */
  String getAddColumnStatement({
    required tableName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    if (databaseType == AcEnumSqlDatabaseType.mysql) {
      return "ALTER TABLE $tableName ADD COLUMN ${getColumnDefinitionForStatement(databaseType:databaseType)}";
    }
    else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      return "ALTER TABLE $tableName ADD COLUMN ${getColumnDefinitionForStatement(databaseType:databaseType)}";
    }
    return "";
  }

  /* AcDoc({
    "summary": "Generates the full SQL definition for a column.",
    "description": "Constructs the column definition string (e.g., '`id` INT AUTO_INCREMENT PRIMARY KEY') based on the column's type and properties for a specific SQL dialect.",
    "params": [
      {"name": "databaseType", "description": "The target SQL dialect (e.g., MySQL, SQLite)."}
    ],
    "returns": "The SQL column definition string.",
    "returns_type": "String"
  }) */
  String getColumnDefinitionForStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    String result = "";
    var defaultValue = getDefaultValue();
    var size = getSize();
    bool isAutoIncrementSet = false;
    bool isPrimaryKeySet = false;
    String sqlType = "";
    if (databaseType == AcEnumSqlDatabaseType.mysql) {
      switch (columnType) {
        case AcEnumDDColumnType.autoIncrement:
          sqlType = 'INT AUTO_INCREMENT PRIMARY KEY';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.blob:
          sqlType = _blobType(size);
          break;
        case AcEnumDDColumnType.date:
          sqlType = 'DATE';
          break;
        case AcEnumDDColumnType.datetime:
          sqlType = 'DATETIME';
          break;
        case AcEnumDDColumnType.double_:
          sqlType = 'DOUBLE';
          break;
        case AcEnumDDColumnType.uuid:
          sqlType = 'CHAR(36)';
          break;
        case AcEnumDDColumnType.integer:
          sqlType = _intType(size);
          break;
        case AcEnumDDColumnType.json:
          sqlType = 'LONGTEXT';
          break;
        case AcEnumDDColumnType.string:
          if (size == 0) size = 255;
          sqlType = 'VARCHAR($size)';
          break;
        case AcEnumDDColumnType.text:
          sqlType = _textType(size);
          break;
        case AcEnumDDColumnType.time:
          sqlType = 'TIME';
          break;
        case AcEnumDDColumnType.timestamp:
          sqlType =
              'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP';
          break;
        default:
          sqlType = 'TEXT';
      }

      result = "`$columnName` $sqlType";
      if (isAutoIncrement() && !isAutoIncrementSet) {
        result += " AUTO_INCREMENT";
      }
      if (isPrimaryKey() && !isPrimaryKeySet) {
        result += " PRIMARY KEY";
      }
      if (isUniqueKey()) {
        result += " UNIQUE";
      }
      if (isNotNull()) {
        result += " NOT NULL";
      }
    } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      switch (columnType) {
        case AcEnumDDColumnType.autoIncrement:
          sqlType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.double_:
          sqlType = 'REAL';
          break;
        case AcEnumDDColumnType.blob:
          sqlType = 'BLOB';
          break;
        case AcEnumDDColumnType.integer:
        case AcEnumDDColumnType.yesNo:
        case AcEnumDDColumnType.autoIndex:
          sqlType = 'INTEGER';
          break;
        default:
          sqlType = 'TEXT';
      }

      result = "`$columnName` $sqlType";
      if (isAutoIncrement() && !isAutoIncrementSet) {
        result += " AUTOINCREMENT";
      }
      if (isPrimaryKey() && !isPrimaryKeySet) {
        result += " PRIMARY KEY";
      }
      if (isUniqueKey()) {
        result += " UNIQUE";
      }
      if (isNotNull()) {
        result += " NOT NULL";
      }
      // Default value logic can be added as needed.
    }

    return result;
  }

  String _blobType(int size) {
    if (size <= 255) return "TINYBLOB";
    if (size <= 65535) return "BLOB";
    if (size <= 16777215) return "MEDIUMBLOB";
    return "LONGBLOB";
  }

  String _textType(int size) {
    if (size <= 255) return "TINYTEXT";
    if (size <= 65535) return "TEXT";
    if (size <= 16777215) return "MEDIUMTEXT";
    return "LONGTEXT";
  }

  String _intType(int size) {
    if (size <= 255) return "TINYINT";
    if (size <= 65535) return "SMALLINT";
    if (size <= 16777215) return "MEDIUMINT";
    return "BIGINT";
  }

  /* AcDoc({"summary": "Gets all foreign key relationships where this column is the destination."}) */
  List<AcDDRelationship> getForeignKeyRelationships() {
    return AcDDRelationship.getInstances(
      destinationTable: table?.tableName ?? "",
      destinationColumn: columnName,
    );
  }

  /* AcDoc({"summary": "Gets the defined size for the column (e.g., character length)."}) */
  int getSize() {
    int result = 0;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.size.value)) {
      result =
          columnProperties[AcEnumDDColumnProperty.size.value]?.propertyValue ??
          0;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is an auto-incrementing integer."}) */
  bool isAutoIncrement() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.autoIncrement.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.autoIncrement.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    if (columnType == AcEnumDDColumnType.autoIncrement) {
      result = true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is a managed auto-number string type."}) */
  bool isAutoNumber() {
    return columnType == AcEnumDDColumnType.autoNumber;
  }

  /* AcDoc({"summary": "Checks if the column is a foreign key by looking for incoming relationships."}) */
  bool isForeignKey() {
    return getForeignKeyRelationships().isNotEmpty;
  }

  /* AcDoc({"summary": "Checks if the column should be included in default search queries."}) */
  bool isUseForRowLikeFilter() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.useForRowLikeFilter.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.useForRowLikeFilter.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is defined as NOT NULL."}) */
  bool isNotNull() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.notNull.value)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.notNull.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is a primary key."}) */
  bool isPrimaryKey() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.primaryKey.value)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.primaryKey.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is marked as required (often a business logic rule)."}) */
  bool isRequired() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.required.value)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.required.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column is intended for `SELECT DISTINCT` queries."}) */
  bool isSelectDistinct() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.isSelectDistinct.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.isSelectDistinct.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column value should be set to null before a delete operation."}) */
  bool isSetValuesNullBeforeDelete() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.setNullBeforeDelete.value,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.setNullBeforeDelete.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({"summary": "Checks if the column has a UNIQUE constraint."}) */
  bool isUniqueKey() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.uniqueKey.value)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.uniqueKey.value]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  /* AcDoc({
    "summary": "Populates the instance from a JSON map.",
    "description": "This method manually deserializes the nested `columnProperties` map before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the column's properties."}
    ],
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDTableColumn"
  }) */
  AcDDTableColumn fromJson({required Map<String, dynamic> jsonData}) {
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

  /* AcDoc({
    "summary": "Serializes the current column instance to a JSON map.",
    "returns": "A JSON map representation of the column.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the column.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
