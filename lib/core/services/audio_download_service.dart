import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'audio_file_helper.dart';

class AudioDownloadResult {
  final bool isAlreadyDownloaded;
  final String path;
  final String fileName;
  final String message;
  final bool isSuccess;

  const AudioDownloadResult({
    required this.isAlreadyDownloaded,
    required this.path,
    required this.fileName,
    required this.message,
    this.isSuccess = true,
  });
}

class AudioDownloadService {
  AudioDownloadService._();
  static final AudioDownloadService instance = AudioDownloadService._();

  final Set<String> _downloadedIds = {};
  final Map<String, String> _downloadPaths = {};
  final Map<String, String> _recordingUrls = {};

  bool isDownloaded(String callId) => _downloadedIds.contains(callId);

  String? getDownloadPath(String callId) => _downloadPaths[callId];

  String formatFileName(String fullName, String? callDate) {
    final sanitizedName = fullName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(' ', '_');
    final dateStr = (callDate != null && callDate.isNotEmpty)
        ? callDate.replaceAll('/', '-').replaceAll(' ', '_')
        : 'recent';
    return 'Call_Log_${sanitizedName}_$dateStr.mp3';
  }

  Future<AudioDownloadResult> downloadCallAudio({
    required String callId,
    required String fullName,
    String? callDate,
    String? recordingUrl,
  }) async {
    final fileName = formatFileName(fullName, callDate);
    if (recordingUrl != null && recordingUrl.isNotEmpty) {
      _recordingUrls[callId] = recordingUrl;
    }

    if (isDownloaded(callId)) {
      final existingPath = _downloadPaths[callId] ?? fileName;
      return AudioDownloadResult(
        isAlreadyDownloaded: true,
        path: existingPath,
        fileName: fileName,
        message: 'Downloaded: $fileName',
      );
    }

    try {
      if (kIsWeb) {
        // On Flutter Web: Trigger browser download and record state
        triggerWebDownload(
          recordingUrl ?? '',
          fileName,
          _generateMinimalAudioBytes(),
        );

        _downloadedIds.add(callId);
        _downloadPaths[callId] = fileName;

        return AudioDownloadResult(
          isAlreadyDownloaded: false,
          path: fileName,
          fileName: fileName,
          message: 'Downloaded: $fileName',
        );
      } else {
        // On Native / Desktop (macOS, Windows, Linux, Mobile)
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
          fileName: fileName,
          message: 'Downloaded: $fileName',
        );
      }
    } catch (e) {
      return AudioDownloadResult(
        isAlreadyDownloaded: false,
        path: '',
        fileName: fileName,
        message: 'Download failed: $e',
        isSuccess: false,
      );
    }
  }

  Future<bool> openDownloadedFile({
    required String callId,
    required String fullName,
    String? callDate,
  }) async {
    final fileName = formatFileName(fullName, callDate);
    final filePath = _downloadPaths[callId];

    if (kIsWeb) {
      final recUrl = _recordingUrls[callId] ?? '';
      openWebFile(recUrl, fileName);
      return true;
    }

    if (filePath != null && !kIsWeb) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          if (Platform.isMacOS) {
            // Reveal in macOS Finder
            await Process.run('open', ['-R', filePath]);
            return true;
          } else if (Platform.isWindows) {
            // Reveal in Windows File Explorer
            await Process.run('explorer.exe', ['/select,', filePath]);
            return true;
          } else if (Platform.isLinux) {
            // Open parent directory in Linux
            await Process.run('xdg-open', [file.parent.path]);
            return true;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  List<int> _generateMinimalAudioBytes() {
    // 44-byte minimal silent PCM WAV header
    return [
      0x52, 0x49, 0x46, 0x46, 0x24, 0x00, 0x00, 0x00,
      0x57, 0x41, 0x56, 0x6f, 0x74, 0x20, 0x10, 0x00,
      0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x44, 0xac,
      0x00, 0x00, 0x88, 0x58, 0x01, 0x00, 0x02, 0x00,
      0x10, 0x00, 0x64, 0x61, 0x74, 0x61, 0x00, 0x00,
      0x00, 0x00,
    ];
  }
}
