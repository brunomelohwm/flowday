import 'package:flutter/material.dart';

void main() {
  runApp(const FlowDayApp());
}

class FlowDayApp extends StatelessWidget {
  const FlowDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('FlowDay'))),
    );
  }
}
