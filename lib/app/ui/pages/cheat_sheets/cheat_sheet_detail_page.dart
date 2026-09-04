// lib/ui/pages/cheat_sheets/cheat_sheet_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/cheat_sheet_model.dart';
import '../../../theme/app_colors.dart';

class CheatSheetDetailPage extends StatelessWidget {
  const CheatSheetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CheatSheetModel sheet = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(sheet.title),
        actions: [
          IconButton(
            onPressed: () {
              final text = sheet.content.map((c) {
                final entry = c.entries.first;
                return '${entry.key}: ${entry.value}';
              }).join('\n\n');
              Clipboard.setData(ClipboardData(text: text));
              Get.snackbar('Copied', 'Cheat sheet copied to clipboard');
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sheet.content.length,
        itemBuilder: (context, index) {
          final entry = sheet.content[index].entries.first;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xFF${sheet.colorHex}')).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Color(int.parse('0xFF${sheet.colorHex}')),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}