/// 日记条目模型
class DiaryEntry {
  final String title;
  final String feeling;
  final String author;
  final String date;
  final String body;
  final String mood;
  final String weather;

  const DiaryEntry({
    required this.title,
    required this.feeling,
    required this.author,
    required this.date,
    required this.body,
    this.mood = '🌙',
    this.weather = '晴 / 22℃',
  });
}
