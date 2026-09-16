import '../../data/models/receipt_scan_result.dart';

/// Turns a receipt's raw recognized text into a [ReceiptScanResult].
///
/// Deliberately dependency-free (no Flutter, no ML Kit) so these parsing
/// rules can be unit-tested against plain strings without mocking a text
/// recognizer. [MlKitReceiptScannerService] is the only production caller.
class ReceiptTextParser {
  const ReceiptTextParser._();

  static final RegExp _totalKeyword = RegExp(
    r'(total\s*(due|amount)?|amount\s*due|balance\s*due|grand\s*total)',
    caseSensitive: false,
  );

  // "Subtotal" contains "total" but is an intermediate sum, not the amount
  // that was actually charged — never let it win as the auto-filled amount.
  static final RegExp _subtotalKeyword = RegExp(
    r'sub\s*-?\s*total',
    caseSensitive: false,
  );

  static final RegExp _currencyAmount = RegExp(
    r'\$?\s*(\d{1,3}(?:,\d{3})*\.\d{2}|\d+\.\d{2})',
  );

  static final RegExp _slashDate = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b');
  static final RegExp _isoDate = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
  static final RegExp _monthNameDate = RegExp(
    r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-zA-Z]*\.?\s+(\d{1,2}),?\s+(\d{4})\b',
    caseSensitive: false,
  );

  static const Map<String, int> _monthNumbers = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'sept': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static ReceiptScanResult parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return ReceiptScanResult(
      rawText: rawText,
      amount: _extractAmount(lines),
      merchantName: _extractMerchantName(lines),
      date: _extractDate(rawText),
    );
  }

  static double? _extractAmount(List<String> lines) {
    // Pass 1: a line explicitly labelled as the total. Receipts often print
    // "Subtotal ... Tax ... Total  $12.34" so take the *last* currency
    // number on a matching line, not the first.
    for (final line in lines) {
      if (_subtotalKeyword.hasMatch(line)) continue;
      if (!_totalKeyword.hasMatch(line)) continue;
      final matches = _currencyAmount.allMatches(line).toList();
      if (matches.isEmpty) continue;
      final value = _parseAmount(matches.last.group(1)!);
      if (value != null) return value;
    }

    // Pass 2: no labelled total line was found (OCR missed the word, or
    // the layout is unusual) — fall back to the largest currency-shaped
    // number anywhere on the receipt, since line items are usually smaller
    // than the total.
    double? largest;
    for (final line in lines) {
      for (final match in _currencyAmount.allMatches(line)) {
        final value = _parseAmount(match.group(1)!);
        if (value != null && (largest == null || value > largest!)) {
          largest = value;
        }
      }
    }
    return largest;
  }

  static double? _parseAmount(String raw) =>
      double.tryParse(raw.replaceAll(',', ''));

  static String? _extractMerchantName(List<String> lines) {
    // The store/merchant name conventionally sits on one of the first few
    // printed lines, ahead of address/phone/date noise. Skip anything
    // that's mostly digits or punctuation rather than an actual name.
    for (final line in lines.take(5)) {
      final letters = line.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (letters.length >= 3 && letters.length >= line.length * 0.5) {
        return line;
      }
    }
    return null;
  }

  static DateTime? _extractDate(String rawText) {
    final monthMatch = _monthNameDate.firstMatch(rawText);
    if (monthMatch != null) {
      final month = _monthNumbers[monthMatch.group(1)!.toLowerCase()];
      final day = int.tryParse(monthMatch.group(2)!);
      final year = int.tryParse(monthMatch.group(3)!);
      final date = _buildDate(year: year, month: month, day: day);
      if (date != null) return date;
    }

    final isoMatch = _isoDate.firstMatch(rawText);
    if (isoMatch != null) {
      final date = _buildDate(
        year: int.tryParse(isoMatch.group(1)!),
        month: int.tryParse(isoMatch.group(2)!),
        day: int.tryParse(isoMatch.group(3)!),
      );
      if (date != null) return date;
    }

    final slashMatch = _slashDate.firstMatch(rawText);
    if (slashMatch != null) {
      final first = int.tryParse(slashMatch.group(1)!);
      final second = int.tryParse(slashMatch.group(2)!);
      var year = int.tryParse(slashMatch.group(3)!);
      if (year != null && year < 100) year += 2000;

      // Receipts are ambiguous between MM/DD and DD/MM. Prefer whichever
      // reading produces a plausible calendar date; when both do, assume
      // MM/DD/YYYY since it's the more common receipt format.
      final asMonthDay = _buildDate(year: year, month: first, day: second);
      if (asMonthDay != null) return asMonthDay;
      final asDayMonth = _buildDate(year: year, month: second, day: first);
      if (asDayMonth != null) return asDayMonth;
    }

    return null;
  }

  static DateTime? _buildDate({int? year, int? month, int? day}) {
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    // DateTime silently rolls invalid dates forward (e.g. Feb 30 -> Mar 2);
    // reject anything that didn't round-trip cleanly.
    if (date.month != month || date.day != day) return null;
    return _isPlausible(date) ? date : null;
  }

  /// Rejects dates more than a year in the future or more than five years
  /// old — OCR misreads (e.g. a "2" read as "7") tend to fail this check,
  /// while genuine receipt dates always pass it.
  static bool _isPlausible(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now.add(const Duration(days: 365))) &&
        date.isAfter(DateTime(now.year - 5));
  }
}
