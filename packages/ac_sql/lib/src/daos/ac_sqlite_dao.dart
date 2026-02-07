import 'dart:io';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

/* AcDoc({
  "summary": "A Data Access Object (DAO) for interacting with a SQLite database.",
  "description": "This class provides a concrete implementation of `AcBaseSqlDao` using the `sqflite` package. It handles SQLite-specific connection management, query execution, parameter substitution, transaction control, and result parsing.",
  "example": "final sqliteConfig = AcSqlConnection(\n  database: 'my_app.db'\n);\n\nfinal dao = AcSqliteDao();\nawait dao.setSqlConnection(sqlConnection: sqliteConfig);\n\nfinal result = await dao.getRows(statement: 'SELECT * FROM users');\nprint(result.rows);"
}) */
class AcSqliteDao extends AcBaseSqlDao {
  static Map<String,Database?> _databaseInstances = {};
  Database? _database;
  static bool autoCloseAfterExecution = false;
  static bool _platformResolved = false;
  Transaction? _transaction = null;
  bool _transactionRollback = false;

  _initSqlite(){
    if(!_platformResolved){
      if (Platform.isWindows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _platformResolved = true;
    }
  }

  /* AcDoc({"summary": "Creates and opens a new SQLite database connection."}) */
  Future<Database?> _getConnection() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    final databasePath = sqlConnection.database;
    if(_databaseInstances.containsKey(databasePath)){
      if (_databaseInstances[databasePath] != null && _databaseInstances[databasePath]!.isOpen) {
        return _databaseInstances[databasePath]!;
      }
    }
    _initSqlite();
    _database = await openDatabase(databasePath);
    _databaseInstances[databasePath] = _database;
    final pragmaStatements = acSqlConfig.sqliteConfig.toPragmaStatements(); // or load from your stored settings
    for (final pragma in pragmaStatements) {
      try {
        await _database!.execute(pragma);
      } catch (e) {
        logger.warn('⚠️ Failed to apply PRAGMA: $pragma — $e');
      }
    }
    return _database;
  }

  /* AcDoc({"summary": "Creates and opens a new SQLite connection without specifying a database."}) */
  Future<Database> _getConnectionWithoutDatabase() async {
    _initSqlite();
    // SQLite always requires a database file, so we use an in-memory database for operations not requiring a specific database
    return await openDatabase(inMemoryDatabasePath);
  }

