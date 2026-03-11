import 'package:flutter/material.dart';
import 'package:memory_assistant/screens/home_screen.dart';

void main() {
  runApp(const MemoryAssistantApp());
}

class MemoryAssistantApp extends StatelessWidget {
  const MemoryAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}