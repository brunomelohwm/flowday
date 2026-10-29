import 'package:flowday/Utils/sort_tasks_by_due_date.dart';
import 'package:flowday/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sorts by due date, then creation time, then id with no due date last', () {
    final tasks = [
      _task('no-date', endDate: null),
      _task('later', endDate: DateTime(2026, 11, 3)),
      _task(
        'older-created',
        endDate: DateTime(2026, 11, 2),
        createdAt: DateTime(2026, 10, 1),
      ),
      _task(
        'newer-created',
        endDate: DateTime(2026, 11, 2),
        createdAt: DateTime(2026, 10, 2),
      ),
      _task(
        'tie-b',
        endDate: DateTime(2026, 11, 2),
        createdAt: DateTime(2026, 10, 2),
      ),
      _task(
        'tie-a',
        endDate: DateTime(2026, 11, 2),
        createdAt: DateTime(2026, 10, 2),
      ),
    ];

    final sorted = sortTasksByDueDate(tasks);

    expect(
      sorted.map((task) => task.id),
      ['newer-created', 'tie-a', 'tie-b', 'older-created', 'later', 'no-date'],
    );
    expect(tasks.first.id, 'no-date');
  });
}

Task _task(String id, {DateTime? endDate, DateTime? createdAt}) => Task(
  id: id,
  userId: 'user-1',
  title: id,
  description: '',
  priority: Priority.none,
  endDate: endDate,
  createdAt: createdAt,
);
