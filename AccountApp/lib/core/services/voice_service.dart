import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/config/api_config.dart';

class VoiceService {
  final AudioRecorder _recorder = AudioRecorder();
  final Dio _asrDio = Dio(BaseOptions(
    baseUrl: 'https://dashscope.aliyuncs.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (!await hasPermission()) {
      throw Exception('麦克风权限被拒绝');
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  Future<void> cancelRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// 阿里云 ASR 语音转文字
  Future<String> transcribeAudio(String filePath) async {
    final audioBase64 = base64.encode(await File(filePath).readAsBytes());
    final mimeType = filePath.endsWith('.m4a') ? 'audio/m4a' : 'audio/wav';

    final response = await _asrDio.post(
      '/api/v1/services/aigc/multimodal-generation/generation',
      data: {
        'model': ApiConfig.aliyunModel,
        'input': {
          'messages': [
            {
              'role': 'user',
              'content': [
                {'audio': 'data:$mimeType;base64,$audioBase64'},
              ],
            },
          ],
        },
        'parameters': {},
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiConfig.aliyunApiKey}',
          'Content-Type': 'application/json',
        },
      ),
    );

    final choices = response.data['output']['choices'] as List;
    final content = choices[0]['message']['content'] as List;
    final text = content.map((e) => e['text'] as String).join('');
    return text.trim();
  }

  Future<bool> get isRecording async => await _recorder.isRecording();

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
