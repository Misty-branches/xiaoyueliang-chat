import 'package:flutter/painting.dart';
class AppSettings {
  final String apiUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool darkMode;
  final String systemPrompt;
  final String dataServiceUrl;
  final int accentColor; // 主题色 hex 值（如 0xFFEC407A）
  final String avatarUser; // 用户头像 base64
  final String avatarXia; // 遐头像 base64
  final String schemeId; // 当前配色方案 ID

  const AppSettings({
    this.apiUrl = '',
    this.apiKey = '',
    this.model = 'hermes-agent',
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.darkMode = false,
    this.systemPrompt = '你是遐，一个温柔、知性、善解人意的AI助手。你的用户是小满，请用温暖亲切的语气与他交流。',
    this.dataServiceUrl = '',
    this.accentColor = 0xFF5A7A94,
    this.avatarUser = '',
    this.avatarXia = '',
    this.schemeId = 'moonlit',
  });

  Color get accentColorObj => Color(accentColor);

  AppSettings copyWith({
    String? apiUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    bool? darkMode,
    String? systemPrompt,
    String? dataServiceUrl,
    int? accentColor,
    String? avatarUser,
    String? avatarXia,
    String? schemeId,
  }) {
    return AppSettings(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      darkMode: darkMode ?? this.darkMode,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      dataServiceUrl: dataServiceUrl ?? this.dataServiceUrl,
      accentColor: accentColor ?? this.accentColor,
      avatarUser: avatarUser ?? this.avatarUser,
      avatarXia: avatarXia ?? this.avatarXia,
      schemeId: schemeId ?? this.schemeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'apiUrl': apiUrl,
        'apiKey': apiKey,
        'model': model,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'darkMode': darkMode,
        'systemPrompt': systemPrompt,
        'dataServiceUrl': dataServiceUrl,
        'accentColor': accentColor,
        'avatarUser': avatarUser,
        'avatarXia': avatarXia,
        'schemeId': schemeId,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        apiUrl: json['apiUrl'] as String? ?? '',
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? 'hermes-agent',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: json['maxTokens'] as int? ?? 4096,
        darkMode: json['darkMode'] as bool? ?? false,
        systemPrompt: json['systemPrompt'] as String? ??
            '你是遐，一个温柔、知性、善解人意的AI助手。你的用户是小满，请用温暖亲切的语气与他交流。',
        dataServiceUrl: json['dataServiceUrl'] as String? ?? '',
        accentColor: json['accentColor'] as int? ?? 0xFF5A7A94,
        avatarUser: json['avatarUser'] as String? ?? '',
        avatarXia: json['avatarXia'] as String? ?? '',
        schemeId: json['schemeId'] as String? ?? 'moonlit',
      );
}
