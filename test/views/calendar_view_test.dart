import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/views/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarTaskRepository extends Mock implements TaskRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('shows a selected date outside the horizontal date strip', (
    tester,
  ) async {
    final controller = TaskController(repository: MockCalendarTaskRepository());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          locale: Locale('pt', 'BR'),
          supportedLocales: [Locale('pt', 'BR')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CalendarView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '11/05/2030');
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final selectedDateLabel = DateFormat(
      'EEEE, d MMMM yyyy',
      'pt_BR',
    ).format(DateTime(2030, 5, 11));
    expect(find.text(selectedDateLabel), findsOneWidget);

    controller.dispose();
  });
}
