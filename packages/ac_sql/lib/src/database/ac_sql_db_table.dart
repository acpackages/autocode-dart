import 'dart:convert';
import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A high-level database service handler focused on a single database table.",
  "description": "This class extends `AcSqlDbBase` to provide a rich set of business logic and data manipulation methods for a specific table. It handles complex operations like validation, event firing (before/after operations), cascade deletes, auto-number generation, and provides a simplified interface for CRUD (Create, Read, Update, Delete) and 'upsert' (save) actions.",
  "example": "// Prerequisite: Global AcSqlDatabase settings are configured.\n\n// 1. Create a service handler for the 'users' table.\nfinal userTableService = AcSqlDbTable(tableName: 'users');\n\n// 2. Save a row. This will either insert a new record or update an existing one.\nfinal result = await userTableService.saveRow(row: {\n  'id': 1,\n  'name': 'John Doe',\n  'email': 'john.doe@example.com'\n});\n\nif (result.isSuccess()) {\n  print('User saved successfully!');\n}"
}) */
class AcSqlDbTable extends AcSqlDbBase {
  /* AcDoc({"summary": "The name of the table this service handler manages."}) */
  final String tableName;

  /* AcDoc({"summary": "The loaded data dictionary definition for the table."}) */
  late AcDDTable acDDTable;

