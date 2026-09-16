/// Best-effort fields extracted from a scanned receipt's OCR text.
///
/// Every field beyond [rawText] is nullable because on-device OCR and
/// regex parsing are inherently unreliable — the caller decides what to
/// do when a field couldn't be read (leave the form field blank, keep
/// whatever the user already typed, etc.) rather than this type ever
/// guessing a fallback value.
class ReceiptScanResult {
  const ReceiptScanResult({
    required this.rawText,
    this.amount,
    this.merchantName,
    this.date,
  });

  /// The raw recognized text, kept around for debugging/fallback display.
  final String rawText;
  final double? amount;
  final String? merchantName;
  final DateTime? date;

  bool get hasAnyMatch => amount != null || merchantName != null || date != null;
}
