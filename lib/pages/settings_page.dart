import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/settings.dart';

import '../models/unified_theme.dart';
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
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    final provider = context.watch<ChatProvider>();
    final settings = provider.settings;


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
              // 头像
              Text('头像', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.inkSec)),
              const SizedBox(height: 10),
              _buildAvatarRow(c, isDark),
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
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
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
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
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
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
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

  /// 头像选择行
  Widget _buildAvatarRow(UnifiedThemeColors c, bool isDark) {
    return Row(
      children: [
        _buildAvatarOption(
          label: '用户',
          base64: _avatarUser,
          color: c.userBubble,
          onTap: () async {
            // TODO: 头像选择
          },
        ),
        const SizedBox(width: 16),
        _buildAvatarOption(
          label: '遐',
          base64: _avatarXia,
          color: c.xiaBubble,
          onTap: () async {
            // TODO: 头像选择
          },
        ),
      ],
    );
  }

  Widget _buildAvatarOption({
    required String label,
    required String base64,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.3),
            child: Text(
              label.substring(0, 1),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

