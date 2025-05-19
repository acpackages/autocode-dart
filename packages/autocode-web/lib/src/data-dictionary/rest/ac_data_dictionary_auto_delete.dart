import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoDelete {
  final AcDDTable acDDTable;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

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

  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = 'Delete ${acDDTable.tableName}';
    acApiDocRoute.description =
    'Auto generated data dictionary api to delete row in table ${acDDTable.tableName}';

    final parameter = AcApiDocParameter()
      ..name = acDDTable.getPrimaryKeyColumnName()
      ..description =
          '${acDDTable.getPrimaryKeyColumnName()} value of row to delete'
      ..required = true
      ..inValue = 'path';

    acApiDocRoute.addParameter(parameter:parameter);

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.DELETE,
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    for (final response in responses) {
      acApiDocRoute.addResponse(response: response);
    }

    return acApiDocRoute;
  }

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
