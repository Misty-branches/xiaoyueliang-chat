import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/settings.dart';
import '../models/theme_scheme.dart';
import '../models/moonlit_colors.dart';
import '../providers/chat_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _systemPromptController;
  late TextEditingController _dataServiceUrlController;
  late double _temperature;
  late int _maxTokens;
  late int _accentColor;
  String _avatarUser = '';
  String _avatarXia = '';
  String _schemeId = 'peach-blossom';

  @override
  void initState() {
    super.initState();
    final settings = context.read<ChatProvider>().settings;
    _apiUrlController = TextEditingController(text: settings.apiUrl);
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _modelController = TextEditingController(text: settings.model);
    _systemPromptController = TextEditingController(text: settings.systemPrompt);
    _dataServiceUrlController = TextEditingController(text: settings.dataServiceUrl);
    _temperature = settings.temperature;
    _maxTokens = settings.maxTokens;
    _accentColor = settings.accentColor;
    _avatarUser = settings.avatarUser;
    _avatarXia = settings.avatarXia;
    _schemeId = settings.schemeId;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _systemPromptController.dispose();
    _dataServiceUrlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final provider = context.read<ChatProvider>();
    provider.updateSettings(AppSettings(
      apiUrl: _apiUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      temperature: _temperature,
      maxTokens: _maxTokens,
      darkMode: provider.settings.darkMode,
      systemPrompt: _systemPromptController.text.trim(),
      dataServiceUrl: _dataServiceUrlController.text.trim(),
      accentColor: _accentColor,
      avatarUser: _avatarUser,
      avatarXia: _avatarXia,
      schemeId: _schemeId,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设置已保存'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = MoonlitColors.forMode(isDark);
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<ChatProvider>();
    final settings = provider.settings;
    final scheme = provider.currentScheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            isDark,
            'API 配置',
            [
              _buildTextField(
                controller: _apiUrlController,
                label: 'API 服务器地址',
                hint: 'http://你的服务器地址:8642',
                icon: Icons.link_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _apiKeyController,
                label: 'API Key',
                hint: 'sk-...',
                icon: Icons.vpn_key_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _modelController,
                label: '模型名称',
                hint: 'deepseek-v4-flash',
                icon: Icons.memory_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _dataServiceUrlController,
                label: '数据服务地址',
                hint: 'http://你的服务器地址:8643',
                icon: Icons.cloud_rounded,
                isDark: isDark,
              ),
              if (provider.cloudConnected)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: c.accent),
                      const SizedBox(width: 6),
                      Text(
                        '云端已连接',
                        style: TextStyle(fontSize: 12, color: c.accent),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            '生成参数',
            [
              _buildSlider(
                isDark: isDark,
                label: '温度 (Temperature)',
                value: _temperature,
                min: 0.0,
                max: 2.0,
                divisions: 40,
                displayValue: _temperature.toStringAsFixed(1),
                onChanged: (v) => setState(() => _temperature = v),
              ),
              const SizedBox(height: 8),
              _buildSlider(
                isDark: isDark,
                label: '最大 Token 数',
                value: _maxTokens.toDouble(),
                min: 256,
                max: 8192,
                divisions: 31,
                displayValue: _maxTokens.toString(),
                onChanged: (v) => setState(() => _maxTokens = v.round()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            '系统提示词',
            [
              TextField(
                controller: _systemPromptController,
                maxLines: 5,
                style: TextStyle(
                  fontSize: 14,
                  color: c.ink,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: c.paper.withValues(alpha: 0.7),
                  hintText: '输入系统提示词...',
                  hintStyle: TextStyle(
                    color: c.inkSec,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            '主题装扮',
            [
              // 配色方案选择
              _buildSchemeSelector(isDark, cs),
              const SizedBox(height: 16),
              // 头像
              Text('头像', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.inkSec)),
              const SizedBox(height: 10),
              _buildAvatarRow(c, isDark),
              const SizedBox(height: 16),
              // 深色模式
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '深色模式',
                  style: TextStyle(
                    color: c.ink,
                  ),
                ),
                value: settings.darkMode,
                onChanged: (v) {
                  provider.updateSettings(settings.copyWith(darkMode: v));
                },
                activeColor: c.accent,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Test connection button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _testConnection(context, isDark),
              icon: const Icon(Icons.wifi_find_rounded, size: 18),
              label: const Text('测试连接'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: c.border,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '遐悦聊天 v1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: c.inkSec,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _testConnection(BuildContext context, bool isDark) async {
    // Simple connectivity test
    try {
      final baseUrl = _apiUrlController.text.trim();
      final uri = Uri.parse('$baseUrl/health');
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusCode == 200 ? '连接成功!' : '服务器响应: ${response.statusCode}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: response.statusCode == 200 ? Colors.green : Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('连接失败: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildSection(bool isDark, String title, List<Widget> children) {
    final c = MoonlitColors.forMode(isDark);
    final borderColor = c.border.withValues(alpha: isDark ? 0.4 : 0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.accent.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    final c = MoonlitColors.forMode(isDark);
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 15,
        color: c.ink,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        labelStyle: TextStyle(
          color: c.inkSec,
        ),
        hintStyle: TextStyle(
          color: c.inkSec,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: c.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: c.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: c.accent,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: c.paper.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSlider({
    required bool isDark,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    final c = MoonlitColors.forMode(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: c.inkSec,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.accent,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: c.accent,
          inactiveColor: c.border,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 配色方案选择器 — 卡片式，每行两个
  Widget _buildSchemeSelector(bool isDark, ColorScheme cs) {
    final c = MoonlitColors.forMode(isDark);
    final schemes = ThemeScheme.presets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('配色方案', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.inkSec)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: schemes.map((scheme) {
            final isSelected = _schemeId == scheme.id;
            final userColor = scheme.userBubbleColorObj;
            final xiaColor = scheme.xiaBubbleColorObj;
            final primaryColor = scheme.primaryColorObj;
            return GestureDetector(
              onTap: () => setState(() => _schemeId = scheme.id),
              child: Container(
                width: (MediaQuery.of(context).size.width - 52) / 2 - 5,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : c.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 颜色预览 — 三个小圆点
                    Row(
                      children: [
                        Container(width: 16, height: 16, decoration: BoxDecoration(color: userColor, shape: BoxShape.circle, border: Border.all(color: c.border, width: 0.5))),
                        const SizedBox(width: 6),
                        Container(width: 16, height: 16, decoration: BoxDecoration(color: xiaColor, shape: BoxShape.circle, border: Border.all(color: c.border, width: 0.5))),
                        const SizedBox(width: 6),
                        Container(width: 16, height: 16, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 方案名称 + 选中标记
                    Row(
                      children: [
                        Expanded(child: Text(scheme.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink), overflow: TextOverflow.ellipsis)),
                        if (isSelected) Icon(Icons.check_circle, size: 16, color: primaryColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(scheme.description, style: TextStyle(fontSize: 11, color: c.inkSec), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 头像选择行
  Widget _buildAvatarRow(MoonlitTheme c, bool isDark) {
    return Row(
      children: [
        Expanded(child: Column(children: [
          _buildAvatarPreview(base64Str: _avatarUser, fallbackText: '满', bgColor: c.accent.withValues(alpha: 0.2), accentColor: c.accent, isDark: isDark),
          const SizedBox(height: 6),
          Text('我的头像', style: TextStyle(fontSize: 11, color: c.inkSec)),
        ])),
        const SizedBox(width: 16),
        Expanded(child: Column(children: [
          _buildAvatarPreview(base64Str: _avatarXia, fallbackText: '遐', bgColor: c.accent.withValues(alpha: 0.2), accentColor: c.accent, isDark: isDark),
          const SizedBox(height: 6),
          Text('遐的头像', style: TextStyle(fontSize: 11, color: c.inkSec)),
        ])),
      ],
    );
  }

  /// 头像预览 + 点击更换
  Widget _buildAvatarPreview({required String base64Str, required String fallbackText, required Color bgColor, required Color accentColor, required bool isDark}) {
    final c = MoonlitColors.forMode(isDark);
    return GestureDetector(
      onTap: () => _pickImage(base64Str == _avatarUser),
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor, border: Border.all(color: c.border)),
        child: ClipOval(
          child: base64Str.isNotEmpty
              ? Image.memory(base64Decode(base64Str), fit: BoxFit.cover)
              : Icon(Icons.person_outline, size: 28, color: accentColor),
        ),
      ),
    );
  }

  void _pickImage(bool isUser) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.single.bytes != null) {
        final base64Str = base64Encode(result.files.single.bytes!);
        setState(() {
          if (isUser) { _avatarUser = base64Str; } else { _avatarXia = base64Str; }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('选择图片失败: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }
}
