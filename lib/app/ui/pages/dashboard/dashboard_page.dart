// lib/ui/pages/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/daily_challenge_card.dart';
import 'widgets/readiness_gauge.dart';
import 'widgets/streak_flame.dart';
import 'widgets/weakness_heatmap.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.refreshDashboard(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Readiness Score Gauge
                Obx(() => ReadinessGauge(score: controller.readinessScore.value)),
                const SizedBox(height: 16),

                // Streak Flame
                Obx(() => StreakFlame(
                  streak: controller.streak.value,
                  hasPracticedToday: controller.hasPracticedToday.value,
                )),
                const SizedBox(height: 16),

                // Daily Challenge
                Obx(() => DailyChallengeCard(
                  challenge: controller.dailyChallenge.value,
                  onComplete: () => controller.markDailyChallengeComplete(),
                )),
                const SizedBox(height: 16),

                // Quick Stats Row
                _buildQuickStats(),
                const SizedBox(height: 16),

                // Weakness Heatmap
                Obx(() => WeaknessHeatmap(
                  heatmapData: controller.heatmapData.toList(),
                )),
                const SizedBox(height: 16),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${controller.greeting},',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Let\'s ace your interview!',
              style: AppTextStyles.heading2,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.PROFILE),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.question_answer,
            label: 'Practiced',
            value: Obx(() => Text(
              '${controller.totalQuestionsPracticed.value}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.mic,
            label: 'Mock Interviews',
            value: Obx(() => Text(
              '${controller.totalMockInterviews.value}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bookmark,
            label: 'Saved',
            value: Obx(() => Text(
              '${controller.bookmarkedCount.value}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )),
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required Widget value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          value,
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  // REPLACE _buildQuickActions method:

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.question_answer,
                label: 'Questions',
                onTap: () => Get.toNamed(Routes.QUESTION_BANK),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.code,
                label: 'Coding',
                onTap: () => Get.toNamed(Routes.CODING_PROBLEMS),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.upload_file,
                label: 'Resume',
                onTap: () => Get.toNamed(Routes.RESUME_UPLOAD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.style,
                label: 'Flashcards',
                onTap: () => Get.toNamed(Routes.FLASHCARDS),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.people,
                label: 'Community',
                onTap: () => Get.toNamed(Routes.COMMUNITY),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.article,
                label: 'Cheat Sheets',
                onTap: () => Get.toNamed(Routes.CHEAT_SHEETS),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for greeting
extension DashboardControllerExtension on DashboardController {
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}