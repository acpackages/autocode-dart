import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
/* AcDoc({
  "summary": "Automatically generates a 'DELETE' API route for a specific table.",
  "description": "This class is a route generator used by `AcDataDictionaryAutoApi`. Upon instantiation, it creates and registers a `DELETE` endpoint with the `AcWeb` server. The generated route handles deleting a single record by its primary key, which is specified as a path parameter.",
  "example": "// This class is not typically used directly. It's instantiated by `AcDataDictionaryAutoApi`.\n// AcDataDictionaryAutoApi will execute this internally for a table:\n// AcDataDictionaryAutoDelete(\n//   acDDTable: userTableDefinition,\n//   acDataDictionaryAutoApi: apiGenerator,\n// );"
}) */
class AcDataDictionaryAutoDelete {
  /* AcDoc({"summary": "The data dictionary definition of the table for which the route is being generated."}) */
  final AcDDTable acDDTable;

  /* AcDoc({"summary": "The main auto-API generator instance, providing configuration and the `AcWeb` server."}) */
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  /* AcDoc({
    "summary": "Creates and registers the DELETE route for a table.",
    "description": "The constructor builds the API URL, creates the handler and its documentation, and registers the final `DELETE` route with the `AcWeb` instance provided by `acDataDictionaryAutoApi`.",
    "params": [
      {"name": "acDDTable", "description": "The definition of the table."},
      {"name": "acDataDictionaryAutoApi", "description": "The main API generator instance."}
    ]
  }) */
  AcDataDictionaryAutoDelete({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForDelete}/{${acDDTable.getPrimaryKeyColumnName()}}';
    acDataDictionaryAutoApi.acWeb.delete(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the generated DELETE route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the endpoint, including its summary, path parameters, and standard success and error responses.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = 'Delete ${acDDTable.tableName}';
    acApiDocRoute.description =
        'Auto generated data dictionary api to delete row in table ${acDDTable.tableName}';

    final parameter =
        AcApiDocParameter()
          ..name = acDDTable.getPrimaryKeyColumnName()
          ..description =
              '${acDDTable.getPrimaryKeyColumnName()} value of row to delete'
          ..required = true
          ..in_ = 'path';

    acApiDocRoute.addParameter(parameter: parameter);

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.delete,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  /* AcDoc({
    "summary": "Creates the request handler function for the DELETE route.",
    "description": "This method returns an asynchronous closure that processes the incoming `AcWebRequest`. The handler extracts the primary key from the URL path, calls the `deleteRows` method of the `AcSqlDbTable` service, and returns the result as a JSON response.",
    "returns": "The request handler function.",
    "returns_type": "AcWebResponse Function(AcWebRequest)"
  }) */
  AcWebResponse Function(AcWebRequest) getHandler() {
    return (AcWebRequest acWebRequest) {
      final response = AcResult();
      final key = acDDTable.getPrimaryKeyColumnName();
      if (acWebRequest.pathParameters.containsKey(key)) {
        final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
        return AcWebResponse.json(
          data: acSqlDbTable.deleteRows(
            primaryKeyValue: acWebRequest.pathParameters[key],
          ),
        );
      } else {
        response.message = 'parameters missing';
        return AcWebResponse.json(data: response);
      }
    };
  }
}
