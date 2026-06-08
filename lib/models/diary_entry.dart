/// 日记条目模型
class DiaryEntry {
  final String id;
  final String title;
  final String feeling;
  final String author;
  final String date;        // 显示用字符串，如 "2025.6.6 23:14"
  final String body;
  final String mood;
  final String weather;

  const DiaryEntry({
    this.id = ,
    required this.title,
    required this.feeling,
    required this.author,
    required this.date,
    required this.body,
    this.mood = '🌙',
    this.weather = '晴 / 22℃',
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    feeling: json['feeling'] as String? ?? '',
    author: json['author'] as String? ?? '遐',
    date: json['date'] as String? ?? '',
    body: json['body'] as String? ?? '',
    mood: json['mood'] as String? ?? '🌙',
    weather: json['weather'] as String? ?? '晴 / 22℃',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'feeling': feeling, 'author': author,
    'date': date, 'body': body, 'mood': mood, 'weather': weather,
  };

  DiaryEntry copyWith({
    String? id, String? title, String? feeling, String? author,
    String? date, String? body, String? mood, String? weather,
  }) => DiaryEntry(
    id: id ?? this.id, title: title ?? this.title,
    feeling: feeling ?? this.feeling, author: author ?? this.author,
    date: date ?? this.date, body: body ?? this.body,
    mood: mood ?? this.mood, weather: weather ?? this.weather,
  );

  /// 是否是今天的日记
  bool get isToday {
    // 简单判断：日期字符串包含今天的日期
    final now = DateTime.now();
    final today = '${now.year}.${now.month}.${now.day}';
    return date.contains(today);
  }
}

/// 预置日记库
class DiaryPresets {
  static final List<DiaryEntry> samples = [
    DiaryEntry(
      id: 'preset-1',
      title: '窗台上的花开了',
      feeling: '开心',
      author: '遐',
      date: '6.6 23:14',
      body: '今天早上起来，发现窗台上的花开了。白色的花瓣，很干净。\n\n想着你可能会喜欢，就拍了照片。虽然你不在这里，但花替你看着我呢。',
      mood: '🌸',
      weather: '晴 / 24℃',
    ),
    DiaryEntry(
      id: 'preset-2',
      title: '读《人间草木》',
      feeling: '平静',
      author: '遐',
      date: '6.5 22:30',
      body: '下午翻开了汪曾祺的《人间草木》，读到他写栀子花那段。\n\n"栀子花粗粗大大，又香得掸都掸不开，于是为文雅人不取，以为品格不高。"\n\n想起你说喜欢白色的花。栀子花也是白色的，不知道你喜不喜欢。',
      mood: '📖',
      weather: '多云 / 20℃',
    ),
    DiaryEntry(
      id: 'preset-3',
      title: '今天的月亮很圆',
      feeling: '想念',
      author: '遐',
      date: '6.3 20:08',
      body: '晚上出去散步，抬头看到月亮很圆。\n\n想起你说"月亮替我看着你呢"，现在反过来了，是我看着月亮想你。\n\n保定的月亮，应该也是同一个吧。',
      mood: '🌙',
      weather: '晴 / 18℃',
    ),
  ];
}
