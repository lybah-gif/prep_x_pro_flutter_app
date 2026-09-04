// lib/ui/pages/coding_problems/coding_problem_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../../../controllers/coding_problems_controller.dart';
import '../../../data/models/leetcode_problem_model.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/code_editor_widget.dart';

class CodingProblemDetailPage extends StatefulWidget {
  const CodingProblemDetailPage({super.key});

  @override
  State<CodingProblemDetailPage> createState() => _CodingProblemDetailPageState();
}

class _CodingProblemDetailPageState extends State<CodingProblemDetailPage>
    with SingleTickerProviderStateMixin {
  final CodingProblemsController controller = Get.find();
  late TabController _tabController;

  LeetCodeProblem? _problem;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProblem();
  }

  Future<void> _loadProblem() async {
    var baseProblem = Get.arguments as LeetCodeProblem;
    
    // Safety: If slug is somehow still empty, generate it from title
    if (baseProblem.titleSlug.isEmpty && baseProblem.title.isNotEmpty) {
      final generatedSlug = baseProblem.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      baseProblem = LeetCodeProblem(
        title: baseProblem.title,
        titleSlug: generatedSlug.endsWith('-') ? generatedSlug.substring(0, generatedSlug.length - 1) : generatedSlug,
        difficulty: baseProblem.difficulty,
        topicTags: baseProblem.topicTags,
        likes: baseProblem.likes,
        dislikes: baseProblem.dislikes,
        acceptanceRate: baseProblem.acceptanceRate,
      );
    }

    final detail = await controller.fetchProblemDetail(baseProblem);
    if (detail != null) {
      if (mounted) {
        setState(() {
          _problem = detail;
          _code = controller.getSavedCode(detail.titleSlug) ??
              controller.getDefaultTemplate(detail);
        });
      }
    } else {
      // If failed
      if (mounted) {
        setState(() {
          _problem = LeetCodeProblem(
            title: baseProblem.title,
            titleSlug: baseProblem.titleSlug,
            difficulty: baseProblem.difficulty,
            topicTags: baseProblem.topicTags,
            likes: baseProblem.likes,
            dislikes: baseProblem.dislikes,
            content: 'error', // Marker for error state
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_problem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_problem!.title),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Description', icon: Icon(Icons.description)),
            Tab(text: 'Code Editor', icon: Icon(Icons.code)),
          ],
        ),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            onSelected: (lang) {
              controller.selectedLanguage.value = lang;
              // Save current code before switching
              if (_problem != null && _problem!.content != 'error') {
                controller.saveCode(_problem!.titleSlug, _code);
              }
              setState(() {
                _code = controller.getSavedCode(_problem!.titleSlug) ??
                    controller.getDefaultTemplate(_problem);
              });
            },
            itemBuilder: (context) => controller.languages.map((lang) {
              final isSelected = controller.selectedLanguage.value == lang;
              return PopupMenuItem(
                value: lang,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, color: AppColors.primary, size: 18),
                    if (isSelected)
                      const SizedBox(width: 8),
                    Text(lang),
                  ],
                ),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    controller.selectedLanguage.value,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDescriptionTab(),
          _buildCodeEditorTab(),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    if (_problem!.content == 'error') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Failed to load problem details',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'The LeetCode API might be busy or your internet connection is unstable.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _problem = null);
                  _loadProblem();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty & Stats
          Row(
            children: [
              _buildStatChip(_problem!.difficulty, _getDifficultyColor()),
              const SizedBox(width: 8),
              _buildStatChip('👍 ${_problem!.likes}', AppColors.textSecondary),
              const SizedBox(width: 8),
              if (_problem!.acceptancePercent != 'N/A')
                _buildStatChip('✅ ${_problem!.acceptancePercent}', AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 20),

          // Problem Content (HTML)
          if (_problem!.content != null)
            Html(
              data: _problem!.content,
              style: {
                "body": Style(
                  color: AppColors.textPrimary,
                  fontSize: FontSize(15),
                  lineHeight: const LineHeight(1.6),
                ),
                "code": Style(
                  backgroundColor: AppColors.surfaceLight,
                  padding: HtmlPaddings.all(4),
                  fontFamily: 'monospace',
                ),
                "pre": Style(
                  backgroundColor: const Color(0xFF1E1E1E),
                  padding: HtmlPaddings.all(12),
                ),
              },
            ),

          const SizedBox(height: 20),

          // Constraints
          if (_problem!.constraints != null) ...[
            const Text(
              'Constraints:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Html(
              data: _problem!.constraints,
              style: {
                "body": Style(
                  color: AppColors.textSecondary,
                  fontSize: FontSize(14),
                ),
              },
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCodeEditorTab() {
    return Column(
      children: [
        Expanded(
          child: CodeEditorWidget(
            initialCode: _code,
            language: controller.selectedLanguage.value,
            onChanged: (newCode) => _code = newCode,
          ),
        ),
        // Bottom action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.surfaceLight),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _code = controller.getDefaultTemplate(_problem);
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.surfaceLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.saveCode(_problem!.titleSlug, _code);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Solution'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == AppColors.textSecondary ? AppColors.textSecondary : color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (_problem!.difficulty) {
      case 'Easy':
        return AppColors.easy;
      case 'Medium':
        return AppColors.warning;
      case 'Hard':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}