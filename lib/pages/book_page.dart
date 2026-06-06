import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/chat_provider.dart';
import '../models/book.dart';
import '../models/theme_scheme.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookProvider = context.watch<BookProvider>();
    final scheme = context.watch<ChatProvider>().currentScheme;
    final books = bookProvider.books;

    return Scaffold(
      backgroundColor: isDark ? scheme.darkBgColorObj : scheme.bgColorObj,
      appBar: AppBar(
        backgroundColor: isDark ? scheme.darkCardBgColorObj : scheme.cardBgColorObj,
        elevation: 0,
        title: Row(
          children: [
            const Text('我的书库'),
            if (books.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '(${books.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookSheet(context, isDark),
        backgroundColor: isDark ? Colors.blue.shade600 : Colors.blue.shade500,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('添加书籍', style: TextStyle(color: Colors.white)),
      ),
      body: books.isEmpty ? _buildEmptyState(isDark) : _buildBookList(isDark, books, bookProvider),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 72,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '书库还空空的',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加小说或文本',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(bool isDark, List<Book> books, BookProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookCard(
          book: book,
          isDark: isDark,
          onQuote: () => Navigator.pop(context, book),
          onDelete: () => _confirmDelete(context, provider, book),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, BookProvider provider, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除书籍'),
        content: Text('确定要删除「${book.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.removeBook(book.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('粘贴文本'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '书名',
                  hintText: '输入书名...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: '文本内容',
                  hintText: '粘贴或输入小说内容...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
            child: const Text('添加'),
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
  final bool isDark;
  final VoidCallback onQuote;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.isDark,
    required this.onQuote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Estimate character count excluding whitespace
    final charCount = book.content.replaceAll(RegExp(r'\s+'), '').length;
    final wordCount = book.content.split(RegExp(r'\s+')).length;
    final scheme = context.read<ChatProvider>().currentScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? scheme.darkCardBgColorObj.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      color: isDark ? scheme.darkCardBgColorObj : scheme.cardBgColorObj,
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
                      color: isDark ? Colors.amber.shade800.withValues(alpha: 0.2) : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
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
                            color: isDark ? Colors.grey.shade200 : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$charCount 字 · 约 $wordCount 词',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quote button
                  _ActionButton(
                    icon: Icons.format_quote_rounded,
                    label: '引用',
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                    onTap: onQuote,
                  ),
                  const SizedBox(width: 4),
                  // Delete button
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: '',
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    book.preview,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
    final scheme = context.read<ChatProvider>().currentScheme;
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      decoration: BoxDecoration(
        color: isDark ? scheme.darkCardBgColorObj : scheme.cardBgColorObj,
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
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '添加书籍',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.shade800.withValues(alpha: 0.2) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.content_paste_rounded,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
            ),
            title: const Text('粘贴文本'),
            subtitle: const Text('复制小说内容，直接粘贴进来'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onAddByText,
          ),
          const Divider(indent: 72, endIndent: 16),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.green.shade800.withValues(alpha: 0.2) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.file_upload_outlined,
                color: isDark ? Colors.green.shade300 : Colors.green.shade700,
              ),
            ),
            title: const Text('上传文件'),
            subtitle: const Text('支持 .txt 格式'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onAddByFile,
          ),
        ],
      ),
    );
  }
}
