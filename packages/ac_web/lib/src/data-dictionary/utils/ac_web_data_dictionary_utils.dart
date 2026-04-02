import '../../ac_web_internal.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';

import '../../../ac_web.dart';
import '../models/ac_data_dictionary_web_auto_execute_result.dart';

class AcWebDataDictionaryUtils {
  static String getTableNameForApiPath({required AcDDTable acDDTable}){
    String result = acDDTable.getPluralName();
    return result.toKebabCase();
  }

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoSelectWebRequest({
    required AcLogger logger,required AcWebRequest request,
    String tableName = "",String viewName = "", String dataDictionaryName = "default",
    String selectFrom = "",
    required AcBaseSqlDao dao,
  }) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try{
      logger.log("Getting rows for table $tableName using post method...");
      logger.log(["Request : ",request]);
        String fromName = "";
        if(tableName.isNotEmpty){
          AcDDTable? acDDTable = AcDataDictionary.getTable(tableName:tableName,dataDictionaryName: dataDictionaryName);
          if(acDDTable != null){
            fromName = acDDTable.getSelectQueryFromName();
          }
        }
        if(viewName.isNotEmpty){
          fromName = viewName;
        }
        final acDDSelectStatement = AcDDSelectStatement(
            tableName: tableName??'',
            viewName: viewName??'',
            logger: logger,
          dataDictionaryName: dataDictionaryName
        );
        if(selectFrom.isNotEmpty){
          acDDSelectStatement.selectFrom = selectFrom;
        }

        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey)) {
          logger.log("Found include columns key");
          acDDSelectStatement.includeColumns = List<String>.from(
            request.post[AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey],
          );
        }
        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey)) {
          logger.log("Found exclude columns key");
          acDDSelectStatement.excludeColumns = List<String>.from(
            request.post[AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey],
          );
        }
        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
          logger.log("Found select query key");
          List<String> queryColumns = List.empty(growable: true);
          if(acDDSelectStatement.tableName.isNotEmpty){
            var acDDTable = AcDataDictionary.getTable(
              tableName: acDDSelectStatement.tableName,
              dataDictionaryName: acDDSelectStatement.dataDictionaryName,
            );
            if(acDDTable!=null){
              queryColumns = acDDTable.getSearchQueryColumnNames();
            }
          }
          else if(acDDSelectStatement.viewName.isNotEmpty){
            var acDDView = AcDataDictionary.getView(
              viewName: acDDSelectStatement.viewName,
              dataDictionaryName: acDDSelectStatement.dataDictionaryName,
            );
            if(acDDView!=null){
              queryColumns = acDDView.getSearchQueryColumnNames();
            }
          }
          acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
          for (final columnName in queryColumns) {
            logger.log("Using column name for select query contains operation");
            acDDSelectStatement.addCondition(
              key: columnName,
              operator: AcEnumConditionOperator.contains,
              value: request.post[AcDataDictionaryAutoApiConfig.selectParameterQueryKey],
            );
          }
          acDDSelectStatement.endGroup();
        }
        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterFiltersKey)) {
          logger.log("Found filter key");
          final filters = request.post[AcDataDictionaryAutoApiConfig.selectParameterFiltersKey] as Map<String, dynamic>;
          acDDSelectStatement.setConditionsFromFilters(filters: filters);
        }

        bool allRows = false;

        if(request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterAllRows)){
          if(request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('yes') || request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('true')){
            allRows = true;
          }
        }

        if(acDDSelectStatement.tableName.isNotEmpty){
          var acDDTable = AcDataDictionary.getTable(
            tableName: acDDSelectStatement.tableName,
            dataDictionaryName: acDDSelectStatement.dataDictionaryName,
          );
          if(acDDTable!=null){
            for (var columnName in acDDTable.getColumnNames()) {
              logger.log('Checking request for column $columnName');
              if(request.post.containsKey(columnName)){
                acDDSelectStatement.conditionGroup.addCondition(key: columnName, operator: AcEnumConditionOperator.equalTo, value: request.post.get(columnName));
              }
            }
          }
        }
        else if(acDDSelectStatement.viewName.isNotEmpty){
          var acDDView = AcDataDictionary.getView(
            viewName: acDDSelectStatement.viewName,
            dataDictionaryName: acDDSelectStatement.dataDictionaryName,
          );
          if(acDDView!=null){
            for (var columnName in acDDView.getColumnNames()) {
              logger.log('Checking request for column $columnName');
              if(request.post.containsKey(columnName)){
                acDDSelectStatement.conditionGroup.addCondition(key: columnName, operator: AcEnumConditionOperator.equalTo, value: request.post.get(columnName));
              }
            }
          }
        }

        if(!allRows){
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)) {
            logger.log("Found page number key");
            acDDSelectStatement.pageNumber =
            request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] is int
                ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey]
                : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey].toString()) ??
                1;
          } else {
            acDDSelectStatement.pageNumber = 1;
          }
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)) {
            logger.log("Found page size key");
            acDDSelectStatement.pageSize =
            request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] is int
                ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey]
                : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey].toString()) ?? 50;
          } else {
            acDDSelectStatement.pageSize = 50;
          }
        }

        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterOrderByKey)) {
          logger.log("Found order by key");
          acDDSelectStatement.orderBy = request.post[AcDataDictionaryAutoApiConfig.selectParameterOrderByKey];
        }

        logger.log(["Getting response from database for sql statement",acDDSelectStatement]);
        AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dao: dao);
        final getResponse = await acSqlDbTable.getRowsFromAcDDStatement(
            acDDSelectStatement: acDDSelectStatement
        );
      result.selectStatement = acDDSelectStatement;
        logger.log(["Response : ",getResponse]);
        response.setFromSqlDaoResult(result: getResponse);
    }
    catch(ex,stack){
      response.setException(exception: ex,stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }
}