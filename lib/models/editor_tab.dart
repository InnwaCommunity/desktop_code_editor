import 'dart:io';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:path/path.dart' as path;

class EditorTab {
  String name;
  String? filePath;
  CodeController controller;
  bool isModified = false;

  EditorTab({
    required this.name,
    this.filePath,
    required this.controller,
  });

  static EditorTab createEmpty({
    String name = 'untitled',
    required Mode language,
  }) {
    return EditorTab(
      name: name,
      controller: CodeController(
        text: '',
        language: language,
      ),
    );
  }

  static EditorTab fromContent({
    required String name,
    String? filePath,
    required Mode language,
    required String content,
  }) {
    return EditorTab(
      name: name,
      filePath: filePath,
      controller: CodeController(
        text: content,
        language: language,
      ),
    );
  }

  static Future<EditorTab> getContentFromFilePath(String filePath) async {
    final file = File(filePath);
    String content = await file.readAsString();
    String name = path.basename(file.path);
    String? ext = path.extension(filePath).toLowerCase();
    Mode language = detectLanguage(ext);

    return EditorTab(
      name: name,
      filePath: filePath,
      controller: CodeController(
        text: content,
        language: language,
      ),
    );
  }

  static Mode detectLanguage(String? ext) {
    Map<String, Mode> supportedLanguages = {
      '.dart': dart,
      '.js': javascript,
      '.ts': typescript,
      '.py': python,
      '.java': java,
      '.cpp': cpp,
      '.css': css,
      '.json': json,
      '.yaml': yaml,
    };

    return supportedLanguages[ext] ?? dart;
  }

  void dispose() {
    controller.dispose();
  }
}
