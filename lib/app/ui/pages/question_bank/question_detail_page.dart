// lib/ui/pages/question_bank/question_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/mock_interview_controller.dart';
import '../../../data/models/question_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/difficulty_badge.dart';

class QuestionDetailPage extends StatelessWidget {
  const QuestionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionModel question = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(question.category),
        actions: [
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: question.question));
              Get.snackbar('Copied', 'Question copied to clipboard');
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.role,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Sample Answer',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.answer,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Frequently Asked At:',
              style: AppTextStyles.heading3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.companies.map((company) {
                return Chip(
                  avatar: const Icon(Icons.business, size: 16, color: AppColors.textSecondary),
                  label: Text(company),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Tags:',
              style: AppTextStyles.heading3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.tags.map((tag) {
                return ActionChip(
                  label: Text('#$tag'),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  onPressed: () {
                    // Could navigate to search with this tag
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final controller = Get.find<MockInterviewController>();
                  controller.startInterviewWithQuestion(question);
                  Get.toNamed(Routes.MOCK_INTERVIEW);
                },
                icon: const Icon(Icons.record_voice_over),
                label: const Text('Practice This Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}