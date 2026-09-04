// lib/ui/pages/community/add_experience_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/community_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AddExperiencePage extends GetView<CommunityController> {
  const AddExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Your Interview', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Help others prepare by sharing your real interview experience.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller.companyController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Company Name (e.g., Google)',
                prefixIcon: Icon(Icons.business, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.roleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Role (e.g., Flutter Developer)',
                prefixIcon: Icon(Icons.work, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            _buildDifficultySelector(),
            const SizedBox(height: 16),
            TextField(
              controller: controller.experienceController,
              maxLines: 6,
              maxLength: 1000,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Describe your interview experience... (rounds, questions, tips)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isPosting.value ? null : controller.addExperience,
                icon: controller.isPosting.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.send),
                label: const Text('Post Experience'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interview Difficulty',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 10,
          children: controller.difficulties.map((diff) {
            final isSelected = controller.selectedDifficulty.value == diff;
            return ChoiceChip(
              label: Text(diff),
              selected: isSelected,
              onSelected: (_) => controller.selectedDifficulty.value = diff,
              selectedColor: AppColors.primary.withOpacity(0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.surfaceLight),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}