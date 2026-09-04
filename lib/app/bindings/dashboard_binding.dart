// lib/app/bindings/dashboard_binding.dart

import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/bookmark_controller.dart';
import '../controllers/question_bank_controller.dart';
import '../controllers/mock_interview_controller.dart';
import '../services/audio_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => BookmarkController(), fenix: true);
    Get.lazyPut(() => QuestionBankController(), fenix: true);
    
    // Initialize these for the Mock Interview tab
    Get.put(AudioService());
    Get.put(MockInterviewController());
  }
}
