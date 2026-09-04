// lib/app/data/models/chat_message_model.dart

class ChatMessageModel {
  final String id;
  final String sender; // 'ai' or 'user'
  final String text;
  final DateTime timestamp;
  final bool isEvaluation;
  final int? score; // 0-100 for evaluation messages
  final String? questionId;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isEvaluation = false,
    this.score,
    this.questionId,
  });

  factory ChatMessageModel.ai({
    required String text,
    bool isEvaluation = false,
    int? score,
    String? questionId,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'ai',
      text: text,
      timestamp: DateTime.now(),
      isEvaluation: isEvaluation,
      score: score,
      questionId: questionId,
    );
  }

  factory ChatMessageModel.user({required String text}) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
  }
}