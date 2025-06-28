import 'dart:core';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';

/* AcDoc({
  "summary": "A manager and in-memory representation of a database schema.",
  "description": "The AcDataDictionary class provides a comprehensive toolkit for managing, querying, and interacting with database schema definitions loaded from JSON. It acts as a central repository for metadata about tables, columns, relationships, views, triggers, and more. All methods for accessing schema data are static, providing a global access point to registered dictionaries.",
  "example": "// 1. Register a data dictionary from a JSON string during app startup.\nfinal jsonString = fetchMySchemaJson();\nAcDataDictionary.registerDataDictionaryJsonString(jsonString: jsonString, dataDictionaryName: 'my_app_db');\n\n// 2. Later, retrieve a specific table's details.\nfinal userTable = AcDataDictionary.getTable(tableName: 'users', dataDictionaryName: 'my_app_db');\n\n// 3. Get all relationships for a specific table.\nfinal userRelationships = AcDataDictionary.getTableRelationships(tableName: 'users', dataDictionaryName: 'my_app_db');"
}) */
@AcReflectable()
class AcDataDictionary {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDataDictionaries = "data_dictionaries";
  static const String keyFunctions = "functions";
  static const String keyRelationships = "relationships";
  static const String keyStoredProcedures = "stored_procedures";
  static const String keyTables = "tables";
  static const String keyTriggers = "triggers";
  static const String keyVersion = "version";
  static const String keyViews = "views";

  @AcBindJsonProperty(key: keyDataDictionaries)
  static Map<String, dynamic> dataDictionaries = {};

  Map<String, dynamic> functions = {};
  Map<String, dynamic> relationships = {};

  @AcBindJsonProperty(key: keyStoredProcedures)
  Map<String, dynamic> storedProcedures = {};

  Map<String, dynamic> tables = {};
  Map<String, dynamic> triggers = {};
  int version = 0;
  Map<String, dynamic> views = {};

