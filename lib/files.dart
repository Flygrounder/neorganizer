import 'dart:io';

import 'package:neorganizer/note_list.dart';
import 'package:neorganizer/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class NoteStorage {
  WebDavSettingsStorage webDavSettingsStorage;
  bool _isSyncing = false;
  Set<String> _syncedFiles = {};

  NoteStorage({required this.webDavSettingsStorage});

  Future<List<Note>> getNotes() async {
    var directory = await _getSyncDirectory();
    var files = await directory.list(recursive: true).toList();
    var notes = <Note>[];
    for (var fileEntry in files) {
      var path = fileEntry.path;
      if (!path.endsWith(".norg")) {
        continue;
      }
      var lastUpdate = (await fileEntry.stat()).changed;
      var file = File(path);
      var content = await file.readAsString();
      notes.add(Note(content: content, path: path, lastUpdate: lastUpdate));
    }
    notes.sort(
        (first, second) => -first.lastUpdate.compareTo(second.lastUpdate));
    return notes;
  }

  Future<void> syncFiles() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    _syncedFiles = {};
    var settings = await webDavSettingsStorage.loadSettings();
    var webdavClient = webdav.newClient(settings.address,
        user: settings.username, password: settings.password);
    await _syncFilesRecursive(
        settings.directory, webdavClient, settings.directory);
    var directory = await _getSyncDirectory();
    var files = await directory.list(recursive: true).toList();
    for (var file in files) {
      if (!_syncedFiles.contains(file.path)) {
        File(file.path).deleteSync();
      }
    }
    _isSyncing = false;
  }

  Future<void> _syncFilesRecursive(String currentDirectory,
      webdav.Client webdavClient, String baseDir) async {
    for (var entry in await webdavClient.readDir(currentDirectory)) {
      var path = entry.path;
      if (path == null) {
        continue;
      }
      if (entry.isDir == true) {
        _syncFilesRecursive(path, webdavClient, baseDir);
      } else {
        var directory = await _getSyncDirectory();
        String newPath = path.replaceFirst(baseDir, directory.path);
        var components = newPath.split("/");
        components.removeLast();
        var newPathDir = components.join("/");
        Directory(newPathDir).createSync(recursive: true);
        try {
          await webdavClient.read2File(
            path,
            newPath,
          );
        } catch (error) {
          continue;
        }
        _syncedFiles.add(newPath);
      }
    }
  }

  Future<Directory> _getSyncDirectory() async {
    var supportDirectory = (await getExternalStorageDirectory())!.path;
    return Directory("$supportDirectory/Sync");
  }
}
