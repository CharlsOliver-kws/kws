import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/design_tokens.dart';
import '../../../providers/voice_provider.dart';

class VoiceButton extends ConsumerStatefulWidget {
  const VoiceButton({super.key, required this.onRecordingComplete});

  final ValueChanged<String> onRecordingComplete;

  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
    ref.read(voiceStateProvider.notifier).startRecording();
  }

  void _onPointerUp(PointerUpEvent event) async {
    if (_isPressed) {
      setState(() => _isPressed = false);
      final path = await ref.read(voiceStateProvider.notifier).stopRecording();
      if (path != null) {
        widget.onRecordingComplete(path);
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() => _isPressed = false);
    ref.read(voiceStateProvider.notifier).cancelRecording();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceStateProvider);
    final isRecording = voiceState.state == RecordingState.recording;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: AppHitTargets.bottomNav,
        height: AppHitTargets.bottomNav,
        decoration: BoxDecoration(
          color: isRecording ? AppColors.accentSoft : AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          isRecording ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: isRecording ? 26 : 22,
        ),
      ),
    );
  }
}
