// lib/ui/pages/cheat_sheets/cheat_sheets_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/cheat_sheet_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class CheatSheetsPage extends StatelessWidget {
  CheatSheetsPage({super.key});

  final StorageService _storage = Get.find<StorageService>();

  final List<CheatSheetModel> allSheets = [
    CheatSheetModel(
      id: 'flutter_widgets',
      title: 'Flutter Widgets',
      category: 'Flutter',
      icon: 'widgets',
      colorHex: '6366F1',
      content: const [
        {'StatelessWidget': 'Immutable, cannot change after build. Use for static UI.'},
        {'StatefulWidget': 'Mutable, can call setState() to rebuild. Use for interactive UI.'},
        {'Scaffold': 'Basic material design layout structure with AppBar, Body, FAB.'},
        {'ListView.builder': 'Efficient scrolling list. Only builds visible items.'},
        {'FutureBuilder': 'Builds itself based on the latest snapshot of a Future.'},
        {'StreamBuilder': 'Rebuilds automatically when new data arrives from a Stream.'},
        {'GestureDetector': 'Detects gestures like tap, double tap, long press, swipe.'},
        {'Hero': 'Creates a shared element transition between routes.'},
      ],
    ),
    CheatSheetModel(
      id: 'react_native_basics',
      title: 'RN Essentials',
      category: 'React Native',
      icon: 'code',
      colorHex: '61DAFB',
      content: const [
        {'View': 'The most fundamental component for building a UI.'},
        {'Text': 'Component for displaying text.'},
        {'StyleSheet': 'An abstraction similar to CSS StyleSheets.'},
        {'FlatList': 'Component for rendering performant lists.'},
        {'Hooks': 'useState, useEffect, useContext for state and lifecycle.'},
        {'Props': 'Short for properties, used to pass data between components.'},
      ],
    ),
    CheatSheetModel(
      id: 'backend_concepts',
      title: 'Backend Core',
      category: 'Backend',
      icon: 'storage',
      colorHex: 'FF9900',
      content: const [
        {'REST API': 'Standard for web service communication.'},
        {'GraphQL': 'Query language for APIs, request exactly what you need.'},
        {'Docker': 'Containerization platform for consistent environments.'},
        {'OAuth 2.0': 'Industry-standard protocol for authorization.'},
        {'Redis': 'In-memory data structure store, used as DB, cache, message broker.'},
      ],
    ),
    CheatSheetModel(
      id: 'sql_joins',
      title: 'SQL Joins',
      category: 'Database',
      icon: 'storage',
      colorHex: 'F59E0B',
      content: const [
        {'INNER JOIN': 'Returns records that have matching values in both tables.'},
        {'LEFT JOIN': 'Returns all records from left table, matched from right.'},
        {'RIGHT JOIN': 'Returns all records from right table, matched from left.'},
        {'FULL OUTER JOIN': 'Returns all records when there is a match in either table.'},
        {'CROSS JOIN': 'Returns Cartesian product of both tables.'},
        {'SELF JOIN': 'Joins a table with itself using aliases.'},
        {'UNION': 'Combines result sets of two queries, removing duplicates.'},
        {'INDEX': 'Speeds up SELECT but slows down INSERT/UPDATE.'},
      ],
    ),
    CheatSheetModel(
      id: 'system_design',
      title: 'System Design',
      category: 'Architecture',
      icon: 'architecture',
      colorHex: 'EF4444',
      content: const [
        {'Load Balancer': 'Distributes traffic across multiple servers (Round Robin, Least Connections).'},
        {'CDN': 'Content Delivery Network caches static content near users.'},
        {'Caching': 'Redis/Memcached for hot data. Reduces database load.'},
        {'Database Sharding': 'Split data across multiple databases by key range/hash.'},
        {'CAP Theorem': 'Consistency, Availability, Partition Tolerance — pick two.'},
        {'Rate Limiting': 'Token bucket or sliding window to prevent abuse.'},
        {'Message Queue': 'Kafka/RabbitMQ for async processing and decoupling.'},
        {'Circuit Breaker': 'Fail fast when downstream service is unhealthy.'},
      ],
    ),
    CheatSheetModel(
      id: 'git_commands',
      title: 'Git Commands',
      category: 'DevOps',
      icon: 'git',
      colorHex: '3B82F6',
      content: const [
        {'git rebase': 'Reapply commits on top of another base tip. Cleaner history.'},
        {'git cherry-pick': 'Apply changes from specific commits to current branch.'},
        {'git stash': 'Temporarily save changes without committing.'},
        {'git bisect': 'Binary search through commits to find which introduced a bug.'},
        {'git reflog': 'Show all actions (commits, merges, resets) for recovery.'},
        {'git squash': 'Combine multiple commits into one for clean history.'},
        {'git hooks': 'Scripts that run automatically on git events (pre-commit, post-merge).'},
        {'.gitignore': 'Specifies files Git should ignore (build artifacts, secrets).'},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final role = _storage.userRole ?? 'Flutter Developer';
    
    // Filter logic: Always show SQL, System Design, Git. 
    // Show role-specific sheets (Flutter, Dart, React Native, Backend).
    final List<CheatSheetModel> filteredSheets = allSheets.where((sheet) {
      if (sheet.category == 'Database' || 
          sheet.category == 'Architecture' || 
          sheet.category == 'DevOps' || 
          sheet.category == 'Fundamentals') {
        return true;
      }
      
      if (role == 'Flutter Developer' && (sheet.category == 'Flutter' || sheet.category == 'Dart')) {
        return true;
      }
      if (role == 'React Native Developer' && sheet.category == 'React Native') {
        return true;
      }
      if (role == 'Backend Engineer' && sheet.category == 'Backend') {
        return true;
      }
      
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cheat Sheets')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredSheets.length,
        itemBuilder: (context, index) {
          final sheet = filteredSheets[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              Routes.CHEAT_SHEET_DETAIL,
              arguments: sheet,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${sheet.colorHex}')).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(sheet.icon),
                      color: Color(int.parse('0xFF${sheet.colorHex}')),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sheet.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sheet.content.length} items',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'widgets':
        return Icons.widgets;
      case 'code':
        return Icons.code;
      case 'storage':
        return Icons.storage;
      case 'architecture':
        return Icons.account_tree;
      case 'git':
        return Icons.merge_type;
      case 'school':
        return Icons.school;
      default:
        return Icons.article;
    }
  }
}
