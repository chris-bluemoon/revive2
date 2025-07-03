class Report {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final DateTime timestamp;
  final String status; // 'pending', 'reviewed', 'resolved'

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.timestamp,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      reason: map['reason'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'pending',
    );
  }

  @override
  String toString() {
    return 'Report(id: $id, reporterId: $reporterId, reportedUserId: $reportedUserId, reason: $reason, timestamp: $timestamp, status: $status)';
  }
}
