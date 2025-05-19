import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDTableColumn {
  static const String KEY_COLUMN_NAME = "column_name";
  static const String KEY_COLUMN_PROPERTIES = "column_properties";
  static const String KEY_COLUMN_TYPE = "column_type";
  static const String KEY_COLUMN_VALUE = "column_value";

  @AcBindJsonProperty(key: AcDDTableColumn.KEY_COLUMN_NAME)
  String columnName = "";

  @AcBindJsonProperty(key: AcDDTableColumn.KEY_COLUMN_PROPERTIES)
  Map<String, AcDDTableColumnProperty> columnProperties = {};

  @AcBindJsonProperty(key: AcDDTableColumn.KEY_COLUMN_TYPE)
  String columnType = "text";

  @AcBindJsonProperty(key: AcDDTableColumn.KEY_COLUMN_VALUE)
  dynamic columnValue;

  @AcBindJsonProperty(skipInFromJson: true,skipInToJson: true)
  AcDDTable? table;

  static AcDDTableColumn getInstance({required String tableName,required String columnName,String dataDictionaryName = "default"}) {
    return AcDataDictionary.getTableColumn(tableName:tableName,columnName: columnName,dataDictionaryName: dataDictionaryName)!;
  }

  static AcDDTableColumn instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDTableColumn();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  static String getDropColumnStatement({required String tableName,required String columnName,String? databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    return "ALTER TABLE $tableName DROP COLUMN $columnName;";
  }

  bool checkInAutoNumber() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.CHECK_IN_AUTO_NUMBER,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.CHECK_IN_AUTO_NUMBER]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool checkInModify() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.CHECK_IN_MODIFY)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.CHECK_IN_MODIFY]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool checkInSave() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.CHECK_IN_SAVE)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.CHECK_IN_SAVE]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  int getAutoNumberLength() {
    int result = 0;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.AUTO_NUMBER_LENGTH,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.AUTO_NUMBER_LENGTH]
              ?.propertyValue ??
          0;
    }
    return result;
  }

  String getAutoNumberPrefix() {
    String result = "";
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.AUTO_NUMBER_PREFIX,
    )) {
      result =
          columnProperties[AcEnumDDColumnProperty.AUTO_NUMBER_PREFIX]
              ?.propertyValue ??
          "";
    }
    return result;
  }

  int getAutoNumberPrefixLength() {
    return getAutoNumberPrefix().length;
  }

  dynamic getDefaultValue() {
    dynamic result;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.DEFAULT_VALUE)) {
      result =
          columnProperties[AcEnumDDColumnProperty.DEFAULT_VALUE]?.propertyValue;
    }
    return result;
  }

  List<String> getColumnFormats() {
    List<String> result = [];
    if (columnProperties.containsKey(AcEnumDDColumnProperty.FORMAT)) {
      result =
          columnProperties[AcEnumDDColumnProperty.FORMAT]?.propertyValue ?? [];
    }
    return result;
  }

  String getColumnTitle() {
    String result = columnName;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.COLUMN_TITLE)) {
      result =
          columnProperties[AcEnumDDColumnProperty.COLUMN_TITLE]
              ?.propertyValue ??
          columnName;
    }
    return result;
  }

  String getAddColumnStatement({required tableName,String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
      return "ALTER TABLE $tableName ADD COLUMN ${getColumnDefinitionForStatement()}";
    }
    return "";
  }

  String getColumnDefinitionForStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = "";
    var defaultValue = getDefaultValue();
    var size = getSize();
    bool isAutoIncrementSet = false;
    bool isPrimaryKeySet = false;

    if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
      switch (columnType) {
        case AcEnumDDColumnType.AUTO_INCREMENT:
          columnType = 'INT AUTO_INCREMENT PRIMARY KEY';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.BLOB:
          columnType = _blobType(size);
          break;
        case AcEnumDDColumnType.DATE:
          columnType = 'DATE';
          break;
        case AcEnumDDColumnType.DATETIME:
          columnType = 'DATETIME';
          break;
        case AcEnumDDColumnType.DOUBLE:
          columnType = 'DOUBLE';
          break;
        case AcEnumDDColumnType.UUID:
          columnType = 'CHAR(36)';
          break;
        case AcEnumDDColumnType.INTEGER:
          columnType = _intType(size);
          break;
        case AcEnumDDColumnType.JSON:
          columnType = 'LONGTEXT';
          break;
        case AcEnumDDColumnType.STRING:
          if (size == 0) size = 255;
          columnType = 'VARCHAR($size)';
          break;
        case AcEnumDDColumnType.TEXT:
          columnType = _textType(size);
          break;
        case AcEnumDDColumnType.TIME:
          columnType = 'TIME';
          break;
        case AcEnumDDColumnType.TIMESTAMP:
          columnType = 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP';
          break;
        default:
          columnType = 'TEXT';
      }

      result = "$columnName $columnType";
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
    } else if (databaseType == AcEnumSqlDatabaseType.SQLITE) {
      switch (columnType) {
        case AcEnumDDColumnType.AUTO_INCREMENT:
          columnType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.DOUBLE:
          columnType = 'REAL';
          break;
        case AcEnumDDColumnType.BLOB:
          columnType = 'BLOB';
          break;
        case AcEnumDDColumnType.INTEGER:
          columnType = 'INTEGER';
          break;
        default:
          columnType = 'TEXT';
      }

      result = "$columnName $columnType";
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

  List<AcDDRelationship> getForeignKeyRelationships() {
    return AcDDRelationship.getInstances(
      destinationTable: table?.tableName ?? "",
      destinationColumn: columnName,
    );
  }

  int getSize() {
    int result = 0;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.SIZE)) {
      result =
          columnProperties[AcEnumDDColumnProperty.SIZE]?.propertyValue ?? 0;
    }
    return result;
  }

  bool isAutoIncrement() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.AUTO_INCREMENT)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.AUTO_INCREMENT]
                  ?.propertyValue ??
              false) ==
          true;
    }
    if (columnType == AcEnumDDColumnType.AUTO_INCREMENT) {
      result = true;
    }
    return result;
  }

  bool isAutoNumber() {
    return columnType == AcEnumDDColumnType.AUTO_NUMBER;
  }

  bool isForeignKey() {
    return getForeignKeyRelationships().isNotEmpty;
  }

  bool isInSearchQuery() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.IN_SEARCH_QUERY)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.IN_SEARCH_QUERY]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isNotNull() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.NOT_NULL)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.NOT_NULL]?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isPrimaryKey() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.PRIMARY_KEY)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.PRIMARY_KEY]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isRequired() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.REQUIRED)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.REQUIRED]?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isSelectDistinct() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.IS_SELECT_DISTINCT,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.IS_SELECT_DISTINCT]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isSetValuesNullBeforeDelete() {
    bool result = false;
    if (columnProperties.containsKey(
      AcEnumDDColumnProperty.SET_NULL_BEFORE_DELETE,
    )) {
      result =
          (columnProperties[AcEnumDDColumnProperty.SET_NULL_BEFORE_DELETE]
                  ?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  bool isUniqueKey() {
    bool result = false;
    if (columnProperties.containsKey(AcEnumDDColumnProperty.UNIQUE_KEY)) {
      result =
          (columnProperties[AcEnumDDColumnProperty.UNIQUE_KEY]?.propertyValue ??
              false) ==
          true;
    }
    return result;
  }

  AcDDTableColumn fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_COLUMN_PROPERTIES) &&
        json[KEY_COLUMN_PROPERTIES] is Map) {
      jsonData[KEY_COLUMN_PROPERTIES].forEach((key, value) {
        columnProperties[key] = AcDDTableColumnProperty.instanceFromJson(
          jsonData: value,
        );
      });
      json.remove(KEY_COLUMN_PROPERTIES);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
