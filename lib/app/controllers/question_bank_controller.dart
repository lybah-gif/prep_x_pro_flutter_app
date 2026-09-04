// lib/app/controllers/question_bank_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/question_model.dart';
import '../data/providers/firestore_provider.dart';
import '../services/storage_service.dart';
import 'bookmark_controller.dart';

class QuestionBankController extends GetxController {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  final StorageService _storage = Get.find<StorageService>();
  final BookmarkController _bookmarkController = Get.find<BookmarkController>();

  final RxList<QuestionModel> allQuestions = <QuestionModel>[].obs;
  final RxList<QuestionModel> filteredQuestions = <QuestionModel>[].obs;

  final RxString selectedCategory = 'All'.obs;
  final RxString selectedDifficulty = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = ''.obs;

  final searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSeeding = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedRole.value = _storage.userRole ?? 'Flutter Developer';
    fetchQuestions();

    // Link search controller to search query
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Reactive workers
    ever(selectedCategory, (_) => applyFilters());
    ever(selectedDifficulty, (_) => applyFilters());
    debounce(searchQuery, (_) => applyFilters(),
        time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchQuestions() async {
    isLoading.value = true;
    try {
      final role = selectedRole.value;
      debugPrint('Fetching questions for role: $role');
      
      // Fetch questions for user's role
      List<QuestionModel> questions = await _firestoreProvider.getQuestionsByRole(role);
      
      // Fallback: If no questions for this role, try fetching some general ones or ALL
      if (questions.isEmpty) {
        debugPrint('No questions found for $role, fetching all questions instead.');
        questions = await _firestoreProvider.getAllQuestions();
      }

      debugPrint('Found ${questions.length} questions');
      allQuestions.value = questions;

      applyFilters();
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      Get.snackbar(
        'Error',
        'Failed to load questions. ${e.toString().contains('index') ? 'Firestore index required.' : 'Please try again.'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> seedDatabase() async {
    isSeeding.value = true;
    try {
      await _firestoreProvider.seedQuestions();
      Get.snackbar('Success', 'Database seeded successfully!', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
      // Small delay to allow Firestore to propagate changes
      await Future.delayed(const Duration(seconds: 1));
      await fetchQuestions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to seed: $e');
    } finally {
      isSeeding.value = false;
    }
  }

  void applyFilters() {
    List<QuestionModel> result = allQuestions.toList();

    // Category filter
    if (selectedCategory.value != 'All') {
      result = result.where((q) => q.category == selectedCategory.value).toList();
    }

    // Difficulty filter
    if (selectedDifficulty.value != 'All') {
      result = result.where((q) => q.difficulty == selectedDifficulty.value).toList();
    }

    // Search filter (question text + tags)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((q) {
        return q.question.toLowerCase().contains(query) ||
            q.tags.any((tag) => tag.toLowerCase().contains(query)) ||
            q.category.toLowerCase().contains(query);
      }).toList();
    }

    filteredQuestions.value = result;
  }

  void toggleBookmark(String questionId) {
    _bookmarkController.toggle(questionId);
  }

  bool isBookmarked(String questionId) {
    return _bookmarkController.isBookmarked(questionId);
  }

  List<QuestionModel> getBookmarkedQuestions() {
    final ids = _bookmarkController.bookmarkedIds;
    return allQuestions.where((q) => ids.contains(q.id)).toList();
  }

  void clearFilters() {
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    searchQuery.value = '';
    searchController.clear();
  }

  // Categories available for current role's questions
  List<String> get availableCategories {
    final cats = allQuestions.map((q) => q.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }
}