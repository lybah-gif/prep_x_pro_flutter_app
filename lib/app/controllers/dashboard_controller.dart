// lib/app/controllers/dashboard_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/daily_challenge_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class DashboardController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  // Readiness Score (0-100)
  final RxInt readinessScore = 0.obs;

  // Streak
  final RxInt streak = 0.obs;
  final RxBool hasPracticedToday = false.obs;

  // Daily Challenge
  final Rx<DailyChallengeModel?> dailyChallenge = Rx<DailyChallengeModel?>(null);

  // Weakness Heatmap (last 14 days)
  final RxList<Map<String, dynamic>> heatmapData = <Map<String, dynamic>>[].obs;

  // Stats
  final RxInt totalQuestionsPracticed = 0.obs;
  final RxInt totalMockInterviews = 0.obs;
  final RxInt bookmarkedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
    _scheduleNotifications(); // NEW
  }

  void _loadAllData() {
    // Streak
    streak.value = _storage.streak;
    _checkIfPracticedToday();

    // Calculate readiness score based on multiple factors
    _calculateReadinessScore();

    // Generate daily challenge
    _generateDailyChallenge();

    // Generate mock heatmap data (Day 8 mein real data se replace hoga)
    _generateHeatmapData();

    // Stats
    totalQuestionsPracticed.value = GetStorage().read('questions_practiced') ?? 0;
    totalMockInterviews.value = GetStorage().read('mock_interviews') ?? 0;
    bookmarkedCount.value = _storage.bookmarks.length;
  }

  void _checkIfPracticedToday() {
    final lastDate = _storage.lastPracticeDate;
    final today = DateTime.now().toIso8601String().split('T')[0];
    hasPracticedToday.value = lastDate == today;
  }

  void _calculateReadinessScore() {
    // Algorithm: Base 20 + streak bonus + questions practiced + mock interviews + weak topics resolved
    int score = 20;

    // Streak bonus (max 20)
    score += (streak.value * 2).clamp(0, 20);

    // Questions practiced (max 30)
    final questions = totalQuestionsPracticed.value;
    score += (questions * 2).clamp(0, 30);

    // Mock interviews (max 20)
    score += (totalMockInterviews.value * 5).clamp(0, 20);

    // Bookmarked questions studied (max 10)
    score += (bookmarkedCount.value).clamp(0, 10);

    readinessScore.value = score.clamp(0, 100);
  }

  void _generateDailyChallenge() {
    final role = _storage.userRole ?? 'Flutter Developer';
    List<DailyChallengeModel> challenges = [];

    if (role == 'React Native Developer') {
      challenges = [
        DailyChallengeModel(
          id: 'dc_rn_001',
          question: 'What is the Bridge in React Native and how does it work?',
          category: 'Architecture',
          difficulty: 'Medium',
          date: DateTime.now(),
        ),
        DailyChallengeModel(
          id: 'dc_rn_002',
          question: 'Difference between ScrollView and FlatList performance-wise.',
          category: 'UI',
          difficulty: 'Easy',
          date: DateTime.now(),
        ),
      ];
    } else if (role == 'Backend Engineer') {
      challenges = [
        DailyChallengeModel(
          id: 'dc_be_001',
          question: 'Explain SQL vs NoSQL and when to choose which.',
          category: 'Database',
          difficulty: 'Medium',
          date: DateTime.now(),
        ),
        DailyChallengeModel(
          id: 'dc_be_002',
          question: 'What are ACID properties in a database system?',
          category: 'Database',
          difficulty: 'Easy',
          date: DateTime.now(),
        ),
      ];
    } else {
      // Default / Flutter challenges
      challenges = [
        DailyChallengeModel(
          id: 'dc_001',
          question: 'Explain the difference between GetX and Provider for state management.',
          category: 'State Management',
          difficulty: 'Medium',
          date: DateTime.now(),
        ),
        DailyChallengeModel(
          id: 'dc_002',
          question: 'How would you optimize a Flutter app that has performance issues?',
          category: 'Performance',
          difficulty: 'Hard',
          date: DateTime.now(),
        ),
        DailyChallengeModel(
          id: 'dc_003',
          question: 'What is the purpose of Keys in Flutter widgets?',
          category: 'Widgets',
          difficulty: 'Easy',
          date: DateTime.now(),
        ),
      ];
    }

    // Pick based on day of year for consistency
    final dayOfYear = DateTime.now().day;
    dailyChallenge.value = challenges[dayOfYear % challenges.length];
  }

  void _generateHeatmapData() {
    // Generate last 14 days of practice data
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    for (int i = 13; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];

      // Mock data: random practice intensity (0-4)
      // Day 8 mein real data se replace hoga
      final intensity = (i == 0 && hasPracticedToday.value)
          ? 4
          : (i % 3 == 0 ? 3 : i % 2 == 0 ? 2 : i % 5 == 0 ? 1 : 0);

      data.add({
        'date': dateStr,
        'day': date.day,
        'intensity': intensity, // 0=none, 1=light, 2=moderate, 3=good, 4=excellent
      });
    }

    heatmapData.value = data;
  }

  Future<void> markDailyChallengeComplete() async {
    dailyChallenge.value = dailyChallenge.value?.copyWith(isCompleted: true);
    await _storage.updateStreak();
    streak.value = _storage.streak;
    hasPracticedToday.value = true;
    _calculateReadinessScore();
    _generateHeatmapData();

    // Show instant notification
    final notifications = Get.find<NotificationService>();
    await notifications.showInstantNotification(
      title: 'Practice Complete! 🎉',
      body: 'Great job! You\'re one step closer to interview readiness.',
    );
  }
  // ADD this method:
  void _scheduleNotifications() {
    final notifications = Get.find<NotificationService>();
    // Schedule daily reminder at 9 AM
    notifications.scheduleDailyReminder(hour: 9, minute: 0);

    // Schedule streak warning at 8 PM
    notifications.scheduleStreakWarning();
  }

  void refreshDashboard() {
    _loadAllData();
  }
}

// Extension for copyWith
extension DailyChallengeExtension on DailyChallengeModel {
  DailyChallengeModel copyWith({bool? isCompleted}) {
    return DailyChallengeModel(
      id: id,
      question: question,
      category: category,
      difficulty: difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date,
    );
  }
}