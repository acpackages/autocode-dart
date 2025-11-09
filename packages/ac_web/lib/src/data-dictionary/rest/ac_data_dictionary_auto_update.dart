import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
/* AcDoc({
  "summary": "Automatically generates a 'POST' (update) API route for a specific table.",
  "description": "This class is a route generator used by `AcDataDictionaryAutoApi`. Upon instantiation, it creates and registers a `POST` endpoint for updating existing records. The generated route can handle updating either a single row or a list of rows in the request body. Each row must contain its primary key to be identified.",
  "example": "// This class is not typically used directly. It's instantiated by `AcDataDictionaryAutoApi`.\n// AcDataDictionaryAutoApi will execute this internally for a table:\n// AcDataDictionaryAutoUpdate(\n//   acDDTable: userTableDefinition,\n//   acDataDictionaryAutoApi: apiGenerator,\n// );"
}) */
class AcDataDictionaryAutoUpdate {
  /* AcDoc({"summary": "The data dictionary definition of the table for which the route is being generated."}) */
  final AcDDTable acDDTable;

  /* AcDoc({"summary": "The main auto-API generator instance, providing configuration and the `AcWeb` server."}) */
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  /* AcDoc({
    "summary": "Creates and registers the UPDATE route for a table.",
    "description": "The constructor builds the API URL, creates the handler and its documentation, and registers the final `POST` route with the `AcWeb` instance provided by `acDataDictionaryAutoApi`.",
    "params": [
      {"name": "acDDTable", "description": "The definition of the table."},
      {"name": "acDataDictionaryAutoApi", "description": "The main API generator instance."}
    ]
  }) */
  AcDataDictionaryAutoUpdate({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/'
        '${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/'
        '${AcDataDictionaryAutoApiConfig.pathForUpdate}';

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the generated UPDATE route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the endpoint, including a detailed request body schema that accepts either a single `row` object or a `rows` array for bulk updates. Each row must contain a primary key.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = 'Update ${acDDTable.tableName}';
    acApiDocRoute.description =
        'Auto generated data dictionary api to update row in table ${acDDTable.tableName}. '
        'Either single row or multiple rows can be updated at a time.';

    final schema = AcApiDocUtils.getApiModelRefFromAcDDTable(
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    final content =
        AcApiDocContent()
          ..encoding = 'application/json'
          ..schema = {
            'type': AcEnumApiDataType.object,
            'properties': {
              'row': schema,
              'rows': {'type': AcEnumApiDataType.array, 'items': schema},
            },
          };

    final requestBody = AcApiDocRequestBody()..addContent(content: content);
    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.update,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  /* AcDoc({
    "summary": "Creates the request handler function for the UPDATE route.",
    "description": "This method returns an asynchronous closure that processes the incoming `AcWebRequest`. The handler inspects the request body for a `row` or `rows` key and calls the appropriate `updateRow` or `updateRows` method from the table service, returning the result as a JSON response.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Function getHandler() {
    return (AcWebRequest acWebRequest, AcLogger logger) async {
      final response = AcWebApiResponse();
      try{
        final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);

        final post = acWebRequest.post;

        if (post.containsKey('row')) {
          response.setFromSqlDaoResult(result: await acSqlDbTable.updateRow(row: post['row']));
        } else if (post.containsKey('rows')) {
          response.setFromSqlDaoResult(result: await acSqlDbTable.updateRows(rows: post['rows']));
        } else {
          response.message = 'parameters missing';
        }
      }
      catch(ex,stack){
        response.setException(exception: ex,stackTrace: stack);
      }
      return response.toWebResponse();
    };
  }
}
