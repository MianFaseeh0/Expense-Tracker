import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/receipt_text_parser.dart';
import '../models/receipt_scan_result.dart';
import 'receipt_scanner_service.dart';

/// [ReceiptScannerService] backed by Google ML Kit's on-device text
/// recognizer.
///
/// Runs entirely on-device — no network call, no API key, and the photo
/// never leaves the phone. [ReceiptTextParser] does the actual field
/// extraction; this class's only job is turning a [File] into recognized
/// text and translating failures into an [AppException].
class MlKitReceiptScannerService implements ReceiptScannerService {
  MlKitReceiptScannerService()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<ReceiptScanResult> scan(File receiptImage) async {
    try {
      final input = InputImage.fromFile(receiptImage);
      final recognized = await _recognizer.processImage(input);
      return ReceiptTextParser.parse(recognized.text);
    } catch (error) {
      throw ReceiptScanException(
        "Couldn't read that receipt automatically — you can still fill "
        'the form in by hand.',
        cause: error,
      );
    }
  }

  /// Releases the native recognizer. Call when the owning provider is
  /// disposed — see `receiptScannerServiceProvider`.
  void dispose() => _recognizer.close();
}
