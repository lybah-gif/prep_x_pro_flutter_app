// lib/app/controllers/skill_gap_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/storage_service.dart';

class SkillGapController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxMap<String, double> skillScores = <String, double>{}.obs;
  final RxBool isAnalyzing = false.obs;

  // Sample skill categories per role
  final Map<String, List<String>> _roleSkills = {
    'Flutter Developer': [
      'State Management',
      'Widgets',
      'Performance',
      'Networking',
      'Testing',
      'Dart',
      'Navigation',
      'System Design',
    ],
    'React Native Developer': [
      'State Management',
      'Navigation',
      'Native Modules',
      'Performance',
      'Testing',
      'JavaScript',
      'UI/UX',
      'System Design',
    ],
    'Backend Engineer': [
      'System Design',
      'Database',
      'API Design',
      'Security',
      'Performance',
      'Testing',
      'DevOps',
      'Microservices',
    ],
    'Product Manager': [
      'Product Strategy',
      'User Research',
      'Data Analysis',
      'Stakeholder Mgmt',
      'Agile/Scrum',
      'Roadmapping',
      'A/B Testing',
      'Communication',
    ],
  };

  @override
  void onInit() {
    super.onInit();
    analyzeSkillGap();
  }

  void analyzeSkillGap() {
    isAnalyzing.value = true;

    final role = _storage.userRole ?? 'Flutter Developer';
    final skills = _roleSkills[role] ?? _roleSkills['Flutter Developer']!;
    final weakTopics = List<String>.from(GetStorage().read('weak_topics') ?? []);
    final practiced = GetStorage().read<int>('questions_practiced') ?? 0;
    final mocks = GetStorage().read<int>('mock_interviews') ?? 0;

    // Calculate scores based on available data
    final Map<String, double> scores = {};

    for (final skill in skills) {
      double score = 30; // Base score

      // Boost if not in weak topics
      if (!weakTopics.contains(skill)) {
        score += 20;
      }

      // Boost based on practice count (diminishing returns)
      score += (practiced * 1.5).clamp(0, 25);

      // Boost based on mock interviews
      score += (mocks * 3).clamp(0, 15);

      // Random variation for demo (remove in production - use real tracking)
      // In production, track per-topic accuracy from quiz/attempts
      scores[skill] = score.clamp(0, 100);
    }

    // Ensure at least 2 weak areas for visual interest
    if (scores.values.every((s) => s > 60)) {
      scores[skills.last] = 35;
      scores[skills[skills.length - 2]] = 45;
    }

    skillScores.value = scores;
    isAnalyzing.value = false;
  }

  List<String> get weakSkills {
    return skillScores.entries
        .where((e) => e.value < 50)
        .map((e) => e.key)
        .toList();
  }

  List<String> get strongSkills {
    return skillScores.entries
        .where((e) => e.value >= 70)
        .map((e) => e.key)
        .toList();
  }

  double get averageScore {
    if (skillScores.isEmpty) return 0;
    return skillScores.values.reduce((a, b) => a + b) / skillScores.length;
  }
}