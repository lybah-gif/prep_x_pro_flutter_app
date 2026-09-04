// lib/ui/pages/mock_interview/mock_interview_setup_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/mock_interview_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class MockInterviewSetupPage extends GetView<MockInterviewController> {
  const MockInterviewSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Interview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildInterviewTypeSelector(),
            const SizedBox(height: 24),
            _buildQuestionCountSelector(),
            const SizedBox(height: 24),
            _buildCompanySelector(),
            const SizedBox(height: 32),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final storage = Get.find<StorageService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Setup Your Interview', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          'Role: ${storage.userRole ?? 'Not set'} • ${storage.experienceLevel ?? ''}',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInterviewTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interview Type',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
          children: controller.interviewTypes.map((type) {
            final isSelected = controller.interviewType.value == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.interviewType.value = type,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type == 'Technical'
                            ? Icons.code
                            : type == 'Behavioral'
                            ? Icons.people
                            : Icons.shuffle,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildQuestionCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of Questions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
          children: [3, 5, 7].map((count) {
            final isSelected = controller.totalQuestions.value == count;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.totalQuestions.value = count,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Questions',
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildCompanySelector() {
    final storage = Get.find<StorageService>();
    final companies = ['General', ...storage.targetCompanies];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Persona',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: companies.map((company) {
            final isSelected = controller.companyPersona.value == company;
            return ChoiceChip(
              label: Text(company),
              selected: isSelected,
              onSelected: (_) => controller.companyPersona.value = company,
              selectedColor: AppColors.primary.withOpacity(0.2),
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
        )),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.startInterview();
          Get.toNamed(Routes.MOCK_INTERVIEW);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Interview'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}