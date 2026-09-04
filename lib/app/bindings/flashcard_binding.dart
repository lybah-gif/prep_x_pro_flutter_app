// lib/app/bindings/flashcard_binding.dart

import 'package:get/get.dart';
import '../controllers/flashcard_controller.dart';

class FlashcardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FlashcardController());
  }
}