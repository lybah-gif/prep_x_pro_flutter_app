// lib/ui/pages/coding_problems/coding_problems_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/coding_problems_controller.dart';
import '../../../data/models/leetcode_problem_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/difficulty_badge.dart';

class CodingProblemsPage extends GetView<CodingProblemsController> {
  const CodingProblemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Problems'),
        actions: [
          IconButton(
            onPressed: controller.fetchProblems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              final loading = controller.isLoading.value;
              final problems = controller.filteredProblems.toList();

              if (loading) {
                return _buildShimmerLoading();
              }

              if (problems.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchProblems,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: problems.length,
                  itemBuilder: (context, index) {
                    return _buildProblemCard(problems[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search problems (e.g., "array", "two sum")...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: () => controller.searchQuery.value = '',
            icon: const Icon(Icons.clear, color: AppColors.textMuted),
          )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            // Difficulty filter
            ...LeetCodeProblem.allDifficulties.map((diff) {
              final isSelected = controller.selectedDifficulty.value == diff;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(diff),
                  selected: isSelected,
                  onSelected: (_) => controller.selectedDifficulty.value = diff,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    ),
                  ),
                ),
              );
            }),
            const VerticalDivider(color: AppColors.surfaceLight, width: 16),
            // Topic filter
            ...controller.availableTopics.take(6).map((topic) {
              final isSelected = controller.selectedTopic.value == topic;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  onSelected: (_) => controller.selectedTopic.value = topic,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    ),
                  ),
                ),
              );
            }),
          ],
        )),
      ),
    );
  }

  Widget _buildProblemCard(LeetCodeProblem problem) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.CODING_PROBLEM_DETAIL,
        arguments: problem,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DifficultyBadge(difficulty: problem.difficulty),
                const SizedBox(width: 8),
                const Icon(Icons.thumb_up, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${problem.likes}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  problem.acceptancePercent,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              problem.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: problem.topicTags.take(4).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 60, height: 20, color: AppColors.surfaceLight),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 16, color: AppColors.surfaceLight),
              const SizedBox(height: 8),
              Container(width: 150, height: 12, color: AppColors.surfaceLight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code_off, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No problems found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}