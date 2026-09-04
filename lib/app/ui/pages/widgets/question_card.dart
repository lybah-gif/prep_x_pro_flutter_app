// lib/ui/widgets/question_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/question_bank_controller.dart';
import '../../../data/models/question_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import 'difficulty_badge.dart';

class QuestionCard extends GetView<QuestionBankController> {
  final QuestionModel question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.QUESTION_DETAIL,
        arguments: question,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DifficultyBadge(difficulty: question.difficulty),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Obx(() => IconButton(
                  onPressed: () => controller.toggleBookmark(question.id),
                  icon: Icon(
                    controller.isBookmarked(question.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: controller.isBookmarked(question.id)
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: question.companies.take(3).map((company) {
                return Chip(
                  label: Text(
                    company,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  backgroundColor: AppColors.surfaceLight,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}