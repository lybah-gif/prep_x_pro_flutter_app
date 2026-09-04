// lib/app/bindings/question_bank_binding.dart

import 'package:get/get.dart';
import '../controllers/bookmark_controller.dart';
import '../controllers/question_bank_controller.dart';

class QuestionBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookmarkController(), fenix: true);
    Get.lazyPut(() => QuestionBankController());
  }
}