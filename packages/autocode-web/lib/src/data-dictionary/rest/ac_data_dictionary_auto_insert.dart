import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoInsert {
  final AcDDTable acDDTable;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  AcDataDictionaryAutoInsert({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForInsert}';

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = 'Insert ${acDDTable.tableName}';
    acApiDocRoute.description =
    'Auto generated data dictionary api to insert row in table ${acDDTable.tableName}. Either single row or multiple rows can be added at a time.';

    final schema = AcApiDocUtils.getApiModelRefFromAcDDTable(
      acDDTable: acDDTable,
      acApiDoc: acDataDictionaryAutoApi.acWeb.acApiDoc,
    );

    final content = AcApiDocContent()
      ..encoding = 'application/json'
      ..schema = {
        'type': AcEnumApiDataType.OBJECT,
        'properties': {
          'row': schema,
          'rows': {
            'type': AcEnumApiDataType.ARRAY,
            'items': schema,
          }
        }
      };

    final requestBody = AcApiDocRequestBody();
    requestBody.addContent(content: content);
    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.INSERT,
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
      final acSqlDbTable = AcSqlDbTable(tableName: acDDTable.tableName);
      final response = AcResult();

      if (acWebRequest.body.containsKey('row')) {
        return AcWebResponse.json(
          data: acSqlDbTable.insertRow(row: acWebRequest.body['row']),
        );
      } else if (acWebRequest.body.containsKey('rows')) {
        return AcWebResponse.json(
          data: acSqlDbTable.insertRows(rows: acWebRequest.body['rows']),
        );
      } else {
        response.message = 'parameters missing';
        return AcWebResponse.json(data: response);
      }
    };
  }
}
