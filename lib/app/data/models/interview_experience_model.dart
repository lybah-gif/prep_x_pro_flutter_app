// lib/app/data/models/interview_experience_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewExperienceModel {
  final String id;
  final String company;
  final String role;
  final String experience;
  final String difficulty;
  final int likes;
  final DateTime createdAt;

  InterviewExperienceModel({
    required this.id,
    required this.company,
    required this.role,
    required this.experience,
    required this.difficulty,
    required this.likes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'role': role,
    'experience': experience,
    'difficulty': difficulty,
    'likes': likes,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory InterviewExperienceModel.fromJson(Map<String, dynamic> json) =>
      InterviewExperienceModel(
        id: json['id'],
        company: json['company'],
        role: json['role'],
        experience: json['experience'],
        difficulty: json['difficulty'],
        likes: json['likes'],
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      );
}