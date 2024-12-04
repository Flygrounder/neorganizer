import 'dart:io';

import 'package:neorganizer/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart';

class NoteStorage {
  WebDavSettingsStorage webDavSettingsStorage;
  bool isSyncing = false;

  NoteStorage({required this.webDavSettingsStorage});

  Future<void> syncFiles() async {
    if (isSyncing) {
      return;
    }
    isSyncing = true;
    var settings = await webDavSettingsStorage.loadSettings();
    var webdavClient = newClient(settings.address,
        user: settings.username, password: settings.password);
    _syncFilesRecursive(settings.directory, webdavClient, settings.directory);
    isSyncing = false;
  }

  void _syncFilesRecursive(
      String currentDirectory, Client webdavClient, String baseDir) async {
    for (var entry in await webdavClient.readDir(currentDirectory)) {
      var path = entry.path;
      if (path == null) {
        continue;
      }
      if (entry.isDir == true) {
        _syncFilesRecursive(path, webdavClient, baseDir);
      } else {
        String newPath = path.replaceFirst(baseDir, await _getSyncDirectory());
        var components = newPath.split("/");
        components.removeLast();
        var newPathDir = components.join("/");
        Directory(newPathDir).createSync(recursive: true);
        await webdavClient.read2File(
          path,
          newPath,
        );
      }
    }
  }

  Future<String> _getSyncDirectory() async {
    var supportDirectory = (await getExternalStorageDirectory())!.path;
    return "$supportDirectory/Sync";
  }
}
