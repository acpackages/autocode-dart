import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';

class AcDataDictionaryAutoSave {
  final AcDDTable acDDTable;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  AcDataDictionaryAutoSave({
    required this.acDDTable,
    required this.acDataDictionaryAutoApi,
  }) {
    final apiUrl =
        '${acDataDictionaryAutoApi.urlPrefix}/${acDDTable.tableName}/${acDataDictionaryAutoApi.pathForSave}';

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

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
            'type': AcEnumApiDataType.OBJECT,
            'properties': {
              'row': schema,
              'rows': {'type': AcEnumApiDataType.ARRAY, 'items': schema},
            },
          };

    final requestBody = AcApiDocRequestBody();
    requestBody.addContent(content: content);
    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.SAVE,
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
          data: acSqlDbTable.saveRow(row: acWebRequest.body['row']),
        );
      } else if (acWebRequest.body.containsKey('rows')) {
        return AcWebResponse.json(
          data: acSqlDbTable.saveRows(rows: acWebRequest.body['rows']),
        );
      } else {
        response.message = 'parameters missing';
        return AcWebResponse.json(data: response);
      }
    };
  }
}
