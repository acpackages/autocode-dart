import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoSelect {
  final AcDDTable acDDTable;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  AcDataDictionaryAutoSelect({required this.acDDTable,required this.acDataDictionaryAutoApi}) {
    final apiUrl1 = '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}';
    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl1,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );

    final apiUrl2 = '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}/{${acDDTable.getPrimaryKeyColumnName()}}';
    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl2,
      handler: getByIdHandler(),
      acApiDocRoute: getByIdAcApiDocRoute(),
    );

    final apiUrl3 = '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSelect}';
    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl3,
      handler: postHandler(),
      acApiDocRoute: postAcApiDocRoute(),
    );
  }

  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = "Get ${acDDTable.tableName}";
    acApiDocRoute.description = "Auto generated data dictionary api to get rows in table ${acDDTable.tableName}";

    final queryColumns = acDDTable.getSearchQueryColumnNames();
    if (queryColumns.isNotEmpty) {
      final queryParameter = AcApiDocParameter();
      queryParameter.name = "query";
      queryParameter.description = "Filter values using like condition for columns (${queryColumns.join(",")})";
      queryParameter.required = false;
      queryParameter.inValue = "query";
      acApiDocRoute.addParameter(parameter: queryParameter);
    }

    final pageParameter = AcApiDocParameter()
      ..name = "page_number"
      ..description = "Page number of rows"
      ..required = false
      ..inValue= "query";
    acApiDocRoute.addParameter(parameter: pageParameter);

    final countParameter = AcApiDocParameter()
      ..name = "page_size"
      ..description = "Number of rows in each page"
      ..required = false
      ..inValue= "query";
    acApiDocRoute.addParameter(parameter: countParameter);

    final orderParameter = AcApiDocParameter()
      ..name = "order_by"
      ..description = "Order by value for rows"
      ..required = false
      ..inValue = "query";
    acApiDocRoute.addParameter(parameter: orderParameter);

    for (final column in acDDTable.tableColumns) {
      final requestParameter = AcApiDocParameter()
        ..name = column.columnName
        ..description = "Filter values in column ${column.columnName}"
        ..required = false
        ..inValue = "query";
      acApiDocRoute.addParameter(parameter: requestParameter);
    }

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.SELECT,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );
    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  Function getHandler() {
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final acDDSelectStatement = AcDDSelectStatement(tableName: acDDTable.tableName);

      if (acWebRequest.get.containsKey("query")) {
        final queryColumns = acDDTable.getSearchQueryColumnNames();
        acDDSelectStatement.startGroup(operator: AcEnumDDLogicalOperator.OR);
        for (final columnName in queryColumns) {
          acDDSelectStatement.addCondition(
            columnName: columnName,
            operator: AcEnumDDConditionOperator.LIKE,
            value: acWebRequest.get["query"],
          );
        }
        acDDSelectStatement.endGroup();
      }

      for (final col in acDDTable.tableColumns) {
        if (acWebRequest.get.containsKey(col.columnName)) {
          acDDSelectStatement.addCondition(
            columnName: col.columnName,
            operator: AcEnumDDConditionOperator.LIKE,
            value: acWebRequest.get[col.columnName],
          );
        }
      }

      acDDSelectStatement.pageNumber = acWebRequest.get.containsKey("page_number")
          ? int.tryParse(acWebRequest.get["page_number"] ?? '') ?? 1
          : 1;
      acDDSelectStatement.pageSize = acWebRequest.get.containsKey("page_size")
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

  AcApiDocRoute getByIdAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = "Get single ${acDDTable.tableName}";
    acApiDocRoute.description = "Auto generated data dictionary api to get single row matching column value ${acDDTable.getPrimaryKeyColumnName()} in table ${acDDTable.tableName}";

    final parameter = AcApiDocParameter()
      ..name = acDDTable.getPrimaryKeyColumnName()
      ..description = "${acDDTable.getPrimaryKeyColumnName()} value of row to get"
      ..required = true
      ..inValue = "path";

    acApiDocRoute.addParameter(parameter: parameter);

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.SELECT,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  Function getByIdHandler() {
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);

      final pkName = acDDTable.getPrimaryKeyColumnName();
      final primaryKeyValue = acWebRequest.pathParameters[pkName];

      final getResponse = await acSqlDbTable.getRows(
        condition: '$pkName = @primaryKeyValue',
        parameters: {'@primaryKeyValue': primaryKeyValue},
      );

      return AcWebResponse.json(data:getResponse.toJson());
    };
  }

  AcApiDocRoute postAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = "Get ${acDDTable.tableName}";
    acApiDocRoute.description = "Auto generated data dictionary api to get rows in table ${acDDTable.tableName}";

    final queryColumns = acDDTable.getSearchQueryColumnNames();

    final properties = <String, dynamic>{
      "query": {"type": AcEnumApiDataType.STRING},
      "page_number": {"type": AcEnumApiDataType.INTEGER},
      "page_size": {"type": AcEnumApiDataType.INTEGER},
      "order_by": {"type": AcEnumApiDataType.STRING},
      "filters": {"type": AcEnumApiDataType.OBJECT},
      "include_columns": {
        "type": AcEnumApiDataType.ARRAY,
        "items": {"type": AcEnumApiDataType.STRING}
      },
      "exclude_columns": {
        "type": AcEnumApiDataType.ARRAY,
        "items": {"type": AcEnumApiDataType.STRING}
      },
    };

    if (queryColumns.isEmpty) {
      properties.remove("query");
    }

    final content = AcApiDocContent()
      ..encoding = "application/json"
      ..schema = {
        "type": AcEnumApiDataType.OBJECT,
        "properties": properties,
      };

    final requestBody = AcApiDocRequestBody();
    requestBody.addContent(content: content);

    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.SELECT,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

  Function postHandler() {
    return (AcWebRequest acWebRequest) async {
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final acDDSelectStatement = AcDDSelectStatement(tableName: acDDTable.tableName);

      if (acWebRequest.body.containsKey("include_columns")) {
        acDDSelectStatement.includeColumns = List<String>.from(acWebRequest.body["include_columns"]);
      }
      if (acWebRequest.body.containsKey("exclude_columns")) {
        acDDSelectStatement.excludeColumns = List<String>.from(acWebRequest.body["exclude_columns"]);
      }
      if (acWebRequest.body.containsKey("query")) {
        final queryColumns = acDDTable.getSearchQueryColumnNames();
        acDDSelectStatement.startGroup(operator: AcEnumDDLogicalOperator.OR);
        for (final columnName in queryColumns) {
          acDDSelectStatement.addCondition(
            columnName: columnName,
            operator: AcEnumDDConditionOperator.LIKE,
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
            operator: AcEnumDDConditionOperator.EQUAL_TO,
            value: value,
          );
        }
      }
      if ( acWebRequest.body.containsKey("page_number")) {
        acDDSelectStatement.pageNumber = acWebRequest.body["page_number"] is int
            ? acWebRequest.body["page_number"]
            : int.tryParse(acWebRequest.body["page_number"].toString()) ?? 1;
      } else {
        acDDSelectStatement.pageNumber = 1;
      }
      if (acWebRequest.body.containsKey("page_size")) {
        acDDSelectStatement.pageSize = acWebRequest.body["page_size"] is int
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

      return AcWebResponse.json(data:getResponse.toJson());
    };
  }
}
