// lib/app/controllers/resume_parser_controller.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import '../data/models/resume_data_model.dart';
import '../data/providers/gemini_provider.dart';
import '../services/storage_service.dart';

class ResumeParserController extends GetxController {
  final GeminiProvider _gemini = GeminiProvider();
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isPicking = false.obs;
  final RxBool isParsing = false.obs;
  final RxBool isGenerating = false.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString fileName = ''.obs;
  final RxString extractedText = ''.obs;
  final RxList<String> detectedSkills = <String>[].obs;
  final RxList<String> aiQuestions = <String>[].obs;
  final Rx<ResumeDataModel?> savedResume = Rx<ResumeDataModel?>(null);

  String get _userRole => _storage.userRole ?? 'Flutter Developer';

  @override
  void onInit() {
    super.onInit();
    _loadSavedResume();
  }

  void _loadSavedResume() {
    final json = GetStorage().read<Map<String, dynamic>>('resume_data');
    if (json != null) {
      savedResume.value = ResumeDataModel.fromJson(json);
    }
  }

  Future<void> pickResume() async {
    isPicking.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        fileName.value = result.files.single.name;
        await _extractText();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    } finally {
      isPicking.value = false;
    }
  }

  Future<void> _extractText() async {
    if (selectedFile.value == null) return;

    isParsing.value = true;
    try {
      final bytes = await selectedFile.value!.readAsBytes();
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: bytes);
      final String text = sf_pdf.PdfTextExtractor(document).extractText();
      document.dispose();

      extractedText.value = text;
      Get.snackbar('Success', 'Resume text extracted. Now generating AI analysis...');
      await _analyzeWithAI();
    } catch (e) {
      // Fallback: if PDF extraction fails, let user paste text
      Get.snackbar(
        'PDF Parse Error',
        'Could not auto-extract text. You can paste resume text below.',
        duration: const Duration(seconds: 4),
      );
    } finally {
      isParsing.value = false;
    }
  }

  void setManualText(String text) {
    extractedText.value = text;
  }

  Future<void> _analyzeWithAI() async {
    if (extractedText.value.isEmpty) return;

    isGenerating.value = true;
    try {
      final prompt = '''
You are a technical recruiter analyzing a resume for a $_userRole position.

Resume Content:
${extractedText.value.substring(0, extractedText.value.length > 3000 ? 3000 : extractedText.value.length)}

Respond STRICTLY in this JSON format:

{
  "detectedSkills": ["skill1", "skill2", "skill3", "skill4", "skill5"],
  "suggestedQuestions": [
    "Question 1 based on their experience?",
    "Question 2 about a specific technology they used?",
    "Question 3 challenging their architecture decision?",
    "Question 4 about team collaboration?",
    "Question 5 deep technical question?"
  ]
}

Requirements:
- detectedSkills: Extract exactly 5 key technical skills
- suggestedQuestions: Generate exactly 5 interview questions tailored to THIS specific resume
- Questions should reference actual technologies/experiences from the resume
- Be specific and challenging
''';

      final response = await _gemini.generateContent([ai.Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      // Parse skills
      final skillsMatch = RegExp(r'"detectedSkills":\s*\[(.*?)\]', dotAll: true)
          .firstMatch(text)
          ?.group(1)
          ?.split(',')
          .map((s) => s.trim().replaceAll('"', ''))
          .where((s) => s.isNotEmpty)
          .toList();

      // Parse questions
      final questionsMatch = RegExp(r'"suggestedQuestions":\s*\[(.*?)\]', dotAll: true)
          .firstMatch(text)
          ?.group(1)
          ?.split('",')
          .map((s) => s.trim().replaceAll('"', '').replaceAll('[', '').replaceAll(']', ''))
          .where((s) => s.isNotEmpty)
          .toList();

      detectedSkills.value = skillsMatch ?? ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'];
      aiQuestions.value = questionsMatch ?? [
        'Tell me about your experience with Flutter.',
        'Describe a challenging project you worked on.',
        'How do you handle state management?',
        'Explain your approach to testing.',
        'How do you optimize app performance?'
      ];

      // Save to storage
      final data = ResumeDataModel(
        fileName: fileName.value,
        extractedText: extractedText.value,
        detectedSkills: detectedSkills.toList(),
        suggestedQuestions: aiQuestions.toList(),
        uploadedAt: DateTime.now(),
      );

      await GetStorage().write('resume_data', data.toJson());
      savedResume.value = data;

      Get.snackbar('AI Analysis Complete', 'Found ${detectedSkills.length} skills & ${aiQuestions.length} questions');
    } catch (e) {
      debugPrint('AI analysis error: $e');
      Get.snackbar('Error', 'AI analysis failed. Using defaults.');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> regenerateQuestions() async {
    if (extractedText.value.isEmpty && savedResume.value != null) {
      extractedText.value = savedResume.value!.extractedText;
    }
    await _analyzeWithAI();
  }

  Future<void> clearResume() async {
    await GetStorage().remove('resume_data');
    selectedFile.value = null;
    fileName.value = '';
    extractedText.value = '';
    detectedSkills.clear();
    aiQuestions.clear();
    savedResume.value = null;
  }
}