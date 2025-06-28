import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single table relationship.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific database relationship (i.e., a foreign key). It holds the relationship's definition, allowing for targeted operations or queries based on that specific link between two tables.",
  "example": "// Prerequisite: An AcDDRelationship object is already defined or loaded.\nfinal userToPostRelationship = AcDDRelationship.getInstances(\n  destinationTable: 'posts',\n  destinationColumn: 'user_id'\n).first;\n\n// Create a handler specifically for that relationship.\nfinal relationshipHandler = AcSqlDbRelationship(\n  acDDRelationship: userToPostRelationship\n);\n\n// Now you can use the handler's dao with context of the relationship.\n// For example, finding all posts for a user, or finding the user for a post."
}) */
class AcSqlDbRelationship extends AcSqlDbBase {
  /* AcDoc({
    "summary": "The loaded data dictionary definition for the specific relationship."
  }) */
  late AcDDRelationship acDDRelationship;

  /* AcDoc({
    "summary": "Creates a service handler for a specific database relationship.",
    "description": "Initializes the base database service and holds the provided relationship definition object for context-aware operations.",
    "params": [
      {"name": "acDDRelationship", "description": "The relationship definition object to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Passed to the superclass."}
    ]
  }) */
  AcSqlDbRelationship({
    required AcDDRelationship acDDRelationship,
    super.dataDictionaryName,
  }) {
    // Correctly assign the instance field from the parameter.
    this.acDDRelationship = acDDRelationship;
  }
}
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbRelationship extends AcSqlDbBase {
//   late AcDDRelationship acDDRelationship;
//
//   AcSqlDbRelationship({
//     required AcDDRelationship acDDRelationship,
//     super.dataDictionaryName,
//   }) {
//     acDDRelationship = acDDRelationship;
//   }
// }
