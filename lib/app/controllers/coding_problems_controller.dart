// lib/app/controllers/coding_problems_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/leetcode_problem_model.dart';
import '../data/providers/leetcode_provider.dart';

class CodingProblemsController extends GetxController {
  final LeetCodeProvider _provider = LeetCodeProvider();

  final RxList<LeetCodeProblem> allProblems = <LeetCodeProblem>[].obs;
  final RxList<LeetCodeProblem> filteredProblems = <LeetCodeProblem>[].obs;

  final RxString selectedDifficulty = 'All'.obs;
  final RxString selectedTopic = 'All'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;

  // Code editor state
  final RxString selectedLanguage = 'Dart'.obs;
  final RxMap<String, String> savedCode = <String, String>{}.obs; // key: titleSlug_lang

  final List<String> languages = ['Dart', 'Python', 'Java', 'C++', 'JavaScript'];

  @override
  void onInit() {
    super.onInit();
    _loadSavedCode();
    fetchProblems();

    // Reactive workers
    ever(selectedDifficulty, (_) => applyFilters());
    ever(selectedTopic, (_) => applyFilters());
    debounce(searchQuery, (_) => applyFilters(),
        time: const Duration(milliseconds: 500));
  }

  void _loadSavedCode() {
    final stored = GetStorage().read<Map<String, dynamic>>('leetcode_code');
    if (stored != null) {
      savedCode.value = stored.map((k, v) => MapEntry(k, v.toString()));
    }
  }

  Future<void> fetchProblems() async {
    isLoading.value = true;
    try {
      final problems = await _provider.getProblems();
      allProblems.value = problems;
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load LeetCode problems. Check your connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<LeetCodeProblem> result = allProblems.toList();

    // Difficulty filter
    if (selectedDifficulty.value != 'All') {
      result = result.where((p) => p.difficulty == selectedDifficulty.value).toList();
    }

    // Topic filter
    if (selectedTopic.value != 'All') {
      result = result.where((p) => p.topicTags.contains(selectedTopic.value)).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((p) =>
      p.title.toLowerCase().contains(query) ||
          p.topicTags.any((t) => t.toLowerCase().contains(query))
      ).toList();
    }

    filteredProblems.value = result;
  }

  Future<LeetCodeProblem?> fetchProblemDetail(LeetCodeProblem problem) async {
    isLoadingDetail.value = true;
    try {
      final detail = await _provider.getProblemDetail(problem);
      return detail;
    } catch (e) {
      debugPrint('Problem Detail Error: $e');
      // No snackbar here to avoid potential Overlay/Obx conflicts during navigation
      return null;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Get all unique topics from loaded problems
  List<String> get availableTopics {
    final topics = allProblems.expand((p) => p.topicTags).toSet().toList();
    topics.sort();
    return ['All', ...topics.take(20)]; // Top 20 topics
  }

  // Code editor functions
  String getCodeKey(String titleSlug) => '${titleSlug}_${selectedLanguage.value}';

  String? getSavedCode(String titleSlug) {
    return savedCode[getCodeKey(titleSlug)];
  }

  Future<void> saveCode(String titleSlug, String code) async {
    final key = getCodeKey(titleSlug);
    savedCode[key] = code;
    await GetStorage().write('leetcode_code', savedCode);
    Get.snackbar('Saved', 'Your code has been saved locally',
        snackPosition: SnackPosition.BOTTOM);
  }

  String getLanguageExtension() {
    switch (selectedLanguage.value) {
      case 'Python':
        return 'py';
      case 'Java':
        return 'java';
      case 'C++':
        return 'cpp';
      case 'JavaScript':
        return 'js';
      case 'Dart':
      default:
        return 'dart';
    }
  }

  String getDefaultTemplate(LeetCodeProblem? problem) {
    // 1. Try to find template from API code snippets
    if (problem?.codeSnippets != null) {
      final langSlug = selectedLanguage.value.toLowerCase();
      final snippet = problem!.codeSnippets!.firstWhereOrNull(
        (s) => s['langSlug'] == langSlug || s['lang']?.toLowerCase() == langSlug
      );
      if (snippet != null && snippet['code'] != null) {
        return snippet['code']!;
      }
    }

    // 2. Fallback to hardcoded templates
    switch (selectedLanguage.value) {
      case 'Python':
        return 'class Solution:\n    def solve(self):\n        # Write your code here\n        pass';
      case 'Java':
        return 'class Solution {\n    public void solve() {\n        // Write your code here\n    }\n}';
      case 'C++':
        return 'class Solution {\npublic:\n    void solve() {\n        // Write your code here\n    }\n};';
      case 'JavaScript':
        return 'function solve() {\n    // Write your code here\n}';
      case 'Dart':
      default:
        return '// Write your Dart solution here\n\nvoid main() {\n  \n}';
    }
  }

  void clearFilters() {
    selectedDifficulty.value = 'All';
    selectedTopic.value = 'All';
    searchQuery.value = '';
  }
}