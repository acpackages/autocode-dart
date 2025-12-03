import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Automatically generates 'SELECT' (read) API routes for a specific table.",
  "description": "This class is a route generator used by `AcDataDictionaryAutoApi`. Upon instantiation, it creates and registers three distinct `SELECT` endpoints with the `AcWeb` server:\n1. `GET /<table>/get`: A flexible endpoint to list records with filtering via query parameters.\n2. `GET /<table>/get/{id}`: An endpoint to fetch a single record by its primary key.\n3. `POST /<table>/get`: A powerful endpoint to perform complex queries using a JSON request body.",
  "example": "// This class is not typically used directly. It's instantiated by `AcDataDictionaryAutoApi`.\n// AcDataDictionaryAutoApi will execute this internally for a table:\n// AcDataDictionaryAutoSelect(\n//   acDDTable: userTableDefinition,\n//   acDataDictionaryAutoApi: apiGenerator,\n// );"
}) */
class AcDataDictionaryAutoSelect {
  /* AcDoc({"summary": "The data dictionary definition of the table for which the routes are being generated."}) */
  final AcDDTable acDDTable;

  /* AcDoc({"summary": "The main auto-API generator instance, providing configuration and the `AcWeb` server."}) */
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  bool includeSelectRow = true;

  /* AcDoc({
    "summary": "Creates and registers the SELECT routes for a table.",
    "description": "The constructor immediately builds and registers three distinct endpoints for querying the table: a general GET for lists, a specific GET for fetching by primary key, and a POST for advanced searches.",
    "params": [
      {"name": "acDDTable", "description": "The definition of the table."},
      {"name": "acDataDictionaryAutoApi", "description": "The main API generator instance."}
    ]
  }) */
  AcDataDictionaryAutoSelect({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
    this.includeSelectRow = true

  }) {
    final apiUrl1 =
        '${acDataDictionaryAutoApi.urlPrefix}/${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/${AcDataDictionaryAutoApiConfig.pathForSelect}';
    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl1,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );

    if(includeSelectRow){
      final apiUrl2 =
          '${acDataDictionaryAutoApi.urlPrefix}/${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/${AcDataDictionaryAutoApiConfig.pathForSelect}/{${acDDTable.getPrimaryKeyColumnName()}}';
      acDataDictionaryAutoApi.acWeb.get(
        url: apiUrl2,
        handler: getByIdHandler(),
        acApiDocRoute: getByIdAcApiDocRoute(),
      );
    }


