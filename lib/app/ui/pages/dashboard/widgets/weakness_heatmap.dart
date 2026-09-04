// lib/ui/pages/dashboard/widgets/weakness_heatmap.dart

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class WeaknessHeatmap extends StatelessWidget {
  final List<Map<String, dynamic>> heatmapData;

  const WeaknessHeatmap({super.key, required this.heatmapData});

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.surfaceLight;
      case 1:
        return const Color(0xFF0E4429); // Light green
      case 2:
        return const Color(0xFF006D32); // Medium green
      case 3:
        return const Color(0xFF26A641); // Bright green
      case 4:
        return const Color(0xFF39D353); // Vibrant green
      default:
        return AppColors.surfaceLight;
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Practice Heatmap',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _buildLegend('Less', AppColors.surfaceLight),
                  const SizedBox(width: 4),
                  _buildLegend('', const Color(0xFF0E4429)),
                  const SizedBox(width: 4),
                  _buildLegend('', const Color(0xFF006D32)),
                  const SizedBox(width: 4),
                  _buildLegend('', const Color(0xFF26A641)),
                  const SizedBox(width: 4),
                  _buildLegend('More', const Color(0xFF39D353)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Heatmap Grid
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: heatmapData.map((day) {
              return Tooltip(
                message: '${day['date']}: ${day['intensity'] > 0 ? day['intensity'] : 'No'} practice',
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getIntensityColor(day['intensity']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: day['intensity'] >= 4
                      ? const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.white,
                  )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Last 14 days of practice activity',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}