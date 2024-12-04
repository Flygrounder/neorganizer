import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:neorganizer/files.dart';
import 'package:neorganizer/note_list.dart';
import 'package:neorganizer/settings.dart';

void main() async {
  var webDavSettingsStorage =
      WebDavSettingsStorage(secureStorage: const FlutterSecureStorage());
  GetIt.I.registerSingleton<WebDavSettingsStorage>(webDavSettingsStorage);
  GetIt.I.registerSingleton<NoteStorage>(
      NoteStorage(webDavSettingsStorage: webDavSettingsStorage));

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
      home: const NoteListRoute(),
    );
  }
}
