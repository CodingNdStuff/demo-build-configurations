import 'dart:io';

abstract class Utils {
  static String get path {
    String scriptPath = Platform.script.toFilePath();
    return Directory(scriptPath).parent.path;
  }

  static String get parentPath {
    String scriptPath = Platform.script.toFilePath();
    return Directory(scriptPath).parent.parent.path;
  }
}
