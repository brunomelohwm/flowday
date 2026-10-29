import 'package:flowday/widgets/due_date_sort_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays and toggles the current due date direction', (
    tester,
  ) async {
    var descending = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: DueDateSortButton(
              descending: descending,
              onPressed: () => setState(() => descending = !descending),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Prazo mais próximo'), findsOneWidget);
    await tester.tap(find.text('Prazo mais próximo'));
    await tester.pump();
    expect(find.text('Prazo mais distante'), findsOneWidget);
  });
}
