import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A base class for providing a standard Data Access Object (DAO) interface for SQL databases.",
  "description": "This class defines a common set of methods for database operations like creating schemas, checking for the existence of objects, and performing CRUD (Create, Read, Update, Delete) operations. It is intended to be extended by concrete implementations for specific database systems (e.g., MySQL, PostgreSQL, SQLite).",
  "example": "class MySqlDao extends AcBaseSqlDao {\n  @override\n  Future<AcResult> checkTableExist({required String tableName}) async {\n    // Implementation for MySQL...\n    final result = AcResult();\n    // ... check logic ...\n    result.setSuccess();\n    return result;\n  }\n}\n\n// Usage:\nfinal myDao = MySqlDao();\nawait myDao.setSqlConnection(sqlConnection: mySqlConnectionConfig);\nfinal tableExistsResult = await myDao.checkTableExist(tableName: 'users');"
}) */
class AcBaseSqlDao {
  /* AcDoc({"summary": "Logger instance for logging DAO operations."}) */
  late AcLogger logger;

  /* AcDoc({"summary": "The connection configuration for the database."}) */
  late AcSqlConnection sqlConnection;

  /* AcDoc({"summary": "Initializes a new instance of the base DAO."}) */
  AcBaseSqlDao() {
    logger = AcLogger(logType: AcEnumLogType.html, logMessages: false,logDirectory: 'logs',logFileName: 'ac_sql_dao.html');
    sqlConnection = AcSqlConnection();
  }

