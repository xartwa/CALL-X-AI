import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/core/services/audio_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioDownloadService Tests', () {
    test('tracks downloaded state and prevents duplicate download requests',
        () async {
      final service = AudioDownloadService.instance;
      const callId = 'test_call_101';
      const fullName = 'Alex Morgan';

      expect(service.isDownloaded(callId), isFalse);

      final result1 = await service.downloadCallAudio(
        callId: callId,
        fullName: fullName,
        recordingUrl: null,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.isAlreadyDownloaded, isFalse);
      expect(result1.path.isNotEmpty, isTrue);
      expect(service.isDownloaded(callId), isTrue);

      // Second download request should detect already downloaded state
      final result2 = await service.downloadCallAudio(
        callId: callId,
        fullName: fullName,
        recordingUrl: null,
      );

      expect(result2.isAlreadyDownloaded, isTrue);
      expect(result2.message, contains('Downloaded:'));
      expect(result2.fileName, contains('Alex_Morgan'));
      expect(result2.path, equals(result1.path));

      // Test opening downloaded file
      final opened = await service.openDownloadedFile(
        callId: callId,
        fullName: fullName,
      );
      expect(opened, isNotNull);
    });
  });
}
