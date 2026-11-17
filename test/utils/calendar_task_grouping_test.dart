import 'package:flowday/Utils/build_date_info.dart';
import 'package:flowday/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

Task _task({required String id, DateTime? startDate, DateTime? endDate}) =>
    Task(
      id: id,
      userId: 'user-1',
      title: id,
      description: '',
      priority: Priority.none,
      startDate: startDate,
      endDate: endDate,
    );

void main() {
  group('groupTasksByCalendarDay', () {
    test('includes both endpoints and every day in a multi-day range', () {
      final task = _task(
        id: 'range',
        startDate: DateTime(2026, 10, 28, 19),
        endDate: DateTime(2026, 10, 30, 8),
      );

      final grouped = groupTasksByCalendarDay([task]);

      expect(grouped.keys.toSet(), {
        DateTime(2026, 10, 28),
        DateTime(2026, 10, 29),
        DateTime(2026, 10, 30),
      });
      expect(grouped[DateTime(2026, 10, 29)], [task]);
    });

    test('includes a same-day range only once', () {
      final task = _task(
        id: 'same-day',
        startDate: DateTime(2026, 10, 28, 8),
        endDate: DateTime(2026, 10, 28, 20),
      );

      final grouped = groupTasksByCalendarDay([task]);

      expect(grouped, {
        DateTime(2026, 10, 28): [task],
      });
    });

    test('places start-only and end-only tasks on their dated day', () {
      final startOnly = _task(
        id: 'start-only',
        startDate: DateTime(2026, 10, 28),
      );
      final endOnly = _task(id: 'end-only', endDate: DateTime(2026, 10, 29));

      final grouped = groupTasksByCalendarDay([startOnly, endOnly]);

      expect(grouped, {
        DateTime(2026, 10, 28): [startOnly],
        DateTime(2026, 10, 29): [endOnly],
      });
    });

    test('omits tasks without either date', () {
      expect(groupTasksByCalendarDay([_task(id: 'undated')]), isEmpty);
    });
  });
}
