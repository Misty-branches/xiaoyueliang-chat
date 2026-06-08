import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/chat_provider.dart';
import '../models/book.dart';
import '../models/unified_theme.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    final bookProvider = context.watch<BookProvider>();
    final books = bookProvider.books;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Row(
          children: [
            Text(
              '我的书库',
              style: TextStyle(color: c.ink),
            ),
            if (books.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '(${books.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: c.inkSec,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookSheet(context, isDark),
        backgroundColor: c.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('添加书籍', style: TextStyle(color: Colors.white)),
      ),
      body: books.isEmpty ? _buildEmptyState(c) : _buildBookList(c, books, bookProvider),
    );
  }

  Widget _buildEmptyState(MoonlitTheme c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 72,
            color: c.border,
          ),
          const SizedBox(height: 16),
          Text(
            '书库还空空的',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: c.inkSec,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加小说或文本',
            style: TextStyle(
              fontSize: 14,
              color: c.inkSec.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(MoonlitTheme c, List<Book> books, BookProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookCard(
          book: book,
          c: c,
          onQuote: () => Navigator.pop(context, book),
          onDelete: () => _confirmDelete(context, provider, book),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, BookProvider provider, Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('删除书籍', style: TextStyle(color: c.ink)),
        content: Text('确定要删除「${book.title}」吗？', style: TextStyle(color: c.inkSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: c.inkSec),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.removeBook(book.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: c.warm),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddBookSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddBookSheet(
        isDark: isDark,
        onAddByText: () {
          Navigator.pop(ctx);
          _showTextInputDialog(context, isDark);
        },
        onAddByFile: () {
          Navigator.pop(ctx);
          _pickFile(context);
        },
      ),
    );
  }

  void _showTextInputDialog(BuildContext context, bool isDark) {
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('粘贴文本', style: TextStyle(color: c.ink)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: c.ink),
                decoration: InputDecoration(
                  labelText: '书名',
                  labelStyle: TextStyle(color: c.inkSec),
                  hintText: '输入书名...',
                  hintStyle: TextStyle(color: c.inkSec.withValues(alpha: 0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  fillColor: c.surface,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 8,
                style: TextStyle(color: c.ink),
                decoration: InputDecoration(
                  labelText: '文本内容',
                  labelStyle: TextStyle(color: c.inkSec),
                  hintText: '粘贴或输入小说内容...',
                  hintStyle: TextStyle(color: c.inkSec.withValues(alpha: 0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  fillColor: c.surface,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: c.inkSec),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (content.isNotEmpty) {
                context.read<BookProvider>().addBook(title, content);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: c.accent),
            child: Text('添加', style: TextStyle(color: c.ink)),
          ),
        ],
      ),
    );
  }

  void _pickFile(BuildContext context) {
    context.read<BookProvider>().pickAndAddBook();
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final MoonlitTheme c;
  final VoidCallback onQuote;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.c,
    required this.onQuote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Estimate character count excluding whitespace
    final charCount = book.content.replaceAll(RegExp(r'\s+'), '').length;
    final wordCount = book.content.split(RegExp(r'\s+')).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: c.border,
          width: 0.5,
        ),
      ),
      color: c.paper,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onQuote,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: c.gold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: c.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$charCount 字 · 约 $wordCount 词',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.inkSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quote button
                  _ActionButton(
                    icon: Icons.format_quote_rounded,
                    label: '引用',
                    color: c.accent,
                    onTap: onQuote,
                  ),
                  const SizedBox(width: 4),
                  // Delete button
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: '',
                    color: c.inkSec,
                    onTap: onDelete,
                  ),
                ],
              ),
              // Preview
              if (book.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    book.preview,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: c.inkSec,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 10, color: color),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBookSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddByText;
  final VoidCallback onAddByFile;

  const _AddBookSheet({
    required this.isDark,
    required this.onAddByText,
    required this.onAddByFile,
  });

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '添加书籍',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.ink),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.content_paste_rounded,
                color: c.accent,
              ),
            ),
            title: Text('粘贴文本', style: TextStyle(color: c.ink)),
            subtitle: Text('复制小说内容，直接粘贴进来', style: TextStyle(color: c.inkSec)),
            trailing: Icon(Icons.chevron_right_rounded, color: c.inkSec),
            onTap: onAddByText,
          ),
          Divider(color: c.border, indent: 72, endIndent: 16),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.file_upload_outlined,
                color: c.gold,
              ),
            ),
            title: Text('上传文件', style: TextStyle(color: c.ink)),
            subtitle: Text('支持 .txt 格式', style: TextStyle(color: c.inkSec)),
            trailing: Icon(Icons.chevron_right_rounded, color: c.inkSec),
            onTap: onAddByFile,
          ),
        ],
      ),
    );
  }
}
