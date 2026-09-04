class StarEvaluationModel {
  final int situationScore;
  final int taskScore;
  final int actionScore;
  final int resultScore;
  final String situationFeedback;
  final String taskFeedback;
  final String actionFeedback;
  final String resultFeedback;
  final bool usedStarFormat;

  StarEvaluationModel({
    required this.situationScore,
    required this.taskScore,
    required this.actionScore,
    required this.resultScore,
    required this.situationFeedback,
    required this.taskFeedback,
    required this.actionFeedback,
    required this.resultFeedback,
    required this.usedStarFormat,
  });

  int get totalScore => situationScore + taskScore + actionScore + resultScore;

  factory StarEvaluationModel.fromGeminiJson(Map<String, dynamic> json) {
    return StarEvaluationModel(
      situationScore: json['situationScore'] ?? 0,
      taskScore: json['taskScore'] ?? 0,
      actionScore: json['actionScore'] ?? 0,
      resultScore: json['resultScore'] ?? 0,
      situationFeedback: json['situationFeedback'] ?? 'Not clearly stated',
      taskFeedback: json['taskFeedback'] ?? 'Not clearly stated',
      actionFeedback: json['actionFeedback'] ?? 'Not clearly stated',
      resultFeedback: json['resultFeedback'] ?? 'Not clearly stated',
      usedStarFormat: json['usedStarFormat'] ?? false,
    );
  }
}