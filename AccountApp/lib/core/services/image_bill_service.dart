import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/api_config.dart';
import '../../data/models/record.dart';
import '../../core/utils/date_helper.dart';

class ImageBillService {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dashscope.aliyuncs.com/apps/anthropic',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static const _prompt = '''You are a bill recognition assistant. Analyze the image and extract every expense record as a JSON array.
Each record: amount (number), category (one of: food/transport/shopping/entertain/medical/education/housing/other), note (short description in Chinese), date (YYYY-MM-DD HH:mm or null).
Return JSON array only. Example: [{"amount": 50, "category": "food", "note": "午饭", "date": "2026-05-18 12:30"}]''';

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    if (fromCamera) {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
    }
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
  }

  Future<List<Record>> recognizeBills(String imagePath) async {
    final imageBytes = await XFile(imagePath).readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    DioException? lastError;
    String? lastResponse;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _dio.post(
          '/v1/messages',
          data: {
            'model': ApiConfig.vlModel,
            'max_tokens': 4096,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'image',
                    'source': {
                      'type': 'base64',
                      'media_type': 'image/jpeg',
                      'data': imageBase64,
                    },
                  },
                  {'type': 'text', 'text': _prompt},
                ],
              },
            ],
          },
          options: Options(
            headers: {
              'x-api-key': ApiConfig.aliyunApiKey,
              'Content-Type': 'application/json',
              'anthropic-version': '2023-06-01',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != 200) {
          lastResponse = 'HTTP ${response.statusCode}: ${response.data}';
          print('API error($attempt): $lastResponse');
          if (attempt < 1) continue;
          throw Exception('API error: $lastResponse');
        }

        final contentList = response.data['content'] as List;
        final content = contentList
            .map((c) => c['text'] as String? ?? '')
            .join('');
        return _parseRecords(content);
      } on DioException catch (e) {
        lastError = e;
        lastResponse = e.response?.data?.toString();
        print('识别图片失败(尝试${attempt + 1}/2): ${e.message} type=${e.type} resp=${lastResponse}');
        if (attempt < 1) continue;
      }
    }

    throw Exception('识别失败: ${lastError?.message} ${lastResponse ?? ''}'.trim());
  }

  List<Record> _parseRecords(String content) {
    var text = content.trim();
    if (text.startsWith('```')) {
      final lines = text.split('\n');
      final jsonLines = lines.where((l) => !l.startsWith('```')).toList();
      text = jsonLines.join('\n');
    }
    final arrayStart = text.indexOf('[');
    final arrayEnd = text.lastIndexOf(']');
    if (arrayStart >= 0 && arrayEnd > arrayStart) {
      text = text.substring(arrayStart, arrayEnd + 1);
    }

    final List<dynamic> list = jsonDecode(text);
    final records = <Record>[];

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final dateStr = map['date'] as String?;
      DateTime billDate;
      if (dateStr != null && dateStr != 'null') {
        try {
          billDate = DateHelper.parseDateTime(dateStr);
        } catch (_) {
          billDate = DateTime.now();
        }
      } else {
        billDate = DateTime.now();
      }
      // 兼容中文分类回退
      var category = (map['category'] as String?) ?? 'other';
      if (_isChineseCategory(category)) {
        category = _chineseToId(category);
      }
      records.add(Record(
        amount: (map['amount'] as num).toDouble(),
        category: category,
        note: (map['note'] as String?) ?? '',
        date: billDate,
      ));
    }
    return records;
  }

  bool _isChineseCategory(String s) {
    return s.contains(RegExp(r'[一-鿿]'));
  }

  String _chineseToId(String label) {
    const map = {
      '餐饮': 'food', '交通': 'transport', '购物': 'shopping',
      '娱乐': 'entertain', '医疗': 'medical', '教育': 'education',
      '住房': 'housing', '其他': 'other',
    };
    return map[label] ?? 'other';
  }
}
