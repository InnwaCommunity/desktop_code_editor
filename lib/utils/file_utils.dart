import 'dart:io';

class FileUtils {
  static Future<List<FileSystemEntity>> getFilesInDirectory(String path) async {
    final directory = Directory(path);
    return directory.listSync();
  }
}
