// lib/ui/widgets/radar_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/app_colors.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const RadarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = data.entries.map((e) {
      return ChartData(e.key, e.value);
    }).toList();

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <RadialBarSeries<ChartData, String>>[
        RadialBarSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData d, _) => d.skill,
          yValueMapper: (ChartData d, _) => d.score,
          maximumValue: 100,
          gap: '2%',
          radius: '90%',
          cornerStyle: CornerStyle.bothCurve,
          trackColor: AppColors.surfaceLight,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 10),
            labelPosition: ChartDataLabelPosition.inside,
          ),
          pointColorMapper: (ChartData d, _) {
            if (d.score >= 70) return AppColors.success;
            if (d.score >= 50) return AppColors.warning;
            return AppColors.error;
          },
        ),
      ],
    );
  }
}

class ChartData {
  final String skill;
  final double score;

  ChartData(this.skill, this.score);
}