import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowday/data/task_document_mapper.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/repositories/task_repository.dart';

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasksFor(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Stream<TaskSyncUpdate> watchTasks(String userId) =>
      _tasksFor(userId).snapshots(includeMetadataChanges: true).map((snapshot) {
        final tasks = snapshot.docs
            .map(
              (document) =>
                  TaskDocumentMapper.fromDocument(document.data(), document.id),
            )
            .toList();
        tasks.sort((first, second) {
          final firstDate =
              first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final secondDate =
              second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return secondDate.compareTo(firstDate);
        });
        return TaskSyncUpdate(
          tasks: tasks,
          hasPendingWrites: snapshot.metadata.hasPendingWrites,
        );
      });

  @override
  Future<void> createTask(Task task) =>
      _tasksFor(task.userId).doc(task.id).set({
        ...TaskDocumentMapper.toDocument(task),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> updateTask(Task task) =>
      _tasksFor(task.userId).doc(task.id).update({
        ...TaskDocumentMapper.toDocument(task),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> deleteTask(String userId, String taskId) =>
      _tasksFor(userId).doc(taskId).delete();

  @override
  Future<void> deleteAllTasks(String userId) async {
    final tasks = await _tasksFor(userId).get();
    WriteBatch batch = _firestore.batch();
    var operationCount = 0;

    for (final task in tasks.docs) {
      batch.delete(task.reference);
      operationCount++;
      if (operationCount == 450) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) await batch.commit();
  }
}
