class User {
  final String id;
  final String email;
  final UserRole role;
  final List<String> skills;
  final Map<String, dynamic> preferences;
  final List<String> functionalNeeds;
  final DateTime createdAt;
  String? name;
  String? phone;
  String? location;
  String? bio;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.skills,
    required this.preferences,
    required this.functionalNeeds,
    required this.createdAt,
    this.name,
    this.phone,
    this.location,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      skills: List<String>.from(json['skills'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      functionalNeeds: List<String>.from(json['functional_needs'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.toString().split('.').last,
      'skills': skills,
      'preferences': preferences,
      'functional_needs': functionalNeeds,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'phone': phone,
      'location': location,
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    List<String>? skills,
    Map<String, dynamic>? preferences,
    List<String>? functionalNeeds,
    DateTime? createdAt,
    String? name,
    String? phone,
    String? location,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      preferences: preferences ?? this.preferences,
      functionalNeeds: functionalNeeds ?? this.functionalNeeds,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }
}

enum UserRole {
  job_seeker,
  employer,
}