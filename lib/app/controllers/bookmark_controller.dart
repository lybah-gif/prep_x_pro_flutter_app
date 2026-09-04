// lib/app/controllers/bookmark_controller.dart

import 'package:get/get.dart';
import '../services/storage_service.dart';

class BookmarkController extends GetxController {
  final _storage = Get.find<StorageService>();

  final RxList<String> bookmarkedIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    bookmarkedIds.value = _storage.bookmarks;
  }

  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  void toggle(String id) {
    _storage.toggleBookmark(id);
    if (bookmarkedIds.contains(id)) {
      bookmarkedIds.remove(id);
    } else {
      bookmarkedIds.add(id);
    }
  }

  List<String> getBookmarkedIds() => bookmarkedIds.toList();
}