  /* AcDoc({
    "summary": "Checks if the configured database exists.",
    "description": "Implementations should query the database server to verify the existence of the database specified in the `sqlConnection` configuration.",
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkDatabaseExist() async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Checks if a specific function exists in the database.",
    "params": [
      {"name": "functionName", "description": "The name of the function to check for."}
    ],
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkFunctionExist({required String functionName}) async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Checks if a specific stored procedure exists in the database.",
    "params": [
      {"name": "storedProcedureName", "description": "The name of the stored procedure to check for."}
    ],
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkStoredProcedureExist({
    required String storedProcedureName,
  }) async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Checks if a specific table exists in the database.",
    "params": [
      {"name": "tableName", "description": "The name of the table to check for."}
    ],
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkTableExist({required String tableName}) async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Checks if a specific trigger exists in the database.",
    "params": [
      {"name": "triggerName", "description": "The name of the trigger to check for."}
    ],
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkTriggerExist({required String triggerName}) async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Checks if a specific view exists in the database.",
    "params": [
      {"name": "viewName", "description": "The name of the view to check for."}
    ],
    "returns": "An `AcResult` indicating the outcome of the check.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkViewExist({required String viewName}) async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Creates the configured database if it does not already exist.",
    "returns": "An `AcResult` indicating the outcome of the creation operation.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabase() async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Deletes rows from a table based on a condition.",
    "params": [
      {"name": "tableName", "description": "The name of the table to delete from."},
      {"name": "condition", "description": "The WHERE clause of the DELETE statement."},
      {"name": "parameters", "description": "A map of parameters to be substituted into the condition."}
    ],
    "returns": "An `AcSqlDaoResult` containing the number of affected rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> deleteRows({
    required String tableName,
    String condition = "",
    Map<String, dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  Future<AcResult> dropExistingRelationships() async {
    return AcResult();
  }

  /* AcDoc({
    "summary": "Executes a list of SQL statements in a transaction or batch.",
    "params": [
      {"name": "statements", "description": "A list of SQL statements to execute."},
      {"name": "parameters", "description": "Parameters for the statements (if supported by the driver)."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the outcome of the batch execution.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> executeMultipleSqlStatements({
    required List<String> statements,
    Map<String, dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Executes a single, generic SQL statement.",
    "params": [
      {"name": "statement", "description": "The SQL statement to execute."},
      {"name": "operation", "description": "The type of operation being performed, for result metadata."},
      {"name": "parameters", "description": "A map of parameters to be substituted into the statement."}
    ],
    "returns": "An `AcSqlDaoResult` containing the outcome of the execution.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> executeStatement({
    required String statement,
    AcEnumDDRowOperation? operation = AcEnumDDRowOperation.unknown,
    Map<String, dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Formats a single row of data based on column format definitions.",
    "params": [
      {"name": "row", "description": "The raw data row as a map."},
      {"name": "columnFormats", "description": "A map defining how to format specific columns."}
    ],
    "returns": "The formatted data row.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> formatRow({
    required Map<String, dynamic> row,
    Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
  }) {
    return row;
  }

  /* AcDoc({
    "summary": "Gets the underlying, driver-specific database connection object.",
    "description": "This method is used to access the raw connection object from the database driver (e.g., a `MySqlConnection` object) for advanced or non-standard operations.",
    "returns": "The driver-specific connection object, or null on error.",
    "returns_type": "dynamic"
  }) */
  dynamic getConnectionObject() {
    try {
      // Normally returns a driver-specific connection object
    } catch (ex) {
      logger.log("Error in getConnectionObject: ${ex.toString()}");
    }
    return null;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all functions in the database.",
    "returns": "An `AcSqlDaoResult` containing the list of functions.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Retrieves a list of all stored procedures in the database.",
    "returns": "An `AcSqlDaoResult` containing the list of stored procedures.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Retrieves a list of all tables in the database.",
    "returns": "An `AcSqlDaoResult` containing the list of tables.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDatabaseTables() async {
    AcSqlDaoResult result = AcSqlDaoResult();
    try {
      // Implement actual logic
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all triggers in the database.",
    "returns": "An `AcSqlDaoResult` containing the list of triggers.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Retrieves a list of all views in the database.",
    "returns": "An `AcSqlDaoResult` containing the list of views.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDatabaseViews() async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Executes a SELECT statement and retrieves rows.",
    "params": [
      {"name": "statement", "description": "The SELECT statement to execute."},
      {"name": "condition", "description": "An optional WHERE clause to append."},
      {"name": "parameters", "description": "A map of parameters for substitution."},
      {"name": "mode", "description": "The desired format for the returned data (e.g., list, map)."},
      {"name": "columnFormats", "description": "Formatting rules to apply to the result columns."}
    ],
    "returns": "An `AcSqlDaoResult` containing the fetched rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getRows({
    required String statement,
    String condition = "",
    Map<String, dynamic> parameters = const {},
    AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
    Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to inspect."}
    ],
    "returns": "An `AcSqlDaoResult` containing the column definitions.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a view.",
    "params": [
      {"name": "viewName", "description": "The name of the view to inspect."}
    ],
    "returns": "An `AcSqlDaoResult` containing the column definitions.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Inserts a single row into a table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to insert into."},
      {"name": "row", "description": "A map representing the row to be inserted, with column names as keys."}
    ],
    "returns": "An `AcSqlDaoResult` containing the last inserted ID.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> insertRow({
    required String tableName,
    required Map<String, dynamic> row,
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Inserts multiple rows into a table in a single operation.",
    "params": [
      {"name": "tableName", "description": "The name of the table to insert into."},
      {"name": "rows", "description": "A list of maps, where each map represents a row to be inserted."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the bulk insert operation.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> insertRows({
    required String tableName,
    required List<Map<String, dynamic>> rows,
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Sets the database connection configuration for this DAO instance.",
    "params": [
      {"name": "sqlConnection", "description": "The connection configuration object."}
    ],
    "returns": "An `AcResult` indicating success.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> setSqlConnection({
    required AcSqlConnection sqlConnection,
  }) async {
    this.sqlConnection = sqlConnection;
    AcResult result = AcResult();
    result.setSuccess();
    return result;
  }

  /* AcDoc({
    "summary": "Sets the connection configuration from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "A JSON map containing connection properties."}
    ],
    "returns": "An `AcResult` indicating success.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> setSqlConnectionFromJson({
    required Map<String, dynamic> jsonData,
  }) async {
    sqlConnection = AcSqlConnection.instanceFromJson(jsonData: jsonData);
    return AcResult();
  }

  /* AcDoc({
    "summary": "Substitutes named parameters into a SQL statement.",
    "description": "A utility method to replace named placeholders in a SQL string with positional `?` markers or driver-specific named parameters (e.g., `:parameter0`). It returns the modified statement and the ordered list or map of parameter values.",
    "params": [
      {"name": "statement", "description": "The SQL statement with named placeholders."},
      {"name": "statementParametersList", "description": "An existing list to add positional parameters to."},
      {"name": "statementParametersMap", "description": "An existing map to add named parameters to."},
      {"name": "passedParameters", "description": "A map of placeholder names to their values."},
      {"name": "returnMap", "description": "If true, prepares parameters for named substitution (e.g., `:key`). If false, prepares for positional substitution (`?`)."}
    ],
    "returns": "A map containing the modified statement and the new parameter collections.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> setSqlStatementParameters({
    required String statement,
    List<dynamic>? statementParametersList,
    Map<String, dynamic>? statementParametersMap,
    required Map<String, dynamic> passedParameters,
    bool returnMap = true,
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
        logger.log("Searching For Key : $key");
        logger.log("Key Value: ${value.toString()}");
        logger.log("SQL Statement Before: $statement");
        logger.log(["SQL Parameters Before:",statementParametersMap]);
        if (value is List) {
          logger.log("Value is List so converting to individual values: ${value.toString()}");
          List<String> listParamKeys = List.empty(growable: true);
          for(int i =0;i<value.length;i++){
            final listParameterKey = ":${parameterKey}_$i";
            listParamKeys.add(listParameterKey);
            statementParametersMap[listParameterKey] = value[i];
          }
          statement = statement.replaceAll(key, listParamKeys.join(","));
        }
        else{
          statement = statement.replaceAll(key, ":$parameterKey");
          statementParametersMap[parameterKey] = value;
        }
        logger.log("SQL Statement After: $statement");
        logger.log(["SQL Parameters After:",statementParametersMap]);
      }
    }
    return {
      'statement': statement,
      'statementParametersList': statementParametersList,
      'statementParametersMap': statementParametersMap,
      'passedParameters': passedParameters
    };
  }

  /* AcDoc({
    "summary": "Updates a single row that matches a condition.",
    "description": "This method is intended to update a single row. For safety, the `condition` should be specific. If the condition matches multiple rows, the database behavior may vary.",
    "params": [
      {"name": "tableName", "description": "The name of the table to update."},
      {"name": "row", "description": "A map of column names to their new values."},
      {"name": "condition", "description": "The WHERE clause to identify the row to update."},
      {"name": "parameters", "description": "Parameters for the condition."}
    ],
    "returns": "An `AcSqlDaoResult` containing the number of affected rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> updateRow({
    required String tableName,
    required Map<String, dynamic> row,
    String condition = "",
    Map<String, dynamic> parameters = const {},
  }) async {
    return AcSqlDaoResult();
  }

  /* AcDoc({
    "summary": "Updates multiple rows in a single batch operation.",
    "description": "Executes a series of UPDATE statements for multiple rows. Each row must have its own condition.",
    "params": [
      {"name": "tableName", "description": "The name of the table to update."},
      {"name": "rowsWithConditions", "description": "A list of maps, where each map contains the row data and its corresponding update condition."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the outcome of the batch update.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> updateRows({
    required String tableName,
    required List<Map<String, dynamic>> rowsWithConditions,
  }) async {
    return AcSqlDaoResult();
  }

  int _countOccurrences(String source, String pattern) {
    return RegExp(RegExp.escape(pattern)).allMatches(source).length;
  }
}
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcBaseSqlDao {
//   late AcLogger logger;
//   late AcSqlConnection sqlConnection;
//
//   AcBaseSqlDao() {
//     logger = AcLogger(logType: AcEnumLogType.print_, logMessages: false);
//     sqlConnection = AcSqlConnection();
//   }
//
//   Future<AcResult> checkDatabaseExist() async {
//     return AcResult();
//   }
//
//   Future<AcResult> checkFunctionExist({required String functionName}) async {
//     return AcResult();
//   }
//
//   Future<AcResult> checkStoredProcedureExist({
//     required String storedProcedureName,
//   }) async {
//     return AcResult();
//   }
//
//   Future<AcResult> checkTableExist({required String tableName}) async {
//     return AcResult();
//   }
//
//   Future<AcResult> checkTriggerExist({required String triggerName}) async {
//     return AcResult();
//   }
//
//   Future<AcResult> checkViewExist({required String viewName}) async {
//     return AcResult();
//   }
//
//   Future<AcResult> createDatabase() async {
//     return AcResult();
//   }
//
//   Future<AcSqlDaoResult> deleteRows({
//     required String tableName,
//     String condition = "",
//     Map<String, dynamic> parameters = const {},
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> executeMultipleSqlStatements({
//     required List<String> statements,
//     Map<String, dynamic> parameters = const {},
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> executeStatement({
//     required String statement,
//     AcEnumDDRowOperation? operation = AcEnumDDRowOperation.unknown,
//     Map<String, dynamic> parameters = const {},
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Map<String, dynamic> formatRow({
//     required Map<String, dynamic> row,
//     Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
//   }) {
//     return row;
//   }
//
//   dynamic getConnectionObject() {
//     try {
//       // Normally returns a connection object
//     } catch (ex) {
//       logger.log("Error in getConnectionObject: ${ex.toString()}");
//     }
//     return null;
//   }
//
//   Future<AcSqlDaoResult> getDatabaseFunctions() async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getDatabaseTables() async {
//     AcSqlDaoResult result = AcSqlDaoResult();
//     try {
//       // Implement actual logic
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   Future<AcSqlDaoResult> getDatabaseTriggers() async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getDatabaseViews() async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getRows({
//     required String statement,
//     String condition = "",
//     Map<String, dynamic> parameters = const {},
//     AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
//     Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> insertRow({
//     required String tableName,
//     required Map<String, dynamic> row,
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> insertRows({
//     required String tableName,
//     required List<Map<String, dynamic>> rows,
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcResult> setSqlConnection({
//     required AcSqlConnection sqlConnection,
//   }) async {
//     this.sqlConnection = sqlConnection;
//     AcResult result = AcResult();
//     result.setSuccess();
//     return result;
//   }
//
//   Future<AcResult> setSqlConnectionFromJson({
//     required Map<String, dynamic> jsonData,
//   }) async {
//     sqlConnection = AcSqlConnection.instanceFromJson(jsonData: jsonData);
//     return AcResult();
//   }
//
//   Map<String, dynamic> setSqlStatementParameters({
//     required String statement,
//     List<dynamic>? statementParametersList,
//     Map<String, dynamic>? statementParametersMap,
//     required Map<String, dynamic> passedParameters,
//     bool returnMap = true,
//   }) {
//     if (returnMap) {
//       statementParametersMap ??= {};
//     } else {
//       statementParametersList ??= List.empty(growable: true);
//     }
//     List<String> keys = passedParameters.keys.toList();
//     for (String key in keys) {
//       var value = passedParameters[key];
//       if (!returnMap) {
//         while (statement.contains(key)) {
//           logger.log("Searching For Key : $key");
//           logger.log("SQL Statement : $statement");
//           logger.log("Key Value: ${value.toString()}");
//           String beforeQueryString = statement.substring(
//             0,
//             statement.indexOf(key),
//           );
//           logger.log(
//             "Before String in Statement Where Key is found: $beforeQueryString",
//           );
//           int parameterIndex = _countOccurrences(beforeQueryString, '?');
//           logger.log("Parameter Index: $parameterIndex");
//           logger.log("Values Before: ${statementParametersList.toString()}");
//           if (value is List) {
//             String replacement = List.filled(value.length, '?').join(',');
//             statement = statement.replaceFirst(
//               RegExp(RegExp.escape(key)),
//               replacement,
//             );
//             statementParametersList!.insertAll(parameterIndex, value);
//           } else {
//             statement = statement.replaceFirst(RegExp(RegExp.escape(key)), '?');
//             statementParametersList!.insert(parameterIndex, value);
//           }
//           logger.log("Statement : $statement");
//           logger.log("Values After: ${statementParametersList.toString()}");
//         }
//       } else {
//         int index = statementParametersMap!.keys.length;
//         String parameterKey = "parameter$index";
//         while (statementParametersMap.keys.contains(parameterKey)) {
//           index++;
//           parameterKey = "parameter$index";
//         }
//         statement = statement.replaceAll(key, ":$parameterKey");
//         statementParametersMap[parameterKey] = value;
//       }
//     }
//     return {
//       'statement': statement,
//       'statementParametersList': statementParametersList,
//       'statementParametersMap': statementParametersMap,
//       'passedParameters': passedParameters,
//     };
//   }
//
//   Future<AcSqlDaoResult> updateRow({
//     required String tableName,
//     required Map<String, dynamic> row,
//     String condition = "",
//     Map<String, dynamic> parameters = const {},
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   Future<AcSqlDaoResult> updateRows({
//     required String tableName,
//     required List<Map<String, dynamic>> rowsWithConditions,
//   }) async {
//     return AcSqlDaoResult();
//   }
//
//   int _countOccurrences(String source, String pattern) {
//     return RegExp(RegExp.escape(pattern)).allMatches(source).length;
//   }
// }
