// lib/ui/widgets/code_editor_widget.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialCode;
  final Function(String) onChanged;
  final String language;

  const CodeEditorWidget({
    super.key,
    required this.initialCode,
    required this.onChanged,
    required this.language,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late TextEditingController _controller;
  final ScrollController _lineScroll = ScrollController();
  final ScrollController _codeScroll = ScrollController();
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _updateLineCount();
    _controller.addListener(() {
      _updateLineCount();
      widget.onChanged(_controller.text);
    });

    // Sync scroll controllers
    _codeScroll.addListener(() {
      if (_lineScroll.hasClients) {
        _lineScroll.jumpTo(_codeScroll.offset);
      }
    });
  }

  void _updateLineCount() {
    setState(() {
      _lineCount = '\n'.allMatches(_controller.text).length + 1;
    });
  }

  @override
  void didUpdateWidget(CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode != widget.initialCode &&
        _controller.text != widget.initialCode) {
      _controller.text = widget.initialCode;
      _updateLineCount();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineScroll.dispose();
    _codeScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          // Language indicator bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.language,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_lineCount lines',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Editor
          Expanded(
            child: Row(
              children: [
                // Line numbers
                Container(
                  width: 48,
                  color: const Color(0xFF1E1E1E),
                  child: Scrollbar(
                    controller: _lineScroll,
                    child: SingleChildScrollView(
                      controller: _lineScroll,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_lineCount, (index) {
                            return Container(
                              height: 22,
                              padding: const EdgeInsets.only(right: 12),
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF6E7681),
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                // Vertical divider
                Container(width: 1, color: AppColors.surfaceLight),
                // Code text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    scrollController: _codeScroll,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      color: Color(0xFFD4D4D4),
                      fontSize: 14,
                      fontFamily: 'monospace',
                      height: 1.57,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}