    final apiUrl3 =
        '${acDataDictionaryAutoApi.urlPrefix}/${AcWebDataDictionaryUtils.getTableNameForApiPath(acDDTable:acDDTable)}/${AcDataDictionaryAutoApiConfig.pathForSelect}';
    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl3,
      handler: postHandler(),
      acApiDocRoute: postAcApiDocRoute(),
    );
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the general GET (list) route.",
    "description": "This method creates an `AcApiDocRoute` object that describes the list endpoint, documenting all possible query parameters for searching, filtering, sorting, and pagination.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = "Get ${acDDTable.tableName}";
    acApiDocRoute.description =
        "Auto generated data dictionary api to get rows in table ${acDDTable.tableName}";

    final queryColumns = acDDTable.getSearchQueryColumnNames();
    if (queryColumns.isNotEmpty) {
      final queryParameter = AcApiDocParameter();
      queryParameter.name = AcDataDictionaryAutoApiConfig.selectParameterQueryKey;
      queryParameter.description =
          "Filter values using like condition for columns (${queryColumns.join(",")})";
      queryParameter.required = false;
      queryParameter.in_ = "query";
      acApiDocRoute.addParameter(parameter: queryParameter);
    }

    final pageParameter =
        AcApiDocParameter()
          ..name = AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey
          ..description = "Page number of rows"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: pageParameter);

    final countParameter =
        AcApiDocParameter()
          ..name = AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey
          ..description = "Number of rows in each page"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: countParameter);

    final orderParameter =
        AcApiDocParameter()
          ..name =AcDataDictionaryAutoApiConfig.selectParameterOrderByKey
          ..description = "Order by value for rows"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: orderParameter);

    for (final column in acDDTable.tableColumns) {
      final requestParameter =
          AcApiDocParameter()
            ..name = column.columnName
            ..description = "Filter values in column ${column.columnName}"
            ..required = false
            ..in_ = "query";
      acApiDocRoute.addParameter(parameter: requestParameter);
    }

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
    "summary": "Creates the request handler for the general GET (list) route.",
    "description": "This method returns an asynchronous closure that processes the incoming `AcWebRequest`. The handler dynamically builds a SQL query using `AcDDSelectStatement` based on the provided query parameters and returns the result.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Function getHandler() {
    return (AcWebRequest acWebRequest, AcLogger logger) async {
      final response = AcWebApiResponse();
      try{
        final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
        final acDDSelectStatement = AcDDSelectStatement(
          tableName: acDDTable.getSelectQueryFromName(),
        );

        if (acWebRequest.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
          final queryColumns = acDDTable.getSearchQueryColumnNames();
          acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
          for (final columnName in queryColumns) {
            acDDSelectStatement.addCondition(
              key: columnName,
              operator: AcEnumConditionOperator.contains,
              value: acWebRequest.get[AcDataDictionaryAutoApiConfig.selectParameterQueryKey],
            );
          }
          acDDSelectStatement.endGroup();
        }

        for (final col in acDDTable.tableColumns) {
          if (acWebRequest.get.containsKey(col.columnName)) {
            acDDSelectStatement.addCondition(
              key: col.columnName,
              operator: AcEnumConditionOperator.contains,
              value: acWebRequest.get[col.columnName],
            );
          }
        }

        acDDSelectStatement.pageNumber =
            acWebRequest.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)
                ? int.tryParse(acWebRequest.get[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] ?? '') ?? 1
                : 1;
        acDDSelectStatement.pageSize =
            acWebRequest.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)
                ? int.tryParse(acWebRequest.get[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] ?? '') ?? 50
                : 50;
        if (acWebRequest.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterOrderByKey)) {
          acDDSelectStatement.orderBy = acWebRequest.get[AcDataDictionaryAutoApiConfig.selectParameterOrderByKey];
        }

        final getResponse = await acSqlDbTable.getRowsFromAcDDStatement(
          acDDSelectStatement: acDDSelectStatement
        );

        response.setFromSqlDaoResult(result: getResponse);
      }
      catch(ex,stack){
        response.setException(exception: ex,stackTrace: stack);
      }
      return response.toWebResponse();
    };
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the GET by ID route.",
    "description": "This method creates an `AcApiDocRoute` object describing the endpoint for fetching a single record, including the required primary key as a path parameter.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute getByIdAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = "Get single ${acDDTable.tableName}";
    acApiDocRoute.description =
        "Auto generated data dictionary api to get single row matching column value ${acDDTable.getPrimaryKeyColumnName()} in table ${acDDTable.tableName}";

    final parameter =
        AcApiDocParameter()
          ..name = acDDTable.getPrimaryKeyColumnName()
          ..description =
              "${acDDTable.getPrimaryKeyColumnName()} value of row to get"
          ..required = true
          ..in_ = "path";

    acApiDocRoute.addParameter(parameter: parameter);

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
    "summary": "Creates the request handler for the GET by ID route.",
    "description": "This method returns an asynchronous closure that processes the `AcWebRequest`. The handler extracts the primary key from the URL path and queries for that single record.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Function getByIdHandler() {
    return (AcWebRequest acWebRequest, AcLogger logger) async{
      final response = AcWebApiResponse();
      try{
        final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);

        final pkName = acDDTable.getPrimaryKeyColumnName();
        final primaryKeyValue = acWebRequest.pathParameters[pkName];

        final getResponse = await acSqlDbTable.getRows(
          condition: '$pkName = @primaryKeyValue',
          parameters: {'@primaryKeyValue': primaryKeyValue},
        );

        response.setFromSqlDaoResult(result: getResponse);
      }
      catch(ex,stack){
        response.setException(exception: ex,stackTrace: stack);
      }
      return response.toWebResponse();
    };
  }

  /* AcDoc({
    "summary": "Builds the OpenAPI documentation for the POST (advanced search) route.",
    "description": "This method creates an `AcApiDocRoute` object describing the endpoint for complex queries, detailing the JSON request body structure for filters, column selection, ordering, and pagination.",
    "returns": "A configured `AcApiDocRoute` object for documentation.",
    "returns_type": "AcApiDocRoute"
  }) */
  AcApiDocRoute postAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag: acDDTable.tableName);
    acApiDocRoute.summary = "Get ${acDDTable.tableName}";
    acApiDocRoute.description =
        "Auto generated data dictionary api to get rows in table ${acDDTable.tableName}";

    final queryColumns = acDDTable.getSearchQueryColumnNames();

    final properties = <String, dynamic>{
      AcDataDictionaryAutoApiConfig.selectParameterQueryKey: {"type": AcEnumApiDataType.string},
      AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey: {"type": AcEnumApiDataType.integer},
      AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey: {"type": AcEnumApiDataType.integer},
      AcDataDictionaryAutoApiConfig.selectParameterOrderByKey: {"type": AcEnumApiDataType.string},
      AcDataDictionaryAutoApiConfig.selectParameterFiltersKey: {"type": AcEnumApiDataType.object},
      AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey : {
        "type": AcEnumApiDataType.array,
        "items": {"type": AcEnumApiDataType.string},
      },
      AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey: {
        "type": AcEnumApiDataType.array,
        "items": {"type": AcEnumApiDataType.string},
      },
    };

    if (queryColumns.isEmpty) {
      properties.remove(AcDataDictionaryAutoApiConfig.selectParameterQueryKey);
    }

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
    "summary": "Creates the request handler for the POST (advanced search) route.",
    "description": "This method returns an asynchronous closure that processes the `AcWebRequest`. The handler parses the JSON request body, builds an `AcDDSelectStatement` from its properties, and executes the complex query.",
    "returns": "The request handler function.",
    "returns_type": "Future<AcWebResponse> Function(AcWebRequest)"
  }) */
  Function postHandler() {
    return (AcWebRequest acWebRequest, AcLogger logger) async {
      final response = AcWebApiResponse();
      try{
        logger.log("Getting rows for table ${acDDTable.tableName} using post method...");
        logger.log(["Request : ",acWebRequest]);
        final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
        final String fromName = acDDTable.getSelectQueryFromName();
        final acDDSelectStatement = AcDDSelectStatement(
          tableName: acDDTable.tableName == fromName?fromName:'',
          viewName: acDDTable.tableName != fromName?fromName:'',
          logger: logger
        );

        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey)) {
          logger.log("Found include columns key");
          acDDSelectStatement.includeColumns = List<String>.from(
            acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey],
          );
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey)) {
          logger.log("Found exclude columns key");
          acDDSelectStatement.excludeColumns = List<String>.from(
            acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey],
          );
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
          logger.log("Found select query key");
          final queryColumns = acDDTable.getSearchQueryColumnNames();
          acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
          for (final columnName in queryColumns) {
            logger.log("Using column name for select query contains operation");
            acDDSelectStatement.addCondition(
              key: columnName,
              operator: AcEnumConditionOperator.contains,
              value: acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterQueryKey],
            );
          }
          acDDSelectStatement.endGroup();
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterFiltersKey)) {
          logger.log("Found filter key");
          final filters = acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterFiltersKey] as Map<String, dynamic>;
          acDDSelectStatement.setConditionsFromFilters(filters: filters);
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)) {
          logger.log("Found page number key");
          acDDSelectStatement.pageNumber =
              acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] is int
                  ? acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey]
                  : int.tryParse(acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey].toString()) ??
                      1;
        } else {
          acDDSelectStatement.pageNumber = 1;
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)) {
          logger.log("Found page size key");
          acDDSelectStatement.pageSize =
              acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] is int
                  ? acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey]
                  : int.tryParse(acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey].toString()) ?? 50;
        } else {
          acDDSelectStatement.pageSize = 50;
        }
        if (acWebRequest.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterOrderByKey)) {
          logger.log("Found order by key");
          acDDSelectStatement.orderBy = acWebRequest.post[AcDataDictionaryAutoApiConfig.selectParameterOrderByKey];
        }

        logger.log(["Getting response from database for sql statement",acDDSelectStatement]);
        final getResponse = await acSqlDbTable.getRowsFromAcDDStatement(
            acDDSelectStatement: acDDSelectStatement
        );
        logger.log(["Response : ",getResponse]);

        response.setFromSqlDaoResult(result: getResponse);
      }
      catch(ex,stack){
        response.setException(exception: ex,stackTrace: stack);
      }
      return response.toWebResponse();
    };
  }
}
