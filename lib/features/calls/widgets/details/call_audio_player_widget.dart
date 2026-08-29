import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallAudioPlayerWidget extends StatefulWidget {
  final CallHistoryModel call;

  const CallAudioPlayerWidget({
    super.key,
    required this.call,
  });

  @override
  State<CallAudioPlayerWidget> createState() => _CallAudioPlayerWidgetState();
}

class _CallAudioPlayerWidgetState extends State<CallAudioPlayerWidget> {
  bool _isPlaying = false;
  double _playbackProgress = 0.0; // 0.0 to 1.0
  double _playbackSpeed = 1.0;
  Timer? _playbackTimer;

  int _totalSeconds = 120;
  int _currentSeconds = 0;

  // Waveform bar heights (normalized 0.15 to 1.0)
  static const List<double> _waveformData = [
    0.2, 0.45, 0.7, 0.3, 0.85, 0.6, 0.95, 0.4, 0.75, 0.5,
    0.8, 0.35, 0.9, 0.65, 0.4, 0.85, 0.7, 0.55, 0.95, 0.3,
    0.6, 0.8, 0.45, 0.75, 0.9, 0.5, 0.85, 0.65, 0.4, 0.7,
    0.95, 0.6, 0.8, 0.35, 0.9, 0.75, 0.5, 0.85, 0.4, 0.6,
  ];

  @override
  void initState() {
    super.initState();
    _parseDuration();
  }

  @override
  void didUpdateWidget(CallAudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.duration != widget.call.duration) {
      _stopPlayback();
      _parseDuration();
    }
  }

  void _parseDuration() {
    final parts = widget.call.duration.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      _totalSeconds = (mins * 60) + secs;
      if (_totalSeconds == 0) _totalSeconds = 90;
    } else {
      _totalSeconds = 90;
    }
    _currentSeconds = 0;
    _playbackProgress = 0.0;
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() => _isPlaying = true);
    final intervalMs = (1000 / _playbackSpeed).round();
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentSeconds < _totalSeconds) {
          _currentSeconds++;
          _playbackProgress = _currentSeconds / _totalSeconds;
        } else {
          _stopPlayback();
          _currentSeconds = 0;
          _playbackProgress = 0.0;
        }
      });
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _toggleSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    setState(() {
      _playbackSpeed = speeds[nextIndex];
    });
    if (_isPlaying) {
      _stopPlayback();
      _startPlayback();
    }
  }

  void _seekTo(double progress) {
    setState(() {
      _playbackProgress = progress.clamp(0.0, 1.0);
      _currentSeconds = (_totalSeconds * _playbackProgress).round();
    });
  }

  String _formatTime(int totalSec) {
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFailedOrPending = widget.call.status == 'Failed' ||
        widget.call.status == 'Queued' ||
        widget.call.status == 'Upcoming';

    if (isFailedOrPending && (widget.call.duration == '0:00' || widget.call.duration.isEmpty)) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
          border: Border.all(
            color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.mic_slash,
              size: 16,
              color: context.colors.darkGreyColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.call.status == 'Failed'
                    ? 'No audio recording available (Call disconnected / unanswered)'
                    : 'Audio recording will be generated once call session completes',
                style: TextStyle(
                  fontSize: 11.5,
                  color: context.colors.darkGreyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header: Label + Playback Speed + Download Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.waveform,
                    size: 14,
                    color: context.colors.primaryLightColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CALL RECORDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: context.colors.primaryLightColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Speed button
                  InkWell(
                    onTap: _toggleSpeed,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: context.colors.primaryLightColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Download button
                  InkWell(
                    onTap: () {
                      AppUtils.showSnackBar(
                        context: context,
                        extraMessage: 'Downloading audio recording for ${widget.call.fullName}...',
                        toastificationType: ToastificationType.success,
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        CupertinoIcons.arrow_down_to_line,
                        size: 14,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Controls Row: Play/Pause Button + Waveform + Timestamps
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Play/Pause Button
              InkWell(
                onTap: _togglePlayPause,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLightColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primaryLightColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Waveform Bars & Time Row
              Expanded(
                child: Column(
                  children: [
                    // Interactive Waveform Visualizer
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final localPos = details.localPosition.dx;
                        final progress = (localPos / (box.size.width - 120)).clamp(0.0, 1.0);
                        _seekTo(progress);
                      },
                      onTapDown: (details) {
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final localPos = details.localPosition.dx;
                        final progress = (localPos / (box.size.width - 120)).clamp(0.0, 1.0);
                        _seekTo(progress);
                      },
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(_waveformData.length, (index) {
                            final barProgress = (index + 1) / _waveformData.length;
                            final isPassed = barProgress <= _playbackProgress;
                            final heightFactor = _waveformData[index];

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                height: 28 * heightFactor,
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? context.colors.primaryLightColor
                                      : (isDark
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Timestamps: Elapsed & Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_currentSeconds),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                        Text(
                          _formatTime(_totalSeconds),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
