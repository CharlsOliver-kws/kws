import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/voice_service.dart';

final voiceServiceProvider = Provider((ref) => VoiceService());

enum RecordingState { idle, recording, processing, success, error }

class VoiceState {
  final RecordingState state;
  final String? filePath;
  final bool isCancelled;
  final String? errorMessage;

  const VoiceState({
    this.state = RecordingState.idle,
    this.filePath,
    this.isCancelled = false,
    this.errorMessage,
  });

  VoiceState copyWith({
    RecordingState? state,
    String? filePath,
    bool? isCancelled,
    String? errorMessage,
  }) {
    return VoiceState(
      state: state ?? this.state,
      filePath: filePath ?? this.filePath,
      isCancelled: isCancelled ?? this.isCancelled,
      errorMessage: errorMessage,
    );
  }
}

final voiceStateProvider =
    StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier(ref.watch(voiceServiceProvider));
});

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceService _voiceService;

  VoiceNotifier(this._voiceService) : super(const VoiceState());

  Future<void> startRecording() async {
    await _voiceService.startRecording();
    state = state.copyWith(state: RecordingState.recording, isCancelled: false);
  }

  Future<String?> stopRecording() async {
    if (state.isCancelled) {
      await _voiceService.cancelRecording();
      state = const VoiceState();
      return null;
    }
    final path = await _voiceService.stopRecording();
    state = VoiceState(
      state: RecordingState.idle,
      filePath: path,
    );
    return path;
  }

  void cancelRecording() {
    state = state.copyWith(isCancelled: true);
  }

  void setProcessing() {
    state = state.copyWith(state: RecordingState.processing);
  }

  void setSuccess() {
    state = state.copyWith(state: RecordingState.success);
  }

  void setError(String message) {
    state = state.copyWith(state: RecordingState.error, errorMessage: message);
  }

  void reset() {
    state = const VoiceState();
  }

  Future<bool> get isRecording async => await _voiceService.isRecording;
}
