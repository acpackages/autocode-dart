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
  Database? _database;
  static bool _platformResolved = false;

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
  Future<Database> _getConnection() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    final databasePath = sqlConnection.database;
    _initSqlite();
    _database = await openDatabase(databasePath);
    return _database!;
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
      final statement =
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?";
      final results = await db.rawQuery(statement, [tableName]);
      final exists = results.isNotEmpty;
      result.setSuccess(
        value: exists,
        message: exists ? 'Table exists' : 'Table does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      result.setSuccess(value: true, message: 'Database created');
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      final statement =
          "DELETE FROM $tableName ${condition.isNotEmpty ? "WHERE $condition" : ""}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
      (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
          .values
          .toList();
      final affectedRows = await db.rawDelete(
        updatedStatement,
        updatedParameterValues,
      );
      result.affectedRowsCount = affectedRows;
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
        await db?.close();
      }
    }
    return result;
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
      await db.transaction((txn) async {
        for (final statement in statements) {
          final setParametersResult = setSqlStatementParameters(
            statement: statement,
            passedParameters: parameters,
          );
          final updatedStatement = setParametersResult['statement'];
          final updatedParameterValues =
          (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
              .values
              .toList();
          await txn.rawQuery(updatedStatement, updatedParameterValues);
        }
      });
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
        await db?.close();
      }
    }
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
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
      (setParametersResult['statementParametersMap'] as Map<String, dynamic>)
          .values
          .toList();
      await db.execute(updatedStatement, updatedParameterValues);
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      const statement =
          "SELECT name AS TABLE_NAME FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'";
      final results = await db.rawQuery(statement);
      for (final row in results) {
        result.rows.add({
          AcDDTable.keyTableName: row['TABLE_NAME'],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      const statement =
          "SELECT name AS TRIGGER_NAME FROM sqlite_master WHERE type='trigger'";
      final results = await db.rawQuery(statement);
      for (final row in results) {
        result.rows.add({
          AcDDTrigger.keyTriggerName: row['TRIGGER_NAME'],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      const statement =
          "SELECT name AS TABLE_NAME FROM sqlite_master WHERE type='view'";
      final results = await db.rawQuery(statement);
      for (final row in results) {
        result.rows.add({
          AcDDView.keyViewName: row['TABLE_NAME'],
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      if (mode == AcEnumDDSelectMode.count) {
        statement =
        "SELECT COUNT(*) AS records_count FROM ($statement) AS records_list";
      }
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
      final results = await db.rawQuery(updatedStatement, updatedParameterValues);
      if (mode == AcEnumDDSelectMode.count) {
        result.totalRows = results.first['records_count'] as int;
      } else {
        result.rows = results.map((row) => formatRow(
          row: Map<String, dynamic>.from(row),
          columnFormats: columnFormats,
        )).toList();
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      final statement = "PRAGMA table_info($tableName)";
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
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      final statement = "PRAGMA table_info($viewName)";
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
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      final columns = row.keys.toList();
      final placeholders = List.generate(columns.length, (i) => '?').join(', ');
      final statement =
          "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
      final params = row.values.toList();
      final lastInsertId = await db.rawInsert(statement, params);
      result.lastInsertedId = lastInsertId;
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
      if (rows.isNotEmpty) {
        final columns = rows.first.keys.toList();
        final placeholders = List.generate(columns.length, (i) => '?').join(', ');
        final statement =
            "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
        await db.transaction((txn) async {
          for (final rowData in rows) {
            final params = rowData.values.toList();
            await txn.rawInsert(statement, params);
          }
        });
        result.setSuccess();
      } else {
        result.setSuccess(value: true, message: 'No rows to insert.');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
        await db?.close();
      }
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
      final setValues = row.keys.map((key) => "$key = ?").join(", ");
      final statement =
          "UPDATE $tableName SET $setValues ${condition.isNotEmpty ? "WHERE $condition" : ""}";
      final params = [...row.values, ...parameters.values];
      final affectedRows = await db.rawUpdate(statement, params);
      result.affectedRowsCount = affectedRows;
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
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
            final affectedRows = await txn.rawUpdate(statement, params);
            result.affectedRowsCount ??= 0;
            result.affectedRowsCount = result.affectedRowsCount! + affectedRows;
          }
        }
      });
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      if (sqlConnection.database != inMemoryDatabasePath) {
        await db?.close();
      }
    }
    return result;
  }
}