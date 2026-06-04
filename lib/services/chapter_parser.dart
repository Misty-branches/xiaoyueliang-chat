import '../models/chapter.dart';

/// 内部使用的章节标记
class _ChapterMarker {
  final int lineIndex;
  final String title;
  final String matchText;

  const _ChapterMarker({
    required this.lineIndex,
    required this.title,
    required this.matchText,
  });
}

/// 章节解析引擎
/// 能把整本书的文本自动拆分成章节
class ChapterParser {
  /// 章节标题的正则模式（按优先级排列）
  static const List<String> _chapterPatterns = [
    // 中文："第X章"（支持中文数字和阿拉伯数字）
    r'第[一二三四五六七八九十百千零〇0-9０-９]+章',
    // 英文："Chapter X" / "Chapter.X"
    r'[Cc]hapter\s*\.?\s*[0-9IVXLCDM]+',
    // 中文："第X节"
    r'第[一二三四五六七八九十百千零〇0-9０-９]+节',
    // 中文："第X部分"
    r'第[一二三四五六七八九十百千零〇0-9０-９]+部分',
    // 中文："Part X"
    r'[Pp]art\s*[0-9IVXLCDM]+',
    // 纯数字："01" / "1." 等在行首的章节标识
    r'^[0-9０-９]+[\.\、\s]',
    // 卷： "第一卷" "卷一"
    r'第[一二三四五六七八九十百千零〇0-9０-９]+卷',
  ];

  /// 解析整本书，返回章节列表
  static List<Chapter> parse(String content) {
    if (content.trim().isEmpty) return [];

    final lines = content.split('\n');
    final List<_ChapterMarker> markers = [];

    // 第一遍扫描：找出所有章节标记
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      for (final pattern in _chapterPatterns) {
        final regex = RegExp(pattern);
        final match = regex.firstMatch(line);
        if (match != null) {
          markers.add(_ChapterMarker(
            lineIndex: i,
            title: line,
            matchText: match.group(0) ?? line,
          ));
          break; // 只匹配第一个模式
        }
      }
    }

    // 如果没找到章节标记，按大约 3000 字一段切分
    if (markers.isEmpty) {
      return _splitBySize(content);
    }

    // 过滤：如果找到的章节标记太多（>200），可能误判了，降级为按大小切分
    if (markers.length > 200) {
      return _splitBySize(content);
    }

    // 按章节标记切分内容
    final List<Chapter> chapters = [];
    for (int i = 0; i < markers.length; i++) {
      final current = markers[i];
      final int startPos = _getCharPosition(lines, current.lineIndex);
      final int endPos = (i + 1 < markers.length)
          ? _getCharPosition(lines, markers[i + 1].lineIndex) - 1
          : content.length;

      final chapterContent = content.substring(startPos, endPos).trim();
      // 跳过内容太少的"章节"（可能是误判）
      if (chapterContent.length < 20 && i < markers.length - 1) continue;

      chapters.add(Chapter(
        index: i + 1,
        title: current.title,
        content: chapterContent,
        startPos: startPos,
        endPos: endPos,
      ));
    }

    // 如果没有生成任何有效的章节，降级
    if (chapters.isEmpty) {
      return _splitBySize(content);
    }

