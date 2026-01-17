import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskController = TaskController();
  await taskController.loadTasks();
  runApp(
    MultiProvider(
      providers: [   
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider.value(value: taskController),
      ],
      child: const FlowDayApp(),
    ),
  );
}

class FlowDayApp extends StatelessWidget {
  const FlowDayApp({super.key});
   
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF212121),
          iconTheme: IconThemeData(color: Color(0xFF212121)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF424242), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF757575)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF212121),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF212121),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashView(), 
    );
  }
}
