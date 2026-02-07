class Application {
  final String userId;
  final String jobId;
  final ApplicationStatus status;
  final DateTime createdAt;

  Application({
    required this.userId,
    required this.jobId,
    required this.status,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      userId: json['user_id'],
      jobId: json['job_id'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'job_id': jobId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum ApplicationStatus {
  pending,
  reviewed,
  accepted,
  rejected,
}