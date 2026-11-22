import 'package:flutter/material.dart';

/// Editable result of "Understand my intent".
class IntentDraft {
  String title;
  DateTime date;
  TimeOfDay time;
  String repeat;
  String category;
  IntentDraft({
    required this.title,
    required this.date,
    required this.time,
    this.repeat = 'None',
    this.category = 'Work',
  });
}

/// Rule-based natural-language parser (port of the original `analyze()`),
/// now relative to the real current date instead of a hard-coded one.
class IntentParser {
  static IntentDraft parse(String command, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final lower = command.toLowerCase();

    final timeMatch = RegExp(r'(?:at\s+)(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
            caseSensitive: false)
        .firstMatch(command);
    var hour = timeMatch != null ? int.parse(timeMatch.group(1)!) : 10;
    final meridiem = timeMatch?.group(3)?.toLowerCase();
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    final minute = int.tryParse(timeMatch?.group(2) ?? '') ?? 0;

    var title = command
        .replaceFirst(
            RegExp(
                r'^(please\s+)?(remind me to|remind me|schedule|add a task to|add|i need to)\s*',
                caseSensitive: false),
            '')
        .replaceFirst(
            RegExp(
                r'\s*(tomorrow|today|next week|at\s+\d{1,2}(:\d{2})?\s*(am|pm)?|every day|daily|every week)[\s\S]*$',
                caseSensitive: false),
            '')
        .replaceFirst(RegExp(r'[.!]$'), '')
        .trim();
    title = title.isEmpty
        ? 'New reminder'
        : title[0].toUpperCase() + title.substring(1);

    final base = DateTime(today.year, today.month, today.day);
    final date = lower.contains('tomorrow')
        ? base.add(const Duration(days: 1))
        : lower.contains('next week')
            ? base.add(const Duration(days: 7))
            : base;

    final repeat = RegExp(r'daily|every day').hasMatch(lower)
        ? 'Daily'
        : lower.contains('every week')
            ? 'Weekly'
            : 'None';

    final category = RegExp(r'workout|walk|gym|meditat').hasMatch(lower)
        ? 'Health'
        : 'Work';

    return IntentDraft(
      title: title,
      date: date,
      time: TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59)),
      repeat: repeat,
      category: category,
    );
  }
}
