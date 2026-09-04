// lib/app/data/models/leetcode_problem_model.dart

import 'dart:convert';

class LeetCodeProblem {
  final String title;
  final String titleSlug;
  final String difficulty;
  final List<String> topicTags;
  final int likes;
  final int dislikes;
  final double? acceptanceRate;

  // Detail fields (nullable for list view)
  final String? content;           // HTML description
  final String? exampleTestcases;  // Raw example input
  final String? constraints;       // HTML constraints
  final List<Map<String, String>>? codeSnippets; // Language-specific boilerplate

  LeetCodeProblem({
    required this.title,
    required this.titleSlug,
    required this.difficulty,
    required this.topicTags,
    required this.likes,
    required this.dislikes,
    this.acceptanceRate,
    this.content,
    this.exampleTestcases,
    this.constraints,
    this.codeSnippets,
  });

  factory LeetCodeProblem.fromListJson(Map<String, dynamic> json) {
    // topicTags can be List<String> or List<Map>
    List<String> tags = [];
    if (json['topicTags'] != null) {
      tags = (json['topicTags'] as List).map((e) {
        if (e is String) return e;
        if (e is Map) return e['name']?.toString() ?? '';
        return e.toString();
      }).where((t) => t.isNotEmpty).toList();
    }

    double? acRate;
    
    // Check multiple possible keys for acceptance rate
    final acRaw = json['acceptanceRate'] ?? json['acRate'] ?? json['ac_rate'];
    
    if (acRaw != null) {
      if (acRaw is num) {
        acRate = acRaw.toDouble() > 1 ? acRaw.toDouble() / 100 : acRaw.toDouble();
      } else if (acRaw is String) {
        final clean = acRaw.replaceAll('%', '');
        acRate = double.tryParse(clean) != null ? double.parse(clean) / 100 : null;
      }
    } else if (json['stats'] != null && json['stats'] is String) {
      // stats is often a stringified JSON: {"totalAccepted": "...", "acRate": "50.1%"}
      try {
        final statsMap = jsonDecode(json['stats']);
        final ac = statsMap['acRate']?.toString().replaceAll('%', '');
        if (ac != null) acRate = double.tryParse(ac)! / 100;
      } catch (_) {}
    }

    // Check multiple possible keys for title and slug
    final question = json['question'] ?? json;
    String slug = question['titleSlug'] ?? question['questionTitleSlug'] ?? question['question__title_slug'] ?? question['slug'] ?? '';
    
    // Fallback: If slug is empty but title exists, slugify title (last resort)
    if (slug.isEmpty && question['title'] != null) {
      slug = question['title'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
    }

    return LeetCodeProblem(
      title: question['title'] ?? question['questionTitle'] ?? question['question__title'] ?? 'Unknown',
      titleSlug: slug,
      difficulty: question['difficulty'] ?? question['questionDifficulty'] ?? question['difficulty_level']?.toString() ?? 'Medium',
      topicTags: tags,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      acceptanceRate: acRate,
    );
  }

  factory LeetCodeProblem.fromDetailJson(
      Map<String, dynamic> json,
      LeetCodeProblem base,
      ) {
    // Some APIs nest everything under 'question' or 'data' or just return it directly
    final question = json['question'] ?? json['data'] ?? json;
    
    // Parse code snippets if available
    List<Map<String, String>>? snippets;
    if (question['codeSnippets'] != null) {
      snippets = (question['codeSnippets'] as List).map((e) {
        return {
          'lang': e['lang']?.toString() ?? '',
          'langSlug': e['langSlug']?.toString() ?? '',
          'code': e['code']?.toString() ?? '',
        };
      }).toList();
    }
    
    // Handle stats in detail if available
    double? acRate = base.acceptanceRate;
    if (acRate == null && question['stats'] != null) {
       try {
        final statsMap = question['stats'] is String 
            ? jsonDecode(question['stats']) 
            : question['stats'];
        final ac = statsMap['acRate']?.toString().replaceAll('%', '');
        if (ac != null) acRate = double.tryParse(ac)! / 100;
      } catch (_) {}
    }

    return LeetCodeProblem(
      title: base.title,
      titleSlug: base.titleSlug,
      difficulty: base.difficulty,
      topicTags: base.topicTags,
      likes: base.likes,
      dislikes: base.dislikes,
      acceptanceRate: acRate,
      content: question['content'] ?? question['questionContent'] ?? question['description'] ?? question['body'],
      exampleTestcases: question['exampleTestcases'] ?? question['sampleTestCase'] ?? question['testcase'],
      constraints: question['constraints'] ?? question['questionConstraints'],
      codeSnippets: snippets,
    );
  }

  String get acceptancePercent {
    if (acceptanceRate == null) return 'N/A';
    return '${(acceptanceRate! * 100).toStringAsFixed(1)}%';
  }

  static List<String> get allDifficulties => ['All', 'Easy', 'Medium', 'Hard'];
}