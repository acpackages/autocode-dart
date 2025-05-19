import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcDDTable {
  static const String KEY_TABLE_COLUMNS = "table_columns";
  static const String KEY_TABLE_NAME = "table_name";
  static const String KEY_TABLE_PROPERTIES = "table_properties";

  @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_COLUMNS)
  List<AcDDTableColumn> tableColumns = [];

  @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_NAME)
  String tableName = "";

  @AcBindJsonProperty(key: AcDDTable.KEY_TABLE_PROPERTIES)
  List<AcDDTableProperty> tableProperties = [];

  static AcDDTable instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDTable();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  static String getDropTableStatement({required String tableName,String? databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    return "DROP TABLE IF EXISTS $tableName;";
  }

  static AcDDTable getInstance({
    required String tableName,
    String dataDictionaryName = "default",
  }) {
    final result = AcDDTable();
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );

    if (acDataDictionary.tables.containsKey(tableName)) {
      result.fromJson(jsonData: acDataDictionary.tables[tableName]);
    }

    return result;
  }

  AcDDTableColumn? getColumn(String columnName) {
    return tableColumns.firstWhere((column) => column.columnName == columnName);
  }

  List<String> getColumnNames() {
    return tableColumns.map((column) => column.columnName).toList();
  }

  String getCreateTableStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    List<String> columnDefinitions = [];
    for (final column in tableColumns) {
      final columnDefinition = column.getColumnDefinitionForStatement(databaseType: databaseType);
      if (columnDefinition != "") {
        columnDefinitions.add(columnDefinition);
      }
    }
    final result = "CREATE TABLE IF NOT EXISTS $tableName (${columnDefinitions.join(", ")});";
    return result;
  }

  String getPrimaryKeyColumnName() {
    final primaryKeyColumn = getPrimaryKeyColumn();
    return primaryKeyColumn != null ? primaryKeyColumn.columnName : '';
  }

  AcDDTableColumn? getPrimaryKeyColumn() {
    final primaryKeyColumns = getPrimaryKeyColumns();
    return primaryKeyColumns.isNotEmpty ? primaryKeyColumns[0] : null;
  }

  List<AcDDTableColumn> getPrimaryKeyColumns() {
    return tableColumns.where((column) => column.isPrimaryKey()).toList();
  }

  List<String> getSearchQueryColumnNames() {
    return getSearchQueryColumns().map((column) => column.columnName).toList();
  }

  List<AcDDTableColumn> getSearchQueryColumns() {
    return tableColumns.where((column) => column.isInSearchQuery()).toList();
  }

  List<AcDDTableColumn> getForeignKeyColumns() {
    return tableColumns.where((column) => column.isForeignKey()).toList();
  }

  String getPluralName() {
    String result = tableName;
    for (var property in tableProperties) {
      if (property.propertyName == AcEnumDDTableProperty.PLURAL_NAME) {
        result = property.propertyValue;
      }
    }
    return result;
  }

  String getSingularName() {
    String result = tableName;
    for (var property in tableProperties) {
      if (property.propertyName == AcEnumDDTableProperty.SINGULAR_NAME) {
        result = property.propertyValue;
      }
    }
    return result;
  }

  List<AcDDTableColumn> getSelectDistinctColumns() {
    return tableColumns.where((column) => column.isSelectDistinct()).toList();
  }

  AcDDTable fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (jsonData.containsKey(KEY_TABLE_COLUMNS) &&
        jsonData[KEY_TABLE_COLUMNS] is Map) {
      json[KEY_TABLE_COLUMNS].forEach((columnName, columnData) {
        final column = AcDDTableColumn.instanceFromJson(jsonData: columnData);
        column.table = this;
        tableColumns.add(column);
      });
      json.remove(KEY_TABLE_COLUMNS);
    }

    if (json.containsKey(KEY_TABLE_PROPERTIES) &&
        json[KEY_TABLE_PROPERTIES] is Map) {
      json[KEY_TABLE_PROPERTIES].forEach((propertyName, propertyData) {
        tableProperties.add(
          AcDDTableProperty.instanceFromJson(jsonData: propertyData),
        );
      });
      json.remove(KEY_TABLE_PROPERTIES);
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
