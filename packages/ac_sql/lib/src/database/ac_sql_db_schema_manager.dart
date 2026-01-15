import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
/* AcDoc({
  "summary": "Manages database schema creation, updates, and validation against a data dictionary.",
  "description": "This class orchestrates the entire process of initializing a database schema. It can create a database from scratch, apply updates from a new data dictionary version, and report differences between the live database and the current dictionary definition. It uses internal tables to track its own version and log operations.",
  "example": "// Prerequisite: Global AcSqlDatabase settings are configured.\n\n// 1. Create a schema manager instance for your application's data dictionary.\nfinal schemaManager = AcSqlDbSchemaManager(dataDictionaryName: 'my_app_schema');\n\n// 2. Initialize the database. This will create or update the schema as needed.\nfinal result = await schemaManager.initDatabase();\n\nif (result.isSuccess()) {\n  print('Database initialization complete!');\n} else {\n  print('Database initialization failed: \${result.message}');\n}"
}) */
class AcSqlDbSchemaManager extends AcSqlDbBase {
  /* AcDoc({"summary": "A pre-configured handler for the internal `_ac_schema_details` table."}) */
  AcSqlDbTable acSqlDDTableSchemaDetails = AcSqlDbTable(
    tableName: AcSchemaManagerTables.schemaDetails,
    dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
  );

  /* AcDoc({"summary": "A pre-configured handler for the internal `_ac_schema_logs` table."}) */
  AcSqlDbTable acSqlDDTableSchemaLogs = AcSqlDbTable(
    tableName: AcSchemaManagerTables.schemaLogs,
    dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
  );

  /* AcDoc({
    "summary": "Creates a new schema manager instance.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the application's data dictionary to manage."}
    ]
  }) */
  AcSqlDbSchemaManager({super.dataDictionaryName});

