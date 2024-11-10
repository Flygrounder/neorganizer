import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neorganizer/note_editor.dart';
import 'package:neorganizer/settings.dart';
import 'package:neorganizer/top_bar.dart';
import 'package:webdav_client/webdav_client.dart';

import 'bottom_bar.dart';

class NoteListRoute extends StatefulWidget {
  const NoteListRoute({super.key});

  @override
  State<NoteListRoute> createState() => _NoteListRouteState();
}

class _NoteListRouteState extends State<NoteListRoute> {
  Future<List<Note>> _notes = fetchNotes();
  String? _selectedNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar('Заметки',
          displayBackButton: false,
          leading: (_selectedNote == null)
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedNote = null;
                    });
                  }),
          actions: (_selectedNote == null)
              ? []
              : [
                  IconButton(
                      onPressed: () async {
                        var settings =
                            await WebDavSettingsStorage.loadSettings();
                        var client = newClient(settings.address,
                            user: settings.username,
                            password: settings.password);
                        var note = _selectedNote;
                        if (note != null) {
                          await client.remove(note);
                        }
                        setState(() {
                          _selectedNote = null;
                          _notes = fetchNotes();
                        });
                      },
                      icon: const Icon(Icons.delete))
                ]),
      body: Center(
        child: FutureBuilder(
          future: _notes,
          builder: (context, snapshot) {
            var notes = snapshot.data ?? [];
            return ListView(
              children: notes.map((note) {
                return NoteCard(
                  note: note,
                  onSelect: () {
                    setState(() {
                      _selectedNote = note.path;
                    });
                  },
                  isSelected: _selectedNote == note.path,
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.create),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  TextEditingController titleController =
                      TextEditingController();
                  return AlertDialog(
                      title: const Text('Создание заметки'),
                      content: TextField(
                          controller: titleController,
                          decoration:
                              const InputDecoration(label: Text('Название'))),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              var settings =
                                  await WebDavSettingsStorage.loadSettings();
                              var title = "${titleController.text}.norg";
                              if (context.mounted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoteEditorRoute(
                                            note: Note(
                                                title: title,
                                                content: '',
                                                path:
                                                    "${settings.directory}/$title",
                                                lastUpdate: DateTime.now()))));
                              }
                            },
                            child: const Text('СОЗДАТЬ'))
                      ]);
                });
          }),
      bottomNavigationBar: const BottomBar(BottomBarTab.notes),
    );
  }

  static Future<List<Note>> fetchNotes() async {
    var settings = await WebDavSettingsStorage.loadSettings();
    var client = newClient(
      settings.address,
      user: settings.username,
      password: settings.password,
    );
    var files = await client.readDir(settings.directory);
    var notes = <Note>[];
    for (var file in files) {
      var title = file.name;
      var path = file.path;
      var lastUpdate = file.mTime;
      if (title == null ||
          !title.endsWith('.norg') ||
          path == null ||
          lastUpdate == null) {
        continue;
      }
      var content = utf8.decode(await client.read(path));
      notes.add(Note(
          title: title, content: content, path: path, lastUpdate: lastUpdate));
    }
    notes.sort(
        (first, second) => -first.lastUpdate.compareTo(second.lastUpdate));
    return notes;
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final void Function() onSelect;
  final bool isSelected;

  const NoteCard(
      {super.key,
      required this.note,
      required this.onSelect,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    var formattedLastUpdate =
        "${note.lastUpdate.day}.${note.lastUpdate.month}.${note.lastUpdate.year}";
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NoteEditorRoute(note: note)))
      },
      onLongPress: onSelect,
      child: Card(
          color: isSelected
              ? Theme.of(context).hoverColor
              : Theme.of(context).cardColor,
          child: Column(
            children: [
              ListTile(
                title: Text(note.title),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(formattedLastUpdate),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class Note {
  final String title;
  final String content;
  final String path;
  final DateTime lastUpdate;

  const Note(
      {required var this.title,
      required var this.content,
      required var this.path,
      required var this.lastUpdate});
}
