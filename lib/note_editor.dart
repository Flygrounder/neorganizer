import 'package:flutter/material.dart';
import 'package:neorganizer/bottom_bar.dart';
import 'package:neorganizer/note_list.dart';
import 'package:neorganizer/top_bar.dart';

class NoteEditorRoute extends StatelessWidget {
  final Note note;
  const NoteEditorRoute({super.key, required var this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TopBar(note.title),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: SingleChildScrollView(child: Text(note.content)),
        ),
        bottomNavigationBar: const BottomBar(BottomBarTab.notes));
  }
}
