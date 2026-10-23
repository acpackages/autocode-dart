import 'dart:core';

import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

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
  static const String keyDescription = 'description';

  @AcBindJsonProperty(key: keyCompletedCount)
  int completedCount = 0;

  @AcBindJsonProperty(key: keyTotalCount)
  int totalCount = 0;

  String description = "";

  int get pendingCount => (totalCount - completedCount);

  AcSqlCallbackArgs({int? completedCount, int? totalCount,String? description}) {
    if (completedCount != null) {
      this.completedCount = completedCount;
    }

    if (totalCount != null) {
      this.totalCount = totalCount;
    }

    if (description != null) {
      this.description = description;
    }
  }

  factory AcSqlCallbackArgs.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcSqlCallbackArgs();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  @override
  AcSqlCallbackArgs fromJson({required Map<String, dynamic> jsonData}) {
    super.fromJson(jsonData: jsonData);
    final cc = jsonData[keyCompletedCount] ?? jsonData['completed_count'];
    if (cc != null) {
      completedCount = cc is int ? cc : (int.tryParse(cc.toString()) ?? completedCount);
    }
    final tc = jsonData[keyTotalCount] ?? jsonData['total_count'];
    if (tc != null) {
      totalCount = tc is int ? tc : (int.tryParse(tc.toString()) ?? totalCount);
    }
    if (jsonData.containsKey(keyDescription)) {
      description = jsonData[keyDescription]?.toString() ?? description;
    }
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[keyCompletedCount] = completedCount;
    map[keyTotalCount] = totalCount;
    map[keyDescription] = description;
    return map;
  }
}