  /* AcDoc({
    "summary": "Creates a data dictionary instance from a JSON map.",
    "description": "This is a factory constructor that initializes a new AcDataDictionary instance and populates its properties from the provided JSON data map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing a single data dictionary."}
    ],
    "returns": "A new, populated AcDataDictionary instance.",
    "returns_type": "AcDataDictionary"
  }) */
  static AcDataDictionary instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    return AcDataDictionary().fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Creates a data dictionary instance from a JSON string.",
    "description": "This factory constructor parses a JSON string into a map and then creates a new, populated AcDataDictionary instance.",
    "params": [
      {"name": "jsonString", "description": "The JSON string representing a single data dictionary."}
    ],
    "returns": "A new, populated AcDataDictionary instance.",
    "returns_type": "AcDataDictionary"
  }) */
  static AcDataDictionary fromJsonString({required String jsonString}) {
    final jsonData = jsonString.toJsonMap();
    return AcDataDictionary().fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Retrieves all functions from a specified data dictionary.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A map of function names to their corresponding AcDDFunction objects.",
    "returns_type": "Map<String, AcDDFunction>"
  }) */
  static Map<String, AcDDFunction> getFunctions({
    String dataDictionaryName = "default",
  }) {
    final result = <String, AcDDFunction>{};
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.functions.forEach((functionName, functionData) {
      result[functionName] = AcDDFunction.instanceFromJson(
        jsonData: functionData,
      );
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a single function by its name.",
    "params": [
      {"name": "functionName", "description": "The name of the function to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDFunction object if found, otherwise null.",
    "returns_type": "AcDDFunction?"
  }) */
  static AcDDFunction? getFunction({
    required String functionName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.functions.containsKey(functionName)) {
      return AcDDFunction.instanceFromJson(
        jsonData: acDataDictionary.functions[functionName],
      );
    }
    return null;
  }

  /* AcDoc({
    "summary": "Gets an instance of a registered data dictionary.",
    "description": "Retrieves the specified data dictionary from the static registry and returns it as a populated AcDataDictionary object. If the dictionary is not found, an empty instance is returned.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to retrieve. Defaults to 'default'."}
    ],
    "returns": "An AcDataDictionary instance populated with the schema data.",
    "returns_type": "AcDataDictionary"
  }) */
  static AcDataDictionary getInstance({String dataDictionaryName = "default"}) {
    final instance = AcDataDictionary();
    if (dataDictionaries.containsKey(dataDictionaryName)) {
      instance.fromJson(jsonData: dataDictionaries[dataDictionaryName]);
    }
    return instance;
  }

  /* AcDoc({
    "summary": "Retrieves all relationships from a data dictionary.",
    "description": "Iterates through the deeply nested relationship structure and returns a flat list of all defined relationships.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A list of all AcDDRelationship objects defined in the schema.",
    "returns_type": "List<AcDDRelationship>"
  }) */
  static List<AcDDRelationship> getRelationships({
    String dataDictionaryName = "default",
  }) {
    final result = <AcDDRelationship>[];
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.relationships.forEach((_, destinationTableDetails) {
      destinationTableDetails.forEach((_, destinationColumnDetails) {
        destinationColumnDetails.forEach((_, sourceTableDetails) {
          sourceTableDetails.forEach((_, relationshipDetails) {
            result.add(
              AcDDRelationship.instanceFromJson(jsonData: relationshipDetails),
            );
          });
        });
      });
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves all stored procedures from a data dictionary.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A map of stored procedure names to their corresponding AcDDStoredProcedure objects.",
    "returns_type": "Map<String, AcDDStoredProcedure>"
  }) */
  static Map<String, AcDDStoredProcedure> getStoredProcedures({
    String dataDictionaryName = "default",
  }) {
    final result = <String, AcDDStoredProcedure>{};
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.storedProcedures.forEach((name, data) {
      result[name] = AcDDStoredProcedure.instanceFromJson(jsonData: data);
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a single stored procedure by its name.",
    "params": [
      {"name": "storedProcedureName", "description": "The name of the stored procedure to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDStoredProcedure object if found, otherwise null.",
    "returns_type": "AcDDStoredProcedure?"
  }) */
  static AcDDStoredProcedure? getStoredProcedure({
    required String storedProcedureName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.storedProcedures.containsKey(storedProcedureName)) {
      return AcDDStoredProcedure.instanceFromJson(
        jsonData: acDataDictionary.storedProcedures[storedProcedureName],
      );
    }
    return null;
  }

  /* AcDoc({
    "summary": "Retrieves a single table by its name.",
    "params": [
      {"name": "tableName", "description": "The name of the table to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDTable object if found, otherwise null.",
    "returns_type": "AcDDTable?"
  }) */
  static AcDDTable? getTable({
    required String tableName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.tables.containsKey(tableName)) {
      return AcDDTable.instanceFromJson(
        jsonData: acDataDictionary.tables[tableName],
      );
    }
    return null;
  }

  /* AcDoc({
    "summary": "Retrieves a single column from a specific table.",
    "params": [
      {"name": "tableName", "description": "The name of the table containing the column."},
      {"name": "columnName", "description": "The name of the column to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDTableColumn object if the table and column are found, otherwise null.",
    "returns_type": "AcDDTableColumn?"
  }) */
  static AcDDTableColumn? getTableColumn({
    required String tableName,
    required String columnName,
    String dataDictionaryName = "default",
  }) {
    final table = getTable(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    );
    return table?.getColumn(columnName);
  }

  /* AcDoc({
    "summary": "Gets all relationships associated with a specific table column.",
    "description": "Finds all relationships where the given column acts as either a source or a destination, based on the specified relation type.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "columnName", "description": "The name of the column."},
      {"name": "relationType", "description": "The type of relationship to find (source, destination, or any). Defaults to 'any'."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A list of AcDDRelationship objects matching the criteria.",
    "returns_type": "List<AcDDRelationship>"
  }) */
  static List<AcDDRelationship> getTableColumnRelationships({
    required String tableName,
    required String columnName,
    AcEnumDDColumnRelationType relationType = AcEnumDDColumnRelationType.any,
    String dataDictionaryName = "default",
  }) {
    final result = <AcDDRelationship>[];
    final allRelationships = getRelationships(dataDictionaryName: dataDictionaryName);

    for (final r in allRelationships) {
      final isSource = r.sourceTable == tableName && r.sourceColumn == columnName;
      final isDestination = r.destinationTable == tableName && r.destinationColumn == columnName;

      bool shouldInclude = false;
      switch (relationType) {
        case AcEnumDDColumnRelationType.any:
          if (isSource || isDestination) shouldInclude = true;
          break;
        case AcEnumDDColumnRelationType.source:
          if (isSource) shouldInclude = true;
          break;
        case AcEnumDDColumnRelationType.destination:
          if (isDestination) shouldInclude = true;
          break;
      }

      if (shouldInclude) {
        result.add(r);
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Gets all relationships associated with a specific table.",
    "description": "Finds all relationships where the given table acts as either a source or a destination, based on the specified relation type.",
    "params": [
      {"name": "tableName", "description": "The name of the table."},
      {"name": "relationType", "description": "The type of relationship to find (source, destination, or any). Defaults to 'any'."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A list of AcDDRelationship objects matching the criteria.",
    "returns_type": "List<AcDDRelationship>"
  }) */
  static List<AcDDRelationship> getTableRelationships({
    required String tableName,
    AcEnumDDColumnRelationType relationType = AcEnumDDColumnRelationType.any,
    String dataDictionaryName = "default",
  }) {
    final result = <AcDDRelationship>[];
    final allRelationships = getRelationships(dataDictionaryName: dataDictionaryName);

    for (final r in allRelationships) {
      final isSource = r.sourceTable == tableName;
      final isDestination = r.destinationTable == tableName;

      bool shouldInclude = false;
      switch (relationType) {
        case AcEnumDDColumnRelationType.any:
          if (isSource || isDestination) shouldInclude = true;
          break;
        case AcEnumDDColumnRelationType.source:
          if (isSource) shouldInclude = true;
          break;
        case AcEnumDDColumnRelationType.destination:
          if (isDestination) shouldInclude = true;
          break;
      }

      if (shouldInclude) {
        result.add(r);
      }
    }
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves all tables from a data dictionary.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A map of table names to their corresponding AcDDTable objects.",
    "returns_type": "Map<String, AcDDTable>"
  }) */
  static Map<String, AcDDTable> getTables({
    String dataDictionaryName = "default",
  }) {
    final result = <String, AcDDTable>{};
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.tables.forEach((name, data) {
      result[name] = AcDDTable.instanceFromJson(jsonData: data);
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves all triggers from a data dictionary.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A map of trigger names to their corresponding AcDDTrigger objects.",
    "returns_type": "Map<String, AcDDTrigger>"
  }) */
  static Map<String, AcDDTrigger> getTriggers({
    String dataDictionaryName = "default",
  }) {
    final result = <String, AcDDTrigger>{};
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.triggers.forEach((name, data) {
      result[name] = AcDDTrigger.instanceFromJson(jsonData: data);
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a single trigger by its name.",
    "params": [
      {"name": "triggerName", "description": "The name of the trigger to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDTrigger object if found, otherwise null.",
    "returns_type": "AcDDTrigger?"
  }) */
  static AcDDTrigger? getTrigger({
    required String triggerName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.triggers.containsKey(triggerName)) {
      return AcDDTrigger.instanceFromJson(
        jsonData: acDataDictionary.triggers[triggerName],
      );
    }
    return null;
  }

  /* AcDoc({
    "summary": "Retrieves all views from a data dictionary.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A map of view names to their corresponding AcDDView objects.",
    "returns_type": "Map<String, AcDDView>"
  }) */
  static Map<String, AcDDView> getViews({
    String dataDictionaryName = "default",
  }) {
    final result = <String, AcDDView>{};
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    acDataDictionary.views.forEach((name, data) {
      result[name] = AcDDView.instanceFromJson(jsonData: data);
    });
    return result;
  }

  /* AcDoc({
    "summary": "Retrieves a single view by its name.",
    "params": [
      {"name": "viewName", "description": "The name of the view to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDView object if found, otherwise null.",
    "returns_type": "AcDDView?"
  }) */
  static AcDDView? getView({
    required String viewName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.views.containsKey(viewName)) {
      return AcDDView.instanceFromJson(
        jsonData: acDataDictionary.views[viewName],
      );
    }
    return null;
  }

  /* AcDoc({
    "summary": "Registers a data dictionary from a JSON map.",
    "description": "Adds or replaces a data dictionary in the static registry under a given name. This allows multiple dictionaries to be managed by the application.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the data dictionary schema."},
      {"name": "dataDictionaryName", "description": "The name to register the dictionary under. Defaults to 'default'."}
    ]
  }) */
  static void registerDataDictionary({required Map<String, dynamic> jsonData, String dataDictionaryName = "default"}) {
    dataDictionaries[dataDictionaryName] = jsonData;
  }

  /* AcDoc({
    "summary": "Registers a data dictionary from a JSON string.",
    "description": "Parses a JSON string and adds or replaces a data dictionary in the static registry under a given name.",
    "params": [
      {"name": "jsonString", "description": "The JSON string representing the data dictionary schema."},
      {"name": "dataDictionaryName", "description": "The name to register the dictionary under. Defaults to 'default'."}
    ]
  }) */
  static void registerDataDictionaryJsonString({
    required String jsonString,
    String dataDictionaryName = "default",
  }) {
    final jsonData = jsonString.toJsonMap();
    registerDataDictionary(
      jsonData: jsonData,
      dataDictionaryName: dataDictionaryName,
    );
  }

  /* AcDoc({
    "summary": "Populates the instance from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the data dictionary properties."}
    ],
    "returns": "The current instance, for chaining.",
    "returns_type": "AcDataDictionary"
  }) */
  AcDataDictionary fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Gets the names of all tables in this dictionary instance.",
    "returns": "A list of table names.",
    "returns_type": "List<String>"
  }) */
  List<String> getTableNames() => tables.keys.toList();

  /* AcDoc({
    "summary": "Gets the raw JSON data for all tables in this dictionary instance.",
    "returns": "A list of JSON maps, where each map represents a table.",
    "returns_type": "List<Map<String, dynamic>>"
  }) */
  List<Map<String, dynamic>> getTablesList() => tables.values.cast<Map<String, dynamic>>().toList();

  /* AcDoc({
    "summary": "Gets the names of all columns for a specific table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to inspect."}
    ],
    "returns": "A list of column names for the given table. Returns an empty list if the table is not found.",
    "returns_type": "List<String>"
  }) */
  List<String> getTableColumnNames({required String tableName}) {
    if (tables.containsKey(tableName)) {
      final tableDetails = tables[tableName] as Map<String, dynamic>;
      if (tableDetails.containsKey(AcDDTable.keyTableColumns)) {
        final tableColumns = tableDetails[AcDDTable.keyTableColumns] as Map<String, dynamic>;
        return tableColumns.keys.toList();
      }
    }
    return [];
  }

  /* AcDoc({
    "summary": "Gets the raw JSON data for all columns in a specific table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to inspect."}
    ],
    "returns": "A list of JSON maps, where each map represents a column. Returns an empty list if the table is not found.",
    "returns_type": "List<Map<String, dynamic>>"
  }) */
  List<Map<String, dynamic>> getTableColumnsList({required String tableName}) {
    if (tables.containsKey(tableName)) {
      final tableDetails = tables[tableName] as Map<String, dynamic>;
      if (tableDetails[AcDDTable.keyTableColumns] is Map) {
        return (tableDetails[AcDDTable.keyTableColumns] as Map).values.cast<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  /* AcDoc({
    "summary": "Gets the raw JSON data for all relationships of a specific table.",
    "description": "Iterates through the complex relationship map to find all relationships where the specified table is either the source or destination.",
    "params": [
      {"name": "tableName", "description": "The name of the table to find relationships for."},
      {"name": "asDestination", "description": "If true, finds relationships where the table is the destination. If false, finds relationships where it is the source."}
    ],
    "returns": "A list of JSON maps, where each map represents a relationship.",
    "returns_type": "List<Map<String, dynamic>>"
  }) */
  List<Map<String, dynamic>> getTableRelationshipsList({
    required String tableName,
    bool asDestination = true,
  }) {
    final result = <Map<String, dynamic>>[];
    relationships.forEach((_, destinationTableDetails) {
      destinationTableDetails.forEach((_, destinationColumnDetails) {
        destinationColumnDetails.forEach((_, sourceTableDetails) {
          sourceTableDetails.forEach((_, relationshipDetails) {
            final r = relationshipDetails as Map<String, dynamic>;
            final columnKey = asDestination
                ? AcDDRelationship.keyDestinationTable
                : AcDDRelationship.keySourceTable;
            if (r[columnKey] == tableName) {
              result.add(r);
            }
          });
        });
      });
    });
    return result;
  }

  /* AcDoc({
    "summary": "Gets the raw JSON data for all triggers associated with a table.",
    "params": [
      {"name": "tableName", "description": "The name of the table to find triggers for."}
    ],
    "returns": "A list of JSON maps, where each map represents a trigger.",
    "returns_type": "List<Map<String, dynamic>>"
  }) */
  List<Map<String, dynamic>> getTableTriggersList({required String tableName}) {
    return triggers.values
        .where((trigger) => trigger[AcDDTrigger.keyTableName] == tableName)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /* AcDoc({
    "summary": "Serializes the current data dictionary instance to a JSON map.",
    "description": "An instance method that uses reflection-based utilities to convert this object's properties into a JSON map.",
    "returns": "A JSON map representation of the data dictionary.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the object.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}

//
//
// @AcReflectable()
// class AcDataDictionary {
//   static const String KEY_DATA_DICTIONARIES = "data_dictionaries";
//   static const String KEY_FUNCTIONS = "functions";
//   static const String KEY_RELATIONSHIPS = "relationships";
//   static const String KEY_STORED_PROCEDURES = "stored_procedures";
//   static const String KEY_TABLES = "tables";
//   static const String KEY_TRIGGERS = "triggers";
//   static const String KEY_VERSION = "version";
//   static const String KEY_VIEWS = "views";
//
//   @AcBindJsonProperty(key: KEY_DATA_DICTIONARIES)
//   static Map<String, dynamic> dataDictionaries = {};
//
//   Map<String, dynamic> functions = {};
//   Map<String, dynamic> relationships = {};
//
//   @AcBindJsonProperty(key: KEY_STORED_PROCEDURES)
//   Map<String, dynamic> storedProcedures = {};
//
//   Map<String, dynamic> tables = {};
//
//   Map<String, dynamic> triggers = {};
//
//   int version = 0;
//
//   Map<String, dynamic> views = {};
//
//   static AcDataDictionary instanceFromJson({
//     required Map<String, dynamic> jsonData,
//   }) {
//     return AcDataDictionary().fromJson(jsonData: jsonData);
//   }
//
//   static AcDataDictionary fromJsonString({required String jsonString}) {
//     final jsonData = jsonString.toJsonMap();
//     return AcDataDictionary().fromJson(jsonData: jsonData);
//   }
//
//   static Map<String, AcDDFunction> getFunctions({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <String, AcDDFunction>{};
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.functions.forEach((functionName, functionData) {
//       result[functionName] = AcDDFunction.instanceFromJson(
//         jsonData: functionData,
//       );
//     });
//     return result;
//   }
//
//   static AcDDFunction? getFunction({
//     required String functionName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.functions.containsKey(functionName)) {
//       return AcDDFunction.instanceFromJson(
//         jsonData: acDataDictionary.functions[functionName],
//       );
//     }
//     return null;
//   }
//
//   static AcDataDictionary getInstance({String dataDictionaryName = "default"}) {
//     final instance = AcDataDictionary();
//     if (dataDictionaries.containsKey(dataDictionaryName)) {
//       instance.fromJson(jsonData: dataDictionaries[dataDictionaryName]);
//     }
//     return instance;
//   }
//
//   static List<AcDDRelationship> getRelationships({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <AcDDRelationship>[];
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.relationships.forEach((_, destinationTableDetails) {
//       destinationTableDetails.forEach((_, destinationColumnDetails) {
//         destinationColumnDetails.forEach((_, sourceTableDetails) {
//           sourceTableDetails.forEach((_, relationshipDetails) {
//             result.add(
//               AcDDRelationship.instanceFromJson(jsonData: relationshipDetails),
//             );
//           });
//         });
//       });
//     });
//     return result;
//   }
//
//   static Map<String, AcDDStoredProcedure> getStoredProcedures({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <String, AcDDStoredProcedure>{};
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.storedProcedures.forEach((name, data) {
//       result[name] = AcDDStoredProcedure.instanceFromJson(jsonData: data);
//     });
//     return result;
//   }
//
//   static AcDDStoredProcedure? getStoredProcedure({
//     required String storedProcedureName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.storedProcedures.containsKey(storedProcedureName)) {
//       return AcDDStoredProcedure.instanceFromJson(
//         jsonData: acDataDictionary.storedProcedures[storedProcedureName],
//       );
//     }
//     return null;
//   }
//
//   static AcDDTable? getTable({
//     required String tableName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.tables.containsKey(tableName)) {
//       return AcDDTable.instanceFromJson(
//         jsonData: acDataDictionary.tables[tableName],
//       );
//     }
//     return null;
//   }
//
//   static AcDDTableColumn? getTableColumn({
//     required String tableName,
//     required String columnName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.tables.containsKey(tableName)) {
//       final tableData = acDataDictionary.tables[tableName];
//       final table = AcDDTable.instanceFromJson(jsonData: tableData);
//       return table.getColumn(columnName);
//     }
//     return null;
//   }
//
//   static List<AcDDRelationship> getTableColumnRelationships({
//     required String tableName,
//     required String columnName,
//     AcEnumDDColumnRelationType relationType = AcEnumDDColumnRelationType.any,
//     String dataDictionaryName = "default",
//   }) {
//     final result = <AcDDRelationship>[];
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.relationships.forEach((_, destinationTableDetails) {
//       destinationTableDetails.forEach((_, destinationColumnDetails) {
//         destinationColumnDetails.forEach((_, sourceTableDetails) {
//           sourceTableDetails.forEach((_, relationshipDetails) {
//             final r = relationshipDetails;
//             final bool include =
//                 (relationType == AcEnumDDColumnRelationType.any &&
//                     ((tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] &&
//                             columnName ==
//                                 r[AcDDRelationship.KEY_DESTINATION_COLUMN]) ||
//                         (tableName == r[AcDDRelationship.KEY_SOURCE_TABLE] &&
//                             columnName ==
//                                 r[AcDDRelationship.KEY_SOURCE_COLUMN]))) ||
//                 (relationType == AcEnumDDColumnRelationType.source &&
//                     tableName == r[AcDDRelationship.KEY_SOURCE_TABLE] &&
//                     columnName == r[AcDDRelationship.KEY_SOURCE_COLUMN]) ||
//                 (relationType == AcEnumDDColumnRelationType.destination &&
//                     tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] &&
//                     columnName == r[AcDDRelationship.KEY_DESTINATION_COLUMN]);
//             if (include) {
//               result.add(AcDDRelationship.instanceFromJson(jsonData: r));
//             }
//           });
//         });
//       });
//     });
//     return result;
//   }
//
//   static List<AcDDRelationship> getTableRelationships({
//     required String tableName,
//     AcEnumDDColumnRelationType relationType = AcEnumDDColumnRelationType.any,
//     String dataDictionaryName = "default",
//   }) {
//     final result = <AcDDRelationship>[];
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.relationships.forEach((_, destinationTableDetails) {
//       destinationTableDetails.forEach((_, destinationColumnDetails) {
//         destinationColumnDetails.forEach((_, sourceTableDetails) {
//           sourceTableDetails.forEach((_, relationshipDetails) {
//             final r = relationshipDetails;
//             final bool include =
//                 (relationType == AcEnumDDColumnRelationType.any &&
//                     (tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] ||
//                         tableName == r[AcDDRelationship.KEY_SOURCE_TABLE])) ||
//                 (relationType == AcEnumDDColumnRelationType.source &&
//                     tableName == r[AcDDRelationship.KEY_SOURCE_TABLE]) ||
//                 (relationType == AcEnumDDColumnRelationType.destination &&
//                     tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE]);
//             if (include) {
//               result.add(AcDDRelationship.instanceFromJson(jsonData: r));
//             }
//           });
//         });
//       });
//     });
//     return result;
//   }
//
//   static Map<String, AcDDTable> getTables({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <String, AcDDTable>{};
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.tables.forEach((name, data) {
//       result[name] = AcDDTable.instanceFromJson(jsonData: data);
//     });
//     return result;
//   }
//
//   static Map<String, AcDDTrigger> getTriggers({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <String, AcDDTrigger>{};
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.triggers.forEach((name, data) {
//       result[name] = AcDDTrigger.instanceFromJson(jsonData: data);
//     });
//     return result;
//   }
//
//   static AcDDTrigger? getTrigger({
//     required String triggerName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.triggers.containsKey(triggerName)) {
//       return AcDDTrigger.instanceFromJson(
//         jsonData: acDataDictionary.triggers[triggerName],
//       );
//     }
//     return null;
//   }
//
//   static Map<String, AcDDView> getViews({
//     String dataDictionaryName = "default",
//   }) {
//     final result = <String, AcDDView>{};
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     acDataDictionary.views.forEach((name, data) {
//       result[name] = AcDDView.instanceFromJson(jsonData: data);
//     });
//     return result;
//   }
//
//   static AcDDView? getView({
//     required String viewName,
//     String dataDictionaryName = "default",
//   }) {
//     final acDataDictionary = getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//     if (acDataDictionary.views.containsKey(viewName)) {
//       return AcDDView.instanceFromJson(
//         jsonData: acDataDictionary.views[viewName],
//       );
//     }
//     return null;
//   }
//
//   static void registerDataDictionary({required Map<String, dynamic> jsonData,String dataDictionaryName = "default"}) {
//     dataDictionaries[dataDictionaryName] = jsonData;
//   }
//
//   static void registerDataDictionaryJsonString({
//     required String jsonString,
//     String dataDictionaryName = "default",
//   }) {
//     final jsonData = jsonString.toJsonMap();
//     registerDataDictionary(
//       jsonData: jsonData,
//       dataDictionaryName: dataDictionaryName,
//     );
//   }
//
//   AcDataDictionary fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(
//       instance: this,
//       jsonData: jsonData,
//     );
//     return this;
//   }
//
//   List<String> getTableNames() => tables.keys.toList();
//
//   List<dynamic> getTablesList() => tables.values.toList();
//
//   List<String> getTableColumnNames({required String tableName}) {
//     List<String> result = [];
//     if (tables.containsKey(tableName)) {
//       Map<String, dynamic> tableDetails = tables[tableName];
//       Map<String, dynamic> tableColumns =
//           tableDetails[AcDDTable.KEY_TABLE_COLUMNS];
//       result = tableColumns.keys.toList();
//     }
//     return result;
//   }
//
//   List<dynamic> getTableColumnsList({required String tableName}) =>
//       tables.containsKey(tableName) &&
//               tables[tableName][AcDDTable.KEY_TABLE_COLUMNS] is Map
//           ? (tables[tableName][AcDDTable.KEY_TABLE_COLUMNS] as Map).values
//               .toList()
//           : [];
//
//   List<dynamic> getTableRelationshipsList({
//     required String tableName,
//     bool asDestination = true,
//   }) {
//     final result = <dynamic>[];
//     relationships.forEach((_, destinationTableDetails) {
//       destinationTableDetails.forEach((_, destinationColumnDetails) {
//         destinationColumnDetails.forEach((_, sourceTableDetails) {
//           sourceTableDetails.forEach((_, relationshipDetails) {
//             final columnKey =
//                 asDestination
//                     ? AcDDRelationship.KEY_DESTINATION_TABLE
//                     : AcDDRelationship.KEY_SOURCE_TABLE;
//             if (relationshipDetails[columnKey] == tableName) {
//               result.add(relationshipDetails);
//             }
//           });
//         });
//       });
//     });
//     return result;
//   }
//
//   List<dynamic> getTableTriggersList({required String tableName}) {
//     return triggers.values
//         .where((trigger) => trigger[AcDDTrigger.KEY_TABLE_NAME] == tableName)
//         .toList();
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance: this);
//   }
//
//   @override
//   String toString() {
//     return AcJsonUtils.prettyEncode(toJson());
//   }
// }
