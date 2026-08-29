import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/services/audio_download_service.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallAudioPlayerWidget extends StatefulWidget {
  final CallHistoryModel call;
  final bool compact;

  const CallAudioPlayerWidget({
    super.key,
    required this.call,
    this.compact = false,
  });

  @override
  State<CallAudioPlayerWidget> createState() => _CallAudioPlayerWidgetState();
}

class _CallAudioPlayerWidgetState extends State<CallAudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerCompleteSub;
  Timer? _fallbackTimer;

  bool _isPlaying = false;
  bool _isDownloading = false;
  double _playbackProgress = 0.0; // 0.0 to 1.0
  double _playbackSpeed = 1.0;

  int _totalSeconds = 90;
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
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
    _parseDuration();
  }

  void _initAudioPlayer() {
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() {
        _currentSeconds = pos.inSeconds;
        if (_totalSeconds > 0) {
          _playbackProgress = (_currentSeconds / _totalSeconds).clamp(0.0, 1.0);
        }
      });
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (!mounted) return;
      if (dur.inSeconds > 0) {
        setState(() {
          _totalSeconds = dur.inSeconds;
        });
      }
    });

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentSeconds = 0;
        _playbackProgress = 0.0;
      });
    });
  }

  @override
  void didUpdateWidget(CallAudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.id != widget.call.id ||
        oldWidget.call.duration != widget.call.duration) {
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

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _stopPlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    final url = widget.call.recordingUrl;
    if (url != null && url.startsWith('http')) {
      try {
        await _audioPlayer.setPlaybackRate(_playbackSpeed);
        await _audioPlayer.play(UrlSource(url));
        return;
      } catch (_) {
        // Fallback to simulated audio ticker if URL fails to load
      }
    }

    // Fallback synchronized playback simulator for Web & offline calls
    setState(() => _isPlaying = true);
    final intervalMs = (1000 / _playbackSpeed).round();
    _fallbackTimer?.cancel();
    _fallbackTimer =
        Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentSeconds < _totalSeconds) {
          _currentSeconds++;
          _playbackProgress =
              (_currentSeconds / _totalSeconds).clamp(0.0, 1.0);
        } else {
          _stopPlayback();
          _currentSeconds = 0;
          _playbackProgress = 0.0;
        }
      });
    });
  }

  Future<void> _stopPlayback() async {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    try {
      await _audioPlayer.pause();
    } catch (_) {}
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _toggleSpeed() async {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final newSpeed = speeds[nextIndex];
    setState(() {
      _playbackSpeed = newSpeed;
    });

    try {
      await _audioPlayer.setPlaybackRate(newSpeed);
    } catch (_) {}

    if (_fallbackTimer != null) {
      _startPlayback();
    }
  }

  Future<void> _seekTo(double progress) async {
    final targetSeconds = (_totalSeconds * progress).round();
    setState(() {
      _playbackProgress = progress.clamp(0.0, 1.0);
      _currentSeconds = targetSeconds;
    });

    try {
      await _audioPlayer.seek(Duration(seconds: targetSeconds));
    } catch (_) {}
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    final result = await AudioDownloadService.instance.downloadCallAudio(
      callId: widget.call.id,
      fullName: widget.call.fullName,
      recordingUrl: widget.call.recordingUrl,
    );

    if (!mounted) return;
    setState(() => _isDownloading = false);

    AppUtils.showSnackBar(
      context: context,
      extraMessage: result.message,
      toastificationType: result.isAlreadyDownloaded
          ? ToastificationType.info
          : (result.isSuccess
              ? ToastificationType.success
              : ToastificationType.error),
    );
  }

  String _formatTime(int totalSec) {
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerCompleteSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFailedOrPending = widget.call.status == 'Failed' ||
        widget.call.status == 'Queued' ||
        widget.call.status == 'Upcoming';

    if (isFailedOrPending &&
        (widget.call.duration == '0:00' || widget.call.duration.isEmpty)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

    final isDownloaded =
        AudioDownloadService.instance.isDownloaded(widget.call.id);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.compact ? 10 : 14),
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
          // Player Header: Label + Playback Speed + Smart Download Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.waveform,
                    size: 15,
                    color: context.colors.primaryLightColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Call Recording',
                    style: TextStyle(
                      fontSize: widget.compact ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
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

                  // Smart Download button with status feedback
                  InkWell(
                    onTap: _handleDownload,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: _isDownloading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                              ),
                            )
                          : Icon(
                              isDownloaded
                                  ? CupertinoIcons.checkmark_alt_circle_fill
                                  : CupertinoIcons.arrow_down_to_line,
                              size: 14,
                              color: isDownloaded
                                  ? context.colors.successColor
                                  : context.colors.darkGreyColor,
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
                  width: widget.compact ? 32 : 36,
                  height: widget.compact ? 32 : 36,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLightColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primaryLightColor
                            .withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    size: widget.compact ? 14 : 16,
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
                        final RenderBox? box =
                            context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final localPos = details.localPosition.dx;
                        final progress =
                            (localPos / (box.size.width - 100)).clamp(0.0, 1.0);
                        _seekTo(progress);
                      },
                      onTapDown: (details) {
                        final RenderBox? box =
                            context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final localPos = details.localPosition.dx;
                        final progress =
                            (localPos / (box.size.width - 100)).clamp(0.0, 1.0);
                        _seekTo(progress);
                      },
                      child: SizedBox(
                        height: widget.compact ? 22 : 28,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(_waveformData.length, (index) {
                            final barProgress =
                                (index + 1) / _waveformData.length;
                            final isPassed = barProgress <= _playbackProgress;
                            final heightFactor = _waveformData[index];

                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                height: (widget.compact ? 22 : 28) * heightFactor,
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
