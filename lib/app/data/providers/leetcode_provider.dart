// lib/app/data/providers/leetcode_provider.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/leetcode_problem_model.dart';

class LeetCodeProvider {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://leetcode-api-pied.vercel.app',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Fetch all problems list
  Future<List<LeetCodeProblem>> getProblems() async {
    try {
      final response = await _dio.get('/problems');
      
      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        if (list.isNotEmpty) {
          debugPrint('LeetCode Problem Keys: ${list.first.keys}');
        }
        return list
            .map((e) => LeetCodeProblem.fromListJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch problems: $e');
    }
  }

  // Fetch problem details by titleSlug
  Future<LeetCodeProblem> getProblemDetail(LeetCodeProblem problem) async {
    if (problem.titleSlug.isEmpty) {
      throw Exception('Invalid problem: titleSlug is empty');
    }
    
    try {
      debugPrint('LeetCode API: Fetching detail for ${problem.titleSlug}');
      final response = await _dio.get('/problem/${problem.titleSlug}');

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        
        // If data is a string, parse it manually
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (e) {
             throw Exception('Failed to parse JSON response: $e');
          }
        }

        if (data is Map<String, dynamic>) {
          // Handle cases where the data might be wrapped in a 'data' key (GraphQL-like)
          final detailMap = data.containsKey('data') 
              ? data['data'] as Map<String, dynamic> 
              : data;

          return LeetCodeProblem.fromDetailJson(
            detailMap,
            problem,
          );
        }
         throw Exception('Expected Map response, got ${data.runtimeType}');
      }
      throw Exception('Server returned status ${response.statusCode}');
    } catch (e) {
      debugPrint('LeetCode Detail Error: $e');
      rethrow;
    }
  }

  // Fetch daily challenge
  Future<LeetCodeProblem?> getDailyChallenge() async {
    try {
      final response = await _dio.get('/daily');

      if (response.statusCode == 200) {
        return LeetCodeProblem.fromListJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}