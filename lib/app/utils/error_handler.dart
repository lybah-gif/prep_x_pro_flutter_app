// lib/app/utils/error_handler.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    debugPrint('❌ ERROR: $error');
    debugPrint('📍 STACK: $stackTrace');

    String userMessage = 'Something went wrong. Please try again.';

    if (error.toString().contains('socket') ||
        error.toString().contains('connection') ||
        error.toString().contains('network')) {
      userMessage = 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('timeout')) {
      userMessage = 'Request timed out. The server is taking too long to respond.';
    } else if (error.toString().contains('permission-denied')) {
      userMessage = 'Permission denied. Please check your login status.';
    } else if (error.toString().contains('not-found')) {
      userMessage = 'The requested data was not found.';
    }

    // Show user-friendly error
    if (Get.isSnackbarOpen == false) {
      Get.snackbar(
        'Error',
        userMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  static Widget buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}