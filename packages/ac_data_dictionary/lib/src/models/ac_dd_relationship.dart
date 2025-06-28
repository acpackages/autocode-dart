import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a foreign key relationship between two table columns.",
  "description": "This class models a single directional link from a source table and column to a destination table and column. It includes metadata to define the relationship and associated behaviors like cascade deletes.",
  "example": "// Example of a `users.id -> posts.user_id` relationship.\nfinal relationship = AcDDRelationship.instanceFromJson(jsonData: {\n  'source_table': 'users',\n  'source_column': 'id',\n  'destination_table': 'posts',\n  'destination_column': 'user_id',\n  'cascade_delete_destination': true\n});"
}) */
@AcReflectable()
class AcDDRelationship {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCascadeDeleteDestination = "cascade_delete_destination";
  static const String keyCascadeDeleteSource = "cascade_delete_source";
  static const String keyDestinationColumn = "destination_column";
  static const String keyDestinationTable = "destination_table";
  static const String keySourceColumn = "source_column";
  static const String keySourceTable = "source_table";

  /* AcDoc({
    "summary": "Indicates if a delete should cascade to destination records.",
    "description": "If true, deleting a source record should also delete related records in the destination table. Corresponds to an `ON DELETE CASCADE` clause."
  }) */
  @AcBindJsonProperty(key: keyCascadeDeleteDestination)
  bool cascadeDeleteDestination = false;

  /* AcDoc({
    "summary": "Indicates if a delete should cascade to source records.",
    "description": "A less common scenario. If true, deleting a destination record could trigger a deletion or nullification on the source record, depending on database rules."
  }) */
  @AcBindJsonProperty(key: keyCascadeDeleteSource)
  bool cascadeDeleteSource = false;

  /* AcDoc({
    "summary": "The name of the column on the destination side of the relationship (the foreign key column)."
  }) */
  @AcBindJsonProperty(key: keyDestinationColumn)
  String destinationColumn = "";

  /* AcDoc({
    "summary": "The name of the table on the destination side of the relationship (the table containing the foreign key)."
  }) */
  @AcBindJsonProperty(key: keyDestinationTable)
  String destinationTable = "";

  /* AcDoc({
    "summary": "The name of the column on the source side of the relationship (the primary key or unique column)."
  }) */
  @AcBindJsonProperty(key: keySourceColumn)
  String sourceColumn = "";

  /* AcDoc({
    "summary": "The name of the table on the source side of the relationship (the table being referenced)."
  }) */
  @AcBindJsonProperty(key: keySourceTable)
  String sourceTable = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a data dictionary relationship."
  }) */
  AcDDRelationship();

  /* AcDoc({
    "summary": "Creates a new AcDDRelationship instance from a JSON map.",
    "description": "This factory constructor provides a convenient way to create and populate a relationship object directly from a JSON data structure.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the relationship."}
    ],
    "returns": "A new, populated AcDDRelationship instance.",
    "returns_type": "AcDDRelationship"
  }) */
  factory AcDDRelationship.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDRelationship();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Gets all relationships pointing to a specific destination column.",
    "description": "Looks up all defined relationships where the specified destination table and column are being referenced, and returns them as a list.",
    "params": [
      {"name": "destinationColumn", "description": "The destination column name (the foreign key)."},
      {"name": "destinationTable", "description": "The destination table name."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "A list of AcDDRelationship objects that point to the specified destination.",
    "returns_type": "List<AcDDRelationship>"
  }) */
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

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the relationship's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDRelationship"
  }) */
  AcDDRelationship fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the foreign key constraint.",
    "description": "Creates a standard `ALTER TABLE ... ADD FOREIGN KEY` statement. Note: This basic implementation does not currently use the `cascade...` flags or the `databaseType` parameter for advanced SQL generation.",
    "params": [
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to create the foreign key.",
    "returns_type": "String"
  }) */
  String getCreateRelationshipStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
    return "ALTER TABLE $destinationTable ADD FOREIGN KEY ($destinationColumn) REFERENCES $sourceTable($sourceColumn);";
  }

  /* AcDoc({
    "summary": "Serializes the current relationship instance to a JSON map.",
    "description": "An instance method that uses reflection-based utilities to convert this object's properties into a JSON map.",
    "returns": "A JSON map representation of the relationship.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the relationship.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}

// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// @AcReflectable()
// class AcDDRelationship {
//   static const String KEY_CASCADE_DELETE_DESTINATION =
//       "cascade_delete_destination";
//   static const String KEY_CASCADE_DELETE_SOURCE = "cascade_delete_source";
//   static const String KEY_DESTINATION_COLUMN = "destination_column";
//   static const String KEY_DESTINATION_TABLE = "destination_table";
//   static const String KEY_SOURCE_COLUMN = "source_column";
//   static const String KEY_SOURCE_TABLE = "source_table";
//
//   @AcBindJsonProperty(key: KEY_CASCADE_DELETE_DESTINATION)
//   bool cascadeDeleteDestination = false;
//
//   @AcBindJsonProperty(key: KEY_CASCADE_DELETE_SOURCE)
//   bool cascadeDeleteSource = false;
//
//   @AcBindJsonProperty(key: KEY_DESTINATION_COLUMN)
//   String destinationColumn = "";
//
//   @AcBindJsonProperty(key: KEY_DESTINATION_TABLE)
//   String destinationTable = "";
//
//   @AcBindJsonProperty(key: KEY_SOURCE_COLUMN)
//   String sourceColumn = "";
//
//   @AcBindJsonProperty(key: KEY_SOURCE_TABLE)
//   String sourceTable = "";
//
//   AcDDRelationship();
//
//   factory AcDDRelationship.instanceFromJson({
//     required Map<String, dynamic> jsonData,
//   }) {
//     final instance = AcDDRelationship();
//     instance.fromJson(jsonData: jsonData);
//     return instance;
//   }
//
//   static List<AcDDRelationship> getInstances({
//     required String destinationColumn,
//     required String destinationTable,
//     String dataDictionaryName = "default",
//   }) {
//     final result = <AcDDRelationship>[];
//     final acDataDictionary = AcDataDictionary.getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//
//     if (acDataDictionary.relationships.containsKey(destinationTable) &&
//         acDataDictionary.relationships[destinationTable].containsKey(
//           destinationColumn,
//         )) {
//       final sourceDetails =
//           acDataDictionary.relationships[destinationTable][destinationColumn];
//       sourceDetails.forEach((sourceTable, sourceColumnDetails) {
//         sourceColumnDetails.forEach((sourceColumn, relationshipDetails) {
//           result.add(
//             AcDDRelationship.instanceFromJson(jsonData: relationshipDetails),
//           );
//         });
//       });
//     }
//
//     return result;
//   }
//
//   AcDDRelationship fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(
//       instance: this,
//       jsonData: jsonData,
//     );
//     return this;
//   }
//
//   String getCreateRelationshipStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = "ALTER TABLE $destinationTable ADD FOREIGN KEY ($destinationColumn) REFERENCES $sourceTable($sourceColumn);";
//     return result;
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
