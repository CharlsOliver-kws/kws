import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../data/models/record.dart';
import '../../core/constants/prompts.dart';
import 'voice_service.dart';

class AiParserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 完整链路：录音文件 → 阿里云 ASR 转文字 → GLM 解析 → Record
  Future<Record> processVoice(String voiceFilePath) async {
    final voiceService = VoiceService();
    final voiceText = await voiceService.transcribeAudio(voiceFilePath);
    final record = await _parseRecord(voiceText);
    return record;
  }

  /// 文本解析为记账记录 (GLM/DeepSeek)
  Future<Record> _parseRecord(String voiceText) async {
    final prompt = Prompts.aiParser.replaceAll('{voice_text}', voiceText);

    final response = await _dio.post(
      '/v1/messages',
      data: {
        'model': ApiConfig.model,
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.1,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiConfig.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
    );

    final contentList = response.data['content'] as List;
    final content = contentList[0]['text'] as String;
    final jsonStr = _extractJson(content);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    // AI 返回的 category 应该是英文ID，兼容中文回退
    var category = map['category'] as String;
    if (_isChineseCategory(category)) {
      category = _chineseToId(category);
    }

    return Record(
      amount: (map['amount'] as num).toDouble(),
      category: category,
      note: map['note'] as String,
      voiceText: voiceText,
      date: DateTime.now(),
    );
  }

  /// 从可能包含markdown的代码块中提取JSON
  String _extractJson(String content) {
    var str = content.trim();
    if (str.startsWith('```')) {
      final lines = str.split('\n');
      final jsonLines = lines.where((l) => !l.startsWith('```')).toList();
      str = jsonLines.join('\n');
    }
    return str;
  }

  /// 检查是否为中文字符串分类（兼容旧格式）
  bool _isChineseCategory(String s) {
    return s.contains(RegExp(r'[一-鿿]'));
  }

  /// 中文分类映射到英文ID
  String _chineseToId(String label) {
    const map = {
      '餐饮': 'food', '交通': 'transport', '购物': 'shopping',
      '娱乐': 'entertain', '医疗': 'medical', '教育': 'education',
      '住房': 'housing', '其他': 'other',
    };
    return map[label] ?? 'other';
  }

  /// 直接文本解析（用户手动输入文字时使用）
  Future<Record> parseText(String text) async {
    return _parseRecord(text);
  }
}
