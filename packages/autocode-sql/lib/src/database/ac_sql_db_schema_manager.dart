import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';

class AcSqlDbSchemaManager extends AcSqlDbBase {
  AcSqlDbTable acSqlDDTableSchemaDetails = AcSqlDbTable(tableName:AcSchemaManagerTables.SCHEMA_DETAILS,dataDictionaryName:AcSMDataDictionary.DATA_DICTIONARY_NAME);
  AcSqlDbTable acSqlDDTableSchemaLogs = AcSqlDbTable(tableName:AcSchemaManagerTables.SCHEMA_LOGS,dataDictionaryName:AcSMDataDictionary.DATA_DICTIONARY_NAME);

  AcSqlDbSchemaManager({super.dataDictionaryName});

  Future<AcResult> checkSchemaUpdateAvailableFromVersion() async {
    final result = AcResult();
    try {
      logger.log('Checking if database data dictionary version is the same as the current data dictionary version...');

      final versionResult = await dao!.getRows(
        statement: acSqlDDTableSchemaDetails.getSelectStatement(),
        condition: "${TblSchemaDetails.AC_SCHEMA_DETAIL_KEY} = @key",
        parameters: {
          "@key": SchemaDetails.KEY_DATA_DICTIONARY_VERSION,
        },
        mode: AcEnumDDSelectMode.FIRST, //important
      );

      if (versionResult.isSuccess()) {
        if (versionResult.rows.isNotEmpty) {
          final databaseVersion = versionResult.rows.first[TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE]
          as int;
          if (acDataDictionary.version == databaseVersion) {
            logger.log('Database data dictionary and current data dictionary version are the same.');
            result.setSuccess(value: false); // No update available
          } else if (acDataDictionary.version < databaseVersion) {
            logger.log('Database data dictionary version is greater than the current data dictionary version.');
            result.setSuccess(value: false); // No update available
          } else {
            logger.log('Database data dictionary version is less than the current data dictionary version.');
            result.setSuccess(value: true); // Update available
          }
        } else {
          logger.log( 'No version detail row found in details table.');
          result.setSuccess(value: true); // Update available
        }
      } else {
        result.setFromResult(result:versionResult,message: 'Error checking schema version',logger: logger);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database functions.
  Future<AcResult> createDatabaseFunctions() async {
    final result = AcResult();
    try {
      logger.log( 'Creating functions in database...');
      // final acDDFunctions =
      //     acDataDictionary.getFunctions(dataDictionaryName: acDataDictionary.name); // Removed dataDictionaryName parameter
      final functionList = AcDataDictionary.getFunctions(dataDictionaryName: dataDictionaryName); //<List<AcDDFunction>
      for (final acDDFunction in functionList.values) {
        final dropStatement = AcDDFunction.getDropFunctionStatement(functionName: acDDFunction.functionName,databaseType:databaseType); // Made databaseType a class variable.
        logger.log( 'Executing drop function statement: $dropStatement');
        final dropResult = await dao!.executeStatement(statement: dropStatement,operation: AcEnumDDRowOperation.UNKNOWN);
        if (dropResult.isSuccess()) {
          logger.log( 'Drop statement executed successfully.');
        } else {
          return result.setFromResult(result:
            dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.FUNCTION,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDFunction.functionName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'drop',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: dropResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: dropStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });

        final createStatement = acDDFunction.getCreateFunctionStatement();
        logger.log( 'Creating function with statement: $createStatement');
        final createResult = await dao!.executeStatement(statement: createStatement,operation: AcEnumDDRowOperation.UNKNOWN);
        if (createResult.isSuccess()) {
          logger.log( 'Function created successfully.');
        } else {
          return result.setFromResult(result:
            createResult,
            message: 'Error creating function',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.FUNCTION,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDFunction.functionName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now()
        });
      }
      result.setSuccess(message: 'Functions created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database relationships.
  Future<AcResult> createDatabaseRelationships() async {
    final result = AcResult();
    try {
      logger.log( 'Creating database relationships...');

      if (databaseType == AcEnumSqlDatabaseType.MYSQL) {
        const disableCheckStatement = "SET FOREIGN_KEY_CHECKS = 0;";
        logger.log( 'Executing disable check statement: $disableCheckStatement');
        final setCheckResult = await dao!.executeStatement(statement: disableCheckStatement,operation: AcEnumDDRowOperation.UNKNOWN);
        if (setCheckResult.isFailure()) {
          return result.setFromResult(result:
            setCheckResult,
            message: 'Error disabling foreign key checks',
            logger: logger,
          );
        } else {
          logger.log( 'Disabled foreign key checks.');
        }
      }

      logger.log( 'Getting and dropping existing relationships...');
      const getDropRelationshipsStatements = "SELECT CONCAT('ALTER TABLE `', table_name, '` DROP FOREIGN KEY `', constraint_name, '`;') AS drop_query, constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = @databaseName";
      final getResult = await dao!.getRows(statement: getDropRelationshipsStatements,parameters: {"@databaseName":dao!.sqlConnection.database}); // Corrected parameter passing
      if (getResult.isSuccess()) {
        for (final row in getResult.rows) {
          final dropRelationshipStatement = row['drop_query'] as String;
          final constraintName = row['constraint_name'] as String;
          logger.log(
              'Executing drop relationship statement: $dropRelationshipStatement');
          final dropResponse = await dao!.executeStatement(
              statement: dropRelationshipStatement,
              operation: AcEnumDDRowOperation.UNKNOWN); // Added operation
          if (dropResponse.isFailure()) {
            return result.setFromResult(result:
              dropResponse,
              message: 'Error dropping relationship',
              logger: logger,
            );
          } else {
            logger.log( 'Executed drop relation statement successfully.');
          }
          await saveSchemaLogEntry({
            TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.RELATIONSHIP,
            TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: constraintName,
            TblSchemaLogs.AC_SCHEMA_OPERATION: 'drop',
            TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: dropResponse.status,
            TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: dropRelationshipStatement,
            TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
          });
        }
      } else {
        return result.setFromResult(result:
          getResult,
          message: 'Error getting relationships to drop',
          logger: logger,
        );
      }

      final relationshipList = AcDataDictionary.getRelationships(dataDictionaryName: dataDictionaryName);
      for (final acDDRelationship in relationshipList) {
        logger.log( 'Creating relationship for: $acDDRelationship');
        final createRelationshipStatement = acDDRelationship.getCreateRelationshipStatement();
        logger.log('Create relationship statement: $createRelationshipStatement');
        final createResult = await dao!.executeStatement(statement: createRelationshipStatement);
        if (createResult.isFailure()) {
          return result.setFromResult(result:
            createResult,
            message: 'Error creating relationship',
            logger: logger,
          );
        } else {
          logger.log( 'Relationship created successfully.');
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.RELATIONSHIP,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME:'${acDDRelationship.sourceTable}.${acDDRelationship.sourceColumn}>${acDDRelationship.destinationTable}.${acDDRelationship.destinationColumn}',
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createRelationshipStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });
      }

      result.setSuccess(
          message: 'Relationships created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database stored procedures.
  Future<AcResult> createDatabaseStoredProcedures() async {
    final result = AcResult();
    try {
      logger.log( 'Creating stored procedures...');
      final storedProcedureList =AcDataDictionary.getStoredProcedures(dataDictionaryName: dataDictionaryName);
      for (final acDDStoredProcedure in storedProcedureList.values) {
        final dropStatement = AcDDStoredProcedure.getDropStoredProcedureStatement(storedProcedureName: acDDStoredProcedure.storedProcedureName,databaseType: databaseType);
        logger.log('Executing drop stored procedure statement: $dropStatement');
        final dropResult = await dao!.executeStatement(statement: dropStatement);
        if (dropResult.isSuccess()) {
          logger.log( 'Drop statement executed successfully.');
        } else {
          return result.setFromResult(result:
            dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.STORED_PROCEDURE,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDStoredProcedure.storedProcedureName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'drop',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: dropResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: dropStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });

        final createStatement = acDDStoredProcedure.getCreateStoredProcedureStatement(
            databaseType: databaseType
        );
        logger.log( 'Create statement: $createStatement');
        final createResult = await dao!.executeStatement(statement: createStatement);
        if (createResult.isSuccess()) {
          logger.log( 'Stored procedure created successfully.');
        } else {
          return result.setFromResult(result:
            createResult,
            message: 'Error creating stored procedure',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.STORED_PROCEDURE,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDStoredProcedure.storedProcedureName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });
      }
      result.setSuccess(
          message: 'Stored procedures created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database tables.
  Future<AcResult> createDatabaseTables() async {
    final result = AcResult();
    try {
      for (final acDDTable in AcDataDictionary.getTables(dataDictionaryName: dataDictionaryName).values) {
        logger.log( 'Creating table ${acDDTable.tableName}');
        final createStatement = acDDTable.getCreateTableStatement(databaseType:databaseType);
        logger.log( 'Executing create table statement: $createStatement');
        final createResult = await dao!.executeStatement(statement: createStatement);
        if (createResult.isSuccess()) {
          logger.log( 'Create statement executed successfully.');
        } else {
          return result.setFromResult(result:
            createResult,
            message: 'Error creating table ${acDDTable.tableName}',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.TABLE,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDTable.tableName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });
      }
      result.setSuccess(message: 'Tables created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database triggers.
  Future<AcResult> createDatabaseTriggers() async {
    final result = AcResult();
    try {
      logger.log( 'Creating triggers...');
      for (final acDDTrigger in AcDataDictionary.getTriggers(dataDictionaryName: dataDictionaryName).values) {
        logger.log( 'Creating trigger ${acDDTrigger.triggerName}');
        final dropStatement = AcDDTrigger.getDropTriggerStatement(triggerName: acDDTrigger.triggerName, databaseType: databaseType);
        logger.log( 'Executing drop trigger statement: $dropStatement');
        final dropResult = await dao!.executeStatement(statement: dropStatement);
        if (dropResult.isSuccess()) {
          logger.log( 'Drop statement executed successfully.');
        } else {
          return result.setFromResult(result:
            dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.TRIGGER,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDTrigger.triggerName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'drop',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: dropResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: dropStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });

        final createStatement = acDDTrigger.getCreateTriggerStatement(databaseType:databaseType);
        logger.log( 'Create statement: $createStatement');
        final createResult = await dao!.executeStatement(statement: createStatement);
        if (createResult.isSuccess()) {
          logger.log( 'Trigger created successfully.');
        } else {
          return result.setFromResult(result:
            createResult,
            message: 'Error creating trigger',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.TRIGGER,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDTrigger.triggerName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });
      }
      result.setSuccess(message: 'Triggers created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates database views.
  Future<AcResult> createDatabaseViews() async {
    final result = AcResult();
    try {
      logger.log( 'Creating views...');
      final viewList = AcDataDictionary.getViews(dataDictionaryName: dataDictionaryName); // Get views
      List<AcDDView> errorViews = [];
      for (final acDDView in viewList.values) {
        logger.log( 'Creating view ${acDDView.viewName}');
        final dropStatement = AcDDView.getDropViewStatement(viewName: acDDView.viewName, databaseType: databaseType);
        logger.log( 'Executing drop view statement: $dropStatement');
        final dropResult = await dao!.executeStatement(statement: dropStatement);
        if (dropResult.isSuccess()) {
          logger.log( 'Drop statement executed successfully.');
        } else {
          return result.setFromResult(result:
            dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.VIEW,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDView.viewName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'drop',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: dropResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: dropStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });

        final createStatement = acDDView.getCreateViewStatement(databaseType:databaseType);
        logger.log( 'Create statement: $createStatement');
        final createResult = await dao!.executeStatement(statement: createStatement);
        if (createResult.isSuccess()) {
          logger.log( 'View created successfully.');
        } else {
          logger.error('Error creating view');
          errorViews.add(acDDView);
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.VIEW,
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDView.viewName,
          TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
        });
      }

      if (errorViews.isNotEmpty) {
        logger.log('Retrying creating ${errorViews.length} views with errors');
        int retryCount = 0;
        List<AcDDView> retryViews = [];
        while (errorViews.isNotEmpty && retryCount < 10) {
          retryCount++;
          logger.log(
              "${errorViews.length} views with errors will be retried in iteration $retryCount");
          for (final acDDView in errorViews) {
            final createStatement = acDDView.getCreateViewStatement(databaseType:databaseType);
            logger.log('Retrying creating view for ${acDDView.viewName}, $createStatement');
            final createResult = await dao!.executeStatement(statement: createStatement);
            if (createResult.isSuccess()) {
              logger.log( 'View created successfully');
            } else {
              logger.error('Error creating view');
              retryViews.add(acDDView);
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.VIEW,
              TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: acDDView.viewName,
              TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
              TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
              TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
              TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now(),
            });
          }
          logger.log(
              "After iteration $retryCount, ${retryViews.length} still has errors");
          errorViews = retryViews;
          retryViews = [];
          logger.log("Will try executing ${errorViews.length} in next iteration");
        }
        logger.log(
            "After retrying creating error views, there are ${errorViews.length} with errors");
        if (errorViews.isNotEmpty) {
          List<Map<String, String>> errorViewsList = [];
          for (final acDDView in errorViews) {
            final createStatement = acDDView.getCreateViewStatement(databaseType:databaseType);
            final errorViewDetails = {
              AcDDViewColumn.KEY_COLUMN_NAME: acDDView.viewName,
              "create_statement": createStatement
            };
            logger.error(["Error in view", errorViewDetails]);
            errorViewsList.add(errorViewDetails);
          }
          result.setFailure(value:errorViewsList,message: 'Error creating views', logger: logger);
        }
      }

      if (errorViews.isEmpty) {
        result.setSuccess(message: 'Views created successfully', logger: logger);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Creates the database schema.
  Future<AcResult> createSchema() async {
    final result = AcResult();
    try {
      logger.log( 'Creating schema in database for data dictionary $dataDictionaryName...');
      logger.log( 'Creating tables in database for data dictionary $dataDictionaryName...');
      final createTablesResult = await createDatabaseTables();
      if (createTablesResult.isSuccess()) {
        logger.log( 'Tables created successfully');
      } else {
        return result.setFromResult(result:
          createTablesResult,
          message: 'Error creating schema database tables',
          logger: logger,
        );
      }

      final createViewsResult = await createDatabaseViews();
      if (createViewsResult.isSuccess()) {
        logger.log( 'Views created successfully');
      } else {
        return result.setFromResult(result:
          createViewsResult,
          message: 'Error creating schema database views',
          logger: logger,
        );
      }

      final createTriggersResult = await createDatabaseTriggers();
      if (createTriggersResult.isSuccess()) {
        logger.log( 'Triggers created successfully');
      } else {
        return result.setFromResult(result:
          createTriggersResult,
          message: 'Error creating schema database triggers',
          logger: logger,
        );
      }

      final createStoredProceduresResult = await createDatabaseStoredProcedures();
      if (createStoredProceduresResult.isSuccess()) {
        logger.log( 'Stored procedures created successfully');
      } else {
        return result.setFromResult(result:
          createStoredProceduresResult,
          message: 'Error creating schema database stored procedures',
          logger: logger,
        );
      }

      final createFunctionsResult = await createDatabaseFunctions();
      if (createFunctionsResult.isSuccess()) {
        logger.log( 'Functions created successfully');
      } else {
        return result.setFromResult(result:
          createFunctionsResult,
          message: 'Error creating schema database functions',
          logger: logger,
        );
      }

      result.setSuccess(message: 'Schema created successfully', logger: logger);
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Gets the difference between the database schema and the data dictionary.
  Future<AcResult> getDatabaseSchemaDifference() async {
    final result = AcResult();
    try {
      Map<String, dynamic> differenceResult = {};
      final getTablesResult = await dao!.getDatabaseTables();
      if (getTablesResult.isSuccess()) {
        List<String> currentDataDictionaryTables = acDataDictionary.tables.keys.toList();
        List<String> foundTables = [];
        List<Map<String, dynamic>> modifiedTables = [];
        List<String> missingInDataDictionaryTables = [];
        for (final tableRow in getTablesResult.rows) {
          if (tableRow[AcDDTable.KEY_TABLE_NAME] != AcSchemaManagerTables.SCHEMA_DETAILS && tableRow[AcDDTable.KEY_TABLE_NAME] != AcSchemaManagerTables.SCHEMA_LOGS) {
            if (currentDataDictionaryTables.contains(tableRow[AcDDTable.KEY_TABLE_NAME])) {
              Map<String, dynamic> tableDifferenceResult = {};
              foundTables.add(tableRow[AcDDTable.KEY_TABLE_NAME]);
              final getTableColumnsResult = await dao!.getTableColumns(tableName: tableRow[AcDDTable.KEY_TABLE_NAME]);
              if (getTableColumnsResult.isSuccess()) {
                final currentDataDictionaryColumns = acDataDictionary.getTableColumnNames(tableName:tableRow[AcDDTable.KEY_TABLE_NAME]);
                List<String> foundColumns = [];
                List<String> missingInDataDictionaryColumns = [];
                for (final columnRow in getTableColumnsResult.rows) {
                  if (currentDataDictionaryColumns
                      .contains(columnRow[AcDDTableColumn.KEY_COLUMN_NAME])) {
                    foundColumns.add(columnRow[AcDDTableColumn.KEY_COLUMN_NAME]);
                  } else {
                    missingInDataDictionaryColumns
                        .add(columnRow[AcDDTableColumn.KEY_COLUMN_NAME]);
                  }
                }
                tableDifferenceResult["missing_columns_in_database"] =
                    currentDataDictionaryColumns
                        .where((element) => !foundColumns.contains(element))
                        .toList();
                tableDifferenceResult["missing_columns_in_data_dictionary"] =
                    missingInDataDictionaryColumns;
              } else {
                return result.setFromResult(result:getTableColumnsResult,message:'Error getting columns for table ${tableRow[AcDDTable.KEY_TABLE_NAME]}',logger: logger);
              }
              if (tableDifferenceResult['missing_columns_in_database'].length > 0 ||tableDifferenceResult["missing_columns_in_data_dictionary"] .length >0) {
                modifiedTables.add({AcDDTable.KEY_TABLE_NAME: tableRow[AcDDTable.KEY_TABLE_NAME],
                  "difference_details": tableDifferenceResult
                });
              }
            } else {
              missingInDataDictionaryTables.add(tableRow[AcDDTable.KEY_TABLE_NAME]);
            }
          }
        }
        differenceResult["missing_tables_in_database"] = currentDataDictionaryTables.where((element) => !foundTables.contains(element)).toList();
        differenceResult["missing_tables_in_data_dictionary"] =
            missingInDataDictionaryTables;
        differenceResult["modified_tables_in_data_dictionary"] = modifiedTables;
        result.setSuccess();
        result.value = differenceResult;
      } else {
        return result.setFromResult(result:
          getTablesResult,
          message: 'Error getting current database tables',
          logger: logger,
        );
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Initializes the database.
  Future<AcResult> initDatabase() async {
    final result = AcResult();
    try {
      logger.log( "Initializing database for data dictionary $dataDictionaryName...");
      final checkResult = await dao!.checkDatabaseExist();
      if (checkResult.isSuccess()) {
        final schemaResult = await initSchemaDataDictionary();
        if (schemaResult.isSuccess()) {
          bool updateDataDictionaryVersion = false;
          if (checkResult.value == false) {
            logger.log( "Creating database...");
            final createDbResult = await dao!.createDatabase();
            if (createDbResult.isSuccess()) {
              logger.log( "Database created successfully");
              final createSchemaResult = await createSchema();
              if (createSchemaResult.isSuccess()) {
                updateDataDictionaryVersion = true;
                result.setSuccess(message: 'Schema created successfully', logger: logger);
                await saveSchemaDetail({
                  TblSchemaDetails.AC_SCHEMA_DETAIL_KEY: SchemaDetails.KEY_CREATED_ON,
                  TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE: DateTime.now().toIso8601String(),
                });
              } else {
                return result.setFromResult(result:createSchemaResult,message:"Error creating database schema from data dictionary",logger: logger);
              }
            } else {
              return result.setFromResult(result:
                createDbResult,
                message: "Error creating database",
                logger: logger,
              );
            }
          } else {
            final checkUpdateResult = await checkSchemaUpdateAvailableFromVersion();
            if (checkUpdateResult.isSuccess()) {
              if (checkUpdateResult.value == true) {
                final updateSchemaResult = await updateSchema();
                if (updateSchemaResult.isSuccess()) {
                  updateDataDictionaryVersion = true;
                  result.setSuccess(
                      message: 'Schema updated successfully', logger: logger);
                  await saveSchemaDetail({
                    TblSchemaDetails.AC_SCHEMA_DETAIL_KEY: SchemaDetails.KEY_LAST_UPDATED_ON,
                    TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE: DateTime.now().toIso8601String(),
                  });
                } else {
                  return result.setFromResult(result:
                    updateSchemaResult,
                    message:
                    "Error updating database schema from data dictionary",
                    logger: logger,
                  );
                }
              } else {
                result.setSuccess(
                    message: 'Schema is latest. No changes required',
                    logger: logger);
              }
            } else {
              return result.setFromResult(result:
                checkUpdateResult,
                message:
                "Error checking for schema updates",
                logger: logger,
              );
            }
          }
          if (updateDataDictionaryVersion) {
            await saveSchemaDetail({
              TblSchemaDetails.AC_SCHEMA_DETAIL_KEY: SchemaDetails.KEY_DATA_DICTIONARY_VERSION,
              TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE: acDataDictionary.version,
            });
          }
        } else {
          return result.setFromResult(result:
            schemaResult,
            message: "Error initializing schema data dictionary",
            logger: logger,
          );
        }
      } else {
        return result.setFromResult(result:
          checkResult,
          message: "Error checking if database exists",
          logger: logger,
        );
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Initializes the schema data dictionary.
  Future<AcResult> initSchemaDataDictionary() async {
    final result = AcResult();
    try {
      if (!AcDataDictionary.dataDictionaries.containsKey(AcSMDataDictionary.DATA_DICTIONARY_NAME)) {
        logger.log( "Registering schema data dictionary...");
        AcDataDictionary.registerDataDictionary(jsonData:AcSMDataDictionary.DATA_DICTIONARY,dataDictionaryName:AcSMDataDictionary.DATA_DICTIONARY_NAME);
        acSqlDDTableSchemaDetails = AcSqlDbTable(tableName: AcSchemaManagerTables.SCHEMA_DETAILS,dataDictionaryName: AcSMDataDictionary.DATA_DICTIONARY_NAME);
        acSqlDDTableSchemaLogs = AcSqlDbTable(tableName: AcSchemaManagerTables.SCHEMA_LOGS,dataDictionaryName: AcSMDataDictionary.DATA_DICTIONARY_NAME);
        final acSchemaManager = AcSqlDbSchemaManager();
        acSchemaManager.dao = dao;
        acSchemaManager.logger = logger;
        acSchemaManager.useDataDictionary(dataDictionaryName:AcSMDataDictionary.DATA_DICTIONARY_NAME);
        acSchemaManager.acDataDictionary = acDataDictionary;
        final initSchemaResult = await acSchemaManager.initDatabase();
        if (initSchemaResult.isSuccess()) {
          result.setSuccess(message: 'Schema data dictionary initialized successfully',logger: logger);
        } else {
          return result.setFromResult(result:initSchemaResult,message: "Error setting schema entities in database",logger: logger);
        }
      } else {
        result.setSuccess(message: 'Schema data dictionary already initialized',logger: logger);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Saves a schema log entry.
  Future<AcSqlDaoResult> saveSchemaLogEntry(Map<String,dynamic> row) async {
    return await acSqlDDTableSchemaLogs.insertRow(row:row);
  }

  /// Saves schema details.
  Future<AcSqlDaoResult> saveSchemaDetail(Map<String,dynamic> data) async {
    return await acSqlDDTableSchemaDetails.saveRow(row:data);
  }

  /// Updates the database schema based on differences with the data dictionary.
  Future<AcResult> updateDatabaseDifferences() async {
    final result = AcResult();
    try {
      final differenceResult = await getDatabaseSchemaDifference();
      if (differenceResult.isSuccess()) {
        final differences =
        differenceResult.value as Map<String, dynamic>; // Cast the value
        List<String> dropColumnStatements = [];
        List<String> dropTableStatements = [];
        if (differences["missing_tables_in_database"] != null) {
          for (final tableName in differences["missing_tables_in_database"]) {
            logger.log( "Creating table $tableName");
            final acDDTable = AcDDTable.getInstance(tableName:tableName,dataDictionaryName: dataDictionaryName);
            final createStatement = acDDTable.getCreateTableStatement();
            logger.log(["Executing create table statement...",createStatement]);
            final createResult = await dao!.executeStatement(statement: createStatement);
            if (createResult.isSuccess()) {
              logger.log( "Create statement executed successfully");
            } else {
              return result.setFromResult(result:createResult, logger: logger);
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.TABLE,
              TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: tableName,
              TblSchemaLogs.AC_SCHEMA_OPERATION: 'create',
              TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
              TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: createStatement,
              TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now().toIso8601String(),
            });
          }
        }

        if (differences["modified_tables_in_data_dictionary"] != null) {
          for (final modificationDetails
          in differences["modified_tables_in_data_dictionary"]) {
            final tableName = modificationDetails[AcDDTable.KEY_TABLE_NAME];
            final tableDifferenceDetails =
            modificationDetails["difference_details"] as Map<String, dynamic>; // Cast
            if (tableDifferenceDetails["missing_columns_in_database"] != null) {
              for (final columnName in tableDifferenceDetails["missing_columns_in_database"]) {
                logger.log( "Adding table column $columnName");
                final acDDTableColumn = AcDDTableColumn.getInstance(tableName: tableName,columnName: columnName,dataDictionaryName: dataDictionaryName);
                final addStatement = acDDTableColumn.getAddColumnStatement(tableName: tableName);
                logger.log(["Executing add table column statement...",addStatement]);
                final createResult = await dao!.executeStatement(statement: addStatement);
                if (createResult.isSuccess()) {
                  logger.log( "Add statement executed successfully");
                } else {
                  return result.setFromResult(result:createResult, logger: logger);
                }
                await saveSchemaLogEntry({
                  TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: AcEnumDDSqlEntity.TABLE,
                  TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: tableName,
                  TblSchemaLogs.AC_SCHEMA_OPERATION: 'modify',
                  TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: createResult.status,
                  TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: addStatement,
                  TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: DateTime.now().toIso8601String(),
                });
              }
            }
            if (tableDifferenceDetails["missing_columns_in_data_dictionary"] !=
                null) {
              for (final columnName
              in tableDifferenceDetails["missing_columns_in_data_dictionary"]) {
                String dropColumnStatement = AcDDTableColumn.getDropColumnStatement(tableName: tableName, columnName: columnName,databaseType: databaseType);
                dropColumnStatements.add(dropColumnStatement); // Use the class method, and pass databaseType
              }
            }
          }
        }
        if (differences["missing_tables_in_data_dictionary"] != null) {
          for (final tableName in differences["missing_tables_in_data_dictionary"]) {
            dropTableStatements.add(AcDDTable.getDropTableStatement(
                tableName: tableName,
                databaseType:
                databaseType)); //  Use the class method, pass databaseType
          }
        }

        result.setSuccess();
        if (dropColumnStatements.isNotEmpty || dropTableStatements.isNotEmpty) {
          logger.warn("There are columns and tables that are not defined in data dictionary. Here are drop statements for dropping them.");
          for (final dropColumnStatement in dropColumnStatements) {
            logger.warn(dropColumnStatement);
          }
          for (final dropTableStatement in dropTableStatements) {
            logger.warn( dropTableStatement);
          }
        }
      } else {
        return result.setFromResult(result:differenceResult);
      }
    } on Exception catch (ex,stack) {
      result.setException(exception:ex, stackTrace:stack, logger: logger);
    }
    return result;
  }

  /// Updates the database schema.
  Future<AcResult> updateSchema() async {
    final result = AcResult();
    bool continueOperation = true;
    final updateDifferenceResult = await updateDatabaseDifferences();
    if (updateDifferenceResult.isSuccess()) {
    } else {
      continueOperation = false;
      result.setFromResult(result:updateDifferenceResult,
          message: 'Error updating differences', logger: logger);
    }
    if (continueOperation) {
      final createViewsResult = await createDatabaseViews();
      if (createViewsResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(result:createViewsResult,
            message: 'Error updating schema database views', logger: logger);
      }
    }
    if (continueOperation) {
      final createTriggersResult = await createDatabaseTriggers();
      if (createTriggersResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(result:createTriggersResult,
            message: 'Error updating schema database triggers',
            logger: logger);
      }
    }
    if (continueOperation) {
      final createStoredProceduresResult =
      await createDatabaseStoredProcedures();
      if (createStoredProceduresResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(result:createStoredProceduresResult,
            message: 'Error updating schema database stored procedures',
            logger: logger);
      }
    }
    if (continueOperation) {
      final createFunctionsResult = await createDatabaseFunctions();
      if (createFunctionsResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(result:createFunctionsResult,
            message: 'Error updating schema database functions',
            logger: logger);
      }
    }
    if (continueOperation) {
      result.setSuccess(message: 'Schema updated successfully', logger: logger);
    }
    return result;
  }


}