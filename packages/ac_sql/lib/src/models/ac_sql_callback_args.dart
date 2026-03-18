import 'dart:core';

import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the result of a database Data Access Object (DAO) operation.",
  "description": "This class encapsulates the outcome of a SQL query such as SELECT, INSERT, UPDATE, or DELETE. It holds any returned rows, the number of affected rows, the last inserted ID(s), and other relevant metadata about the operation.",
  "example": "// Example result from an INSERT operation that created one new record.\nfinal result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert)\n  ..affectedRowsCount = 1\n  ..lastInsertedId = 123;"
}) */
@AcReflectable()
class AcSqlCallbackArgs extends AcResult {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCompletedCount = 'completedCount';
  static const String keyTotalCount = 'totalCount';

  @AcBindJsonProperty(key: keyCompletedCount)
  int completedCount = 0;

  @AcBindJsonProperty(key: keyTotalCount)
  int totalCount = 0;

  int get pendingCount => (totalCount - completedCount);

  AcSqlCallbackArgs({int? completedCount,int? totalCount}){
    if(completedCount!=null){
      this.completedCount = completedCount;
    }

    if(totalCount!=null){
      this.totalCount = totalCount;
    }
  }
}

