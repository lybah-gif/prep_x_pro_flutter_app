// lib/ui/pages/dashboard/widgets/readiness_gauge.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class ReadinessGauge extends StatelessWidget {
  final int score;

  const ReadinessGauge({super.key, required this.score});

  Color get _scoreColor {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _message {
    if (score >= 80) return 'Interview Ready!';
    if (score >= 50) return 'Getting There';
    if (score >= 30) return 'Keep Practicing';
    return 'Just Started';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Interview Readiness',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _scoreColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: _CustomRadialGauge(
              score: score.toDouble(),
              color: _scoreColor,
            ),
          ),
          const SizedBox(height: 16),
          // Score breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Streak', '${(score * 0.2).toInt()} pts'),
              _buildMiniStat('Practice', '${(score * 0.3).toInt()} pts'),
              _buildMiniStat('Mocks', '${(score * 0.2).toInt()} pts'),
              _buildMiniStat('Study', '${(score * 0.1).toInt()} pts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CustomRadialGauge extends StatelessWidget {
  final double score;
  final Color color;

  const _CustomRadialGauge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadialGaugePainter(score: score, color: color),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toInt()}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _RadialGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = math.min(size.width / 2, size.height * 0.8) - 10;
    
    final backgroundPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Draw background arc (half circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 180 degrees
      math.pi, // 180 degrees sweep
      false,
      backgroundPaint,
    );

    // Draw progress arc
    final sweepAngle = (score / 100) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
