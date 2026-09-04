// lib/app/data/models/interview_result_model.dart

class InterviewResultModel {
  final int overallScore;
  final int totalQuestions;
  final List<QuestionResult> questionResults;
  final String overallFeedback;
  final List<String> strengths;
  final List<String> improvements;
  final DateTime completedAt;

  InterviewResultModel({
    required this.overallScore,
    required this.totalQuestions,
    required this.questionResults,
    required this.overallFeedback,
    required this.strengths,
    required this.improvements,
    required this.completedAt,
  });
}

class QuestionResult {
  final String question;
  final String userAnswer;
  final String aiFeedback;
  final int score; // 0-100

  QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.aiFeedback,
    required this.score,
  });
}