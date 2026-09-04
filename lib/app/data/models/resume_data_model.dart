// lib/app/data/models/resume_data_model.dart

class ResumeDataModel {
  final String fileName;
  final String extractedText;
  final List<String> detectedSkills;
  final List<String> suggestedQuestions;
  final DateTime uploadedAt;

  ResumeDataModel({
    required this.fileName,
    required this.extractedText,
    required this.detectedSkills,
    required this.suggestedQuestions,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'extractedText': extractedText,
    'detectedSkills': detectedSkills,
    'suggestedQuestions': suggestedQuestions,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory ResumeDataModel.fromJson(Map<String, dynamic> json) => ResumeDataModel(
    fileName: json['fileName'],
    extractedText: json['extractedText'],
    detectedSkills: List<String>.from(json['detectedSkills']),
    suggestedQuestions: List<String>.from(json['suggestedQuestions']),
    uploadedAt: DateTime.parse(json['uploadedAt']),
  );
}