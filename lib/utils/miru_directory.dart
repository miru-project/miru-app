import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MiruDirectory {
  static late final Directory _appDocDir;
  static late final Directory _cacheDir;

  static ensureInitialized() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _cacheDir = await getTemporaryDirectory();
  }

  static String get getDirectory => _miruDir(_appDocDir);

  static String get getCacheDirectory => _miruDir(_cacheDir);

  static String _miruDir(Directory directory) {
    final dir = path.join(directory.path, 'miru');
    Directory(dir).createSync(recursive: true);
    return dir;
  }
}
