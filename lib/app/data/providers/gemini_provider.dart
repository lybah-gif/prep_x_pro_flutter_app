import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiProvider {
  // ⚠️ API Key should be provided via --dart-define or environment variables
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final GenerativeModel _model;

  GeminiProvider() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  // Generate interview question based on context
  Future<String> generateQuestion({
    required String role,
    required String experienceLevel,
    required String interviewType,
    required String? companyPersona,
    required int questionNumber,
    required int totalQuestions,
    required List<String>? weakTopics,
  }) async {
    final companyContext = companyPersona != null && companyPersona != 'General'
        ? 'You are interviewing at $companyPersona. Frame questions in their style (e.g., Google = deep technical, Amazon = leadership principles, Microsoft = system design focus).'
        : 'You are a senior interviewer at a top tech company.';

    final weakTopicsContext = (weakTopics != null && weakTopics.isNotEmpty)
        ? 'Focus on these weak areas: ${weakTopics.join(", ")}.'
        : '';

    final typeInstructions = switch (interviewType) {
      'Behavioral' => 'Ask a behavioral question. The user should answer using the STAR method (Situation, Task, Action, Result).',
      'Technical' => 'Ask a technical coding or conceptual question relevant to $role.',
      _ => 'Ask a mixed question - could be technical or behavioral.',
    };

    final prompt = '''
$companyContext

You are conducting a $interviewType interview for a $role position ($experienceLevel).
This is question $questionNumber of $totalQuestions.

$typeInstructions
$weakTopicsContext

Requirements:
- Ask ONLY the question, no extra text
- Make it realistic and challenging for $experienceLevel level
- Do not include any markdown formatting like ** or ##
- Keep it under 3 sentences if possible
- Do not reveal the answer or hints
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Tell me about your experience with $role.';
    } catch (e) {
      debugPrint('Gemini question error: $e');
      return 'What are your strengths as a $role?';
    }
  }

  // Evaluate user answer (Technical / Mixed)
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String userAnswer,
    required String role,
    required String interviewType,
    required String? companyPersona,
  }) async {
    final starCheck = interviewType == 'Behavioral'
        ? 'Did they use STAR method? Rate STAR usage 0-25.'
        : '';

    final prompt = '''
You are a senior interviewer at ${companyPersona ?? 'a top tech company'} evaluating a $role candidate.

Question: $question
Candidate's Answer: $userAnswer

Evaluate and respond STRICTLY in this JSON format (no markdown, no extra text):

{
  "score": <number 0-100>,
  "feedback": "<2-3 sentence constructive feedback>",
  "strength": "<what they did well>",
  "improvement": "<what they should improve>"
}

Scoring criteria:
- Accuracy and relevance (40 points)
- Depth of explanation (30 points)
- Communication clarity (30 points)
$starCheck

Be honest but encouraging. If the answer is poor, give specific advice.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      debugPrint('Gemini Evaluation Raw: $text');

      // Try parsing as JSON first
      try {
        final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleanText);
        return {
          'score': json['score'] ?? 50,
          'feedback': json['feedback'] ?? 'Good attempt.',
          'strength': json['strength'] ?? '',
          'improvement': json['improvement'] ?? '',
          'raw': text,
        };
      } catch (e) {
        // Regex Fallback
        final scoreMatch = RegExp(r'"score":\s*"?(\d+)"?').firstMatch(text);
        final feedbackMatch = RegExp(r'"feedback":\s*"([^"]+)"').firstMatch(text);
        final strengthMatch = RegExp(r'"strength":\s*"([^"]+)"').firstMatch(text);
        final improvementMatch = RegExp(r'"improvement":\s*"([^"]+)"').firstMatch(text);

        return {
          'score': int.tryParse(scoreMatch?.group(1) ?? '50') ?? 50,
          'feedback': feedbackMatch?.group(1) ?? 'Good attempt. Keep practicing.',
          'strength': strengthMatch?.group(1) ?? 'You attempted the question.',
          'improvement': improvementMatch?.group(1) ?? 'Try to be more specific.',
          'raw': text,
        };
      }
    } catch (e) {
      debugPrint('Gemini evaluation error: $e');
      return {
        'score': 0, // Changed to 0 to distinguish from a "pass"
        'feedback': 'Evaluation Error: Please check your API key and connection. ($e)',
        'strength': 'N/A',
        'improvement': 'Check Gemini API Key configuration.',
        'raw': '',
      };
    }
  }

  // NEW: Enhanced behavioral evaluation with STAR breakdown
  Future<Map<String, dynamic>> evaluateBehavioralAnswer({
    required String question,
    required String userAnswer,
    required String? companyPersona,
  }) async {
    final prompt = '''
You are a senior HR interviewer at ${companyPersona ?? 'a top tech company'} evaluating a behavioral answer.

Question: $question
Candidate's Answer: $userAnswer

Evaluate STRICTLY using the STAR method (Situation, Task, Action, Result). 
Respond ONLY in this JSON format:

{
  "overallScore": <number 0-100>,
  "feedback": "<2 sentence overall feedback>",
  "star": {
    "usedStarFormat": <boolean>,
    "situationScore": <0-25>,
    "situationFeedback": "<1 sentence>",
    "taskScore": <0-25>,
    "taskFeedback": "<1 sentence>",
    "actionScore": <0-25>,
    "actionFeedback": "<1 sentence>",
    "resultScore": <0-25>,
    "resultFeedback": "<1 sentence>"
  },
  "strength": "<what they did well>",
  "improvement": "<what to improve>"
}

Scoring:
- Situation (25 pts): Did they set the context clearly?
- Task (25 pts): Did they explain their responsibility?
- Action (25 pts): Did they describe what THEY did (not "we")?
- Result (25 pts): Did they share a measurable outcome?

Be strict but constructive. If they missed a STAR component, say so clearly.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      debugPrint('Gemini Behavioral Evaluation Raw: $text');

      // Try parsing as JSON first
      try {
        final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final json = jsonDecode(cleanText);
        return {
          'score': json['overallScore'] ?? 50,
          'feedback': json['feedback'] ?? 'Good attempt.',
          'strength': json['strength'] ?? '',
          'improvement': json['improvement'] ?? '',
          'star': json['star'],
          'raw': text,
        };
      } catch (e) {
        // Regex Fallback
        final scoreMatch = RegExp(r'"overallScore":\s*"?(\d+)"?').firstMatch(text);
        final feedbackMatch = RegExp(r'"feedback":\s*"([^"]+)"').firstMatch(text);
        final strengthMatch = RegExp(r'"strength":\s*"([^"]+)"').firstMatch(text);
        final improvementMatch = RegExp(r'"improvement":\s*"([^"]+)"').firstMatch(text);

        final usedStarMatch = RegExp(r'"usedStarFormat":\s*(true|false)').firstMatch(text);
        final sitScoreMatch = RegExp(r'"situationScore":\s*"?(\d+)"?').firstMatch(text);
        final sitFbMatch = RegExp(r'"situationFeedback":\s*"([^"]+)"').firstMatch(text);
        final taskScoreMatch = RegExp(r'"taskScore":\s*"?(\d+)"?').firstMatch(text);
        final taskFbMatch = RegExp(r'"taskFeedback":\s*"([^"]+)"').firstMatch(text);
        final actScoreMatch = RegExp(r'"actionScore":\s*"?(\d+)"?').firstMatch(text);
        final actFbMatch = RegExp(r'"actionFeedback":\s*"([^"]+)"').firstMatch(text);
        final resScoreMatch = RegExp(r'"resultScore":\s*"?(\d+)"?').firstMatch(text);
        final resFbMatch = RegExp(r'"resultFeedback":\s*"([^"]+)"').firstMatch(text);

        return {
          'score': int.tryParse(scoreMatch?.group(1) ?? '50') ?? 50,
          'feedback': feedbackMatch?.group(1) ?? 'Good attempt.',
          'strength': strengthMatch?.group(1) ?? 'You answered the question.',
          'improvement': improvementMatch?.group(1) ?? 'Use STAR format.',
          'star': {
            'usedStarFormat': usedStarMatch?.group(1) == 'true',
            'situationScore': int.tryParse(sitScoreMatch?.group(1) ?? '0') ?? 0,
            'situationFeedback': sitFbMatch?.group(1) ?? 'Not clearly stated.',
            'taskScore': int.tryParse(taskScoreMatch?.group(1) ?? '0') ?? 0,
            'taskFeedback': taskFbMatch?.group(1) ?? 'Not clearly stated.',
            'actionScore': int.tryParse(actScoreMatch?.group(1) ?? '0') ?? 0,
            'actionFeedback': actFbMatch?.group(1) ?? 'Not clearly stated.',
            'resultScore': int.tryParse(resScoreMatch?.group(1) ?? '0') ?? 0,
            'resultFeedback': resFbMatch?.group(1) ?? 'Not clearly stated.',
          },
          'raw': text,
        };
      }
    } catch (e) {
      debugPrint('STAR evaluation error: $e');
      return {
        'score': 0,
        'feedback': 'Evaluation Error: Please check your API key and connection. ($e)',
        'strength': 'N/A',
        'improvement': 'Check Gemini API Key configuration.',
        'star': null,
        'raw': '',
      };
    }
  }

  // Generic prompt generation
  Future<GenerateContentResponse> generateContent(List<Content> content) async {
    return await _model.generateContent(content);
  }

  // Generate final summary
  Future<Map<String, dynamic>> generateSummary({
    required List<Map<String, dynamic>> qaHistory,
    required String role,
  }) async {
    final qaText = qaHistory.map((qa) {
      return 'Q: ${qa['question']}\nA: ${qa['answer']}\nScore: ${qa['score']}';
    }).join('\n\n');

    final prompt = '''
You are a career coach reviewing a mock interview for $role.

Interview History:
$qaText

Provide a final assessment STRICTLY in this JSON format:

{
  "overallScore": <average of scores, number 0-100>,
  "overallFeedback": "<3-4 sentence summary>",
  "strengths": ["<strength 1>", "<strength 2>"],
  "improvements": ["<improvement 1>", "<improvement 2>"]
}

Be specific and actionable.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      final scoreMatch = RegExp(r'"overallScore":\s*(\d+)').firstMatch(text);
      final feedbackMatch = RegExp(r'"overallFeedback":\s*"([^"]+)"').firstMatch(text);

      final strengths = RegExp(r'"strengths":\s*\[(.*?)\]', dotAll: true)
          .firstMatch(text)
          ?.group(1)
          ?.split(',')
          .map((s) => s.trim().replaceAll('"', ''))
          .where((s) => s.isNotEmpty)
          .toList() ??
          ['Good participation'];

      final improvements = RegExp(r'"improvements":\s*\[(.*?)\]', dotAll: true)
          .firstMatch(text)
          ?.group(1)
          ?.split(',')
          .map((s) => s.trim().replaceAll('"', ''))
          .where((s) => s.isNotEmpty)
          .toList() ??
          ['Practice more'];

      return {
        'overallScore': int.tryParse(scoreMatch?.group(1) ?? '50') ?? 50,
        'overallFeedback': feedbackMatch?.group(1) ?? 'Keep practicing!',
        'strengths': strengths,
        'improvements': improvements,
      };
    } catch (e) {
      debugPrint('Gemini summary error: $e');
      return {
        'overallScore': 50,
        'overallFeedback': 'Good effort! Keep practicing consistently.',
        'strengths': ['You completed the interview'],
        'improvements': ['Practice more structured answers'],
      };
    }
  }
}