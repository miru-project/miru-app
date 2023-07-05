import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MiruDirectory {
  static Future<String> get getDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return _miruDir(directory);
  }

  static Future<String> get getCacheDirectory async {
    final directory = await getTemporaryDirectory();
    return _miruDir(directory);
  }

  static String _miruDir(Directory directory) {
    final dir = path.join(directory.path, 'miru');
    Directory(dir).createSync(recursive: true);
    return dir;
  }
}
