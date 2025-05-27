import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'dart:convert';
import 'package:mysql_dart/mysql_client.dart';

class AcMysqlDao extends AcBaseSqlDao {

  Future<MySQLConnection> _getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: sqlConnection.hostname,
      port: sqlConnection.port,
      userName: sqlConnection.username, // Changed to userName
      password: sqlConnection.password,
      databaseName: sqlConnection.database,
      secure: false
    );
    await conn.connect();
    return conn;
  }

  Future<MySQLConnection> _getConnectionWithoutDatabase() async {
    final conn = await MySQLConnection.createConnection(
      host: sqlConnection.hostname,
      port: sqlConnection.port,
      userName: sqlConnection.username, // Changed to userName
      password: sqlConnection.password,
      secure: false
    );
    await conn.connect();
    return conn;
  }

  @override
  Future<AcResult> checkDatabaseExist() async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      const statement = "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {"@databaseName": sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      final exists = results.rows.isNotEmpty;
      result.setSuccess(value:exists, message: exists ? 'Database exists' : 'Database does not exist');
    } catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcResult> checkTableExist({required String tableName}) async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @databaseName AND TABLE_NAME = @tableName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {"@databaseName": sqlConnection.database, '@tableName': tableName},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      final exists = results.rows.isNotEmpty;
      result.setSuccess(value:exists, message: exists ? 'Table exists' : 'Table does not exist');
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcResult> createDatabase() async {
    final result = AcResult();
    MySQLConnection? db;
    try {
      db = await _getConnectionWithoutDatabase();
      final statement = "CREATE DATABASE IF NOT EXISTS ${sqlConnection.database}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {"@databaseName": sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      await db.execute(statement);
      result.setSuccess(value:true, message: 'Database created');
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> deleteRows({required String tableName, String condition = "", Map<String, dynamic> parameters = const {}}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.DELETE);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final statement = "DELETE FROM $tableName ${condition.isNotEmpty ? "WHERE $condition" : ""}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      result.affectedRowsCount = results.affectedRows.toInt();
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> executeMultipleSqlStatements({required List<String> statements, Map<String, dynamic> parameters = const {}}) async {
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
          final updatedParameterValues = setParametersResult['statementParametersMap'];
          await txn.execute(updatedStatement, updatedParameterValues);
        }
      });
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception:ex, stackTrace:stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> executeStatement({required String statement, String? operation = AcEnumDDRowOperation.UNKNOWN, Map<String, dynamic> parameters = const {}}) async {
    final result = AcSqlDaoResult(operation: operation);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: parameters,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      await db.execute(updatedStatement, updatedParameterValues);
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception:ex, stackTrace:stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Map<String, dynamic> formatRow({required Map<String, dynamic> row, Map<String, List<String>> columnFormats = const {}}) {
    final formattedRow = Map<String, dynamic>.from(row);
    columnFormats.forEach((key, formats) {
      if (formattedRow.containsKey(key)) {
        final value = formattedRow[key];
        if (value is String) {
          if (formats.contains(AcEnumDDColumnFormat.ENCRYPT)) {
            formattedRow[key] = AcEncryption.decrypt(encryptedText: value);
          }
          if (formats.contains(AcEnumDDColumnFormat.JSON)) {
            if (value.isNotEmpty) {
              try {
                formattedRow[key] = jsonDecode(value);
              } catch (_) {
              }
            } else {
              formattedRow[key] = null;
            }
          }
        }
        if (formats.contains(AcEnumDDColumnFormat.HIDE_COLUMN)) {
          formattedRow.remove(key);
        }
      }
    });
    return formattedRow;
  }

  @override
  Future<MySQLConnection?> getConnectionObject({bool includeDatabase = true}) async {
    if (includeDatabase) {
      return await _getConnection();
    } else {
      return await _getConnectionWithoutDatabase();
    }
  }

  @override
  Future<AcSqlDaoResult> getDatabaseFunctions() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT ROUTINE_NAME, DATA_TYPE, CREATED, DEFINER FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @databaseName AND ROUTINE_TYPE = 'FUNCTION'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        result.rows.add({
          AcDDFunction.KEY_FUNCTION_NAME: row.colByName('ROUTINE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT ROUTINE_NAME, CREATED, DEFINER FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @databaseName AND ROUTINE_TYPE = 'PROCEDURE'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        result.rows.add({
          AcDDStoredProcedure.KEY_STORED_PROCEDURE_NAME: row.colByName('ROUTINE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseTables() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @databaseName AND TABLE_TYPE='BASE TABLE'";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        result.rows.add({
          AcDDTable.KEY_TABLE_NAME: row.colByName('TABLE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseTriggers() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_STATEMENT, ACTION_TIMING FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        result.rows.add({
          AcDDTrigger.KEY_TRIGGER_NAME: row.colByName('TRIGGER_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getDatabaseViews() async {
    final result = AcSqlDaoResult();
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = @databaseName";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@databaseName': sqlConnection.database},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        result.rows.add({
          AcDDView.KEY_VIEW_NAME: row.colByName('TABLE_NAME'),
        });
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getRows({required String statement, String condition = "", Map<String, dynamic> parameters = const {}, String mode = AcEnumDDSelectMode.LIST, Map<String, List<String>> columnFormats = const {}}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      if (mode == AcEnumDDSelectMode.COUNT) {
        statement = "SELECT COUNT(*) AS records_count FROM ($statement) AS records_list";
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
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      if (mode == AcEnumDDSelectMode.COUNT) {
        Map<String,dynamic> row = results.rows.first.assoc();
        result.totalRows = row['records_count'];
      }
      else{
        result.rows = results.rows.map((row) => formatRow(row:row.typedAssoc(), columnFormats: columnFormats)).toList();
      }
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "DESCRIBE `@tableName`";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@tableName': tableName},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        final properties = <String, dynamic>{};
        if (row.colByName('Null') != "YES") {
          properties[AcEnumDDColumnProperty.NOT_NULL] = false;
        }
        if (row.colByName('Key') == "PRI") {
          properties[AcEnumDDColumnProperty.PRIMARY_KEY] = true;
        }
        if (row.colByName('Default') != null) {
          properties[AcEnumDDColumnProperty.DEFAULT_VALUE] = row.colByName('Default');
        }
        result.rows.add({
          AcDDTableColumn.KEY_COLUMN_NAME: row.colByName('Field'),
          AcDDTableColumn.KEY_COLUMN_TYPE: row.colByName('Type'),
          AcDDTableColumn.KEY_COLUMN_PROPERTIES: properties,
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception:ex, stackTrace:stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      const statement = "DESCRIBE `@viewName`";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {'@viewName': viewName},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final results = await db.execute(updatedStatement, updatedParameterValues);
      for (final row in results.rows) {
        final properties = <String, dynamic>{};
        if (row.colByName('Null') != "YES") {
          properties[AcEnumDDColumnProperty.NOT_NULL] = false;
        }
        if (row.colByName('Key') == "PRI") {
          properties[AcEnumDDColumnProperty.PRIMARY_KEY] = true;
        }
        if (row.colByName('Default') != null) {
          properties[AcEnumDDColumnProperty.DEFAULT_VALUE] = row.colByName('Default');
        }
        result.rows.add({
          AcDDViewColumn.KEY_COLUMN_NAME: row.colByName('Field'),
          AcDDViewColumn.KEY_COLUMN_TYPE: row.colByName('Type'),
          AcDDViewColumn.KEY_COLUMN_PROPERTIES: properties,
        });
      }
      result.setSuccess();
    } catch (ex, stack) {
      result.setException(exception:ex, stackTrace:stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> insertRow({required String tableName, required Map<String, dynamic> row}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final columns = row.keys.toList();
      final placeholders = List.generate(columns.length, (i) => '@p$i').join(', ');
      final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
      final params = <String, dynamic>{};
      for (var i = 0; i < columns.length; i++) {
        params['@p$i'] = row[columns[i]];
      }
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: params,
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final insertResult = await db.execute(updatedStatement, updatedParameterValues);
      result.lastInsertedId = insertResult.lastInsertID.toInt();
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> insertRows({required String tableName,required List<Map<String, dynamic>> rows}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      if (rows.isNotEmpty) {
        final columns = rows.first.keys.toList();
        final placeholders = List.generate(columns.length, (i) => '@p$i').join(', ');
        final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
        await db.transactional((txn) async {
          for (final rowData in rows) {
            final params = <String, dynamic>{};
            for (var i = 0; i < columns.length; i++) {
              params['@p$i'] = rowData[columns[i]];
            }
            List<dynamic> parameterValues = List<dynamic>.empty(growable:true);
            final setParametersResult = setSqlStatementParameters(
              statement: statement,
              passedParameters: params,
            );
            final updatedStatement = setParametersResult['statement'];
            final updatedParameterValues = setParametersResult['statementParametersMap'];
            await txn.execute(updatedStatement, updatedParameterValues);
          }
        });
        result.setSuccess();
      } else {
        result.setSuccess(value:true, message: 'No rows to insert.');
      }
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> updateRow({required String tableName,required Map<String, dynamic> row, String condition = "", Map<String, dynamic> parameters = const {}}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      final setValues = row.keys.map((key) => "$key = @$key").join(", ");
      final statement = "UPDATE $tableName SET $setValues ${condition.isNotEmpty ? "WHERE $condition" : ""}";
      final setParametersResult = setSqlStatementParameters(
        statement: statement,
        passedParameters: {...row, ...parameters},
      );
      final updatedStatement = setParametersResult['statement'];
      final updatedParameterValues = setParametersResult['statementParametersMap'];
      final updateResult = await db.execute(updatedStatement, updatedParameterValues);
      result.affectedRowsCount = updateResult.affectedRows.toInt();
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }

  @override
  Future<AcSqlDaoResult> updateRows({required String tableName, required List<Map<String, dynamic>> rowsWithConditions}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
    MySQLConnection? db;
    try {
      db = await _getConnection();
      await db.transactional((txn) async {
        for (final rowWithCondition in rowsWithConditions) {
          if (rowWithCondition.containsKey('row') && rowWithCondition.containsKey('condition')) {
            final row = rowWithCondition['row'] as Map<String, dynamic>;
            final condition = rowWithCondition['condition'] as String;
            final conditionParameters = rowWithCondition.containsKey('parameters') ? rowWithCondition['parameters'] as Map<String, dynamic> : <String, dynamic>{};

            final setValues = row.keys.map((key) => "$key = @row_$key").join(", ");
            final statement = "UPDATE $tableName SET $setValues WHERE $condition";
            final params = <String, dynamic>{};
            row.forEach((key, value) {
              params['@row_$key'] = value;
            });
            final setParametersResult = setSqlStatementParameters(
              statement: statement,
              passedParameters: {...params, ...conditionParameters},
            );
            final updatedStatement = setParametersResult['statement'];
            final updatedParameterValues = setParametersResult['statementParametersMap'];
            final updateResult = await txn.execute(updatedStatement, updatedParameterValues);
            result.affectedRowsCount ??= 0;
            result.affectedRowsCount = result.affectedRowsCount! + updateResult.affectedRows.toInt();
          }
        }
      });
      result.setSuccess();
    } catch (ex,stack) {
      result.setException(exception:ex,stackTrace: stack);
    } finally {
      await db?.close();
    }
    return result;
  }
}

