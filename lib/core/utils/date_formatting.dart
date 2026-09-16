import 'package:intl/intl.dart';

/// Shared date-formatting utilities.
///
/// The original codebase exposed a bare top-level `formater` variable that
/// any file could import; centralizing it here behind a documented API
/// makes the dependency explicit and easy to find.
abstract final class DateFormatting {
  static final DateFormat shortDate = DateFormat.yMd();

  static String formatShort(DateTime date) => shortDate.format(date);
}
