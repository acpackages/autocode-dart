import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
/* AcDoc({
  "summary": "Automatically generates a 'SELECT DISTINCT' API route for a specific table column.",
  "description": "This class is a route generator used by `AcDataDictionaryAutoApi`. Upon instantiation, it creates and registers a `GET` endpoint for fetching the unique values from a single column in a table. This is useful for populating dropdowns or autocomplete fields in a UI.",
  "example": "// This class is not typically used directly. It's instantiated by `AcDataDictionaryAutoApi`.\n// AcDataDictionaryAutoApi will execute this internally for a column marked for distinct select:\n// AcDataDictionaryAutoSelectDistinct(\n//   acDDTable: userTableDefinition,\n//   acDDTableColumn: statusColumnDefinition,\n//   acDataDictionaryAutoApi: apiGenerator,\n// );"
}) */
class AcDataDictionaryAutoSelectDistinct {
  /* AcDoc({"summary": "The data dictionary definition of the table containing the column."}) */
  final AcDDTable acDDTable;

  /* AcDoc({"summary": "The data dictionary definition of the column for which to get distinct values."}) */
  final AcDDTableColumn acDDTableColumn;

  /* AcDoc({"summary": "The main auto-API generator instance, providing configuration and the `AcWeb` server."}) */
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  /* AcDoc({
    "summary": "Creates and registers the SELECT DISTINCT route for a table column.",
    "description": "The constructor builds a unique API URL (e.g., /users/unique-status), creates the handler and its documentation, and registers the final `GET` route with the `AcWeb` instance.",
    "params": [
      {"name": "acDDTable", "description": "The definition of the table."},
      {"name": "acDDTableColumn", "description": "The definition of the column."},
      {"name": "acDataDictionaryAutoApi", "description": "The main API generator instance."}
    ]
  }) */
  AcDataDictionaryAutoSelectDistinct({
    required this.acDDTable,
    required this.acDDTableColumn,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/'
        '${acDDTable.tableName}/'
        '${acDataDictionaryAutoApi.pathForSelectDistinct}-'
        '${acDDTableColumn.columnName}';

    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the generated SELECT DISTINCT route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the endpoint, including query parameters for filtering and paginating the distinct values.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary =
        "Get ${acDDTable.tableName}'s ${acDDTableColumn.columnName}";
    acApiDocRoute.description =
        "Auto generated data dictionary api to get distinct values from column "
        "${acDDTableColumn.columnName} in table ${acDDTable.tableName}";

    final queryParameter =
        AcApiDocParameter()
          ..name = "query"
          ..description =
              "Filter values using like condition for column ${acDDTable.getPrimaryKeyColumnName()}"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: queryParameter);

    final pageParameter =
        AcApiDocParameter()
          ..name = "page_number"
          ..description = "Page number of rows"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: pageParameter);

    final countParameter =
        AcApiDocParameter()
          ..name = "rows_count"
          ..description = "Number of rows in each page"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: countParameter);

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.select,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );
    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  /* AcDoc({
    "summary": "Creates the request handler function for the SELECT DISTINCT route.",
    "description": "This method returns an asynchronous closure that processes the incoming `AcWebRequest`. The handler extracts any filtering and pagination parameters from the query string and calls the `getDistinctColumnValues` method from the table service.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Function getHandler() {
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final getResponse = await acSqlDbTable.getDistinctColumnValues(
        columnName: acDDTableColumn.columnName,
      );
      return AcWebResponse.json(data: getResponse.toJson());
    };
  }
}
