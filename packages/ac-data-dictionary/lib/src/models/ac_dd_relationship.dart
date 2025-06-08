import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

class AcDDRelationship {
  static const String KEY_CASCADE_DELETE_DESTINATION =
      "cascade_delete_destination";
  static const String KEY_CASCADE_DELETE_SOURCE = "cascade_delete_source";
  static const String KEY_DESTINATION_COLUMN = "destination_column";
  static const String KEY_DESTINATION_TABLE = "destination_table";
  static const String KEY_SOURCE_COLUMN = "source_column";
  static const String KEY_SOURCE_TABLE = "source_table";

  @AcBindJsonProperty(key: KEY_CASCADE_DELETE_DESTINATION)
  bool cascadeDeleteDestination = false;

  @AcBindJsonProperty(key: KEY_CASCADE_DELETE_SOURCE)
  bool cascadeDeleteSource = false;

  @AcBindJsonProperty(key: KEY_DESTINATION_COLUMN)
  String destinationColumn = "";

  @AcBindJsonProperty(key: KEY_DESTINATION_TABLE)
  String destinationTable = "";

  @AcBindJsonProperty(key: KEY_SOURCE_COLUMN)
  String sourceColumn = "";

  @AcBindJsonProperty(key: KEY_SOURCE_TABLE)
  String sourceTable = "";

  AcDDRelationship();

  factory AcDDRelationship.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDRelationship();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  static List<AcDDRelationship> getInstances({
    required String destinationColumn,
    required String destinationTable,
    String dataDictionaryName = "default",
  }) {
    final result = <AcDDRelationship>[];
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );

    if (acDataDictionary.relationships.containsKey(destinationTable) &&
        acDataDictionary.relationships[destinationTable].containsKey(
          destinationColumn,
        )) {
      final sourceDetails =
          acDataDictionary.relationships[destinationTable][destinationColumn];
      sourceDetails.forEach((sourceTable, sourceColumnDetails) {
        sourceColumnDetails.forEach((sourceColumn, relationshipDetails) {
          result.add(
            AcDDRelationship.instanceFromJson(jsonData: relationshipDetails),
          );
        });
      });
    }

    return result;
  }

  AcDDRelationship fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  String getCreateRelationshipStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    String result = "ALTER TABLE $destinationTable ADD FOREIGN KEY ($destinationColumn) REFERENCES $sourceTable($sourceColumn);";
    return result;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
