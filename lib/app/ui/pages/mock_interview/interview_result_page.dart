import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/mock_interview_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/star_breakdown_card.dart';

class InterviewResultPage extends GetView<MockInterviewController> {
  const InterviewResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Result'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final result = controller.result.value;
        if (result == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildScoreCard(result.overallScore),
              const SizedBox(height: 24),
              _buildFeedbackCard(result.overallFeedback),
              const SizedBox(height: 24),
              // Show STAR breakdown for behavioral interviews
              Obx(() {
                final star = controller.starResult.value;
                if (controller.interviewType.value == 'Behavioral' &&
                    star != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StarBreakdownCard(star: star),
                  );
                }
                return const SizedBox.shrink();
              }),
              _buildStrengthsCard(result.strengths),
              const SizedBox(height: 16),
              _buildImprovementsCard(result.improvements),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScoreCard(int score) {
    final color = score >= 80
        ? AppColors.success
        : score >= 50
        ? AppColors.warning
        : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Overall Score',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  controller.interviewType.value,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/100',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(score),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.feedback, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Feedback',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard(List<String> strengths) {
    return _buildListCard(
      title: 'Strengths',
      icon: Icons.thumb_up,
      iconColor: AppColors.success,
      items: strengths,
    );
  }

  Widget _buildImprovementsCard(List<String> improvements) {
    return _buildListCard(
      title: 'Areas to Improve',
      icon: Icons.trending_up,
      iconColor: AppColors.warning,
      items: improvements,
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.resetInterview();
              Get.offNamed(Routes.MOCK_INTERVIEW_SETUP);
            },
            icon: const Icon(Icons.replay),
            label: const Text('Try Again'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
            icon: const Icon(Icons.home),
            label: const Text('Go to Dashboard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceLight),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Outstanding! 🌟';
    if (score >= 80) return 'Great Job! 🎉';
    if (score >= 60) return 'Good Effort! 👍';
    if (score >= 40) return 'Keep Practicing! 💪';
    return 'Don\'t Give Up! 🚀';
  }
}