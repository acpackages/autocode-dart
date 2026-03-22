import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';

/* AcDoc({
  "summary": "A Data Access Object (DAO) for interacting with a PostgreSQL database.",
  "description": "This class provides a concrete implementation of `AcBaseSqlDao` using the `postgres` package. It handles PostgreSQL-specific connection management, query execution, parameter substitution, transaction control, and result parsing.",
  "example": "final postgresConfig = AcSqlConnection(\n  host: 'localhost',\n  database: 'my_app_db',\n  username: 'postgres',\n  password: 'password'\n);\n\nfinal dao = AcPostgresDao();\nawait dao.setSqlConnection(sqlConnection: postgresConfig);\n\nfinal result = await dao.getRows(statement: 'SELECT * FROM users');\nprint(result.rows);"
}) */
class AcPostgresDao extends AcBaseSqlDao {
  Session? _transaction;

  /* AcDoc({"summary": "Creates and opens a new PostgreSQL database connection."}) */
  Future<Connection?> _getConnection() async {
    var database = await Connection.open(
      Endpoint(
        host: sqlConnection.hostname,
        port: sqlConnection.port,
        database: sqlConnection.database,
        username: sqlConnection.username,
        password: sqlConnection.password,
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
    return database;
  }

  /* AcDoc({"summary": "Creates and opens a new PostgreSQL connection without specifying a particular database (connects to 'postgres')."}) */
  Future<Connection> _getConnectionWithoutDatabase() async {
    return await Connection.open(
      Endpoint(
        host: sqlConnection.hostname,
        port: sqlConnection.port,
        database: 'postgres',
        username: sqlConnection.username,
        password: sqlConnection.password,
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
  }

  /* AcDoc({
    "summary": "Checks if the configured database exists on the server.",
    "returns": "An `AcResult` with a boolean `value` indicating if the database exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkDatabaseExist() async {
    final result = AcResult();
    Connection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      final statement = "SELECT COUNT(*) AS count FROM pg_database WHERE datname = @dbName";
      final results = await db.execute(Sql.named(statement), parameters: {'dbName': sqlConnection.database});
      final count = results.first.first as int;
      final exists = count > 0;
      print(exists);
      print(results.first.toList());
      result.setSuccess(
        value: exists,
        message: exists ? 'Database exists' : 'Database does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Checks if a specific table exists in the database.",
    "params": [{"name": "tableName", "description": "The name of the table to check."}],
    "returns": "An `AcResult` with a boolean `value` indicating if the table exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkTableExist({required String tableName}) async {
    final result = AcResult();
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT COUNT(*) AS count FROM information_schema.tables WHERE table_schema = 'public' AND table_name = @tableName";
      final results = await db!.execute(Sql.named(statement), parameters: {'tableName': tableName});
      final count = results.first.first as int;
      final exists = count > 0;
      result.setSuccess(
        value: exists,
        message: exists ? 'Table exists' : 'Table does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates the configured database if it does not already exist.",
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> createDatabase() async {
    final result = AcResult();
    Connection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      final statement = "CREATE DATABASE \"${sqlConnection.database}\"";
      await db.execute(statement);
      result.setSuccess(value: true, message: 'Database created');
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Map<String, dynamic> setSqlStatementParameters({
    required String statement,
    List<dynamic>? statementParametersList,
    Map<String, dynamic>? statementParametersMap,
    required Map<String, dynamic> passedParameters,
    bool returnMap = true,
    String? parameterPrefix = ":"
  }) {
    if (returnMap) {
      statementParametersMap ??= {};
    } else {
      statementParametersList ??= List.empty(growable: true);
    }
    List<String> keys = passedParameters.keys.toList();
    for (String key in keys) {
      var value = passedParameters[key];
        int index = statementParametersMap!.keys.length;
        String parameterKey = "parameter$index";
        while (statementParametersMap.keys.contains(parameterKey)) {
          index++;
          parameterKey = "parameter$index";
        }
        logger.log("Searching For Key : $key");
        logger.log("Key Value: `${value.toString()}`");
        logger.log("SQL Statement Before: $statement");
        logger.log(["SQL Parameters Before:", statementParametersMap]);
        if (value is List) {
          logger.log(
            "Value is List so converting to individual values: ${value.toString()}",
          );
          List<String> listParamKeys = List.empty(growable: true);
          for (int i = 0; i < value.length; i++) {
            final listParameterKey = "@${parameterKey}_$i";
            listParamKeys.add(listParameterKey);
            statementParametersMap[listParameterKey.replaceAll("@","")] = value[i];
          }
          statement = statement.replaceAll(key, listParamKeys.join(","));
        } else {
          logger.log("Value is not list");
          statement = statement.replaceAll(key, "@$parameterKey");
          statementParametersMap[parameterKey] = value;
        }
        logger.log("SQL Statement After: $statement");
        logger.log([
          "SQL Parameters After:",
          jsonEncode(statementParametersMap),
        ]);
    }
    return {
      'statement': statement,
      'statementParametersList': statementParametersList,
      'statementParametersMap': statementParametersMap,
      'passedParameters': passedParameters,
    };
  }

  dynamic ensureValidParamsType({required dynamic param}) {
    if (param is DateTime) {
      return param; // Postgres package handles DateTime natively
    }
    return param;
  }

  Map<String, dynamic> validateParametersMap(Map<String, dynamic> parameters) {
    var validMap = <String, dynamic>{};
    parameters.forEach((key, value) {
      validMap[key] = ensureValidParamsType(param: value);
    });
    return validMap;
  }

  /* AcDoc({
    "summary": "Deletes rows from a table that match a given condition.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "condition", "description": "The WHERE clause for the deletion."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."}
    ],
    "returns": "An `AcSqlDaoResult` containing the number of affected rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> deleteRows({
    required String tableName,
    String condition = "",
    Map<String, dynamic> parameters = const {},
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.delete);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = 'DELETE FROM $tableName ${condition.isNotEmpty ? "WHERE $condition" : ""}';
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'] as String;
      final updatedParameterValuesMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
      
      final results = await db!.execute(Sql.named(updatedStatement), parameters: updatedParameterValuesMap);
      result.affectedRowsCount = results.affectedRows;
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes multiple SQL statements within a single transaction.",
    "returns": "An `AcSqlDaoResult` indicating the overall success or failure.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> executeMultipleSqlStatements({
    required List<String> statements,
    Map<String, dynamic> parameters = const {},
    Function(AcSqlCallbackArgs)? perStatementCallback
  }) async {
    final result = AcSqlDaoResult();
    dynamic lastSqlStatement;
    dynamic lastParameters;
    Connection? db;
    try {
      db = await _getConnection();
      if (db != null) {
        int totalCount = statements.length;
        int completedCount = 0;
        
        Future<void> runStatements(Session session) async {
          for (final statement in statements) {
            completedCount++;
            if (statement.trim().isNotEmpty) {
              final setParametersResult = setSqlStatementParameters(
                statement: statement,
                passedParameters: parameters,
              );
              final updatedStatement = setParametersResult['statement'] as String;
              final updatedParameterValuesMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
              
              lastSqlStatement = updatedStatement;
              lastParameters = updatedParameterValuesMap;
              
              await session.execute(Sql.named(updatedStatement), parameters: updatedParameterValuesMap);
              if (perStatementCallback != null) {
                perStatementCallback(AcSqlCallbackArgs(totalCount: totalCount, completedCount: completedCount));
              }
            }
          }
        }
        
        if (_transaction != null) {
          await runStatements(_transaction!);
        } else {
          await db.runTx((ctx) async {
            await runStatements(ctx);
          });
        }
        result.setSuccess();
      } else {
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
      result.value = {'last_sql_statement': lastSqlStatement, 'last_sql_parameters': lastParameters};
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcResult> executeSqlOperations({
    required List<AcSqlOperation> operations,
    Function(AcSqlCallbackArgs)? perOperationCallback
  }) async {
    final result = AcSqlDaoResult();
    Connection? db;
    try {
      db = await _getConnection();

      if (db != null) {
        Future<List<dynamic>> runOperations(Session session) async {
          List<dynamic> operationResults = [];
          int totalCount = operations.length;
          int completedCount = 0;

          for (int i = 0; i < operations.length; i++) {
            completedCount++;
            final sqlOperation = operations[i];
            
            if (sqlOperation.rawSql != null) {
              final setParametersResult = setSqlStatementParameters(
                statement: sqlOperation.rawSql!,
                passedParameters: sqlOperation.parameters ?? {},
              );
              final updatedStatement = setParametersResult['statement'] as String;
              final updatedParameterMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
              await session.execute(Sql.named(updatedStatement), parameters: updatedParameterMap);
              operationResults.add(null);
            } else if (sqlOperation.operation == AcEnumDDRowOperation.insert) {
              var row = sqlOperation.row!;
              final columns = row.keys.toList();
              final placeholders = List.generate(columns.length, (i) => '@parameter$i').join(', ');
              final statement = "INSERT INTO ${sqlOperation.table} (${columns.join(', ')}) VALUES ($placeholders) RETURNING *";
              var params = <String, dynamic>{};
              for (int j = 0; j < columns.length; j++) {
                params['parameter$j'] = ensureValidParamsType(param: row[columns[j]]);
              }
              final executionResult = await session.execute(Sql.named(statement), parameters: params);
              operationResults.add(executionResult.isNotEmpty ? executionResult.first[0] : null);
            } else if (sqlOperation.operation == AcEnumDDRowOperation.update) {
              var row = sqlOperation.row!;
              int paramIndex = 0;
              final setValues = row.keys.map((key) {
                final p = '@parameter$paramIndex';
                paramIndex++;
                return "$key = $p";
              }).join(", ");
              
              var params = <String, dynamic>{};
              paramIndex = 0;
              for (var key in row.keys) {
                params['parameter$paramIndex'] = ensureValidParamsType(param: row[key]);
                paramIndex++;
              }
              
              final conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty
                  ? "WHERE ${sqlOperation.condition}"
                  : "";
                  
              final setParametersResult = setSqlStatementParameters(
                statement: conditionClause,
                passedParameters: sqlOperation.parameters ?? {},
                statementParametersMap: params
              );
              final updatedCondition = setParametersResult['statement'] as String;
              final updatedParameterMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
              
              final statement = "UPDATE ${sqlOperation.table} SET $setValues $updatedCondition";
              final executionResult = await session.execute(Sql.named(statement), parameters: updatedParameterMap);
              operationResults.add(executionResult.affectedRows);
            } else if (sqlOperation.operation == AcEnumDDRowOperation.delete) {
              final conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty
                  ? "WHERE ${sqlOperation.condition}"
                  : "";
              final baseStatement = "DELETE FROM ${sqlOperation.table} $conditionClause";

              final setParametersResult = setSqlStatementParameters(
                statement: baseStatement,
                passedParameters: sqlOperation.parameters ?? {},
              );
              final updatedStatement = setParametersResult['statement'] as String;
              final parameterMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
              
              final executionResult = await session.execute(Sql.named(updatedStatement), parameters: parameterMap);
              operationResults.add(executionResult.affectedRows);
            } else {
              operationResults.add(null);
            }
            if (perOperationCallback != null) {
              perOperationCallback(AcSqlCallbackArgs(totalCount: totalCount, completedCount: completedCount));
            }
          }
          return operationResults;
        }

        if (_transaction != null) {
          result.value = await runOperations(_transaction!);
        } else {
          result.value = await db.runTx((ctx) async {
             return await runOperations(ctx);
          });
        }
        result.setSuccess();
      } else {
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes a single, parameterized SQL statement.",
    "returns": "An `AcSqlDaoResult` indicating the outcome.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> executeStatement({
    required String statement,
    AcEnumDDRowOperation? operation = AcEnumDDRowOperation.unknown,
    Map<String, dynamic> parameters = const {},
  }) async {
    final result = AcSqlDaoResult(operation: operation!);
    Connection? db;
    try {
      db = await _getConnection();
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'] as String;
      final updatedParameterValuesMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
      
      final results = await db!.execute(Sql.named(updatedStatement), parameters: updatedParameterValuesMap);
      result.setSuccess();
      if ([AcEnumDDRowOperation.insert, AcEnumDDRowOperation.update, AcEnumDDRowOperation.delete].contains(operation)) {
        result.affectedRowsCount = results.affectedRows;
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Map<String, dynamic> formatRow({
    required Map<String, dynamic> row,
    Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
  }) {
    final formattedRow = Map<String, dynamic>.from(row);
    columnFormats.forEach((key, formats) {
      if (formattedRow.containsKey(key)) {
        final value = formattedRow[key];
        if (value is String) {
          if (formats.contains(AcEnumDDColumnFormat.encrypt)) {
            formattedRow[key] = AcEncryption.decrypt(encryptedText: value);
          }
          if (formats.contains(AcEnumDDColumnFormat.json)) {
            if (value.isNotEmpty) {
              try {
                formattedRow[key] = jsonDecode(value);
              } catch (_) {}
            } else {
              formattedRow[key] = null;
            }
          }
        }
        if (formats.contains(AcEnumDDColumnFormat.hideColumn)) {
          formattedRow.remove(key);
        }
      }
    });
    return formattedRow;
  }

  @override
  Future<dynamic> getConnectionObject({
    bool includeDatabase = true,
  }) async {
    try {
      if (includeDatabase) {
        return await _getConnection();
      } else {
        return await _getConnectionWithoutDatabase();
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT routine_name FROM information_schema.routines WHERE routine_type='FUNCTION' AND specific_schema='public'";
      final results = await db!.execute(statement);
      for (final row in results) {
        result.rows.add({
          "routine_name": row[0],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT routine_name FROM information_schema.routines WHERE routine_type='PROCEDURE' AND specific_schema='public'";
      final results = await db!.execute(statement);
      for (final row in results) {
        result.rows.add({
          "routine_name": row[0],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseTables() async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT table_name AS \"TABLE_NAME\" FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'";
      final results = await db!.execute(statement);
      for (final row in results) {
        result.rows.add({
          AcDDTable.keyTableName: row[0],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT trigger_name AS \"TRIGGER_NAME\" FROM information_schema.triggers WHERE trigger_schema='public'";
      final results = await db!.execute(statement);
      for (final row in results) {
        result.rows.add({
          AcDDTrigger.keyTriggerName: row[0],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseViews() async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT table_name AS \"TABLE_NAME\" FROM information_schema.views WHERE table_schema='public'";
      final results = await db!.execute(statement);
      for (final row in results) {
        result.rows.add({
          AcDDView.keyViewName: row[0],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getRows({
    required String statement,
    String condition = "",
    Map<String, dynamic> parameters = const {},
    AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
    Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      String updatedStatement = statement;
      if (condition.isNotEmpty) {
        updatedStatement += " WHERE $condition";
      }
      final setParametersResult = setSqlStatementParameters(
        statement: updatedStatement,
        passedParameters: parameters,
      );
      updatedStatement = setParametersResult['statement'] as String;
      final updatedParameterValuesMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
      
      if (mode == AcEnumDDSelectMode.count) {
        updatedStatement = "SELECT COUNT(*) AS records_count FROM ($updatedStatement) AS records_list";
      }
      print(updatedStatement);
      print(updatedParameterValuesMap);
      final results = await db!.execute(Sql.named(updatedStatement), parameters: updatedParameterValuesMap);
      
      if (mode == AcEnumDDSelectMode.count) {
        result.totalRows = int.parse(results.first[0].toString());
      } else {
        final columnNames = results.schema.columns.map((c) => c.columnName ?? '').toList();
        result.rows = results.map((row) {
          final rowMap = <String, dynamic>{};
          for (int i = 0; i < columnNames.length; i++) {
            rowMap[columnNames[i]] = row[i];
          }
          return formatRow(row: rowMap, columnFormats: columnFormats);
        }).toList();
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    Connection? db;
    try {
      db = await _getConnection();
      final statement = "SELECT column_name, data_type, column_default, is_nullable FROM information_schema.columns WHERE table_name = @tableName AND table_schema = 'public'";
      final results = await db!.execute(Sql.named(statement), parameters: {'tableName': tableName});
      
      final pkStatement = """
        SELECT kcu.column_name
        FROM information_schema.table_constraints tco
        JOIN information_schema.key_column_usage kcu 
          ON kcu.constraint_name = tco.constraint_name 
          AND kcu.constraint_schema = tco.constraint_schema
        WHERE tco.constraint_type = 'PRIMARY KEY' AND tco.table_name = @tableName
      """;
      final pkResults = await db!.execute(Sql.named(pkStatement), parameters: {'tableName': tableName});
      final pkColumns = pkResults.map((r) => r[0] as String).toList();

      for (final row in results) {
        final properties = <String, dynamic>{};
        if (row[3] == 'NO') {
          properties[AcEnumDDColumnProperty.notNull.value] = true;
        }
        if (pkColumns.contains(row[0] as String)) {
          properties[AcEnumDDColumnProperty.primaryKey.value] = true;
        }
        if (row[2] != null) {
          properties[AcEnumDDColumnProperty.defaultValue.value] = row[2];
        }
        result.rows.add({
          AcDDTableColumn.keyColumnName: row[0],
          AcDDTableColumn.keyColumnType: row[1],
          AcDDTableColumn.keyColumnProperties: properties,
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    return getTableColumns(tableName: viewName);
  }

  @override
  Future<AcSqlDaoResult> insertRow({
    required String tableName,
    required Map<String, dynamic> row,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
    Connection? db;
    try {
      db = await _getConnection();
      final columns = row.keys.toList();
      final placeholders = List.generate(columns.length, (i) => '@parameter$i').join(', ');
      final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders) RETURNING *";
      var params = <String, dynamic>{};
      for (int i = 0; i < columns.length; i++) {
        params['parameter$i'] = ensureValidParamsType(param: row[columns[i]]);
      }
      final results = await db!.execute(Sql.named(statement), parameters: params);
      if (results.isNotEmpty) {
        result.lastInsertedId = results.first[0];
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> insertRows({
    required String tableName,
    required List<Map<String, dynamic>> rows,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
    Connection? db;
    try {
      db = await _getConnection();
      if (db != null) {
        if (rows.isNotEmpty) {
          Future<void> runInsert(Session session) async {
            for (final rowData in rows) {
              final columns = rowData.keys.toList();
              final placeholders = List.generate(columns.length, (i) => '@parameter$i').join(', ');
              final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
              var params = <String, dynamic>{};
              for (int i = 0; i < columns.length; i++) {
                params['parameter$i'] = ensureValidParamsType(param: rowData[columns[i]]);
              }
              await session.execute(Sql.named(statement), parameters: params);
            }
          }
          if (_transaction != null) {
            await runInsert(_transaction!);
          } else {
            await db.runTx((ctx) async {
              await runInsert(ctx);
            });
          }
          result.setSuccess();
        } else {
          result.setSuccess(message: 'No rows to insert.');
        }
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> updateRow({
    required String tableName,
    required Map<String, dynamic> row,
    String condition = "",
    Map<String, dynamic> parameters = const {},
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
    Connection? db;
    try {
      db = await _getConnection();
      int paramIndex = 0;
      final setValues = row.keys.map((key) {
        final p = '@parameter$paramIndex';
        paramIndex++;
        return "$key = $p";
      }).join(", ");
      
      var params = <String, dynamic>{};
      paramIndex = 0;
      for (var key in row.keys) {
        params['parameter$paramIndex'] = ensureValidParamsType(param: row[key]);
        paramIndex++;
      }
      
      final conditionClause = condition.isNotEmpty ? "WHERE $condition" : "";
      final setParametersResult = setSqlStatementParameters(
        statement: conditionClause,
        passedParameters: parameters,
        statementParametersMap: params
      );
      final updatedCondition = setParametersResult['statement'] as String;
      final updatedParameterMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
      
      final statement = "UPDATE $tableName SET $setValues $updatedCondition";
      final executionResult = await db!.execute(Sql.named(statement), parameters: updatedParameterMap);
      result.affectedRowsCount = executionResult.affectedRows;
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> updateRows({
    required String tableName,
    required List<Map<String, dynamic>> rowsWithConditions,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
    Connection? db;
    try {
      final db = await _getConnection();
      if (db != null) {
        Future<void> runUpdates(Session session) async {
          result.affectedRowsCount = 0;
          for (final rowWithCondition in rowsWithConditions) {
            if (rowWithCondition.containsKey('row') && rowWithCondition.containsKey('condition')) {
              final row = rowWithCondition['row'] as Map<String, dynamic>;
              final condition = rowWithCondition['condition'] as String;
              final conditionParameters = rowWithCondition.containsKey('parameters')
                  ? rowWithCondition['parameters'] as Map<String, dynamic>
                  : <String, dynamic>{};
                  
              int paramIndex = 0;
              final setValues = row.keys.map((key) {
                final p = '@parameter$paramIndex';
                paramIndex++;
                return "$key = $p";
              }).join(", ");
              
              var params = <String, dynamic>{};
              paramIndex = 0;
              for (var key in row.keys) {
                params['parameter$paramIndex'] = ensureValidParamsType(param: row[key]);
                paramIndex++;
              }
              
              final conditionClause = condition.isNotEmpty ? "WHERE $condition" : "";
              final setParametersResult = setSqlStatementParameters(
                statement: conditionClause,
                passedParameters: conditionParameters,
                statementParametersMap: params
              );
              final updatedCondition = setParametersResult['statement'] as String;
              final updatedParameterMap = validateParametersMap(setParametersResult['statementParametersMap'] as Map<String, dynamic>);
              
              final statement = "UPDATE $tableName SET $setValues $updatedCondition";
              final executionResult = await session.execute(Sql.named(statement), parameters: updatedParameterMap);
              result.affectedRowsCount = (result.affectedRowsCount ?? 0) + executionResult.affectedRows;
            }
          }
        }
        if (_transaction != null) {
          await runUpdates(_transaction!);
        } else {
          await db.runTx((ctx) async {
            await runUpdates(ctx);
          });
        }
        result.setSuccess();
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    finally {
      if (db != null) {
        await db.close();
      }
    }
    return result;
  }
}
