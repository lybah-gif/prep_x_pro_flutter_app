// lib/app/bindings/mock_interview_binding.dart

import 'package:get/get.dart';
import '../controllers/mock_interview_controller.dart';

class MockInterviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MockInterviewController());
  }
}