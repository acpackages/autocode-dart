import 'dart:core';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';

class AcDataDictionary {
  static const String KEY_DATA_DICTIONARIES = "data_dictionaries";
  static const String KEY_FUNCTIONS = "functions";
  static const String KEY_RELATIONSHIPS = "relationships";
  static const String KEY_STORED_PROCEDURES = "stored_procedures";
  static const String KEY_TABLES = "tables";
  static const String KEY_TRIGGERS = "triggers";
  static const String KEY_VERSION = "version";
  static const String KEY_VIEWS = "views";

  @AcBindJsonProperty(key: KEY_DATA_DICTIONARIES)
  static Map<String, dynamic> dataDictionaries = {};

  Map<String, dynamic> functions = {};
  Map<String, dynamic> relationships = {};

  @AcBindJsonProperty(key: KEY_STORED_PROCEDURES)
  Map<String, dynamic> storedProcedures = {};

  Map<String, dynamic> tables = {};

  Map<String, dynamic> triggers = {};

  int version = 0;

  Map<String, dynamic> views = {};

  static AcDataDictionary instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    return AcDataDictionary().fromJson(jsonData: jsonData);
  }

  static AcDataDictionary fromJsonString({required String jsonString}) {
    final jsonData = jsonString.parseJsonToMap();
    return AcDataDictionary().fromJson(jsonData: jsonData);
  }

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

  static AcDataDictionary getInstance({String dataDictionaryName = "default"}) {
    final instance = AcDataDictionary();
    if (dataDictionaries.containsKey(dataDictionaryName)) {
      instance.fromJson(jsonData: dataDictionaries[dataDictionaryName]);
    }
    return instance;
  }

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

  static AcDDTableColumn? getTableColumn({
    required String tableName,
    required String columnName,
    String dataDictionaryName = "default",
  }) {
    final acDataDictionary = getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.tables.containsKey(tableName)) {
      final tableData = acDataDictionary.tables[tableName];
      final table = AcDDTable.instanceFromJson(jsonData: tableData);
      return table.getColumn(columnName);
    }
    return null;
  }

  static List<AcDDRelationship> getTableColumnRelationships({
    required String tableName,
    required String columnName,
    String relationType = AcEnumDDColumnRelationType.ANY,
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
            final r = relationshipDetails;
            final bool include =
                (relationType == AcEnumDDColumnRelationType.ANY &&
                    ((tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] &&
                            columnName ==
                                r[AcDDRelationship.KEY_DESTINATION_COLUMN]) ||
                        (tableName == r[AcDDRelationship.KEY_SOURCE_TABLE] &&
                            columnName ==
                                r[AcDDRelationship.KEY_SOURCE_COLUMN]))) ||
                (relationType == AcEnumDDColumnRelationType.SOURCE &&
                    tableName == r[AcDDRelationship.KEY_SOURCE_TABLE] &&
                    columnName == r[AcDDRelationship.KEY_SOURCE_COLUMN]) ||
                (relationType == AcEnumDDColumnRelationType.DESTINATION &&
                    tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] &&
                    columnName == r[AcDDRelationship.KEY_DESTINATION_COLUMN]);
            if (include) {
              result.add(AcDDRelationship.instanceFromJson(jsonData: r));
            }
          });
        });
      });
    });
    return result;
  }

  static List<AcDDRelationship> getTableRelationships({
    required String tableName,
    String relationType = AcEnumDDColumnRelationType.ANY,
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
            final r = relationshipDetails;
            final bool include =
                (relationType == AcEnumDDColumnRelationType.ANY &&
                    (tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE] ||
                        tableName == r[AcDDRelationship.KEY_SOURCE_TABLE])) ||
                (relationType == AcEnumDDColumnRelationType.SOURCE &&
                    tableName == r[AcDDRelationship.KEY_SOURCE_TABLE]) ||
                (relationType == AcEnumDDColumnRelationType.DESTINATION &&
                    tableName == r[AcDDRelationship.KEY_DESTINATION_TABLE]);
            if (include) {
              result.add(AcDDRelationship.instanceFromJson(jsonData: r));
            }
          });
        });
      });
    });
    return result;
  }

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

  static void registerDataDictionary({required Map<String, dynamic> jsonData,String dataDictionaryName = "default"}) {
    dataDictionaries[dataDictionaryName] = jsonData;
  }

  static void registerDataDictionaryJsonString({
    required String jsonString,
    String dataDictionaryName = "default",
  }) {
    final jsonData = jsonString.parseJsonToMap();
    registerDataDictionary(
      jsonData: jsonData,
      dataDictionaryName: dataDictionaryName,
    );
  }

  AcDataDictionary fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  List<String> getTableNames() => tables.keys.toList();

  List<dynamic> getTablesList() => tables.values.toList();

  List<String> getTableColumnNames({required String tableName}) {
    List<String> result = [];
    if (tables.containsKey(tableName)) {
      Map<String, dynamic> tableDetails = tables[tableName];
      Map<String, dynamic> tableColumns =
          tableDetails[AcDDTable.KEY_TABLE_COLUMNS];
      result = tableColumns.keys.toList();
    }
    return result;
  }

  List<dynamic> getTableColumnsList({required String tableName}) =>
      tables.containsKey(tableName) &&
              tables[tableName][AcDDTable.KEY_TABLE_COLUMNS] is Map
          ? (tables[tableName][AcDDTable.KEY_TABLE_COLUMNS] as Map).values
              .toList()
          : [];

  List<dynamic> getTableRelationshipsList({
    required String tableName,
    bool asDestination = true,
  }) {
    final result = <dynamic>[];
    relationships.forEach((_, destinationTableDetails) {
      destinationTableDetails.forEach((_, destinationColumnDetails) {
        destinationColumnDetails.forEach((_, sourceTableDetails) {
          sourceTableDetails.forEach((_, relationshipDetails) {
            final columnKey =
                asDestination
                    ? AcDDRelationship.KEY_DESTINATION_TABLE
                    : AcDDRelationship.KEY_SOURCE_TABLE;
            if (relationshipDetails[columnKey] == tableName) {
              result.add(relationshipDetails);
            }
          });
        });
      });
    });
    return result;
  }

  List<dynamic> getTableTriggersList({required String tableName}) {
    return triggers.values
        .where((trigger) => trigger[AcDDTrigger.KEY_TABLE_NAME] == tableName)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