  /* AcDoc({
    "summary": "Creates a service handler for a specific database table.",
    "description": "Initializes the base database service and loads the definition for the specified table from the data dictionary.",
    "params": [
      {"name": "tableName", "description": "The name of the table to manage."},
      {"name": "dataDictionaryName", "description": "The data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbTable({required this.tableName, super.dataDictionaryName,super.logger,super.dao}){
    acDDTable = AcDDTable.getInstance(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    );
  }

  /* AcDoc({
    "summary": "Performs cascade deletes for a given set of rows.",
    "description": "Based on the relationships defined in the data dictionary where 'cascadeDelete' is true, this method deletes corresponding records in related tables.",
    "params": [
      {"name": "rows", "description": "A list of rows that have been (or are about to be) deleted."}
    ],
    "returns": "An `AcResult` indicating the outcome of the cascade delete operations.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> cascadeDeleteRows({
    required List<Map<String, dynamic>> rows,
  }) async {
    final result = AcResult();
    try {
      logger.log("Checking cascade delete for table $tableName");
      final tableRelationships = AcDataDictionary.getTableRelationships(
        tableName: tableName,
      );
      logger.log(["Table relationships : ", tableRelationships]);

      for (final row in rows) {
        logger.log(["Checking cascade delete for table row :", row]);
        for (final acRelationship in tableRelationships) {
          String deleteTableName = "";
          String deleteColumnName = "";
          dynamic deleteColumnValue;
          logger.log([
            "Checking cascade delete for relationship : ",
            acRelationship,
          ]);
          if (acRelationship.sourceTable == tableName && acRelationship.cascadeDeleteDestination == true ) {
            deleteTableName = acRelationship.destinationTable;
            deleteColumnName = acRelationship.destinationColumn;
            deleteColumnValue = row[acRelationship.sourceColumn];
          }
          if (acRelationship.destinationTable == tableName &&
              acRelationship.cascadeDeleteSource == true) {
            deleteTableName = acRelationship.sourceTable;
            deleteColumnName = acRelationship.sourceColumn;
            deleteColumnValue = row[acRelationship.destinationColumn];
          }
          logger.log(
            "Performing cascade delete with related table $deleteTableName and column $deleteColumnName with value $deleteColumnValue",
          );
          if (deleteTableName.isNotEmpty && deleteColumnName.isNotEmpty) {
            if (Autocode.validPrimaryKey(deleteColumnValue)) {
              logger.log(
                "Deleting related rows for primary key value : $deleteColumnValue",
              );
              final deleteCondition = "$deleteColumnName = :deleteColumnValue";
              final deleteAcTable = AcSqlDbTable(
                tableName: deleteTableName,
                dataDictionaryName: dataDictionaryName,
              );
              final deleteResult = await deleteAcTable.deleteRows(
                condition: deleteCondition,
                parameters: {":deleteColumnValue": deleteColumnValue},
              );
              if (deleteResult.isSuccess()) {
                logger.log("Cascade delete successful for $deleteTableName");
              } else {
                return result.setFromResult(
                  result: deleteResult,
                  message: "Error in cascade delete: ${deleteResult.message}",
                  logger: logger,
                );
              }
            } else {
              logger.log("No value for cascade delete records");
            }
          } else {
            logger.log("No table & column for cascade delete records");
          }
        }
      }
      result.setSuccess();
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Checks and generates values for auto-number columns in a row.",
    "description": "For columns of type `autoNumber`, this method calculates the next sequential number based on existing records (e.g., finds the max 'INV-009' and generates 'INV-010') and populates the value in the provided row map.",
    "params": [
      {"name": "row", "description": "The row data map to be checked and modified in place."}
    ],
    "returns": "An `AcResult` with the modified row map as its `value` on success.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkAndSetAutoNumberValues({
    required Map<String, dynamic> row,
  }) async {
    final result = AcResult();
    try {
      List<String> checkColumns = [];
      Map<String, Map<String, dynamic>> autoNumberColumns = {};
      bool continueOperation = true;
      for (final tableColumn in acDDTable.tableColumns) {
        bool setAutoNumber = true;
        if (tableColumn.isAutoNumber()) {
          if (row.containsKey(tableColumn.columnName) &&
              row[tableColumn.columnName] != null &&
              row[tableColumn.columnName].toString().isNotEmpty) {
            setAutoNumber = false;
          }
          if (setAutoNumber) {
            autoNumberColumns[tableColumn.columnName] = {
              "prefix": tableColumn.getAutoNumberPrefix(),
              "length": tableColumn.getAutoNumberLength(),
              "prefix_length": tableColumn.getAutoNumberPrefixLength(),
            };
          }
        }
        if (tableColumn.checkInAutoNumber() || tableColumn.checkInModify()) {
          checkColumns.add(tableColumn.columnName);
        }
      }

      if (autoNumberColumns.isNotEmpty) {
        List<String> selectColumnsList = autoNumberColumns.keys.toList();
        String checkCondition = "";
        Map<String, dynamic> checkConditionValues = {};
        if (checkColumns.isNotEmpty) {
          for (final checkColumn in checkColumns) {
            checkCondition += " AND $checkColumn = @checkColumn$checkColumn";
            if (row.containsKey(checkColumn)) {
              checkConditionValues["@checkColumn$checkColumn"] =
                  row[checkColumn];
            }
          }
        }

        List<String> getRowsStatements = [];
        for (final name in selectColumnsList) {
          String columnGetRows = "";
          if (databaseType == AcEnumSqlDatabaseType.mysql) {
            columnGetRows =
                "SELECT CONCAT('{\"$name\":',IF(MAX(CAST(SUBSTRING($name, ${autoNumberColumns[name]!["prefix_length"]} + 1) AS UNSIGNED)) IS NULL,0,MAX(CAST(SUBSTRING($name, ${autoNumberColumns[name]!["prefix_length"]} + 1) AS UNSIGNED))),'}') AS max_json FROM $tableName WHERE $name LIKE '${autoNumberColumns[name]!["prefix"]}%' $checkCondition";
          }
          if (columnGetRows.isNotEmpty) {
            getRowsStatements.add(columnGetRows);
          }
        }

        if (getRowsStatements.isNotEmpty) {
          final getRows = getRowsStatements.join(" UNION ");
          final selectResponse = await dao!.getRows(
            statement: getRows,
            parameters: checkConditionValues,
          );
          if (selectResponse.isSuccess()) {
            final rows = selectResponse.rows;
            for (final rowData in rows) {
              final maxJson =
                  jsonDecode(rowData["max_json"]) as Map<String, dynamic>;
              final name = maxJson.keys.first;
              int lastRecordId = maxJson[name] ?? 0;
              lastRecordId++;
              String autoNumberValue =
                  autoNumberColumns[name]!["prefix"] +
                  updateValueLengthWithChars(
                    value: lastRecordId.toString(),
                    char: "0",
                    length: autoNumberColumns[name]!["length"],
                  );
              row[name] = autoNumberValue;
            }
          } else {
            continueOperation = false;
            return result.setFromResult(result: selectResponse);
          }
        }
      }
      if(continueOperation){
        result.setSuccess(value: row);
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Checks for unique key violations before an insert or update.",
    "description": "Validates that the data in the provided `row` does not violate any unique key constraints defined in the data dictionary by querying for existing records with the same values.",
    "params": [
      {"name": "row", "description": "The row data to validate."}
    ],
    "returns": "An `AcResult` that is successful if no violations are found, or fails with a message if a violation is detected.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkUniqueValues({
    required Map<String, dynamic> row,
  }) async {
    final result = AcResult();
    try {
      bool continueOperation = false;
      Map<String, dynamic> parameters = {};
      List<String> conditions = [];
      List<String> modifyConditions = [];
      List<String> uniqueConditions = [];
      List<String> uniqueColumns = [];
      final primaryKeyColumnName = acDDTable.getPrimaryKeyColumnName();
      if (primaryKeyColumnName.isNotEmpty) {
        if (row.containsKey(primaryKeyColumnName) &&
            Autocode.validPrimaryKey(row[primaryKeyColumnName])) {
          conditions.add("$primaryKeyColumnName != @primaryKeyValue");
          parameters["@primaryKeyValue"] = row[primaryKeyColumnName];
        }
      }

      for (final tableColumn in acDDTable.tableColumns) {
        final value = row[tableColumn.columnName];
        if (tableColumn.checkInModify()) {
          modifyConditions.add(
            "${tableColumn.columnName} = @modify_${tableColumn.columnName}",
          );
          parameters["@modify_${tableColumn.columnName}"] = value;
        }
        if (tableColumn.isUniqueKey()) {
          uniqueConditions.add(
            "${tableColumn.columnName} = @unique_${tableColumn.columnName}",
          );
          parameters["@unique_${tableColumn.columnName}"] = value;
          uniqueColumns.add(tableColumn.columnName);
        }
      }

      if (uniqueConditions.isNotEmpty) {
        if (modifyConditions.isNotEmpty) {
          conditions.addAll(modifyConditions);
        }
        conditions.add("(${uniqueConditions.join(" OR ")})");
        if (conditions.isNotEmpty) {
          logger.log("Searching for Unique Records getting Repeated");
          final selectResponse = await getRows(
            condition: conditions.join(" AND "),
            parameters: parameters,
            mode: AcEnumDDSelectMode.count,
          );
          if (selectResponse.isSuccess()) {
            final rowsCount = selectResponse.rowsCount;
            if (rowsCount > 0) {
              result.setFailure(
                value: {"unique_columns": uniqueColumns},
                message: "Unique key violated",
              );
            } else {
              result.setSuccess();
            }
          } else {
            result.setFromResult(result: selectResponse);
            continueOperation = false;
          }
        } else {
          result.setSuccess();
        }
      } else {
        logger.log("No unique conditions found");
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Deletes rows from the table, with full event and cascade handling.",
    "description": "This is a high-level delete method that orchestrates the entire delete lifecycle:\n1. Fires a `beforeDelete` event.\n2. Sets related foreign keys in other tables to null if configured.\n3. Performs cascade deletes if configured.\n4. Executes the final `DELETE` statement.\n5. Fires an `afterDelete` event.",
    "params": [
      {"name": "condition", "description": "The WHERE clause to identify rows to delete."},
      {"name": "primaryKeyValue", "description": "A primary key value to delete a single record. An alternative to using `condition`."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."},
      {"name": "executeBeforeEvent", "description": "Whether to fire the `beforeDelete` event."},
      {"name": "executeAfterEvent", "description": "Whether to fire the `afterDelete` event."}
    ],
    "returns": "An `AcSqlDaoResult` containing the results of the operation, including the deleted rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> deleteRows({
    String condition = "",
    String primaryKeyValue = "",
    Map<String, dynamic> parameters = const {},
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    parameters = Map.from(parameters);
    logger.log(
      "Deleting row with condition : $condition & primaryKeyValue $primaryKeyValue",
    );
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.delete);
    try {
      bool continueOperation = true;
      final primaryKeyColumnName = acDDTable.getPrimaryKeyColumnName();
      if (condition.isEmpty) {
        if (primaryKeyValue.isNotEmpty && primaryKeyColumnName.isNotEmpty) {
          condition = "$primaryKeyColumnName = :primaryKeyValue";
          parameters[":primaryKeyValue"]= primaryKeyValue;
        } else {
          continueOperation = false;
          result.setFailure(
            message: 'Primary key column or column value is missing',
          );
        }
      } else {
        condition =
            " $primaryKeyColumnName  IN (SELECT $primaryKeyColumnName FROM $tableName WHERE $condition)";
      }
      if (continueOperation) {
        if (executeBeforeEvent) {
          final rowEvent = AcSqlDbRowEvent(
            tableName: tableName,
            dataDictionaryName: dataDictionaryName,
          );
          rowEvent.condition = condition;
          rowEvent.parameters = parameters;
          rowEvent.eventType = AcEnumDDRowEvent.beforeDelete;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            condition = rowEvent.condition;
            parameters = rowEvent.parameters;
          } else {
            continueOperation = false;
            result.setFromResult(
              result: eventResult,
              message: "Aborted from before delete row events",
            );
          }
        }
      }
      if (continueOperation) {
        logger.log([
          "",
          "",
          "Performing delete operation on table $tableName with condition : $condition and parameters : ",
          parameters,
          "",
          "",
        ]);
        final getResult = await getRows(
          condition: condition,
          parameters: parameters,
        );
        if (getResult.isSuccess()) {
          result.rows = getResult.rows;
          final setNullResult = await setValuesNullBeforeDelete(
            condition: condition,
            parameters: parameters,
          );
          if (setNullResult.isFailure()) {
            logger.error(['Error setting null before delete', setNullResult]);
            continueOperation = false;
            result.setFromResult(result: setNullResult);
          }
          if (continueOperation && acSqlConfig.cascadeDeleteDestinationRows) {
            final cascadeDeleteResult = await cascadeDeleteRows(
              rows: result.rows,
            );
            if (cascadeDeleteResult.isFailure()) {
              logger.error(['Error cascade deleting row', cascadeDeleteResult]);
              continueOperation = false;
              result.setFromResult(result: setNullResult, logger: logger);
            } else {
              logger.log(['Cascade delete result', cascadeDeleteResult]);
            }
          }
          if (continueOperation) {
            final deleteResult = await dao!.deleteRows(
              tableName: tableName,
              condition: condition,
              parameters: parameters,
            );
            if (deleteResult.isSuccess()) {
              result.affectedRowsCount = deleteResult.affectedRowsCount;
              result.setSuccess(
                message:
                    "${deleteResult.affectedRowsCount} row(s) deleted successfully",
              );
            } else {
              continueOperation=false;
              result.setFromResult(result: deleteResult);
              if (deleteResult.message.contains("foreign key")) {
                result.message =
                    "Cannot delete row! Foreign key constraint is preventing from deleting rows!";
              }
            }
          }
        } else {
          continueOperation=false;
          result.setFromResult(result: getResult, logger: logger);
        }
      }
      if (continueOperation && executeAfterEvent) {
        final rowEvent = AcSqlDbRowEvent(
          tableName: tableName,
          dataDictionaryName: dataDictionaryName,
        );
        rowEvent.eventType = AcEnumDDRowEvent.afterDelete;
        rowEvent.condition = condition;
        rowEvent.parameters = parameters;
        rowEvent.result = result;
        final eventResult = await rowEvent.execute();
        if (eventResult.isSuccess()) {
          result = rowEvent.result;
        } else {
          continueOperation=false;
          result.setFromResult(result: eventResult);
        }
      }
      if(continueOperation){
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Formats row values based on column definitions.",
    "description": "Applies formatting such as trimming strings, encrypting passwords, and JSON encoding/decoding to a row's data before it is saved. Also handles default values for insert operations.",
    "params": [
      {"name": "row", "description": "The row data map to be formatted in place."},
      {"name": "insertMode", "description": "If true, default values will be applied."}
    ],
    "returns": "An `AcResult` with the formatted row as its `value` on success.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> formatValues({
    required Map<String, dynamic> row,
    bool insertMode = false,
  }) async {
    row = Map.from(row);
    final result = AcResult();
    bool continueOperation = true;
    final rowEvent = AcSqlDbRowEvent(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    );
    rowEvent.row = row;
    rowEvent.eventType = AcEnumDDRowEvent.beforeFormat;
    final eventResult = await rowEvent.execute();
    if (eventResult.isSuccess()) {
      row = rowEvent.row;
    } else {
      result.setFromResult(result: eventResult);
      continueOperation = false;
    }
    if (continueOperation) {
      List<String> tableColumnNames = List.empty(growable: true);
      for (final column in acDDTable.tableColumns) {
        tableColumnNames.add(column.columnName);
        if (row.containsKey(column.columnName) || insertMode) {
          bool setColumnValue = row.containsKey(column.columnName);
          List<String> formats = column.getColumnFormats();
          AcEnumDDColumnType type = column.columnType;
          dynamic value = row[column.columnName];
          logger.log("Formatting value for ${column.columnName} with value type ${value.runtimeType} and value : $value");
          if (value == null && insertMode) {
            if(column.getDefaultValue() != null){
              value = column.getDefaultValue();
              setColumnValue = true;
            }
            else if ((type == AcEnumDDColumnType.uuid || type == AcEnumDDColumnType.string) && insertMode && column.isPrimaryKey()) {
              setColumnValue = true;
            }
          }
          if (setColumnValue) {
            if ([
              AcEnumDDColumnType.date,
              AcEnumDDColumnType.datetime,
              AcEnumDDColumnType.string,
            ].contains(type)) {
              if (type == AcEnumDDColumnType.string && value is String) {
                if (formats.contains(AcEnumDDColumnFormat.lowercase.value)) {
                  value = value.toLowerCase();
                }
                if (formats.contains(AcEnumDDColumnFormat.uppercase.value)) {
                  value = value.toUpperCase();
                }
                if (formats.contains(AcEnumDDColumnFormat.encrypt.value)) {
                  value = AcEncryption.encrypt(plainText: value);
                }
              }
              else if ([
                    AcEnumDDColumnType.datetime,
                    AcEnumDDColumnType.date,
                  ].contains(type) &&
                  value is String) {
                try {
                  DateTime dateTimeValue = DateTime.parse(value);
                  String format =
                      (type == AcEnumDDColumnType.datetime)
                          ? 'yyyy-MM-dd HH:mm:ss'
                          : 'yyyy-MM-dd';
                  value = dateTimeValue.fromFormatted(format);
                } catch (e) {
                  logger.warn(
                    "Error while setting dateTimeValue for ${column.columnName} in table $tableName with value: $value",
                  );
                }
              }
            } else if ([AcEnumDDColumnType.json].contains(type) && value != null) {
              value = value is String ? value : json.encode(value);
            } else if (type == AcEnumDDColumnType.password && value is String) {
              value = AcEncryption.encrypt(plainText: value);
            }
            else if ((type == AcEnumDDColumnType.uuid || type == AcEnumDDColumnType.string) && insertMode && column.isPrimaryKey()) {
              if(value == '' || value == null){
                value = Autocode.uuid();
              }
            }
            if ((type == AcEnumDDColumnType.uuid || type == AcEnumDDColumnType.string) && column.isForeignKey() && value is String && value.isEmpty) {
              value = null;
            }
            logger.log("Formatted value for ${column.columnName} with value type ${value.runtimeType} and value : $value");
            row[column.columnName] = value;
          }
        }
      }
      List<String> invalidKeys = row.keys.where((key){
        return !tableColumnNames.contains(key);
      }).toList();
      for(var key in invalidKeys){
        row.remove(key);
      }
    }
    if (continueOperation) {
      final rowEvent = AcSqlDbRowEvent(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      rowEvent.row = row;
      rowEvent.eventType = AcEnumDDRowEvent.afterFormat;
      final eventResult = await rowEvent.execute();
      if (eventResult.isSuccess()) {
        row = rowEvent.row;
      } else {
        result.setFromResult(result: eventResult);
        continueOperation = false;
      }
    }
    if (continueOperation) {
      result.setSuccess(value: row);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Gets a map of formatting rules for the table's columns.",
    "description": "Builds a map where keys are column names and values are a list of `AcEnumDDColumnFormat` rules, derived from the column's data type (e.g., `json`, `password`). This is used by `getRows` to format results.",
    "params": [
      {"name": "getPasswordColumns", "description": "If false (default), password columns are marked for hiding."}
    ],
    "returns": "A map of column names to their formatting rules.",
    "returns_type": "Map<String, List<AcEnumDDColumnFormat>>"
  }) */
  Map<String, List<AcEnumDDColumnFormat>> getColumnFormats({
    bool getPasswordColumns = false,
  }) {
    Map<String, List<AcEnumDDColumnFormat>> result = {};
    for (final acDDTableColumn in acDDTable.tableColumns) {
      List<AcEnumDDColumnFormat> columnFormats = [];
      if (acDDTableColumn.columnType == AcEnumDDColumnType.json) {
        columnFormats.add(AcEnumDDColumnFormat.json);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.date) {
        columnFormats.add(AcEnumDDColumnFormat.date);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.password &&
          !getPasswordColumns) {
        columnFormats.add(AcEnumDDColumnFormat.hideColumn);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.encrypted) {
        columnFormats.add(AcEnumDDColumnFormat.encrypt);
      }
      if (columnFormats.isNotEmpty) {
        result[acDDTableColumn.columnName] = columnFormats;
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Generates a SELECT statement for this table.",
    "description": "Constructs a `SELECT` statement, allowing for the inclusion or exclusion of specific columns. If no columns are specified, it defaults to `SELECT *`.",
    "params": [
      {"name": "includeColumns", "description": "A specific list of columns to include."},
      {"name": "excludeColumns", "description": "A list of columns to exclude from a `SELECT *`."}
    ],
    "returns": "The generated SELECT statement string.",
    "returns_type": "String"
  }) */
  String getSelectStatement({
    List<String> includeColumns = const [],
    List<String> excludeColumns = const [],
  }) {
    String result = "";
    String fromName = acDDTable.getSelectQueryFromName();
    List<String> columns = [];
    if (includeColumns.isEmpty && excludeColumns.isEmpty) {
      columns = ["*"];
    } else {
      if (includeColumns.isNotEmpty) {
        columns = includeColumns;
      } else if (excludeColumns.isNotEmpty) {
        columns = excludeColumns; // Corrected logic
      }
    }
    result = "SELECT ${columns.join(", ")} FROM $fromName";
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a list of distinct values for a specific column.",
    "params": [
      {"name": "columnName", "description": "The column to get distinct values from."},
      {"name": "condition", "description": "An optional WHERE clause to filter the results."},
      {"name": "orderBy", "description": "An optional ORDER BY clause."},
      {"name": "mode", "description": "The selection mode (e.g., `list` or `count`)."},
      {"name": "pageNumber", "description": "The page number for pagination."},
      {"name": "pageSize", "description": "The number of records per page."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."}
    ],
    "returns": "An `AcSqlDaoResult` containing the list of distinct values.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getDistinctColumnValues({
    required String columnName,
    String condition = "",
    String orderBy = "",
    AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
    int pageNumber = -1,
    int pageSize = -1,
    Map<String, dynamic> parameters = const {},
  }) async {
    parameters = Map.from(parameters);
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    try {
      String actualOrderBy = orderBy.isNotEmpty ? orderBy : columnName;

      String selectStatement = getSelectStatement();
      selectStatement =
          "SELECT DISTINCT $columnName FROM ($selectStatement) AS recordsList";
      if (condition.isNotEmpty) {
        condition += " AND $columnName IS NOT NULL AND $columnName != ''";
      } else {
        condition = " $columnName IS NOT NULL AND $columnName != ''";
      }
      logger.log([
        "",
        "",
        "Executing getDistinctColumnValues select statement",
      ]);
      final sqlStatement = AcDDSelectStatement.generateSqlStatement(
        selectStatement: selectStatement,
        condition: condition,
        orderBy: actualOrderBy,
        pageNumber: pageNumber,
        pageSize: pageSize,
        databaseType: databaseType,
      );
      result = await dao!.getRows(
        statement: sqlStatement,
        parameters: parameters,
        mode: mode,
      );
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  Future<AcResult> getInsertRowData({required Map<String, dynamic> row}) async{
    AcResult result = AcResult();
    final formatResult = await formatValues(row: row,insertMode: true);
    if (formatResult.isSuccess()) {
      result.setSuccess(value:formatResult.value);
    } else {
      result.setFromResult(result:result);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves rows from the table.",
    "description": "The primary method for querying the table. It constructs and executes a SELECT statement with optional conditions, ordering, and pagination.",
    "params": [
      {"name": "selectStatement", "description": "An optional full SELECT statement to use instead of the default."},
      {"name": "condition", "description": "A WHERE clause to filter rows."},
      {"name": "orderBy", "description": "An ORDER BY clause."},
      {"name": "mode", "description": "The selection mode (e.g., `list` or `count`)."},
      {"name": "pageNumber", "description": "The page number for pagination."},
      {"name": "pageSize", "description": "The number of records per page."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."}
    ],
    "returns": "An `AcSqlDaoResult` containing the fetched rows.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getRows({
    String selectStatement = "",
    String condition = "",
    String orderBy = "",
    AcEnumDDSelectMode mode = AcEnumDDSelectMode.list,
    int pageNumber = -1,
    int pageSize = -1,
    Map<String, dynamic> parameters = const {},
  }) async {
    parameters = Map.from(parameters);
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    try {
      String actualSelectStatement = selectStatement.isNotEmpty ? selectStatement : getSelectStatement();
      final sqlStatement = AcDDSelectStatement.generateSqlStatement(
        selectStatement: actualSelectStatement,
        condition: condition,
        orderBy: orderBy,
        pageNumber: pageNumber,
        pageSize: pageSize,
        databaseType: databaseType,
      );
      result = await dao!.getRows(
        statement: sqlStatement,
        parameters: parameters,
        mode: mode,
        columnFormats: getColumnFormats(),
      );
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Executes a pre-configured `AcDDSelectStatement` against this table.",
    "description": "A convenience method to run a complex query defined in an `AcDDSelectStatement` object. It also automatically fetches the total row count for pagination.",
    "params": [
      {"name": "acDDSelectStatement", "description": "The configured select statement object."}
    ],
    "returns": "An `AcSqlDaoResult` containing the fetched rows and total row count.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> getRowsFromAcDDStatement({
    required AcDDSelectStatement acDDSelectStatement,
  }) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.select);
    try {
      String sqlStatement = acDDSelectStatement.getSqlStatement();
      Map<String, dynamic> sqlParameters = acDDSelectStatement.parameters;
      result = await dao!.getRows(
        statement: sqlStatement,
        parameters: sqlParameters,
        columnFormats: getColumnFormats(),
      );
      if (result.rows.isNotEmpty) {
        String countSqlStatement = acDDSelectStatement.getSqlStatement(
          skipLimit: true,
        );
        var countResult = await dao!.getRows(
          statement: countSqlStatement,
          parameters: sqlParameters,
          mode: AcEnumDDSelectMode.count
        );
        if (countResult.isSuccess()) {
          result.totalRows = countResult.totalRows;
        }
      } else {
        result.totalRows = 0;
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Inserts a single row into the table, with full event handling.",
    "description": "Orchestrates the insert lifecycle:\n1. Validates the row data.\n2. Generates UUIDs or auto-numbers.\n3. Fires a `beforeInsert` event.\n4. Executes the `INSERT` statement.\n5. Fires an `afterInsert` event.",
    "params": [
      {"name": "row", "description": "A map representing the row to insert."},
      {"name": "validateResult", "description": "An optional, pre-computed validation result."},
      {"name": "executeBeforeEvent", "description": "Whether to fire the `beforeInsert` event."},
      {"name": "executeAfterEvent", "description": "Whether to fire the `afterInsert` event."}
    ],
    "returns": "An `AcSqlDaoResult` containing the newly inserted row and its primary key.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> insertRow({
    required Map<String, dynamic> row,
    AcResult? validateResult,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
    try {
      logger.log(["Inserting row with data : ", row]);

      bool continueOperation = true;
      final formatResult = await formatValues(row: row,insertMode: true);
      if (formatResult.isSuccess()) {
        row = formatResult.value;
      } else {
        continueOperation = false;
      }

      validateResult ??= await validateValues(row: row, isInsert: true);
      logger.log(["Validation result : ", validateResult]);
      if (validateResult.isSuccess()) {

        final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
        dynamic primaryKeyValue = row[primaryKeyColumn];
        if (row.isNotEmpty) {
          if (continueOperation) {
            if (executeBeforeEvent) {
              logger.log("Executing before insert event");
              final rowEvent = AcSqlDbRowEvent(
                tableName: tableName,
                dataDictionaryName: dataDictionaryName,
              );
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.beforeInsert;
              final eventResult = await rowEvent.execute();
              logger.log(["Before insert result", eventResult]);
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(
                  result: eventResult,
                  message: "Aborted from before insert row events",
                );
              }
            }
          }
          if (continueOperation) {
            logger.log(["Inserting data : ", row]);
            final insertResult = await dao!.insertRow(
              tableName: tableName,
              row: row,
            );
            logger.log(insertResult.toString());
            if (insertResult.isSuccess()) {
              result.primaryKeyColumn = primaryKeyColumn;
              result.primaryKeyValue = primaryKeyValue;
              if (primaryKeyColumn.isNotEmpty) {
                if (!Autocode.validPrimaryKey(primaryKeyValue) &&
                    Autocode.validPrimaryKey(insertResult.lastInsertedId)) {
                  primaryKeyValue = insertResult.lastInsertedId;
                }
              }
              result.lastInsertedId = primaryKeyValue;
              logger.log("Getting inserted row from database");
              final condition = "$primaryKeyColumn = @primaryKeyValue";
              final parameters = {"@primaryKeyValue": primaryKeyValue};
              logger.log(["Select condition", condition, parameters]);
              final selectResult = await getRows(
                condition: condition,
                parameters: parameters,
              );
              if (selectResult.isSuccess()) {
                logger.log(["Select executed successfully",selectResult]);
                if (selectResult.hasRows()) {
                  result.rows = selectResult.rows;
                }
                else{
                  continueOperation = false;
                  result.setFailure(message: 'Row inserted but cannot get inserted row',logger: logger);
                }
              } else {
                logger.error(["Error executing select statement"]);
                continueOperation = false;
                result.setFromResult(result: selectResult,logger: logger);
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName,
                );
                rowEvent.eventType = AcEnumDDRowEvent.afterInsert;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  // result = eventResult;
                } else {
                  continueOperation=false;
                  result.setFromResult(result: eventResult,logger: logger);
                }
              }
            } else {
              continueOperation=false;
              result.setFromResult(result: insertResult,logger: logger);
            }
          }
        } else {
          result.message = 'No values for new row';
        }
      } else {
        continueOperation=false;
        result.setFromResult(result: validateResult,logger: logger);
      }
      if(continueOperation){
        result.setSuccess(message: "Row inserted successfully");
      }
    } catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Inserts multiple rows into the table in a batch, with event handling.",
    "description": "Processes a list of rows, validates each one, fires `beforeInsert` events, and then executes the `INSERT` statements, typically within a transaction.",
    "params": [
      {"name": "rows", "description": "A list of maps, where each map is a row to insert."},
      {"name": "executeBeforeEvent", "description": "Whether to fire `beforeInsert` events for each row."},
      {"name": "executeAfterEvent", "description": "Whether to fire `afterInsert` events for each row."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the bulk operation.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> insertRows({
    required List<Map<String, dynamic>> rows,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert);
    try {
      logger.log(["Inserting rows : ", rows]);
      bool continueOperation = true;
      List<Map<String, dynamic>> rowsToInsert = [];
      List<dynamic> primaryKeyValues = [];
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      for (var row in rows) {
        if (continueOperation) {
          final formatResult = await formatValues(row: row,insertMode: true);
          if (formatResult.isSuccess()) {
            row = formatResult.value;
          } else {
            continueOperation = false;
          }

          final validateResult = await validateValues(row: row, isInsert: true);
          if (validateResult.isSuccess()) {
            if (row.containsKey(primaryKeyColumn)) {
              primaryKeyValues.add(row[primaryKeyColumn]);
            }
            if (row.isNotEmpty) {
              if (continueOperation) {
                if (executeBeforeEvent) {
                  logger.log("Executing before insert event");
                  final rowEvent = AcSqlDbRowEvent(
                    tableName: tableName,
                    dataDictionaryName: dataDictionaryName,
                  );
                  rowEvent.row = row;
                  rowEvent.eventType = AcEnumDDRowEvent.beforeInsert;
                  final eventResult = await rowEvent.execute();
                  logger.log(["Before insert result", eventResult]);
                  if (eventResult.isSuccess()) {
                    row = rowEvent.row;
                  } else {
                    continueOperation = false;
                    result.setFromResult(
                      result: eventResult,
                      message: "Aborted from before insert row events",
                    );
                  }
                }
              }
              if (continueOperation) {
                rowsToInsert.add(row);
              }
            } else {
              result.message = 'No values for new row';
            }
          } else {
            result.setFromResult(result: validateResult);
            continueOperation = false;
          }
        }
      }
      if (continueOperation) {
        logger.log("Inserting ${rows.length} rows");
        final insertResult = await dao!.insertRows(
          tableName: tableName,
          rows: rowsToInsert,
        );
        if (insertResult.isSuccess()) {
          logger.log(insertResult.toString());
          result.lastInsertedIds = primaryKeyValues;
          logger.log("Getting inserted rows from database");
          final condition = "$primaryKeyColumn IN (:primaryKeyValue)";
          final parameters = {":primaryKeyValue": primaryKeyValues};
          logger.log(["Select condition", condition, parameters]);
          final selectResult = await getRows(
            condition: condition,
            parameters: parameters,
          );
          if (selectResult.isSuccess()) {
            if (selectResult.hasRows()) {
              result.rows = selectResult.rows;
            }
          } else {
            result.message =
                'Error getting inserted rows : ${selectResult.message}';
          }
          if (continueOperation && executeAfterEvent) {
            for (final row in result.rows) {
              // Changed to result.rows
              final rowEvent = AcSqlDbRowEvent(
                tableName: tableName,
                dataDictionaryName: dataDictionaryName,
              );
              rowEvent.eventType = AcEnumDDRowEvent.afterInsert;
              rowEvent.result = result;
              rowEvent.row = row;
              final eventResult = await rowEvent.execute();
              if (!eventResult.isSuccess()) {
                // check for failure
                continueOperation = false;
                result.setFromResult(result: eventResult); // set the error
                break; // exit loop on error
              }
            }
          }
        } else {
          continueOperation = false;
          result.setFromResult(result: insertResult);
        }
      }
      if (continueOperation) {
        result.setSuccess(message: "Rows inserted successfully");
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Saves a row, performing an 'upsert' (insert or update) operation.",
    "description": "This method intelligently determines whether to insert a new row or update an existing one. It first tries to find an existing record based on the primary key or columns marked with `checkInSave`. If a record is found, it performs an update; otherwise, it performs an insert.",
    "params": [
      {"name": "row", "description": "The row data to save."},
      {"name": "executeBeforeEvent", "description": "Whether to fire `beforeSave` events."},
      {"name": "executeAfterEvent", "description": "Whether to fire `afterSave` events."}
    ],
    "returns": "An `AcSqlDaoResult` containing the final state of the saved row.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> saveRow({
    required Map<String, dynamic> row,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.unknown);
    try {
      bool continueOperation = true;
      var operation = AcEnumDDRowOperation.unknown;
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      dynamic primaryKeyValue = row[primaryKeyColumn];
      String condition = "";
      Map<String, dynamic> conditionParameters = {};

      if (Autocode.validPrimaryKey(primaryKeyValue)) {
        logger.log("Found primary key value so primary key value will be used");
        condition = "$primaryKeyColumn = :primaryKeyValue";
        conditionParameters[":primaryKeyValue"] = primaryKeyValue;
      } else {
        final Map<String, dynamic> checkInSaveColumns = {};
        for (final column in acDDTable.tableColumns) {
          if (column.checkInSave()) {
            checkInSaveColumns[column.columnName] = row[column.columnName];
          }
        }

        logger.log(
          "Not found primary key value so checking for columns while saving",
        );
        if (checkInSaveColumns.isNotEmpty) {
          final List<String> checkConditions = [];
          conditionParameters = {};
          checkInSaveColumns.forEach((key, value) {
            checkConditions.add("$key = :$key");
            conditionParameters[":$key"] = value;
          });
          condition = checkConditions.join(" AND ");
        }
      }

      if (condition.isNotEmpty) {
        final getResult = await getRows(
          condition: condition,
          parameters: conditionParameters,
        );
        if (getResult.isSuccess()) {
          if (getResult.hasRows()) {
            final existingRecord = getResult.rows.first;
            if (existingRecord.containsKey(primaryKeyColumn)) {
              primaryKeyValue = existingRecord[primaryKeyColumn];
              row[primaryKeyColumn] = primaryKeyValue;
              operation = AcEnumDDRowOperation.update;
            } else {
              continueOperation = false;
              result.message = "Row does not have primary key value";
            }
          } else {
            operation = AcEnumDDRowOperation.insert;
          }
        } else {
          continueOperation = false;
          result.setFromResult(result: getResult);
        }
      } else {
        operation = AcEnumDDRowOperation.insert;
      }

      if (operation != AcEnumDDRowOperation.insert &&
          operation != AcEnumDDRowOperation.update) {
        result.message = "Invalid Operation";
        continueOperation = false;
      }

      if (continueOperation) {
        logger.log("Executing operation $operation in save.");
        if (executeBeforeEvent) {
          final rowEvent = AcSqlDbRowEvent(
            tableName: tableName,
            dataDictionaryName: dataDictionaryName,
          );
          rowEvent.row = row;
          rowEvent.eventType = AcEnumDDRowEvent.beforeSave;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            row = rowEvent.row;
          } else {
            continueOperation = false;
            result.setFromResult(
              result: eventResult,
              message: "Aborted from before update row events",
              logger: logger,
            );
          }
        }
        if (operation == AcEnumDDRowOperation.insert) {
          AcSqlDaoResult insertResult = await insertRow(row: row);
          logger.log(["Insert result",insertResult]);
          if(insertResult.isFailure()){
            result.setFromResult(result: insertResult);
            continueOperation = false;
          }
          else{
            logger.log(["Setting insert result as result of save operation"]);
            result = insertResult;
          }
        } else if (operation == AcEnumDDRowOperation.update) {
          AcSqlDaoResult updateResult = await updateRow(row: row);
          logger.log(["Update result",updateResult]);
          if(updateResult.isFailure()){
            result.setFromResult(result: updateResult);
            continueOperation = false;
          }
          else{
            logger.log(["Setting update result as result of save operation"]);
            result = updateResult;
          }
        } else {
          continueOperation = false; // Redundant, but good for clarity
        }

        if (continueOperation && executeAfterEvent) {
          final rowEvent = AcSqlDbRowEvent(
            tableName: tableName,
            dataDictionaryName: dataDictionaryName,
          );
          rowEvent.eventType = AcEnumDDRowEvent.afterSave;
          rowEvent.result = result;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            // result.setFromResult(eventResult.result);
          } else {
            continueOperation = false;
            result.setFromResult(result: eventResult);
          }
        }
      }

      if(continueOperation){
        result.setSuccess();
      }

      logger.log(["Final save result",result]);
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Saves a list of rows, performing 'upsert' operations for each.",
    "description": "Processes a list of rows, determining for each one whether it needs to be inserted or updated. This is useful for synchronizing a batch of data with the database.",
    "params": [
      {"name": "rows", "description": "The list of row data maps to save."},
      {"name": "executeBeforeEvent", "description": "Whether to fire `beforeSave` events."},
      {"name": "executeAfterEvent", "description": "Whether to fire `afterSave` events."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the batch save operation.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> saveRows({
    required List<Map<String, dynamic>> rows,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.unknown);
    try {
      bool continueOperation = true;
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      List<Map<String, dynamic>> rowsToInsert = [];
      List<Map<String, dynamic>> rowsToUpdate = [];

      for (final row in rows) {
        if (continueOperation) {
          dynamic primaryKeyValue = row[primaryKeyColumn];
          String condition = "";
          Map<String, dynamic> conditionParameters = {};

          if (Autocode.validPrimaryKey(primaryKeyValue)) {
            logger.log(
              "Found primary key value so primary key value will be used",
            );
            condition = "$primaryKeyColumn = :primaryKeyValue";
            conditionParameters[":primaryKeyValue"] = primaryKeyValue;
          } else {
            final Map<String, dynamic> checkInSaveColumns = {};
            for (final column in acDDTable.tableColumns) {
              if (column.checkInSave()) {
                checkInSaveColumns[column.columnName] = row[column.columnName];
              }
            }
            logger.log(
              "Not found primary key value so checking for columns while saving",
            );
            if (checkInSaveColumns.isNotEmpty) {
              final List<String> checkConditions = [];
              conditionParameters = {};
              checkInSaveColumns.forEach((key, value) {
                checkConditions.add("$key = :$key");
                conditionParameters[":$key"] = value;
              });
              condition = checkConditions.join(" AND ");
            } else {
              continueOperation = false;
              result.setFailure(
                message: "No values to check in save",
                logger: logger,
              );
            }
          }

          if (condition.isNotEmpty) {
            final getResult = await getRows(
              condition: condition,
              parameters: conditionParameters,
            );
            if (getResult.isSuccess()) {
              if (getResult.hasRows()) {
                final existingRecord = getResult.rows.first;
                if (existingRecord.containsKey(primaryKeyColumn)) {
                  primaryKeyValue = existingRecord[primaryKeyColumn];
                  row[primaryKeyColumn] = primaryKeyValue;
                  rowsToUpdate.add(row);
                } else {
                  continueOperation = false;
                  result.message = "Row does not have primary key value";
                }
              } else {
                rowsToInsert.add(row);
              }
            } else {
              continueOperation = false;
              result.setFromResult(result: getResult);
            }
          } else {
            rowsToInsert.add(row);
          }
        }
      }

      if (continueOperation) {
        if (executeBeforeEvent) {
          for (var row in rowsToInsert) {
            if (continueOperation) {
              final rowEvent = AcSqlDbRowEvent(
                tableName: tableName,
                dataDictionaryName: dataDictionaryName,
              );
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.beforeSave;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(
                  result: eventResult,
                  message: "Aborted from before save row events",
                  logger: logger,
                );
              }
            }
          }
          for (var row in rowsToUpdate) {
            if (continueOperation) {
              final rowEvent = AcSqlDbRowEvent(
                tableName: tableName,
                dataDictionaryName: dataDictionaryName,
              );
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.beforeSave;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(
                  result: eventResult,
                  message: "Aborted from before save row events",
                  logger: logger,
                );
              }
            }
          }
        }
        List<Map<String, dynamic>> combinedRows = [];
        if (continueOperation) {
          final insertResult = await insertRows(rows: rowsToInsert);
          if (insertResult.isFailure()) {
            continueOperation = false;
            result.setFromResult(result: insertResult);
          } else {
            combinedRows.addAll(insertResult.rows);
          }
        }
        if (continueOperation) {
          final updateResult = await updateRows(rows: rowsToUpdate);
          if (updateResult.isFailure()) {
            continueOperation = false;
            result.setFromResult(result: updateResult);
          } else {
            combinedRows.addAll(updateResult.rows);
          }
        }
        if (continueOperation) {
          result.setSuccess(message: "Rows saved successfully");
          if (result.rows.isNotEmpty) {
            combinedRows.addAll(result.rows);
          }
          result.rows = combinedRows;
        }
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Sets related foreign key columns to null before a delete.",
    "description": "As part of the delete process, this method finds tables that reference the records being deleted and, if configured via the `setNullBeforeDelete` property, updates their foreign key columns to NULL to prevent constraint violations.",
    "params": [
      {"name": "condition", "description": "The WHERE clause identifying the primary records being deleted."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."}
    ],
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> setValuesNullBeforeDelete({
    required String condition,
    Map<String, dynamic> parameters = const {},
  }) async {
    parameters = Map.from(parameters);
    final result = AcResult();
    try {
      bool continueOperation = true;
      logger.log("Checking cascade delete for table $tableName");
      final tableRelationships = AcDataDictionary.getTableRelationships(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );

      for (final acRelationship in tableRelationships) {
        if (continueOperation) {
          if (acRelationship.destinationTable == tableName) {
            final column = acDDTable.getColumn(
              acRelationship.destinationColumn,
            );
            if (column != null) {
              if (column.isSetValuesNullBeforeDelete()) {
                final setNullStatement =
                    "UPDATE ${acRelationship.sourceTable} SET ${acRelationship.sourceColumn} = NULL WHERE ${acRelationship.sourceColumn} IN (SELECT ${acRelationship.destinationColumn} FROM $tableName WHERE $condition)";
                logger.log(["Executing set null statement", setNullStatement]);
                final setNullResult = await dao!.executeStatement(
                  statement: setNullStatement,
                  parameters: parameters,
                );
                if (setNullResult.isSuccess()) {
                  logger.success(setNullResult.toJson());
                } else {
                  continueOperation = false;
                  result.setFromResult(result: setNullResult);
                }
              }
            }
            // }
          }
        }
      }
      if (continueOperation) {
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Updates a row in the table, with full event handling.",
    "description": "Orchestrates the update lifecycle:\n1. Validates the row data.\n2. Formats values (e.g., encryption).\n3. Fires a `beforeUpdate` event.\n4. Executes the `UPDATE` statement.\n5. Fires an `afterUpdate` event.",
    "params": [
      {"name": "row", "description": "A map of column names to their new values."},
      {"name": "condition", "description": "The WHERE clause to identify the row(s) to update. If empty, the primary key from the `row` data is used."},
      {"name": "parameters", "description": "Parameters for the WHERE clause."},
      {"name": "validateResult", "description": "An optional, pre-computed validation result."},
      {"name": "executeBeforeEvent", "description": "Whether to fire the `beforeUpdate` event."},
      {"name": "executeAfterEvent", "description": "Whether to fire the `afterUpdate` event."}
    ],
    "returns": "An `AcSqlDaoResult` containing the final state of the updated row(s).",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> updateRow({
    required Map<String, dynamic> row,
    String condition = "",
    Map<String, dynamic> parameters = const {},
    AcResult? validateResult,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    parameters = Map.from(parameters);
    logger.log(["Updating row with data : ", row]);
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
    try {
      bool continueOperation = true;

      final formatResult = await formatValues(row: row);
      if (formatResult.isSuccess()) {
        row = formatResult.value;
      } else {
        continueOperation = false;
      }

      validateResult ??= await validateValues(row: row, isInsert: false);

      if (validateResult.isSuccess() && continueOperation) {
        logger.log(["Validation result : ", validateResult]);
        final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
        final primaryKeyValue = row[primaryKeyColumn];


        logger.log(["Formatted data : ", row]);

        if (condition.isEmpty && Autocode.validPrimaryKey(primaryKeyValue)) {
          condition = "$primaryKeyColumn = :primaryKeyValue";
          parameters = {":primaryKeyValue": primaryKeyValue};
        }
        logger.log(["Update condition : $condition", parameters]);

        if (row.isNotEmpty) {
          if (continueOperation) {
            if (executeBeforeEvent) {
              logger.log("Executing before update event");
              final rowEvent = AcSqlDbRowEvent(
                tableName: tableName,
                dataDictionaryName: dataDictionaryName,
              );
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.beforeUpdate;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                logger.log(["Before event result", eventResult]);
                row = rowEvent.row;
              } else {
                logger.error(["Before event result", eventResult]);
                continueOperation = false;
                result.setFromResult(
                  result: eventResult,
                  message: "Aborted from before update row events",
                );
              }
            } else {
              logger.log("Skipping before update event");
            }
          }
          if (continueOperation) {
            final updateResult = await dao!.updateRow(
              tableName: tableName,
              row: row,
              condition: condition,
              parameters: parameters,
            );
            if (updateResult.isSuccess()) {
              result.setSuccess(
                message: "Row updated successfully",
                logger: logger,
              );
              result.primaryKeyColumn = primaryKeyColumn;
              result.primaryKeyValue = primaryKeyValue;
              final selectResult = await getRows(
                condition: condition,
                parameters: parameters,
              );
              if (selectResult.isSuccess()) {
                result.rows = selectResult.rows;
              } else {
                logger.error([
                  'Error getting updated row : ${selectResult.message}',
                  selectResult,
                ]);
                result.message =
                    'Error getting updated row : ${selectResult.message}';
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName,
                );
                rowEvent.eventType = AcEnumDDRowEvent.afterUpdate;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["After event result", eventResult]);
                  // result.setFromResult(eventResult.result);
                } else {
                  logger.error(["After event result", eventResult]);
                  continueOperation = false;
                  result.setFromResult(result: eventResult);
                }
              }
            } else {
              continueOperation = false;
              result.setFromResult(result: updateResult, logger: logger);
            }
          }
        } else {
          logger.log("No data to update");
          result.message = 'No values to update row';
        }
      } else {
        logger.error(["Validation result : ", validateResult]);
        result.setFromResult(result: validateResult);
        continueOperation = false;
      }
      if(continueOperation){
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Updates multiple rows in the table in a batch, with event handling.",
    "description": "Processes a list of rows, validates each one, fires `beforeUpdate` events, and then executes the `UPDATE` statements, typically within a transaction.",
    "params": [
      {"name": "rows", "description": "A list of maps, where each map is a row to update. Each row must contain a primary key to identify it."},
      {"name": "executeBeforeEvent", "description": "Whether to fire `beforeUpdate` events for each row."},
      {"name": "executeAfterEvent", "description": "Whether to fire `afterUpdate` events for each row."}
    ],
    "returns": "An `AcSqlDaoResult` summarizing the batch update.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> updateRows({
    required List<Map<String, dynamic>> rows,
    bool executeAfterEvent = true,
    bool executeBeforeEvent = true,
  }) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.update);
    try {
      bool continueOperation = true;
      List<Map<String, dynamic>> rowsWithConditions = [];
      List<dynamic> primaryKeyValues = [];
      int index = -1;
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      for (var row in rows) {
        index++;
        if (continueOperation) {
          logger.log(["Updating row with data : ", row]);
          final formatResult = await formatValues(row: row);
          if (formatResult.isSuccess()) {
            row = formatResult.value;
          } else {
            continueOperation = false;
          }

          final validateResult = await validateValues(
            row: row,
            isInsert: false,
          );
          if (validateResult.isSuccess() && continueOperation) {
            logger.log(["Validation result : ", validateResult]);
            final primaryKeyValue = row[primaryKeyColumn];
            logger.log(["Formatted data : ", row]);
            if (row.isNotEmpty && Autocode.validPrimaryKey(primaryKeyValue)) {
              final condition = "$primaryKeyColumn = :primaryKeyValue$index";
              final parameters = {":primaryKeyValue$index": primaryKeyValue};
              primaryKeyValues.add(primaryKeyValue);
              rowsWithConditions.add({
                "row": row,
                "condition": condition,
                "parameters": parameters,
              });
            }
          } else {
            logger.error(["Validation result : ", validateResult]);
            result.setFromResult(result: validateResult);
            continueOperation = false;
          }
        }
      }
      if (continueOperation) {
        if (rowsWithConditions.isNotEmpty) {
          if (executeBeforeEvent) {
            if (continueOperation) {
              for (var rowDetails in rowsWithConditions) {
                logger.log("Executing before update event");
                final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName,
                );
                rowEvent.row = rowDetails["row"];
                rowEvent.condition = rowDetails["condition"];
                rowEvent.parameters = rowDetails["parameters"];
                rowEvent.eventType = AcEnumDDRowEvent.beforeUpdate;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["Before event result", eventResult]);
                  // row = rowEvent.row;
                } else {
                  logger.error(["Before event result", eventResult]);
                  continueOperation = false;
                  result.setFromResult(
                    result: eventResult,
                    message: "Aborted from before update row events",
                  );
                }
              }
            }
          } else {
            logger.log("Skipping before update event");
          }
          if (continueOperation) {
            final updateResult = await dao!.updateRows(
              tableName: tableName,
              rowsWithConditions: rowsWithConditions,
            );
            if (updateResult.isSuccess()) {
              result.setSuccess(
                message: "Rows updated successfully",
                logger: logger,
              );
              final selectResult = await getRows(
                condition: "$primaryKeyColumn IN (@primaryKeyValues)",
                parameters: {"@primaryKeyValues": primaryKeyValues},
              ); // Corrected parameter name
              if (selectResult.isSuccess()) {
                result.rows = selectResult.rows;
              } else {
                continueOperation = false;
                logger.error([
                  'Error getting updated row : ${selectResult.message}',
                  selectResult,
                ]);
                result.message =
                    'Error getting updated row : ${selectResult.message}';
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName,
                );
                rowEvent.eventType = AcEnumDDRowEvent.afterUpdate;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["After event result", eventResult]);
                  // result.setFromResult(result.eventResult.result);
                } else {
                  logger.error(["After event result", eventResult]);
                  continueOperation = false;
                  result.setFromResult(result: eventResult);
                }
              }
            } else {
              continueOperation = false;
              result.setFromResult(result: updateResult, logger: logger);
            }
          }
        } else {
          result.message = "Nothing to update";
        }
      }
      if(continueOperation){
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "A string padding utility.",
    "description": "Pads a string on the left with a given character to reach a specified total length.",
    "params": [
      {"name": "value", "description": "The original string value."},
      {"name": "char", "description": "The character to use for padding."},
      {"name": "length", "description": "The desired total length of the final string."}
    ],
    "returns": "The padded string.",
    "returns_type": "String"
  }) */
  String updateValueLengthWithChars({
    required String value,
    required String char,
    required int length,
  }) {
    String result = value;
    if (length > 0) {
      int currentLength = value.length;
      if (currentLength < length) {
        result = char * (length - currentLength) + value;
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Validates a row of data against the table's column definitions.",
    "description": "Checks for required fields, correct data types (for numerics and datetimes), and unique key constraints.",
    "params": [
      {"name": "row", "description": "The row data map to validate."},
      {"name": "isInsert", "description": "If true, checks apply to an insert operation (e.g., all required fields must be present)."}
    ],
    "returns": "An `AcResult` that is successful if the validation passes, or fails with a message if it does not.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> validateValues({
    required Map<String, dynamic> row,
    bool isInsert = false,
  }) async {
    final result = AcResult();
    try {
      bool continueOperation = true;
      for (final column in acDDTable.tableColumns) {
        dynamic value = row[column.columnName];
        if (continueOperation) {
          if (column.isRequired() && isInsert) {
            bool validRequired = true;
            if (!row.containsKey(column.columnName) && isInsert) {
              validRequired = false;
            } else if ((value is String && value.trim().isEmpty) ||
                value == null) {
              validRequired = false;
            }
            if (!validRequired) {
              continueOperation = false;
              result.setFailure(message: "${column.columnName} value is missing");
            }
          }
        }
        if (continueOperation) {
          if (column.columnType == AcEnumDDColumnType.integer ||
              column.columnType == AcEnumDDColumnType.double_) {
            if (value != null && value is! num) {
              result.setFailure(
                message:
                    "Invalid numeric value for column : ${column.columnName}",
              );
              break;
            }
          } else if (column.columnType == AcEnumDDColumnType.date ||
              column.columnType == AcEnumDDColumnType.datetime ||
              column.columnType == AcEnumDDColumnType.time) {
            if (value != null && value != "null" && value != "NOW") {
              try {
                DateTime.parse(value);
              } catch (ex, stack) {
                result.setException(
                  message:
                      "Invalid datetime value for column : ${column.columnName}",
                  exception: ex,
                  stackTrace: stack,
                );
                break;
              }
            }
          }
        }
      }
      if (continueOperation) {
        final checkResponse = await checkUniqueValues(row: row);
        if (checkResponse.isFailure()) {
          continueOperation = false;
          result.setFromResult(result: checkResponse);
        }
      }
      if (continueOperation) {
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(
        exception: ex,
        stackTrace: stack,
        logger: logger,
        logException: true,
      );
    }
    return result;
  }
}
