import 'package:flutter/material.dart';
import 'package:neorganizer/note_list.dart';

void main() {
  runApp(const NeorganizerApp());
}

class NeorganizerApp extends StatelessWidget {
  const NeorganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neorganizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: NoteListRoute(),
    );
  }
}
