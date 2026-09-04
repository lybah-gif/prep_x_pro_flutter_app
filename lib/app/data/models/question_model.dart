// lib/app/data/models/question_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String role;
  final String category;
  final String question;
  final String answer;
  final String difficulty;
  final List<String> companies;
  final List<String> tags;
  final bool isTechnical;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.role,
    required this.category,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.companies,
    required this.tags,
    required this.isTechnical,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'category': category,
    'question': question,
    'answer': answer,
    'difficulty': difficulty,
    'companies': companies,
    'tags': tags,
    'isTechnical': isTechnical,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
    id: json['id'],
    role: json['role'],
    category: json['category'],
    question: json['question'],
    answer: json['answer'],
    difficulty: json['difficulty'],
    companies: List<String>.from(json['companies']),
    tags: List<String>.from(json['tags']),
    isTechnical: json['isTechnical'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );

  // Helper for difficulty color
  static String getDifficultyLabel(String difficulty) => difficulty;

  static List<String> get categories => [
    'All',
    'State Management',
    'Widgets',
    'Performance',
    'Networking',
    'System Design',
    'Testing',
    'Behavioral',
    'Dart',
    'Navigation',
  ];

  static List<String> get difficulties => ['All', 'Easy', 'Medium', 'Hard'];
}