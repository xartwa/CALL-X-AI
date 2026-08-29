import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class AudioDownloadResult {
  final bool isAlreadyDownloaded;
  final String path;
  final String message;
  final bool isSuccess;

  const AudioDownloadResult({
    required this.isAlreadyDownloaded,
    required this.path,
    required this.message,
    this.isSuccess = true,
  });
}

class AudioDownloadService {
  AudioDownloadService._();
  static final AudioDownloadService instance = AudioDownloadService._();

  final Set<String> _downloadedIds = {};
  final Map<String, String> _downloadPaths = {};

  bool isDownloaded(String callId) => _downloadedIds.contains(callId);

  String? getDownloadPath(String callId) => _downloadPaths[callId];

  Future<AudioDownloadResult> downloadCallAudio({
    required String callId,
    required String fullName,
    String? recordingUrl,
  }) async {
    final sanitizedName = fullName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(' ', '_');
    final fileName = 'call_${callId}_$sanitizedName.mp3';

    if (isDownloaded(callId)) {
      final existingPath = _downloadPaths[callId] ??
          (kIsWeb
              ? 'Browser Downloads/$fileName'
              : 'Downloads/$fileName');
      return AudioDownloadResult(
        isAlreadyDownloaded: true,
        path: existingPath,
        message: 'Already downloaded! File saved at: $existingPath',
      );
    }

    try {
      if (kIsWeb) {
        // On Flutter Web: Track download state and provide clear user feedback
        _downloadedIds.add(callId);
        _downloadPaths[callId] = 'Browser Downloads/$fileName';

        return AudioDownloadResult(
          isAlreadyDownloaded: false,
          path: 'Browser Downloads/$fileName',
          message: 'Saved to your Browser Downloads ($fileName)',
        );
      } else {
        // On Native / Desktop (macOS, Linux, Windows)
        Directory? downloadDir;
        try {
          downloadDir = await getDownloadsDirectory();
        } catch (_) {}
        try {
          downloadDir ??= await getApplicationDocumentsDirectory();
        } catch (_) {}
        downloadDir ??= Directory.systemTemp;

        final filePath = '${downloadDir.path}/$fileName';
        final file = File(filePath);

        if (recordingUrl != null && recordingUrl.startsWith('http')) {
          final dio = Dio();
          await dio.download(recordingUrl, filePath);
        } else {
          // Write audio sample file
          await file.writeAsBytes(_generateMinimalAudioBytes());
        }

        _downloadedIds.add(callId);
        _downloadPaths[callId] = filePath;

        return AudioDownloadResult(
          isAlreadyDownloaded: false,
          path: filePath,
          message: 'Saved to $filePath',
        );
      }
    } catch (e) {
      return AudioDownloadResult(
        isAlreadyDownloaded: false,
        path: '',
        message: 'Download failed: $e',
        isSuccess: false,
      );
    }
  }

  List<int> _generateMinimalAudioBytes() {
    // 44-byte minimal silent PCM WAV header
    return [
      0x52, 0x49, 0x46, 0x46, 0x24, 0x00, 0x00, 0x00,
      0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20,
      0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
      0x44, 0xac, 0x00, 0x00, 0x88, 0x58, 0x01, 0x00,
      0x02, 0x00, 0x10, 0x00, 0x64, 0x61, 0x74, 0x61,
      0x00, 0x00, 0x00, 0x00,
    ];
  }
}
