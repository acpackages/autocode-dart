import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'dart:convert';
import 'package:mysql_dart/mysql_client.dart';

/* AcDoc({
  "summary": "A Data Access Object (DAO) for interacting with a MySQL or MariaDB database.",
  "description": "This class provides a concrete implementation of `AcBaseSqlDao` using the `mysql_dart` package. It handles MySQL-specific connection management, query execution, parameter substitution, transaction control, and result parsing.",
  "example": "final mysqlConfig = AcSqlConnection(\n  hostname: '127.0.0.1',\n  port: 3306,\n  username: 'root',\n  password: 'password',\n  database: 'my_app'\n);\n\nfinal dao = AcMysqlDao();\nawait dao.setSqlConnection(sqlConnection: mysqlConfig);\n\nfinal result = await dao.getRows(statement: 'SELECT * FROM users');\nprint(result.rows);"
}) */
class AcMysqlDao extends AcBaseSqlDao {
  /* AcDoc({"summary": "Creates and opens a new MySQL connection to the specified database."}) */
  Future<MySQLConnection> _getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: sqlConnection.hostname,
      port: sqlConnection.port,
      userName: sqlConnection.username, // Changed to userName
      password: sqlConnection.password,
      databaseName: sqlConnection.database,
      secure: false,
    );
    await conn.connect();
    return conn;
  }

  /* AcDoc({"summary": "Creates and opens a new MySQL connection without specifying a database."}) */
  Future<MySQLConnection> _getConnectionWithoutDatabase() async {
    final conn = await MySQLConnection.createConnection(
      host: sqlConnection.hostname,
      port: sqlConnection.port,
      userName: sqlConnection.username, // Changed to userName
      password: sqlConnection.password,
      secure: false,
    );
    await conn.connect();
    return conn;
  }

  /* AcDoc({
    "summary": "Checks if the configured database exists on the server.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.SCHEMATA` view to verify the database's existence.",
    "returns": "An `AcResult` with a boolean `value` indicating if the database exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkDatabaseExist() async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      const statement =
          "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {"@databaseName": sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      final exists = results.rows.isNotEmpty;
      result.setSuccess(
        value: exists,
        message: exists ? 'Database exists' : 'Database does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Checks if a specific table exists in the database.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.TABLES` view.",
    "params": [{"name": "tableName", "description": "The name of the table to check."}],
    "returns": "An `AcResult` with a boolean `value` indicating if the table exists.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> checkTableExist({required String tableName}) async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @databaseName AND TABLE_NAME = @tableName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {
          "@databaseName": sqlConnection.database,
          '@tableName': tableName,
        },
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      final exists = results.rows.isNotEmpty;
      result.setSuccess(
        value: exists,
        message: exists ? 'Table exists' : 'Table does not exist',
      );
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates the configured database if it does not already exist.",
    "description": "This MySQL implementation executes a `CREATE DATABASE IF NOT EXISTS` statement.",
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  @override
  Future<AcResult> createDatabase() async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      final statement =
          "CREATE DATABASE IF NOT EXISTS ${sqlConnection.database}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {"@databaseName": sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      await db.execute(statement);
      result.setSuccess(value: true, message: 'Database created');
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Deletes rows from a table that match a given condition.",
    "description": "This MySQL implementation executes a `DELETE FROM` statement.",
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
    MySQLConnection? db;
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
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      result.affectedRowsCount = results.affectedRows.toInt();
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes multiple SQL statements within a single transaction.",
    "description": "This MySQL implementation wraps the list of statements in a transaction block to ensure atomicity.",
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      await db.transactional((txn) async {
        for (final statement in statements) {
          final setParametersResult = setSqlStatementParameters(
            statement: statement,
            passedParameters: parameters,
          );
          final updatedStatement = setParametersResult['statement'];
          final updatedParameterValues =
              setParametersResult['statementParametersMap'];
          await txn.execute(updatedStatement, updatedParameterValues);
        }
      });
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      await db.execute(updatedStatement, updatedParameterValues);
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
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
    "summary": "Gets the underlying `MySQLConnection` object.",
    "params": [
      {"name": "includeDatabase", "description": "If true, connects to a specific database. If false, connects to the server without selecting a database."}
    ],
    "returns": "A future that completes with the raw `MySQLConnection` object, or null on error.",
    "returns_type": "Future<MySQLConnection?>"
  }) */
  @override
  Future<MySQLConnection?> getConnectionObject({
    bool includeDatabase = true,
  }) async {
    if (includeDatabase) {
      return await _getConnection();
    } else {
      return await _getConnectionWithoutDatabase();
    }
  }

  /* AcDoc({
    "summary": "Retrieves a list of all functions from the database schema.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.ROUTINES` view for functions.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with function data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT ROUTINE_NAME, DATA_TYPE, CREATED, DEFINER FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @databaseName AND ROUTINE_TYPE = 'FUNCTION'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        result.rows.add({
          AcDDFunction.keyFunctionName: row.colByName('ROUTINE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all stored procedures from the database schema.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.ROUTINES` view for procedures.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with stored procedure data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT ROUTINE_NAME, CREATED, DEFINER FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @databaseName AND ROUTINE_TYPE = 'PROCEDURE'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        result.rows.add({
          AcDDStoredProcedure.keyStoredProcedureName: row.colByName(
            'ROUTINE_NAME',
          ),
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all tables from the database schema.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.TABLES` view for base tables.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with table data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseTables() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @databaseName AND TABLE_TYPE='BASE TABLE'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        result.rows.add({
          AcDDTable.keyTableName: row.colByName('TABLE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all triggers from the database schema.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.TRIGGERS` view.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with trigger data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_STATEMENT, ACTION_TIMING FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        result.rows.add({
          AcDDTrigger.keyTriggerName: row.colByName('TRIGGER_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of all views from the database schema.",
    "description": "This MySQL implementation queries the `INFORMATION_SCHEMA.VIEWS` view.",
    "returns": "An `AcSqlDaoResult` with its `rows` property populated with view data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getDatabaseViews() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement =
          "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        result.rows.add({AcDDView.keyViewName: row.colByName('TABLE_NAME')});
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes a SELECT statement and retrieves rows.",
    "description": "This MySQL implementation builds and executes a SELECT query, handling different modes like fetching a list of rows or counting the total number of matching records.",
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
    MySQLConnection? db;
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
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      if (mode == AcEnumDDSelectMode.count) {
        Map<String, dynamic> row = results.rows.first.assoc();
        result.totalRows = row['records_count'];
      } else {
        result.rows =
            results.rows
                .map(
                  (row) => formatRow(
                    row: row.typedAssoc(),
                    columnFormats: columnFormats,
                  ),
                )
                .toList();
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a table.",
    "description": "This MySQL implementation executes the `DESCRIBE` command to get column metadata.",
    "params": [{"name": "tableName", "description": "The name of the table to inspect."}],
    "returns": "An `AcSqlDaoResult` with `rows` populated with column schema data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "DESCRIBE `@tableName`";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@tableName': tableName},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        final properties = <String, dynamic>{};
        if (row.colByName('Null') != "YES") {
          properties[AcEnumDDColumnProperty.notNull.value] = false;
        }
        if (row.colByName('Key') == "PRI") {
          properties[AcEnumDDColumnProperty.primaryKey.value] = true;
        }
        if (row.colByName('Default') != null) {
          properties[AcEnumDDColumnProperty.defaultValue.value] = row.colByName(
            'Default',
          );
        }
        result.rows.add({
          AcDDTableColumn.keyColumnName: row.colByName('Field'),
          AcDDTableColumn.keyColumnType: row.colByName('Type'),
          AcDDTableColumn.keyColumnProperties: properties,
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves schema information for all columns in a view.",
    "description": "This MySQL implementation executes the `DESCRIBE` command on the view.",
    "params": [{"name": "viewName", "description": "The name of the view to inspect."}],
    "returns": "An `AcSqlDaoResult` with `rows` populated with view column schema data.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  @override
  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "DESCRIBE `@viewName`";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@viewName': viewName},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final results = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      for (final row in results.rows) {
        final properties = <String, dynamic>{};
        if (row.colByName('Null') != "YES") {
          properties[AcEnumDDColumnProperty.notNull.value] = false;
        }
        if (row.colByName('Key') == "PRI") {
          properties[AcEnumDDColumnProperty.primaryKey.value] = true;
        }
        if (row.colByName('Default') != null) {
          properties[AcEnumDDColumnProperty.defaultValue.value] = row.colByName(
            'Default',
          );
        }
        result.rows.add({
          AcDDViewColumn.keyColumnName: row.colByName('Field'),
          AcDDViewColumn.keyColumnType: row.colByName('Type'),
          AcDDViewColumn.keyColumnProperties: properties,
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  /* AcDoc({
    "summary": "Inserts a single row into a table.",
    "description": "This MySQL implementation constructs and executes an `INSERT INTO` statement and returns the last inserted ID.",
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final columns = row.keys.toList();
      final placeholders = List.generate(
        columns.length,
        (i) => '@p$i',
      ).join(', ');
      final statement =
          "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
      final params = <String, dynamic>{};
      for (var i = 0; i < columns.length; i++) {
        params['@p$i'] = row[columns[i]];
      }
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: params,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final insertResult = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      result.lastInsertedId = insertResult.lastInsertID.toInt();
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      if (rows.isNotEmpty) {
        final columns = rows.first.keys.toList();
        final placeholders = List.generate(
          columns.length,
          (i) => '@p$i',
        ).join(', ');
        final statement =
            "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
        await db.transactional((txn) async {
          for (final rowData in rows) {
            final params = <String, dynamic>{};
            for (var i = 0; i < columns.length; i++) {
              params['@p$i'] = rowData[columns[i]];
            }
            List<dynamic> parameterValues = List<dynamic>.empty(growable: true);
            final setParametersResult = setSqlStatementParameters(
              statement: statement,
              passedParameters: params,
            );
            final updatedStatement = setParametersResult['statement'];
            final updatedParameterValues =
                setParametersResult['statementParametersMap'];
            await txn.execute(updatedStatement, updatedParameterValues);
          }
        });
        result.setSuccess();
      } else {
        result.setSuccess(value: true, message: 'No rows to insert.');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final setValues = row.keys.map((key) => "$key = @$key").join(", ");
      final statement =
          "UPDATE $tableName SET $setValues ${condition.isNotEmpty ? "WHERE $condition" : ""}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {...row, ...parameters},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues =
          setParametersResult['statementParametersMap'];
      final updateResult = await db.execute(
        updatedStatement,
        updatedParameterValues,
      );
      result.affectedRowsCount = updateResult.affectedRows.toInt();
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
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
    MySQLConnection? db;
    try {
      db = await _getConnection();
      await db.transactional((txn) async {
        for (final rowWithCondition in rowsWithConditions) {
          if (rowWithCondition.containsKey('row') &&
              rowWithCondition.containsKey('condition')) {
            final row = rowWithCondition['row'] as Map<String, dynamic>;
            final condition = rowWithCondition['condition'] as String;
            final conditionParameters =
                rowWithCondition.containsKey('parameters')
                    ? rowWithCondition['parameters'] as Map<String, dynamic>
                    : <String, dynamic>{};

            final setValues = row.keys
                .map((key) => "$key = @row_$key")
                .join(", ");
            final statement =
                "UPDATE $tableName SET $setValues WHERE $condition";
            final params = <String, dynamic>{};
            row.forEach((key, value) {
              params['@row_$key'] = value;
            });
            final setParametersResult = setSqlStatementParameters(
              statement: statement,
              passedParameters: {...params, ...conditionParameters},
            );
            final updatedStatement = setParametersResult['statement'];
            final updatedParameterValues =
                setParametersResult['statementParametersMap'];
            final updateResult = await txn.execute(
              updatedStatement,
              updatedParameterValues,
            );
            result.affectedRowsCount ??= 0;
            result.affectedRowsCount =
                result.affectedRowsCount! + updateResult.affectedRows.toInt();
          }
        }
      });
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }
}