  /* AcDoc({
    "summary": "Checks if the configured database exists on the server.",
    "description": "This SQLite implementation checks if the database file exists.",
    "returns": "An `AcResult` with a boolean `value` indicating if the database exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkDatabaseExist() async {
    final result = AcResult();
    try {
      _initSqlite();
      final path = sqlConnection.database;
      final exists = await databaseExists(path);
      result.setSuccess(
        value: exists,
        message: exists ? 'Database exists' : 'Database does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Checks if a specific table exists in the database.",
    "description": "This SQLite implementation queries the `sqlite_master` table.",
    "params": [{"name": "tableName", "description": "The name of the table to check."}],
    "returns": "An `AcResult` with a boolean `value` indicating if the table exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkTableExist({required String tableName}) async {
    final result = AcResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final statement = "SELECT name FROM sqlite_master WHERE type='table' AND name=?";
        bool exists = false;
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement, [tableName]);
          exists = results.isNotEmpty;
        }
        else{
          final results = await db.rawQuery(statement, [tableName]);
          exists = results.isNotEmpty;
        }
        result.setSuccess(
          value: exists,
          message: exists ? 'Table exists' : 'Table does not exist',
        );
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates the configured database if it does not already exist.",
    "description": "This SQLite implementation opens or creates the database file.",
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> createDatabase() async {
    final result = AcResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        result.setSuccess(value: true, message: 'Database created');
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Deletes rows from a table that match a given condition.",
    "description": "This SQLite implementation executes a `DELETE FROM` statement.",
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
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final statement = "DELETE FROM $tableName ${condition.isNotEmpty ? "WHERE $condition" : ""}";
        final setParametersResult = setSqlStatementParameters(
          statement: statement,
          passedParameters: parameters,
        );
        final updatedStatement = setParametersResult['statement'];
        final updatedParameterValues =
        (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
            .values
            .toList();
        int affectedRows = 0;
        if(_transaction != null){
          affectedRows = await _transaction!.rawDelete(
            updatedStatement,
            ensureValidParamsType(params:updatedParameterValues),
          );
        }
        else{
          affectedRows = await db.rawDelete(
            updatedStatement,
            ensureValidParamsType(params:updatedParameterValues),
          );
        }
        result.affectedRowsCount = affectedRows;
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  ensureValidParamsType({required List<dynamic> params}){
    for(int i=0;i<params.length;i++){
      if(params[i] is DateTime){
        params[i] = params[i].toIso8601String();
        logger.log("Found invalid date data type");
      }
      else{
        logger.log(["Found valid data type : ${params[i].runtimeType.toString()} => ${params[i]}"]);
      }
    }
    return params;
  }

  /* AcDoc({
    "summary": "Executes multiple SQL statements within a single transaction.",
    "description": "This SQLite implementation wraps the list of statements in a transaction block to ensure atomicity.",
    "params": [
      {"name": "statements", "description": "The list of SQL statements to execute."},
      {"name": "parameters", "description": "A map of shared parameters for the statements."}
    ],
    "returns": "An `AcSqlDaoResult` indicating the overall success or failure.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> executeMultipleSqlStatements({
    required List<String> statements,
    Map<String, dynamic> parameters = const {},
  }) async {
    final result = AcSqlDaoResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        if(_transaction != null){
          for (final statement in statements) {
            final setParametersResult = setSqlStatementParameters(
              statement: statement,
              passedParameters: parameters,
            );
            final updatedStatement = setParametersResult['statement'];
            final updatedParameterValues = (setParametersResult['statementParametersMap'] as Map<String, dynamic>).values.toList();
            await _transaction!.rawQuery(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
          }
        }
        else{
          await db.transaction((txn) async {
            for (final statement in statements) {
              final setParametersResult = setSqlStatementParameters(
                statement: statement,
                passedParameters: parameters,
              );
              final updatedStatement = setParametersResult['statement'];
              final updatedParameterValues = (setParametersResult['statementParametersMap'] as Map<String, dynamic>).values.toList();
              await txn.rawQuery(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
            }
          });
        }
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  @override
  Future<AcResult> executeSqlOperations({
    required List<AcSqlOperation> operations,
  }) async {
    final result = AcSqlDaoResult();
    Database? db;

    logger.log('=== START executeSqlOperations - ${operations.length} operation(s) to execute ===');

    try {
      logger.log('Acquiring database connection...');
      db = await _getConnection();

      if (db != null) {
        logger.log('Database connection acquired successfully. Starting transaction...');

        result.value = await db.transaction((txn) async {
          List<dynamic> operationResults = List.empty(growable: true);

          logger.log('Transaction started. Processing ${operations.length} SQL operation(s)');

          for (int i = 0; i < operations.length; i++) {
            final sqlOperation = operations[i];
            logger.log('--- Processing Operation ${i + 1}/${operations.length} ---');
            logger.log('Type: ${sqlOperation.operation}');
            logger.log('Table: ${sqlOperation.table}');

            if (sqlOperation.operation == AcEnumDDRowOperation.insert) {
              var row = sqlOperation.row!;
              final columns = row.keys.toList();
              final placeholders = List.generate(columns.length, (i) => '?').join(', ');
              final statement = "INSERT INTO ${sqlOperation.table} (${columns.join(', ')}) VALUES ($placeholders)";
              final params = row.values.toList();

              logger.log('INSERT Statement: $statement');
              logger.log('INSERT Parameters: $params');
              logger.log('INSERT Columns: ${columns.join(', ')}');

              try {
                final insertedId = await txn.rawInsert(statement, ensureValidParamsType(params: params));
                operationResults.add(insertedId);
                logger.log('INSERT SUCCESS - Rows affected / Inserted ID: $insertedId');
              } catch (insertEx) {
                logger.log('INSERT FAILED - Exception: $insertEx');
                rethrow;
              }
            }

            else if (sqlOperation.operation == AcEnumDDRowOperation.update) {
              var row = sqlOperation.row!;
              final setValues = row.keys.map((key) => "$key = ?").join(", ");
              final conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty
                  ? "WHERE ${sqlOperation.condition}"
                  : "";
              final statement = "UPDATE ${sqlOperation.table} SET $setValues $conditionClause";
              final params = [...row.values, ...(sqlOperation.parameters?.values ?? [])];

              logger.log('UPDATE Statement: $statement');
              logger.log('UPDATE Set Values: $setValues');
              if (conditionClause.isNotEmpty) {
                logger.log('UPDATE Condition: ${sqlOperation.condition}');
                logger.log('UPDATE Condition Parameters: ${sqlOperation.parameters}');
              }
              logger.log('UPDATE Parameters (combined): $params');

              try {
                final updatedCount = await txn.rawUpdate(statement, ensureValidParamsType(params: params));
                operationResults.add(updatedCount);
                logger.log('UPDATE SUCCESS - Rows affected: $updatedCount');
              } catch (updateEx) {
                logger.log('UPDATE FAILED - Exception: $updateEx');
                rethrow;
              }
            }

            else if (sqlOperation.operation == AcEnumDDRowOperation.delete) {
              final conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty
                  ? "WHERE ${sqlOperation.condition}"
                  : "";
              final baseStatement = "DELETE FROM ${sqlOperation.table} $conditionClause";

              final setParametersResult = setSqlStatementParameters(
                statement: baseStatement,
                passedParameters: sqlOperation.parameters ?? {},
              );
              final updatedStatement = setParametersResult['statement'] as String;
              final parameterMap = setParametersResult['statementParametersMap'] as Map<String, dynamic>;
              final updatedParameterValues = parameterMap.values.toList();

              logger.log('DELETE Base Statement: $baseStatement');
              logger.log('DELETE Final Statement: $updatedStatement');
              logger.log('DELETE Parameters: $updatedParameterValues');

              try {
                final deletedCount = await txn.rawDelete(
                  updatedStatement,
                  ensureValidParamsType(params: updatedParameterValues),
                );
                operationResults.add(deletedCount);
                logger.log('DELETE SUCCESS - Rows deleted: $deletedCount');
              } catch (deleteEx) {
                logger.log('DELETE FAILED - Exception: $deleteEx');
                rethrow;
              }
            }

            else {
              logger.log('UNKNOWN/UNSUPPORTED Operation Type: ${sqlOperation.operation} - Skipping');
              operationResults.add(null);
            }

            logger.log('--- End Operation ${i + 1} ---\n');
          }

          logger.log('All ${operations.length} operations processed. Committing transaction...');
          return operationResults;
        });

        logger.log('Transaction committed successfully');
        result.setSuccess();
        logger.log('executeSqlOperations COMPLETED SUCCESSFULLY');
      } else {
        logger.log('FAILED: Could not acquire database connection');
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      logger.log('EXCEPTION during executeSqlOperations: $ex');
      logger.log('Stack trace: $stack');
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (db != null &&
          sqlConnection.database != inMemoryDatabasePath &&
          autoCloseAfterExecution) {
        logger.log('Closing database connection (autoCloseAfterExecution = true)');
        await db.close();
        logger.log('Database connection closed');
      } else if (db != null) {
        logger.log('Keeping database connection open (in-memory or autoClose disabled)');
      }
    }

    logger.log('=== END executeSqlOperations ===');
    return result;
  }

  /* AcDoc({
    "summary": "Executes a single, parameterized SQL statement.",
    "params": [
      {"name": "statement", "description": "The SQL statement to execute."},
      {"name": "operation", "description": "The type of operation, for result metadata."},
      {"name": "parameters", "description": "A map of parameters."}
    ],
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
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final setParametersResult = setSqlStatementParameters(
          statement: statement,
          passedParameters: parameters,
        );
        final updatedStatement = setParametersResult['statement'];
        final updatedParameterValues =
        (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
            .values
            .toList();
        if(_transaction != null){
          await _transaction!.execute(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
        }
        else{
          await db.execute(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
        }
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Applies formatting rules to a single data row.",
    "description": "This implementation can decrypt encrypted strings, decode JSON strings, and hide specified columns from the final result set.",
    "params": [
      {"name": "row", "description": "The raw data row map."},
      {"name": "columnFormats", "description": "A map defining formatting rules for columns."}
    ],
    "returns": "The transformed data row.",
    "returns_type": "Map<String, dynamic>"
  }) */
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

