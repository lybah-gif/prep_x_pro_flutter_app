// lib/app/data/models/daily_challenge_model.dart

class DailyChallengeModel {
  final String id;
  final String question;
  final String category;
  final String difficulty;
  final bool isCompleted;
  final DateTime date;

  DailyChallengeModel({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    this.isCompleted = false,
    required this.date,
  });
}