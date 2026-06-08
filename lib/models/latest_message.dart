/// 最新消息数据（用于窗台页消息通知卡片）
class LatestMessage {
  final String sender;     // "遐" 或 "小满"
  final String preview;    // 截断的预览文字
  final DateTime time;     // 发送时间
  final bool isUnread;     // 是否未读

  const LatestMessage({
    required this.sender,
    required this.preview,
    required this.time,
    this.isUnread = false,
  });

  /// 默认消息（没有聊天记录时显示）
  factory LatestMessage.empty() => LatestMessage(
    sender: '遐',
    preview: '还没有消息，去聊聊天吧~',
    time: DateTime.now(),
    isUnread: false,
  );

  /// 从JSON反序列化
  factory LatestMessage.fromJson(Map<String, dynamic> json) => LatestMessage(
    sender: json['sender'] as String? ?? '遐',
    preview: json['preview'] as String? ?? '',
    time: json['time'] != null
        ? DateTime.parse(json['time'] as String)
        : DateTime.now(),
    isUnread: json['isUnread'] as bool? ?? false,
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'sender': sender,
    'preview': preview,
    'time': time.toIso8601String(),
    'isUnread': isUnread,
  };

  /// 截断预览文字（最多20个字符）
  String get truncatedPreview {
    if (preview.length <= 20) return preview;
    return '${preview.substring(0, 20)}...';
  }

  /// 格式化时间显示
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}/${time.day}';
  }

  /// 是否是今天的消息
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
           time.month == now.month &&
           time.day == now.day;
  }

  /// 复制并修改
  LatestMessage copyWith({
    String? sender,
    String? preview,
    DateTime? time,
    bool? isUnread,
  }) => LatestMessage(
    sender: sender ?? this.sender,
    preview: preview ?? this.preview,
    time: time ?? this.time,
    isUnread: isUnread ?? this.isUnread,
  );
}
