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
  static const String keyConditionGroup = "conditionGroup";
  static const String keyDatabaseType = "databaseType";
  static const String keyDataDictionaryName = "dataDictionaryName";
  static const String keyExcludeColumns = "excludeColumns";
  static const String keyIncludeColumns = "includeColumns";
  static const String keyOrderBy = "orderBy";
  static const String keyPageNumber = "pageNumber";
  static const String keyPageSize = "pageSize";
  static const String keyParameters = "parameters";
  static const String keySelectStatement = "selectStatement";
  static const String keySqlStatement = "sqlStatement";
  static const String keyTableName = "tableName";

  // Internal state properties
  String condition = "";
  late AcDDConditionGroup conditionGroup;
  List<AcDDConditionGroup> groupStack = [];
  Map<String, dynamic> parameters = {};
  String selectStatement = "";
  String sqlStatement = "";
  AcLogger logger = AcLogger(logMessages: false);

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
  AcDDSelectStatement({
    this.tableName = "",
    this.dataDictionaryName = "default",
    AcLogger? logger
  }) {
    if(logger!=null){
      this.logger = logger;
      this.logger.log('Custom logger provided and set');
    }
    conditionGroup = AcDDConditionGroup();
    conditionGroup.operator = AcEnumLogicalOperator.and;
    this.logger.log('Initialized conditionGroup with operator: ${conditionGroup.operator}');
    groupStack.add(conditionGroup);
    this.logger.log('Added initial conditionGroup to groupStack. Stack size: ${groupStack.length}');
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
    // Note: Static method, no instance logger available. Consider adding a static logger if needed.
    String sqlStatement = selectStatement ?? "";
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
    required String key,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    logger.log('addCondition called: key=$key, operator=$operator, value=$value');
    logger.log('Current groupStack size before add: ${groupStack.length}');
    groupStack.last.addCondition(
      key: key,
      operator: operator,
      value: value,
    );
    logger.log('Condition added to last group in stack');
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
    logger.log('addConditionGroup called: conditions count=${conditions.length}, operator=$operator');
    logger.log('Current groupStack size before add: ${groupStack.length}');
    groupStack.last.addConditionGroup(
      conditions: conditions,
      operator: operator,
    );
    logger.log('Condition group added to last group in stack');
    return this;
  }

  /* AcDoc({
    "summary": "Closes the current condition group.",
    "description": "Finalizes the current nested group and adds it to its parent group. This is used to create parenthesized `(...)` blocks in the WHERE clause.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDDSelectStatement"
  }) */
  AcDDSelectStatement endGroup() {
    logger.log('endGroup called. Current groupStack size: ${groupStack.length}');
    if (groupStack.length > 1) {
      logger.log('Popping last group and adding to parent (index ${groupStack.length - 2})');
      groupStack[groupStack.length - 2].conditions.add(groupStack.removeLast());
      logger.log('Group ended and added to parent. New stack size: ${groupStack.length}');
    } else {
      logger.log('endGroup ignored: stack has only 1 group');
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
    logger.log('fromJson called with keys: ${jsonData.keys.toList()}');
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    logger.log('Properties set from JSON data');
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
    bool skipLimit = false,
  }) {
    logger.log('getSqlStatement called: skipCondition=$skipCondition, skipSelectStatement=$skipSelectStatement, skipLimit=$skipLimit');
    logger.log('Current tableName: $tableName, includeColumns: $includeColumns, excludeColumns: $excludeColumns');

    if (!skipSelectStatement) {
      logger.log('Generating SELECT...FROM clause');
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      List<String> columns = [];
      if (includeColumns.isEmpty && excludeColumns.isEmpty) {
        logger.log('No column filters: selecting all (*)');
        columns.add("*");
      } else if (includeColumns.isNotEmpty) {
        logger.log('Including specific columns: $includeColumns');
        columns = includeColumns;
      } else if (acDDTable != null && excludeColumns.isNotEmpty) {
        logger.log('Excluding columns: $excludeColumns from table with columns: ${acDDTable.getColumnNames()}');
        for (var columnName in acDDTable.getColumnNames()) {
          if (!excludeColumns.contains(columnName)) {
            columns.add(columnName);
          }
        }
      }
      var columnsList = columns.join(",");
      selectStatement = "SELECT $columnsList FROM $tableName";
      logger.log('SELECT statement generated: $selectStatement');
    }

    if (!skipCondition) {
      logger.log('Generating WHERE clause and parameters');
      condition = "";
      parameters = {};
      logger.log('Reset condition and parameters');
      setSqlConditionGroup(
        acDDConditionGroup: conditionGroup,
        includeParenthesis: false,
      );
      logger.log('Condition built: $condition');
      logger.log('Parameters count: ${parameters.length}');
    }

    logger.log('Assembling final SQL with orderBy: $orderBy, pageNumber: $pageNumber, pageSize: $pageSize');
    sqlStatement = AcDDSelectStatement.generateSqlStatement(
      selectStatement: selectStatement,
      condition: condition,
      orderBy: orderBy,
      pageNumber: skipLimit ? 0 : pageNumber,
      pageSize: skipLimit ? 0 : pageSize,
      databaseType: databaseType,
    );
    logger.log('Final SQL statement: $sqlStatement');
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
    logger.log('setConditionsFromFilters called with filters keys: ${filters.keys.toList()}');
    // Assuming AcDDConditionGroup.keyConditions is also refactored
    if (filters.containsKey(AcDDConditionGroup.keyConditions)) {
      var operator = AcEnumLogicalOperator.and;
      if (filters.containsKey(AcDDConditionGroup.keyOperator)) {
        operator = AcEnumLogicalOperator.fromValue(filters[AcDDConditionGroup.keyOperator])!;
        logger.log('Operator from filters: $operator');
      }
      logger.log('Adding condition group from filters with operator: $operator');
      addConditionGroup(
        conditions: filters[AcDDConditionGroup.keyConditions],
        operator: operator,
      );
    } else {
      logger.log('No conditions key found in filters');
    }
    return this;
  }

  // Internal helper methods for building the WHERE clause.
  // Users should typically use the fluent `addCondition` and `start/endGroup` methods.

  AcDDSelectStatement setSqlCondition({required AcDDCondition acDDCondition}) {
    logger.log('setSqlCondition called for key: ${acDDCondition.key}, operator: ${acDDCondition.operator}, value: ${acDDCondition.value}');
    var parameterName = "";
    switch (acDDCondition.operator) {
      case AcEnumConditionOperator.between:
        logger.log('Handling BETWEEN operator');
        if (acDDCondition.value is List && acDDCondition.value.length == 2) {
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[0];
          condition += "${acDDCondition.key} BETWEEN $parameterName";
          logger.log('Added BETWEEN start param: $parameterName = ${acDDCondition.value[0]}');
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[1];
          condition += " AND $parameterName";
          logger.log('Added BETWEEN end param: $parameterName = ${acDDCondition.value[1]}');
        } else {
          logger.log('Invalid BETWEEN value: not a list of 2 elements');
        }
        break;
      case AcEnumConditionOperator.contains:
        logger.log('Handling CONTAINS operator');
        setSqlLikeStringCondition(acDDCondition: acDDCondition);
        break;
      case AcEnumConditionOperator.endsWith:
        logger.log('Handling ENDS_WITH operator');
        setSqlLikeStringCondition(
          acDDCondition: acDDCondition,
          includeInBetween: false,
          includeStart: false,
        );
        break;
      case AcEnumConditionOperator.equalTo:
        logger.log('Handling EQUAL_TO operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} = $parameterName";
        logger.log('Added EQUAL_TO param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.greaterThan:
        logger.log('Handling GREATER_THAN operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} > $parameterName";
        logger.log('Added GREATER_THAN param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.greaterThanEqualTo:
        logger.log('Handling GREATER_THAN_EQUAL_TO operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} >= $parameterName";
        logger.log('Added GREATER_THAN_EQUAL_TO param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.in_:
        logger.log('Handling IN operator');
        parameterName = "@parameter${parameters.length}";
        if (acDDCondition.value is String) {
          parameters[parameterName] = acDDCondition.value.toString().split(",");
          logger.log('Parsed string value to list for IN');
        } else if (acDDCondition.value is List) {
          parameters[parameterName] = acDDCondition.value;
        }
        condition += "${acDDCondition.key} IN ($parameterName)";
        logger.log('Added IN param: $parameterName = ${parameters[parameterName]}');
        break;
      case AcEnumConditionOperator.isEmpty:
        logger.log('Handling IS_EMPTY operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} = ''";
        logger.log('Added IS_EMPTY condition');
        break;
      case AcEnumConditionOperator.isNotNull:
        logger.log('Handling IS_NOT_NULL operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} IS NOT NULL";
        logger.log('Added IS_NOT_NULL condition');
        break;
      case AcEnumConditionOperator.isNull:
        logger.log('Handling IS_NULL operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} IS NULL";
        logger.log('Added IS_NULL condition');
        break;
      case AcEnumConditionOperator.lessThan:
        logger.log('Handling LESS_THAN operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} < $parameterName";
        logger.log('Added LESS_THAN param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.lessThanEqualTo:
        logger.log('Handling LESS_THAN_EQUAL_TO operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} <= $parameterName";
        logger.log('Added LESS_THAN_EQUAL_TO param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.notEqualTo:
        logger.log('Handling NOT_EQUAL_TO operator');
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.key} != $parameterName";
        logger.log('Added NOT_EQUAL_TO param: $parameterName = ${acDDCondition.value}');
        break;
      case AcEnumConditionOperator.notIn:
        logger.log('Handling NOT_IN operator');
        parameterName = "@parameter${parameters.length}";
        if (acDDCondition.value is String) {
          parameters[parameterName] = acDDCondition.value.toString().split(",");
          logger.log('Parsed string value to list for NOT_IN');
        } else if (acDDCondition.value is List) {
          parameters[parameterName] = acDDCondition.value;
        }
        condition += "${acDDCondition.key} NOT IN ($parameterName)";
        logger.log('Added NOT_IN param: $parameterName = ${parameters[parameterName]}');
        break;
      case AcEnumConditionOperator.startsWith:
        logger.log('Handling STARTS_WITH operator');
        setSqlLikeStringCondition(
          acDDCondition: acDDCondition,
          includeInBetween: false,
          includeEnd: false,
        );
        break;
      default:
        logger.log('Unknown operator: ${acDDCondition.operator}, skipping condition');
        break;
    }
    logger.log('setSqlCondition completed. Current condition snippet: $condition...');
    return this;
  }

  AcDDSelectStatement setSqlConditionGroup({
    required AcDDConditionGroup acDDConditionGroup,
    bool includeParenthesis = true,
  }) {
    logger.log('setSqlConditionGroup called: operator=${acDDConditionGroup.operator}, conditions count=${acDDConditionGroup.conditions.length}, includeParenthesis=$includeParenthesis');
    int index = -1;
    for (var acDDCondition in acDDConditionGroup.conditions) {
      index++;
      if (index > 0) {
        condition += " ${acDDConditionGroup.operator} ";
        logger.log('Added operator ${acDDConditionGroup.operator} before condition $index');
      }
      if (acDDCondition is AcDDConditionGroup) {
        logger.log('Processing nested group at index $index');
        if (includeParenthesis) {
          condition += "(";
          logger.log('Added opening parenthesis');
        }
        setSqlConditionGroup(
          acDDConditionGroup: acDDCondition,
          includeParenthesis: includeParenthesis,
        );
        if (includeParenthesis) {
          condition += ")";
          logger.log('Added closing parenthesis');
        }
      } else if (acDDCondition is AcDDCondition) {
        logger.log('Processing condition at index $index');
        setSqlCondition(acDDCondition: acDDCondition);
      }
    }
    logger.log('setSqlConditionGroup completed for group with ${acDDConditionGroup.conditions.length} conditions');
    return this;
  }

  AcDDSelectStatement setSqlLikeStringCondition({
    required AcDDCondition acDDCondition,
    bool includeEnd = true,
    bool includeInBetween = true,
    bool includeStart = true,
  }) {
    logger.log('setSqlLikeStringCondition called: key=${acDDCondition.key}, value=${acDDCondition.value}, includeStart=$includeStart, includeInBetween=$includeInBetween, includeEnd=$includeEnd');
    AcDDTableColumn acDDTableColumn =
    AcDataDictionary.getTableColumn(
      tableName: tableName,
      columnName: acDDCondition.key,
      dataDictionaryName: dataDictionaryName,
    )!;
    logger.log('Retrieved column type: ${acDDTableColumn.columnType}');
    String columnCheck = 'LOWER(${acDDCondition.key})';
    String likeValue = acDDCondition.value.toLowerCase();
    String jsonColumn = "value";
    List<String> conditionParts = List.empty(growable: true);
    if (acDDTableColumn.columnType == AcEnumDDColumnType.json) {
      logger.log('Handling JSON column LIKE conditions');
      if (includeStart) {
        String parameter1 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter1");
        parameters[parameter1] = '%"$jsonColumn":"$likeValue%"%';
        logger.log('Added JSON START LIKE param: $parameter1');
      }
      if (includeInBetween) {
        String parameter2 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter2");
        parameters[parameter2] = '%"$jsonColumn":"%$likeValue%"%';
        logger.log('Added JSON IN_BETWEEN LIKE param: $parameter2');
      }
      if (includeEnd) {
        String parameter3 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter3");
        parameters[parameter3] = '%"$jsonColumn":"%$likeValue"%';
        logger.log('Added JSON END LIKE param: $parameter3');
      }
    } else {
      logger.log('Handling non-JSON column LIKE conditions');
      if (includeStart) {
        String parameter1 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter1");
        parameters[parameter1] = '$likeValue%';
        logger.log('Added START LIKE param: $parameter1');
      }
      if (includeInBetween) {
        String parameter2 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter2");
        parameters[parameter2] = '%$likeValue%';
        logger.log('Added IN_BETWEEN LIKE param: $parameter2');
      }
      if (includeEnd) {
        String parameter3 = "@parameter${parameters.length}";
        conditionParts.add("$columnCheck LIKE $parameter3");
        parameters[parameter3] = '$likeValue%';
        logger.log('Added END LIKE param: $parameter3');
      }
    }
    if (conditionParts.isNotEmpty) {
      condition += '(${conditionParts.join((" OR "))})';
      logger.log('Added LIKE condition parts: ${conditionParts.join(" OR ")}');
    } else {
      logger.log('No LIKE condition parts added');
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
  AcDDSelectStatement startGroup({
    AcEnumLogicalOperator operator = AcEnumLogicalOperator.and,
  }) {
    logger.log('startGroup called with operator: $operator');
    logger.log('Current groupStack size before push: ${groupStack.length}');
    var group = AcDDConditionGroup();
    group.operator = operator;
    groupStack.add(group);
    logger.log('New group pushed to stack with operator: $operator. New stack size: ${groupStack.length}');
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current select statement configuration to a JSON map.",
    "returns": "A JSON map representation of the statement builder's properties.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    logger.log('toJson called');
    var json = AcJsonUtils.getJsonDataFromInstance(instance: this);
    logger.log('JSON serialization completed with keys: ${json.keys.toList()}');
    return json;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the object.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    logger.log('toString called');
    var jsonString = AcJsonUtils.prettyEncode(toJson());
    logger.log('toString completed');
    return jsonString;
  }
}