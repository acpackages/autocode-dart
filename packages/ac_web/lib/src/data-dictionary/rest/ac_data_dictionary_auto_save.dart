
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
/* AcDoc({
  "summary": "Automatically generates a 'POST' (save/upsert) API route for a specific table.",
  "description": "This class is a route generator used by `AcDataDictionaryAutoApi`. Upon instantiation, it creates and registers a `POST` endpoint for saving records. The 'save' operation implies an 'upsert': if a record exists (based on its primary key or other unique identifiers), it is updated; otherwise, it is inserted. The route can handle saving a single row or a list of rows.",
  "example": "// This class is not typically used directly. It's instantiated by `AcDataDictionaryAutoApi`.\n// AcDataDictionaryAutoApi will execute this internally for a table:\n// AcDataDictionaryAutoSave(\n//   acDDTable: userTableDefinition,\n//   acDataDictionaryAutoApi: apiGenerator,\n// );"
}) */
class AcDataDictionaryAutoSave {
  /* AcDoc({"summary": "The data dictionary definition of the table for which the route is being generated."}) */
  final AcDDTable acDDTable;

  /* AcDoc({"summary": "The main auto-API generator instance, providing configuration and the `AcWeb` server."}) */
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  /* AcDoc({
    "summary": "Creates and registers the SAVE route for a table.",
    "description": "The constructor builds the API URL, creates the handler and its documentation, and registers the final `POST` route with the `AcWeb` instance provided by `acDataDictionaryAutoApi`.",
    "params": [
      {"name": "acDDTable", "description": "The definition of the table."},
      {"name": "acDataDictionaryAutoApi", "description": "The main API generator instance."}
    ]
  }) */
  AcDataDictionaryAutoSave({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/${AcDataDictionaryAutoApiConfig.pathForSave}';

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the generated SAVE route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the endpoint, including a detailed request body schema that accepts either a single `row` object or a `rows` array for bulk save operations.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = 'Save ${acDDTable.tableName}';
    acApiDocRoute.description =
        'Auto generated data dictionary api to save row in table ${acDDTable.tableName}. Either single row or multiple rows can be saved at a time.';

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

    final requestBody = AcApiDocRequestBody();
    requestBody.addContent(content: content);
    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.save,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  /* AcDoc({
    "summary": "Creates the request handler function for the SAVE route.",
    "description": "This method returns an asynchronous closure that processes the incoming `AcWebRequest`. The handler inspects the request body for a `row` or `rows` key and calls the appropriate `saveRow` or `saveRows` 'upsert' method from the table service, returning the result as a JSON response.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Future<AcWebResponse> Function(AcWebRequest) getHandler() {
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final response = AcWebApiResponse();

      if (acWebRequest.post.containsKey('row')) {
        return response.setFromSqlDaoResult(result: await acSqlDbTable.saveRow(row: acWebRequest.post['row'])).toWebResponse();
      } else if (acWebRequest.post.containsKey('rows')) {
        return response.setFromSqlDaoResult(result: await acSqlDbTable.saveRows(rows: acWebRequest.post['rows'])).toWebResponse();
      } else {
        response.message = 'parameters missing';
        return AcWebResponse.json(data: response);
      }
    };
  }
}
