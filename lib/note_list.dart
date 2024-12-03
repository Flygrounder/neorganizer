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
  Map<String, Note> _selectedNotes = {};

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (_selectedNotes.length == 1) {
      var note = _selectedNotes.values.first;
      actions.add(IconButton(
          onPressed: () async {
            var newTitleController =
                TextEditingController(text: note.getTitle());
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Переименовать'),
                    content: TextField(
                      controller: newTitleController,
                      decoration:
                          const InputDecoration(label: Text('Название')),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            var settings =
                                await WebDavSettingsStorage.loadSettings();
                            var client = newClient(settings.address,
                                user: settings.username,
                                password: settings.password);
                            var components = note.path.split("/");
                            components.last = "${newTitleController.text}.norg";
                            var newPath = components.join("/");
                            await client.rename(note.path, newPath, false);
                            refreshNotes();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Переименовать'))
                    ],
                  );
                });
          },
          icon: const Icon(Icons.edit)));
    }
    if (_selectedNotes.isNotEmpty) {
      actions.add(IconButton(
          onPressed: () async {
            var settings = await WebDavSettingsStorage.loadSettings();
            var notes = _selectedNotes;
            var deleteFutures = notes.keys.map((note) {
              var client = newClient(settings.address,
                  user: settings.username, password: settings.password);
              return client.remove(note);
            });
            await Future.wait(deleteFutures);
            refreshNotes();
          },
          icon: const Icon(Icons.delete)));
    }
    return Scaffold(
      appBar: TopBar(
          _selectedNotes.isEmpty
              ? 'Заметки'
              : "Выбрано: ${_selectedNotes.length}",
          displayBackButton: false,
          leading: (_selectedNotes.isEmpty)
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedNotes = {};
                    });
                  }),
          actions: actions),
      body: Center(
        child: FutureBuilder(
          future: _notes,
          builder: (context, snapshot) {
            var notes = snapshot.data ?? [];
            return ListView(
              children: notes.map((note) {
                onSelect() {
                  setState(() {
                    if (_selectedNotes.keys.contains(note.path)) {
                      _selectedNotes.remove(note.path);
                    } else {
                      _selectedNotes.putIfAbsent(note.path, () => note);
                    }
                  });
                }

                return NoteCard(
                  note: note,
                  onTap: () {
                    if (_selectedNotes.isEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NoteEditorRoute(note: note)));
                    } else {
                      onSelect();
                    }
                  },
                  onSelect: onSelect,
                  isSelected: _selectedNotes.keys.contains(note.path),
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
                      title: const Text('Создать'),
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

  void refreshNotes() {
    setState(() {
      _notes = fetchNotes();
      _selectedNotes = {};
    });
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
      notes.add(Note(content: content, path: path, lastUpdate: lastUpdate));
    }
    notes.sort(
        (first, second) => -first.lastUpdate.compareTo(second.lastUpdate));
    return notes;
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final void Function() onSelect;
  final void Function() onTap;
  final bool isSelected;

  const NoteCard(
      {super.key,
      required this.note,
      required this.onSelect,
      required this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    var formattedLastUpdate =
        "${note.lastUpdate.day}.${note.lastUpdate.month}.${note.lastUpdate.year}";
    return GestureDetector(
      onTap: onTap,
      onLongPress: onSelect,
      child: Card(
          color: isSelected
              ? Theme.of(context).hoverColor
              : Theme.of(context).cardColor,
          child: Column(
            children: [
              ListTile(
                title: Text(note.getTitle()),
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
  final String path;
  final String content;
  final DateTime lastUpdate;

  const Note(
      {required var this.path,
      required var this.content,
      required var this.lastUpdate});

  String getTitle() {
    const neorgExtension = ".norg";
    var filename = path.split("/").last;
    if (filename.endsWith(neorgExtension)) {
      return filename.substring(0, filename.length - neorgExtension.length);
    } else {
      return filename;
    }
  }
}
