// lib/ui/pages/flashcards/flashcard_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/flashcard_controller.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/flashcard_widget.dart';

class FlashcardPage extends GetView<FlashcardController> {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          Obx(() => IconButton(
            onPressed: controller.isShuffled.value
                ? controller.resetOrder
                : controller.shuffleCards,
            icon: Icon(
              controller.isShuffled.value ? Icons.restore : Icons.shuffle,
              color: AppColors.primary,
            ),
            tooltip: controller.isShuffled.value ? 'Reset order' : 'Shuffle',
          )),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${controller.currentIndex.value + 1} of ${controller.flashcards.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(controller.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: controller.progress,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )),

          // Flashcard
          Expanded(
            child: Obx(() {
              if (controller.flashcards.isEmpty) {
                return const Center(child: Text('No flashcards available'));
              }
              return GestureDetector(
                onTap: controller.flipCard,
                child: FlashcardWidget(
                  question: controller.flashcards[controller.currentIndex.value].question,
                  answer: controller.flashcards[controller.currentIndex.value].answer,
                  category: controller.flashcards[controller.currentIndex.value].category,
                  isFlipped: controller.isFlipped.value,
                ),
              );
            }),
          ),

          // Controls
          _buildControls(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Previous
          Expanded(
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.currentIndex.value > 0 ? controller.previousCard : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Prev'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
          ),
          const SizedBox(width: 12),
          // Know it
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.markAsKnown,
              icon: const Icon(Icons.check_circle, color: AppColors.success),
              label: const Text(
                'Know it',
                style: TextStyle(color: AppColors.success),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Review
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.markForReview,
              icon: const Icon(Icons.refresh, color: AppColors.warning),
              label: const Text(
                'Review',
                style: TextStyle(color: AppColors.warning),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next
          Expanded(
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.currentIndex.value < controller.flashcards.length - 1
                  ? controller.nextCard
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
          ),
        ],
      ),
    );
  }
}