import 'package:flutter/material.dart';

/// General-purpose helper functions used across the application.
class Helpers {
  Helpers._();

  /// Generate time slots between [startHour] and [endHour] with given [interval] in minutes.
  /// Returns a list of time strings in "HH:mm" format.
  static List<String> generateTimeSlots({
    required int startHour,
    required int endHour,
    int intervalMinutes = 30,
  }) {
    final slots = <String>[];
    var current = startHour * 60; // convert to minutes
    final end = endHour * 60;

    while (current < end) {
      final hour = current ~/ 60;
      final minute = current % 60;
      slots.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
      current += intervalMinutes;
    }
    return slots;
  }

  /// Check if a given date is in the past (before today)
  static bool isDatePast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  /// Check if a given date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get the first name from a full name
  static String firstName(String fullName) {
    return fullName.split(' ').first;
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate a list of dates from [start] to [end] (inclusive)
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Debounce helper - returns a function that delays execution
  static VoidCallback debounce(VoidCallback action, Duration delay) {
    var timerActive = false;
    return () {
      if (timerActive) return;
      timerActive = true;
      Future.delayed(delay, () {
        action();
        timerActive = false;
      });
    };
  }
}
