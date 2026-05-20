import 'package:flutter/material.dart';
import '../../../core/config/design_tokens.dart';
import '../../../providers/voice_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全屏录音遮罩 — 支持 5 状态
class RecordingOverlay extends ConsumerWidget {
  const RecordingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceStateProvider);

    if (voiceState.state == RecordingState.idle) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(voiceState),
            const SizedBox(height: AppSpacing.xl),
            if (voiceState.state == RecordingState.recording)
              _buildHint('松开完成录音')
            else if (voiceState.state == RecordingState.processing)
              _buildHint('正在识别...')
            else if (voiceState.state == RecordingState.error) ...[
              _buildError(voiceState.errorMessage ?? '识别失败'),
              const SizedBox(height: AppSpacing.md),
              _buildRetryButton(context, ref),
            ],
            const SizedBox(height: AppSpacing.lg * 2),
            if (voiceState.state != RecordingState.processing &&
                voiceState.state != RecordingState.success)
              TextButton(
                onPressed: () => ref.read(voiceStateProvider.notifier).reset(),
                child: const Text('取消',
                  style: TextStyle(color: Colors.white70, fontSize: AppText.bodyMd),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VoiceState data) {
    switch (data.state) {
      case RecordingState.recording:
        return const _RecordingAnimation();
      case RecordingState.processing:
        return const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 3,
          ),
        );
      case RecordingState.success:
        return const Icon(Icons.check_circle, size: 80, color: AppColors.positive);
      case RecordingState.error:
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
        style: const TextStyle(color: AppColors.danger, fontSize: AppText.bodySm),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => ref.read(voiceStateProvider.notifier).reset(),
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
  const _RecordingAnimation();

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
