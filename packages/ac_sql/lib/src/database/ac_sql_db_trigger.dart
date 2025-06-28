import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single database trigger.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific database trigger. It automatically loads the trigger's definition from the data dictionary upon instantiation, making it easy to access its metadata.",
  "example": "// Prerequisite: A data dictionary with a trigger named 'before_user_update' is registered.\n\n// Create a handler specifically for that trigger.\nfinal triggerHandler = AcSqlDbTrigger(triggerName: 'before_user_update');\n\n// Access the trigger's definition.\nfinal triggerCode = triggerHandler.acDDTrigger.triggerCode;\nprint('Trigger `before_user_update` will execute: \$triggerCode');"
}) */
class AcSqlDbTrigger extends AcSqlDbBase {
  /* AcDoc({
    "summary": "The loaded data dictionary definition for the specific trigger."
  }) */
  late AcDDTrigger acDDTrigger;

  /* AcDoc({
    "summary": "The name of the trigger this handler is responsible for."
  }) */
  String triggerName = '';

  /* AcDoc({
    "summary": "Creates a service handler for a specific database trigger.",
    "description": "Initializes the base database service and loads the definition for the specified trigger from the data dictionary.\n\nNote: This constructor will throw a runtime error if the `triggerName` does not exist in the specified `dataDictionaryName`.",
    "params": [
      {"name": "triggerName", "description": "The name of the database trigger to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbTrigger({
    required String triggerName,
    String dataDictionaryName = 'default',
  }) : super(dataDictionaryName: dataDictionaryName) {
    // Correctly assign the instance field from the parameter.
    this.triggerName = triggerName;

    // Warning: The force-unwrap operator `!` will cause an error if the trigger is not found.
    acDDTrigger =
    AcDataDictionary.getTrigger(
      triggerName: triggerName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbTrigger extends AcSqlDbBase {
//   late AcDDTrigger acDDTrigger;
//   String triggerName = '';
//
//   AcSqlDbTrigger({
//     required String triggerName,
//     String dataDictionaryName = 'default',
//   }) : super(dataDictionaryName: dataDictionaryName) {
//     triggerName = triggerName;
//     acDDTrigger =
//         AcDataDictionary.getTrigger(
//           triggerName: triggerName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//   }
// }