  /* AcDoc({
    "summary": "Checks if the live database schema version is older than the current data dictionary version.",
    "returns": "An `AcResult` with a boolean `value`: `true` if an update is available, `false` otherwise.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkSchemaUpdateAvailableFromVersion() async {
    final result = AcResult();
    try {
      logger.log(
        'Checking if database data dictionary version is same as the current data dictionary version...',
      );

      final versionResult = await dao!.getRows(
        statement: acSqlDDTableSchemaDetails.getSelectStatement(),
        condition: "${TblSchemaDetails.acSchemaDetailKey} = @key",
        parameters: {"@key": "${SchemaDetails.keyDataDictionaryVersion}[$dataDictionaryName]"},
        mode: AcEnumDDSelectMode.first, //important
      );

      if (versionResult.isSuccess()) {
        if (versionResult.rows.isNotEmpty) {
          print(versionResult.rows[0]);
          final databaseVersion = versionResult.rows.first.getDouble(TblSchemaDetails.acSchemaDetailNumericValue);
          if (acDataDictionary.version == databaseVersion) {
            logger.log(
              'Database data dictionary version ${acDataDictionary.version} and current data dictionary version $databaseVersion are same.',
            );
            result.setSuccess(value: false); // No update available
          } else if (acDataDictionary.version < databaseVersion) {
            logger.log(
              'Database data dictionary version ${acDataDictionary.version} is greater than the current data dictionary version $databaseVersion.',
            );
            result.setSuccess(value: false); // No update available
          } else {
            logger.log(
              'Database data dictionary version ${acDataDictionary.version} is less than the current data dictionary version $databaseVersion.',
            );
            result.setSuccess(value: true); // Update available
          }
        } else {
          logger.log('No version detail row found in details table.');
          result.setSuccess(value: true); // Update available
        }
      } else {
        result.setFromResult(
          result: versionResult,
          message: 'Error checking schema version',
          logger: logger,
        );
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates or recreates all database functions defined in the data dictionary.",
    "description": "This method iterates through all functions, drops each one if it exists, and then recreates it based on the current definition.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseFunctions() async {
    final result = AcResult();
    try {
      logger.log('Creating functions in database...');
      // final acDDFunctions =
      //     acDataDictionary.getFunctions(dataDictionaryName: acDataDictionary.name); // Removed dataDictionaryName parameter
      final functionList = AcDataDictionary.getFunctions(
        dataDictionaryName: dataDictionaryName,
      ); //<List<AcDDFunction>
      for (final acDDFunction in functionList.values) {
        final dropStatement = AcDDFunction.getDropFunctionStatement(
          functionName: acDDFunction.functionName,
          databaseType: databaseType,
        ); // Made databaseType a class variable.
        logger.log('Executing drop function statement: $dropStatement');
        final dropResult = await dao!.executeStatement(
          statement: dropStatement,
          operation: AcEnumDDRowOperation.unknown,
        );
        if (dropResult.isSuccess()) {
          logger.log('Drop statement executed successfully.');
        } else {
          return result.setFromResult(
            result: dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.function.value,
          TblSchemaLogs.acSchemaEntityName: acDDFunction.functionName,
          TblSchemaLogs.acSchemaOperation: 'drop',
          TblSchemaLogs.acSchemaOperationResult: dropResult.status,
          TblSchemaLogs.acSchemaOperationStatement: dropStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });

        final createStatement = acDDFunction.getCreateFunctionStatement();
        logger.log('Creating function with statement: $createStatement');
        final createResult = await dao!.executeStatement(
          statement: createStatement,
          operation: AcEnumDDRowOperation.unknown,
        );
        if (createResult.isSuccess()) {
          logger.log('Function created successfully.');
        } else {
          return result.setFromResult(
            result: createResult,
            message: 'Error creating function',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.function.value,
          TblSchemaLogs.acSchemaEntityName: acDDFunction.functionName,
          TblSchemaLogs.acSchemaOperation: 'create',
          TblSchemaLogs.acSchemaOperationResult: createResult.status,
          TblSchemaLogs.acSchemaOperationStatement: createStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });
      }
      result.setSuccess(
        message: 'Functions created successfully',
        logger: logger,
      );
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates or recreates all database relationships defined in the data dictionary.",
    "description": "For MySQL, this method first disables foreign key checks, drops all existing foreign key constraints, and then creates new ones based on the current data dictionary definitions.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseRelationships() async {
    final result = AcResult();
    try {
      logger.log('Creating database relationships...');
      bool continueOperation = true;
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        const disableCheckStatement = "SET FOREIGN_KEY_CHECKS = 0;";
        logger.log('Executing disable check statement: $disableCheckStatement');
        final setCheckResult = await dao!.executeStatement(
          statement: disableCheckStatement,
          operation: AcEnumDDRowOperation.unknown,
        );
        if (setCheckResult.isFailure()) {
          continueOperation = false;
          result.setFromResult(
            result: setCheckResult,
            message: 'Error disabling foreign key checks',
            logger: logger,
          );
        } else {
          logger.log('Disabled foreign key checks.');
        }

        if(continueOperation){
          logger.log('Getting and dropping existing relationships...');
          const getDropRelationshipsStatements = "SELECT CONCAT('ALTER TABLE `', table_name, '` DROP FOREIGN KEY `', constraint_name, '`;') AS drop_query, constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = @databaseName";
          final getResult = await dao!.getRows(
            statement: getDropRelationshipsStatements,
            parameters: {"@databaseName": dao!.sqlConnection.database},
          ); // Corrected parameter passing
          if (getResult.isSuccess()) {
            for (final row in getResult.rows) {
              final dropRelationshipStatement = row['drop_query'] as String;
              final constraintName = row['constraint_name'] as String;
              logger.log(
                'Executing drop relationship statement: $dropRelationshipStatement',
              );
              final dropResponse = await dao!.executeStatement(
                statement: dropRelationshipStatement,
                operation: AcEnumDDRowOperation.unknown,
              ); // Added operation
              if (dropResponse.isFailure()) {
                continueOperation = false;
                result.setFromResult(
                  result: dropResponse,
                  message: 'Error dropping relationship',
                  logger: logger,
                );
              } else {
                logger.log('Executed drop relation statement successfully.');
              }
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.relationship.value,
                TblSchemaLogs.acSchemaEntityName: constraintName,
                TblSchemaLogs.acSchemaOperation: 'drop',
                TblSchemaLogs.acSchemaOperationResult: dropResponse.status,
                TblSchemaLogs.acSchemaOperationStatement:
                dropRelationshipStatement,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
              });
            }
          } else {
            continueOperation = false;
            return result.setFromResult(
              result: getResult,
              message: 'Error getting relationships to drop',
              logger: logger,
            );
          }
        }
      }
      if(continueOperation && databaseType != AcEnumSqlDatabaseType.sqlite){
          final relationshipList = AcDataDictionary.getRelationships(
            dataDictionaryName: dataDictionaryName,
          );
          for (final acDDRelationship in relationshipList) {
            if(continueOperation){
              logger.log('Creating relationship for: $acDDRelationship');
              final createRelationshipStatement =
              acDDRelationship.getCreateRelationshipStatement(databaseType: databaseType);
              logger.log(
                'Create relationship statement: $createRelationshipStatement',
              );
              final createResult = await dao!.executeStatement(
                statement: createRelationshipStatement,
              );
              if (createResult.isFailure()) {
                continueOperation = false;
                logger.error("Error creating relationship : ${createResult.message}");
                result.setFromResult(
                  result: createResult,
                  message: 'Error creating relationship',
                  logger: logger,
                );
                break;
              } else {
                logger.log('Relationship created successfully.');
              }
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.relationship.value,
                TblSchemaLogs.acSchemaEntityName:
                '${acDDRelationship.sourceTable}.${acDDRelationship.sourceColumn}>${acDDRelationship.destinationTable}.${acDDRelationship.destinationColumn}',
                TblSchemaLogs.acSchemaOperation: 'create',
                TblSchemaLogs.acSchemaOperationResult: createResult.status,
                TblSchemaLogs.acSchemaOperationStatement:
                createRelationshipStatement,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
              });
            }

          }
      }


      if(continueOperation){
        result.setSuccess(
          message: 'Relationships created successfully',
          logger: logger,
        );
      }

    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates or recreates all stored procedures defined in the data dictionary.",
    "description": "This method iterates through all stored procedures, drops each one if it exists, and then recreates it.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseStoredProcedures() async {
    final result = AcResult();
    try {
      logger.log('Creating stored procedures...');
      final storedProcedureList = AcDataDictionary.getStoredProcedures(
        dataDictionaryName: dataDictionaryName,
      );
      for (final acDDStoredProcedure in storedProcedureList.values) {
        final dropStatement =
            AcDDStoredProcedure.getDropStoredProcedureStatement(
              storedProcedureName: acDDStoredProcedure.storedProcedureName,
              databaseType: databaseType,
            );
        logger.log('Executing drop stored procedure statement: $dropStatement');
        final dropResult = await dao!.executeStatement(
          statement: dropStatement,
        );
        if (dropResult.isSuccess()) {
          logger.log('Drop statement executed successfully.');
        } else {
          return result.setFromResult(
            result: dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType:
              AcEnumSqlEntity.storedProcedure.value,
          TblSchemaLogs.acSchemaEntityName:
              acDDStoredProcedure.storedProcedureName,
          TblSchemaLogs.acSchemaOperation: 'drop',
          TblSchemaLogs.acSchemaOperationResult: dropResult.status,
          TblSchemaLogs.acSchemaOperationStatement: dropStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });

        final createStatement = acDDStoredProcedure
            .getCreateStoredProcedureStatement(databaseType: databaseType);
        logger.log('Create statement: $createStatement');
        final createResult = await dao!.executeStatement(
          statement: createStatement,
        );
        if (createResult.isSuccess()) {
          logger.log('Stored procedure created successfully.');
        } else {
          return result.setFromResult(
            result: createResult,
            message: 'Error creating stored procedure',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType:
              AcEnumSqlEntity.storedProcedure.value,
          TblSchemaLogs.acSchemaEntityName:
              acDDStoredProcedure.storedProcedureName,
          TblSchemaLogs.acSchemaOperation: 'create',
          TblSchemaLogs.acSchemaOperationResult: createResult.status,
          TblSchemaLogs.acSchemaOperationStatement: createStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });
      }
      result.setSuccess(
        message: 'Stored procedures created successfully',
        logger: logger,
      );
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates all database tables defined in the data dictionary.",
    "description": "This method iterates through all table definitions and executes a `CREATE TABLE IF NOT EXISTS` statement for each one.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseTables() async {
    final result = AcResult();
    try {
      bool continueOperation = true;
      if (databaseType == AcEnumSqlDatabaseType.sqlite && dataDictionaryName == AcSMDataDictionary.dataDictionaryName){
        logger.log("Enabling foreign keys for sqlite");
        final enableForeignKeyResult = await dao!.executeStatement(
          statement: 'PRAGMA foreign_keys = ON;',
        );
        if(enableForeignKeyResult.isFailure()){
          continueOperation = false;
          logger.log("Error setting foreign keys on");
          result.setFromResult(result: enableForeignKeyResult);
        }
      }
      if(continueOperation){
        for (final acDDTable in AcDataDictionary.getTables(dataDictionaryName: dataDictionaryName,foreignKeysSorted: dataDictionaryName != AcSMDataDictionary.dataDictionaryName).values) {
          if(continueOperation){
            logger.log('Creating table ${acDDTable.tableName}');
            final createStatement = acDDTable.getCreateTableStatement(
              databaseType: databaseType,
            );
            logger.log('Executing create table statement: $createStatement');
            final createResult = await dao!.executeStatement(
              statement: createStatement,
            );
            if (createResult.isSuccess()) {
              logger.log('Create statement executed successfully.');
            } else {
              continueOperation = false;
              result.setFromResult(
                result: createResult,
                message: 'Error creating table ${acDDTable.tableName}',
                logger: logger,
              );
              break;
            }
            if(dataDictionaryName!=AcSMDataDictionary.dataDictionaryName){
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
                TblSchemaLogs.acSchemaEntityName: acDDTable.tableName,
                TblSchemaLogs.acSchemaOperation: 'create',
                TblSchemaLogs.acSchemaOperationResult: createResult.status,
                TblSchemaLogs.acSchemaOperationStatement: createStatement,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
              });
            }
          }

        }
      }
      if(continueOperation){
        result.setSuccess(message: 'Tables created successfully', logger: logger);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates or recreates all database triggers defined in the data dictionary.",
    "description": "This method iterates through all triggers, drops each one if it exists, and then recreates it.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseTriggers() async {
    final result = AcResult();
    try {
      logger.log('Creating triggers...');
      AcResult timestampTriggers = await createUpdateTimestampTriggers();

      if(timestampTriggers.isSuccess()){
        for (final acDDTrigger
        in AcDataDictionary.getTriggers(
          dataDictionaryName: dataDictionaryName,
        ).values) {
          logger.log('Creating trigger ${acDDTrigger.triggerName}');
          final dropStatement = AcDDTrigger.getDropTriggerStatement(
            triggerName: acDDTrigger.triggerName,
            databaseType: databaseType,
          );
          logger.log('Executing drop trigger statement: $dropStatement');
          final dropResult = await dao!.executeStatement(
            statement: dropStatement,
          );
          if (dropResult.isSuccess()) {
            logger.log('Drop statement executed successfully.');
          } else {
            return result.setFromResult(
              result: dropResult,
              message: 'Error executing drop statement',
              logger: logger,
            );
          }
          await saveSchemaLogEntry({
            TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.trigger.value,
            TblSchemaLogs.acSchemaEntityName: acDDTrigger.triggerName,
            TblSchemaLogs.acSchemaOperation: 'drop',
            TblSchemaLogs.acSchemaOperationResult: dropResult.status,
            TblSchemaLogs.acSchemaOperationStatement: dropStatement,
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
          });

          final createStatement = acDDTrigger.getCreateTriggerStatement(
            databaseType: databaseType,
          );
          logger.log('Create statement: $createStatement');
          final createResult = await dao!.executeStatement(
            statement: createStatement,
          );
          if (createResult.isSuccess()) {
            logger.log('Trigger created successfully.');
          } else {
            return result.setFromResult(
              result: createResult,
              message: 'Error creating trigger',
              logger: logger,
            );
          }
          await saveSchemaLogEntry({
            TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.trigger.value,
            TblSchemaLogs.acSchemaEntityName: acDDTrigger.triggerName,
            TblSchemaLogs.acSchemaOperation: 'create',
            TblSchemaLogs.acSchemaOperationResult: createResult.status,
            TblSchemaLogs.acSchemaOperationStatement: createStatement,
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
          });
        }
        result.setSuccess(
          message: 'Triggers created successfully',
          logger: logger,
        );
      }
      else{
        result.setFromResult(result: timestampTriggers);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates or recreates all database views defined in the data dictionary.",
    "description": "This method iterates through all views, drops each one if it exists, and then recreates it. It includes a retry mechanism for views that may depend on other, later-created views.",
    "returns": "An `AcResult` indicating the overall success or failure.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createDatabaseViews() async {
    final result = AcResult();
    try {
      logger.log('Creating views...');
      final viewList = AcDataDictionary.getViews(
        dataDictionaryName: dataDictionaryName,
      ); // Get views
      List<AcDDView> errorViews = [];
      for (final acDDView in viewList.values) {
        logger.log('Creating view ${acDDView.viewName}');
        final dropStatement = AcDDView.getDropViewStatement(
          viewName: acDDView.viewName,
          databaseType: databaseType,
        );
        logger.log('Executing drop view statement: $dropStatement');
        final dropResult = await dao!.executeStatement(
          statement: dropStatement,
        );
        if (dropResult.isSuccess()) {
          logger.log('Drop statement executed successfully.');
        } else {
          return result.setFromResult(
            result: dropResult,
            message: 'Error executing drop statement',
            logger: logger,
          );
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.view.value,
          TblSchemaLogs.acSchemaEntityName: acDDView.viewName,
          TblSchemaLogs.acSchemaOperation: 'drop',
          TblSchemaLogs.acSchemaOperationResult: dropResult.status,
          TblSchemaLogs.acSchemaOperationStatement: dropStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });

        final createStatement = acDDView.getCreateViewStatement(
          databaseType: databaseType,
        );
        logger.log('Create statement: $createStatement');
        final createResult = await dao!.executeStatement(
          statement: createStatement,
        );
        if (createResult.isSuccess()) {
          logger.log('View created successfully.');
        } else {
          logger.error('Error creating view');
          errorViews.add(acDDView);
        }
        await saveSchemaLogEntry({
          TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.view.value,
          TblSchemaLogs.acSchemaEntityName: acDDView.viewName,
          TblSchemaLogs.acSchemaOperation: 'create',
          TblSchemaLogs.acSchemaOperationResult: createResult.status,
          TblSchemaLogs.acSchemaOperationStatement: createStatement,
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
        });
      }

      if (errorViews.isNotEmpty) {
        logger.log('Retrying creating ${errorViews.length} views with errors');
        int retryCount = 0;
        List<AcDDView> retryViews = [];
        while (errorViews.isNotEmpty && retryCount < 10) {
          retryCount++;
          logger.log(
            "${errorViews.length} views with errors will be retried in iteration $retryCount",
          );
          for (final acDDView in errorViews) {
            final createStatement = acDDView.getCreateViewStatement(
              databaseType: databaseType,
            );
            logger.log(
              'Retrying creating view for ${acDDView.viewName}, $createStatement',
            );
            final createResult = await dao!.executeStatement(
              statement: createStatement,
            );
            if (createResult.isSuccess()) {
              logger.log('View created successfully');
            } else {
              logger.error('Error creating view');
              retryViews.add(acDDView);
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.view.value,
              TblSchemaLogs.acSchemaEntityName: acDDView.viewName,
              TblSchemaLogs.acSchemaOperation: 'create',
              TblSchemaLogs.acSchemaOperationResult: createResult.status,
              TblSchemaLogs.acSchemaOperationStatement: createStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
            });
          }
          logger.log(
            "After iteration $retryCount, ${retryViews.length} still has errors",
          );
          errorViews = retryViews;
          retryViews = [];
          logger.log(
            "Will try executing ${errorViews.length} in next iteration",
          );
        }
        logger.log(
          "After retrying creating error views, there are ${errorViews.length} with errors",
        );
        if (errorViews.isNotEmpty) {
          List<Map<String, String>> errorViewsList = [];
          for (final acDDView in errorViews) {
            final createStatement = acDDView.getCreateViewStatement(
              databaseType: databaseType,
            );
            final errorViewDetails = {
              AcDDViewColumn.keyColumnName: acDDView.viewName,
              "create_statement": createStatement,
            };
            logger.error(["Error in view", errorViewDetails]);
            errorViewsList.add(errorViewDetails);
          }
          result.setFailure(
            value: errorViewsList,
            message: 'Error creating views',
            logger: logger,
          );
        }
      }

      if (errorViews.isEmpty) {
        result.setSuccess(
          message: 'Views created successfully',
          logger: logger,
        );
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Creates the entire database schema.",
    "description": "This is a composite method that orchestrates the creation of all schema entities in the correct order: tables, views, triggers, stored procedures, and functions.",
    "returns": "An `AcResult` indicating the overall success or failure of the entire process.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> createSchema() async {
    final result = AcResult();
    try {
      logger.log(
        'Creating schema in database for data dictionary $dataDictionaryName...',
      );
      logger.log(
        'Creating tables in database for data dictionary $dataDictionaryName...',
      );
      final createTablesResult = await createDatabaseTables();
      if (createTablesResult.isSuccess()) {
        logger.log('Tables created successfully');
      } else {
        return result.setFromResult(
          result: createTablesResult,
          message: 'Error creating schema database tables',
          logger: logger,
        );
      }

      final createViewsResult = await createDatabaseViews();
      if (createViewsResult.isSuccess()) {
        logger.log('Views created successfully');
      } else {
        return result.setFromResult(
          result: createViewsResult,
          message: 'Error creating schema database views',
          logger: logger,
        );
      }

      // final createRelationshipsResult = await createDatabaseRelationships();
      // if (createRelationshipsResult.isSuccess()) {
      //   logger.log('Relationships created successfully');
      // } else {
      //   return result.setFromResult(
      //     result: createRelationshipsResult,
      //     message: 'Error creating schema database relationships',
      //     logger: logger,
      //   );
      // }

      final createTriggersResult = await createDatabaseTriggers();
      if (createTriggersResult.isSuccess()) {
        logger.log('Triggers created successfully');
      } else {
        return result.setFromResult(
          result: createTriggersResult,
          message: 'Error creating schema database triggers',
          logger: logger,
        );
      }

      final createStoredProceduresResult =
          await createDatabaseStoredProcedures();
      if (createStoredProceduresResult.isSuccess()) {
        logger.log('Stored procedures created successfully');
      } else {
        return result.setFromResult(
          result: createStoredProceduresResult,
          message: 'Error creating schema database stored procedures',
          logger: logger,
        );
      }

      final createFunctionsResult = await createDatabaseFunctions();
      if (createFunctionsResult.isSuccess()) {
        logger.log('Functions created successfully');
      } else {
        return result.setFromResult(
          result: createFunctionsResult,
          message: 'Error creating schema database functions',
          logger: logger,
        );
      }

      result.setSuccess(message: 'Schema created successfully', logger: logger);
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> createUpdateTimestampTriggers() async {
    final result = AcResult();
    try {
      bool continueOperation = true;
      String columnName = acDDConfig.updateTimestampColumnKey;
      if(columnName.isNotEmpty){
        // Optional: same foreign key enabling block as in your table creation
        if (databaseType == AcEnumSqlDatabaseType.sqlite &&
            dataDictionaryName == AcSMDataDictionary.dataDictionaryName) {
          logger.log("Enabling foreign keys for sqlite (triggers phase)");
          final enableForeignKeyResult = await dao!.executeStatement(
            statement: 'PRAGMA foreign_keys = ON;',
          );
          if (enableForeignKeyResult.isFailure()) {
            continueOperation = false;
            logger.log("Error setting foreign keys on");
            result.setFromResult(result: enableForeignKeyResult);
          }
        }

        if (continueOperation) {
          // Get only tables that have updated_at column
          final tablesWithUpdatedAt = AcDataDictionary.getTables(
            dataDictionaryName: dataDictionaryName,
            foreignKeysSorted: dataDictionaryName != AcSMDataDictionary.dataDictionaryName,
          ).values.toList();

          for (final acDDTable in tablesWithUpdatedAt) {
            if (!continueOperation) break;

            final tableName = acDDTable.tableName;
            final triggerName = 'ac_tr_${tableName}_set_upd_ts';

            logger.log('Creating update trigger for $tableName → $triggerName');

            final createTriggerStmt = '''
                CREATE TRIGGER IF NOT EXISTS $triggerName
                BEFORE UPDATE ON $tableName
                FOR EACH ROW
                WHEN NEW.$columnName IS NULL
                BEGIN
                  UPDATE $tableName SET $columnName = strftime('%Y-%m-%dT%H:%M:%fZ', 'now') WHERE rowid = NEW.rowid;
                END;
              ''';

            logger.log('Executing trigger statement:\n$createTriggerStmt');

            final triggerResult = await dao!.executeStatement(
              statement: createTriggerStmt,
            );

            if (triggerResult.isSuccess()) {
              logger.log('Trigger $triggerName created successfully.');
            } else {
              continueOperation = false;
              result.setFromResult(
                result: triggerResult,
                message: 'Error creating trigger for table $tableName',
                logger: logger,
              );
              break;
            }

            // Optional: log schema change (same as your table creation)
            if (dataDictionaryName != AcSMDataDictionary.dataDictionaryName) {
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.trigger.value,
                TblSchemaLogs.acSchemaEntityName: triggerName,
                TblSchemaLogs.acSchemaOperation: 'create',
                TblSchemaLogs.acSchemaOperationResult: triggerResult.status,
                TblSchemaLogs.acSchemaOperationStatement: createTriggerStmt,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
              });
            }
          }
        }

        if (continueOperation) {
          result.setSuccess(
            message: 'All update timestamp triggers created successfully',
            logger: logger,
          );
        }
      }
      else{
        result.setSuccess();
      }

    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }

    return result;
  }

// Helper method - generates the actual trigger SQL
  String _generateUpdateAtTriggerSql({
    required String tableName,
    required String columnName,
    required String triggerName,
    required AcEnumSqlDatabaseType databaseType,
  }) {
    if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      return '''
        CREATE TRIGGER IF NOT EXISTS $triggerName
        BEFORE UPDATE ON $tableName
        FOR EACH ROW
        WHEN NEW.$columnName IS NULL
        BEGIN
          SET $columnName = strftime('%Y-%m-%dT%H:%M:%fZ', 'now');
        END;
      ''';
    } else {
      return '';
    }
  }

  /* AcDoc({
    "summary": "Compares the live database schema against the current data dictionary.",
    "description": "This method inspects the live database and reports on differences, such as tables or columns that exist in one but not the other, and tables that have different column definitions.",
    "returns": "An `AcResult` where the `value` is a map detailing the differences.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> getDatabaseSchemaDifference() async {
    final result = AcResult();
    try {
      // Map<String, dynamic> differenceResult = {};
      AcSqlSchemaDifference schemaDifference = AcSqlSchemaDifference();
      final getTablesResult = await dao!.getDatabaseTables();
      if (getTablesResult.isSuccess()) {
        List<String> currentDataDictionaryTables =
            acDataDictionary.tables.keys.toList();
        List<String> foundTables = [];
        // List<Map<String, dynamic>> modifiedTables = [];
        // List<String> missingInDataDictionaryTables = [];
        for (final tableRow in getTablesResult.rows) {
          if (tableRow[AcDDTable.keyTableName] !=
                  AcSchemaManagerTables.schemaDetails &&
              tableRow[AcDDTable.keyTableName] !=
                  AcSchemaManagerTables.schemaLogs) {
            if (currentDataDictionaryTables.contains(
              tableRow[AcDDTable.keyTableName],
            )) {
              AcSqlSchemaTableDifference tableDifference = AcSqlSchemaTableDifference(tableName:tableRow[AcDDTable.keyTableName]);
              // Map<String, dynamic> tableDifferenceResult = {};
              foundTables.add(tableRow[AcDDTable.keyTableName]);
              final getTableColumnsResult = await dao!.getTableColumns(
                tableName: tableRow[AcDDTable.keyTableName],
              );
              if (getTableColumnsResult.isSuccess()) {
                final currentDataDictionaryColumns = acDataDictionary
                    .getTableColumnNames(
                      tableName: tableRow[AcDDTable.keyTableName],
                    );
                List<String> foundColumns = [];
                for (final columnRow in getTableColumnsResult.rows) {
                  if (currentDataDictionaryColumns.contains(
                    columnRow[AcDDTableColumn.keyColumnName],
                  )) {
                    foundColumns.add(columnRow[AcDDTableColumn.keyColumnName],
                    );
                  } else {
                    tableDifference.missingColumnsInDataDictionary.add(
                      columnRow[AcDDTableColumn.keyColumnName],
                    );
                  }
                }
                tableDifference.missingColumnsInDatabase.addAll(currentDataDictionaryColumns.where((element) => !foundColumns.contains(element)));
                // tableDifferenceResult["missing_columns_in_database"] =
                //     currentDataDictionaryColumns
                //         .where((element) => !foundColumns.contains(element))
                //         .toList();
                // tableDifferenceResult["missing_columns_in_data_dictionary"] =
                //     missingInDataDictionaryColumns;
              } else {
                return result.setFromResult(
                  result: getTableColumnsResult,
                  message:
                      'Error getting columns for table ${tableRow[AcDDTable.keyTableName]}',
                  logger: logger,
                );
              }
              if(tableDifference.missingColumnsInDataDictionary.isNotEmpty || tableDifference.missingColumnsInDatabase.isNotEmpty){
                schemaDifference.modifiedTables.add(tableDifference);
              }
              // if (tableDifferenceResult['missing_columns_in_database'].length >
              //         0 ||
              //     tableDifferenceResult["missing_columns_in_data_dictionary"]
              //             .length >
              //         0) {
              //   modifiedTables.add({
              //     AcDDTable.keyTableName: tableRow[AcDDTable.keyTableName],
              //     "difference_List<>details": tableDifferenceResult,
              //   });
              // }
            } else {
              schemaDifference.missingTablesInDataDictionary.add(
                tableRow[AcDDTable.keyTableName],
              );
            }
          }
        }
        schemaDifference.missingTablesInDatabase.addAll(currentDataDictionaryTables.where((element) => !foundTables.contains(element)));
        // schemaDifference.missingTablesInDataDictionary.addAll(missingInDataDictionaryTables);
        // differenceResult["missing_tables_in_database"] =  currentDataDictionaryTables.where((element) => !foundTables.contains(element)).toList();
        // differenceResult["missing_tables_in_data_dictionary"] = missingInDataDictionaryTables;
        // differenceResult["modified_tables_in_data_dictionary"] = modifiedTables;
        result.setSuccess();
        result.value = schemaDifference;
      } else {
        return result.setFromResult(
          result: getTablesResult,
          message: 'Error getting current database tables',
          logger: logger,
        );
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Initializes the database, creating or updating the schema as necessary.",
    "description": "This is the main entry point for the schema manager. It checks if the database exists, creates it if not, and then creates or updates the schema to match the current data dictionary version. It also ensures the manager's own internal tracking tables are present.",
    "returns": "An `AcResult` indicating the final outcome of the initialization process.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> initDatabase() async {
    final result = AcResult();
    try {
      logger.log(
        "Initializing database for data dictionary $dataDictionaryName...",
      );
      final checkResult = await dao!.checkDatabaseExist();
      if (checkResult.isSuccess()) {
        final schemaResult = await initSchemaDataDictionary();
        if (schemaResult.isSuccess()) {
          bool updateDataDictionaryVersion = false;
          if (checkResult.value == false) {
            logger.log("Creating database...");
            final createDbResult = await dao!.createDatabase();
            if (createDbResult.isSuccess()) {
              logger.log("Database created successfully");
              final createSchemaResult = await createSchema();
              if (createSchemaResult.isSuccess()) {
                updateDataDictionaryVersion = true;
                result.setSuccess(
                  message: 'Schema created successfully',
                  logger: logger,
                );
                var createdOnResponse = await saveSchemaDetail({
                  TblSchemaDetails.acSchemaDetailKey:
                      SchemaDetails.keyCreatedOn,
                  TblSchemaDetails.acSchemaDetailStringValue:
                      DateTime.now(),
                });
                if (createdOnResponse.isFailure()) {
                  result.setFromResult(result: createdOnResponse, message: 'error saving created on schema detail' );
                }
              } else {
                return result.setFromResult(
                  result: createSchemaResult,
                  message:
                      "Error creating database schema from data dictionary",
                  logger: logger,
                );
              }
            } else {
              return result.setFromResult(
                result: createDbResult,
                message: "Error creating database",
                logger: logger,
              );
            }
          } else {
            final checkUpdateResult =
                await checkSchemaUpdateAvailableFromVersion();
            if (checkUpdateResult.isSuccess()) {
              if (checkUpdateResult.value == true) {
                final updateSchemaResult = await updateSchema();
                if (updateSchemaResult.isSuccess()) {
                  updateDataDictionaryVersion = true;
                  result.setSuccess(
                    message: 'Schema updated successfully',
                    logger: logger,
                  );
                  var updatedOnResponse = await saveSchemaDetail({
                    TblSchemaDetails.acSchemaDetailKey:
                        SchemaDetails.keyLastUpdatedOn,
                    TblSchemaDetails.acSchemaDetailStringValue:
                        DateTime.now(),
                  });
                  if (updatedOnResponse.isFailure()) {
                    result.setFromResult(result: updatedOnResponse, message: 'error saving updated on schema detail' );
                  }
                } else {
                  return result.setFromResult(
                    result: updateSchemaResult,
                    message:
                        "Error updating database schema from data dictionary",
                    logger: logger,
                  );
                }
              } else {
                result.setSuccess(
                  message: 'Schema is latest. No changes required',
                  logger: logger,
                );
              }
            } else {
              return result.setFromResult(
                result: checkUpdateResult,
                message: "Error checking for schema updates",
                logger: logger,
              );
            }
          }
          if (updateDataDictionaryVersion) {
            var versionLogResponse = await saveSchemaDetail({
              TblSchemaDetails.acSchemaDetailKey:
                  "${SchemaDetails.keyDataDictionaryVersion}[$dataDictionaryName]",
              TblSchemaDetails.acSchemaDetailNumericValue:
                  acDataDictionary.version,
            });
            if (versionLogResponse.isFailure()) {
              result.setFromResult(result: versionLogResponse, message: 'error saving version schema detail' );
            }
          }
        } else {
          return result.setFromResult(
            result: schemaResult,
            message: "Error initializing schema data dictionary",
            logger: logger,
          );
        }
      } else {
        return result.setFromResult(
          result: checkResult,
          message: "Error checking if database exists",
          logger: logger,
        );
      }
    } on Exception catch (ex, stack) {

      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Initializes the internal schema required by the Schema Manager itself.",
    "description": "Ensures that the `_ac_schema_details` and `_ac_schema_logs` tables exist so that the manager can track schema versions and log its operations.",
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> initSchemaDataDictionary() async {
    final result = AcResult();
    try {
      if (!AcDataDictionary.dataDictionaries.containsKey(
        AcSMDataDictionary.dataDictionaryName,
      )) {
        logger.log("Registering schema data dictionary...");
        AcDataDictionary.registerDataDictionary(
          jsonData: AcSMDataDictionary.dataDictionary,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        acSqlDDTableSchemaDetails = AcSqlDbTable(
          tableName: AcSchemaManagerTables.schemaDetails,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        acSqlDDTableSchemaLogs = AcSqlDbTable(
          tableName: AcSchemaManagerTables.schemaLogs,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        final acSchemaManager = AcSqlDbSchemaManager(dataDictionaryName: AcSMDataDictionary.dataDictionaryName);
        acSchemaManager.dao = dao;
        acSchemaManager.logger = logger;
        acSchemaManager.useDataDictionary(
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        // acSchemaManager.acDataDictionary = acDataDictionary;
        final initSchemaResult = await acSchemaManager.initDatabase();
        if (initSchemaResult.isSuccess()) {
          result.setSuccess(
            message: 'Schema data dictionary initialized successfully',
            logger: logger,
          );
        } else {
          return result.setFromResult(
            result: initSchemaResult,
            message: "Error setting schema entities in database",
            logger: logger,
          );
        }
      } else {
        result.setSuccess(
          message: 'Schema data dictionary already initialized',
          logger: logger,
        );
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Saves a record to the internal `_ac_schema_logs` table.",
    "params": [{"name": "row", "description": "A map representing the log entry."}],
    "returns": "An `AcSqlDaoResult` from the insert operation.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> saveSchemaLogEntry(Map<String, dynamic> row) async {
    print(row);
    AcSqlDaoResult result =  await acSqlDDTableSchemaLogs.saveRow(row: row);
    if(result.isFailure()){
      print(result.toJson());
    }
    print(result);
    return result;
  }

  /* AcDoc({
    "summary": "Saves a key-value record to the internal `_ac_schema_details` table.",
    "description": "Used to store persistent metadata like the schema version and creation/update timestamps.",
    "params": [{"name": "data", "description": "A map representing the detail entry."}],
    "returns": "An `AcSqlDaoResult` from the save operation.",
    "returns_type": "Future<AcSqlDaoResult>"
  }) */
  Future<AcSqlDaoResult> saveSchemaDetail(Map<String, dynamic> row) async {
    AcSqlDaoResult result =  await acSqlDDTableSchemaDetails.saveRow(row: row);
    if(result.isFailure()){
      print(result.toJson());
    }
    return result;
  }

