// lib/ui/pages/question_bank/question_bank_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/question_bank_controller.dart';
import '../../../data/models/question_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/question_card.dart';

class QuestionBankPage extends GetView<QuestionBankController> {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          // TEMPORARY: Seed data button (remove after first run)
          Obx(() => controller.isSeeding.value
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
              : TextButton(
            onPressed: controller.seedDatabase,
            child: const Text('SEED', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerLoading();
              }

              if (controller.filteredQuestions.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.fetchQuestions,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return QuestionCard(
                      question: controller.filteredQuestions[index],
                    );
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
        controller: controller.searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search questions, tags...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
            onPressed: () {
              controller.searchController.clear();
            },
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
            // Category filter
            ...controller.availableCategories.map((cat) {
              final isSelected = controller.selectedCategory.value == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => controller.selectedCategory.value = cat,
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            }),
            const VerticalDivider(color: AppColors.surfaceLight, width: 16),
            // Difficulty filter
            ...QuestionModel.difficulties.map((diff) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            }),
          ],
        )),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
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
              Row(
                children: [
                  Container(width: 50, height: 20, color: AppColors.surfaceLight),
                  const SizedBox(width: 8),
                  Container(width: 80, height: 20, color: AppColors.surfaceLight),
                ],
              ),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 16, color: AppColors.surfaceLight),
              const SizedBox(height: 8),
              Container(width: double.infinity * 0.7, height: 16, color: AppColors.surfaceLight),
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
          Icon(Icons.search_off, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No questions found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search query',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}