// import 'dart:io';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
// import 'dart:convert';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class AcSqliteDao extends AcBaseSqlDao {
//   Database? _db;
//
//   // Use factory constructor for singleton
//   factory AcSqliteDao() {
//     _instance ??= AcSqliteDao._internal();
//     return _instance!;
//   }
//   AcSqliteDao._internal();
//   static AcSqliteDao? _instance;
//
//   Future<Database> _getConnection() async {
//     if (_db == null || !(_db?.isOpen ?? false)) {
//       var databasesPath = await getDatabasesPath();
//       String path = join(databasesPath, sqlConnection.database);
//       _db = await openDatabase(path, version: 1,
//           onCreate: (Database db, int version) async {
//             // You might need to create tables here if they don't exist.
//             // This is handled in createDatabase in this implementation.
//           });
//     }
//     return _db!;
//   }
//
//   Future<Database> _getConnectionWithoutDatabase() async {
//     if (_db == null || !(_db?.isOpen ?? false)) {
//       var databasesPath = await getDatabasesPath();
//       String path = join(databasesPath, sqlConnection.database);
//       _db = await openDatabase(path, version: 1,
//           onCreate: (Database db, int version) async {
//             //This function is called only when the database is created for the first time
//             // in sqflite, database creation is handled when you open the database.
//           });
//     }
//     return _db!;
//   }
//
//   @override
//   Future<AcResult> checkDatabaseExist() async {
//     final result = AcResult();
//     try {
//       final dbPath = await getDatabasesPath();
//       final dbFile = File(join(dbPath, sqlConnection.database));
//       final exists = await dbFile.exists();
//       result.setSuccess(value: exists, message: exists ? 'Database exists' : 'Database does not exist');
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcResult> checkTableExist({required String tableName}) async {
//     final result = AcResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       final statement = "SELECT name FROM sqlite_master WHERE type='table' AND name=?";
//       final results = await db.query(statement, whereArgs: [tableName]);
//       final exists = results.isNotEmpty;
//       result.setSuccess(value: exists, message: exists ? 'Table exists' : 'Table does not exist');
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcResult> createDatabase() async {
//     final result = AcResult();
//     try {
//       await _getConnectionWithoutDatabase();
//       result.setSuccess(value: true, message: 'Database created or opened');
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> deleteRows({required String tableName, String condition = "", Map<String, dynamic> parameters = const {}}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.DELETE);
//     Database? db;
//     try {
//       db = await _getConnection();
//       String whereClause = condition.isNotEmpty ? "WHERE $condition" : "";
//       final statement = "DELETE FROM $tableName $whereClause";
//       final argList = parameters.values.toList();
//       final affectedRows = await db.rawDelete(statement, argList);
//       result.affectedRowsCount = affectedRows;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> executeMultipleSqlStatements({required List<String> statements, Map<String, dynamic> parameters = const {}}) async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       await db.transaction((txn) async {
//         for (final statement in statements) {
//           await txn.execute(statement, parameters.values.toList());
//         }
//       });
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> executeStatement({required String statement, String? operation = AcEnumDDRowOperation.UNKNOWN, Map<String, dynamic> parameters = const {}}) async {
//     final result = AcSqlDaoResult(operation: operation);
//     Database? db;
//     try {
//       db = await _getConnection();
//       await db.execute(statement, parameters.values.toList());
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Map<String, dynamic> formatRow({required Map<String, dynamic> row, Map<String, List<String>> columnFormats = const {}}) {
//     final formattedRow = Map<String, dynamic>.from(row);
//     columnFormats.forEach((key, formats) {
//       if (formattedRow.containsKey(key)) {
//         final value = formattedRow[key];
//         if (value is String) {
//           if (formats.contains(AcEnumDDColumnFormat.ENCRYPT)) {
//             formattedRow[key] = AcEncryption.decrypt(encryptedText: value);
//           }
//           if (formats.contains(AcEnumDDColumnFormat.JSON)) {
//             if (value.isNotEmpty) {
//               try {
//                 formattedRow[key] = jsonDecode(value);
//               } catch (_) {
//                 // Keep the original string if it's not valid JSON
//               }
//             } else {
//               formattedRow[key] = null; // Or any other default value
//             }
//           }
//         }
//         if (formats.contains(AcEnumDDColumnFormat.HIDE_COLUMN)) {
//           formattedRow.remove(key);
//         }
//       }
//     });
//     return formattedRow;
//   }
//
//   @override
//   Future<Database?> getConnectionObject({bool includeDatabase = true}) async {
//     return await _getConnection();
//   }
//
//   @override
//   Future<AcSqlDaoResult> getDatabaseFunctions() async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "SELECT name FROM sqlite_master WHERE type='function'";
//       final results = await db.rawQuery(statement);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (var r in results) {
//         formattedResults.add({AcDDFunction.KEY_FUNCTION_NAME: r['name']});
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getDatabaseStoredProcedures() async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "SELECT name FROM sqlite_master WHERE type='procedure'"; //sqlite does not have procedures.
//       final results = await db.rawQuery(statement);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (var r in results) {
//         formattedResults.add({AcDDStoredProcedure.KEY_STORED_PROCEDURE_NAME: r['name']});
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getDatabaseTables() async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "SELECT name FROM sqlite_master WHERE type='table'";
//       final results = await db.rawQuery(statement);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (var r in results) {
//         formattedResults.add({AcDDTable.KEY_TABLE_NAME: r['name']});
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getDatabaseTriggers() async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "SELECT name FROM sqlite_master WHERE type='trigger'";
//       final results = await db.rawQuery(statement);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (var r in results) {
//         formattedResults.add({AcDDTrigger.KEY_TRIGGER_NAME: r['name']});
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getDatabaseViews() async {
//     final result = AcSqlDaoResult();
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "SELECT name FROM sqlite_master WHERE type='view'";
//       final results = await db.rawQuery(statement);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (var r in results) {
//         formattedResults.add({AcDDView.KEY_VIEW_NAME: r['name']});
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getRows({required String statement, String condition = "", Map<String, dynamic> parameters = const {}, String mode = AcEnumDDSelectMode.LIST, Map<String, List<String>> columnFormats = const {}}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
//     Database? db;
//     try {
//       db = await _getConnection();
//       String updatedStatement = statement;
//       if (condition.isNotEmpty) {
//         updatedStatement += " WHERE $condition";
//       }
//       final argList = parameters.values.toList();
//       final results = await db.rawQuery(updatedStatement, argList);
//
//       List<Map<String, dynamic>> formattedResults = results.map((row) => formatRow(row: row, columnFormats: columnFormats)).toList();
//       result.rows = formattedResults;
//       if (mode == AcEnumDDSelectMode.FIRST && result.rows.isNotEmpty) {
//         result.rows = [result.rows.first];
//       }
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getTableColumns({required String tableName}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "PRAGMA table_info(?)";
//       final results = await db.rawQuery(statement, [tableName]);
//       List<Map<String, dynamic>> formattedResults = [];
//
//       for (final row in results) {
//         final properties = <String, dynamic>{};
//         if (row['notnull'] == 1) {
//           properties[AcEnumDDColumnProperty.NOT_NULL] = true;
//         }
//         if (row['pk'] == 1) {
//           properties[AcEnumDDColumnProperty.PRIMARY_KEY] = true;
//         }
//         if (row['dflt_value'] != null) {
//           properties[AcEnumDDColumnProperty.DEFAULT_VALUE] = row['dflt_value'];
//         }
//         formattedResults.add({
//           AcDDTableColumn.KEY_COLUMN_NAME: row['name'],
//           AcDDTableColumn.KEY_COLUMN_TYPE: row['type'],
//           AcDDTableColumn.KEY_COLUMN_PROPERTIES: properties,
//         });
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> getViewColumns({required String viewName}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
//     Database? db;
//     try {
//       db = await _getConnection();
//       const statement = "PRAGMA table_info(?)"; //sqlite uses same pragma for views and tables
//       final results = await db.rawQuery(statement, [viewName]);
//       List<Map<String, dynamic>> formattedResults = [];
//       for (final row in results) {
//         final properties = <String, dynamic>{};
//         if (row['notnull'] == 1) {
//           properties[AcEnumDDColumnProperty.NOT_NULL] = true;
//         }
//         if (row['pk'] == 1) {
//           properties[AcEnumDDColumnProperty.PRIMARY_KEY] = true;
//         }
//         if (row['dflt_value'] != null) {
//           properties[AcEnumDDColumnProperty.DEFAULT_VALUE] = row['dflt_value'];
//         }
//         formattedResults.add({
//           AcDDViewColumn.KEY_COLUMN_NAME: row['name'],
//           AcDDViewColumn.KEY_COLUMN_TYPE: row['type'],
//           AcDDViewColumn.KEY_COLUMN_PROPERTIES: properties,
//         });
//       }
//       result.rows = formattedResults;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> insertRow({required String tableName, required Map<String, dynamic> row}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
//     Database? db;
//     try {
//       db = await _getConnection();
//       final columns = row.keys.toList();
//       final placeholders = List.generate(columns.length, (i) => '?').join(', ');
//       final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
//       final values = row.values.toList();
//       result.lastInsertedId = await db.rawInsert(statement,values);
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> insertRows({required String tableName, required List<Map<String, dynamic>> rows}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
//     Database? db;
//     try {
//       db = await _getConnection();
//       if (rows.isNotEmpty) {
//         final columns = rows.first.keys.toList();
//         final placeholders = List.generate(columns.length, (i) => '?').join(', ');
//         final statement = "INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)";
//
//         await db.transaction((txn) async {
//           for (final rowData in rows) {
//             final values = rowData.values.toList();
//             await txn.execute(statement, values);
//           }
//         });
//         result.setSuccess();
//       } else {
//         result.setSuccess(value: true, message: 'No rows to insert.');
//       }
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> updateRow({required String tableName, required Map<String, dynamic> row, String condition = "", Map<String, dynamic> parameters = const {}}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
//     Database? db;
//     try {
//       db = await _getConnection();
//       final setValues = row.keys.map((key) => "$key = ?").join(", ");
//       final statement = "UPDATE $tableName SET $setValues ${condition.isNotEmpty ? "WHERE $condition" : ""}";
//       final values = [...row.values, ...parameters.values];
//       final affectedRows = await db.rawUpdate(statement, values);
//       result.affectedRowsCount = affectedRows;
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
//
//   @override
//   Future<AcSqlDaoResult> updateRows({required String tableName, required List<Map<String, dynamic>> rowsWithConditions}) async {
//     final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
//     Database? db;
//     try {
//       db = await _getConnection();
//       await db.transaction((txn) async {
//         for (final rowWithCondition in rowsWithConditions) {
//           if (rowWithCondition.containsKey('row') && rowWithCondition.containsKey('condition')) {
//             final row = rowWithCondition['row'] as Map<String, dynamic>;
//             final condition = rowWithCondition['condition'] as String;
//             final conditionParameters = rowWithCondition.containsKey('parameters')
//                 ? rowWithCondition['parameters'] as Map<String, dynamic>
//                 : <String, dynamic>{};
//
//             final setValues = row.keys.map((key) => "$key = ?").join(", ");
//             final statement = "UPDATE $tableName SET $setValues WHERE $condition";
//             final values = [...row.values, ...conditionParameters.values];
//             final affectedRows = await txn.rawUpdate(statement, values);
//             result.affectedRowsCount ??= 0;
//             result.affectedRowsCount = result.affectedRowsCount! + affectedRows;
//           }
//         }
//       });
//       result.setSuccess();
//     } catch (ex, stack) {
//       result.setException(exception: ex, stackTrace: stack);
//     }
//     return result;
//   }
// }
//
