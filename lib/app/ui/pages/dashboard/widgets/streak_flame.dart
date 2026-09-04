// lib/ui/pages/dashboard/widgets/streak_flame.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';

class StreakFlame extends StatelessWidget {
  final int streak;
  final bool hasPracticedToday;

  const StreakFlame({
    super.key,
    required this.streak,
    required this.hasPracticedToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasPracticedToday
              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
              : [AppColors.surfaceLight, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Animated Flame
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasPracticedToday)
                ...List.generate(3, (index) {
                  return Icon(
                    Icons.local_fire_department,
                    size: 48,
                    color: Colors.orange.withValues(alpha: 0.3 - (index * 0.1)),
                  )
                      .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                      .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: Duration(milliseconds: 800 + (index * 200)),
                  );
                }),
              Icon(
                Icons.local_fire_department,
                size: 48,
                color: hasPracticedToday ? Colors.white : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day${streak == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: hasPracticedToday ? Colors.white : AppColors.textMuted,
                  ),
                ),
                Text(
                  hasPracticedToday
                      ? 'Streak alive! Keep it up! 🔥'
                      : 'Practice today to keep your streak!',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasPracticedToday
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!hasPracticedToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Start Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}