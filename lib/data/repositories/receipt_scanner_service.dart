import 'dart:io';

import '../models/receipt_scan_result.dart';

/// Abstraction over the on-device OCR engine used to read a receipt photo.
///
/// Kept separate from [ImageStorageService]: that one persists a file,
/// this one reads one, and the two have different lifecycles — a text
/// recognizer holds a native resource that needs explicit disposal, plain
/// file I/O doesn't.
abstract interface class ReceiptScannerService {
  Future<ReceiptScanResult> scan(File receiptImage);
}
