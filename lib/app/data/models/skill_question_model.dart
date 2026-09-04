// lib/app/data/models/skill_question_model.dart

class SkillQuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String topic;

  SkillQuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.topic,
  });
}