  /* AcDoc({
    "summary": "Applies schema changes to the database based on a difference analysis.",
    "description": "This method takes the output of `getDatabaseSchemaDifference` and executes the necessary `CREATE TABLE` or `ALTER TABLE ADD COLUMN` statements. It logs statements for dropping extra tables/columns but does not execute them automatically.",
    "returns": "An `AcResult` indicating the outcome.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> updateDatabaseDifferences() async {
    final result = AcResult();
    try {
      final differenceResult = await getDatabaseSchemaDifference();
      if (differenceResult.isSuccess()) {
        AcSqlSchemaDifference differences =  differenceResult.value; // Cast the value
        List<String> dropColumnStatements = [];
        List<String> dropTableStatements = [];
        if (differences.missingTablesInDatabase.isNotEmpty) {
          for (final tableName in differences.missingTablesInDatabase) {
            logger.log("Creating table $tableName");
            final acDDTable = AcDDTable.getInstance(
              tableName: tableName,
              dataDictionaryName: dataDictionaryName,
            );
            print(acDDTable.tableColumns.length);
            final createStatement = acDDTable.getCreateTableStatement(databaseType: databaseType);
            logger.log([
              "Executing create table statement...",
              createStatement,
            ]);
            final createResult = await dao!.executeStatement(
              statement: createStatement,
            );
            if (createResult.isSuccess()) {
              logger.log("Create statement executed successfully");
            } else {
              return result.setFromResult(result: createResult, logger: logger);
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
              TblSchemaLogs.acSchemaEntityName: tableName,
              TblSchemaLogs.acSchemaOperation: 'create',
              TblSchemaLogs.acSchemaOperationResult: createResult.status,
              TblSchemaLogs.acSchemaOperationStatement: createStatement,
              TblSchemaLogs.acSchemaOperationTimestamp:
                  DateTime.now(),
            });
          }
        }

        if (differences.modifiedTables.isNotEmpty) {
          for (final modificationDetails in differences.modifiedTables) {
            final tableName = modificationDetails.tableName;
            if (modificationDetails.missingColumnsInDatabase.isNotEmpty) {
              for (final columnName in modificationDetails.missingColumnsInDatabase) {
                logger.log("Adding table column $columnName");
                final acDDTableColumn = AcDDTableColumn.getInstance(
                  tableName: tableName,
                  columnName: columnName,
                  dataDictionaryName: dataDictionaryName,
                );
                final addStatement = acDDTableColumn.getAddColumnStatement(
                  tableName: tableName, databaseType: databaseType
                );
                logger.log([
                  "Executing add table column statement...",
                  addStatement,
                ]);
                final createResult = await dao!.executeStatement(
                  statement: addStatement,
                );
                if (createResult.isSuccess()) {
                  logger.log("Add statement executed successfully");
                } else {
                  return result.setFromResult(
                    result: createResult,
                    logger: logger,
                  );
                }
                await saveSchemaLogEntry({
                  TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
                  TblSchemaLogs.acSchemaEntityName: tableName,
                  TblSchemaLogs.acSchemaOperation: 'modify',
                  TblSchemaLogs.acSchemaOperationResult: createResult.status,
                  TblSchemaLogs.acSchemaOperationStatement: addStatement,
                  TblSchemaLogs.acSchemaOperationTimestamp:DateTime.now(),
                });
              }
            }
            if (modificationDetails.missingColumnsInDataDictionary.isNotEmpty) {
              for (final columnName in modificationDetails.missingColumnsInDataDictionary) {
                String dropColumnStatement =
                    AcDDTableColumn.getDropColumnStatement(
                      tableName: tableName,
                      columnName: columnName,
                      databaseType: databaseType,
                    );
                dropColumnStatements.add(
                  dropColumnStatement,
                ); // Use the class method, and pass databaseType
              }
            }
          }
        }
        if (differences.missingTablesInDataDictionary.isNotEmpty) {
          for (final tableName in differences.missingTablesInDataDictionary) {
            dropTableStatements.add(
              AcDDTable.getDropTableStatement(
                tableName: tableName,
                databaseType: databaseType,
              ),
            ); //  Use the class method, pass databaseType
          }
        }

        result.setSuccess();
        if (dropColumnStatements.isNotEmpty || dropTableStatements.isNotEmpty) {
          logger.warn(
            "There are columns and tables that are not defined in data dictionary. Here are drop statements for dropping them.",
          );
          for (final dropColumnStatement in dropColumnStatements) {
            logger.warn(dropColumnStatement);
          }
          for (final dropTableStatement in dropTableStatements) {
            logger.warn(dropTableStatement);
          }
        }
      } else {
        return result.setFromResult(result: differenceResult);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Updates an existing database schema to match the current data dictionary.",
    "description": "This is a composite method that first applies structural differences (new tables/columns) and then recreates other database objects like views, triggers, stored procedures, and functions to ensure they are up-to-date.",
    "returns": "An `AcResult` indicating the outcome of the full update process.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> updateSchema() async {
    final result = AcResult();
    bool continueOperation = true;
    final updateDifferenceResult = await updateDatabaseDifferences();
    if (updateDifferenceResult.isSuccess()) {
    } else {
      continueOperation = false;
      result.setFromResult(
        result: updateDifferenceResult,
        message: 'Error updating differences',
        logger: logger,
      );
    }
    if (continueOperation) {
      final createViewsResult = await createDatabaseViews();
      if (createViewsResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(
          result: createViewsResult,
          message: 'Error updating schema database views',
          logger: logger,
        );
      }
    }
    if (continueOperation) {
      final createTriggersResult = await createDatabaseTriggers();
      if (createTriggersResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(
          result: createTriggersResult,
          message: 'Error updating schema database triggers',
          logger: logger,
        );
      }
    }
    if (continueOperation) {
      final createStoredProceduresResult =
          await createDatabaseStoredProcedures();
      if (createStoredProceduresResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(
          result: createStoredProceduresResult,
          message: 'Error updating schema database stored procedures',
          logger: logger,
        );
      }
    }
    if (continueOperation) {
      final createFunctionsResult = await createDatabaseFunctions();
      if (createFunctionsResult.isSuccess()) {
      } else {
        continueOperation = false;
        result.setFromResult(
          result: createFunctionsResult,
          message: 'Error updating schema database functions',
          logger: logger,
        );
      }
    }
    if (continueOperation) {
      result.setSuccess(message: 'Schema updated successfully', logger: logger);
    }
    return result;
  }
}
