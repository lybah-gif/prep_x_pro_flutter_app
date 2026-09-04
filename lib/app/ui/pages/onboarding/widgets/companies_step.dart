import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/onboarding_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class CompaniesStep extends GetView<OnboardingController> {
  const CompaniesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Companies', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Select companies you\'re interviewing with. You can select multiple.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() => SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.companies.map((company) {
                  final isSelected = controller.selectedCompanies.contains(company);
                  return ChoiceChip(
                    label: Text(company),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleCompany(company),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      ),
                    ),
                  );
                }).toList(),
              ),
            )),
          ),
        ],
      ),
    );
  }
}