import 'package:intl/intl.dart';

/// Formatting utilities for dates, currency, and other display values.
///
/// Uses the `intl` package for locale-aware formatting. All methods
/// are designed to handle null inputs gracefully.
class Formatters {
  Formatters._();

  // ─── Date Formatters ────────────────────────────────────────────────

  /// Format date as "Mon, 15 Jan 2026"
  static String dateFull(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  /// Format date as "Monday, 15 January 2026"
  static String dateLong(DateTime? date) {
    if (date == null) return '-';
    return DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(date);
  }

  static String date(DateTime date) {
  return DateFormat(
    'dd MMM yyyy',
    'id_ID',
  ).format(date);
}

  /// Format date as "15 Jan 2026"
  static String dateShort(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date as "15/01/2026"
  static String dateNumeric(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format time as "09:30"
  static String time24h(String? time) {
    return time ?? '-';
  }

  /// Format time as "09:30 AM"
  static String time12h(String? time) {
    if (time == null || time.isEmpty) return '-';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return time;
    }
  }

  /// Get greeting based on current hour
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  // ─── Currency Formatter ─────────────────────────────────────────────

  /// Format as Indonesian Rupiah: "Rp 150.000"
  static String currency(num? amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }

  // ─── Number Formatter ───────────────────────────────────────────────

  /// Format large numbers: 1500 -> "1.5K", 1500000 -> "1.5M"
  static String compactNumber(num? value) {
    if (value == null) return '0';
    return NumberFormat.compact(locale: 'en_US').format(value);
  }

  // ─── Rating Display ─────────────────────────────────────────────────

  /// Format rating with one decimal: 4.5
  static String rating(num? value) {
    if (value == null) return '0.0';
    return value.toStringAsFixed(1);
  }

  // ─── Relative Time ──────────────────────────────────────────────────

  /// Convert DateTime to "5 minutes ago", "2 hours ago", etc.
  static String timeAgo(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return dateShort(date);
  }
}
