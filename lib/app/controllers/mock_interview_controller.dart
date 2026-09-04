import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/interview_result_model.dart';
import '../data/models/question_model.dart';
import '../data/models/star_evaluation_model.dart';
import '../data/providers/gemini_provider.dart';
import '../routes/app_routes.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class MockInterviewController extends GetxController {
  final GeminiProvider _gemini = GeminiProvider();
  final StorageService _storage = Get.find<StorageService>();
  final AudioService _audio = Get.find<AudioService>();

  // Setup state
  final RxString interviewType = 'Mixed'.obs;
  final RxInt totalQuestions = 5.obs;
  final RxString companyPersona = 'General'.obs;
  final List<String> interviewTypes = ['Technical', 'Behavioral', 'Mixed'];

  // Interview state
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isGenerating = false.obs;
  final RxBool isEvaluating = false.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isInterviewActive = false.obs;
  final RxBool isInterviewComplete = false.obs;

  // Voice state
  final RxBool isVoiceMode = false.obs;
  final RxBool autoReadQuestions = true.obs;
  final RxString voiceTranscript = ''.obs;
  final RxBool isListening = false.obs;
  final RxBool isSpeaking = false.obs;

  // Timer
  final RxInt secondsElapsed = 0.obs;
  final RxString currentQuestionText = ''.obs;

  // Results
  final Rx<InterviewResultModel?> result = Rx<InterviewResultModel?>(null);
  final Rx<StarEvaluationModel?> starResult = Rx<StarEvaluationModel?>(null);
  final List<Map<String, dynamic>> _qaHistory = [];

  // Text input
  final TextEditingController answerController = TextEditingController();

  // User profile
  String get _userRole => _storage.userRole ?? 'Flutter Developer';
  String get _experienceLevel => _storage.experienceLevel ?? 'Mid-Level';
  List<String> get _weakTopics =>
      List<String>.from(GetStorage().read('weak_topics') ?? []);

  @override
  void onInit() {
    super.onInit();
    // Bind audio reactive states
    ever(_audio.isListening, (val) => isListening.value = val);
    ever(_audio.isSpeaking, (val) => isSpeaking.value = val);
    ever(_audio.transcript, (val) {
      voiceTranscript.value = val;
      if (val.isNotEmpty) {
        answerController.text = val;
      }
    });

    // Play fanfare when interview result is available
    ever(result, (val) {
      if (val != null) {
        _audio.playRawSound('success_fanfare');
      }
    });
  }

  @override
  void onClose() {
    answerController.dispose();
    _audio.stopSpeaking();
    _audio.stopListening();
    super.onClose();
  }

  void startInterview() {
    isInterviewActive.value = true;
    isInterviewComplete.value = false;
    currentQuestionIndex.value = 0;
    messages.clear();
    _qaHistory.clear();
    result.value = null;
    starResult.value = null;
    secondsElapsed.value = 0;

    _startTimer();
    _askNextQuestion();
  }

  void startInterviewWithQuestion(QuestionModel question) {
    isInterviewActive.value = true;
    isInterviewComplete.value = false;
    currentQuestionIndex.value = 0;
    totalQuestions.value = 1; // Only practice this one question
    interviewType.value = question.isTechnical ? 'Technical' : 'Behavioral';
    
    messages.clear();
    _qaHistory.clear();
    result.value = null;
    starResult.value = null;
    secondsElapsed.value = 0;

    _startTimer();
    
    // Skip generation and use the provided question
    currentQuestionText.value = question.question;
    messages.add(ChatMessageModel.ai(
      text: question.question,
      questionId: 'q_0',
    ));

    if (autoReadQuestions.value) {
      _audio.speak(question.question);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isInterviewActive.value) return false;
      secondsElapsed.value++;
      return true;
    });
  }

  String get formattedTime {
    final m = (secondsElapsed.value ~/ 60).toString().padLeft(2, '0');
    final s = (secondsElapsed.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _askNextQuestion() async {
    isGenerating.value = true;

    final question = await _gemini.generateQuestion(
      role: _userRole,
      experienceLevel: _experienceLevel,
      interviewType: interviewType.value,
      companyPersona: companyPersona.value == 'General' ? null : companyPersona.value,
      questionNumber: currentQuestionIndex.value + 1,
      totalQuestions: totalQuestions.value,
      weakTopics: _weakTopics,
    );

    currentQuestionText.value = question;

    messages.add(ChatMessageModel.ai(
      text: question,
      questionId: 'q_${currentQuestionIndex.value}',
    ));

    // Auto-read question if enabled
    if (autoReadQuestions.value) {
      await _audio.speak(question);
    }

    isGenerating.value = false;
  }

  Future<void> submitAnswer() async {
    final answer = answerController.text.trim();
    if (answer.isEmpty) return;

    // Add user message
    messages.add(ChatMessageModel.user(text: answer));
    answerController.clear();
    voiceTranscript.value = '';

    // Evaluate
    isEvaluating.value = true;

    Map<String, dynamic> evaluation;

    // Use STAR evaluation for behavioral, regular for others
    if (interviewType.value == 'Behavioral') {
      evaluation = await _gemini.evaluateBehavioralAnswer(
        question: currentQuestionText.value,
        userAnswer: answer,
        companyPersona: companyPersona.value == 'General' ? null : companyPersona.value,
      );

      // Parse STAR result
      if (evaluation['star'] != null) {
        starResult.value = StarEvaluationModel.fromGeminiJson(
          evaluation['star'] as Map<String, dynamic>,
        );
      }
    } else {
      evaluation = await _gemini.evaluateAnswer(
        question: currentQuestionText.value,
        userAnswer: answer,
        role: _userRole,
        interviewType: interviewType.value,
        companyPersona: companyPersona.value == 'General' ? null : companyPersona.value,
      );
      starResult.value = null;
    }

    final score = evaluation['score'] as int;
    final feedback = evaluation['feedback'] as String;

    // Save to history
    _qaHistory.add({
      'question': currentQuestionText.value,
      'answer': answer,
      'score': score,
      'star': evaluation['star'],
    });

    // Add evaluation message
    messages.add(ChatMessageModel.ai(
      text: feedback,
      isEvaluation: true,
      score: score,
      questionId: 'q_${currentQuestionIndex.value}',
    ));

    isEvaluating.value = false;

    // Check if interview complete
    if (currentQuestionIndex.value + 1 >= totalQuestions.value) {
      await _finishInterview();
    } else {
      currentQuestionIndex.value++;
      await Future.delayed(const Duration(seconds: 1));
      await _askNextQuestion();
    }
  }

  Future<void> _finishInterview() async {
    isInterviewActive.value = false;
    isInterviewComplete.value = true;

    // Generate summary
    final summary = await _gemini.generateSummary(
      qaHistory: _qaHistory,
      role: _userRole,
    );

    final avgScore = _qaHistory.isEmpty
        ? 0
        : _qaHistory.map((e) => e['score'] as int).reduce((a, b) => a + b) ~/ _qaHistory.length;

    final questionResults = _qaHistory.map((qa) => QuestionResult(
      question: qa['question'],
      userAnswer: qa['answer'],
      aiFeedback: '',
      score: qa['score'],
    )).toList();

    result.value = InterviewResultModel(
      overallScore: summary['overallScore'] as int,
      totalQuestions: totalQuestions.value,
      questionResults: questionResults,
      overallFeedback: summary['overallFeedback'] as String,
      strengths: List<String>.from(summary['strengths']),
      improvements: List<String>.from(summary['improvements']),
      completedAt: DateTime.now(),
    );

    // Update stats in storage
    final currentMocks = GetStorage().read('mock_interviews') ?? 0;
    await GetStorage().write('mock_interviews', currentMocks + 1);
    await _storage.updateStreak();

    // Navigate to result after delay
    await Future.delayed(const Duration(seconds: 2));
    Get.offNamed(Routes.INTERVIEW_RESULT);
  }

  // Voice helpers
  void toggleVoiceMode() {
    isVoiceMode.value = !isVoiceMode.value;
    if (isVoiceMode.value) {
      Get.snackbar(
        'Voice Mode On',
        'Tap the mic button and speak your answer',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleAutoRead() {
    autoReadQuestions.value = !autoReadQuestions.value;
    Get.snackbar(
      autoReadQuestions.value ? 'Auto-read ON' : 'Auto-read OFF',
      autoReadQuestions.value
          ? 'AI will read questions aloud'
          : 'Questions will be text only',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> startVoiceInput() async {
    if (!_audio.speechAvailable.value) {
      Get.snackbar('Error', 'Speech recognition not available on this device');
      return;
    }

    voiceTranscript.value = '';
    answerController.clear();

    // Start listening
    await _audio.startListening();
  }

  Future<void> stopVoiceInput() async {
    await _audio.stopListening();
  }

  Future<void> speakCurrentQuestion() async {
    if (currentQuestionText.value.isNotEmpty) {
      await _audio.speak(currentQuestionText.value);
    }
  }

  Future<void> stopSpeaking() async {
    await _audio.stopSpeaking();
  }

  void resetInterview() {
    isInterviewActive.value = false;
    isInterviewComplete.value = false;
    messages.clear();
    result.value = null;
    starResult.value = null;
    currentQuestionIndex.value = 0;
    secondsElapsed.value = 0;
    answerController.clear();
    voiceTranscript.value = '';
    _audio.stopSpeaking();
    _audio.stopListening();
  }
}