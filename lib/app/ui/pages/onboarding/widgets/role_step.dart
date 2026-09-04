import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/onboarding_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class RoleStep extends GetView<OnboardingController> {
  const RoleStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What role are you preparing for?', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'We\'ll customize your interview prep based on this.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.roles.length,
              itemBuilder: (context, index) {
                final role = controller.roles[index];
                final isSelected = controller.selectedRole.value == role;
                return GestureDetector(
                  onTap: () => controller.selectedRole.value = role,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getRoleIcon(role),
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            role,
                            style: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 15,
                            ),
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

  IconData _getRoleIcon(String role) {
    if (role.contains('Flutter') || role.contains('React')) return Icons.phone_android;
    if (role.contains('iOS')) return Icons.apple;
    if (role.contains('Android')) return Icons.android;
    if (role.contains('Backend') || role.contains('DevOps')) return Icons.cloud;
    if (role.contains('Product')) return Icons.lightbulb;
    if (role.contains('Data')) return Icons.bar_chart;
    if (role.contains('UI') || role.contains('UX')) return Icons.design_services;
    return Icons.code;
  }
}