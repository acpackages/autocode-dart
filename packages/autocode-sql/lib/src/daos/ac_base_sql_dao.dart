import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcBaseSqlDao {
  late AcLogger logger;
  late AcSqlConnection sqlConnection;

  AcBaseSqlDao() {
    logger = AcLogger(logType: AcEnumLogType.PRINT, logMessages: false);
    sqlConnection = AcSqlConnection();
  }

  Future<AcResult> checkDatabaseExist() async {
    return AcResult();
  }

  Future<AcResult> checkFunctionExist({required String functionName}) async {
    return AcResult();
  }

  Future<AcResult> checkStoredProcedureExist({required String storedProcedureName}) async {
    return AcResult();
  }

  Future<AcResult> checkTableExist({required String tableName}) async {
    return AcResult();
  }

  Future<AcResult> checkTriggerExist({required String triggerName}) async {
    return AcResult();
  }

  Future<AcResult> checkViewExist({required String viewName}) async {
    return AcResult();
  }

  Future<AcResult> createDatabase() async {
    return AcResult();
  }

  Future<AcSqlDaoResult> deleteRows({
    required String tableName,
    String condition = "",
    Map<String,dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> executeMultipleSqlStatements({
    required List<String> statements,
    Map<String,dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> executeStatement({
    required String statement,
    String? operation = AcEnumDDRowOperation.UNKNOWN,
    Map<String,dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  Map<String,dynamic> formatRow({
    required Map<String,dynamic> row,
    Map<String, List<String>> columnFormats = const {},
  }) {
    return row;
  }

  dynamic getConnectionObject() {
    try {
      // Normally returns a connection object
    } catch (ex) {
      logger.log("Error in getConnectionObject: ${ex.toString()}");
    }
    return null;
  }

  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getDatabaseTables() async {
    AcSqlDaoResult result = AcSqlDaoResult();
    try {
      // Implement actual logic
    } catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack);
    }
    return result;
  }

  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getDatabaseViews() async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getRows({
    required String statement,
    String condition = "",
    Map<String,dynamic> parameters = const {},
    String mode = AcEnumDDSelectMode.LIST,
    Map<String, List<String>> columnFormats = const {}
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> insertRow({
    required String tableName,
    required Map<String,dynamic> row,
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> insertRows({
    required String tableName,
    required List<Map<String,dynamic>> rows,
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcResult> setSqlConnection({required AcSqlConnection sqlConnection}) async {
    this.sqlConnection = sqlConnection;
    AcResult result = AcResult();
    result.setSuccess();
    return result;
  }

  Future<AcResult> setSqlConnectionFromJson({required Map<String, dynamic> jsonData}) async {
    sqlConnection = AcSqlConnection.instanceFromJson(jsonData: jsonData);
    return AcResult();
  }

  Map<String, dynamic> setSqlStatementParameters({
    required String statement,
    List<dynamic>? statementParametersList,
    Map<String,dynamic>? statementParametersMap,
    required Map<String, dynamic> passedParameters,
    bool returnMap = true
  }) {
    if(returnMap){
      statementParametersMap ??= {};
    }
    else {
      statementParametersList ??= List.empty(growable: true);
    }
    List<String> keys = passedParameters.keys.toList();
    for (String key in keys) {
      var value = passedParameters[key];
      if(!returnMap){
        while (statement.contains(key)) {
          logger.log("Searching For Key : $key");
          logger.log("SQL Statement : $statement");
          logger.log("Key Value: ${value.toString()}");
          String beforeQueryString = statement.substring(0, statement.indexOf(key));
          logger.log("Before String in Statement Where Key is found: $beforeQueryString");
          int parameterIndex = _countOccurrences(beforeQueryString, '?');
          logger.log("Parameter Index: $parameterIndex");
          logger.log("Values Before: ${statementParametersList.toString()}");
          if (value is List) {
            String replacement = List.filled(value.length, '?').join(',');
            statement = statement.replaceFirst(RegExp(RegExp.escape(key)), replacement);
            statementParametersList!.insertAll(parameterIndex, value);
          } else {
            statement = statement.replaceFirst(RegExp(RegExp.escape(key)), '?');
            statementParametersList!.insert(parameterIndex, value);
          }
          logger.log("Statement : $statement");
          logger.log("Values After: ${statementParametersList.toString()}");
        }
      }
      else{
        int index = statementParametersMap!.keys.length;
        String parameterKey = "parameter$index";
        while(statementParametersMap.keys.contains(parameterKey)){
          index++;
          parameterKey = "parameter$index";
        }
        statement = statement.replaceAll(key, ":$parameterKey");
        statementParametersMap[parameterKey] = value;
      }
    }
    return {
      'statement': statement,
      'statementParametersList': statementParametersList,
      'statementParametersMap': statementParametersMap,
      'passedParameters': passedParameters
    };
  }

  Future<AcSqlDaoResult> updateRow({
    required String tableName,
    required Map<String,dynamic> row,
    String condition = "",
    Map<String,dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcSqlDaoResult> updateRows({
    required String tableName,
    required List<Map<String,dynamic>> rowsWithConditions,
  }) async {
    return AcSqlDaoResult();
  }

  int _countOccurrences(String source, String pattern) {
    return RegExp(RegExp.escape(pattern)).allMatches(source).length;
  }
}
