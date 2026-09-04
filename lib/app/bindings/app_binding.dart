// lib/app/bindings/app_binding.dart

import 'package:get/get.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(AudioService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
  }
}