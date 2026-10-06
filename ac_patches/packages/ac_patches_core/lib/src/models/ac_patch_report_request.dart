class AcPatchReportRequest {
  final String installationId;
  final String appId;
  final String patchId;
  final String releaseId;
  final String eventType;
  final String? errorMessage;
  final DateTime timestamp;

  AcPatchReportRequest({
    required this.installationId,
    required this.appId,
    required this.patchId,
    required this.releaseId,
    required this.eventType,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() {
    return {
      'installationId': installationId,
      'appId': appId,
      'patchId': patchId,
      'releaseId': releaseId,
      'eventType': eventType,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AcPatchReportRequest.fromJson(Map<String, dynamic> json) {
    return AcPatchReportRequest(
      installationId: json['installationId'] as String,
      appId: json['appId'] as String,
      patchId: json['patchId'] as String,
      releaseId: json['releaseId'] as String,
      eventType: json['eventType'] as String,
      errorMessage: json['errorMessage'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
