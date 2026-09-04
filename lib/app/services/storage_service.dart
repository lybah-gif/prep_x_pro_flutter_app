import 'package:get_storage/get_storage.dart';

class StorageService {
  final _box = GetStorage();

  // Keys
  static const String _hasSeenOnboarding = 'has_seen_onboarding';
  static const String _userRole = 'user_role';
  static const String _experienceLevel = 'experience_level';
  static const String _targetCompanies = 'target_companies';
  static const String _bookmarks = 'bookmarks';
  static const String _streak = 'streak';
  static const String _lastPracticeDate = 'last_practice_date';

  // Onboarding
  bool get hasSeenOnboarding => _box.read(_hasSeenOnboarding) ?? false;
  Future<void> setHasSeenOnboarding(bool value) =>
      _box.write(_hasSeenOnboarding, value);

  // User Profile
  String? get userRole => _box.read(_userRole);
  Future<void> setUserRole(String role) => _box.write(_userRole, role);

  String? get experienceLevel => _box.read(_experienceLevel);
  Future<void> setExperienceLevel(String level) =>
      _box.write(_experienceLevel, level);

  List<String> get targetCompanies =>
      List<String>.from(_box.read(_targetCompanies) ?? []);
  Future<void> setTargetCompanies(List<String> companies) =>
      _box.write(_targetCompanies, companies);

  // Bookmarks
  List<String> get bookmarks =>
      List<String>.from(_box.read(_bookmarks) ?? []);
  Future<void> toggleBookmark(String questionId) {
    final list = bookmarks;
    if (list.contains(questionId)) {
      list.remove(questionId);
    } else {
      list.add(questionId);
    }
    return _box.write(_bookmarks, list);
  }

  bool isBookmarked(String questionId) => bookmarks.contains(questionId);

  // Streak
  int get streak => _box.read(_streak) ?? 0;
  String? get lastPracticeDate => _box.read(_lastPracticeDate);

  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final last = lastPracticeDate;

    if (last == today) return;

    if (last != null) {
      final lastDate = DateTime.parse(last);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final isConsecutive = lastDate.year == yesterday.year &&
          lastDate.month == yesterday.month &&
          lastDate.day == yesterday.day;

      if (isConsecutive) {
        await _box.write(_streak, streak + 1);
      } else {
        await _box.write(_streak, 1);
      }
    } else {
      await _box.write(_streak, 1);
    }

    await _box.write(_lastPracticeDate, today);
  }

  // Clear all (for testing)
  Future<void> clearAll() => _box.erase();
}