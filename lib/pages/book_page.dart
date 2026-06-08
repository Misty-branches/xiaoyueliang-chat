     1|import 'package:flutter/material.dart';
     2|import 'package:provider/provider.dart';
     3|import '../providers/book_provider.dart';
     4|import '../providers/chat_provider.dart';
     5|import '../models/book.dart';
     6|import '../models/unified_theme.dart';
     7|
     8|class BookPage extends StatefulWidget {
     9|  const BookPage({super.key});
    10|
    11|  @override
    12|  State<BookPage> createState() => _BookPageState();
    13|}
    14|
    15|class _BookPageState extends State<BookPage> {
    16|  @override
    17|  Widget build(BuildContext context) {
    18|    final isDark = Theme.of(context).brightness == Brightness.dark;
    19|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    20|    final bookProvider = context.watch<BookProvider>();
    21|    final books = bookProvider.books;
    22|
    23|    return Scaffold(
    24|      backgroundColor: c.bg,
    25|      appBar: AppBar(
    26|        backgroundColor: c.surface,
    27|        elevation: 0,
    28|        title: Row(
    29|          children: [
    30|            Text(
    31|              '我的书库',
    32|              style: TextStyle(color: c.ink),
    33|            ),
    34|            if (books.isNotEmpty)
    35|              Padding(
    36|                padding: const EdgeInsets.only(left: 8),
    37|                child: Text(
    38|                  '(${books.length})',
    39|                  style: TextStyle(
    40|                    fontSize: 14,
    41|                    color: c.inkSec,
    42|                  ),
    43|                ),
    44|              ),
    45|          ],
    46|        ),
    47|      ),
    48|      floatingActionButton: FloatingActionButton.extended(
    49|        onPressed: () => _showAddBookSheet(context, isDark),
    50|        backgroundColor: c.accent,
    51|        icon: const Icon(Icons.add_rounded, color: Colors.white),
    52|        label: const Text('添加书籍', style: TextStyle(color: Colors.white)),
    53|      ),
    54|      body: books.isEmpty ? _buildEmptyState(c) : _buildBookList(c, books, bookProvider),
    55|    );
    56|  }
    57|
    58|  Widget _buildEmptyState(MoonlitTheme c) {
    59|    return Center(
    60|      child: Column(
    61|        mainAxisAlignment: MainAxisAlignment.center,
    62|        children: [
    63|          Icon(
    64|            Icons.menu_book_rounded,
    65|            size: 72,
    66|            color: c.border,
    67|          ),
    68|          const SizedBox(height: 16),
    69|          Text(
    70|            '书库还空空的',
    71|            style: TextStyle(
    72|              fontSize: 18,
    73|              fontWeight: FontWeight.w500,
    74|              color: c.inkSec,
    75|            ),
    76|          ),
    77|          const SizedBox(height: 8),
    78|          Text(
    79|            '点击下方按钮添加小说或文本',
    80|            style: TextStyle(
    81|              fontSize: 14,
    82|              color: c.inkSec.withValues(alpha: 0.65),
    83|            ),
    84|          ),
    85|        ],
    86|      ),
    87|    );
    88|  }
    89|
    90|  Widget _buildBookList(MoonlitTheme c, List<Book> books, BookProvider provider) {
    91|    return ListView.builder(
    92|      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
    93|      itemCount: books.length,
    94|      itemBuilder: (context, index) {
    95|        final book = books[index];
    96|        return _BookCard(
    97|          book: book,
    98|          c: c,
    99|          onQuote: () => Navigator.pop(context, book),
   100|          onDelete: () => _confirmDelete(context, provider, book),
   101|        );
   102|      },
   103|    );
   104|  }
   105|
   106|  void _confirmDelete(BuildContext context, BookProvider provider, Book book) {
   107|    final isDark = Theme.of(context).brightness == Brightness.dark;
   108|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   109|    showDialog(
   110|      context: context,
   111|      builder: (ctx) => AlertDialog(
   112|        backgroundColor: c.paper,
   113|        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   114|        title: Text('删除书籍', style: TextStyle(color: c.ink)),
   115|        content: Text('确定要删除「${book.title}」吗？', style: TextStyle(color: c.inkSec)),
   116|        actions: [
   117|          TextButton(
   118|            onPressed: () => Navigator.pop(ctx),
   119|            style: TextButton.styleFrom(foregroundColor: c.inkSec),
   120|            child: const Text('取消'),
   121|          ),
   122|          TextButton(
   123|            onPressed: () {
   124|              provider.removeBook(book.id);
   125|              Navigator.pop(ctx);
   126|            },
   127|            style: TextButton.styleFrom(foregroundColor: c.warm),
   128|            child: const Text('删除'),
   129|          ),
   130|        ],
   131|      ),
   132|    );
   133|  }
   134|
   135|  void _showAddBookSheet(BuildContext context, bool isDark) {
   136|    showModalBottomSheet(
   137|      context: context,
   138|      isScrollControlled: true,
   139|      backgroundColor: Colors.transparent,
   140|      builder: (ctx) => _AddBookSheet(
   141|        isDark: isDark,
   142|        onAddByText: () {
   143|          Navigator.pop(ctx);
   144|          _showTextInputDialog(context, isDark);
   145|        },
   146|        onAddByFile: () {
   147|          Navigator.pop(ctx);
   148|          _pickFile(context);
   149|        },
   150|      ),
   151|    );
   152|  }
   153|
   154|  void _showTextInputDialog(BuildContext context, bool isDark) {
   155|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   156|    final titleController = TextEditingController();
   157|    final contentController = TextEditingController();
   158|
   159|    showDialog(
   160|      context: context,
   161|      builder: (ctx) => AlertDialog(
   162|        backgroundColor: c.paper,
   163|        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   164|        title: Text('粘贴文本', style: TextStyle(color: c.ink)),
   165|        content: SizedBox(
   166|          width: double.maxFinite,
   167|          child: Column(
   168|            mainAxisSize: MainAxisSize.min,
   169|            children: [
   170|              TextField(
   171|                controller: titleController,
   172|                style: TextStyle(color: c.ink),
   173|                decoration: InputDecoration(
   174|                  labelText: '书名',
   175|                  labelStyle: TextStyle(color: c.inkSec),
   176|                  hintText: '输入书名...',
   177|                  hintStyle: TextStyle(color: c.inkSec.withValues(alpha: 0.6)),
   178|                  border: OutlineInputBorder(
   179|                    borderRadius: BorderRadius.circular(12),
   180|                    borderSide: BorderSide(color: c.border),
   181|                  ),
   182|                  enabledBorder: OutlineInputBorder(
   183|                    borderRadius: BorderRadius.circular(12),
   184|                    borderSide: BorderSide(color: c.border),
   185|                  ),
   186|                  focusedBorder: OutlineInputBorder(
   187|                    borderRadius: BorderRadius.circular(12),
   188|                    borderSide: BorderSide(color: c.accent, width: 2),
   189|                  ),
   190|                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
   191|                  fillColor: c.surface,
   192|                  filled: true,
   193|                ),
   194|              ),
   195|              const SizedBox(height: 12),
   196|              TextField(
   197|                controller: contentController,
   198|                maxLines: 8,
   199|                style: TextStyle(color: c.ink),
   200|                decoration: InputDecoration(
   201|                  labelText: '文本内容',
   202|                  labelStyle: TextStyle(color: c.inkSec),
   203|                  hintText: '粘贴或输入小说内容...',
   204|                  hintStyle: TextStyle(color: c.inkSec.withValues(alpha: 0.6)),
   205|                  border: OutlineInputBorder(
   206|                    borderRadius: BorderRadius.circular(12),
   207|                    borderSide: BorderSide(color: c.border),
   208|                  ),
   209|                  enabledBorder: OutlineInputBorder(
   210|                    borderRadius: BorderRadius.circular(12),
   211|                    borderSide: BorderSide(color: c.border),
   212|                  ),
   213|                  focusedBorder: OutlineInputBorder(
   214|                    borderRadius: BorderRadius.circular(12),
   215|                    borderSide: BorderSide(color: c.accent, width: 2),
   216|                  ),
   217|                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
   218|                  fillColor: c.surface,
   219|                  filled: true,
   220|                ),
   221|              ),
   222|            ],
   223|          ),
   224|        ),
   225|        actions: [
   226|          TextButton(
   227|            onPressed: () => Navigator.pop(ctx),
   228|            style: TextButton.styleFrom(foregroundColor: c.inkSec),
   229|            child: const Text('取消'),
   230|          ),
   231|          FilledButton(
   232|            onPressed: () {
   233|              final title = titleController.text.trim();
   234|              final content = contentController.text.trim();
   235|              if (content.isNotEmpty) {
   236|                context.read<BookProvider>().addBook(title, content);
   237|              }
   238|              Navigator.pop(ctx);
   239|            },
   240|            style: FilledButton.styleFrom(backgroundColor: c.accent),
   241|            child: Text('添加', style: TextStyle(color: c.ink)),
   242|          ),
   243|        ],
   244|      ),
   245|    );
   246|  }
   247|
   248|  void _pickFile(BuildContext context) {
   249|    context.read<BookProvider>().pickAndAddBook();
   250|  }
   251|}
   252|
   253|class _BookCard extends StatelessWidget {
   254|  final Book book;
   255|  final MoonlitTheme c;
   256|  final VoidCallback onQuote;
   257|  final VoidCallback onDelete;
   258|
   259|  const _BookCard({
   260|    required this.book,
   261|    required this.c,
   262|    required this.onQuote,
   263|    required this.onDelete,
   264|  });
   265|
   266|  @override
   267|  Widget build(BuildContext context) {
   268|    // Estimate character count excluding whitespace
   269|    final charCount = book.content.replaceAll(RegExp(r'\s+'), '').length;
   270|    final wordCount = book.content.split(RegExp(r'\s+')).length;
   271|
   272|    return Card(
   273|      margin: const EdgeInsets.only(bottom: 12),
   274|      elevation: 0,
   275|      shape: RoundedRectangleBorder(
   276|        borderRadius: BorderRadius.circular(16),
   277|        side: BorderSide(
   278|          color: c.border,
   279|          width: 0.5,
   280|        ),
   281|      ),
   282|      color: c.paper,
   283|      child: InkWell(
   284|        borderRadius: BorderRadius.circular(16),
   285|        onTap: onQuote,
   286|        child: Padding(
   287|          padding: const EdgeInsets.all(16),
   288|          child: Column(
   289|            crossAxisAlignment: CrossAxisAlignment.start,
   290|            children: [
   291|              // Title row
   292|              Row(
   293|                children: [
   294|                  Container(
   295|                    width: 44,
   296|                    height: 44,
   297|                    decoration: BoxDecoration(
   298|                      color: c.gold.withValues(alpha: 0.15),
   299|                      borderRadius: BorderRadius.circular(12),
   300|                    ),
   301|                    child: Icon(
   302|                      Icons.auto_stories_rounded,
   303|                      color: c.gold,
   304|                      size: 22,
   305|                    ),
   306|                  ),
   307|                  const SizedBox(width: 12),
   308|                  Expanded(
   309|                    child: Column(
   310|                      crossAxisAlignment: CrossAxisAlignment.start,
   311|                      children: [
   312|                        Text(
   313|                          book.title,
   314|                          style: TextStyle(
   315|                            fontSize: 16,
   316|                            fontWeight: FontWeight.w600,
   317|                            color: c.ink,
   318|                          ),
   319|                          overflow: TextOverflow.ellipsis,
   320|                        ),
   321|                        const SizedBox(height: 2),
   322|                        Text(
   323|                          '$charCount 字 · 约 $wordCount 词',
   324|                          style: TextStyle(
   325|                            fontSize: 12,
   326|                            color: c.inkSec,
   327|                          ),
   328|                        ),
   329|                      ],
   330|                    ),
   331|                  ),
   332|                  // Quote button
   333|                  _ActionButton(
   334|                    icon: Icons.format_quote_rounded,
   335|                    label: '引用',
   336|                    color: c.accent,
   337|                    onTap: onQuote,
   338|                  ),
   339|                  const SizedBox(width: 4),
   340|                  // Delete button
   341|                  _ActionButton(
   342|                    icon: Icons.delete_outline_rounded,
   343|                    label: '',
   344|                    color: c.inkSec,
   345|                    onTap: onDelete,
   346|                  ),
   347|                ],
   348|              ),
   349|              // Preview
   350|              if (book.content.isNotEmpty) ...[
   351|                const SizedBox(height: 12),
   352|                Container(
   353|                  width: double.infinity,
   354|                  padding: const EdgeInsets.all(12),
   355|                  decoration: BoxDecoration(
   356|                    color: c.accentLight,
   357|                    borderRadius: BorderRadius.circular(10),
   358|                  ),
   359|                  child: Text(
   360|                    book.preview,
   361|                    style: TextStyle(
   362|                      fontSize: 13,
   363|                      height: 1.5,
   364|                      color: c.inkSec,
   365|                    ),
   366|                    maxLines: 3,
   367|                    overflow: TextOverflow.ellipsis,
   368|                  ),
   369|                ),
   370|              ],
   371|            ],
   372|          ),
   373|        ),
   374|      ),
   375|    );
   376|  }
   377|}
   378|
   379|class _ActionButton extends StatelessWidget {
   380|  final IconData icon;
   381|  final String label;
   382|  final Color color;
   383|  final VoidCallback onTap;
   384|
   385|  const _ActionButton({
   386|    required this.icon,
   387|    required this.label,
   388|    required this.color,
   389|    required this.onTap,
   390|  });
   391|
   392|  @override
   393|  Widget build(BuildContext context) {
   394|    return Material(
   395|      color: Colors.transparent,
   396|      child: InkWell(
   397|        borderRadius: BorderRadius.circular(8),
   398|        onTap: onTap,
   399|        child: Padding(
   400|          padding: const EdgeInsets.all(6),
   401|          child: Column(
   402|            mainAxisSize: MainAxisSize.min,
   403|            children: [
   404|              Icon(icon, size: 20, color: color),
   405|              if (label.isNotEmpty)
   406|                Padding(
   407|                  padding: const EdgeInsets.only(top: 2),
   408|                  child: Text(
   409|                    label,
   410|                    style: TextStyle(fontSize: 10, color: color),
   411|                  ),
   412|                ),
   413|            ],
   414|          ),
   415|        ),
   416|      ),
   417|    );
   418|  }
   419|}
   420|
   421|class _AddBookSheet extends StatelessWidget {
   422|  final bool isDark;
   423|  final VoidCallback onAddByText;
   424|  final VoidCallback onAddByFile;
   425|
   426|  const _AddBookSheet({
   427|    required this.isDark,
   428|    required this.onAddByText,
   429|    required this.onAddByFile,
   430|  });
   431|
   432|  @override
   433|  Widget build(BuildContext context) {
   434|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   435|    return Container(
   436|      padding: const EdgeInsets.only(top: 8, bottom: 32),
   437|      decoration: BoxDecoration(
   438|        color: c.paper,
   439|        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
   440|      ),
   441|      child: Column(
   442|        mainAxisSize: MainAxisSize.min,
   443|        children: [
   444|          // Handle
   445|          Container(
   446|            width: 36,
   447|            height: 4,
   448|            decoration: BoxDecoration(
   449|              color: c.border,
   450|              borderRadius: BorderRadius.circular(2),
   451|            ),
   452|          ),
   453|          const SizedBox(height: 20),
   454|          Text(
   455|            '添加书籍',
   456|            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.ink),
   457|          ),
   458|          const SizedBox(height: 24),
   459|          ListTile(
   460|            leading: Container(
   461|              width: 44,
   462|              height: 44,
   463|              decoration: BoxDecoration(
   464|                color: c.accent.withValues(alpha: 0.15),
   465|                borderRadius: BorderRadius.circular(12),
   466|              ),
   467|              child: Icon(
   468|                Icons.content_paste_rounded,
   469|                color: c.accent,
   470|              ),
   471|            ),
   472|            title: Text('粘贴文本', style: TextStyle(color: c.ink)),
   473|            subtitle: Text('复制小说内容，直接粘贴进来', style: TextStyle(color: c.inkSec)),
   474|            trailing: Icon(Icons.chevron_right_rounded, color: c.inkSec),
   475|            onTap: onAddByText,
   476|          ),
   477|          Divider(color: c.border, indent: 72, endIndent: 16),
   478|          ListTile(
   479|            leading: Container(
   480|              width: 44,
   481|              height: 44,
   482|              decoration: BoxDecoration(
   483|                color: c.gold.withValues(alpha: 0.15),
   484|                borderRadius: BorderRadius.circular(12),
   485|              ),
   486|              child: Icon(
   487|                Icons.file_upload_outlined,
   488|                color: c.gold,
   489|              ),
   490|            ),
   491|            title: Text('上传文件', style: TextStyle(color: c.ink)),
   492|            subtitle: Text('支持 .txt 格式', style: TextStyle(color: c.inkSec)),
   493|            trailing: Icon(Icons.chevron_right_rounded, color: c.inkSec),
   494|            onTap: onAddByFile,
   495|          ),
   496|        ],
   497|      ),
   498|    );
   499|  }
   500|}
   501|