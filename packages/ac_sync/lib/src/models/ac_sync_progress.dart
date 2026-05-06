class AcSyncProgress {
  String title;
  String description;
  int total;
  int pendingCount;
  double progress;

  AcSyncProgress({
    this.title = '',
    this.description = '',
    this.total = 0,
    this.pendingCount = 0,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'total': total,
      'pendingCount': pendingCount,
      'progress': progress,
    };
  }

  factory AcSyncProgress.fromJson(Map<String, dynamic> json) {
    return AcSyncProgress(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      total: json['total'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}
