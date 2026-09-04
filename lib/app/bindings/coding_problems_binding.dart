// lib/app/bindings/coding_problems_binding.dart

import 'package:get/get.dart';
import '../controllers/coding_problems_controller.dart';

class CodingProblemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CodingProblemsController());
  }
}