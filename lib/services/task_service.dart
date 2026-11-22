import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  TaskService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  /// Live list of the user's tasks, sorted by date + time (no composite index needed).
  Stream<List<TaskModel>> watch(String uid) => _col(uid).snapshots().map((s) {
        final list = s.docs.map(TaskModel.fromDoc).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      });

  Future<String> add(String uid, TaskModel t) async {
    final ref = await _col(uid).add({
      ...t.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> update(String uid, TaskModel t) => _col(uid).doc(t.id).update({
        ...t.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> setDone(String uid, String id, bool done) => _col(uid)
      .doc(id)
      .update({'done': done, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
