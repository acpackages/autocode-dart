import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
@AcReflectable()
class AcDDSelectStatement {
  static const String KEY_CONDITION = "condition";
  static const String KEY_CONDITION_GROUP = "condition_group";
  static const String KEY_DATABASE_TYPE = "database_type";
  static const String KEY_DATA_DICTIONARY_NAME = "data_dictionary_name";
  static const String KEY_EXCLUDE_COLUMNS = "exclude_columns";
  static const String KEY_INCLUDE_COLUMNS = "include_columns";
  static const String KEY_ORDER_BY = "order_by";
  static const String KEY_PAGE_NUMBER = "page_number";
  static const String KEY_PAGE_SIZE = "page_size";
  static const String KEY_PARAMETERS = "parameters";
  static const String KEY_SELECT_STATEMENT = "select_statement";
  static const String KEY_SQL_STATEMENT = "sql_statement";
  static const String KEY_TABLE_NAME = "table_name";

  String condition = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_CONDITION_GROUP)
  late AcDDConditionGroup conditionGroup;

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_DATABASE_TYPE)
  String databaseType = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_DATA_DICTIONARY_NAME)
  String dataDictionaryName = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_EXCLUDE_COLUMNS)
  List<String> excludeColumns = [];

  List<AcDDConditionGroup> groupStack = [];

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_INCLUDE_COLUMNS)
  List<String> includeColumns = [];

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_ORDER_BY)
  String orderBy = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_PAGE_NUMBER)
  int pageNumber = 0;

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_PAGE_SIZE)
  int pageSize = 0;

  Map<String,dynamic> parameters = {};

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_SELECT_STATEMENT)
  String selectStatement = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_SQL_STATEMENT)
  String sqlStatement = "";

  @AcBindJsonProperty(key: AcDDSelectStatement.KEY_TABLE_NAME)
  String tableName = "";

  AcDDSelectStatement({this.tableName = "", this.dataDictionaryName = "default"}) {
    conditionGroup = AcDDConditionGroup();
    conditionGroup.operator = AcEnumDDLogicalOperator.AND;
    groupStack.add(conditionGroup);
  }

  static String generateSqlStatement({
    String? selectStatement = "",
    String? condition = "",
    String? orderBy = "",
    int pageNumber = 0,
    int pageSize = 0,
    String databaseType = AcEnumSqlDatabaseType.UNKNOWN,
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

  static AcDDSelectStatement instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcDDSelectStatement();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcDDSelectStatement addCondition({
    required String columnName,
    required String operator,
    required dynamic value,
  }) {
    groupStack.last.addCondition(
      columnName: columnName,
      operator: operator,
      value: value,
    );
    return this;
  }

  AcDDSelectStatement addConditionGroup({
    required List<dynamic> conditions,
    String operator = AcEnumDDLogicalOperator.AND,
  }) {
    groupStack.last.addConditionGroup(
      conditions: conditions,
      operator: operator,
    );
    return this;
  }

  AcDDSelectStatement endGroup() {
    if (groupStack.length > 1) {
      groupStack[groupStack.length - 2].conditions.add(groupStack.removeLast());
    }
    return this;
  }

  void fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
  }

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
      } else if (excludeColumns.isNotEmpty) {
        for (var columnName in acDDTable!.getColumnNames()) {
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

    if(skipLimit){
      sqlStatement = AcDDSelectStatement.generateSqlStatement(
        selectStatement: selectStatement,
        condition: condition,
        orderBy: orderBy,
        databaseType: databaseType,
      );
    }
    else{
      sqlStatement = AcDDSelectStatement.generateSqlStatement(
        selectStatement: selectStatement,
        condition: condition,
        orderBy: orderBy,
        pageNumber: pageNumber,
        pageSize: pageSize,
        databaseType: databaseType,
      );
    }
    return sqlStatement;
  }

  AcDDSelectStatement setConditionsFromFilters({
    required Map<String, dynamic> filters,
  }) {
    if (filters.containsKey(AcDDConditionGroup.KEY_CONDITIONS)) {
      var operator = AcEnumDDLogicalOperator.AND;
      if (filters.containsKey(AcDDConditionGroup.KEY_OPERATOR)) {
        operator = filters[AcDDConditionGroup.KEY_OPERATOR];
      }
      addConditionGroup(
        conditions: filters[AcDDConditionGroup.KEY_CONDITIONS],
        operator: operator,
      );
    }
    return this;
  }

  AcDDSelectStatement setSqlCondition({required AcDDCondition acDDCondition}) {
    var parameterName = "";
    switch (acDDCondition.operator) {
      case AcEnumDDConditionOperator.BETWEEN:
        if (acDDCondition.value is List && acDDCondition.value.length == 2) {
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[0];
          condition += "${acDDCondition.columnName} BETWEEN $parameterName";
          parameterName = "@parameter${parameters.length}";
          parameters[parameterName] = acDDCondition.value[1];
          condition += " AND $parameterName";
        }
        break;
      case AcEnumDDConditionOperator.CONTAINS:
        setSqlLikeStringCondition(acDDCondition:acDDCondition);
        break;
      case AcEnumDDConditionOperator.ENDS_WITH:
        setSqlLikeStringCondition(acDDCondition:acDDCondition,includeInBetween: false, includeStart: false);
        break;
      case AcEnumDDConditionOperator.EQUAL_TO:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} = $parameterName";
        break;
      case AcEnumDDConditionOperator.GREATER_THAN:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} > $parameterName";
        break;
      case AcEnumDDConditionOperator.GREATER_THAN_EQUAL_TO:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} >= $parameterName";
        break;
      case AcEnumDDConditionOperator.IN:
        parameterName = "@parameter${parameters.length}";
        if(acDDCondition.value is String){
          parameters[parameterName] = acDDCondition.value.toString().split(",");
        }
        else if(acDDCondition.value is List){
          parameters[parameterName] = acDDCondition.value;
        }        
        condition += "${acDDCondition.columnName} IN ($parameterName)";
        break;
      case AcEnumDDConditionOperator.IS_EMPTY:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} = ''";
        break;
      case AcEnumDDConditionOperator.IS_NOT_NULL:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} IS NOT NULL";
        break;
      case AcEnumDDConditionOperator.IS_NULL:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} IS NULL";
        break;
      case AcEnumDDConditionOperator.LESS_THAN:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} < $parameterName";
        break;
      case AcEnumDDConditionOperator.LESS_THAN_EQUAL_TO:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} <= $parameterName";
        break;
      case AcEnumDDConditionOperator.NOT_EQUAL_TO:
        parameterName = "@parameter${parameters.length}";
        parameters[parameterName] = acDDCondition.value;
        condition += "${acDDCondition.columnName} != $parameterName";
        break;
      case AcEnumDDConditionOperator.NOT_IN:
        parameterName = "@parameter${parameters.length}";
        if(acDDCondition.value is String){
          parameters[parameterName] = acDDCondition.value.toString().split(",");
        }
        else if(acDDCondition.value is List){
          parameters[parameterName] = acDDCondition.value;
        }
        condition += "${acDDCondition.columnName} NOT IN ($parameterName)";
        break;
      case AcEnumDDConditionOperator.STARTS_WITH:
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
    if (acDDTableColumn.columnType == AcEnumDDColumnType.JSON) {
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


  AcDDSelectStatement startGroup({String operator = 'AND'}) {
    var group = AcDDConditionGroup();
    group.operator = operator;
    groupStack.add(group);
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
