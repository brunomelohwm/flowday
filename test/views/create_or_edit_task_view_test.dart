import 'dart:async';

import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/models/task.dart';
import 'package:flowday/models/task_sync_update.dart';
import 'package:flowday/models/user.dart';
import 'package:flowday/repositories/auth_repository.dart';
import 'package:flowday/repositories/task_repository.dart';
import 'package:flowday/views/create_or_edit_task_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockEditorAuthRepository extends Mock implements AuthRepository {}

class MockEditorTaskRepository extends Mock implements TaskRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Task(
        id: 'fallback',
        userId: 'user-1',
        title: 'Fallback',
        description: '',
        priority: Priority.none,
      ),
    );
  });

  for (final editing in [false, true]) {
    testWidgets(
      editing
          ? 'edit form returns while its offline write is pending'
          : 'create form returns while its offline write is pending',
      (tester) async {
        final authRepository = MockEditorAuthRepository();
        final taskRepository = MockEditorTaskRepository();
        final write = Completer<void>();
        final taskEvents = StreamController<TaskSyncUpdate>.broadcast();
        when(() => authRepository.currentUserId).thenReturn('user-1');
        when(
          () => authRepository.authStateChanges(),
        ).thenAnswer((_) => const Stream<String?>.empty());
        when(
          () => authRepository.loadProfile('user-1'),
        ).thenAnswer((_) async => User(id: 'user-1', email: 'ana@example.com'));
        when(
          () => taskRepository.watchTasks('user-1'),
        ).thenAnswer((_) => taskEvents.stream);
        when(
          () => taskRepository.createTask(any()),
        ).thenAnswer((_) => write.future);
        when(
          () => taskRepository.updateTask(any()),
        ).thenAnswer((_) => write.future);

        final authController = AuthController(repository: authRepository);
        final taskController = TaskController(repository: taskRepository);
        taskController.setUserId('user-1');
        taskEvents.add(
          TaskSyncUpdate(tasks: const [], hasPendingWrites: false),
        );
        final task = editing
            ? const Task(
                id: 'task-1',
                userId: 'user-1',
                title: 'Existing title',
                description: '',
                priority: Priority.medium,
              )
            : null;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: authController),
              ChangeNotifierProvider.value(value: taskController),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateOrEditTaskView(
                            controller: taskController,
                            task: task,
                          ),
                        ),
                      ),
                      child: const Text('Abrir editor'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(taskController.isLoading, isFalse);
        await tester.tap(find.text('Abrir editor'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField).first,
          editing ? 'Updated title' : 'Offline title',
        );
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          editing ? 'Updated title' : 'Offline title',
        );
        tester.binding.focusManager.primaryFocus?.unfocus();
        await tester.pump();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        if (editing) {
          verify(() => taskRepository.updateTask(any())).called(1);
        } else {
          verify(() => taskRepository.createTask(any())).called(1);
        }
        expect(
          find.text(
            editing ? 'Tarefa atualizada no app.' : 'Tarefa criada no app.',
          ),
          findsOneWidget,
        );
        expect(find.text('Abrir editor'), findsOneWidget);
        expect(find.byType(CreateOrEditTaskView), findsNothing);
        expect(
          find.text(
            editing ? 'Tarefa atualizada no app.' : 'Tarefa criada no app.',
          ),
          findsOneWidget,
        );
        write.complete();
        authController.dispose();
        taskController.dispose();
        await taskEvents.close();
      },
    );
  }
}
