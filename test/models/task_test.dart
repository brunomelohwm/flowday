import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowday/data/task_document_mapper.dart';
import 'package:flowday/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDocumentMapper', () {
    test('round trips every task status', () {
      for (final status in TaskStatus.values) {
        final task = Task(
          id: 'task-1',
          userId: 'owner-1',
          title: 'Prepare portfolio',
          description: 'Finish Flowday',
          priority: Priority.high,
          status: status,
        );

        final data = TaskDocumentMapper.toDocument(task);
        final restored = TaskDocumentMapper.fromDocument(data, task.id);

        expect(restored.status, status);
      }
    });

    test('defaults a legacy document without status to todo', () {
      final task = TaskDocumentMapper.fromDocument({
        'userId': 'owner-1',
        'title': 'Legacy task',
        'description': '',
        'priority': 'medium',
      }, 'legacy-task');

      expect(task.status, TaskStatus.todo);
    });

    test('defaults an unknown stored status to todo', () {
      final task = TaskDocumentMapper.fromDocument({
        'userId': 'owner-1',
        'title': 'Unknown status',
        'description': '',
        'priority': 'none',
        'status': 'archived',
      }, 'unknown-task');

      expect(task.status, TaskStatus.todo);
    });

    test('round trips all task dates through Firestore timestamps', () {
      final start = DateTime(2026, 10, 28, 9);
      final end = DateTime(2026, 10, 30, 17);
      final created = DateTime(2026, 10, 20, 8);
      final updated = DateTime(2026, 10, 27, 12);
      final task = Task(
        id: 'task-dates',
        userId: 'owner-1',
        title: 'Dated task',
        description: '',
        priority: Priority.low,
        createdAt: created,
        updatedAt: updated,
        startDate: start,
        endDate: end,
      );

      final data = TaskDocumentMapper.toDocument(task);
      final restored = TaskDocumentMapper.fromDocument(data, task.id);

      expect(data['startDate'], isA<Timestamp>());
      expect(data['endDate'], isA<Timestamp>());
      expect(restored.createdAt, created);
      expect(restored.updatedAt, updated);
      expect(restored.startDate, start);
      expect(restored.endDate, end);
    });
  });

  test('copyWith preserves dates and updates status', () {
    final start = DateTime(2026, 10, 28);
    final end = DateTime(2026, 10, 29);
    final task = Task(
      id: 'task-1',
      userId: 'owner-1',
      title: 'Prepare portfolio',
      description: '',
      priority: Priority.medium,
      startDate: start,
      endDate: end,
    );

    final updated = task.copyWith(status: TaskStatus.done);

    expect(updated.status, TaskStatus.done);
    expect(updated.startDate, start);
    expect(updated.endDate, end);
  });
}
