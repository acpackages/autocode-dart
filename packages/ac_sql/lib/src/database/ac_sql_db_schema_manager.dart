import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "Manages database schema creation, updates, and validation against a data dictionary.",
  "description": "This class orchestrates the entire process of initializing a database schema. It can create a database from scratch, apply updates from a new data dictionary version, and report differences between the live database and the current dictionary definition. It uses internal tables to track its own version and log operations.",
  "example": "// Prerequisite: Global AcSqlDatabase settings are configured.\n\n// 1. Create a schema manager instance for your application's data dictionary.\nfinal schemaManager = AcSqlDbSchemaManager(dataDictionaryName: 'my_app_schema');\n\n// 2. Initialize the database. This will create or update the schema as needed.\nfinal result = await schemaManager.initDatabase();\n\nif (result.isSuccess()) {\n  logger.log('[AcSqlDbSchemaManager] Database initialization complete!');\n} else {\n  logger.log('[AcSqlDbSchemaManager] Database initialization failed: \${result.message}');\n}"
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

  bool ignoreFunctions = false;
  bool ignoreTriggers = false;
  bool ignoreViews = false;
  bool ignoreStoredProcedures = false;

  bool skipSchema = false;

  /* AcDoc({
    "summary": "Creates a new schema manager instance.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the application's data dictionary to manage."}
    ]
  }) */
  AcSqlDbSchemaManager({super.dataDictionaryName, super.dao}) {
    if (dao != null) {
      acSqlDDTableSchemaDetails.dao = dao;
      acSqlDDTableSchemaLogs.dao = dao;
    }
    logger.logMessages = false;
    logger.logType = AcEnumLogType.console;
  }

  // Helper method - generates the actual trigger SQL
  List<String> _generateUpdateAtTriggerSql({
    required String tableName,
    required String columnName,
    required String triggerName,
    required AcEnumSqlDatabaseType databaseType,
  }) {
    if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      return [
        '''
        CREATE TRIGGER IF NOT EXISTS $triggerName
        BEFORE UPDATE ON $tableName
        FOR EACH ROW
        WHEN NEW.$columnName IS NULL
        BEGIN
          UPDATE $tableName SET $columnName = strftime('%Y-%m-%dT%H:%M:%fZ', 'now') WHERE rowid = NEW.rowid;
        END;
      ''',
      ];
    } else if (databaseType == AcEnumSqlDatabaseType.postgres) {
      String functionName = '${triggerName}_func';
      return [
        '''
        CREATE OR REPLACE FUNCTION $functionName() RETURNS TRIGGER AS \$\$ 
        BEGIN 
          IF NEW."$columnName" IS NULL THEN
            NEW."$columnName" = CURRENT_TIMESTAMP; 
          END IF;
          RETURN NEW; 
        END; \$\$ LANGUAGE plpgsql;''',
        '''
        CREATE TRIGGER $triggerName
        BEFORE UPDATE ON "$tableName"
        FOR EACH ROW
        EXECUTE FUNCTION $functionName();
      ''',
      ];
    } else {
      return [''];
    }
  }

  /* AcDoc({
    "summary": "Checks if the live database schema version is older than the current data dictionary version.",
    "returns": "An `AcResult` with a boolean `value`: `true` if an update is available, `false` otherwise.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> checkSchemaUpdateAvailableFromVersion() async {
    final result = AcResult();
    try {
      logger.log(
        '[AcSqlDbSchemaManager] Checking if database data dictionary version is same as the current data dictionary version...',
      );

      final versionResult = await dao!.getRows(
        statement: acSqlDDTableSchemaDetails.getSelectStatement(),
        condition: "${TblSchemaDetails.acSchemaDetailKey} = @key",
        parameters: {
          "@key":
              "${SchemaDetails.keyDataDictionaryVersion}[$dataDictionaryName]",
        },
        mode: AcEnumDDSelectMode.first, //important
      );

      if (versionResult.isSuccess()) {
        if (versionResult.rows.isNotEmpty) {
          final databaseVersion = versionResult.rows.first.getDouble(
            TblSchemaDetails.acSchemaDetailNumericValue,
          );
          if (acDataDictionary.version == databaseVersion) {
            logger.log(
              '[AcSqlDbSchemaManager] Database data dictionary version ${acDataDictionary.version} and current data dictionary version $databaseVersion are same.',
            );
            result.setSuccess(value: false); // No update available
          } else if (acDataDictionary.version < databaseVersion) {
            logger.log(
              '[AcSqlDbSchemaManager] Database data dictionary version ${acDataDictionary.version} is greater than the current data dictionary version $databaseVersion.',
            );
            result.setSuccess(value: false); // No update available
          } else {
            logger.log(
              '[AcSqlDbSchemaManager] Database data dictionary version ${acDataDictionary.version} is less than the current data dictionary version $databaseVersion.',
            );
            result.setSuccess(value: true); // Update available
          }
        } else {
          logger.log(
            '[AcSqlDbSchemaManager] No version detail row found in details table.',
          );
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
  Future<AcResult> createDatabaseFunctions({
    bool skipExistingDrop = false,
  }) async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Creating functions in database...');
      // final acDDFunctions =
      //     acDataDictionary.getFunctions(dataDictionaryName: acDataDictionary.name); // Removed dataDictionaryName parameter
      final functionList = AcDataDictionary.getFunctions(
        dataDictionaryName: dataDictionaryName,
      ); //<List<AcDDFunction>
      for (final acDDFunction in functionList.values) {
        if (!skipExistingDrop) {
          final dropStatement = AcDDFunction.getDropFunctionStatement(
            functionName: acDDFunction.functionName,
            databaseType: databaseType,
          ); // Made databaseType a class variable.
          logger.log(
            '[AcSqlDbSchemaManager] Executing drop function statement: $dropStatement',
          );
          final dropResult = await dao!.executeStatement(
            statement: dropStatement,
            operation: AcEnumDDRowOperation.unknown,
          );

          await saveSchemaLogEntry({
            TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.function.value,
            TblSchemaLogs.acSchemaEntityName: acDDFunction.functionName,
            TblSchemaLogs.acSchemaOperation: 'drop',
            TblSchemaLogs.acSchemaOperationResult: dropResult.status,
            TblSchemaLogs.acSchemaOperationStatement: dropStatement,
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                .toUtcIso8601String(),
          });
          if (dropResult.isSuccess()) {
            logger.log(
              '[AcSqlDbSchemaManager] Drop statement executed successfully.',
            );
          } else {
            return result.setFromResult(
              result: dropResult,
              message: 'Error executing drop statement',
              logger: logger,
            );
          }
        }

        final createStatement = acDDFunction.getCreateFunctionStatement();
        logger.log(
          '[AcSqlDbSchemaManager] Creating function with statement: $createStatement',
        );
        final createResult = await dao!.executeStatement(
          statement: createStatement,
          operation: AcEnumDDRowOperation.unknown,
        );
        if (createResult.isSuccess()) {
          logger.log('[AcSqlDbSchemaManager] Function created successfully.');
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
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
              .toUtcIso8601String(),
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
      logger.log('[AcSqlDbSchemaManager] Creating database relationships...');
      bool continueOperation = true;
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        const disableCheckStatement = "SET FOREIGN_KEY_CHECKS = 0;";
        logger.log(
          '[AcSqlDbSchemaManager] Executing disable check statement: $disableCheckStatement',
        );
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
          logger.log('[AcSqlDbSchemaManager] Disabled foreign key checks.');
        }

        if (continueOperation) {
          logger.log(
            '[AcSqlDbSchemaManager] Getting and dropping existing relationships...',
          );
          const getDropRelationshipsStatements =
              "SELECT CONCAT('ALTER TABLE `', table_name, '` DROP FOREIGN KEY `', constraint_name, '`;') AS drop_query, constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = @databaseName";
          final getResult = await dao!.getRows(
            statement: getDropRelationshipsStatements,
            parameters: {"@databaseName": dao!.sqlConnection.database},
          ); // Corrected parameter passing
          if (getResult.isSuccess()) {
            for (final row in getResult.rows) {
              final dropRelationshipStatement = row['drop_query'] as String;
              final constraintName = row['constraint_name'] as String;
              logger.log(
                '[AcSqlDbSchemaManager] Executing drop relationship statement: $dropRelationshipStatement',
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
                logger.log(
                  '[AcSqlDbSchemaManager] Executed drop relation statement successfully.',
                );
              }
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType:
                    AcEnumSqlEntity.relationship.value,
                TblSchemaLogs.acSchemaEntityName: constraintName,
                TblSchemaLogs.acSchemaOperation: 'drop',
                TblSchemaLogs.acSchemaOperationResult: dropResponse.status,
                TblSchemaLogs.acSchemaOperationStatement:
                    dropRelationshipStatement,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                    .toUtcIso8601String(),
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
      if (continueOperation && databaseType != AcEnumSqlDatabaseType.sqlite) {
        final relationshipList = AcDataDictionary.getRelationships(
          dataDictionaryName: dataDictionaryName,
        );
        for (final acDDRelationship in relationshipList) {
          if (continueOperation) {
            logger.log(
              '[AcSqlDbSchemaManager] Creating relationship for: $acDDRelationship',
            );
            final createRelationshipStatement = acDDRelationship
                .getCreateRelationshipStatement(databaseType: databaseType);
            logger.log(
              '[AcSqlDbSchemaManager] Create relationship statement: $createRelationshipStatement',
            );
            final createResult = await dao!.executeStatement(
              statement: createRelationshipStatement,
            );
            if (createResult.isFailure()) {
              continueOperation = false;
              logger.error(
                "[AcSqlDbSchemaManager] Error creating relationship : ${createResult.message}",
              );
              result.setFromResult(
                result: createResult,
                message: 'Error creating relationship',
                logger: logger,
              );
              break;
            } else {
              logger.log(
                '[AcSqlDbSchemaManager] Relationship created successfully.',
              );
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType:
                  AcEnumSqlEntity.relationship.value,
              TblSchemaLogs.acSchemaEntityName:
                  '${acDDRelationship.sourceTable}.${acDDRelationship.sourceColumn}>${acDDRelationship.destinationTable}.${acDDRelationship.destinationColumn}',
              TblSchemaLogs.acSchemaOperation: 'create',
              TblSchemaLogs.acSchemaOperationResult: createResult.status,
              TblSchemaLogs.acSchemaOperationStatement:
                  createRelationshipStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
        }
      }

      if (continueOperation) {
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
  Future<AcResult> createDatabaseStoredProcedures({
    bool skipExistingDrop = false,
  }) async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Creating stored procedures...');
      final storedProcedureList = AcDataDictionary.getStoredProcedures(
        dataDictionaryName: dataDictionaryName,
      );
      for (final acDDStoredProcedure in storedProcedureList.values) {
        if (!skipExistingDrop) {
          final dropStatement =
              AcDDStoredProcedure.getDropStoredProcedureStatement(
                storedProcedureName: acDDStoredProcedure.storedProcedureName,
                databaseType: databaseType,
              );
          logger.log(
            '[AcSqlDbSchemaManager] Executing drop stored procedure statement: $dropStatement',
          );
          final dropResult = await dao!.executeStatement(
            statement: dropStatement,
          );

          await saveSchemaLogEntry({
            TblSchemaLogs.acSchemaEntityType:
                AcEnumSqlEntity.storedProcedure.value,
            TblSchemaLogs.acSchemaEntityName:
                acDDStoredProcedure.storedProcedureName,
            TblSchemaLogs.acSchemaOperation: 'drop',
            TblSchemaLogs.acSchemaOperationResult: dropResult.status,
            TblSchemaLogs.acSchemaOperationStatement: dropStatement,
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                .toUtcIso8601String(),
          });
          if (dropResult.isSuccess()) {
            logger.log(
              '[AcSqlDbSchemaManager] Drop statement executed successfully.',
            );
          } else {
            return result.setFromResult(
              result: dropResult,
              message: 'Error executing drop statement',
              logger: logger,
            );
          }
        }

        final createStatement = acDDStoredProcedure
            .getCreateStoredProcedureStatement(databaseType: databaseType);
        logger.log('[AcSqlDbSchemaManager] Create statement: $createStatement');
        final createResult = await dao!.executeStatement(
          statement: createStatement,
        );
        if (createResult.isSuccess()) {
          logger.log(
            '[AcSqlDbSchemaManager] Stored procedure created successfully.',
          );
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
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
              .toUtcIso8601String(),
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
      if (databaseType == AcEnumSqlDatabaseType.sqlite &&
          dataDictionaryName == AcSMDataDictionary.dataDictionaryName) {
        logger.log("[AcSqlDbSchemaManager] Enabling foreign keys for sqlite");
        final enableForeignKeyResult = await dao!.executeStatement(
          statement: 'PRAGMA foreign_keys = ON;',
        );
        if (enableForeignKeyResult.isFailure()) {
          continueOperation = false;
          logger.log("[AcSqlDbSchemaManager] Error setting foreign keys on");
          result.setFromResult(result: enableForeignKeyResult);
        }
      }
      if (continueOperation) {
        for (final acDDTable
            in AcDataDictionary.getTables(
              dataDictionaryName: dataDictionaryName,
              foreignKeysSorted:
                  dataDictionaryName != AcSMDataDictionary.dataDictionaryName,
            ).values) {
          if (continueOperation) {
            logger.log(
              '[AcSqlDbSchemaManager] Creating table ${acDDTable.tableName}',
            );
            final createStatement = acDDTable.getCreateTableStatement(
              databaseType: databaseType,
            );
            logger.log(
              '[AcSqlDbSchemaManager] Executing create table statement: $createStatement',
            );
            final createResult = await dao!.executeStatement(
              statement: createStatement,
            );
            if (createResult.isSuccess()) {
              logger.log(
                '[AcSqlDbSchemaManager] Create statement executed successfully.',
              );
            } else {
              continueOperation = false;
              result.setFromResult(
                result: createResult,
                message: 'Error creating table ${acDDTable.tableName}',
                logger: logger,
              );
              break;
            }
            if (dataDictionaryName != AcSMDataDictionary.dataDictionaryName) {
              await saveSchemaLogEntry({
                TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
                TblSchemaLogs.acSchemaEntityName: acDDTable.tableName,
                TblSchemaLogs.acSchemaOperation: 'create',
                TblSchemaLogs.acSchemaOperationResult: createResult.status,
                TblSchemaLogs.acSchemaOperationStatement: createStatement,
                TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                    .toUtcIso8601String(),
              });
            }
          }
        }
      }
      if (continueOperation) {
        result.setSuccess(
          message: 'Tables created successfully',
          logger: logger,
        );
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
  Future<AcResult> createDatabaseTriggers({
    bool skipExistingDrop = false,
  }) async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Creating triggers...');
      AcResult timestampTriggers = await createUpdateTimestampTriggers();

      if (timestampTriggers.isSuccess()) {
        for (final acDDTrigger
            in AcDataDictionary.getTriggers(
              dataDictionaryName: dataDictionaryName,
            ).values) {
          logger.log(
            '[AcSqlDbSchemaManager] Creating trigger ${acDDTrigger.triggerName}',
          );
          if (!skipExistingDrop) {
            final dropStatement = AcDDTrigger.getDropTriggerStatement(
              triggerName: acDDTrigger.triggerName,
              tableName: acDDTrigger.tableName,
              databaseType: databaseType,
            );
            logger.log(
              '[AcSqlDbSchemaManager] Executing drop trigger statement: $dropStatement',
            );
            final dropResult = await dao!.executeStatement(
              statement: dropStatement,
            );
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.trigger.value,
              TblSchemaLogs.acSchemaEntityName: acDDTrigger.triggerName,
              TblSchemaLogs.acSchemaOperation: 'drop',
              TblSchemaLogs.acSchemaOperationResult: dropResult.status,
              TblSchemaLogs.acSchemaOperationStatement: dropStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
            });
            if (dropResult.isSuccess()) {
              logger.log(
                '[AcSqlDbSchemaManager] Drop statement executed successfully.',
              );
            } else {
              return result.setFromResult(
                result: dropResult,
                message: 'Error executing drop statement',
                logger: logger,
              );
            }
          }

          final createStatement = acDDTrigger.getCreateTriggerStatement(
            databaseType: databaseType,
          );
          logger.log(
            '[AcSqlDbSchemaManager] Create statement: $createStatement',
          );
          final createResult = await dao!.executeStatement(
            statement: createStatement,
          );
          if (createResult.isSuccess()) {
            logger.log('[AcSqlDbSchemaManager] Trigger created successfully.');
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
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                .toUtcIso8601String(),
          });
        }
        result.setSuccess(
          message: 'Triggers created successfully',
          logger: logger,
        );
      } else {
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
  Future<AcResult> createDatabaseViews({bool skipExistingDrop = false}) async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Creating views...');
      final viewList = AcDataDictionary.getViews(
        dataDictionaryName: dataDictionaryName,
      ); // Get views
      List<AcDDView> errorViews = [];
      for (final acDDView in viewList.values) {
        logger.log('[AcSqlDbSchemaManager] Creating view ${acDDView.viewName}');
        if (!skipExistingDrop) {
          final dropStatement = AcDDView.getDropViewStatement(
            viewName: acDDView.viewName,
            databaseType: databaseType,
          );
          logger.log(
            '[AcSqlDbSchemaManager] Executing drop view statement: $dropStatement',
          );
          final dropResult = await dao!.executeStatement(
            statement: dropStatement,
          );
          await saveSchemaLogEntry({
            TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.view.value,
            TblSchemaLogs.acSchemaEntityName: acDDView.viewName,
            TblSchemaLogs.acSchemaOperation: 'drop',
            TblSchemaLogs.acSchemaOperationResult: dropResult.status,
            TblSchemaLogs.acSchemaOperationStatement: dropStatement,
            TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now(),
          });
          if (dropResult.isSuccess()) {
            logger.log(
              '[AcSqlDbSchemaManager] Drop statement executed successfully.',
            );
          } else {
            return result.setFromResult(
              result: dropResult,
              message: 'Error executing drop statement',
              logger: logger,
            );
          }
        }

        final createStatement = acDDView.getCreateViewStatement(
          databaseType: databaseType,
        );
        logger.log('[AcSqlDbSchemaManager] Create statement: $createStatement');
        final createResult = await dao!.executeStatement(
          statement: createStatement,
        );
        if (createResult.isSuccess()) {
          logger.log('[AcSqlDbSchemaManager] View created successfully.');
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
          TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
              .toUtcIso8601String(),
        });
      }

      if (errorViews.isNotEmpty) {
        logger.log(
          '[AcSqlDbSchemaManager] Retrying creating ${errorViews.length} views with errors',
        );
        int retryCount = 0;
        List<AcDDView> retryViews = [];
        while (errorViews.isNotEmpty && retryCount < 10) {
          retryCount++;
          logger.log(
            "[AcSqlDbSchemaManager] ${errorViews.length} views with errors will be retried in iteration $retryCount",
          );
          for (final acDDView in errorViews) {
            final createStatement = acDDView.getCreateViewStatement(
              databaseType: databaseType,
            );
            logger.log(
              '[AcSqlDbSchemaManager] Retrying creating view for ${acDDView.viewName}, $createStatement',
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
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
          logger.log(
            "[AcSqlDbSchemaManager] After iteration $retryCount, ${retryViews.length} still has errors",
          );
          errorViews = retryViews;
          retryViews = [];
          logger.log(
            "[AcSqlDbSchemaManager] Will try executing ${errorViews.length} in next iteration",
          );
        }
        logger.log(
          "[AcSqlDbSchemaManager] After retrying creating error views, there are ${errorViews.length} with errors",
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
  Future<AcResult> createSchema({bool ignoreViews = false,bool ignoreTriggers = false,bool ignoreStoredProcedures = false,bool ignoreFunctions = false}) async {
    final result = AcResult();
    try {
      logger.log(
        '[AcSqlDbSchemaManager] Creating schema in database for data dictionary $dataDictionaryName...',
      );
      if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        logger.log("[AcSqlDbSchemaManager] Database type is sqlite");
      }
      if (databaseType == AcEnumSqlDatabaseType.postgres) {
        logger.log("[AcSqlDbSchemaManager] Database type is postgres");
      }
      logger.log(
        '[AcSqlDbSchemaManager] Creating tables in database for data dictionary $dataDictionaryName...}',
      );
      final createTablesResult = await createDatabaseTables();
      if (createTablesResult.isSuccess()) {
        logger.log('[AcSqlDbSchemaManager] Tables created successfully');
      } else {
        return result.setFromResult(
          result: createTablesResult,
          message: 'Error creating schema database tables',
          logger: logger,
        );
      }

      if(!ignoreViews){
        final createViewsResult = await createDatabaseViews();
        if (createViewsResult.isSuccess()) {
          logger.log('[AcSqlDbSchemaManager] Views created successfully');
        } else {
          return result.setFromResult(
            result: createViewsResult,
            message: 'Error creating schema database views',
            logger: logger,
          );
        }
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
      if(!ignoreTriggers){
        final createTriggersResult = await createDatabaseTriggers();
        if (createTriggersResult.isSuccess()) {
          logger.log('[AcSqlDbSchemaManager] Triggers created successfully');
        } else {
          return result.setFromResult(
            result: createTriggersResult,
            message: 'Error creating schema database triggers',
            logger: logger,
          );
        }
      }

      if(!ignoreStoredProcedures){
        final createStoredProceduresResult = await createDatabaseStoredProcedures();
        if (createStoredProceduresResult.isSuccess()) {
          logger.log(
            '[AcSqlDbSchemaManager] Stored procedures created successfully',
          );
        } else {
          return result.setFromResult(
            result: createStoredProceduresResult,
            message: 'Error creating schema database stored procedures',
            logger: logger,
          );
        }
      }

      if(!ignoreFunctions){
        final createFunctionsResult = await createDatabaseFunctions();
        if (createFunctionsResult.isSuccess()) {
          logger.log('[AcSqlDbSchemaManager] Functions created successfully');
        } else {
          return result.setFromResult(
            result: createFunctionsResult,
            message: 'Error creating schema database functions',
            logger: logger,
          );
        }
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
      if (columnName.isNotEmpty) {
        // Optional: same foreign key enabling block as in your table creation
        if (databaseType == AcEnumSqlDatabaseType.sqlite &&
            dataDictionaryName == AcSMDataDictionary.dataDictionaryName) {
          logger.log(
            "[AcSqlDbSchemaManager] Enabling foreign keys for sqlite (triggers phase)",
          );
          final enableForeignKeyResult = await dao!.executeStatement(
            statement: 'PRAGMA foreign_keys = ON;',
          );
          if (enableForeignKeyResult.isFailure()) {
            continueOperation = false;
            logger.log("[AcSqlDbSchemaManager] Error setting foreign keys on");
            result.setFromResult(result: enableForeignKeyResult);
          }
        }

        if (continueOperation) {
          // Get only tables that have updated_at column
          final tablesWithUpdatedAt =
              AcDataDictionary.getTables(
                dataDictionaryName: dataDictionaryName,
                foreignKeysSorted:
                    dataDictionaryName != AcSMDataDictionary.dataDictionaryName,
              ).values.toList();

          for (final acDDTable in tablesWithUpdatedAt) {
            if (!continueOperation) break;

            final tableName = acDDTable.tableName;
            final triggerName = 'ac_tr_${tableName}_set_upd_ts';

            logger.log(
              '[AcSqlDbSchemaManager] Creating update trigger for $tableName → $triggerName',
            );

            final createTriggerStmt = _generateUpdateAtTriggerSql(
              tableName: tableName,
              columnName: columnName,
              triggerName: triggerName,
              databaseType: databaseType,
            );

            logger.log([
              '[AcSqlDbSchemaManager] Executing trigger statements :',
              createTriggerStmt,
            ]);
            for (var stmt in createTriggerStmt) {
              final triggerResult = await dao!.executeStatement(
                statement: stmt,
              );
              if (triggerResult.isSuccess()) {
                logger.log(
                  '[AcSqlDbSchemaManager] Trigger $triggerName created successfully.',
                );
              } else {
                continueOperation = false;
                result.setFromResult(
                  result: triggerResult,
                  message: 'Error creating trigger for table $tableName',
                  logger: logger,
                );
                break;
              }
              if (dataDictionaryName != AcSMDataDictionary.dataDictionaryName) {
                await saveSchemaLogEntry({
                  TblSchemaLogs.acSchemaEntityType:
                      AcEnumSqlEntity.trigger.value,
                  TblSchemaLogs.acSchemaEntityName: triggerName,
                  TblSchemaLogs.acSchemaOperation: 'create',
                  TblSchemaLogs.acSchemaOperationResult: triggerResult.status,
                  TblSchemaLogs.acSchemaOperationStatement: stmt,
                  TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                      .toUtcIso8601String(),
                });
              }
            }

            // Optional: log schema change (same as your table creation)
          }
        }

        if (continueOperation) {
          result.setSuccess(
            message: 'All update timestamp triggers created successfully',
            logger: logger,
          );
        }
      } else {
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }

    return result;
  }

  Future<AcResult> dropDatabaseFunctions() async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Dropping functions...');
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        // MySql Implementation Pending
      } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> dropDatabaseStoredProcedures() async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Dropping stored procedures...');
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        // MySql Implementation Pending
      } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        result.setSuccess();
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> dropDatabaseTables() async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Dropping tables...');
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        // MySql Implementation Pending
      } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        AcSqlDaoResult selectResult = await dao!.getRows(
          statement:
              "SELECT name,'DROP TABLE IF EXISTS \"' || name || '\";' as drop_statement FROM sqlite_master WHERE type = 'table';",
        );
        if (selectResult.isSuccess()) {
          List<Map<String, dynamic>> rows = selectResult.rows;
          for (var row in rows) {
            String dropStatement = row.getString('drop_statement');
            var dropResult = await dao!.executeStatement(
              statement: dropStatement,
            );
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
              TblSchemaLogs.acSchemaEntityName: row.getString('name'),
              TblSchemaLogs.acSchemaOperation: 'drop',
              TblSchemaLogs.acSchemaOperationResult: dropResult.status,
              TblSchemaLogs.acSchemaOperationStatement: dropStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
        }
        result.setFromResult(result: selectResult);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> dropDatabaseTriggers() async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Dropping triggers...');
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        // MySql Implementation Pending
      } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        AcSqlDaoResult selectResult = await dao!.getRows(
          statement:
              "SELECT name,'DROP TRIGGER IF EXISTS \"' || name || '\";' as drop_statement FROM sqlite_master WHERE type = 'trigger';",
        );
        if (selectResult.isSuccess()) {
          List<Map<String, dynamic>> rows = selectResult.rows;
          for (var row in rows) {
            String dropStatement = row.getString('drop_statement');
            var dropResult = await dao!.executeStatement(
              statement: dropStatement,
            );
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.trigger.value,
              TblSchemaLogs.acSchemaEntityName: row.getString('name'),
              TblSchemaLogs.acSchemaOperation: 'drop',
              TblSchemaLogs.acSchemaOperationResult: dropResult.status,
              TblSchemaLogs.acSchemaOperationStatement: dropStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
        }
        result.setFromResult(result: selectResult);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> dropDatabaseViews() async {
    final result = AcResult();
    try {
      logger.log('[AcSqlDbSchemaManager] Dropping triggers...');
      if (databaseType == AcEnumSqlDatabaseType.mysql) {
        // MySql Implementation Pending
      } else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
        AcSqlDaoResult selectResult = await dao!.getRows(
          statement:
              "SELECT name,'DROP VIEW IF EXISTS \"' || name || '\";' as drop_statement FROM sqlite_master WHERE type = 'view';",
        );
        if (selectResult.isSuccess()) {
          List<Map<String, dynamic>> rows = selectResult.rows;
          for (var row in rows) {
            String dropStatement = row.getString('drop_statement');
            var dropResult = await dao!.executeStatement(
              statement: dropStatement,
            );
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.view.value,
              TblSchemaLogs.acSchemaEntityName: row.getString('name'),
              TblSchemaLogs.acSchemaOperation: 'drop',
              TblSchemaLogs.acSchemaOperationResult: dropResult.status,
              TblSchemaLogs.acSchemaOperationStatement: dropStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
        }
        result.setFromResult(result: selectResult);
      }
    } on Exception catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
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
              AcSqlSchemaTableDifference tableDifference =
                  AcSqlSchemaTableDifference(
                    tableName: tableRow[AcDDTable.keyTableName],
                  );
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
                    foundColumns.add(columnRow[AcDDTableColumn.keyColumnName]);
                  } else {
                    tableDifference.missingColumnsInDataDictionary.add(
                      columnRow[AcDDTableColumn.keyColumnName],
                    );
                  }
                }
                tableDifference.missingColumnsInDatabase.addAll(
                  currentDataDictionaryColumns.where(
                    (element) => !foundColumns.contains(element),
                  ),
                );
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
              if (tableDifference.missingColumnsInDataDictionary.isNotEmpty ||
                  tableDifference.missingColumnsInDatabase.isNotEmpty) {
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
        schemaDifference.missingTablesInDatabase.addAll(
          currentDataDictionaryTables.where(
            (element) => !foundTables.contains(element),
          ),
        );
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
        "[AcSqlDbSchemaManager] Initializing database for data dictionary $dataDictionaryName...",
      );
      final checkResult = await dao!.checkDatabaseExist();
      if (checkResult.isSuccess()) {
        bool updateDataDictionaryVersion = false;
          if (checkResult.value == false) {
            logger.log("[AcSqlDbSchemaManager] Creating database...");
            final createDbResult = await dao!.createDatabase();
            if (createDbResult.isSuccess()) {
              logger.log(
                "[AcSqlDbSchemaManager] Database created successfully",
              );
              final schemaResult = await initSchemaDataDictionary();
              if (schemaResult.isSuccess()) {
                final createSchemaResult = await createSchema();
                if (createSchemaResult.isSuccess()) {
                  updateDataDictionaryVersion = true;
                  result.setSuccess(
                    message: 'Schema created successfully',
                    logger: logger,
                  );
                  String createdOnTime = DateTime.now()
                      .toUtcIso8601String();
                  var createdOnResponse = await saveSchemaDetail({
                    TblSchemaDetails.acSchemaDetailKey:
                    SchemaDetails.keyCreatedOn,
                    TblSchemaDetails.acSchemaDetailStringValue: createdOnTime,
                  });
                  if (createdOnResponse.isFailure()) {
                    return result.setFromResult(
                      result: createdOnResponse,
                      message: 'error saving created on schema detail',
                    );
                  }

                  var createdSchemaOnResponse = await saveSchemaDetail({
                    TblSchemaDetails.acSchemaDetailKey:
                    "${SchemaDetails.keyCreatedOn}[$dataDictionaryName]",
                    TblSchemaDetails.acSchemaDetailStringValue: createdOnTime,
                  });
                  if (createdSchemaOnResponse.isFailure()) {
                    return result.setFromResult(
                      result: createdSchemaOnResponse,
                      message:
                      'error saving created on schema data dictionary detail',
                    );
                  }
                } else {
                  return result.setFromResult(
                    result: createSchemaResult,
                    message:
                    "Error creating database schema from data dictionary",
                    logger: logger,
                  );
                }
              }
              else {
                return result.setFromResult(
                  result: schemaResult,
                  message: "Error initializing schema",
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
            final schemaResult = await initSchemaDataDictionary();
            if (schemaResult.isSuccess()) {
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
                    String updatedOnTime = DateTime.now()
                        .toUtcIso8601String();
                    var updatedOnResponse = await saveSchemaDetail({
                      TblSchemaDetails.acSchemaDetailKey:
                      SchemaDetails.keyLastUpdatedOn,
                      TblSchemaDetails.acSchemaDetailStringValue: updatedOnTime,
                    });
                    if (updatedOnResponse.isFailure()) {
                      return result.setFromResult(
                        result: updatedOnResponse,
                        message: 'error saving updated on schema detail',
                      );
                    }

                    var updatedOnDataDictionaryResponse = await saveSchemaDetail({
                      TblSchemaDetails.acSchemaDetailKey:
                      "${SchemaDetails.keyLastUpdatedOn}[$dataDictionaryName]",
                      TblSchemaDetails.acSchemaDetailStringValue: updatedOnTime,
                    });
                    if (updatedOnDataDictionaryResponse.isFailure()) {
                      return result.setFromResult(
                        result: updatedOnDataDictionaryResponse,
                        message: 'error saving updated on schema detail',
                      );
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
            else {
              return result.setFromResult(
                result: schemaResult,
                message: "Error initializing schema",
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
              result.setFromResult(
                result: versionLogResponse,
                message: 'error saving version schema detail',
              );
            }
          }
      }
      else {
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

  Future<AcResult> initMultipleDataDictionaryDatabase({required List<String> dataDictionaryNames,Future<void> Function({required Map<String,double> oldSchemaVersions, required AcBaseSqlDao dao})? afterTablesUpdateCallback}) async {
    final result = AcResult();
    try {
      logger.log(
        "[AcSqlDbSchemaManager] Initializing database for multiple data dictionaries...",
      );
      Map<String, AcSqlDbSchemaManager> schemaManagers = {};
      List<String> schemaUpdateVersions = List.empty(growable: true);

      List<String> schemaMissing = List.empty(growable: true);
      List<String> schemaHasUpdates = List.empty(growable: true);
      List<String> schemaUpToDate = List.empty(growable: true);

      Future<AcResult> createDataDictionarySchema(String ddName, [bool isExisting = false]) async {
        AcResult result = AcResult();
        logger.log(
          "[AcSqlDbSchemaManager] Creating schema for data dictionary $ddName...",
        );
        if(!isExisting){
          final createSchemaResult = await schemaManagers[ddName]!.createSchema(ignoreViews: true,ignoreFunctions: true,ignoreStoredProcedures: true,ignoreTriggers: true);
          if (createSchemaResult.isFailure()) {
            return result.setFromResult(
              result: createSchemaResult,
              logger: logger,
            );
          }
        }
        else if(isExisting){
          final createSchemaResult = await schemaManagers[ddName]!.updateSchema(ignoreViews: true,ignoreFunctions: true,ignoreStoredProcedures: true,ignoreTriggers: true);
          if (createSchemaResult.isFailure()) {
            return result.setFromResult(
              result: createSchemaResult,
              logger: logger,
            );
          }
        }

        logger.log(
          "[AcSqlDbSchemaManager] Updating Created on timestamp for data dictionary $ddName...",
        );

        var createdOnResponse = await saveSchemaDetail({
          TblSchemaDetails.acSchemaDetailKey:
              "${SchemaDetails.keyCreatedOn}[$ddName]",
          TblSchemaDetails.acSchemaDetailStringValue: DateTime.now()
              .toUtcIso8601String(),
        });
        if (createdOnResponse.isFailure()) {
          return result.setFromResult(
            result: createdOnResponse,
            logger: logger,
            message: 'error saving created on schema detail',
          );
        }
        schemaUpdateVersions.add(ddName);
        result.setSuccess();
        return result;
      }

      Future<AcResult> createDataDictionarySchemaEntities() async {
        AcResult result = AcResult();
        for (var ddName in schemaManagers.keys) {
          logger.log(
            "[AcSqlDbSchemaManager] Creating views from data dictionary schema $ddName...",
          );
          var createViewsResult = await schemaManagers[ddName]!
              .createDatabaseViews(skipExistingDrop: true);
          if (createViewsResult.isFailure()) {
            return result.setFromResult(result: createViewsResult,logger: logger);
          }

          logger.log(
            "[AcSqlDbSchemaManager] Creating triggers from data dictionary schema $ddName...",
          );
          var createTriggersResult = await schemaManagers[ddName]!
              .createDatabaseTriggers(skipExistingDrop: true);
          if (createTriggersResult.isFailure()) {
            return result.setFromResult(result: createTriggersResult,logger: logger);
          }

          logger.log(
            "[AcSqlDbSchemaManager] Creating stored procedures from data dictionary schema $ddName...",
          );
          var createStoredProceduresResult = await schemaManagers[ddName]!
              .createDatabaseStoredProcedures(skipExistingDrop: true);
          if (createStoredProceduresResult.isFailure()) {
            return result.setFromResult(result: createStoredProceduresResult,logger: logger);
          }

          logger.log(
            "[AcSqlDbSchemaManager] Creating functions from data dictionary schema $ddName...",
          );
          var createFunctionsResult = await schemaManagers[ddName]!
              .createDatabaseFunctions(skipExistingDrop: true);
          if (createFunctionsResult.isFailure()) {
            return result.setFromResult(result: createFunctionsResult,logger: logger);
          }
        }
        result.setSuccess();
        return result;
      }

      for (var ddName in dataDictionaryNames) {
        if (AcDataDictionary.dataDictionaries.containsKey(ddName)) {
          logger.log(
            "[AcSqlDbSchemaManager] $ddName data dictionary for schema changes...",
          );
          schemaManagers[ddName] = AcSqlDbSchemaManager(
            dataDictionaryName: ddName,dao: dao
          );
          schemaManagers[ddName]!.logger = logger;
        } else {
          logger.log(
            "[AcSqlDbSchemaManager] $ddName data dictionary is not registered so excluding from  schema changes...",
          );
        }
      }

      logger.log("[AcSqlDbSchemaManager] Checking database exist");

      final checkResult = await dao!.checkDatabaseExist();
      if (checkResult.isSuccess()) {
        if (checkResult.value == false) {
          logger.log("[AcSqlDbSchemaManager] Creating database...");
          final createDbResult = await dao!.createDatabase();
          if (createDbResult.isSuccess()) {
            logger.log(
              "[AcSqlDbSchemaManager] Database Exists : ${checkResult.value}",
            );

            logger.log(
              "[AcSqlDbSchemaManager] Initializing schema data dictionary",
            );
            final schemaResult = await initSchemaDataDictionary();
            if (schemaResult.isFailure()) {
              return result.setFromResult(result: schemaResult, logger: logger);
            }

            for (var ddName in schemaManagers.keys) {
              schemaMissing.add(ddName);
              var createSchemaResult = await createDataDictionarySchema(ddName);
              if (createSchemaResult.isFailure()) {
                return result.setFromResult(result: createSchemaResult);
              }
            }

            var createEntitiesResponse =
                await createDataDictionarySchemaEntities();
            if (createEntitiesResponse.isFailure()) {
              return result.setFromResult(
                result: createEntitiesResponse,
                message: 'error creating schema entities',
              );
            }

            logger.log(
              "[AcSqlDbSchemaManager] Saving database created on details in schema",
            );
            var createdOnResponse = await saveSchemaDetail({
              TblSchemaDetails.acSchemaDetailKey: SchemaDetails.keyCreatedOn,
              TblSchemaDetails.acSchemaDetailStringValue: DateTime.now()
                  .toUtcIso8601String(),
            });
            if (createdOnResponse.isFailure()) {
              return result.setFromResult(
                result: createdOnResponse,
                message: 'error saving created on schema detail',
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
          logger.log(
            "[AcSqlDbSchemaManager] Database alrerady exist",
          );
          logger.log(
            "[AcSqlDbSchemaManager] Initializing schema data dictionary",
          );
          final schemaResult = await initSchemaDataDictionary();
          if (schemaResult.isFailure()) {
            return result.setFromResult(result: schemaResult, logger: logger);
          }

          Map<String,double> oldSchemaVersions = {};
          List<String> keys = List.empty(growable: true);
          for(var key in schemaManagers.keys){
            keys.add("${SchemaDetails.keyDataDictionaryVersion}[$key]");
          }

          logger.log(
            "[AcSqlDbSchemaManager] Getting current versions of data dictionary schemas",
          );
          final versionResult = await dao!.getRows(
            statement: acSqlDDTableSchemaDetails.getSelectStatement(),
            condition: "${TblSchemaDetails.acSchemaDetailKey} IN (@keys)",
            parameters: {
              "@keys": keys,
            },
            mode: AcEnumDDSelectMode.first, //important
          );

          if (versionResult.isSuccess()) {
            if (versionResult.rows.isNotEmpty) {
              for (var row in versionResult.rows) {
                final databaseVersion = versionResult.rows.first.getDouble(
                  TblSchemaDetails.acSchemaDetailNumericValue,
                );
                String ddName = row.getString(TblSchemaDetails.acSchemaDetailKey).substring(SchemaDetails.keyDataDictionaryVersion.length+1);
                ddName = ddName.substring(0, ddName.length - 1);
                logger.log(
                  "[AcSqlDbSchemaManager] Found version $databaseVersion of data dictionary $ddName. Latest version is ${schemaManagers[ddName]!.acDataDictionary.version}",
                );
                if (schemaManagers[ddName]!.acDataDictionary.version > databaseVersion) {
                  oldSchemaVersions[ddName] = databaseVersion;
                  schemaHasUpdates.add(ddName);
                  logger.log(
                    "[AcSqlDbSchemaManager] Added data dictionary $ddName to update list",
                  );
                } else {
                  logger.log(
                    "[AcSqlDbSchemaManager] Added data dictionary $ddName to no change list",
                  );
                  schemaUpToDate.add(ddName);
                }
              }
            }
          } else {
            return result.setFromResult(
              result: versionResult,
              message: 'Error checking schema version',
              logger: logger,
            );
          }

          for (var ddName in schemaManagers.keys) {
            if (!schemaHasUpdates.contains(ddName) &&
                !schemaUpToDate.contains(ddName)) {
              logger.log(
                "[AcSqlDbSchemaManager] Added data dictionary $ddName to create list",
              );
              schemaMissing.add(ddName);
            }
          }

          if (schemaMissing.isNotEmpty || schemaHasUpdates.isNotEmpty) {
            logger.log(
              "[AcSqlDbSchemaManager] Removing all database functions",
            );
            var dropFunctionsResult = await dropDatabaseFunctions();
            if (dropFunctionsResult.isFailure()) {
              return result.setFromResult(
                result: dropFunctionsResult,
                logger: logger,
              );
            }

            logger.log(
              "[AcSqlDbSchemaManager] Removing all database stored procedures",
            );
            var dropStoredProceduresResult =
                await dropDatabaseStoredProcedures();
            if (dropStoredProceduresResult.isFailure()) {
              return result.setFromResult(
                result: dropStoredProceduresResult,
                logger: logger,
              );
            }

            logger.log("[AcSqlDbSchemaManager] Removing all database triggers");
            var dropTriggersResult = await dropDatabaseTriggers();
            if (dropTriggersResult.isFailure()) {
              return result.setFromResult(
                result: dropTriggersResult,
                logger: logger,
              );
            }

            logger.log("[AcSqlDbSchemaManager] Removing all database views");
            var dropViewsResult = await dropDatabaseViews();
            if (dropViewsResult.isFailure()) {
              return result.setFromResult(
                result: dropViewsResult,
                logger: logger,
              );
            }

            logger.log(
              "[AcSqlDbSchemaManager] Creating missing data dictionary schemas...",
            );
            for (var ddName in schemaMissing) {
              var createSchemaResult = await createDataDictionarySchema(ddName,true);
              if (createSchemaResult.isFailure()) {
                return result.setFromResult(result: createSchemaResult);
              }
            }

            logger.log(
              "[AcSqlDbSchemaManager] Updating changed data dictionary schemas...",
            );
            for (var ddName in schemaHasUpdates) {
              final updateSchemaResult =
                  await schemaManagers[ddName]!.updateDatabaseDifferences();
              if (updateSchemaResult.isSuccess()) {
                schemaUpdateVersions.add(ddName);
                var versionUpdatedOnResponse = await saveSchemaDetail({
                  TblSchemaDetails.acSchemaDetailKey:
                      "${SchemaDetails.keyLastUpdatedOn}[$ddName]",
                  TblSchemaDetails.acSchemaDetailStringValue: DateTime.now()
                      .toUtcIso8601String(),
                });
                if (versionUpdatedOnResponse.isFailure()) {
                  return result.setFromResult(
                    result: versionUpdatedOnResponse,
                    message: 'error saving version schema detail',
                    logger: logger,
                  );
                }
              } else {
                return result.setFromResult(
                  result: updateSchemaResult,
                  message:
                      "Error updating database schema from data dictionary",
                  logger: logger,
                );
              }
            }

            if(afterTablesUpdateCallback != null){
              await afterTablesUpdateCallback(oldSchemaVersions: oldSchemaVersions,dao:dao!);
            }

            logger.log(
              "[AcSqlDbSchemaManager] Creating data dictionary entities...",
            );
            var createEntitiesResponse = await createDataDictionarySchemaEntities();
            if (createEntitiesResponse.isFailure()) {
              return result.setFromResult(
                result: createEntitiesResponse,
                message: 'error creating schema entities',
                logger: logger,
              );
            }
          }
        }
        if (schemaUpdateVersions.isNotEmpty) {
          logger.log(
            "[AcSqlDbSchemaManager] Updating versions of data dictionary schemas in schema details...",
          );
          for (var ddName in schemaUpdateVersions) {
            logger.log(
              "[AcSqlDbSchemaManager] Updating version of $ddName to ${schemaManagers[ddName]!.acDataDictionary.version}",
            );
            var versionLogResponse = await saveSchemaDetail({
              TblSchemaDetails.acSchemaDetailKey:
                  "${SchemaDetails.keyDataDictionaryVersion}[$ddName]",
              TblSchemaDetails.acSchemaDetailNumericValue:
                  schemaManagers[ddName]!.acDataDictionary.version,
            });
            if (versionLogResponse.isSuccess()) {
            } else {
              return result.setFromResult(
                result: versionLogResponse,
                message: 'error saving version schema detail',
                logger: logger,
              );
            }
          }

          logger.log(
            "[AcSqlDbSchemaManager] Updating last updated details of data dictionary in schema details...",
          );
          var versionUpdatedOnResponse = await saveSchemaDetail({
            TblSchemaDetails.acSchemaDetailKey: SchemaDetails.keyLastUpdatedOn,
            TblSchemaDetails.acSchemaDetailStringValue: DateTime.now()
                .toUtcIso8601String(),
          });
          if (versionUpdatedOnResponse.isFailure()) {
            return result.setFromResult(
              result: versionUpdatedOnResponse,
              message: 'error saving version schema detail',
              logger: logger,
            );
          }
        }
        logger.log(
          "[AcSqlDbSchemaManager] initMultipleDataDictionaryDatabase completed with status success.",
        );
        result.setSuccess(
          value: {
            "created": schemaMissing,
            "updated": schemaHasUpdates,
            "not_change": schemaUpToDate,
          },
        );
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
      if (skipSchema) {
        result.setSuccess();
        return result;
      } else {
        logger.log(
          "[AcSqlDbSchemaManager] Registering schema data dictionary...",
        );
        AcDataDictionary.registerDataDictionary(
          jsonData: AcSMDataDictionary.dataDictionary,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        acSqlDDTableSchemaDetails = AcSqlDbTable(
          tableName: AcSchemaManagerTables.schemaDetails,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
          dao: dao,
        );
        acSqlDDTableSchemaLogs = AcSqlDbTable(
          tableName: AcSchemaManagerTables.schemaLogs,
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
          dao: dao,
        );
        final acSchemaManager = AcSqlDbSchemaManager(
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
          dao: dao,
        );
        acSchemaManager.dao = dao;
        acSchemaManager.databaseType = databaseType;
        acSchemaManager.skipSchema = true;
        acSchemaManager.logger = logger;
        acSchemaManager.useDataDictionary(
          dataDictionaryName: AcSMDataDictionary.dataDictionaryName,
        );
        AcSqlDaoResult getTablesResult = await dao!.getDatabaseTables();
        if(getTablesResult.isSuccess()){
          bool foundSchemaTables = false;
          for(var row in getTablesResult.rows){
            if(row[AcDDTable.keyTableName] == AcSchemaManagerTables.schemaDetails){
              foundSchemaTables = true;
              break;
            }
          }
          if(!foundSchemaTables){
            var createResult = await acSchemaManager.createSchema();
            if(createResult.isSuccess()){
              String createdOnTime = DateTime.now()
                  .toUtcIso8601String();
              var createdOnResponse = await saveSchemaDetail({
                TblSchemaDetails.acSchemaDetailKey:
                SchemaDetails.keyCreatedOn,
                TblSchemaDetails.acSchemaDetailStringValue: createdOnTime,
              });
              if (createdOnResponse.isFailure()) {
                return result.setFromResult(
                  result: createdOnResponse,
                  message: 'error saving created on schema detail',
                );
              }

              var createdSchemaOnResponse = await saveSchemaDetail({
                TblSchemaDetails.acSchemaDetailKey:
                "${SchemaDetails.keyCreatedOn}[$dataDictionaryName]",
                TblSchemaDetails.acSchemaDetailStringValue: createdOnTime,
              });
              if (createdSchemaOnResponse.isFailure()) {
                return result.setFromResult(
                  result: createdSchemaOnResponse,
                  message:
                  'error saving created on schema data dictionary detail',
                );
              }

              result.setSuccess();
            }
            else{
              return createResult;
            }
          }
          else{
            var updateResult = await acSchemaManager.checkSchemaUpdateAvailableFromVersion();
            if(updateResult.isSuccess()){
              if(updateResult.value){
                var updateSchemaResult =  await acSchemaManager.updateDatabaseDifferences();
                if(updateSchemaResult.isSuccess()){
                 String updatedOnTime = DateTime.now()
                     .toUtcIso8601String();
                 var updatedOnResponse = await saveSchemaDetail({
                   TblSchemaDetails.acSchemaDetailKey:
                   SchemaDetails.keyLastUpdatedOn,
                   TblSchemaDetails.acSchemaDetailStringValue: updatedOnTime,
                 });
                 if (updatedOnResponse.isFailure()) {
                   return result.setFromResult(
                     result: updatedOnResponse,
                     message: 'error saving updated on schema detail',
                   );
                 }

                 var updatedOnDataDictionaryResponse = await saveSchemaDetail({
                   TblSchemaDetails.acSchemaDetailKey:
                   "${SchemaDetails.keyLastUpdatedOn}[${AcSMDataDictionary.dataDictionaryName}]",
                   TblSchemaDetails.acSchemaDetailStringValue: updatedOnTime,
                 });
                 if (updatedOnDataDictionaryResponse.isFailure()) {
                   return result.setFromResult(
                     result: updatedOnDataDictionaryResponse,
                     message: 'error saving updated on schema detail',
                   );
                 }

                 result.setSuccess();
               }
               else{
                 return updateSchemaResult;
               }
              }
              else{
                result.setSuccess();
              }
            }
            else{
              return updateResult;
            }
          }
        }
        else{
          return result.setFromResult(
            result: getTablesResult,
            message: "Error getting database tables",
            logger: logger,
          );
        }
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
    AcSqlDaoResult result = await acSqlDDTableSchemaLogs.saveRow(row: row);
    if (result.isFailure()) {}
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
    AcSqlDaoResult result = await acSqlDDTableSchemaDetails.saveRow(row: row);
    if (result.isFailure()) {}
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
        AcSqlSchemaDifference differences =
            differenceResult.value; // Cast the value
        List<String> dropColumnStatements = [];
        List<String> dropTableStatements = [];
        if (differences.missingTablesInDatabase.isNotEmpty) {
          for (final tableName in differences.missingTablesInDatabase) {
            logger.log("[AcSqlDbSchemaManager] Creating table $tableName");
            final acDDTable = AcDDTable.getInstance(
              tableName: tableName,
              dataDictionaryName: dataDictionaryName,
            );
            final createStatement = acDDTable.getCreateTableStatement(
              databaseType: databaseType,
            );
            logger.log([
              "[AcSqlDbSchemaManager] Executing create table statement...",
              createStatement,
            ]);
            final createResult = await dao!.executeStatement(
              statement: createStatement,
            );
            if (createResult.isSuccess()) {
              logger.log(
                "[AcSqlDbSchemaManager] Create statement executed successfully",
              );
            } else {
              return result.setFromResult(result: createResult, logger: logger);
            }
            await saveSchemaLogEntry({
              TblSchemaLogs.acSchemaEntityType: AcEnumSqlEntity.table.value,
              TblSchemaLogs.acSchemaEntityName: tableName,
              TblSchemaLogs.acSchemaOperation: 'create',
              TblSchemaLogs.acSchemaOperationResult: createResult.status,
              TblSchemaLogs.acSchemaOperationStatement: createStatement,
              TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                  .toUtcIso8601String(),
            });
          }
        }

        if (differences.modifiedTables.isNotEmpty) {
          for (final modificationDetails in differences.modifiedTables) {
            final tableName = modificationDetails.tableName;
            if (modificationDetails.missingColumnsInDatabase.isNotEmpty) {
              for (final columnName
                  in modificationDetails.missingColumnsInDatabase) {
                logger.log(
                  "[AcSqlDbSchemaManager] Adding table column $columnName",
                );
                final acDDTableColumn = AcDDTableColumn.getInstance(
                  tableName: tableName,
                  columnName: columnName,
                  dataDictionaryName: dataDictionaryName,
                );
                final addStatement = acDDTableColumn.getAddColumnStatement(
                  tableName: tableName,
                  databaseType: databaseType,
                );
                logger.log([
                  "[AcSqlDbSchemaManager] Executing add table column statement...",
                  addStatement,
                ]);
                final createResult = await dao!.executeStatement(
                  statement: addStatement,
                );
                if (createResult.isSuccess()) {
                  logger.log(
                    "[AcSqlDbSchemaManager] Add statement executed successfully",
                  );
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
                  TblSchemaLogs.acSchemaOperationTimestamp: DateTime.now()
                      .toUtcIso8601String(),
                });
              }
            }
            if (modificationDetails.missingColumnsInDataDictionary.isNotEmpty) {
              for (final columnName
                  in modificationDetails.missingColumnsInDataDictionary) {
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
  Future<AcResult> updateSchema({bool ignoreViews = false,bool ignoreTriggers = false,bool ignoreStoredProcedures = false,bool ignoreFunctions = false}) async {
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
    if (continueOperation && !ignoreViews) {
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
    if (continueOperation && !ignoreTriggers) {
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
    if (continueOperation && !ignoreStoredProcedures) {
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
    if (continueOperation && !ignoreFunctions) {
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
