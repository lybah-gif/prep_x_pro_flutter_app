import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/mock_interview_controller.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/typing_indicator.dart';

class MockInterviewPage extends GetView<MockInterviewController> {
  const MockInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${controller.currentQuestionIndex.value + 1}/${controller.totalQuestions.value}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        )),
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.interviewType.value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Obx(() => LinearProgressIndicator(
            value: (controller.currentQuestionIndex.value + 1) /
                controller.totalQuestions.value,
            backgroundColor: AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 3,
          )),

          // Chat area
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: controller.messages.length +
                    (controller.isGenerating.value ||
                        controller.isEvaluating.value
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.messages.length) {
                    return const TypingIndicator();
                  }
                  return ChatBubble(message: controller.messages[index]);
                },
              );
            }),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceLight),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice controls row
            Row(
              children: [
                // Auto-read toggle
                Obx(() => IconButton(
                  onPressed: controller.toggleAutoRead,
                  icon: Icon(
                    controller.autoReadQuestions.value
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: controller.autoReadQuestions.value
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: 'Auto-read questions',
                )),
                // Voice mode toggle
                Obx(() => IconButton(
                  onPressed: controller.toggleVoiceMode,
                  icon: Icon(
                    controller.isVoiceMode.value
                        ? Icons.keyboard_voice
                        : Icons.keyboard,
                    color: controller.isVoiceMode.value
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: controller.isVoiceMode.value
                      ? 'Voice mode'
                      : 'Text mode',
                )),
                // Speak current question
                Obx(() => IconButton(
                  onPressed: controller.isSpeaking.value
                      ? controller.stopSpeaking
                      : controller.speakCurrentQuestion,
                  icon: Icon(
                    controller.isSpeaking.value
                        ? Icons.stop
                        : Icons.play_arrow,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  tooltip: 'Read question aloud',
                )),
                const Spacer(),
                // Listening indicator
                Obx(() => controller.isListening.value
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Listening...',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 8),
            // Input row
            Row(
              children: [
                // Mic button
                Obx(() => GestureDetector(
                  onTap: controller.isListening.value
                      ? controller.stopVoiceInput
                      : controller.startVoiceInput,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: controller.isListening.value
                          ? AppColors.error
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: controller.isListening.value ? [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                    child: Icon(
                      controller.isListening.value
                          ? Icons.stop
                          : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                )),
                // Text field
                Expanded(
                  child: TextField(
                    controller: controller.answerController,
                    maxLines: null,
                    minLines: 1,
                    maxLength: 2000,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type or tap mic to speak...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      counterStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send button
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: controller.isGenerating.value ||
                        controller.isEvaluating.value ||
                        controller.isListening.value
                        ? AppColors.surfaceLight
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: controller.isGenerating.value ||
                        controller.isEvaluating.value ||
                        controller.isListening.value
                        ? null
                        : controller.submitAnswer,
                    icon: controller.isEvaluating.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}