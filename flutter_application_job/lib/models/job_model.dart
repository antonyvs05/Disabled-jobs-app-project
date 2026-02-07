class Job {
  final String id;
  final String employerId;
  final String title;
  final String description;
  final bool remote;
  final bool flexibleHours;
  final List<String> accessibilityFeatures;
  final DateTime createdAt;
  String? company;
  String? location;
  String? salary;

  Job({
    required this.id,
    required this.employerId,
    required this.title,
    required this.description,
    required this.remote,
    required this.flexibleHours,
    required this.accessibilityFeatures,
    required this.createdAt,
    this.company,
    this.location,
    this.salary,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      employerId: json['employer_id'],
      title: json['title'],
      description: json['description'],
      remote: json['remote'],
      flexibleHours: json['flexible_hours'],
      accessibilityFeatures: List<String>.from(json['accessibility_features'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      company: json['company'],
      location: json['location'],
      salary: json['salary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employer_id': employerId,
      'title': title,
      'description': description,
      'remote': remote,
      'flexible_hours': flexibleHours,
      'accessibility_features': accessibilityFeatures,
      'created_at': createdAt.toIso8601String(),
      'company': company,
      'location': location,
      'salary': salary,
    };
  }
}