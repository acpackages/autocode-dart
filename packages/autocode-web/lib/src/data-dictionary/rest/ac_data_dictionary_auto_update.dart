import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_sql/autocode_sql.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoUpdate {
  final AcDDTable acDDTable;
  final AcDataDictionaryAutoApi acDataDictionaryAutoApi;

  AcDataDictionaryAutoUpdate({required this.acDDTable,required this.acDataDictionaryAutoApi}) {
    final apiUrl = '${acDataDictionaryAutoApi.urlPrefix}/'
        '${acDDTable.tableName}/'
        '${acDataDictionaryAutoApi.pathForUpdate}';

    acDataDictionaryAutoApi.acWeb.post(
      url: apiUrl,
      handler: getHandler(),
      acApiDocRoute: getAcApiDocRoute(),
    );
  }

  AcApiDocRoute getAcApiDocRoute() {
    final acApiDocRoute = AcApiDocRoute();
    acApiDocRoute.addTag(tag:acDDTable.tableName);
    acApiDocRoute.summary = 'Update ${acDDTable.tableName}';
    acApiDocRoute.description =
    'Auto generated data dictionary api to update row in table ${acDDTable.tableName}. '
        'Either single row or multiple rows can be updated at a time.';

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
          },
        },
      };

    final requestBody = AcApiDocRequestBody()..addContent(content: content);
    acApiDocRoute.requestBody = requestBody;

    final responses = AcApiDocUtils.getApiDocRouteResponsesForOperation(
      operation: AcEnumDDRowOperation.UPDATE,
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
      var response = AcResult();

      final body = acWebRequest.body;

      if (body.containsKey('row')) {
        response = await acSqlDbTable.updateRow(row: body['row']);
      } else if (body.containsKey('rows')) {
        response = await acSqlDbTable.updateRows(rows: body['rows']);
      } else {
        response.message = 'parameters missing';
      }

      return AcWebResponse.json(data: response);
    };
  }
}
