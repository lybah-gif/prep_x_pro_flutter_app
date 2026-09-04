class UserProfileModel {
  final String role;
  final String experienceLevel;
  final List<String> targetCompanies;
  final List<String> weakTopics;
  final DateTime createdAt;

  UserProfileModel({
    required this.role,
    required this.experienceLevel,
    required this.targetCompanies,
    required this.weakTopics,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'experienceLevel': experienceLevel,
    'targetCompanies': targetCompanies,
    'weakTopics': weakTopics,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        role: json['role'],
        experienceLevel: json['experienceLevel'],
        targetCompanies: List<String>.from(json['targetCompanies']),
        weakTopics: List<String>.from(json['weakTopics']),
        createdAt: DateTime.parse(json['createdAt']),
      );
}