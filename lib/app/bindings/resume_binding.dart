// lib/app/bindings/resume_binding.dart

import 'package:get/get.dart';
import '../controllers/resume_parser_controller.dart';

class ResumeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResumeParserController());
  }
}