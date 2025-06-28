import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single stored function.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific database function. It automatically loads the function's definition from the data dictionary upon instantiation, making it easy to access the function's metadata and code.",
  "example": "// Prerequisite: A data dictionary with a function named 'get_user_full_name' is registered.\n\n// Create a handler specifically for that function.\nfinal functionHandler = AcSqlDbFunction(functionName: 'get_user_full_name');\n\n// Access the function's definition.\nprint(functionHandler.acDDFunction.functionCode);"
}) */
class AcSqlDbFunction extends AcSqlDbBase {
  /* AcDoc({
    "summary": "The loaded data dictionary definition for the specific function."
  }) */
  late AcDDFunction acDDFunction;

  /* AcDoc({
    "summary": "The name of the function this handler is responsible for."
  }) */
  String functionName = "";

  /* AcDoc({
    "summary": "Creates a service handler for a specific database function.",
    "description": "Initializes the base database service and loads the definition for the specified function from the data dictionary.\n\nNote: This constructor will throw a runtime error if the `functionName` does not exist in the specified `dataDictionaryName`, due to an unsafe lookup.",
    "params": [
      {"name": "functionName", "description": "The name of the database function to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbFunction({
    required String functionName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: dataDictionaryName) {
    // Correctly assign the instance field from the parameter.
    this.functionName = functionName;

    // Warning: The force-unwrap operator `!` will cause an error if the function is not found.
    acDDFunction =
    AcDataDictionary.getFunction(
      functionName: functionName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbFunction extends AcSqlDbBase {
//   late AcDDFunction acDDFunction;
//   String functionName = "";
//
//   AcSqlDbFunction({
//     required String functionName,
//     String dataDictionaryName = "default",
//   }) : super(dataDictionaryName: dataDictionaryName) {
//     functionName = functionName;
//     acDDFunction =
//         AcDataDictionary.getFunction(
//           functionName: functionName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//   }
// }
