import '../../ac_web_internal.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import '../../models/ac_web_request.dart';
import '../../models/ac_web_response.dart';
import '../../models/ac_web_request_handler_args.dart';
import '../../models/ac_web_api_response.dart';
import '../../api-docs/models/ac_api_doc_route.dart';
import '../../api-docs/models/ac_api_doc_parameter.dart';
import '../../api-docs/models/ac_api_doc_request_body.dart';
import '../../api-docs/models/ac_api_doc_media_type.dart';
import '../../api-docs/utils/ac_api_doc_utils.dart';
import '../utils/ac_web_data_dictionary_utils.dart';
import './ac_data_dictionary_auto_api_config.dart';
import './ac_data_dictionary_auto_api.dart';
import '../../api-docs/enums/ac_enum_api_data_type.dart';

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
    final apiUrl = '${acDataDictionaryAutoApi.urlPrefix}/${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/${AcDataDictionaryAutoApiConfig.pathForDelete}';
    acDataDictionaryAutoApi.acWeb.delete(
      url: "$apiUrl/{${acDDTable.getPrimaryKeyColumnName()}}",
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getPostHandler(),
      acApiDocRoute: getAcApPostDocRoute(),
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
  Future<AcWebResponse> Function(AcWebRequestHandlerArgs args) getHandler() {
    return (AcWebRequestHandlerArgs args) async {
      AcWebRequest acWebRequest = args.request;
      final response = AcWebApiResponse();
      final key = acDDTable.getPrimaryKeyColumnName();
      if (acWebRequest.pathParameters.containsKey(key)) {
        AcResult sqlDbTableResult = await acDataDictionaryAutoApi.getAcSqlDbTable(request:acWebRequest,acDDTable: acDDTable);
        if(sqlDbTableResult.isSuccess()){
          AcSqlDbTable acSqlDbTable = sqlDbTableResult.value;
          response.setFromSqlDaoResult(result: await acSqlDbTable.deleteRows(
            primaryKeyValue: acWebRequest.pathParameters[key],
          ));
        }
        else{
          response.setFromResult(result: sqlDbTableResult);
        }
        return response.toWebResponse();
      } else {
        response.message = 'parameters missing';
        return AcWebResponse.json(data: response);
      }
    };
  }


  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the generated DELETE route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the endpoint, including its summary, path parameters, and standard success and error responses.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApPostDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = "Delete row in ${acDDTable.tableName}";
    acApiDocRoute.description = "Auto generated data dictionary api to delete row in table ${acDDTable.tableName}";

    final properties = <String, dynamic>{
      acDDTable.getPrimaryKeyColumnName() : {"type": AcEnumApiDataType.string}
    };
    final content =
    AcApiDocContent()
      ..encoding = "application/json"
      ..schema = {
        "type": AcEnumApiDataType.object,
        "properties": properties,
      };

    final requestBody = AcApiDocRequestBody();
    requestBody.addContent(content: content);

    acApiDocRoute.requestBody = requestBody;

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
  Function(AcWebRequestHandlerArgs args) getPostHandler() {
    return (AcWebRequestHandlerArgs args) async {
      AcLogger logger = args.logger;
      AcWebRequest acWebRequest = args.request;
      final response = AcWebApiResponse();
      try{
        logger.log("Deleting row from table ${acDDTable.tableName}");
        final key = acDDTable.getPrimaryKeyColumnName();
        logger.log("Deleting for primary key field ${key}");
        if (acWebRequest.post.containsKey(key)) {
          logger.log("Found primary key field ${key}");
          AcResult sqlDbTableResult = await acDataDictionaryAutoApi.getAcSqlDbTable(request:acWebRequest,acDDTable: acDDTable);
          if(sqlDbTableResult.isSuccess()){
            AcSqlDbTable acSqlDbTable = sqlDbTableResult.value;
            response.setFromSqlDaoResult(result: await acSqlDbTable.deleteRows(
              primaryKeyValue: acWebRequest.post[key],
            )).toWebResponse();
          }
          else{
            response.setFromResult(result: sqlDbTableResult);
          }
          return response.toWebResponse();
        } else {
          logger.log(["Primary key field is missing in post",acWebRequest.post]);
          response.message = 'parameters missing';
        }
      }
      catch(ex,stack){
        response.setException(exception: ex,stackTrace: stack);
      }
      return AcWebResponse.json(data: response);
    };
  }
}
