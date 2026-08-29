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
  bool _isMuted = false;
  bool _isDownloading = false;
  double _playbackProgress = 0.0; // 0.0 to 1.0
  double _playbackSpeed = 1.0;

  int _totalSeconds = 135;
  int _currentSeconds = 0;

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
      if (_totalSeconds == 0) _totalSeconds = 135;
    } else {
      _totalSeconds = 135;
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
        await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
        await _audioPlayer.play(UrlSource(url));
        return;
      } catch (_) {
        // Fallback to synchronized timer ticker
      }
    }

    // Fallback synchronized playback simulator
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

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    try {
      await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    } catch (_) {}
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

    final isAlready = AudioDownloadService.instance.isDownloaded(widget.call.id);
    if (isAlready) {
      final opened = await AudioDownloadService.instance.openDownloadedFile(
        callId: widget.call.id,
        fullName: widget.call.fullName,
        callDate: widget.call.callDate,
      );

      final fileName = AudioDownloadService.instance.formatFileName(
        widget.call.fullName,
        widget.call.callDate,
      );

      if (!mounted) return;
      AppUtils.showSnackBar(
        context: context,
        extraMessage: opened
            ? 'Opening file location for: $fileName'
            : 'Downloaded: $fileName',
        toastificationType: ToastificationType.info,
      );
      return;
    }

    setState(() => _isDownloading = true);

    final result = await AudioDownloadService.instance.downloadCallAudio(
      callId: widget.call.id,
      fullName: widget.call.fullName,
      callDate: widget.call.callDate,
      recordingUrl: widget.call.recordingUrl,
    );

    if (!mounted) return;
    setState(() => _isDownloading = false);

    AppUtils.showSnackBar(
      context: context,
      extraMessage: result.message,
      toastificationType: result.isSuccess
          ? ToastificationType.success
          : ToastificationType.error,
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

  String get _formattedSpeed {
    if (_playbackSpeed == 1.0) return '1x';
    if (_playbackSpeed == 1.25) return '1.25x';
    if (_playbackSpeed == 1.5) return '1.5x';
    if (_playbackSpeed == 2.0) return '2x';
    return '${_playbackSpeed}x';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDownloaded =
        AudioDownloadService.instance.isDownloaded(widget.call.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Play / Pause Round Button with Smooth Gradient and Glow
          InkWell(
            onTap: _togglePlayPause,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF4F46E5),
                  ],
                ),
                shape: BoxShape.circle,
                
              ),
              child: Center(
                child: Icon(
                  _isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Elapsed / Total Duration Text
          Text(
            '${_formatTime(_currentSeconds)} / ${_formatTime(_totalSeconds)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),

          // Track Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                  elevation: 2,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: context.colors.primaryLightColor,
                inactiveTrackColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
                thumbColor: context.colors.primaryLightColor,
                overlayColor:
                    context.colors.primaryLightColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _playbackProgress.clamp(0.0, 1.0),
                onChanged: (val) {
                  _seekTo(val);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mute / Unmute Volume Button
          IconButton(
            onPressed: _toggleMute,
            splashRadius: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            icon: Icon(
              _isMuted
                  ? CupertinoIcons.speaker_slash_fill
                  : CupertinoIcons.speaker_2_fill,
              size: 18,
              color: _isMuted
                  ? context.colors.errorColor
                  : context.colors.darkGreyColor,
            ),
            tooltip: _isMuted ? 'Unmute' : 'Mute',
          ),
          const SizedBox(width: 4),

          // Speed Button with FIXED WIDTH to prevent resizing jitter (1x, 1.25x, 1.5x, 2x)
          InkWell(
            onTap: _toggleSpeed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _formattedSpeed,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primaryLightColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Smart Download Button
          IconButton(
            onPressed: _handleDownload,
            splashRadius: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            icon: _isDownloading
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
                    size: 18,
                    color: isDownloaded
                        ? context.colors.successColor
                        : context.colors.darkGreyColor,
                  ),
            tooltip: isDownloaded ? 'Downloaded' : 'Download recording',
          ),
        ],
      ),
    );
  }
}

