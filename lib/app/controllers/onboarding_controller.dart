// lib/app/controllers/onboarding_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/skill_question_model.dart';
import '../data/models/user_profile_model.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final storage = Get.find<StorageService>();

  final currentStep = 0.obs;
  final selectedRole = ''.obs;
  final selectedExperience = ''.obs;
  final selectedCompanies = <String>[].obs;
  final quizAnswers = <int?>[].obs;
  final isSubmitting = false.obs;

  final roles = [
    'Flutter Developer',
    'React Native Developer',
    'iOS Developer',
    'Android Developer',
    'Frontend Developer',
    'Backend Engineer',
    'DevOps Engineer',
    'Product Manager',
    'Data Scientist',
    'UI/UX Designer',
  ].obs;

  final experienceLevels = [
    'Junior (0-2 years)',
    'Mid-Level (2-5 years)',
    'Senior (5+ years)',
  ].obs;

  final companies = [
    'Google',
    'Amazon',
    'Microsoft',
    'Meta',
    'Apple',
    'Netflix',
    'Tesla',
    'Uber',
    'Airbnb',
    'Other',
  ].obs;

  final questions = <SkillQuestionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Default questions
    questions.assignAll(_getQuestionsForRole());
    quizAnswers.assignAll(List.filled(questions.length, null));

    // Update questions when role changes
    ever(selectedRole, (role) {
      questions.assignAll(_getQuestionsForRole());
      quizAnswers.assignAll(List.filled(questions.length, null));
    });
  }

  List<SkillQuestionModel> _getQuestionsForRole() {
    final role = selectedRole.value;

    if (role == 'React Native Developer') {
      return [
        SkillQuestionModel(
          question: 'What is the primary language used in React Native?',
          options: ['Java', 'Swift', 'JavaScript/TypeScript', 'Dart'],
          correctIndex: 2,
          topic: 'Basics',
        ),
        SkillQuestionModel(
          question: 'How do you bridge native code in React Native?',
          options: ['Native Modules', 'Platform.OS', 'Redux', 'Hooks'],
          correctIndex: 0,
          topic: 'Native Bridge',
        ),
        SkillQuestionModel(
          question: 'Which component is used for scrollable lists in RN?',
          options: ['ScrollView', 'ListView', 'FlatList', 'SectionList'],
          correctIndex: 2,
          topic: 'Performance',
        ),
        SkillQuestionModel(
          question: 'What is the virtual DOM?',
          options: ['Native view tree', 'In-memory representation of UI', 'Direct DB access', 'CSS engine'],
          correctIndex: 1,
          topic: 'Core Architecture',
        ),
        SkillQuestionModel(
          question: 'How do you handle state globally in RN?',
          options: ['useState', 'Redux/Context API', 'Props', 'Local Storage'],
          correctIndex: 1,
          topic: 'State Management',
        ),
      ];
    }

    if (role == 'Backend Engineer') {
      return [
        SkillQuestionModel(
          question: 'Which database is best for highly relational data?',
          options: ['MongoDB', 'PostgreSQL', 'Redis', 'Cassandra'],
          correctIndex: 1,
          topic: 'Database',
        ),
        SkillQuestionModel(
          question: 'What does ACID stand for in databases?',
          options: ['Atomicity, Consistency, Isolation, Durability', 'Access, Control, Input, Data', 'Always Correct In Data', 'None of these'],
          correctIndex: 0,
          topic: 'ACID Properties',
        ),
        SkillQuestionModel(
          question: 'What is the purpose of a Load Balancer?',
          options: ['Storage', 'Traffic distribution', 'Encryption', 'Backup'],
          correctIndex: 1,
          topic: 'System Design',
        ),
        SkillQuestionModel(
          question: 'What is a JWT used for?',
          options: ['Database queries', 'Authentication', 'Image processing', 'Networking'],
          correctIndex: 1,
          topic: 'Security',
        ),
        SkillQuestionModel(
          question: 'What is the main advantage of Microservices?',
          options: ['Simplicity', 'Scalability/Isolation', 'Cost', 'Faster DB access'],
          correctIndex: 1,
          topic: 'Architecture',
        ),
      ];
    }

    // Default to Flutter or generic if others not implemented
    return [
      SkillQuestionModel(
        question: 'Which state management solution is built into Flutter?',
        options: ['GetX', 'Provider', 'setState', 'Riverpod'],
        correctIndex: 2,
        topic: 'State Management',
      ),
      SkillQuestionModel(
        question: 'What is the purpose of BuildContext?',
        options: ['To manage app state', 'To locate widgets in the tree', 'To handle HTTP requests', 'To store user preferences'],
        correctIndex: 1,
        topic: 'Flutter Basics',
      ),
      SkillQuestionModel(
        question: 'Which widget is used for scrollable lists with many items?',
        options: ['Column', 'ListView', 'Stack', 'Row'],
        correctIndex: 1,
        topic: 'Widgets',
      ),
      SkillQuestionModel(
        question: 'What does "const" constructor do in Flutter?',
        options: ['Makes widget mutable', 'Creates widget at compile time', 'Deletes widget after use', 'Rebuilds widget every frame'],
        correctIndex: 1,
        topic: 'Performance',
      ),
      SkillQuestionModel(
        question: 'Which lifecycle method is called when widget is first inserted?',
        options: ['dispose', 'deactivate', 'initState', 'didUpdateWidget'],
        correctIndex: 2,
        topic: 'Lifecycle',
      ),
    ];
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleCompany(String company) {
    if (selectedCompanies.contains(company)) {
      selectedCompanies.remove(company);
    } else {
      selectedCompanies.add(company);
    }
  }

  void answerQuestion(int questionIndex, int optionIndex) {
    quizAnswers[questionIndex] = optionIndex;
    quizAnswers.refresh();
  }

  Future<void> completeOnboarding() async {
    isSubmitting.value = true;

    // Identify weak topics
    final weakTopics = <String>{};
    for (int i = 0; i < questions.length; i++) {
      if (quizAnswers[i] != questions[i].correctIndex) {
        weakTopics.add(questions[i].topic);
      }
    }

    // Save to GetStorage (offline)
    await storage.setUserRole(selectedRole.value);
    await storage.setExperienceLevel(selectedExperience.value);
    await storage.setTargetCompanies(selectedCompanies.toList());
    await storage.setHasSeenOnboarding(true);
    await GetStorage().write('weak_topics', weakTopics.toList());

    // Save to Firestore (cloud backup)
    try {
      // Anonymous auth if not already signed in
      final user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? '';
      if (user == null) {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        uid = cred.user!.uid;
      }

      final profile = UserProfileModel(
        role: selectedRole.value,
        experienceLevel: selectedExperience.value,
        targetCompanies: selectedCompanies.toList(),
        weakTopics: weakTopics.toList(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(profile.toJson());
    } catch (e) {
      debugPrint('Firestore save error (non-critical): $e');
    }

    isSubmitting.value = false;
    Get.offAllNamed(Routes.DASHBOARD);
  }

  bool canProceed() {
    switch (currentStep.value) {
      case 0:
        return selectedRole.isNotEmpty;
      case 1:
        return selectedExperience.isNotEmpty;
      case 2:
        return selectedCompanies.isNotEmpty;
      case 3:
        return !quizAnswers.contains(null);
      default:
        return false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}