import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single database view.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific database view. It automatically loads the view's definition from the data dictionary upon instantiation, making it easy to query the view or inspect its columns.",
  "example": "// Prerequisite: A data dictionary with a view named 'published_articles' is registered.\n\n// Create a handler specifically for that view.\nfinal viewHandler = AcSqlDbView(viewName: 'published_articles');\n\n// Use the handler's dao to query the view.\nfinal result = await viewHandler.dao?.getRows(statement: 'SELECT * FROM published_articles');"
}) */
class AcSqlDbView extends AcSqlDbBase {
  /* AcDoc({
    "summary": "The name of the view this handler is responsible for."
  }) */
  String viewName = '';

  /* AcDoc({
    "summary": "The loaded data dictionary definition for the specific view."
  }) */
  late AcDDView acDDView;

  /* AcDoc({
    "summary": "Creates a service handler for a specific database view.",
    "description": "Initializes the base database service and loads the definition for the specified view from the data dictionary.\n\nNote: This constructor will throw a runtime error if the `viewName` does not exist in the specified `dataDictionaryName`.",
    "params": [
      {"name": "viewName", "description": "The name of the database view to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbView({required String viewName, String dataDictionaryName = 'default'})
      : super(dataDictionaryName: dataDictionaryName) {
    // Correctly assign the instance field from the parameter.
    this.viewName = viewName;

    // Warning: The force-unwrap operator `!` will cause an error if the view is not found.
    acDDView =
    AcDataDictionary.getView(
      viewName: viewName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbView extends AcSqlDbBase {
//   String viewName = '';
//   late AcDDView acDDView;
//
//   AcSqlDbView({required String viewName, String dataDictionaryName = 'default'})
//     : super(dataDictionaryName: dataDictionaryName) {
//     viewName = viewName;
//     acDDView =
//         AcDataDictionary.getView(
//           viewName: viewName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//   }
// }
