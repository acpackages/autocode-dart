import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single stored procedure.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific stored procedure. It automatically loads the procedure's definition from the data dictionary upon instantiation.",
  "example": "// Prerequisite: A data dictionary with a stored procedure named 'archive_old_records' is registered.\n\n// Create a handler specifically for that stored procedure.\nfinal spHandler = AcSqlDbStoredProcedure(storedProcedureName: 'archive_old_records');\n\n// Access the procedure's definition and underlying DAO to execute it.\n// final createSql = spHandler.acDDStoredProcedure.getCreateStoredProcedureStatement();\n// spHandler.dao?.executeStatement(statement: 'CALL archive_old_records()');"
}) */
class AcSqlDbStoredProcedure extends AcSqlDbBase {
  /* AcDoc({
    "summary": "The loaded data dictionary definition for the specific stored procedure."
  }) */
  late AcDDStoredProcedure acDDStoredProcedure;

  /* AcDoc({
    "summary": "The name of the stored procedure this handler is responsible for."
  }) */
  String storedProcedureName = "";

  /* AcDoc({
    "summary": "Creates a service handler for a specific database stored procedure.",
    "description": "Initializes the base database service and loads the definition for the specified procedure from the data dictionary.\n\nNote: This constructor will throw a runtime error if the `storedProcedureName` does not exist in the specified `dataDictionaryName`.",
    "params": [
      {"name": "storedProcedureName", "description": "The name of the database stored procedure to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbStoredProcedure({
    required String storedProcedureName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: dataDictionaryName) { // Correctly pass the parameter to the super constructor.
    // Correctly assign the instance field from the parameter.
    this.storedProcedureName = storedProcedureName;

    // Warning: The force-unwrap operator `!` will cause an error if the stored procedure is not found.
    acDDStoredProcedure =
    AcDataDictionary.getStoredProcedure(
      storedProcedureName: storedProcedureName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbStoredProcedure extends AcSqlDbBase {
//   late AcDDStoredProcedure acDDStoredProcedure;
//   String storedProcedureName = "";
//
//   AcSqlDbStoredProcedure({
//     required String storedProcedureName,
//     String dataDictionaryName = "default",
//   }) : super(dataDictionaryName: "default") {
//     storedProcedureName = storedProcedureName;
//     acDDStoredProcedure =
//         AcDataDictionary.getStoredProcedure(
//           storedProcedureName: storedProcedureName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//   }
// }
