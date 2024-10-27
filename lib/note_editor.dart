import 'package:flutter/material.dart';
import 'package:neorganizer/note_list.dart';

class NoteEditor extends StatelessWidget {
  final Note note;
  const NoteEditor({super.key, required var this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: SingleChildScrollView(child: Text(note.content)),
      ),
    );
  }
}
