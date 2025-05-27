import 'dart:convert';

import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_extensions/autocode_extensions.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbTable extends AcSqlDbBase {
  final String tableName;
  late AcDDTable acDDTable;

  AcSqlDbTable({required this.tableName, String dataDictionaryName = "default"}): super(dataDictionaryName: dataDictionaryName){
    acDDTable = AcDDTable.getInstance(tableName:tableName,dataDictionaryName: dataDictionaryName);
  }
  
  Future<AcResult> cascadeDeleteRows({required List<Map<String, dynamic>> rows}) async {
    final result = AcResult();
    try {
      logger.log("Checking cascade delete for table $tableName");
      final tableRelationships = AcDataDictionary.getTableRelationships(tableName: tableName);
      logger.log(["Table relationships : ", tableRelationships]);

      for (final row in rows) {
        logger.log(["Checking cascade delete for table row :", row]);
        for (final acRelationship in tableRelationships) {
          String deleteTableName = "";
          String deleteColumnName = "";
          dynamic deleteColumnValue;
          logger.log(["Checking cascade delete for relationship : ",acRelationship]);
          if (acRelationship.sourceTable == tableName &&
              acRelationship.cascadeDeleteDestination == true) {
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
              "Performing cascade delete with related table $deleteTableName and column $deleteColumnName with value $deleteColumnValue");
          if (deleteTableName.isNotEmpty && deleteColumnName.isNotEmpty) {
            if (Autocode.validPrimaryKey(deleteColumnValue)) {
              logger.log("Deleting related rows for primary key value : $deleteColumnValue");
              final deleteCondition = "$deleteColumnName = :deleteColumnValue";
              final deleteAcTable = AcSqlDbTable(tableName: deleteTableName, dataDictionaryName: dataDictionaryName);
              final deleteResult = await deleteAcTable.deleteRows(
                  condition: deleteCondition,
                  parameters: {":deleteColumnValue": deleteColumnValue});
              if (deleteResult.isSuccess()) {
                logger.log("Cascade delete successful for $deleteTableName");
              } else {
                return result.setFromResult(result:deleteResult,message: "Error in cascade delete: ${deleteResult.message}",logger: logger);
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
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcResult> checkAndSetAutoNumberValues({required Map<String, dynamic> row}) async {
    final result = AcResult();
    try {
      List<String> checkColumns = [];
      Map<String, Map<String, dynamic>> autoNumberColumns = {};

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
              "prefix_length": tableColumn.getAutoNumberPrefixLength()
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
              checkConditionValues["@checkColumn$checkColumn"] = row[checkColumn];
            }
          }
        }

        List<String> getRowsStatements = [];
        for (final name in selectColumnsList) {
          String columnGetRows = "";
          if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
            columnGetRows =
            "SELECT CONCAT('{\"$name\":',IF(MAX(CAST(SUBSTRING($name, ${autoNumberColumns[name]!["prefix_length"]} + 1) AS UNSIGNED)) IS NULL,0,MAX(CAST(SUBSTRING($name, ${autoNumberColumns[name]!["prefix_length"]} + 1) AS UNSIGNED))),'}') AS max_json FROM $tableName WHERE $name LIKE '${autoNumberColumns[name]!["prefix"]}%' $checkCondition";
          }
          if (columnGetRows.isNotEmpty) {
            getRowsStatements.add(columnGetRows);
          }
        }

        if (getRowsStatements.isNotEmpty) {
          final getRows = getRowsStatements.join(" UNION ");
          final selectResponse =
          await dao!.getRows(statement: getRows, parameters: checkConditionValues);
          if (selectResponse.isSuccess()) {
            final rows = selectResponse.rows;
            for (final rowData in rows) {
              final maxJson = jsonDecode(rowData["max_json"]) as Map<String, dynamic>;
              final name = maxJson.keys.first;
              int lastRecordId = maxJson[name] ?? 0;
              lastRecordId++;
              String autoNumberValue = autoNumberColumns[name]!["prefix"] + updateValueLengthWithChars(value:lastRecordId.toString(),char:"0",length:autoNumberColumns[name]!["length"]);
              row[name] = autoNumberValue;
            }
          } else {
            return result.setFromResult(result:selectResponse);
          }
        }
      }
      result.setSuccess(value:row);
    } on Exception catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcResult> checkUniqueValues({required Map<String, dynamic> row}) async {
    final result = AcResult();
    try {
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
              "${tableColumn.columnName} = @modify_${tableColumn.columnName}");
          parameters["@modify_${tableColumn.columnName}"] = value;
        }
        if (tableColumn.isUniqueKey()) {
          uniqueConditions.add(
              "${tableColumn.columnName} = @unique_${tableColumn.columnName}");
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
              mode: "COUNT");
          if (selectResponse.isSuccess()) {
            final rowsCount = selectResponse.rowsCount();
            if (rowsCount > 0) {
              result.setFailure(
                  value: {"unique_columns": uniqueColumns},
                  message: "Unique key violated");
            } else {
              result.setSuccess();
            }
          } else {
            result.setFromResult(result:selectResponse);
          }
        } else {
          result.setSuccess();
        }
      } else {
        logger.log("No unique conditions found");
        result.setSuccess();
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> deleteRows({String condition = "",String primaryKeyValue = "",Map<String, dynamic> parameters = const {},bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    logger.log(
        "Deleting row with condition : $condition & primaryKeyValue $primaryKeyValue");
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.DELETE);
    try {
      bool continueOperation = true;
      final primaryKeyColumnName = acDDTable.getPrimaryKeyColumnName();
      if (condition.isEmpty) {
        if (primaryKeyValue.isNotEmpty && primaryKeyColumnName.isNotEmpty) {
          condition = "$primaryKeyColumnName = :primaryKeyValue";
          parameters = {":primaryKeyValue": primaryKeyValue};
        } else {
          continueOperation = false;
          result.setFailure(message: 'Primary key column or column value is missing');
        }
      } else {
        condition =
        " $primaryKeyColumnName  IN (SELECT $primaryKeyColumnName FROM $tableName WHERE $condition)";
      }
      if (continueOperation) {
        if (executeBeforeEvent) {
          final rowEvent = AcSqlDbRowEvent(tableName: tableName, dataDictionaryName: dataDictionaryName);
          rowEvent.condition = condition;
          rowEvent.parameters = parameters;
          rowEvent.eventType = AcEnumDDRowEvent.BEFORE_DELETE;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            condition = rowEvent.condition;
            parameters = rowEvent.parameters;
          } else {
            continueOperation = false;
            result.setFromResult(result:eventResult,message: "Aborted from before delete row events");
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
          ""
        ]);
        final getResult = await getRows(condition: condition, parameters: parameters);
        if (getResult.isSuccess()) {
          result.rows = getResult.rows;
          final setNullResult = await setValuesNullBeforeDelete(condition: condition, parameters: parameters);
          if (setNullResult.isFailure()) {
            logger.error(['Error setting null before delete',setNullResult]);
            continueOperation = false;
            result.setFromResult(result:setNullResult);
          }
          if (continueOperation) {
            final cascadeDeleteResult = await cascadeDeleteRows(rows: result.rows);
            if (cascadeDeleteResult.isFailure()) {
              logger.error(['Error cascade deleting row',cascadeDeleteResult]);
              continueOperation = false;
              result.setFromResult(result:setNullResult, logger: logger);
            } else {
              logger.log(['Cascade delete result',cascadeDeleteResult]);
            }
          }
          if (continueOperation) {
            final deleteResult = await dao!.deleteRows(tableName: tableName, condition: condition, parameters: parameters);
            if (deleteResult.isSuccess()) {
              result.affectedRowsCount = deleteResult.affectedRowsCount;
              result.setSuccess(
                  message: "${deleteResult.affectedRowsCount} row(s) deleted successfully");
            } else {
              result.setFromResult(result:deleteResult);
              if (deleteResult.message.contains("foreign key")) {
                result.message =
                "Cannot delete row! Foreign key constraint is preventing from deleting rows!";
              }
            }
          }
        } else {
          result.setFromResult(result:getResult, logger: logger);
        }
      }
      if (continueOperation && executeAfterEvent) {
        final rowEvent = AcSqlDbRowEvent(tableName: tableName, dataDictionaryName: dataDictionaryName);
        rowEvent.eventType = AcEnumDDRowEvent.AFTER_DELETE;
        rowEvent.condition = condition;
        rowEvent.parameters = parameters;
        rowEvent.result = result;
        final eventResult = await rowEvent.execute();
        if (eventResult.isSuccess()) {
          result = rowEvent.result;
        } else {
          result.setFromResult(result:eventResult);
        }
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcResult> formatValues({required Map<String, dynamic> row, bool insertMode = false}) async {
    final result = AcResult();
    bool continueOperation = true;
    final rowEvent = AcSqlDbRowEvent(
        tableName: tableName, dataDictionaryName: dataDictionaryName);
    rowEvent.row = row;
    rowEvent.eventType = AcEnumDDRowEvent.BEFORE_FORMAT;
    final eventResult = await rowEvent.execute();
    if (eventResult.isSuccess()) {
      row = rowEvent.row;
    } else {
      result.setFromResult(result: eventResult);
      continueOperation = false;
    }
    if (continueOperation) {
      for (final column in acDDTable.tableColumns) {
        if (row.containsKey(column.columnName) || insertMode) {
          bool setColumnValue = row.containsKey(column.columnName);
          List<String> formats = column.getColumnFormats();
          String type = column.columnType;
          dynamic value = row[column.columnName] ?? "";
          if (value == "" && column.getDefaultValue() != null && insertMode) {
            value = column.getDefaultValue();
            setColumnValue = true;
          }
          if (setColumnValue) {
            if ([
              AcEnumDDColumnType.DATE,
              AcEnumDDColumnType.DATETIME,
              AcEnumDDColumnType.STRING
            ].contains(type)) {
              value = value.toString().trim();
              if (type == AcEnumDDColumnType.STRING) {
                if (formats.contains(AcEnumDDColumnFormat.LOWERCASE)) {
                  value = value.toLowerCase();
                }
                if (formats.contains(AcEnumDDColumnFormat.UPPERCASE)) {
                  value = value.toUpperCase();
                }
                if (formats.contains(AcEnumDDColumnFormat.ENCRYPT)) {
                  value = AcEncryption.encrypt(plainText: value);
                }
              } else if ([AcEnumDDColumnType.DATETIME,AcEnumDDColumnType.DATE].contains(type) && value.isNotEmpty) {
                try {
                  DateTime dateTimeValue = DateTime.parse(value);
                  String format = (type == AcEnumDDColumnType.DATETIME) ? 'yyyy-MM-dd HH:mm:ss' : 'yyyy-MM-dd';
                  value = dateTimeValue.format(format);
                } catch (e) {
                  logger.warn("Error while setting dateTimeValue for ${column.columnName} in table $tableName with value: $value");
                }
              }
            } else if ([
              AcEnumDDColumnType.JSON,
              AcEnumDDColumnType.MEDIA_JSON
            ].contains(type)) {
              value = value is String ? value : json.encode(value);
            } else if (type == AcEnumDDColumnType.PASSWORD) {
              value = AcEncryption.encrypt(plainText: value);
            }
            row[column.columnName] = value;
          }
        }
      }
    }
    if (continueOperation) {
      final rowEvent = AcSqlDbRowEvent(tableName: tableName, dataDictionaryName: dataDictionaryName);
      rowEvent.row = row;
      rowEvent.eventType = AcEnumDDRowEvent.AFTER_FORMAT;
      final eventResult = await rowEvent.execute();
      if (eventResult.isSuccess()) {
        row = rowEvent.row;
      } else {
        result.setFromResult(result:eventResult);
        continueOperation = false;
      }
    }
    if (continueOperation) {
      result.setSuccess(value:row);
    }
    return result;
  }

  Map<String, List<String>> getColumnFormats({bool getPasswordColumns = false}) {
    Map<String, List<String>> result = {};
    for (final acDDTableColumn in acDDTable.tableColumns) {
      List<String> columnFormats = [];
      if (acDDTableColumn.columnType == AcEnumDDColumnType.JSON ||acDDTableColumn.columnType == AcEnumDDColumnType.MEDIA_JSON) {
        columnFormats.add(AcEnumDDColumnFormat.JSON);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.DATE) {
        columnFormats.add(AcEnumDDColumnFormat.DATE);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.PASSWORD && !getPasswordColumns) {
        columnFormats.add(AcEnumDDColumnFormat.HIDE_COLUMN);
      } else if (acDDTableColumn.columnType == AcEnumDDColumnType.ENCRYPTED) {
        columnFormats.add(AcEnumDDColumnFormat.ENCRYPT);
      }
      if (columnFormats.isNotEmpty) {
        result[acDDTableColumn.columnName] = columnFormats;
      }
    }
    return result;
  }

  String getSelectStatement({List<String> includeColumns = const [],List<String> excludeColumns = const []}) {
    String result = "SELECT * FROM $tableName";
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
    result = "SELECT ${columns.join(", ")} FROM $tableName";
    return result;
  }

  Future<AcSqlDaoResult> getDistinctColumnValues({required String columnName,String condition = "",String orderBy = "",String mode = AcEnumDDSelectMode.LIST,int pageNumber = -1,int pageSize = -1,Map<String, dynamic> parameters = const {},}) async {    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
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
      logger.log(["", "", "Executing getDistinctColumnValues select statement"]);
      final sqlStatement = AcDDSelectStatement.generateSqlStatement(
          selectStatement: selectStatement,
          condition: condition,
          orderBy: actualOrderBy,
          pageNumber: pageNumber,
          pageSize: pageSize,
          databaseType: databaseType);
      result = await dao!.getRows(statement: sqlStatement, parameters: parameters, mode: mode);
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  String getColumnDefinitionForStatement({required String columnName}) {
    String result = "";
    final acDDTableColumn = acDDTable.getColumn(columnName)!;
    String columnType = acDDTableColumn.columnType;
    dynamic defaultValue = acDDTableColumn.getDefaultValue();
    int size = acDDTableColumn.getSize();
    bool isAutoIncrementSet = false;
    bool isPrimaryKeySet = false;
    if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
      columnType = "TEXT";
      switch (columnType) {
        case AcEnumDDColumnType.AUTO_INCREMENT:
          columnType = 'INT AUTO_INCREMENT PRIMARY KEY';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.BLOB:
          columnType = "LONGBLOB";
          if (size > 0) {
            if (size <= 255) {
              columnType = "TINYBLOB";
            }
            if (size <= 65535) {
              columnType = "BLOB";
            } else if (size <= 16777215) {
              columnType = "MEDIUMBLOB";
            }
          }
          break;
        case AcEnumDDColumnType.DATE:
          columnType = 'DATE';
          break;
        case AcEnumDDColumnType.DATETIME:
          columnType = 'DATETIME';
          break;
        case AcEnumDDColumnType.DOUBLE:
          columnType = 'DOUBLE';
          break;
        case AcEnumDDColumnType.UUID:
          columnType = 'CHAR(36)';
          break;
        case AcEnumDDColumnType.INTEGER:
          columnType = 'INT';
          if (size > 0) {
            if (size <= 255) {
              columnType = "TINYINT";
            } else if (size <= 65535) {
              columnType = "SMALLINT";
            } else if (size <= 16777215) {
              columnType = "MEDIUMINT";
            }
              // else if (size <= 18446744073709551615) {
            //   columnType = "BIGINT";
            // }
          }
          break;
        case AcEnumDDColumnType.JSON:
          columnType = 'LONGTEXT';
          break;
        case AcEnumDDColumnType.STRING:
          if (size == 0) {
            size = 255;
          }
          columnType = "VARCHAR($size)";
          break;
        case AcEnumDDColumnType.TEXT:
          columnType = 'LONGTEXT';
          if (size > 0) {
            if (size <= 255) {
              columnType = "TINYTEXT";
            }
            if (size <= 65535) {
              columnType = "TEXT";
            } else if (size <= 16777215) {
              columnType = "MEDIUMTEXT";
            }
          }
          break;
        case AcEnumDDColumnType.TIME:
          columnType = 'TIME';
          break;
        case AcEnumDDColumnType.TIMESTAMP:
          columnType =
          'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP';
          break;
      }
      result = "$columnName $columnType";
      if (acDDTableColumn.isAutoIncrement() && !isAutoIncrementSet) {
        result += " AUTO_INCREMENT";
      }
      if (acDDTableColumn.isPrimaryKey() && !isPrimaryKeySet) {
        result += " PRIMARY KEY";
      }
      if (acDDTableColumn.isUniqueKey()) {
        result += " UNIQUE";
      }
      if (acDDTableColumn.isNotNull()) {
        result += " NOT NULL";
      }
      if (defaultValue != null) {
        // result.=" DEFAULT $defaultValue";
      }
    } else if (databaseType == AcEnumSqlDatabaseType.SQLITE) {
      columnType = "TEXT";
      switch (columnType) {
        case AcEnumDDColumnType.AUTO_INCREMENT:
          columnType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
          isAutoIncrementSet = true;
          isPrimaryKeySet = true;
          break;
        case AcEnumDDColumnType.DOUBLE:
          columnType = 'REAL';
          break;
        case AcEnumDDColumnType.BLOB:
          columnType = 'BLOB';
          break;
        case AcEnumDDColumnType.INTEGER:
          columnType = 'INTEGER';
          break;
      }
      result = "$columnName $columnType";
      if (acDDTableColumn.isAutoIncrement() && !isAutoIncrementSet) {
        result += " AUTOINCREMENT";
      }
      if (acDDTableColumn.isPrimaryKey() && !isPrimaryKeySet) {
        result += " PRIMARY KEY";
      }
      if (acDDTableColumn.isUniqueKey()) {
        result += " UNIQUE ";
      }
      if (acDDTableColumn.isNotNull()) {
        result += " NOT NULL";
      }
      if (defaultValue != null) {
        // result.=" DEFAULT $defaultValue";
      }
    }
    return result;
  }

  Future<AcSqlDaoResult> getRows({String selectStatement = "",String condition = "",String orderBy = "",String mode = AcEnumDDSelectMode.LIST,int pageNumber = -1,int pageSize = -1,Map<String, dynamic> parameters = const {},}) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
    try {
      String actualSelectStatement =
      selectStatement.isNotEmpty ? selectStatement : getSelectStatement();
      final sqlStatement = AcDDSelectStatement.generateSqlStatement(
          selectStatement: actualSelectStatement,
          condition: condition,
          orderBy: orderBy,
          pageNumber: pageNumber,
          pageSize: pageSize,
          databaseType: databaseType);
      result = await dao!.getRows(
          statement: sqlStatement,
          parameters: parameters,
          mode: mode,
          columnFormats: getColumnFormats());
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> getRowsFromAcDDStatement({required AcDDSelectStatement acDDSelectStatement}) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.SELECT);
    try {
      String sqlStatement = acDDSelectStatement.getSqlStatement();
      Map<String,dynamic> sqlParameters = acDDSelectStatement.parameters;
      result = await dao!.getRows(statement: sqlStatement,parameters: sqlParameters,columnFormats: getColumnFormats());
      if(result.rows.isNotEmpty){
        String countSqlStatement = acDDSelectStatement.getSqlStatement(skipLimit: true);
        var countResult = await dao!.getRows(statement: countSqlStatement,parameters: sqlParameters);
        if(countResult.isSuccess()){
          result.totalRows = countResult.totalRows;
        }
      }
      else{
        result.totalRows = 0;
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> insertRow({required Map<String, dynamic> row,AcResult? validateResult,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    var result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
    try {
      logger.log(["Inserting row with data : ", row]);
      bool continueOperation = true;
      validateResult ??= await validateValues(row: row, isInsert: true);
      logger.log(["Validation result : ", validateResult]);
      if (validateResult.isSuccess()) {
        for (final column in acDDTable.tableColumns) {
          if ((column.columnType == AcEnumDDColumnType.UUID ||
              (column.columnType == AcEnumDDColumnType.STRING &&
                  column.isPrimaryKey())) &&
              !row.containsKey(column.columnName)) {
            row[column.columnName] = Autocode.uuid(); // Use the uuid package
          }
        }
        final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
        dynamic primaryKeyValue = row[primaryKeyColumn];
        if (row.isNotEmpty) {
          if (continueOperation) {
            if (executeBeforeEvent) {
              logger.log("Executing before insert event");
              final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName, dataDictionaryName: dataDictionaryName);
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.BEFORE_INSERT;
              final eventResult = await rowEvent.execute();
              logger.log(["Before insert result", eventResult]);
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(result:eventResult,
                    message: "Aborted from before insert row events");
              }
            }
          }
          if (continueOperation) {
            logger.log(["Inserting data : ", row]);
            final insertResult =
            await dao!.insertRow(tableName: tableName, row: row);
            if (insertResult.isSuccess()) {
              logger.log(insertResult.toString());
              result.setSuccess(message: "Row inserted successfully");
              result.primaryKeyColumn = primaryKeyColumn;
              result.primaryKeyValue = primaryKeyValue;
              if (primaryKeyColumn.isNotEmpty) {
                if (!Autocode.validPrimaryKey(primaryKeyValue) && Autocode.validPrimaryKey(insertResult.lastInsertedId)) {
                  primaryKeyValue = insertResult.lastInsertedId;
                }
              }
              result.lastInsertedId = primaryKeyValue;
              logger.log("Getting inserted row from database");
              final condition = "$primaryKeyColumn = :primaryKeyValue";
              final parameters = {":primaryKeyValue": primaryKeyValue};
              logger.log(["Select condition", condition, parameters]);
              final selectResult =
              await getRows(condition: condition, parameters: parameters);
              if (selectResult.isSuccess()) {
                if (selectResult.hasRows()) {
                  result.rows = selectResult.rows;
                }
              } else {
                result.message =
                'Error getting inserted row : ${selectResult.message}';
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                    tableName: tableName,
                    dataDictionaryName: dataDictionaryName);
                rowEvent.eventType = AcEnumDDRowEvent.AFTER_INSERT;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  // result = eventResult;
                } else {
                  result.setFromResult(result:eventResult);
                }
              }
            } else {
              result.setFromResult(result:insertResult);
            }
          }
        } else {
          result.message = 'No values for new row';
        }
      } else {
        result.setFromResult(result: validateResult);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> insertRows({required List<Map<String, dynamic>> rows,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.INSERT);
    try {
      logger.log(["Inserting rows : ", rows]);
      bool continueOperation = true;
      List<Map<String, dynamic>> rowsToInsert = [];
      List<dynamic> primaryKeyValues = [];
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      for (var row in rows) {
        if (continueOperation) {
          final validateResult =
          await validateValues(row: row, isInsert: true);
          if (validateResult.isSuccess()) {
            for (final column in acDDTable.tableColumns) {
              if ((column.columnType == AcEnumDDColumnType.UUID ||
                  (column.columnType == AcEnumDDColumnType.STRING &&
                      column.isPrimaryKey())) &&
                  !row.containsKey(column.columnName)) {
                row[column.columnName] = Autocode.uuid(); // Use uuid package.
              }
            }
            if (row.containsKey(primaryKeyColumn)) {
              primaryKeyValues.add(row[primaryKeyColumn]);
            }
            if (row.isNotEmpty) {
              if (continueOperation) {
                if (executeBeforeEvent) {
                  logger.log("Executing before insert event");
                  final rowEvent = AcSqlDbRowEvent(
                      tableName: tableName,
                      dataDictionaryName: dataDictionaryName);
                  rowEvent.row = row;
                  rowEvent.eventType = AcEnumDDRowEvent.BEFORE_INSERT;
                  final eventResult = await rowEvent.execute();
                  logger.log(["Before insert result", eventResult]);
                  if (eventResult.isSuccess()) {
                    row = rowEvent.row;
                  } else {
                    continueOperation = false;
                    result.setFromResult(result:eventResult,
                        message: "Aborted from before insert row events");
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
          }
        }
      }
      if (continueOperation) {
        logger.log("Inserting ${rows.length} rows");
        final insertResult = await dao!.insertRows(
            tableName: tableName, rows: rowsToInsert);
        if (insertResult.isSuccess()) {
          logger.log(insertResult.toString());
          result.lastInsertedIds = primaryKeyValues;
          logger.log("Getting inserted rows from database");
          final condition = "$primaryKeyColumn IN (:primaryKeyValue)";
          final parameters = {":primaryKeyValue": primaryKeyValues};
          logger.log(["Select condition", condition, parameters]);
          final selectResult =
          await getRows(condition: condition, parameters: parameters);
          if (selectResult.isSuccess()) {
            if (selectResult.hasRows()) {
              result.rows = selectResult.rows;
            }
          } else {
            result.message =
            'Error getting inserted rows : ${selectResult.message}';
          }
          if (continueOperation && executeAfterEvent) {
            for (final row in result.rows) { // Changed to result.rows
              final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName);
              rowEvent.eventType = AcEnumDDRowEvent.AFTER_INSERT;
              rowEvent.result = result;
              rowEvent.row = row;
              final eventResult = await rowEvent.execute();
              if (!eventResult.isSuccess()) { // check for failure
                continueOperation = false;
                result.setFromResult(result:eventResult); // set the error
                break; // exit loop on error
              }
            }
          }
        } else {
          continueOperation = false;
          result.setFromResult(result:insertResult);
        }
      }
      if (continueOperation) {
        result.setSuccess(message: "Rows inserted successfully");
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> saveRow({required Map<String, dynamic> row,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UNKNOWN);
    try {
      bool continueOperation = true;
      var operation = AcEnumDDRowOperation.UNKNOWN;
      final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
      dynamic primaryKeyValue = row[primaryKeyColumn];
      String condition = "";
      Map<String, dynamic> conditionParameters = {};

      if (Autocode.validPrimaryKey(primaryKeyValue)) {
        logger.log(
            "Found primary key value so primary key value will be used");
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
            "Not found primary key value so checking for columns while saving");
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
              message: "No values to check in save", logger: logger);
        }
      }

      if (condition.isNotEmpty) {
        final getResult =
        await getRows(condition: condition, parameters: conditionParameters);
        if (getResult.isSuccess()) {
          if (getResult.hasRows()) {
            final existingRecord = getResult.rows.first;
            if (existingRecord.containsKey(primaryKeyColumn)) {
              primaryKeyValue = existingRecord[primaryKeyColumn];
              row[primaryKeyColumn] = primaryKeyValue;
              operation = AcEnumDDRowOperation.UPDATE;
            } else {
              continueOperation = false;
              result.message = "Row does not have primary key value";
            }
          } else {
            operation = AcEnumDDRowOperation.INSERT;
          }
        } else {
          continueOperation = false;
          result.setFromResult(result:getResult);
        }
      } else {
        operation = AcEnumDDRowOperation.INSERT;
      }

      if (operation != AcEnumDDRowOperation.INSERT &&
          operation != AcEnumDDRowOperation.UPDATE) {
        result.message = "Invalid Operation";
        continueOperation = false;
      }

      if (continueOperation) {
        logger.log("Executing operation $operation in save.");
        if (executeBeforeEvent) {
          final rowEvent = AcSqlDbRowEvent(
              tableName: tableName, dataDictionaryName: dataDictionaryName);
          rowEvent.row = row;
          rowEvent.eventType = AcEnumDDRowEvent.BEFORE_SAVE;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            row = rowEvent.row;
          } else {
            continueOperation = false;
            result.setFromResult(result:eventResult,
                message: "Aborted from before update row events",
                logger: logger);
          }
        }
        if (operation == AcEnumDDRowOperation.INSERT) {
          result.setFromResult(result:await insertRow(row: row));
        } else if (operation == AcEnumDDRowOperation.UPDATE) {
          result.setFromResult(result:await updateRow(row: row));
        } else {
          continueOperation = false; // Redundant, but good for clarity
        }

        if (continueOperation && executeAfterEvent) {
          final rowEvent = AcSqlDbRowEvent(
              tableName: tableName, dataDictionaryName: dataDictionaryName);
          rowEvent.eventType = AcEnumDDRowEvent.AFTER_SAVE;
          rowEvent.result = result;
          final eventResult = await rowEvent.execute();
          if (eventResult.isSuccess()) {
            // result.setFromResult(eventResult.result);
          } else {
            result.setFromResult(result:eventResult);
          }
        }
      }
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> saveRows({required List<Map<String, dynamic>> rows,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UNKNOWN);
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
                "Found primary key value so primary key value will be used");
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
                "Not found primary key value so checking for columns while saving");
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
                  message: "No values to check in save", logger: logger);
            }
          }

          if (condition.isNotEmpty) {
            final getResult = await getRows(
                condition: condition, parameters: conditionParameters);
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
              result.setFromResult(result:getResult);
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
                  dataDictionaryName: dataDictionaryName);
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.BEFORE_SAVE;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(result:eventResult,
                    message: "Aborted from before save row events",
                    logger: logger);
              }
            }
          }
          for (var row in rowsToUpdate) {
            if (continueOperation) {
              final rowEvent = AcSqlDbRowEvent(
                  tableName: tableName,
                  dataDictionaryName: dataDictionaryName);
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.BEFORE_SAVE;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                row = rowEvent.row;
              } else {
                continueOperation = false;
                result.setFromResult(result:eventResult,
                    message: "Aborted from before save row events",
                    logger: logger);
              }
            }
          }
        }
        List<Map<String, dynamic>> combinedRows = [];
        if (continueOperation) {
          final insertResult = await insertRows(rows: rowsToInsert);
          if (insertResult.isFailure()) {
            continueOperation = false;
            result.setFromResult(result:insertResult);
          }
          else{
            combinedRows.addAll(insertResult.rows);
          }
        }
        if (continueOperation) {
          final updateResult = await updateRows(rows: rowsToUpdate);
          if (updateResult.isFailure()) {
            continueOperation = false;
            result.setFromResult(result:updateResult);
          }
          else{
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
    } on Exception catch (ex,stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcResult> setValuesNullBeforeDelete({required String condition,Map<String,dynamic> parameters = const{}}) async {
    final result = AcResult();
    try {
      bool continueOperation = true;
      logger.log("Checking cascade delete for table $tableName");
      final tableRelationships = AcDataDictionary.getTableRelationships(tableName: tableName, dataDictionaryName: dataDictionaryName);

      for (final acRelationship in tableRelationships) {
        if (continueOperation) {
          if (acRelationship.destinationTable == tableName) {
            final column =
            acDDTable.getColumn(acRelationship.destinationColumn);
            if (column != null) {
              if (column.isSetValuesNullBeforeDelete()) {
                final setNullStatement =
                    "UPDATE ${acRelationship.sourceTable} SET ${acRelationship.sourceColumn} = NULL WHERE ${acRelationship.sourceColumn} IN (SELECT ${acRelationship.destinationColumn} FROM $tableName WHERE $condition)";
                logger.log([
                  "Executing set null statement",
                  setNullStatement
                ]);
                final setNullResult = await dao!.executeStatement(statement: setNullStatement, parameters: parameters);
                if (setNullResult.isSuccess()) {
                  logger.success(setNullResult.toJson());
                } else {
                  continueOperation = false;
                  result.setFromResult(result:setNullResult);
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
    } on Exception catch (ex,stack) {
      result.setException(exception:ex,stackTrace:stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> updateRow({required Map<String, dynamic> row,String condition = "",Map<String, dynamic> parameters = const {},AcResult? validateResult,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    logger.log(["Updating row with data : ", row]);
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
    try {
      bool continueOperation = true;
      validateResult ??= await validateValues(row: row, isInsert: false);

      if (validateResult.isSuccess() && continueOperation) {
        logger.log(["Validation result : ", validateResult]);
        final primaryKeyColumn = acDDTable.getPrimaryKeyColumnName();
        final primaryKeyValue = row[primaryKeyColumn];

        final formatResult = await formatValues(row:row);
        if (formatResult.isSuccess()) {
          row = formatResult.value;
        } else {
          continueOperation = false;
        }
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
                  dataDictionaryName: dataDictionaryName);
              rowEvent.row = row;
              rowEvent.eventType = AcEnumDDRowEvent.BEFORE_UPDATE;
              final eventResult = await rowEvent.execute();
              if (eventResult.isSuccess()) {
                logger.log(["Before event result", eventResult]);
                row = rowEvent.row;
              } else {
                logger.error(["Before event result", eventResult]);
                continueOperation = false;
                result.setFromResult(result:eventResult, message: "Aborted from before update row events");
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
                parameters: parameters);
            if (updateResult.isSuccess()) {
              result.setSuccess(
                  message: "Row updated successfully", logger: logger);
              result.primaryKeyColumn = primaryKeyColumn;
              result.primaryKeyValue = primaryKeyValue;
              final selectResult =
              await getRows(condition: condition, parameters: parameters);
              if (selectResult.isSuccess()) {
                result.rows = selectResult.rows;
              } else {
                logger.error(['Error getting updated row : ${selectResult.message}',selectResult]);
                result.message = 'Error getting updated row : ${selectResult.message}';
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                    tableName: tableName,
                    dataDictionaryName: dataDictionaryName);
                rowEvent.eventType = AcEnumDDRowEvent.AFTER_UPDATE;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["After event result", eventResult]);
                  // result.setFromResult(eventResult.result);
                } else {
                  logger.error(["After event result", eventResult]);
                  result.setFromResult(result:eventResult);
                }
              }
            } else {
              result.setFromResult(result:updateResult, logger: logger);
            }
          }
        } else {
          logger.log("No data to update");
          result.message = 'No values to update row';
        }
      } else {
        logger.error(["Validation result : ", validateResult]);
        result.setFromResult(result: validateResult);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex,stackTrace:stack, logger: logger, logException: true);
    }
    return result;
  }

  Future<AcSqlDaoResult> updateRows({required List<Map<String, dynamic>> rows,bool executeAfterEvent = true,bool executeBeforeEvent = true}) async {
    final result = AcSqlDaoResult(operation: AcEnumDDRowOperation.UPDATE);
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
          final validateResult =
          await validateValues(row: row, isInsert: false);
          if (validateResult.isSuccess() && continueOperation) {
            logger.log(["Validation result : ", validateResult]);
            final primaryKeyValue = row[primaryKeyColumn];
            final formatResult = await formatValues(row:row);
            if (formatResult.isSuccess()) {
              row = formatResult.value;
            } else {
              continueOperation = false;
            }
            logger.log(["Formatted data : ", row]);
            if (row.isNotEmpty && Autocode.validPrimaryKey(primaryKeyValue)) {
              final condition = "$primaryKeyColumn = :primaryKeyValue$index";
              final parameters = {":primaryKeyValue$index": primaryKeyValue};
              primaryKeyValues.add(primaryKeyValue);
              rowsWithConditions.add({
                "row": row,
                "condition": condition,
                "parameters": parameters
              });
            }
          } else {
            logger.error(["Validation result : ", validateResult]);
            result.setFromResult(result:validateResult);
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
                    dataDictionaryName: dataDictionaryName);
                rowEvent.row = rowDetails["row"];
                rowEvent.condition = rowDetails["condition"];
                rowEvent.parameters = rowDetails["parameters"];
                rowEvent.eventType = AcEnumDDRowEvent.BEFORE_UPDATE;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["Before event result", eventResult]);
                  // row = rowEvent.row;
                } else {
                  logger.error(["Before event result", eventResult]);
                  continueOperation = false;
                  result.setFromResult(result:eventResult,
                      message: "Aborted from before update row events");
                }
              }
            }
          } else {
            logger.log("Skipping before update event");
          }
          if (continueOperation) {
            final updateResult = await dao!.updateRows(
                tableName: tableName, rowsWithConditions: rowsWithConditions);
            if (updateResult.isSuccess()) {
              result.setSuccess(
                  message: "Rows updated successfully", logger: logger);
              final selectResult = await getRows(
                  condition: "$primaryKeyColumn IN (@primaryKeyValues)",
                  parameters: {
                    "@primaryKeyValues": primaryKeyValues
                  }); // Corrected parameter name
              if (selectResult.isSuccess()) {
                result.rows = selectResult.rows;
              } else {
                continueOperation = false;
                logger.error(['Error getting updated row : ${selectResult.message}',selectResult]);
                result.message =
                'Error getting updated row : ${selectResult.message}';
              }
              if (continueOperation && executeAfterEvent) {
                final rowEvent = AcSqlDbRowEvent(
                    tableName: tableName,
                    dataDictionaryName: dataDictionaryName);
                rowEvent.eventType = AcEnumDDRowEvent.AFTER_UPDATE;
                rowEvent.result = result;
                final eventResult = await rowEvent.execute();
                if (eventResult.isSuccess()) {
                  logger.log(["After event result", eventResult]);
                  // result.setFromResult(result.eventResult.result);
                } else {
                  logger.error(["After event result", eventResult]);
                  continueOperation = false;
                  result.setFromResult(result:eventResult);
                }
              }
            } else {
              result.setFromResult(result:updateResult, logger: logger);
            }
          }
        } else {
          result.message = "Nothing to update";
        }
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex,stackTrace:stack, logger: logger, logException: true);
    }
    return result;
  }

  String updateValueLengthWithChars({required String value,required String char,required int length}) {
    String result = value;
    if (length > 0) {
      int currentLength = value.length;
      if (currentLength < length) {
        result = char * (length - currentLength) + value;
      }
    }
    return result;
  }

  Future<AcResult> validateValues({required Map<String, dynamic> row, bool isInsert = false}) async {
    final result = AcResult();
    try {
      bool continueOperation = true;
      for (final column in acDDTable.tableColumns) {
        dynamic value = row[column.columnName];
        if (continueOperation) {
          if (column.isRequired()) {
            bool validRequired = true;
            if (!row.containsKey(column.columnName) && isInsert) {
              validRequired = false;
            } else if ((value is String && value.trim().isEmpty) ||
                value == null) {
              validRequired = false;
            }
            if (!validRequired) {
              continueOperation = false;
              result.setFailure(message: "Required column value is missing");
            }
          }
        }
        if (continueOperation) {
          if (column.columnType == AcEnumDDColumnType.INTEGER ||
              column.columnType == AcEnumDDColumnType.DOUBLE) {
            if (value != null && value is! num) {
              result.setFailure(
                  message:
                  "Invalid numeric value for column : ${column.columnName}");
              break;
            }
          } else if (column.columnType == AcEnumDDColumnType.DATE || column.columnType == AcEnumDDColumnType.DATETIME || column.columnType == AcEnumDDColumnType.TIME) {
            if (value != null && value != "NOW") {
              try {
                DateTime.parse(value);
              } catch (ex,stack) {
                result.setException(message:"Invalid datetime value for column : ${column.columnName}",exception: ex,stackTrace: stack);
                break;
              }
            }
          }
        }
      }
      if (continueOperation) {
        final checkResponse = await checkUniqueValues(row:row);
        if (checkResponse.isFailure()) {
          continueOperation = false;
          result.setFromResult(result:checkResponse);
        }
      }
      if (continueOperation) {
        result.setSuccess();
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex,stackTrace:stack, logger: logger, logException: true);
    }
    return result;
  }

}

