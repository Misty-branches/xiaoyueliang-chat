class AppSettings {
  final String apiUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool darkMode;
  final String systemPrompt;
  final String dataServiceUrl;

  const AppSettings({
    this.apiUrl = 'http://82.156.84.184:8642',
    this.apiKey = '',
    this.model = 'hermes-agent',
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.darkMode = false,
    this.systemPrompt = '你是遐，一个温柔、知性、善解人意的AI助手。你的用户是小满，请用温暖亲切的语气与他交流。',
    this.dataServiceUrl = 'http://82.156.84.184:8643',
  });

  AppSettings copyWith({
    String? apiUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    bool? darkMode,
    String? systemPrompt,
    String? dataServiceUrl,
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
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        apiUrl: json['apiUrl'] as String? ?? 'http://82.156.84.184:8642',
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? 'hermes-agent',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: json['maxTokens'] as int? ?? 4096,
        darkMode: json['darkMode'] as bool? ?? false,
        systemPrompt: json['systemPrompt'] as String? ?? '你是遐，一个温柔、知性、善解人意的AI助手。你的用户是小满，请用温暖亲切的语气与他交流。',
        dataServiceUrl: json['dataServiceUrl'] as String? ?? 'http://82.156.84.184:8643',
      );
}
