// lib/app/data/models/cheat_sheet_model.dart

class CheatSheetModel {
  final String id;
  final String title;
  final String category;
  final String icon;
  final List<Map<String, String>> content; // title -> description pairs
  final String colorHex;

  CheatSheetModel({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.content,
    required this.colorHex,
  });
}