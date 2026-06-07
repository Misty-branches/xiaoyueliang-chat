import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/moonlit_colors.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isStreaming;
  final VoidCallback? onCancel;
  final Book? referencedBook;
  final VoidCallback? onClearReference;

  const InputBar({
    super.key,
    required this.onSend,
    this.isStreaming = false,
    this.onCancel,
    this.referencedBook,
    this.onClearReference,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isStreaming) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = MoonlitColors.forMode(isDark);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          top: BorderSide(color: c.border, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Book reference
          if (widget.referencedBook != null)
            _buildBookReferenceBar(c),
          // Input row
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: widget.referencedBook != null ? 0 : 8,
              bottom: bottomInset > 0 ? bottomInset + 8 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(fontSize: 15, color: c.ink),
                    decoration: InputDecoration(
                      hintText: widget.isStreaming
                          ? '正在回复...'
                          : (widget.referencedBook != null
                              ? '输入关于「${widget.referencedBook!.title}」的问题...'
                              : '给遐发消息...'),
                      hintStyle: TextStyle(color: c.inkSec),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: c.paper,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isStreaming)
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: c.warm,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.stop_rounded, color: Colors.white, size: 20),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _hasText ? _handleSend : null,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _hasText
                            ? c.accent
                            : c.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: _hasText ? Colors.white : c.inkSec,
                        size: 20,
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

  Widget _buildBookReferenceBar(MoonlitTheme c) {
    final book = widget.referencedBook!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: c.warm.withValues(alpha: 0.15),
        border: Border(
          bottom: BorderSide(color: c.warm.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories_rounded, size: 16, color: c.warm),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '已引用《${book.title}》',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.warm),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: widget.onClearReference,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18, color: c.warm),
            ),
          ),
        ],
      ),
    );
  }
}
