import 'package:flutter/material.dart';
import 'package:rumber_me/screens/home_screen.dart';

void main() {
  runApp(const RumberMeApp());
}

class RumberMeApp extends StatelessWidget {
  const RumberMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记忆梦核',
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