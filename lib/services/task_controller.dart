import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import 'notification_service.dart';
import 'task_service.dart';

class ShellController extends ChangeNotifier {
  int index = 0;
  void go(int i) {
    if (i == index) return;
    index = i;
    notifyListeners();
  }
}

class TaskController extends ChangeNotifier {
  TaskController(this.uid) {
    _sub = _service.watch(uid).listen((list) {
      tasks = list;
      loading = false;
      error = null;
      notifyListeners();
      NotificationService.instance.syncReminders(list);
    }, onError: (Object e) {
      loading = false;
      error = 'Could not load your tasks. Check your connection.';
      notifyListeners();
    });
  }

  final String uid;
  final TaskService _service = TaskService();
  StreamSubscription<List<TaskModel>>? _sub;

  List<TaskModel> tasks = [];
  bool loading = true;
  String? error;

  List<TaskModel> get pending => tasks.where((t) => !t.done).toList();
  List<TaskModel> get completed => tasks.where((t) => t.done).toList();

  List<TaskModel> forDate(DateTime d) =>
      tasks.where((t) => t.date == dateKey(d)).toList();

  List<TaskModel> get today => forDate(DateTime.now());

  List<TaskModel> get upcoming {
    final now = DateTime.now();
    return pending.where((t) => t.dateTime.isAfter(now)).take(3).toList();
  }

  /// Share of today's tasks that are done (0-100).
  int get todayProgress {
    final t = today;
    if (t.isEmpty) return 0;
    return ((t.where((x) => x.done).length / t.length) * 100).round();
  }

  Future<String> add(TaskModel t) async {
    final id = await _service.add(uid, t);
    await NotificationService.instance.scheduleTaskReminder(t.copyWith(id: id));
    return id;
  }

  Future<void> update(TaskModel t) async {
    await _service.update(uid, t);
    if (t.done) {
      await NotificationService.instance.cancelTaskReminder(t.id);
    } else {
      await NotificationService.instance.scheduleTaskReminder(t);
    }
  }

  Future<void> toggle(TaskModel t) async {
    final newDone = !t.done;
    await _service.setDone(uid, t.id, newDone);
    if (newDone) {
      await NotificationService.instance.cancelTaskReminder(t.id);
    } else {
      await NotificationService.instance.scheduleTaskReminder(t.copyWith(done: false));
    }
  }

  Future<void> remove(String id) async {
    await _service.delete(uid, id);
    await NotificationService.instance.cancelTaskReminder(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
