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

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoDeleteWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String dataDictionaryName = "default",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      if(acDDTable!=null){
        final key = acDDTable.getPrimaryKeyColumnName();
        logger.log("Deleting for primary key field $key");
        if (request.post.containsKey(key)) {
          logger.log("Found primary key field $key");
          AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dataDictionaryName: dataDictionaryName,dao: dao);
          response.setFromSqlDaoResult(result: await acSqlDbTable.deleteRows(
            primaryKeyValue: request.post[key],
          )).toWebResponse();
        } else {
          logger.log(["Primary key field is missing in post",request.post]);
          response.message = 'parameters missing';
        }
      }
      else{
        response.setFailure(message: "$tableName does not exist in $dataDictionaryName data dictionary");
      }
    }
    catch (ex, stack) {
      response.setException(exception: ex, stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoInsertWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String dataDictionaryName = "default",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      if(acDDTable!=null){
        AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dataDictionaryName: dataDictionaryName,dao: dao);
        if (request.post.containsKey('row')) {
          response.setFromSqlDaoResult(
              result: await acSqlDbTable.insertRow(
                  row: request.post['row'])).toWebResponse();
        } else if (request.post.containsKey('rows')) {
          List<Map<String,dynamic>> rows = List<Map<String,dynamic>>.from(request.post['rows']);
          response.setFromSqlDaoResult(result: await acSqlDbTable.insertRows(rows: rows)
          ).toWebResponse();
        } else {
          response.message = 'parameters missing';
        }
      }
      else{
        response.setFailure(message: "$tableName does not exist in $dataDictionaryName data dictionary");
      }
    }
    catch (ex, stack) {
      response.setException(exception: ex, stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoSaveWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String dataDictionaryName = "default",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      if(acDDTable!=null){
        AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dataDictionaryName: dataDictionaryName,dao: dao);
        if (request.post.containsKey('row')) {
          response
              .setFromSqlDaoResult(
              result: await acSqlDbTable.saveRow(row: request.post['row']))
              .toWebResponse();
        } else if (request.post.containsKey('rows')) {
          List<Map<String,dynamic>> rows = List<Map<String,dynamic>>.from(request.post['rows']);
          response.setFromSqlDaoResult(result: await acSqlDbTable.saveRows(rows: rows)).toWebResponse();
        } else {
          response.message = 'parameters missing';
        }
      }
      else{
        response.setFailure(message: "$tableName does not exist in $dataDictionaryName data dictionary");
      }
    }
    catch (ex, stack) {
      response.setException(exception: ex, stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoSelectDistinctWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String columnName = "",
    String viewName = "",
    String dataDictionaryName = "default",
    String selectFrom = "",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      String query = "";
      int pageNumber = -1;
      int pageSize = -1;
      if(httpMethod == AcEnumHttpMethod.post){
        if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
          query = request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterQueryKey).trim();
        }
        bool allRows = false;
        if(request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterAllRows)){
          if(request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('yes') || request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('true')){
            allRows = true;
          }
        }
        if(!allRows){
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found page number key");
            pageNumber =
            request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] is int
                ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey]
                : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey].toString()) ??
                1;
          } else {
            pageNumber = 1;
          }
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found page size key");
            pageSize =
            request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] is int
                ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey]
                : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey].toString()) ?? 50;
          } else {
            pageSize = 50;
          }
        }
      }
      else{
        if (request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
          query = request.get.getString(AcDataDictionaryAutoApiConfig.selectParameterQueryKey).trim();
        }
        bool allRows = false;
        if(request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterAllRows)){
          if(request.get.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('yes') || request.get.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('true')){
            allRows = true;
          }
        }
        if(!allRows){
          pageNumber =
          request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)
              ? int.tryParse(request.get[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] ?? '') ?? 1
              : 1;
          pageSize =
          request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)
              ? int.tryParse(request.get[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] ?? '') ?? 50
              : 50;
        }
      }
      if(tableName.isNotEmpty){
        selectFrom = tableName;
      }
      else if(viewName.isNotEmpty){
        selectFrom = viewName;
      }
      if(selectFrom.isNotEmpty){
        String condition = "";
        Map<String,dynamic> parameters = {};
        if(query.isNotEmpty){
          condition = "$columnName LIKE @query";
          parameters = {
            "@query":"%$query%"
          };
        }
        String selectStatement = AcDDSelectStatement.generateSqlStatement(
          selectStatement:"SELECT $columnName FROM $selectFrom AS records",
          pageNumber: pageNumber,
          pageSize: pageSize,
          orderBy: columnName,
          condition: condition,
        );
        final getResponse = await dao.getRows(statement: selectStatement,parameters: parameters);
        response.setFromSqlDaoResult(result: getResponse);
      }
      else{
        response.setFailure(message: "$tableName does not exist in $dataDictionaryName data dictionary");
      }
    }
    catch (ex, stack) {
      response.setException(exception: ex, stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoSelectWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String viewName = "",
    String dataDictionaryName = "default",
    String selectFrom = "",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try{
      logger.log("[AcWebDataDictionaryUtils] : Getting rows for table $tableName using post method...");
      logger.log(["[AcWebDataDictionaryUtils] : Request : ",request]);
        final acDDSelectStatement = AcDDSelectStatement(
            tableName: tableName,
            viewName: viewName,
            logger: logger,
          dataDictionaryName: dataDictionaryName
        );
        if(selectFrom.isNotEmpty){
          acDDSelectStatement.selectFrom = selectFrom;
        }

        List<String> queryColumns = List.empty(growable: true);
        List<String> columnNames = List.empty(growable: true);

        if(tableName.isNotEmpty){
          var acDDTable = AcDataDictionary.getTable(
            tableName: tableName,
            dataDictionaryName: dataDictionaryName,
          );
          if(acDDTable!=null){
            acDDSelectStatement.selectFrom = acDDTable.getSelectQueryFromName();
            queryColumns = acDDTable.getSearchQueryColumnNames();
            columnNames = acDDTable.getColumnNames();
            if(acDDTable.getSqlViewName().isNotEmpty){
              if(viewName.isEmpty){
                viewName = acDDTable.getSqlViewName();
              }
            }
            if(acDDTable.getOrderByValue().isNotEmpty){
              acDDSelectStatement.orderBy = acDDTable.getOrderByValue();
            }
          }
        }
        if(viewName.isNotEmpty){
          var acDDView = AcDataDictionary.getView(
            viewName: viewName,
            dataDictionaryName: dataDictionaryName,
          );
          if(acDDView!=null){
            queryColumns = acDDView.getSearchQueryColumnNames();
            columnNames = acDDView.getColumnNames();
          }
        }

        if(httpMethod == AcEnumHttpMethod.post){
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found include columns key");
            acDDSelectStatement.includeColumns = List<String>.from(
              request.post[AcDataDictionaryAutoApiConfig.selectParameterIncludeColumnsKey],
            );
          }
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found exclude columns key");
            acDDSelectStatement.excludeColumns = List<String>.from(
              request.post[AcDataDictionaryAutoApiConfig.selectParameterExcludeColumnsKey],
            );
          }
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found select query key");
            acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
            for (final columnName in queryColumns) {
              logger.log("[AcWebDataDictionaryUtils] : Using column name for select query contains operation");
              acDDSelectStatement.addCondition(
                key: columnName,
                operator: AcEnumConditionOperator.contains,
                value: request.post[AcDataDictionaryAutoApiConfig.selectParameterQueryKey],
              );
            }
            acDDSelectStatement.endGroup();
          }
          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterFiltersKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found filter key");
            final filters = request.post[AcDataDictionaryAutoApiConfig.selectParameterFiltersKey] as Map<String, dynamic>;
            acDDSelectStatement.setConditionsFromFilters(filters: filters);
          }

          bool allRows = false;

          if(request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterAllRows)){
            if(request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('yes') || request.post.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('true')){
              allRows = true;
            }
          }

          for (var columnName in columnNames) {
            logger.log('[AcWebDataDictionaryUtils] : Checking request for column $columnName');
            if(request.post.containsKey(columnName)){
              acDDSelectStatement.conditionGroup.addCondition(key: columnName, operator: AcEnumConditionOperator.equalTo, value: request.post.get(columnName));
            }
          }

          if(!allRows){
            if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)) {
              logger.log("[AcWebDataDictionaryUtils] : Found page number key");
              acDDSelectStatement.pageNumber =
              request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] is int
                  ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey]
                  : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey].toString()) ??
                  1;
            } else {
              acDDSelectStatement.pageNumber = 1;
            }
            if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)) {
              logger.log("[AcWebDataDictionaryUtils] : Found page size key");
              acDDSelectStatement.pageSize =
              request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] is int
                  ? request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey]
                  : int.tryParse(request.post[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey].toString()) ?? 50;
            } else {
              acDDSelectStatement.pageSize = 50;
            }
          }

          if (request.post.containsKey(AcDataDictionaryAutoApiConfig.selectParameterOrderByKey)) {
            logger.log("[AcWebDataDictionaryUtils] : Found order by key");
            acDDSelectStatement.orderBy = request.post[AcDataDictionaryAutoApiConfig.selectParameterOrderByKey];
          }
        }
        else{
          if (request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterQueryKey)) {
            acDDSelectStatement.startGroup(operator: AcEnumLogicalOperator.or);
            for (final columnName in queryColumns) {
              acDDSelectStatement.addCondition(
                key: columnName,
                operator: AcEnumConditionOperator.contains,
                value: request.get[AcDataDictionaryAutoApiConfig.selectParameterQueryKey],
              );
            }
            acDDSelectStatement.endGroup();
          }

          bool allRows = false;

          if(request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterAllRows)){
            if(request.get.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('yes') || request.get.getString(AcDataDictionaryAutoApiConfig.selectParameterAllRows).equalsIgnoreCase('true')){
              allRows = true;
            }
          }

          if(!allRows){
            acDDSelectStatement.pageNumber = request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey)
                ? int.tryParse(request.get[AcDataDictionaryAutoApiConfig.selectParameterPageNumberKey] ?? '') ?? 1
                : 1;
            acDDSelectStatement.pageSize =
            request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey)
                ? int.tryParse(request.get[AcDataDictionaryAutoApiConfig.selectParameterPageSizeKey] ?? '') ?? 50
                : 50;
          }

          if (request.get.containsKey(AcDataDictionaryAutoApiConfig.selectParameterOrderByKey)) {
            acDDSelectStatement.orderBy = request.get[AcDataDictionaryAutoApiConfig.selectParameterOrderByKey];
          }
        }



        logger.log(["[AcWebDataDictionaryUtils] : Getting response from database for sql statement",acDDSelectStatement.getSqlStatement()]);
        AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dao: dao);
        final getResponse = await acSqlDbTable.getRowsFromAcDDStatement(
            acDDSelectStatement: acDDSelectStatement
        );
      result.selectStatement = acDDSelectStatement;
        // logger.log(["[AcWebDataDictionaryUtils] : Response : ",getResponse]);
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

  static Future<AcDataDictionaryWebAutoExecuteResult> handleAutoUpdateWebRequest({
    required AcLogger logger,
    required AcWebRequest request,
    String tableName = "",
    String dataDictionaryName = "default",
    AcEnumHttpMethod httpMethod = AcEnumHttpMethod.post,
    required AcBaseSqlDao dao}) async {
    final result = AcDataDictionaryWebAutoExecuteResult();
    final response = AcWebApiResponse();
    try {
      var acDDTable = AcDataDictionary.getTable(
        tableName: tableName,
        dataDictionaryName: dataDictionaryName,
      );
      if(acDDTable!=null){
        AcSqlDbTable acSqlDbTable = AcSqlDbTable(tableName: tableName,dataDictionaryName: dataDictionaryName,dao: dao);
        if (request.post.containsKey('row')) {
          response
              .setFromSqlDaoResult(
              result: await acSqlDbTable.updateRow(row: request.post['row']))
              .toWebResponse();
        } else if (request.post.containsKey('rows')) {
          List<Map<String,dynamic>> rows = List<Map<String,dynamic>>.from(request.post['rows']);
          response.setFromSqlDaoResult(result: await acSqlDbTable.updateRows(rows: rows)).toWebResponse();
        } else {
          response.message = 'parameters missing';
        }
      }
      else{
        response.setFailure(message: "$tableName does not exist in $dataDictionaryName data dictionary");
      }
    }
    catch (ex, stack) {
      response.setException(exception: ex, stackTrace: stack);
    }
    result.setFromResult(result: response);
    result.webApiResponse = response;
    result.webResponse = response.toWebResponse();
    return result;
  }
}