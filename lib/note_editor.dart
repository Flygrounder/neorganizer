import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neorganizer/bottom_bar.dart';
import 'package:neorganizer/note_list.dart';
import 'package:neorganizer/settings.dart';
import 'package:neorganizer/top_bar.dart';
import 'package:webdav_client/webdav_client.dart';

class NoteEditorRoute extends StatefulWidget {
  final Note note;
  const NoteEditorRoute({super.key, required var this.note});

  @override
  State<NoteEditorRoute> createState() => _NoteEditorRouteState();
}

class _NoteEditorRouteState extends State<NoteEditorRoute> {
  bool editMode = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.note.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TopBar(widget.note.title),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: SingleChildScrollView(
              child: TextField(
                  controller: _controller, maxLines: null, enabled: editMode)),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(editMode ? Icons.save : Icons.edit),
            onPressed: () {
              if (editMode) {
                updateNote();
              }
              setState(() {
                editMode = !editMode;
              });
            }),
        bottomNavigationBar: const BottomBar(BottomBarTab.notes));
  }

  Future<void> updateNote() async {
    var settings = await WebDavSettingsStorage.loadSettings();
    var client = newClient(settings.address,
        user: settings.username, password: settings.password);
    await client.write(widget.note.path, utf8.encode(_controller.text));
  }
}
