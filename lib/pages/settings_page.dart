     1|import 'dart:convert';
     2|import 'dart:io';
     3|import 'dart:typed_data';
     4|import 'package:flutter/material.dart';
     5|import 'package:provider/provider.dart';
     6|import 'package:file_picker/file_picker.dart';
     7|import '../models/settings.dart';
     8|import '../models/theme_scheme.dart';
     9|import '../models/unified_theme.dart';
    10|import '../providers/chat_provider.dart';
    11|
    12|class SettingsPage extends StatefulWidget {
    13|  const SettingsPage({super.key});
    14|
    15|  @override
    16|  State<SettingsPage> createState() => _SettingsPageState();
    17|}
    18|
    19|class _SettingsPageState extends State<SettingsPage> {
    20|  late TextEditingController _apiUrlController;
    21|  late TextEditingController _apiKeyController;
    22|  late TextEditingController _modelController;
    23|  late TextEditingController _systemPromptController;
    24|  late TextEditingController _dataServiceUrlController;
    25|  late double _temperature;
    26|  late int _maxTokens;
    27|  late int _accentColor;
    28|  String _avatarUser = '';
    29|  String _avatarXia = '';
    30|  String _schemeId = 'peach-blossom';
    31|
    32|  @override
    33|  void initState() {
    34|    super.initState();
    35|    final settings = context.read<ChatProvider>().settings;
    36|    _apiUrlController = TextEditingController(text: settings.apiUrl);
    37|    _apiKeyController = TextEditingController(text: settings.apiKey);
    38|    _modelController = TextEditingController(text: settings.model);
    39|    _systemPromptController = TextEditingController(text: settings.systemPrompt);
    40|    _dataServiceUrlController = TextEditingController(text: settings.dataServiceUrl);
    41|    _temperature = settings.temperature;
    42|    _maxTokens = settings.maxTokens;
    43|    _accentColor = settings.accentColor;
    44|    _avatarUser = settings.avatarUser;
    45|    _avatarXia = settings.avatarXia;
    46|    _schemeId = settings.schemeId;
    47|  }
    48|
    49|  @override
    50|  void dispose() {
    51|    _apiUrlController.dispose();
    52|    _apiKeyController.dispose();
    53|    _modelController.dispose();
    54|    _systemPromptController.dispose();
    55|    _dataServiceUrlController.dispose();
    56|    super.dispose();
    57|  }
    58|
    59|  void _saveSettings() {
    60|    final provider = context.read<ChatProvider>();
    61|    provider.updateSettings(AppSettings(
    62|      apiUrl: _apiUrlController.text.trim(),
    63|      apiKey: _apiKeyController.text.trim(),
    64|      model: _modelController.text.trim(),
    65|      temperature: _temperature,
    66|      maxTokens: _maxTokens,
    67|      darkMode: provider.settings.darkMode,
    68|      systemPrompt: _systemPromptController.text.trim(),
    69|      dataServiceUrl: _dataServiceUrlController.text.trim(),
    70|      accentColor: _accentColor,
    71|      avatarUser: _avatarUser,
    72|      avatarXia: _avatarXia,
    73|      schemeId: _schemeId,
    74|    ));
    75|    ScaffoldMessenger.of(context).showSnackBar(
    76|      SnackBar(
    77|        content: const Text('设置已保存'),
    78|        behavior: SnackBarBehavior.floating,
    79|        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    80|        duration: const Duration(seconds: 2),
    81|      ),
    82|    );
    83|  }
    84|
    85|  @override
    86|  Widget build(BuildContext context) {
    87|    final isDark = Theme.of(context).brightness == Brightness.dark;
    88|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    89|    final cs = Theme.of(context).colorScheme;
    90|    final provider = context.watch<ChatProvider>();
    91|    final settings = provider.settings;
    92|    final scheme = provider.currentScheme;
    93|
    94|    return Scaffold(
    95|      backgroundColor: c.bg,
    96|      appBar: AppBar(
    97|        backgroundColor: c.surface,
    98|        elevation: 0,
    99|        title: const Text('设置'),
   100|        actions: [
   101|          TextButton(
   102|            onPressed: _saveSettings,
   103|            child: const Text('保存'),
   104|          ),
   105|        ],
   106|      ),
   107|      body: ListView(
   108|        padding: const EdgeInsets.all(16),
   109|        children: [
   110|          _buildSection(
   111|            isDark,
   112|            'API 配置',
   113|            [
   114|              _buildTextField(
   115|                controller: _apiUrlController,
   116|                label: 'API 服务器地址',
   117|                hint: 'http://你的服务器地址:8642',
   118|                icon: Icons.link_rounded,
   119|                isDark: isDark,
   120|              ),
   121|              const SizedBox(height: 12),
   122|              _buildTextField(
   123|                controller: _apiKeyController,
   124|                label: 'API Key',
   125|                hint: 'sk-...',
   126|                icon: Icons.vpn_key_rounded,
   127|                isDark: isDark,
   128|              ),
   129|              const SizedBox(height: 12),
   130|              _buildTextField(
   131|                controller: _modelController,
   132|                label: '模型名称',
   133|                hint: 'deepseek-v4-flash',
   134|                icon: Icons.memory_rounded,
   135|                isDark: isDark,
   136|              ),
   137|              const SizedBox(height: 12),
   138|              _buildTextField(
   139|                controller: _dataServiceUrlController,
   140|                label: '数据服务地址',
   141|                hint: 'http://你的服务器地址:8643',
   142|                icon: Icons.cloud_rounded,
   143|                isDark: isDark,
   144|              ),
   145|              if (provider.cloudConnected)
   146|                Padding(
   147|                  padding: const EdgeInsets.only(top: 8),
   148|                  child: Row(
   149|                    children: [
   150|                      Icon(Icons.check_circle_rounded, size: 14, color: c.accent),
   151|                      const SizedBox(width: 6),
   152|                      Text(
   153|                        '云端已连接',
   154|                        style: TextStyle(fontSize: 12, color: c.accent),
   155|                      ),
   156|                    ],
   157|                  ),
   158|                ),
   159|            ],
   160|          ),
   161|          const SizedBox(height: 16),
   162|          _buildSection(
   163|            isDark,
   164|            '生成参数',
   165|            [
   166|              _buildSlider(
   167|                isDark: isDark,
   168|                label: '温度 (Temperature)',
   169|                value: _temperature,
   170|                min: 0.0,
   171|                max: 2.0,
   172|                divisions: 40,
   173|                displayValue: _temperature.toStringAsFixed(1),
   174|                onChanged: (v) => setState(() => _temperature = v),
   175|              ),
   176|              const SizedBox(height: 8),
   177|              _buildSlider(
   178|                isDark: isDark,
   179|                label: '最大 Token 数',
   180|                value: _maxTokens.toDouble(),
   181|                min: 256,
   182|                max: 8192,
   183|                divisions: 31,
   184|                displayValue: _maxTokens.toString(),
   185|                onChanged: (v) => setState(() => _maxTokens = v.round()),
   186|              ),
   187|            ],
   188|          ),
   189|          const SizedBox(height: 16),
   190|          _buildSection(
   191|            isDark,
   192|            '系统提示词',
   193|            [
   194|              TextField(
   195|                controller: _systemPromptController,
   196|                maxLines: 5,
   197|                style: TextStyle(
   198|                  fontSize: 14,
   199|                  color: c.ink,
   200|                ),
   201|                decoration: InputDecoration(
   202|                  border: OutlineInputBorder(
   203|                    borderRadius: BorderRadius.circular(12),
   204|                    borderSide: BorderSide.none,
   205|                  ),
   206|                  filled: true,
   207|                  fillColor: c.paper.withValues(alpha: 0.7),
   208|                  hintText: '输入系统提示词...',
   209|                  hintStyle: TextStyle(
   210|                    color: c.inkSec,
   211|                  ),
   212|                ),
   213|              ),
   214|            ],
   215|          ),
   216|          const SizedBox(height: 16),
   217|          _buildSection(
   218|            isDark,
   219|            '主题装扮',
   220|            [
   221|              // 配色方案选择
   222|              _buildSchemeSelector(isDark, cs),
   223|              const SizedBox(height: 16),
   224|              // 头像
   225|              Text('头像', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.inkSec)),
   226|              const SizedBox(height: 10),
   227|              _buildAvatarRow(c, isDark),
   228|              const SizedBox(height: 16),
   229|              // 深色模式
   230|              SwitchListTile(
   231|                contentPadding: EdgeInsets.zero,
   232|                title: Text(
   233|                  '深色模式',
   234|                  style: TextStyle(
   235|                    color: c.ink,
   236|                  ),
   237|                ),
   238|                value: settings.darkMode,
   239|                onChanged: (v) {
   240|                  provider.updateSettings(settings.copyWith(darkMode: v));
   241|                },
   242|                activeColor: c.accent,
   243|              ),
   244|            ],
   245|          ),
   246|          const SizedBox(height: 32),
   247|          // Test connection button
   248|          SizedBox(
   249|            width: double.infinity,
   250|            child: OutlinedButton.icon(
   251|              onPressed: () => _testConnection(context, isDark),
   252|              icon: const Icon(Icons.wifi_find_rounded, size: 18),
   253|              label: const Text('测试连接'),
   254|              style: OutlinedButton.styleFrom(
   255|                padding: const EdgeInsets.symmetric(vertical: 14),
   256|                shape: RoundedRectangleBorder(
   257|                  borderRadius: BorderRadius.circular(12),
   258|                ),
   259|                side: BorderSide(
   260|                  color: c.border,
   261|                ),
   262|              ),
   263|            ),
   264|          ),
   265|          const SizedBox(height: 16),
   266|          Center(
   267|            child: Text(
   268|              '遐悦聊天 v1.0.0',
   269|              style: TextStyle(
   270|                fontSize: 13,
   271|                color: c.inkSec,
   272|              ),
   273|            ),
   274|          ),
   275|        ],
   276|      ),
   277|    );
   278|  }
   279|
   280|  void _testConnection(BuildContext context, bool isDark) async {
   281|    // Simple connectivity test
   282|    try {
   283|      final baseUrl = _apiUrlController.text.trim();
   284|      final uri = Uri.parse('$baseUrl/health');
   285|      final httpClient = HttpClient();
   286|      final request = await httpClient.getUrl(uri);
   287|      final response = await request.close();
   288|      if (context.mounted) {
   289|        ScaffoldMessenger.of(context).showSnackBar(
   290|          SnackBar(
   291|            content: Text(response.statusCode == 200 ? '连接成功!' : '服务器响应: ${response.statusCode}'),
   292|            behavior: SnackBarBehavior.floating,
   293|            backgroundColor: response.statusCode == 200 ? Colors.green : Colors.orange,
   294|            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   295|          ),
   296|        );
   297|      }
   298|    } catch (e) {
   299|      if (context.mounted) {
   300|        ScaffoldMessenger.of(context).showSnackBar(
   301|          SnackBar(
   302|            content: Text('连接失败: $e'),
   303|            behavior: SnackBarBehavior.floating,
   304|            backgroundColor: Colors.red,
   305|            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   306|          ),
   307|        );
   308|      }
   309|    }
   310|  }
   311|
   312|  Widget _buildSection(bool isDark, String title, List<Widget> children) {
   313|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   314|    final borderColor = c.border.withValues(alpha: isDark ? 0.4 : 0.6);
   315|    return Column(
   316|      crossAxisAlignment: CrossAxisAlignment.start,
   317|      children: [
   318|        Padding(
   319|          padding: const EdgeInsets.only(left: 4, bottom: 8),
   320|          child: Text(
   321|            title,
   322|            style: TextStyle(
   323|              fontSize: 13,
   324|              fontWeight: FontWeight.w600,
   325|              color: c.accent.withValues(alpha: 0.7),
   326|              letterSpacing: 0.5,
   327|            ),
   328|          ),
   329|        ),
   330|        Container(
   331|          padding: const EdgeInsets.all(16),
   332|          decoration: BoxDecoration(
   333|            color: c.paper,
   334|            borderRadius: BorderRadius.circular(16),
   335|            border: Border.all(
   336|              color: borderColor,
   337|              width: 0.5,
   338|            ),
   339|          ),
   340|          child: Column(
   341|            crossAxisAlignment: CrossAxisAlignment.start,
   342|            children: children,
   343|          ),
   344|        ),
   345|      ],
   346|    );
   347|  }
   348|
   349|  Widget _buildTextField({
   350|    required TextEditingController controller,
   351|    required String label,
   352|    required String hint,
   353|    required IconData icon,
   354|    required bool isDark,
   355|  }) {
   356|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   357|    return TextField(
   358|      controller: controller,
   359|      style: TextStyle(
   360|        fontSize: 15,
   361|        color: c.ink,
   362|      ),
   363|      decoration: InputDecoration(
   364|        labelText: label,
   365|        hintText: hint,
   366|        prefixIcon: Icon(icon, size: 20),
   367|        labelStyle: TextStyle(
   368|          color: c.inkSec,
   369|        ),
   370|        hintStyle: TextStyle(
   371|          color: c.inkSec,
   372|          fontSize: 13,
   373|        ),
   374|        border: OutlineInputBorder(
   375|          borderRadius: BorderRadius.circular(12),
   376|          borderSide: BorderSide(
   377|            color: c.border,
   378|          ),
   379|        ),
   380|        enabledBorder: OutlineInputBorder(
   381|          borderRadius: BorderRadius.circular(12),
   382|          borderSide: BorderSide(
   383|            color: c.border,
   384|          ),
   385|        ),
   386|        focusedBorder: OutlineInputBorder(
   387|          borderRadius: BorderRadius.circular(12),
   388|          borderSide: BorderSide(
   389|            color: c.accent,
   390|            width: 1.5,
   391|          ),
   392|        ),
   393|        filled: true,
   394|        fillColor: c.paper.withValues(alpha: 0.7),
   395|        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
   396|      ),
   397|    );
   398|  }
   399|
   400|  Widget _buildSlider({
   401|    required bool isDark,
   402|    required String label,
   403|    required double value,
   404|    required double min,
   405|    required double max,
   406|    required int divisions,
   407|    required String displayValue,
   408|    required ValueChanged<double> onChanged,
   409|  }) {
   410|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   411|    return Column(
   412|      crossAxisAlignment: CrossAxisAlignment.start,
   413|      children: [
   414|        Row(
   415|          mainAxisAlignment: MainAxisAlignment.spaceBetween,
   416|          children: [
   417|            Text(
   418|              label,
   419|              style: TextStyle(
   420|                fontSize: 14,
   421|                color: c.inkSec,
   422|              ),
   423|            ),
   424|            Text(
   425|              displayValue,
   426|              style: TextStyle(
   427|                fontSize: 14,
   428|                fontWeight: FontWeight.w600,
   429|                color: c.accent,
   430|              ),
   431|            ),
   432|          ],
   433|        ),
   434|        Slider(
   435|          value: value,
   436|          min: min,
   437|          max: max,
   438|          divisions: divisions,
   439|          activeColor: c.accent,
   440|          inactiveColor: c.border,
   441|          onChanged: onChanged,
   442|        ),
   443|      ],
   444|    );
   445|  }
   446|
   447|  /// 配色方案选择器 — 卡片式，每行两个
   448|  Widget _buildSchemeSelector(bool isDark, ColorScheme cs) {
   449|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
   450|    final schemes = ThemeScheme.presets;
   451|    return Column(
   452|      crossAxisAlignment: CrossAxisAlignment.start,
   453|      children: [
   454|        Text('配色方案', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.inkSec)),
   455|        const SizedBox(height: 10),
   456|        Wrap(
   457|          spacing: 10,
   458|          runSpacing: 10,
   459|          children: schemes.map((scheme) {
   460|            final isSelected = _schemeId == scheme.id;
   461|            final userColor = scheme.userBubbleColorObj;
   462|            final xiaColor = scheme.xiaBubbleColorObj;
   463|            final primaryColor = scheme.primaryColorObj;
   464|            return GestureDetector(
   465|              onTap: () => setState(() => _schemeId = scheme.id),
   466|              child: Container(
   467|                width: (MediaQuery.of(context).size.width - 52) / 2 - 5,
   468|                padding: const EdgeInsets.all(12),
   469|                decoration: BoxDecoration(
   470|                  color: c.paper,
   471|                  borderRadius: BorderRadius.circular(12),
   472|                  border: Border.all(
   473|                    color: isSelected ? primaryColor : c.border,
   474|                    width: isSelected ? 2 : 1,
   475|                  ),
   476|                ),
   477|                child: Column(
   478|                  crossAxisAlignment: CrossAxisAlignment.start,
   479|                  children: [
   480|                    // 颜色预览 — 三个小圆点
   481|                    Row(
   482|                      children: [
   483|                        Container(width: 16, height: 16, decoration: BoxDecoration(color: userColor, shape: BoxShape.circle, border: Border.all(color: c.border, width: 0.5))),
   484|                        const SizedBox(width: 6),
   485|                        Container(width: 16, height: 16, decoration: BoxDecoration(color: xiaColor, shape: BoxShape.circle, border: Border.all(color: c.border, width: 0.5))),
   486|                        const SizedBox(width: 6),
   487|                        Container(width: 16, height: 16, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
   488|                      ],
   489|                    ),
   490|                    const SizedBox(height: 8),
   491|                    // 方案名称 + 选中标记
   492|                    Row(
   493|                      children: [
   494|                        Expanded(child: Text(scheme.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink), overflow: TextOverflow.ellipsis)),
   495|                        if (isSelected) Icon(Icons.check_circle, size: 16, color: primaryColor),
   496|                      ],
   497|                    ),
   498|                    const SizedBox(height: 2),
   499|                    Text(scheme.description, style: TextStyle(fontSize: 11, color: c.inkSec), maxLines: 1, overflow: TextOverflow.ellipsis),
   500|                  ],
   501|