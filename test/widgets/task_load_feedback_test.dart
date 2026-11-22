import 'package:flowday/widgets/task_load_feedback.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the task error and calls retry when tapped', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskLoadFeedback(
            isLoading: false,
            errorMessage: 'Falha ao conectar.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Falha ao conectar.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(retried, isTrue);
  });

  testWidgets('shows progress while task data is loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaskLoadFeedback(
            isLoading: true,
            errorMessage: null,
            onRetry: _noop,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });
}

void _noop() {}
