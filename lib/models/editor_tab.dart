
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/highlight_core.dart';

class EditorTab {
  String name;
  String? filePath;
  Mode language;
  CodeController controller;
  bool isModified = false;

  EditorTab({
    required this.name,
    this.filePath,
    required this.language,
    required this.controller,
  });

  // Helper to create a new empty tab
  static EditorTab createEmpty({
    String name = 'Untitled',
    required Mode language,
  }) {
    return EditorTab(
      name: name,
      language: language,
      controller: CodeController(
        text: '',
        language:  language,
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
      language: language,
      controller: CodeController(
        text: content,
        language: language,
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}

