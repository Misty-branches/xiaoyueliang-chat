     1|import 'package:flutter/material.dart';
     2|import 'package:provider/provider.dart';
     3|import 'package:xiayue_chat/providers/chat_provider.dart';
     4|import 'package:xiayue_chat/providers/reading_provider.dart';
     5|import 'package:xiayue_chat/models/theme_scheme.dart';
     6|import '../models/unified_theme.dart';
     7|import '../widgets/message_bubble.dart';
     8|import '../widgets/input_bar.dart';
     9|
    10|class ChatPage extends StatefulWidget {
    11|  const ChatPage({super.key});
    12|
    13|  @override
    14|  State<ChatPage> createState() => _ChatPageState();
    15|}
    16|
    17|class _ChatPageState extends State<ChatPage> {
    18|  final ScrollController _scrollController = ScrollController();
    19|
    20|  @override
    21|  void initState() {
    22|    super.initState();
    23|    _scrollToBottom();
    24|  }
    25|
    26|  void _scrollToBottom() {
    27|    WidgetsBinding.instance.addPostFrameCallback((_) {
    28|      if (_scrollController.hasClients) {
    29|        _scrollController.animateTo(
    30|          _scrollController.position.maxScrollExtent,
    31|          duration: const Duration(milliseconds: 300),
    32|          curve: Curves.easeOut,
    33|        );
    34|      }
    35|    });
    36|  }
    37|
    38|  void _handleSend(String text) {
    39|    final provider = context.read<ChatProvider>();
    40|    provider.sendMessage(text);
    41|    _scrollToBottom();
    42|  }
    43|
    44|  String _formatDate(DateTime dt) {
    45|    final days = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    46|    return '${dt.month}月${dt.day}日 ${days[dt.weekday - 1]}';
    47|  }
    48|
    49|  @override
    50|  void dispose() {
    51|    _scrollController.dispose();
    52|    super.dispose();
    53|  }
    54|
    55|  @override
    56|  Widget build(BuildContext context) {
    57|    final isDark = Theme.of(context).brightness == Brightness.dark;
    58|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    59|    final chatProvider = context.watch<ChatProvider>();
    60|    final readingProvider = context.watch<ReadingProvider>();
    61|    final session = chatProvider.currentSession;
    62|    final settings = chatProvider.settings;
    63|    final scheme = chatProvider.currentScheme;
    64|    final topInset = MediaQuery.of(context).padding.top;
    65|
    66|    return Scaffold(
    67|      backgroundColor: Colors.transparent,
    68|      body: Container(
    69|        decoration: BoxDecoration(
    70|          gradient: _buildBgGradient(isDark, c),
    71|        ),
    72|        child: SafeArea(
    73|          top: false,
    74|          child: Column(
    75|            children: [
    76|              SizedBox(height: topInset > 0 ? topInset : 8),
    77|
    78|              // ===== 顶栏 =====
    79|              _buildHeader(c),
    80|
    81|              // ===== 聊天卡片 =====
    82|              Expanded(
    83|                child: Container(
    84|                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    85|                  decoration: BoxDecoration(
    86|                    color: c.paper,
    87|                    borderRadius: BorderRadius.circular(20),
    88|                    boxShadow: [
    89|                      BoxShadow(
    90|                        color: c.shadow,
    91|                        blurRadius: 20,
    92|                        offset: const Offset(0, 4),
    93|                      ),
    94|                    ],
    95|                  ),
    96|                  child: Column(
    97|                    children: [
    98|
    99|                      // 消息列表
   100|                      Expanded(
   101|                        child: session == null || session.messages.isEmpty
   102|                            ? _buildEmptyState(isDark, c, readingProvider, scheme)
   103|                            : ListView.builder(
   104|                                controller: _scrollController,
   105|                                padding: const EdgeInsets.symmetric(vertical: 8),
   106|                                itemCount: session.messages.length,
   107|                                itemBuilder: (context, index) {
   108|                                  final msg = session.messages[index];
   109|
   110|                                  // 日期分割
   111|                                  final widgets = <Widget>[];
   112|                                  if (index == 0 || _isNewDay(session.messages[index - 1].timestamp, msg.timestamp)) {
   113|                                    widgets.add(
   114|                                      _buildDateDivider(
   115|                                        _formatDate(msg.timestamp),
   116|                                        c,
   117|                                      ),
   118|                                    );
   119|                                  }
   120|
   121|                                  widgets.add(MessageBubble(
   122|                                    message: msg,
   123|                                    avatarUser: settings.avatarUser,
   124|                                    avatarXia: settings.avatarXia,
   125|                                    userBubbleColor: scheme.userBubbleColorObj,
   126|                                    xiaBubbleColor: scheme.xiaBubbleColorObj,
   127|                                    primaryColor: scheme.primaryColorObj,
   128|                                    onDelete: () => chatProvider.deleteMessage(index),
   129|                                    onRegenerate: () {
   130|                                      if (index > 0 && session.messages.length > index) {
   131|                                        final userMsg = session.messages[index - 1];
   132|                                        chatProvider.deleteMessage(index);
   133|                                        chatProvider.sendMessage(userMsg.content);
   134|                                      }
   135|                                    },
   136|                                    onRead: () {},
   137|                                    onEdit: () {},
   138|                                    onFavorite: () {},
   139|                                    onShare: () {},
   140|                                  ));
   141|
   142|                                  return Column(children: widgets);
   143|                                },
   144|                              ),
   145|                      ),
   146|
   147|                      // Loading indicator
   148|                      if (chatProvider.isLoading)
   149|                        const Padding(
   150|                          padding: EdgeInsets.symmetric(vertical: 6),
   151|                          child: SizedBox(
   152|                            width: 18, height: 18,
   153|                            child: CircularProgressIndicator(strokeWidth: 2),
   154|                          ),
   155|                        ),
   156|
   157|                      // 输入区
   158|                      InputBar(
   159|                        isStreaming: chatProvider.isStreaming,
   160|                        referencedBook: chatProvider.referencedBook,
   161|                        onSend: _handleSend,
   162|                        onCancel: () => chatProvider.cancelStreaming(),
   163|                        onClearReference: () => chatProvider.clearReferenceBook(),
   164|                      ),
   165|                    ],
   166|                  ),
   167|                ),
   168|              ),
   169|            ],
   170|          ),
   171|        ),
   172|      ),
   173|
   174|      // ===== 会话抽屉（保留） =====
   175|      drawer: _buildSessionDrawer(context, isDark, c, chatProvider, scheme),
   176|    );
   177|  }
   178|
   179|  // ===== 顶栏 =====
   180|  Widget _buildHeader(MoonlitTheme c) {
   181|    return Padding(
   182|      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
   183|      child: Row(
   184|        children: [
   185|          // X 关闭按钮（圆形描边）
   186|          GestureDetector(
   187|            onTap: () => Navigator.pop(context),
   188|            child: Container(
   189|              width: 36,
   190|              height: 36,
   191|              decoration: BoxDecoration(
   192|                shape: BoxShape.circle,
   193|                border: Border.all(color: c.border, width: 1.5),
   194|                color: c.paper,
   195|              ),
   196|              child: Icon(Icons.close_rounded, size: 18, color: c.inkSec),
   197|            ),
   198|          ),
   199|          const Spacer(),
   200|          // 标题 + 副标题
   201|          Column(
   202|            mainAxisSize: MainAxisSize.min,
   203|            children: [
   204|              Text(
   205|                '小月亮 · 月下窗',
   206|                style: TextStyle(
   207|                  fontFamily: 'Noto Serif SC',
   208|                  fontSize: 17,
   209|                  fontWeight: FontWeight.w700,
   210|                  color: c.ink,
   211|                  letterSpacing: 1.2,
   212|                ),
   213|              ),
   214|              Text(
   215|                ' 在线 · 月光正好',
   216|                style: TextStyle(
   217|                  fontSize: 11,
   218|                  color: c.inkSec,
   219|                  letterSpacing: 0.5,
   220|                ),
   221|              ),
   222|            ],
   223|          ),
   224|          const Spacer(),
   225|          // ... 菜单按钮（圆形描边）
   226|          GestureDetector(
   227|            onTap: () => Scaffold.of(context).openDrawer(),
   228|            child: Container(
   229|              width: 36,
   230|              height: 36,
   231|              decoration: BoxDecoration(
   232|                shape: BoxShape.circle,
   233|                border: Border.all(color: c.border, width: 1.5),
   234|                color: c.paper,
   235|              ),
   236|              child: Icon(Icons.more_horiz_rounded, size: 18, color: c.inkSec),
   237|            ),
   238|          ),
   239|        ],
   240|      ),
   241|    );
   242|  }
   243|
   244|  // ===== 聊天卡片顶部的头像 + 状态 =====
   245|  Widget _buildChatProfile(MoonlitTheme c) {
   246|    return Container(
   247|      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
   248|      child: Row(
   249|        children: [
   250|          // 弯月头像
   251|          Container(
   252|            width: 40,
   253|            height: 40,
   254|            decoration: BoxDecoration(
   255|              shape: BoxShape.circle,
   256|              color: c.accentLight,
   257|              border: Border.all(color: c.border, width: 1),
   258|            ),
   259|            child: Icon(Icons.circle_rounded, size: 22, color: c.gold),
   260|          ),
   261|          const SizedBox(width: 10),
   262|          // 名称 + 状态
   263|          Expanded(
   264|            child: Column(
   265|              crossAxisAlignment: CrossAxisAlignment.start,
   266|              children: [
   267|                Text(
   268|                  '小月亮·月下窗',
   269|                  style: TextStyle(
   270|                    fontSize: 15,
   271|                    fontWeight: FontWeight.w600,
   272|                    color: c.ink,
   273|                  ),
   274|                ),
   275|                const SizedBox(height: 2),
   276|                Text(
   277|                  '在线·月光正好',
   278|                  style: TextStyle(
   279|                    fontSize: 12,
   280|                    color: c.inkSec,
   281|                  ),
   282|                ),
   283|              ],
   284|            ),
   285|          ),
   286|          // 右侧弯月图标
   287|          Container(
   288|            width: 32,
   289|            height: 32,
   290|            decoration: BoxDecoration(
   291|              shape: BoxShape.circle,
   292|              border: Border.all(color: c.border, width: 1),
   293|              color: c.surface,
   294|            ),
   295|            child: Icon(Icons.circle_rounded, size: 16, color: c.gold),
   296|          ),
   297|        ],
   298|      ),
   299|    );
   300|  }
   301|
   302|  // ===== 日期分割线 =====
   303|  Widget _buildDateDivider(String text, MoonlitTheme c) {
   304|    return Padding(
   305|      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
   306|      child: Row(
   307|        children: [
   308|          Expanded(child: Divider(color: c.border, thickness: 0.5)),
   309|          Padding(
   310|            padding: const EdgeInsets.symmetric(horizontal: 10),
   311|            child: Text(
   312|              text,
   313|              style: TextStyle(fontSize: 12, color: c.inkSec),
   314|            ),
   315|          ),
   316|          Expanded(child: Divider(color: c.border, thickness: 0.5)),
   317|        ],
   318|      ),
   319|    );
   320|  }
   321|
   322|  // ===== 空状态 =====
   323|  Widget _buildEmptyState(bool isDark, MoonlitTheme c, ReadingProvider readingProvider, ThemeScheme scheme) {
   324|    if (readingProvider.isReading && readingProvider.currentChapter != null) {
   325|      final ch = readingProvider.currentChapter!;
   326|      return SingleChildScrollView(
   327|        padding: const EdgeInsets.all(16),
   328|        child: Column(
   329|          crossAxisAlignment: CrossAxisAlignment.start,
   330|          children: [
   331|            Container(
   332|              width: double.infinity,
   333|              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
   334|              decoration: BoxDecoration(
   335|                color: c.accentLight,
   336|                borderRadius: BorderRadius.circular(8),
   337|              ),
   338|              child: Text(
   339|                readingProvider.progressText,
   340|                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.accent),
   341|              ),
   342|            ),
   343|            const SizedBox(height: 16),
   344|            Text(
   345|              ch.content,
   346|              style: TextStyle(fontSize: 15, height: 1.8, color: c.ink),
   347|            ),
   348|          ],
   349|        ),
   350|      );
   351|    }
   352|
   353|    return Center(
   354|      child: Column(
   355|        mainAxisAlignment: MainAxisAlignment.center,
   356|        children: [
   357|          Container(
   358|            width: 64, height: 64,
   359|            decoration: BoxDecoration(
   360|              shape: BoxShape.circle,
   361|              color: c.accentLight,
   362|            ),
   363|            child: Icon(Icons.chat_bubble_outline_rounded, size: 32, color: c.accent),
   364|          ),
   365|          const SizedBox(height: 16),
   366|          Text('开始与遐对话', style: TextStyle(fontSize: 16, color: c.ink, fontWeight: FontWeight.w500)),
   367|          const SizedBox(height: 6),
   368|          Text('说点什么吧，月下窗开着呢', style: TextStyle(fontSize: 13, color: c.inkSec)),
   369|        ],
   370|      ),
   371|    );
   372|  }
   373|
   374|  bool _isNewDay(DateTime? prev, DateTime? current) {
   375|    if (prev == null || current == null) return false;
   376|    return prev.year != current.year || prev.month != current.month || prev.day != current.day;
   377|  }
   378|
   379|  // ===== 背景渐变 =====
   380|  RadialGradient _buildBgGradient(bool isDark, MoonlitTheme c) {
   381|    return RadialGradient(
   382|      center: Alignment.center,
   383|      radius: 1.3,
   384|      colors: [c.surface, c.bg],
   385|      stops: const [0.0, 1.0],
   386|    );
   387|  }
   388|
   389|  // ===== 会话抽屉 =====
   390|  Widget _buildSessionDrawer(BuildContext context, bool isDark, MoonlitTheme c, ChatProvider provider, ThemeScheme scheme) {
   391|    return Drawer(
   392|      backgroundColor: c.paper,
   393|      child: SafeArea(
   394|        child: Column(
   395|          crossAxisAlignment: CrossAxisAlignment.start,
   396|          children: [
   397|            Container(
   398|              padding: const EdgeInsets.all(20),
   399|              child: Column(
   400|                crossAxisAlignment: CrossAxisAlignment.start,
   401|                children: [
   402|                  Row(
   403|                    children: [
   404|                      CircleAvatar(
   405|                        radius: 24,
   406|                        backgroundColor: c.accentLight,
   407|                        child: Text('遐', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.accent)),
   408|                      ),
   409|                      const SizedBox(width: 12),
   410|                      Column(
   411|                        crossAxisAlignment: CrossAxisAlignment.start,
   412|                        children: [
   413|                          Text('遐悦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.ink)),
   414|                          Text('小满 & 遐', style: TextStyle(fontSize: 13, color: c.inkSec)),
   415|                        ],
   416|                      ),
   417|                    ],
   418|                  ),
   419|                  const SizedBox(height: 16),
   420|                  SizedBox(
   421|                    width: double.infinity,
   422|                    child: TextButton.icon(
   423|                      onPressed: () { provider.newSession(); Navigator.pop(context); },
   424|                      icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
   425|                      label: Text('新建对话', style: TextStyle(color: c.accent)),
   426|                      style: TextButton.styleFrom(
   427|                        backgroundColor: c.accentLight,
   428|                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
   429|                        padding: const EdgeInsets.symmetric(vertical: 10),
   430|                      ),
   431|                    ),
   432|                  ),
   433|                  const SizedBox(height: 8),
   434|                  SizedBox(
   435|                    width: double.infinity,
   436|                    child: TextButton.icon(
   437|                      onPressed: () async {
   438|                        Navigator.pop(context);
   439|                        final result = await Navigator.pushNamed(context, '/book');
   440|                        if (result != null && context.mounted) {}
   441|                      },
   442|                      icon: Icon(Icons.auto_stories_rounded, size: 18, color: c.warm),
   443|                      label: Text('我的书库', style: TextStyle(color: c.warm)),
   444|                      style: TextButton.styleFrom(
   445|                        backgroundColor: c.warm.withValues(alpha: 0.3),
   446|                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
   447|                        padding: const EdgeInsets.symmetric(vertical: 10),
   448|                      ),
   449|                    ),
   450|                  ),
   451|                ],
   452|              ),
   453|            ),
   454|            Divider(height: 1, color: c.border),
   455|            Expanded(
   456|              child: provider.sessions.isEmpty
   457|                  ? Center(child: Text('暂无对话', style: TextStyle(color: c.inkSec)))
   458|                  : ListView.builder(
   459|                      padding: const EdgeInsets.symmetric(vertical: 8),
   460|                      itemCount: provider.sessions.length,
   461|                      itemBuilder: (context, index) {
   462|                        final session = provider.sessions[index];
   463|                        final isActive = session.id == provider.currentSession?.id;
   464|                        return ListTile(
   465|                          selected: isActive,
   466|                          selectedTileColor: c.accentLight,
   467|                          leading: Icon(
   468|                            Icons.chat_rounded, size: 20,
   469|                            color: isActive ? c.accent : c.inkSec,
   470|                          ),
   471|                          title: Text(
   472|                            session.title,
   473|                            style: TextStyle(
   474|                              fontSize: 14,
   475|                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
   476|                              color: c.ink,
   477|                            ),
   478|                            overflow: TextOverflow.ellipsis,
   479|                          ),
   480|                          subtitle: Text(
   481|                            session.lastMessagePreview,
   482|                            style: TextStyle(fontSize: 12, color: c.inkSec),
   483|                            overflow: TextOverflow.ellipsis,
   484|                            maxLines: 1,
   485|                          ),
   486|                          onTap: () {
   487|                            provider.switchSession(session.id);
   488|                            Navigator.pop(context);
   489|                          },
   490|                          trailing: IconButton(
   491|                            icon: Icon(Icons.delete_outline_rounded, size: 18, color: c.inkSec),
   492|                            onPressed: () => provider.deleteSession(session.id),
   493|                          ),
   494|                        );
   495|                      },
   496|                    ),
   497|            ),
   498|          ],
   499|        ),
   500|      ),
   501|