import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/onboarding_controller.dart';
import '../../../theme/app_colors.dart';
import 'widgets/companies_step.dart';
import 'widgets/experience_step.dart';
import 'widgets/quiz_step.dart';
import 'widgets/role_step.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  RoleStep(),
                  ExperienceStep(),
                  CompaniesStep(),
                  QuizStep(),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= controller.currentStep.value
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildBottomNavigation() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (controller.currentStep.value > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.canProceed()
                  ? (controller.currentStep.value == 3
                  ? controller.completeOnboarding
                  : controller.nextStep)
                  : null,
              child: controller.isSubmitting.value && controller.currentStep.value == 3
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                controller.currentStep.value == 3 ? 'Complete Setup' : 'Next',
              ),
            ),
          ),
        ],
      ),
    ));
  }
}