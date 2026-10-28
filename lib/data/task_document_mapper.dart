import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowday/models/task.dart';

class TaskDocumentMapper {
  const TaskDocumentMapper._();

  static Task fromDocument(Map<String, dynamic> data, String id) {
    DateTime? dateFrom(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Task(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: Priority.values.firstWhere(
        (value) => value.name == data['priority'],
        orElse: () => Priority.none,
      ),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => TaskStatus.todo,
      ),
      createdAt: dateFrom(data['createdAt']),
      updatedAt: dateFrom(data['updatedAt']),
      startDate: dateFrom(data['startDate']),
      endDate: dateFrom(data['endDate']),
    );
  }

  static Map<String, dynamic> toDocument(Task task) {
    return {
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'status': task.status.name,
      if (task.createdAt != null)
        'createdAt': Timestamp.fromDate(task.createdAt!),
      if (task.updatedAt != null)
        'updatedAt': Timestamp.fromDate(task.updatedAt!),
      'startDate': task.startDate == null
          ? null
          : Timestamp.fromDate(task.startDate!),
      'endDate': task.endDate == null
          ? null
          : Timestamp.fromDate(task.endDate!),
    };
  }
}
