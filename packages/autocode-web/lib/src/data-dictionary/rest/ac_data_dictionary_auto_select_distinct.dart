import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoSelectDistinct {
  final AcDDTable acDDTable;
  final AcDDTableColumn acDDTableColumn;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  AcDataDictionaryAutoSelectDistinct({required this.acDDTable, required this.acDDTableColumn, required this.acDataDictionaryAutoApi}) {
    final apiUrl = '${acDataDictionaryAutoApi.urlPrefix}/'
        '${acDDTable.tableName}/'
        '${acDataDictionaryAutoApi.pathForSelectDistinct}-'
        '${acDDTableColumn.columnName}';

    acDataDictionaryAutoApi.acWeb.get(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = "Get ${acDDTable.tableName}'s ${acDDTableColumn.columnName}";
    acApiDocRoute.description =
    "Auto generated data dictionary api to get distinct values from column "
        "${acDDTableColumn.columnName} in table ${acDDTable.tableName}";

    final queryParameter = AcApiDocParameter()
      ..name = "query"
      ..description = "Filter values using like condition for column ${acDDTable.getPrimaryKeyColumnName()}"
      ..required = false
      ..inValue = "query";
    acApiDocRoute.addParameter(parameter: queryParameter);

    final pageParameter = AcApiDocParameter()
      ..name = "page_number"
      ..description = "Page number of rows"
      ..required = false
      ..inValue = "query";
    acApiDocRoute.addParameter(parameter: pageParameter);

    final countParameter = AcApiDocParameter()
      ..name = "rows_count"
      ..description = "Number of rows in each page"
      ..required = false
      ..inValue = "query";
    acApiDocRoute.addParameter(parameter: countParameter);

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
      final getResponse = await acSqlDbTable.getDistinctColumnValues(columnName: acDDTableColumn.columnName);
      return AcWebResponse.json(data: getResponse.toJson());
    };
  }
}