    return chapters;
  }

  /// 按大小切分（每个章节约 3000 字）
  static List<Chapter> _splitBySize(String content) {
    const int chunkSize = 3000;
    final List<Chapter> chapters = [];
    int start = 0;
    int index = 1;

    while (start < content.length) {
      int end = start + chunkSize;
      if (end >= content.length) {
        end = content.length;
      } else {
        // 尽量在段落边界切分
        final searchStart = (end - 200).clamp(0, content.length);
        final searchEnd = (end + 200).clamp(0, content.length);
        final segment = content.substring(searchStart, searchEnd);
        final newlinePos = segment.lastIndexOf('\n\n');
        if (newlinePos > 0 && newlinePos < segment.length - 1) {
          end = searchStart + newlinePos;
        }
      }

      chapters.add(Chapter(
        index: index,
        title: '第$index部分',
        content: content.substring(start, end).trim(),
        startPos: start,
        endPos: end,
      ));

      start = end;
      index++;
    }

    return chapters;
  }

  /// 根据行号计算字符位置
  static int _getCharPosition(List<String> lines, int lineIndex) {
    int pos = 0;
    for (int i = 0; i < lineIndex && i < lines.length; i++) {
      pos += lines[i].length + 1; // +1 for \n
    }
    return pos;
  }

  /// 检测内容是否有章节结构
  static bool hasChapterStructure(String content) {
    if (content.trim().isEmpty) return false;
    final lines = content.split('\n');
    int chapterCount = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      for (final pattern in _chapterPatterns) {
        if (RegExp(pattern).hasMatch(trimmed)) {
          chapterCount++;
          break;
        }
      }
    }

    // 至少在 3 个以上不同行匹配才认为有章节结构
    return chapterCount >= 3;
  }

  /// 从自然语言指令中提取章节号
  /// 例如："读第三章" → 3, "chapter 5" → 5, "第10章" → 10
  static int? extractChapterNumber(String command) {
    // 匹配 "第X章" 或 "Chapter X" 中的数字
    final patterns = [
      RegExp(r'第([0-9０-９]+)章'),
      RegExp(r'[Cc]hapter\s*\.?\s*([0-9]+)'),
      RegExp(r'第([一二三四五六七八九十百千零〇]+)章'),
      RegExp(r'第([0-9０-９]+)节'),
      RegExp(r'第([一二三四五六七八九十百千零〇]+)节'),
      RegExp(r'第([0-9０-９]+)部分'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null) {
        final numStr = match.group(1)!;
        // 尝试阿拉伯数字
        final arabic = int.tryParse(numStr);
        if (arabic != null) return arabic;
        // 尝试中文数字
        final cnNum = _parseChineseNumber(numStr);
        if (cnNum != null) return cnNum;
      }
    }

    // 纯数字：如 "读3章"、"3"
    final simpleNum = RegExp(r'(\d+)').firstMatch(command);
    if (simpleNum != null) {
      return int.tryParse(simpleNum.group(1)!);
    }

    return null;
  }

  /// 解析中文数字（支持 一~十九 等）
  static int? _parseChineseNumber(String cn) {
    const Map<String, int> nums = {
      '零': 0, '一': 1, '二': 2, '三': 3, '四': 4,
      '五': 5, '六': 6, '七': 7, '八': 8, '九': 9,
      '十': 10,
    };

    if (nums.containsKey(cn)) return nums[cn];

    // 处理 "十一" ~ "十九"
    if (cn.startsWith('十')) {
      if (cn.length == 1) return 10;
      final unit = nums[cn[1]];
      if (unit != null && unit <= 9) return 10 + unit;
    }

    // 处理 "二十" ~ "九十九"
    if (cn.endsWith('十') && cn.length == 2) {
      final tens = nums[cn[0]];
      if (tens != null && tens >= 2 && tens <= 9) return tens * 10;
    }

    // 处理 "二十一" ~ "九十九"
    if (cn.length == 3) {
      final tens = nums[cn[0]];
      final unit = nums[cn[2]];
      if (tens != null && unit != null &&
          tens >= 2 && tens <= 9 && unit >= 1 && unit <= 9) {
        return tens * 10 + unit;
      }
    }

    return null;
  }

  /// 判断指令是否是阅读相关
  static bool isReadingCommand(String text) {
    final readingKeywords = [
      '读第', '读 ', '继续', '下一章', '上一章', '翻到',
      'chapter', 'Chapter', '不读了', '退出阅读',
      '接着读', '开始读',
    ];
    final lower = text.toLowerCase();
    return readingKeywords.any((k) => lower.contains(k));
  }
}
