import 'dart:convert';

/// Represents local persistent client state for crash-safe patch lifecycle and rollback.
class AcPatchState {
  String? activePatchId;
  int activePatchNumber;
  String? pendingPatchId;
  int pendingPatchNumber;
  String? knownGoodPatchId;
  int failureCount;
  int maxFailuresThreshold;
  DateTime? lastLaunchTime;
  bool isHealthy;

  AcPatchState({
    this.activePatchId,
    this.activePatchNumber = 0,
    this.pendingPatchId,
    this.pendingPatchNumber = 0,
    this.knownGoodPatchId,
    this.failureCount = 0,
    this.maxFailuresThreshold = 3,
    this.lastLaunchTime,
    this.isHealthy = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'activePatchId': activePatchId,
      'activePatchNumber': activePatchNumber,
      'pendingPatchId': pendingPatchId,
      'pendingPatchNumber': pendingPatchNumber,
      'knownGoodPatchId': knownGoodPatchId,
      'failureCount': failureCount,
      'maxFailuresThreshold': maxFailuresThreshold,
      'lastLaunchTime': lastLaunchTime?.toIso8601String(),
      'isHealthy': isHealthy,
    };
  }

  factory AcPatchState.fromJson(Map<String, dynamic> json) {
    return AcPatchState(
      activePatchId: json['activePatchId'] as String?,
      activePatchNumber: json['activePatchNumber'] as int? ?? 0,
      pendingPatchId: json['pendingPatchId'] as String?,
      pendingPatchNumber: json['pendingPatchNumber'] as int? ?? 0,
      knownGoodPatchId: json['knownGoodPatchId'] as String?,
      failureCount: json['failureCount'] as int? ?? 0,
      maxFailuresThreshold: json['maxFailuresThreshold'] as int? ?? 3,
      lastLaunchTime: json['lastLaunchTime'] != null
          ? DateTime.parse(json['lastLaunchTime'] as String)
          : null,
      isHealthy: json['isHealthy'] as bool? ?? true,
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory AcPatchState.fromJsonString(String str) {
    return AcPatchState.fromJson(jsonDecode(str) as Map<String, dynamic>);
  }
}
