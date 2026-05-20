/// 语音录音遮罩 — Voice Recording Overlay
/// route: shown as full-screen overlay when user long-presses voice button
///
/// @context used inside HomeScreen stack, triggered by voiceStateProvider
/// @states idle → recording → processing → done / error
///
/// @component VoiceRecordingOverlay
///   @props recordingState: VoiceRecordingState
/// @component RecordingState enum
///   idle | recording | processing | success | error(msg: String)
///
/// @interaction
///   用户长按底部"语音"按钮 → state = recording (显示此遮罩)
///   用户松手 → state = processing (显示转圈动画)
///   解析完成 → state = success → 自动关闭 + SnackBar
///   解析失败 → state = error → 显示错误 + 可重试

import 'package:flutter/material.dart';
import 'design_tokens.dart';

// ── State ─────────────────────────────────────────────

enum VoiceRecordingState { idle, recording, processing, success, error }

/// 语音录音状态
class VoiceRecordingData {
  final VoiceRecordingState state;
  final String? errorMessage;

  const VoiceRecordingData({
    this.state = VoiceRecordingState.idle,
    this.errorMessage,
  });
}

// ── Overlay ───────────────────────────────────────────

/// 全屏录音遮罩
/// @props data: 录音状态数据
/// @props onCancel: 取消录音回调
/// @props onRetry: 重试回调
class VoiceRecordingOverlay extends StatelessWidget {
  final VoiceRecordingData data;
  final VoidCallback onCancel;
  final VoidCallback? onRetry;

  const VoiceRecordingOverlay({
    super.key,
    required this.data,
    required this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (data.state == VoiceRecordingState.idle) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(),
            const SizedBox(height: AppSpacing.xl),
            if (data.state == VoiceRecordingState.recording)
              _buildHint('松开完成录音')
            else if (data.state == VoiceRecordingState.processing)
              _buildHint('正在识别...')
            else if (data.state == VoiceRecordingState.error) ...[
              _buildError(data.errorMessage ?? '识别失败'),
              const SizedBox(height: AppSpacing.md),
              if (onRetry != null)
                _buildRetryButton(onRetry!),
            ],
            const SizedBox(height: AppSpacing.lg * 2),
            if (data.state != VoiceRecordingState.processing &&
                data.state != VoiceRecordingState.success)
              TextButton(
                onPressed: onCancel,
                child: const Text('取消',
                  style: TextStyle(color: Colors.white70, fontSize: AppText.bodyMd),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (data.state) {
      case VoiceRecordingState.recording:
        return _RecordingAnimation();
      case VoiceRecordingState.processing:
        return const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 3,
          ),
        );
      case VoiceRecordingState.success:
        return const Icon(Icons.check_circle, size: 80, color: AppColors.positive);
      case VoiceRecordingState.error:
        return const Icon(Icons.error_outline, size: 80, color: AppColors.danger);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHint(String text) {
    return Text(text, style: const TextStyle(
      color: Colors.white54,
      fontSize: AppText.bodySm,
    ));
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Text(msg, textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.danger, fontSize: AppText.bodySm,
      )),
    );
  }

  Widget _buildRetryButton(VoidCallback onRetry) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('重试'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }
}

// ── Recording Animation ───────────────────────────────

/// 录音波形动画
class _RecordingAnimation extends StatefulWidget {
  @override
  State<_RecordingAnimation> createState() => _RecordingAnimationState();
}

class _RecordingAnimationState extends State<_RecordingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (i) {
            final scale = 0.3 + 0.7 * (_ctrl.value * (1.0 - i * 0.15)).abs();
            return Container(
              width: 6,
              height: 48 * scale,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }
}