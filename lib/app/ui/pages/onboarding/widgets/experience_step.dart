import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/onboarding_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class ExperienceStep extends GetView<OnboardingController> {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What\'s your experience level?', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'This helps us adjust question difficulty.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.experienceLevels.length,
              itemBuilder: (context, index) {
                final level = controller.experienceLevels[index];
                final isSelected = controller.selectedExperience.value == level;
                return GestureDetector(
                  onTap: () => controller.selectedExperience.value = level,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            index == 0 ? Icons.school : index == 1 ? Icons.work : Icons.workspace_premium,
                            color: isSelected ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.split(' ')[0],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                level.split('(')[1].replaceAll(')', ''),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}