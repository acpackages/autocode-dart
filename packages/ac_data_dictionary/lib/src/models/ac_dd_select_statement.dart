import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "A builder for creating and executing SQL SELECT statements.",
  "description": "This class provides a programmatic and fluent interface to build complex SQL queries. It supports dynamic WHERE clauses with nested condition groups, column selection (inclusion/exclusion), ordering, and pagination, all based on data dictionary definitions.",
  "example": "final select = AcDDSelectStatement(tableName: 'users')\n  ..includeColumns = ['id', 'name', 'email']\n  ..startGroup(operator: AcEnumLogicalOperator.and)\n    ..addCondition(columnName: 'is_active', operator: AcEnumConditionOperator.equalTo, value: true)\n    ..startGroup(operator: AcEnumLogicalOperator.or)\n      ..addCondition(columnName: 'role', operator: AcEnumConditionOperator.equalTo, value: 'admin')\n      ..addCondition(columnName: 'role', operator: AcEnumConditionOperator.equalTo, value: 'support')\n    ..endGroup()\n  ..endGroup()\n  ..orderBy = 'name ASC'\n  ..pageSize = 50\n  ..pageNumber = 1;\n\nfinal sql = select.getSqlStatement();\n// Executes the query using the generated `sql` and `select.parameters`."
}) */
@AcReflectable()
class AcDDSelectStatement {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCondition = "condition";
  static const String keyConditionGroup = "condition_group";
  static const String keyDatabaseType = "database_type";
  static const String keyDataDictionaryName = "data_dictionary_name";
  static const String keyExcludeColumns = "exclude_columns";
  static const String keyIncludeColumns = "include_columns";
  static const String keyOrderBy = "order_by";
  static const String keyPageNumber = "page_number";
  static const String keyPageSize = "page_size";
  static const String keyParameters = "parameters";
  static const String keySelectStatement = "select_statement";
  static const String keySqlStatement = "sql_statement";
  static const String keyTableName = "table_name";

  // Internal state properties
  String condition = "";
  late AcDDConditionGroup conditionGroup;
  List<AcDDConditionGroup> groupStack = [];
  Map<String,dynamic> parameters = {};
  String selectStatement = "";
  String sqlStatement = "";

  /* AcDoc({"summary": "The target database type for SQL dialect generation."}) */
  @AcBindJsonProperty(key: keyDatabaseType)
  AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;

  /* AcDoc({"summary": "The name of the data dictionary to use for schema lookups."}) */
  @AcBindJsonProperty(key: keyDataDictionaryName)
  String dataDictionaryName = "";

  /* AcDoc({"summary": "A list of column names to exclude from the SELECT clause."}) */
  @AcBindJsonProperty(key: keyExcludeColumns)
  List<String> excludeColumns = [];

  /* AcDoc({"summary": "A list of column names to include in the SELECT clause."}) */
  @AcBindJsonProperty(key: keyIncludeColumns)
  List<String> includeColumns = [];

  /* AcDoc({"summary": "The ORDER BY clause for the query (e.g., 'name ASC, id DESC')."}) */
  @AcBindJsonProperty(key: keyOrderBy)
  String orderBy = "";

  /* AcDoc({"summary": "The page number for pagination (1-based)."}) */
  @AcBindJsonProperty(key: keyPageNumber)
  int pageNumber = 0;

  /* AcDoc({"summary": "The number of records per page for pagination."}) */
  @AcBindJsonProperty(key: keyPageSize)
  int pageSize = 0;

  /* AcDoc({"summary": "The primary table for the SELECT statement."}) */
  @AcBindJsonProperty(key: keyTableName)
  String tableName = "";

