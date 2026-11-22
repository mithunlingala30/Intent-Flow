import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

const kCategories = ['Work', 'Personal', 'Health'];
const kRepeats = ['None', 'Daily', 'Weekly'];

String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

class TaskModel {
  final String id;
  final String title;
  final String category;
  final String color;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm (24h)
  final String repeat;
  final bool done;
  final DateTime? createdAt;

  const TaskModel({
    this.id = '',
    required this.title,
    required this.category,
    String? color,
    required this.date,
    required this.time,
    this.repeat = 'None',
    this.done = false,
    this.createdAt,
  }) : color = color ?? '';

  String get colorName => color.isEmpty ? CategoryStyle.colorFor(category) : color;

  DateTime get dateTime {
    final d = DateTime.tryParse(date) ?? DateTime.now();
    final parts = time.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(d.year, d.month, d.day, h, m);
  }

  /// "09:30 AM"
  String get displayTime => DateFormat('hh:mm a').format(dateTime);

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    String? date,
    String? time,
    String? repeat,
    bool? done,
  }) {
    final newCategory = category ?? this.category;
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: newCategory,
      color: CategoryStyle.colorFor(newCategory),
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      done: done ?? this.done,
      createdAt: createdAt,
    );
  }

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final category = (d['category'] as String?) ?? 'Work';
    return TaskModel(
      id: doc.id,
      title: (d['title'] as String?) ?? '',
      category: category,
      color: (d['color'] as String?) ?? CategoryStyle.colorFor(category),
      date: (d['date'] as String?) ?? dateKey(DateTime.now()),
      time: (d['time'] as String?) ?? '09:00',
      repeat: (d['repeat'] as String?) ?? 'None',
      done: (d['done'] as bool?) ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fields written to Firestore (must match firestore.rules `validTask`).
  Map<String, dynamic> toMap() => {
        'title': title.trim(),
        'category': category,
        'color': colorName,
        'date': date,
        'time': time,
        'repeat': repeat,
        'done': done,
      };
}
