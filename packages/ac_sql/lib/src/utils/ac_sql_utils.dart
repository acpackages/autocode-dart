import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';

import '../../ac_sql.dart';

class AcSqlUtils{
  static String convertValueForSql({required dynamic value}){
    if(value is int || value is double){
      return "$value";
    }
    else if(value is List){
      List<String> listResult = [];
      for(var v in value){
        listResult.add(convertValueForSql(value: v));
      }
      return listResult.join(",");
    }
    else if(value is DateTime){
      return value.toUtcIso8601String();
    }
    return "'$value'";
  }

  static AcSqlOperation mergeMultipleOperations({
    required List<AcSqlOperation> sqlOperations,
    String paramPrefix = "@autoParam",
    bool hardcodeParams = false
  }) {
    var instance = AcSqlOperation();
    List<String> sqlStatements = [];
    Map<String,dynamic> parameters = {};
    for(var sqlOperation in sqlOperations){
      if (sqlOperation.rawSql != null) {
        String sql = sqlOperation.rawSql!.trim();
        if(sqlOperation.parameters!= null && sqlOperation.parameters!.isNotEmpty){
          for(var key in sqlOperation.parameters!.keys){
            if(hardcodeParams){
              sql = sql.replaceAll(key, convertValueForSql(value:sqlOperation.parameters![key]));
            }
            else{
              String parameterKey = "$paramPrefix.${parameters.length}";
              sql = sql.replaceAll(key, parameterKey);
              parameters[parameterKey] = sqlOperation.parameters![key];
            }
          }
        }
        if(!sql.endsWith(";")){
          sql = "$sql;";
        }
        sqlStatements.add(sql);
      } else if (sqlOperation.operation == AcEnumDDRowOperation.insert) {
        var row = sqlOperation.row!;
        List<String> columns = [];
        List<String> placeholders = [];
        for(var key in row.keys){
          columns.add(key);
          if(hardcodeParams){
            placeholders.add(convertValueForSql(value:sqlOperation.parameters![key]));
          }
          else{
            String parameterKey = "$paramPrefix.${parameters.length}";
            placeholders.add(parameterKey);
            parameters[parameterKey] = row[key];
          }
        }
        final statement = "INSERT INTO ${sqlOperation.table} (${columns.join(', ')}) VALUES (${placeholders.join(', ')};";
        sqlStatements.add(statement);
      } else if (sqlOperation.operation == AcEnumDDRowOperation.update) {
        var row = sqlOperation.row!;
        List<String> placeholders = [];
        String conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty ? "WHERE ${sqlOperation.condition}" : "";
        if(sqlOperation.parameters!= null && sqlOperation.parameters!.isNotEmpty){
          for(var key in sqlOperation.parameters!.keys){
            if(hardcodeParams){
              conditionClause = conditionClause.replaceAll(key, convertValueForSql(value:sqlOperation.parameters![key]));
            }
            else{
              String parameterKey = "$paramPrefix.${parameters.length}";
              conditionClause = conditionClause.replaceAll(key, parameterKey);
              parameters[parameterKey] = sqlOperation.parameters![key];
            }
          }
        }
        for(var key in row.keys){
          if(hardcodeParams) {
            placeholders.add("$key = ${convertValueForSql(value:row[key])}");
          }
          else{
            String parameterKey = "$paramPrefix.${parameters.length}";
            placeholders.add("$key = $parameterKey");
            parameters[parameterKey] = row[key];
          }

        }
        final statement = "UPDATE ${sqlOperation.table} SET ${placeholders.join(", ")} $conditionClause;";
        sqlStatements.add(statement);
      } else if (sqlOperation.operation == AcEnumDDRowOperation.delete) {
        String conditionClause = sqlOperation.condition != null && sqlOperation.condition!.isNotEmpty ? "WHERE ${sqlOperation.condition}" : "";
        if(sqlOperation.parameters!= null && sqlOperation.parameters!.isNotEmpty){
          for(var key in sqlOperation.parameters!.keys){
            if(hardcodeParams){
              conditionClause = conditionClause.replaceAll(key, convertValueForSql(value:sqlOperation.parameters![key]));
            }
            else{
              String parameterKey = "$paramPrefix.${parameters.length}";
              conditionClause = conditionClause.replaceAll(key, parameterKey);
              parameters[parameterKey] = sqlOperation.parameters![key];
            }
          }
        }
        final statement = "DELETE FROM ${sqlOperation.table} $conditionClause;";
        sqlStatements.add(statement);
      }
    }
    instance.rawSql=sqlStatements.join();
    instance.parameters = parameters;
    return instance;
  }
}