  /* AcDoc({
    "summary": "Gets the underlying `Database` object.",
    "params": [
      {"name": "includeDatabase", "description": "If true, connects to a specific database. If false, connects to an in-memory database."}
    ],
    "returns": "A future that completes with the raw `Database` object, or null on error.",
    "returns_type": "Future<Database?>"
  }) */
  @override
  Future<Database?> getConnectionObject({
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

  /* AcDoc({
    "summary": "Retrieves a list of all functions from the database schema.",
    "description": "This SQLite implementation notes that user-defined functions are not supported in standard SQLite.",
    "returns": "An `AcSqlDaoResult` with an empty `rows` list, as SQLite does not support user-defined functions by default.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    final result = AcSqlDaoResult();
    result.setSuccess(
      message: 'SQLite does not support user-defined functions by default.',
    );
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all stored procedures from the database schema.",
    "description": "This SQLite implementation notes that stored procedures are not supported in SQLite.",
    "returns": "An `AcSqlDaoResult` with an empty `rows` list, as SQLite does not support stored procedures.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    final result = AcSqlDaoResult();
    result.setSuccess(
      message: 'SQLite does not support stored procedures.',
    );
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all tables from the database schema.",
    "description": "This SQLite implementation queries the `sqlite_master` table for base tables.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with table data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseTables() async {
    final result = AcSqlDaoResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        const statement = "SELECT name AS TABLE_NAME FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'";
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDTable.keyTableName: row['TABLE_NAME'],
            });
          }
        }
        else{
          final results = await db.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDTable.keyTableName: row['TABLE_NAME'],
            });
          }
        }
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all triggers from the database schema.",
    "description": "This SQLite implementation queries the `sqlite_master` table for triggers.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with trigger data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    final result = AcSqlDaoResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        const statement = "SELECT name AS TRIGGER_NAME FROM sqlite_master WHERE type='trigger'";
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDTrigger.keyTriggerName: row['TRIGGER_NAME'],
            });
          }
        }
        else{
          final results = await db.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDTrigger.keyTriggerName: row['TRIGGER_NAME'],
            });
          }
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all views from the database schema.",
    "description": "This SQLite implementation queries the `sqlite_master` table for views.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with view data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseViews() async {
    final result = AcSqlDaoResult();
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        const statement =
            "SELECT name AS TABLE_NAME FROM sqlite_master WHERE type='view'";
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDView.keyViewName: row['TABLE_NAME'],
            });
          }
        }
        else{
          final results = await db.rawQuery(statement);
          for (final row in results) {
            result.rows.add({
              AcDDView.keyViewName: row['TABLE_NAME'],
            });
          }
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes a SELECT statement and retrieves rows.",
    "description": "This SQLite implementation builds and executes a SELECT query, handling different modes like fetching a list of rows or counting the total number of matching records.",
    "params": [
      {"name": "statement", "description": "The base SELECT statement to execute."},
      {"name": "condition", "description": "An optional WHERE clause to append."},
      {"name": "parameters", "description": "A map of parameters for substitution."},
      {"name": "mode", "description": "The desired format for the returned data (e.g., `list`, `count`)."},
      {"name": "columnFormats", "description": "Formatting rules to apply to the result columns."}
    ],
    "returns": "An `AcSqlDaoResult` containing the fetched rows or the total count.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getRows({
    required String statement,
    String condition = "",
    Map<String, dynamic> parameters = const {},
    AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
    Map<String, List<AcEnumDDColumnFormat>> columnFormats = const {},
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        String updatedStatement = statement;
        if (condition.isNotEmpty) {
          updatedStatement += " WHERE $condition";
        }
        final setParametersResult = setSqlStatementParameters(
          statement: updatedStatement,
          passedParameters: parameters,
        );
        updatedStatement = setParametersResult['statement'] as String;
        final updatedParameterValues =
        (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
            .values
            .toList();
        if (mode == AcEnumDDSelectMode.count) {
          updatedStatement = "SELECT COUNT(*) AS records_count FROM ($updatedStatement) AS records_list";
        }
        logger.log(["Select statement",updatedStatement,"parameters",updatedParameterValues]);
        if(_transaction != null){
          final results = await _transaction!.rawQuery(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
          if (mode == AcEnumDDSelectMode.count) {
            result.totalRows = results.first['records_count'] as int;
          } else {
            result.rows = results.map((row) => formatRow(
              row: Map<String, dynamic>.from(row),
              columnFormats: columnFormats,
            )).toList();
          }
        }
        else{
          final results = await db.rawQuery(updatedStatement, ensureValidParamsType(params: updatedParameterValues));
          if (mode == AcEnumDDSelectMode.count) {
            result.totalRows = results.first['records_count'] as int;
          } else {
            logger.log(["Total rows",results.length]);
            result.rows = results.map((row) => formatRow(
              row: Map<String, dynamic>.from(row),
              columnFormats: columnFormats,
            )).toList();
          }
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a table.",
    "description": "This SQLite implementation uses `PRAGMA table_info` to get column metadata.",
    "params": [{"name": "tableName", "description": "The name of the table to inspect."}],
    "returns": "An `AcSqlDaoResult` with `rows` populated with column schema data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final statement = "PRAGMA table_info($tableName)";
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement);
          for (final row in results) {
            final properties = <String, dynamic>{};
            if (row['notnull'] == 1) {
              properties[AcEnumDDColumnProperty.notNull.value] = false;
            }
            if (row['pk'] == 1) {
              properties[AcEnumDDColumnProperty.primaryKey.value] = true;
            }
            if (row['dflt_value'] != null) {
              properties[AcEnumDDColumnProperty.defaultValue.value] =
              row['dflt_value'];
            }
            result.rows.add({
              AcDDTableColumn.keyColumnName: row['name'],
              AcDDTableColumn.keyColumnType: row['type'],
              AcDDTableColumn.keyColumnProperties: properties,
            });
          }
        }
        else{
          final results = await db.rawQuery(statement);
          for (final row in results) {
            final properties = <String, dynamic>{};
            if (row['notnull'] == 1) {
              properties[AcEnumDDColumnProperty.notNull.value] = false;
            }
            if (row['pk'] == 1) {
              properties[AcEnumDDColumnProperty.primaryKey.value] = true;
            }
            if (row['dflt_value'] != null) {
              properties[AcEnumDDColumnProperty.defaultValue.value] =
              row['dflt_value'];
            }
            result.rows.add({
              AcDDTableColumn.keyColumnName: row['name'],
              AcDDTableColumn.keyColumnType: row['type'],
              AcDDTableColumn.keyColumnProperties: properties,
            });
          }
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a view.",
    "description": "This SQLite implementation uses `PRAGMA table_info` on the view.",
    "params": [{"name": "viewName", "description": "The name of the view to inspect."}],
    "returns": "An `AcSqlDaoResult` with `rows` populated with view column schema data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final statement = "PRAGMA table_info($viewName)";
        if(_transaction != null){
          final results = await _transaction!.rawQuery(statement);
          for (final row in results) {
            final properties = <String, dynamic>{};
            if (row['notnull'] == 1) {
              properties[AcEnumDDColumnProperty.notNull.value] = false;
            }
            if (row['pk'] == 1) {
              properties[AcEnumDDColumnProperty.primaryKey.value] = true;
            }
            if (row['dflt_value'] != null) {
              properties[AcEnumDDColumnProperty.defaultValue.value] =
              row['dflt_value'];
            }
            result.rows.add({
              AcDDViewColumn.keyColumnName: row['name'],
              AcDDViewColumn.keyColumnType: row['type'],
              AcDDViewColumn.keyColumnProperties: properties,
            });
          }
        }
        else{
          final results = await db.rawQuery(statement);
          for (final row in results) {
            final properties = <String, dynamic>{};
            if (row['notnull'] == 1) {
              properties[AcEnumDDColumnProperty.notNull.value] = false;
            }
            if (row['pk'] == 1) {
              properties[AcEnumDDColumnProperty.primaryKey.value] = true;
            }
            if (row['dflt_value'] != null) {
              properties[AcEnumDDColumnProperty.defaultValue.value] =
              row['dflt_value'];
            }
            result.rows.add({
              AcDDViewColumn.keyColumnName: row['name'],
              AcDDViewColumn.keyColumnType: row['type'],
              AcDDViewColumn.keyColumnProperties: properties,
            });
          }
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Inserts a single row into a table.",
    "description": "This SQLite implementation constructs and executes an `INSERT INTO` statement and returns the last inserted ID.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "row", "description": "A map representing the row to insert."}
    ],
    "returns": "An `AcSqlDaoResult` containing the `lastInsertedId`.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> insertRow({
    required String tableName,
    required Map<String, dynamic> row,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final columns = row.keys.toList();
        final placeholders = List.generate(columns.length, (i) => '?').join(', ');
        final statement =
            "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
        final params = row.values.toList();
        var lastInsertedId = 0;
        if(_transaction != null){
          lastInsertedId = await _transaction!.rawInsert(statement, ensureValidParamsType(params: params));
        }
        else{
          lastInsertedId = await db.rawInsert(statement, ensureValidParamsType(params: params));
        }
        result.lastInsertedId = lastInsertedId;
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Inserts multiple rows into a table within a single transaction.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "rows", "description": "A list of maps, where each map is a row to insert."}
    ],
    "returns": "An `AcSqlDaoResult` indicating the overall success or failure.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> insertRows({
    required String tableName,
    required List<Map<String, dynamic>> rows,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        if (rows.isNotEmpty) {
          if(_transaction != null){
            for (final rowData in rows) {
              final columns = rowData.keys.toList();
              final placeholders = List.generate(columns.length, (i) => '?').join(', ');
              final statement =
                  "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
              final params = rowData.values.toList();
              await _transaction!.rawInsert(statement, ensureValidParamsType(params: params));
            }
          }
          else{
            await db.transaction((txn) async {
              for (final rowData in rows) {
                final columns = rowData.keys.toList();
                final placeholders = List.generate(columns.length, (i) => '?').join(', ');
                final statement =
                    "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
                final params = rowData.values.toList();
                await txn.rawInsert(statement, ensureValidParamsType(params: params));
              }
            });
          }
          result.setSuccess();
        } else {
          result.setSuccess(value: true, message: 'No rows to insert.');
        }
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  Future<AcResult> transactionCommit() async{
    AcResult result = AcResult();
    try {
      if(_transaction != null) {
        _transaction = null;
        result.setSuccess();
      }
      else{
        result.setSuccess(message: 'Transaction not started');
      }
    }
    catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  Future<AcResult> transactionRollback() async{
    AcResult result = AcResult();
    try {
      if(_transaction != null) {
        _transaction = null;
        result.setSuccess();
      }
      else{
        result.setSuccess(message: 'Transaction not started');
      }
    }
    catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  Future<AcResult> transactionStart() async{
    AcResult result = AcResult();
   Database? db;
    try {
      if(_transaction == null) {
        db = await _getConnection();
        if (db != null) {
          db.transaction((Transaction trns) async{
            try {
              _transaction = trns;
              while (_transaction != null) {
                await Future.delayed(Duration(milliseconds: 100));
              }
              if (_transactionRollback) {
                _transactionRollback = false;
                throw Error();
              }
            }
            catch(ex){

            }
          },exclusive: false);
          result.setSuccess();
        }
        else {
          result.setFailure(message: 'Error connecting database');
        }
      }
      else{
        result.setSuccess(message: 'Transaction already started');
      }
    }
    catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Updates rows in a table that match a given condition.",
    "params": [
      {"name": "tableName", "description": "The name of the table to update."},
      {"name": "row", "description": "A map of column names to their new values."},
      {"name": "condition", "description": "The WHERE clause to identify rows to update."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."}
    ],
    "returns": "An `AcSqlDaoResult` containing the number of affected rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> updateRow({
    required String tableName,
    required Map<String, dynamic> row,
    String condition = "",
    Map<String, dynamic> parameters = const {},
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        final setValues = row.keys.map((key) => "$key = ?").join(", ");
        final statement =
            "UPDATE $tableName SET $setValues ${condition.isNotEmpty ? "WHERE $condition" : ""}";
        final params = [...row.values, ...parameters.values];
        var affectedRows = 0;
        if(_transaction != null){
          affectedRows = await _transaction!.rawUpdate(statement, ensureValidParamsType(params: params));
        }
        else{
          affectedRows = await db.rawUpdate(statement, ensureValidParamsType(params: params));
        }
        result.affectedRowsCount = affectedRows;
        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Updates multiple rows in a single transaction, each with its own condition.",
    "params": [
      {"name": "tableName", "description": "The name of the table to update."},
      {"name": "rowsWithConditions", "description": "A list of maps, where each map must contain 'row', 'condition', and optional 'parameters'."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the total number of affected rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> updateRows({
    required String tableName,
    required List<Map<String, dynamic>> rowsWithConditions,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
   Database? db;
    try {
      db = await _getConnection();
      if(db != null){
        if(_transaction != null){
          for (final rowWithCondition in rowsWithConditions) {
            if (rowWithCondition.containsKey('row') &&
                rowWithCondition.containsKey('condition')) {
              final row = rowWithCondition['row'] as Map<String, dynamic>;
              final condition = rowWithCondition['condition'] as String;
              final conditionParameters =
              rowWithCondition.containsKey('parameters')
                  ? rowWithCondition['parameters'] as Map<String, dynamic>
                  : <String, dynamic>{};
              final setValues = row.keys.map((key) => "$key = ?").join(", ");
              final statement =
                  "UPDATE $tableName SET $setValues WHERE $condition";
              final params = [...row.values, ...conditionParameters.values];
              final affectedRows = await _transaction!.rawUpdate(statement, ensureValidParamsType(params: params));
              result.affectedRowsCount ??= 0;
              result.affectedRowsCount = (result.affectedRowsCount! + affectedRows) as int?;
            }
          }
        }
        else{
          await db.transaction((txn) async {
            for (final rowWithCondition in rowsWithConditions) {
              if (rowWithCondition.containsKey('row') &&
                  rowWithCondition.containsKey('condition')) {
                final row = rowWithCondition['row'] as Map<String, dynamic>;
                final condition = rowWithCondition['condition'] as String;
                final conditionParameters =
                rowWithCondition.containsKey('parameters')
                    ? rowWithCondition['parameters'] as Map<String, dynamic>
                    : <String, dynamic>{};
                final setValues = row.keys.map((key) => "$key = ?").join(", ");
                final statement =
                    "UPDATE $tableName SET $setValues WHERE $condition";
                final params = [...row.values, ...conditionParameters.values];
                final affectedRows = await txn.rawUpdate(statement, ensureValidParamsType(params: params));
                result.affectedRowsCount ??= 0;
                result.affectedRowsCount = (result.affectedRowsCount! + affectedRows) as int?;
              }
            }
          });
        }

        result.setSuccess();
      }
      else{
        result.setFailure(message: 'Error connecting database');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath && autoCloseAfterExecution) {
        await db?.close();
      }
    }
    return result;
  }
}