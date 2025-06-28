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
  }) {
    final apiUrl1 =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}';
    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl1,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );

    final apiUrl2 =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}/{${acDDTable.getPrimaryKeyColumnName()}}';
    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl2,
      handler: getByIdHandler(),
      acApiDocRoute: getByIdAcApiDocRoute(),
    );

    final apiUrl3 =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}';
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
      queryParameter.name = "query";
      queryParameter.description =
          "Filter values using like condition for columns (${queryColumns.join(",")})";
      queryParameter.required = false;
      queryParameter.in_ = "query";
      acApiDocRoute.addParameter(parameter: queryParameter);
    }

    final pageParameter =
        AcApiDocParameter()
          ..name = "page_number"
          ..description = "Page number of rows"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: pageParameter);

    final countParameter =
        AcApiDocParameter()
          ..name = "page_size"
          ..description = "Number of rows in each page"
          ..required = false
          ..in_ = "query";
    acApiDocRoute.addParameter(parameter: countParameter);

    final orderParameter =
        AcApiDocParameter()
          ..name = "order_by"
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
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final acDDSelectStatement = AcDDSelectStatement(
        tableName: acDDTable.tableName,
      );

      if (acWebRequest.get.containsKey("query")) {
        final queryColumns = acDDTable.getSearchQueryColumnNames();
        acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
        for (final columnName in queryColumns) {
          acDDSelectStatement.addCondition(
            columnName: columnName,
            operator: AcEnumConditionOperator.contains,
            value: acWebRequest.get["query"],
          );
        }
        acDDSelectStatement.endGroup();
      }

      for (final col in acDDTable.tableColumns) {
        if (acWebRequest.get.containsKey(col.columnName)) {
          acDDSelectStatement.addCondition(
            columnName: col.columnName,
            operator: AcEnumConditionOperator.contains,
            value: acWebRequest.get[col.columnName],
          );
        }
      }

      acDDSelectStatement.pageNumber =
          acWebRequest.get.containsKey("page_number")
              ? int.tryParse(acWebRequest.get["page_number"] ?? '') ?? 1
              : 1;
      acDDSelectStatement.pageSize =
          acWebRequest.get.containsKey("page_size")
              ? int.tryParse(acWebRequest.get["page_size"] ?? '') ?? 50
              : 50;
      if (acWebRequest.get.containsKey("order_by")) {
        acDDSelectStatement.orderBy = acWebRequest.get["order_by"];
      }

      final sqlStatement = acDDSelectStatement.getSqlStatement();
      final sqlParameters = acDDSelectStatement.parameters;

      final getResponse = await acSqlDbTable.getRows(
        selectStatement: sqlStatement,
        parameters: sqlParameters,
      );

      return AcWebResponse.json(data: getResponse.toJson());
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
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);

      final pkName = acDDTable.getPrimaryKeyColumnName();
      final primaryKeyValue = acWebRequest.pathParameters[pkName];

      final getResponse = await acSqlDbTable.getRows(
        condition: '$pkName = @primaryKeyValue',
        parameters: {'@primaryKeyValue': primaryKeyValue},
      );

      return AcWebResponse.json(data: getResponse.toJson());
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
      "query": {"type": AcEnumApiDataType.string},
      "page_number": {"type": AcEnumApiDataType.integer},
      "page_size": {"type": AcEnumApiDataType.integer},
      "order_by": {"type": AcEnumApiDataType.string},
      "filters": {"type": AcEnumApiDataType.object},
      "include_columns": {
        "type": AcEnumApiDataType.array,
        "items": {"type": AcEnumApiDataType.string},
      },
      "exclude_columns": {
        "type": AcEnumApiDataType.array,
        "items": {"type": AcEnumApiDataType.string},
      },
    };

    if (queryColumns.isEmpty) {
      properties.remove("query");
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
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final acDDSelectStatement = AcDDSelectStatement(
        tableName: acDDTable.tableName,
      );

      if (acWebRequest.body.containsKey("include_columns")) {
        acDDSelectStatement.includeColumns = List<String>.from(
          acWebRequest.body["include_columns"],
        );
      }
      if (acWebRequest.body.containsKey("exclude_columns")) {
        acDDSelectStatement.excludeColumns = List<String>.from(
          acWebRequest.body["exclude_columns"],
        );
      }
      if (acWebRequest.body.containsKey("query")) {
        final queryColumns = acDDTable.getSearchQueryColumnNames();
        acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
        for (final columnName in queryColumns) {
          acDDSelectStatement.addCondition(
            columnName: columnName,
            operator: AcEnumConditionOperator.contains,
            value: acWebRequest.body["query"],
          );
        }
        acDDSelectStatement.endGroup();
      }
      if (acWebRequest.body.containsKey("filters")) {
        final filters = acWebRequest.body["filters"] as Map<String, dynamic>;
        for (final entry in filters.entries) {
          final columnName = entry.key;
          final value = entry.value;
          acDDSelectStatement.addCondition(
            columnName: columnName,
            operator: AcEnumConditionOperator.equalTo,
            value: value,
          );
        }
      }
      if (acWebRequest.body.containsKey("page_number")) {
        acDDSelectStatement.pageNumber =
            acWebRequest.body["page_number"] is int
                ? acWebRequest.body["page_number"]
                : int.tryParse(acWebRequest.body["page_number"].toString()) ??
                    1;
      } else {
        acDDSelectStatement.pageNumber = 1;
      }
      if (acWebRequest.body.containsKey("page_size")) {
        acDDSelectStatement.pageSize =
            acWebRequest.body["page_size"] is int
                ? acWebRequest.body["page_size"]
                : int.tryParse(acWebRequest.body["page_size"].toString()) ?? 50;
      } else {
        acDDSelectStatement.pageSize = 50;
      }
      if (acWebRequest.body.containsKey("order_by")) {
        acDDSelectStatement.orderBy = acWebRequest.body["order_by"];
      }

      final sqlStatement = acDDSelectStatement.getSqlStatement();
      final sqlParameters = acDDSelectStatement.parameters;

      final getResponse = await acSqlDbTable.getRows(
        selectStatement: sqlStatement,
        parameters: sqlParameters,
      );

      return AcWebResponse.json(data: getResponse.toJson());
    };
  }
}
