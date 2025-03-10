
import 'dart:developer';

import 'package:code_editor/models/editor_tab.dart';
import 'package:code_editor/screens/multi_editor_page.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Required for web downloads
import '../components/file_explorer.dart';
import 'package:path/path.dart' as path;
import '../components/terminal.dart';
import 'dart:io';


class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late CodeController _codeController;
  String _currentLanguage = 'dart';
  String? _currentFilePath;
  
  final Map<String, Map<String, dynamic>> _supportedLanguages = {
    'dart': {'mode': dart, 'ext': '.dart'},
    'python': {'mode': python, 'ext': '.py'},
    'javascript': {'mode': javascript, 'ext': '.js'},
  };
  final List<EditorTab> _tabs = [
    EditorTab(
        name: 'dart testing',
        language: dart,
        controller: CodeController(
          text: '',
          language: dart,
        )), EditorTab(
        name: 'python testing',
        language: python,
        controller: CodeController(
          text: '',
          language: python,
        ))
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '',
      language: _supportedLanguages[_currentLanguage]!['mode'],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

Future<void> _openFile() async {
  try {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String content = '';
      String name = '';

      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          content = String.fromCharCodes(bytes);
          name = result.files.single.name; // For web, get the file name directly
        }
      } else {
        final file = File(result.files.single.path!);
        content = await file.readAsString();
        name = path.basename(file.path); // Extract file name
      }

      setState(() {
        _currentFilePath = kIsWeb ? 'Web File' : result.files.single.path!;
        _codeController.text = content; // Update UI text controller

        final ext = result.files.single.extension?.toLowerCase();
        for (var entry in _supportedLanguages.entries) {
          if (entry.value['ext'] == '.$ext') {
            _currentLanguage = entry.key;
            _codeController.language = entry.value['mode'];

            // Add a new tab with the correct file name and content
            _tabs.add(EditorTab.fromContent(
              name: name,
              language: entry.value['mode'],
              content: content,
            ));
            break;
          }
        }
      });
    }
  } catch (e) {
    _showError('Error opening file: $e');
  }
}


  Future<void> _saveFile() async {
    try {
      String content = _codeController.text;
      String? filePath = _currentFilePath;

      if (kIsWeb || filePath == null) {
        String? fileName = await _showFileNameDialog();
        if (fileName == null || fileName.isEmpty) return;

        final extension = _supportedLanguages[_currentLanguage]!['ext'];
        if (!fileName.endsWith(extension)) {
          fileName += extension;
        }

        if (kIsWeb) {
          final blob = html.Blob([utf8.encode(content)]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          // final anchor = html.AnchorElement(href: url)
          //   ..setAttribute("download", fileName)
          //   ..click();
          html.Url.revokeObjectUrl(url);
          _showMessage('File downloaded successfully');
          return;
        } else {
          filePath = await FilePicker.platform.saveFile(
            dialogTitle: "Save File",
            fileName: fileName,
            type: FileType.any,
            allowedExtensions: _supportedLanguages.values
                .map((e) => e['ext'].substring(1) as String)
                .toList(),
          );
          if (filePath == null) return;
        }
      }

      final file = File(filePath);
      await file.writeAsString(content);
      setState(() => _currentFilePath = filePath);
      _showMessage('File saved successfully');
    } catch (e) {
      _showError('Error saving file: $e');
    }
  }

  Future<String?> _showFileNameDialog() async {
    TextEditingController fileNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter File Name"),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: "Enter file name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileNameController.text.trim());
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _closeTab(int index) {
    setState(() {
      if (_tabs.length == 1) {
        return;
      }

      _tabs.removeAt(index);
    });
  }

 void _createNew() {
  setState(() {
    Mode languageMode = _supportedLanguages[_currentLanguage]!['mode']; // Get the Mode
    _tabs.add(EditorTab.createEmpty(language: languageMode));
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          DropdownButton<String>(
            value: _currentLanguage,
            items: _supportedLanguages.keys.map((String lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.toUpperCase()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentLanguage = newValue;
                  _codeController.language = _supportedLanguages[newValue]!['mode'];
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _openFile,
            tooltip: 'Open File',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
            tooltip: 'Save File',
          ),
        ],
      ),
      drawer: FileExplorer(),
      body: MultiEditorPage(
            tab:_tabs,
            onClose: (p0) => _closeTab(p0),
            createNew: () => _createNew(),
          ),
      // body: Column(
      //   children: [
      //     MultiEditorPage(
      //       tab:_tabs,
      //       onClose: (p0) => _closeTab(p0),
      //     ),
      //     // Expanded(
      //     //   flex: 1,
      //     //   child: Terminal(),
      //     // ),
      //   ],
      // ),
    );
  }
}