  /* AcDoc({
    "summary": "Creates a new select statement builder.",
    "params": [
      {"name": "tableName", "description": "The primary table to select from."},
      {"name": "dataDictionaryName", "description": "The data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcDDSelectStatement({this.tableName = "", this.dataDictionaryName = "default"}) {
    conditionGroup = AcDDConditionGroup();
    conditionGroup.operator = AcEnumLogicalOperator.and;
    groupStack.add(conditionGroup);
  }

  /* AcDoc({
    "summary": "A static helper to generate a simple SQL statement.",
    "description": "Assembles a basic SQL query from its constituent parts. Does not support parameterized queries.",
    "params": [
      {"name": "selectStatement", "description": "The full SELECT...FROM clause."},
      {"name": "condition", "description": "The full WHERE clause content."},
      {"name": "orderBy", "description": "The full ORDER BY clause content."},
      {"name": "pageNumber", "description": "The page number for a LIMIT clause."},
      {"name": "pageSize", "description": "The page size for a LIMIT clause."},
      {"name": "databaseType", "description": "The target database type (for future dialect-specific limits)."}
    ],
    "returns": "The assembled SQL string.",
    "returns_type": "String"
  }) */
  static String generateSqlStatement({
    String? selectStatement = "",
    String? condition = "",
    String? orderBy = "",
    int pageNumber = 0,
    int pageSize = 0,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    var sqlStatement = selectStatement ?? "";
    if (condition != null && condition.isNotEmpty) {
      sqlStatement += ' WHERE $condition';
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      sqlStatement += " ORDER BY $orderBy";
    }
    if (pageSize > 0 && pageNumber > 0) {
      sqlStatement += " LIMIT ${(pageNumber - 1) * pageSize},$pageSize";
    }
    return sqlStatement;
  }

  /* AcDoc({
    "summary": "Creates a new AcDDSelectStatement instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the select statement's properties."}
    ],
    "returns": "A new, populated AcDDSelectStatement instance.",
    "returns_type": "AcDDSelectStatement"
  }) */
  static AcDDSelectStatement instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcDDSelectStatement();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Adds a simple condition to the current condition group.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement addCondition({
    required String columnName,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    groupStack.last.addCondition(
      columnName: columnName,
      operator: operator,
      value: value,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Adds a pre-defined condition group to the current group.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement addConditionGroup({
    required List<dynamic> conditions,
    AcEnumLogicalOperator operator = AcEnumLogicalOperator.and,
  }) {
    groupStack.last.addConditionGroup(
      conditions: conditions,
      operator: operator,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Closes the current condition group.",
    "description": "Finalizes the current nested group and adds it to its parent group. This is used to create parenthesized `(...)` blocks in the WHERE clause.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement endGroup() {
    if (groupStack.length > 1) {
      groupStack[groupStack.length - 2].conditions.add(groupStack.removeLast());
    }
    return this;
  }

  /* AcDoc({
    "summary": "Populates the instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "A map containing the select statement's properties."}
    ]
  }) */
  void fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
  }

  /* AcDoc({
    "summary": "Generates the final SQL statement and parameters map.",
    "description": "Assembles the complete SQL query string and populates the `parameters` map based on the configured properties and conditions. This is the primary method for getting the final query.",
    "params": [
      {"name": "skipCondition", "description": "If true, the WHERE clause is not generated."},
      {"name": "skipSelectStatement", "description": "If true, the SELECT...FROM clause is not generated."},
      {"name": "skipLimit", "description": "If true, the LIMIT clause for pagination is not generated."}
    ],
    "returns": "The complete, generated SQL query string.",
    "returns_type": "String"
  }) */
  String getSqlStatement({
    bool skipCondition = false,
    bool skipSelectStatement = false,
    bool skipLimit = false
  }) {
    if (!skipSelectStatement) {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      List<String> columns = [];
      if (includeColumns.isEmpty && excludeColumns.isEmpty) {
        columns.add("*");
      } else if (includeColumns.isNotEmpty) {
        columns = includeColumns;
      } else if (acDDTable != null && excludeColumns.isNotEmpty) {
        for (var columnName in acDDTable.getColumnNames()) {
          if (!excludeColumns.contains(columnName)) {
            columns.add(columnName);
          }
        }
      }
      var columnsList = columns.join(",");
      selectStatement = "SELECT $columnsList FROM $tableName";
    }

    if (!skipCondition) {
      condition = "";
      parameters = {};
      setSqlConditionGroup(
        acDDConditionGroup: conditionGroup,
        includeParenthesis: false,
      );
    }

    sqlStatement = AcDDSelectStatement.generateSqlStatement(
      selectStatement: selectStatement,
      condition: condition,
      orderBy: orderBy,
      pageNumber: skipLimit ? 0 : pageNumber,
      pageSize: skipLimit ? 0 : pageSize,
      databaseType: databaseType,
    );
    return sqlStatement;
  }

  /* AcDoc({
    "summary": "Sets conditions from a map of filters.",
    "description": "A utility to build a condition group from a map that conforms to the `AcDDConditionGroup` JSON structure.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement setConditionsFromFilters({
    required Map<String, dynamic> filters,
  }) {
    // Assuming AcDDConditionGroup.keyConditions is also refactored
    if (filters.containsKey(AcDDConditionGroup.keyConditions)) {
      var operator = AcEnumLogicalOperator.and;
      if (filters.containsKey(AcDDConditionGroup.keyOperator)) {
        operator = filters[AcDDConditionGroup.keyOperator];
      }
      addConditionGroup(
        conditions: filters[AcDDConditionGroup.keyConditions],
        operator: operator,
      );
    }
    return this;
  }

  // Internal helper methods for building the WHERE clause.
  // Users should typically use the fluent `addCondition` and `start/endGroup` methods.

  AcDDSelectStatement setSqlCondition({required AcDDCondition acDDCondition}) {
    var parameterName = "";
    switch (acDDCondition.operator) {
      case AcEnumConditionOperator.between:
        if (acDDCondition.value is List && acDDCondition.value.length == 2) {
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[0];
          condition += "${acDDCondition.columnName} BETWEEN $parameterName";
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[1];
          condition += " AND $parameterName";
        }
        break;
      case AcEnumConditionOperator.contains:
        setSqlLikeStringCondition(acDDCondition:acDDCondition);
        break;
      case AcEnumConditionOperator.endsWith:
        setSqlLikeStringCondition(acDDCondition:acDDCondition,includeInBetween: false, includeStart: false);
        break;
      case AcEnumConditionOperator.equalTo:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} = $parameterName";
        break;
      case AcEnumConditionOperator.greaterThan:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} > $parameterName";
        break;
      case AcEnumConditionOperator.greaterThanEqualTo:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} >= $parameterName";
        break;
      case AcEnumConditionOperator.in_:
        parameterName = "@parameter${parameters.length}";
        if(acDDCondition.value is String){
          parameters[parameterName] = acDDCondition.value.toString().split(",");
        }
        else if(acDDCondition.value is List){
          parameters[parameterName] = acDDCondition.value;
        }
        condition += "${acDDCondition.columnName} IN ($parameterName)";
        break;
      case AcEnumConditionOperator.isEmpty:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} = ''";
        break;
      case AcEnumConditionOperator.isNotNull:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} IS NOT NULL";
        break;
      case AcEnumConditionOperator.isNull:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} IS NULL";
        break;
      case AcEnumConditionOperator.lessThan:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} < $parameterName";
        break;
      case AcEnumConditionOperator.lessThanEqualTo:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} <= $parameterName";
        break;
      case AcEnumConditionOperator.notEqualTo:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} != $parameterName";
        break;
      case AcEnumConditionOperator.notIn:
        parameterName = "@parameter${parameters.length}";
        if(acDDCondition.value is String){
          parameters[parameterName] = acDDCondition.value.toString().split(",");
        }
        else if(acDDCondition.value is List){
          parameters[parameterName] = acDDCondition.value;
        }
        condition += "${acDDCondition.columnName} NOT IN ($parameterName)";
        break;
      case AcEnumConditionOperator.startsWith:
        setSqlLikeStringCondition(acDDCondition:acDDCondition,includeInBetween: false, includeEnd: false);
        break;
      default:
        break;
    }
    return this;
  }

  AcDDSelectStatement setSqlConditionGroup({
    required AcDDConditionGroup acDDConditionGroup,
    bool includeParenthesis = true,
  }) {
    int index = -1;
    for (var acDDCondition in acDDConditionGroup.conditions) {
      index++;
      if (index > 0) {
        condition += " ${acDDConditionGroup.operator} ";
      }
      if (acDDCondition is AcDDConditionGroup) {
        if (includeParenthesis) {
          condition += "(";
        }
        setSqlConditionGroup(
          acDDConditionGroup: acDDCondition,
          includeParenthesis: includeParenthesis,
        );
        if (includeParenthesis) {
          condition += ")";
        }
      } else if (acDDCondition is AcDDCondition) {
        setSqlCondition(acDDCondition: acDDCondition);
      }
    }
    return this;
  }

  AcDDSelectStatement setSqlLikeStringCondition({required AcDDCondition acDDCondition,bool includeEnd = true,bool includeInBetween = true,bool includeStart = true}) {
    AcDDTableColumn acDDTableColumn = AcDataDictionary.getTableColumn(
      tableName: tableName,
      columnName: acDDCondition.columnName,
      dataDictionaryName: dataDictionaryName,
    )!;
    String columnCheck = 'LOWER(${acDDCondition.columnName})';
    String likeValue = acDDCondition.value.toLowerCase();
    String jsonColumn = "value";
    List<String> conditionParts = List.empty(growable: true);
    if (acDDTableColumn.columnType == AcEnumDDColumnType.json) {
      if(includeStart) {
        String parameter1 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter1");
        parameters[parameter1] = '%"$jsonColumn":"$likeValue%"%';
      }
      if(includeInBetween) {
        String parameter2 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter2");
        parameters[parameter2] = '%"$jsonColumn":"%$likeValue%"%';
      }
      if(includeEnd) {
        String parameter3 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter3");
        parameters[parameter3] = '%"$jsonColumn":"%$likeValue"%';
      }

    } else {
      if(includeStart) {
        String parameter1 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter1");
        parameters[parameter1] = '$likeValue%';
      }
      if(includeInBetween) {
        String parameter2 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter2");
        parameters[parameter2] = '%$likeValue%';
      }
      if(includeEnd) {
        String parameter3 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter3");
        parameters[parameter3] = '$likeValue%';
      }
    }
    if(conditionParts.isNotEmpty){
      condition += '(${conditionParts.join((" OR "))})';
    }
    return this;
  }

  /* AcDoc({
    "summary": "Starts a new nested condition group.",
    "description": "Pushes a new group onto the stack, allowing for the creation of a new parenthesized `(...)` block in the WHERE clause. Must be balanced with a call to `endGroup()`.",
    "params": [
      {"name": "operator", "description": "The logical operator (AND/OR) for this new group."}
    ],
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement startGroup({AcEnumLogicalOperator operator = AcEnumLogicalOperator.and}) {
    var group = AcDDConditionGroup();
    group.operator = operator;
    groupStack.add(group);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current select statement configuration to a JSON map.",
    "returns": "A JSON map representation of the statement builder's properties.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the object.",
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
// class AcDDSelectStatement {
//   static const String KEY_CONDITION = "condition";
//   static const String KEY_CONDITION_GROUP = "condition_group";
//   static const String KEY_DATABASE_TYPE = "database_type";
//   static const String KEY_DATA_DICTIONARY_NAME = "data_dictionary_name";
//   static const String KEY_EXCLUDE_COLUMNS = "exclude_columns";
//   static const String KEY_INCLUDE_COLUMNS = "include_columns";
//   static const String KEY_ORDER_BY = "order_by";
//   static const String KEY_PAGE_NUMBER = "page_number";
//   static const String KEY_PAGE_SIZE = "page_size";
//   static const String KEY_PARAMETERS = "parameters";
//   static const String KEY_SELECT_STATEMENT = "select_statement";
//   static const String KEY_SQL_STATEMENT = "sql_statement";
//   static const String KEY_TABLE_NAME = "table_name";
//
//   String condition = "";
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_CONDITION_GROUP)
//   late AcDDConditionGroup conditionGroup;
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_DATABASE_TYPE)
//   AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_DATA_DICTIONARY_NAME)
//   String dataDictionaryName = "";
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_EXCLUDE_COLUMNS)
//   List<String> excludeColumns = [];
//
//   List<AcDDConditionGroup> groupStack = [];
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_INCLUDE_COLUMNS)
//   List<String> includeColumns = [];
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_ORDER_BY)
//   String orderBy = "";
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_PAGE_NUMBER)
//   int pageNumber = 0;
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_PAGE_SIZE)
//   int pageSize = 0;
//
//   Map<String,dynamic> parameters = {};
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_SELECT_STATEMENT)
//   String selectStatement = "";
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_SQL_STATEMENT)
//   String sqlStatement = "";
//
//   @AcBindJsonProperty(key: AcDDSelectStatement.KEY_TABLE_NAME)
//   String tableName = "";
//
//   AcDDSelectStatement({this.tableName = "", this.dataDictionaryName = "default"}) {
//     conditionGroup = AcDDConditionGroup();
//     conditionGroup.operator = AcEnumLogicalOperator.and;
//     groupStack.add(conditionGroup);
//   }
//
//   static String generateSqlStatement({
//     String? selectStatement = "",
//     String? condition = "",
//     String? orderBy = "",
//     int pageNumber = 0,
//     int pageSize = 0,
//     AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
//   }) {
//     var sqlStatement = selectStatement ?? "";
//     if (condition != null && condition.isNotEmpty) {
//       sqlStatement += ' WHERE $condition';
//     }
//     if (orderBy != null && orderBy.isNotEmpty) {
//       sqlStatement += " ORDER BY $orderBy";
//     }
//     if (pageSize > 0 && pageNumber > 0) {
//       sqlStatement += " LIMIT ${(pageNumber - 1) * pageSize},$pageSize";
//     }
//     return sqlStatement;
//   }
//
//   static AcDDSelectStatement instanceFromJson({
//     required Map<String, dynamic> jsonData,
//   }) {
//     var instance = AcDDSelectStatement();
//     instance.fromJson(jsonData: jsonData);
//     return instance;
//   }
//
//   AcDDSelectStatement addCondition({
//     required String columnName,
//     required AcEnumConditionOperator operator,
//     required dynamic value,
//   }) {
//     groupStack.last.addCondition(
//       columnName: columnName,
//       operator: operator,
//       value: value,
//     );
//     return this;
//   }
//
//   AcDDSelectStatement addConditionGroup({
//     required List<dynamic> conditions,
//     AcEnumLogicalOperator operator = AcEnumLogicalOperator.and,
//   }) {
//     groupStack.last.addConditionGroup(
//       conditions: conditions,
//       operator: operator,
//     );
//     return this;
//   }
//
//   AcDDSelectStatement endGroup() {
//     if (groupStack.length > 1) {
//       groupStack[groupStack.length - 2].conditions.add(groupStack.removeLast());
//     }
//     return this;
//   }
//
//   void fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(
//       instance: this,
//       jsonData: jsonData,
//     );
//   }
//
//   String getSqlStatement({
//     bool skipCondition = false,
//     bool skipSelectStatement = false,
//     bool skipLimit = false
//   }) {
//     if (!skipSelectStatement) {
//       var acDDTable = AcDataDictionary.getTable(
//         tableName: tableName,
//         dataDictionaryName: dataDictionaryName,
//       );
//       List<String> columns = [];
//       if (includeColumns.isEmpty && excludeColumns.isEmpty) {
//         columns.add("*");
//       } else if (includeColumns.isNotEmpty) {
//         columns = includeColumns;
//       } else if (excludeColumns.isNotEmpty) {
//         for (var columnName in acDDTable!.getColumnNames()) {
//           if (!excludeColumns.contains(columnName)) {
//             columns.add(columnName);
//           }
//         }
//       }
//       var columnsList = columns.join(",");
//       selectStatement = "SELECT $columnsList FROM $tableName";
//     }
//
//     if (!skipCondition) {
//       condition = "";
//       parameters = {};
//       setSqlConditionGroup(
//         acDDConditionGroup: conditionGroup,
//         includeParenthesis: false,
//       );
//     }
//
//     if(skipLimit){
//       sqlStatement = AcDDSelectStatement.generateSqlStatement(
//         selectStatement: selectStatement,
//         condition: condition,
//         orderBy: orderBy,
//         databaseType: databaseType,
//       );
//     }
//     else{
//       sqlStatement = AcDDSelectStatement.generateSqlStatement(
//         selectStatement: selectStatement,
//         condition: condition,
//         orderBy: orderBy,
//         pageNumber: pageNumber,
//         pageSize: pageSize,
//         databaseType: databaseType,
//       );
//     }
//     return sqlStatement;
//   }
//
//   AcDDSelectStatement setConditionsFromFilters({
//     required Map<String, dynamic> filters,
//   }) {
//     if (filters.containsKey(AcDDConditionGroup.KEY_CONDITIONS)) {
//       var operator = AcEnumLogicalOperator.and;
//       if (filters.containsKey(AcDDConditionGroup.KEY_OPERATOR)) {
//         operator = filters[AcDDConditionGroup.KEY_OPERATOR];
//       }
//       addConditionGroup(
//         conditions: filters[AcDDConditionGroup.KEY_CONDITIONS],
//         operator: operator,
//       );
//     }
//     return this;
//   }
//
//   AcDDSelectStatement setSqlCondition({required AcDDCondition acDDCondition}) {
//     var parameterName = "";
//     switch (acDDCondition.operator) {
//       case AcEnumConditionOperator.between:
//         if (acDDCondition.value is List && acDDCondition.value.length == 2) {
//           parameterName = "@parameter${parameters.length}";
//           parameters[parameterName] = acDDCondition.value[0];
//           condition += "${acDDCondition.columnName} BETWEEN $parameterName";
//           parameterName = "@parameter${parameters.length}";
//           parameters[parameterName] = acDDCondition.value[1];
//           condition += " AND $parameterName";
//         }
//         break;
//       case AcEnumConditionOperator.contains:
//         setSqlLikeStringCondition(acDDCondition:acDDCondition);
//         break;
//       case AcEnumConditionOperator.endsWith:
//         setSqlLikeStringCondition(acDDCondition:acDDCondition,includeInBetween: false, includeStart: false);
//         break;
//       case AcEnumConditionOperator.equalTo:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} = $parameterName";
//         break;
//       case AcEnumConditionOperator.greaterThan:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} > $parameterName";
//         break;
//       case AcEnumConditionOperator.greaterThanEqualTo:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} >= $parameterName";
//         break;
//       case AcEnumConditionOperator.in_:
//         parameterName = "@parameter${parameters.length}";
//         if(acDDCondition.value is String){
//           parameters[parameterName] = acDDCondition.value.toString().split(",");
//         }
//         else if(acDDCondition.value is List){
//           parameters[parameterName] = acDDCondition.value;
//         }
//         condition += "${acDDCondition.columnName} IN ($parameterName)";
//         break;
//       case AcEnumConditionOperator.isEmpty:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} = ''";
//         break;
//       case AcEnumConditionOperator.isNotNull:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} IS NOT NULL";
//         break;
//       case AcEnumConditionOperator.isNull:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} IS NULL";
//         break;
//       case AcEnumConditionOperator.lessThan:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} < $parameterName";
//         break;
//       case AcEnumConditionOperator.lessThanEqualTo:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} <= $parameterName";
//         break;
//       case AcEnumConditionOperator.notEqualTo:
//         parameterName = "@parameter${parameters.length}";
//         parameters[parameterName] = acDDCondition.value;
//         condition += "${acDDCondition.columnName} != $parameterName";
//         break;
//       case AcEnumConditionOperator.notIn:
//         parameterName = "@parameter${parameters.length}";
//         if(acDDCondition.value is String){
//           parameters[parameterName] = acDDCondition.value.toString().split(",");
//         }
//         else if(acDDCondition.value is List){
//           parameters[parameterName] = acDDCondition.value;
//         }
//         condition += "${acDDCondition.columnName} NOT IN ($parameterName)";
//         break;
//       case AcEnumConditionOperator.startsWith:
//         setSqlLikeStringCondition(acDDCondition:acDDCondition,includeInBetween: false, includeEnd: false);
//         break;
//       default:
//         break;
//     }
//     return this;
//   }
//
//   AcDDSelectStatement setSqlConditionGroup({
//     required AcDDConditionGroup acDDConditionGroup,
//     bool includeParenthesis = true,
//   }) {
//     int index = -1;
//     for (var acDDCondition in acDDConditionGroup.conditions) {
//       index++;
//       if (index > 0) {
//         condition += " ${acDDConditionGroup.operator} ";
//       }
//       if (acDDCondition is AcDDConditionGroup) {
//         if (includeParenthesis) {
//           condition += "(";
//         }
//         setSqlConditionGroup(
//           acDDConditionGroup: acDDCondition,
//           includeParenthesis: includeParenthesis,
//         );
//         if (includeParenthesis) {
//           condition += ")";
//         }
//       } else if (acDDCondition is AcDDCondition) {
//         setSqlCondition(acDDCondition: acDDCondition);
//       }
//     }
//     return this;
//   }
//
//   AcDDSelectStatement setSqlLikeStringCondition({required AcDDCondition acDDCondition,bool includeEnd = true,bool includeInBetween = true,bool includeStart = true}) {
//     AcDDTableColumn acDDTableColumn = AcDataDictionary.getTableColumn(
//       tableName: tableName,
//       columnName: acDDCondition.columnName,
//       dataDictionaryName: dataDictionaryName,
//     )!;
//
//     String columnCheck = 'LOWER(${acDDCondition.columnName})';
//     String likeValue = acDDCondition.value.toLowerCase();
//     String jsonColumn = "value";
//     List<String> conditionParts = List.empty(growable: true);
//     if (acDDTableColumn.columnType == AcEnumDDColumnType.json) {
//       if(includeStart) {
//         String parameter1 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter1");
//         parameters[parameter1] = '%"$jsonColumn":"$likeValue%"%';
//       }
//       if(includeInBetween) {
//         String parameter2 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter2");
//         parameters[parameter2] = '%"$jsonColumn":"%$likeValue%"%';
//       }
//       if(includeEnd) {
//         String parameter3 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter3");
//         parameters[parameter3] = '%"$jsonColumn":"%$likeValue"%';
//       }
//
//     } else {
//       if(includeStart) {
//         String parameter1 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter1");
//         parameters[parameter1] = '$likeValue%';
//       }
//       if(includeInBetween) {
//         String parameter2 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter2");
//         parameters[parameter2] = '%$likeValue%';
//       }
//       if(includeEnd) {
//         String parameter3 = "@parameter${parameters.length}";
//         conditionParts.add("$columnCheck LIKE $parameter3");
//         parameters[parameter3] = '$likeValue%';
//       }
//     }
//     if(conditionParts.isNotEmpty){
//       condition += '(${conditionParts.join((" OR "))})';
//     }
//     return this;
//   }
//
//
//   AcDDSelectStatement startGroup({AcEnumLogicalOperator operator = AcEnumLogicalOperator.and}) {
//     var group = AcDDConditionGroup();
//     group.operator = operator;
//     groupStack.add(group);
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
