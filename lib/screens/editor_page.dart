

import 'package:code_editor/models/editor_tab.dart';
import 'package:code_editor/screens/multi_editor_page.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
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
  // late CodeController _codeController;
  // String _currentLanguage = 'dart';
  // String? _currentFilePath;
  bool _isExplorerExpanded = true;
  final double _minDrawerWidth = 200;
  final double _maxDrawerWidth = 400;
  double _drawerWidth = 250;
  
  // final Map<String, Map<String, dynamic>> _supportedLanguages = {
  //   'dart': {'mode': dart, 'ext': '.dart'},
  //   'python': {'mode': python, 'ext': '.py'},
  //   'javascript': {'mode': javascript, 'ext': '.js'},
  // };
  final List<EditorTab> _tabs = [
    EditorTab(
        name: 'dart testing',
        controller: CodeController(
          text: '',
          language: dart,
        )), EditorTab(
        name: 'python testing',
        controller: CodeController(
          text: '',
          language: python,
        ))
  ];

  @override
  void initState() {
    super.initState();
    // _codeController = CodeController(
    //   text: '',
    //   language: _supportedLanguages[_currentLanguage]!['mode'],
    // );
  }

  @override
  void dispose() {
    // _codeController.dispose();
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

        // EditorTab newtab= await EditorTab.getContentFromFilePath(result.files.single.path!);
      setState(() {
        // _tabs.add(newtab);
        // _currentFilePath = kIsWeb ? 'Web File' : result.files.single.path!;
        // _codeController.text = content; // Update UI text controller

        final ext = result.files.single.extension?.toLowerCase();
        Mode language= EditorTab.detectLanguage(ext);
        _tabs.add(EditorTab.fromContent(
              name: name,
              language: language,
              content: content,
            ));
      });
    }
  } catch (e) {
    _showError('Error opening file: $e');
  }
}


  // Future<void> _saveFile() async {
  //   try {
  //     String content = _codeController.text;
  //     String? filePath = _currentFilePath;

  //     if (kIsWeb || filePath == null) {
  //       String? fileName = await _showFileNameDialog();
  //       if (fileName == null || fileName.isEmpty) return;

  //       final extension = _supportedLanguages[_currentLanguage]!['ext'];
  //       if (!fileName.endsWith(extension)) {
  //         fileName += extension;
  //       }

  //       if (kIsWeb) {
  //         final blob = html.Blob([utf8.encode(content)]);
  //         final url = html.Url.createObjectUrlFromBlob(blob);
  //         // final anchor = html.AnchorElement(href: url)
  //         //   ..setAttribute("download", fileName)
  //         //   ..click();
  //         html.Url.revokeObjectUrl(url);
  //         _showMessage('File downloaded successfully');
  //         return;
  //       } else {
  //         filePath = await FilePicker.platform.saveFile(
  //           dialogTitle: "Save File",
  //           fileName: fileName,
  //           type: FileType.any,
  //           allowedExtensions: _supportedLanguages.values
  //               .map((e) => e['ext'].substring(1) as String)
  //               .toList(),
  //         );
  //         if (filePath == null) return;
  //       }
  //     }

  //     final file = File(filePath);
  //     await file.writeAsString(content);
  //     setState(() => _currentFilePath = filePath);
  //     _showMessage('File saved successfully');
  //   } catch (e) {
  //     _showError('Error saving file: $e');
  //   }
  // }

  Future<String?> _showFileNameDialog({String? name}) async {
    TextEditingController fileNameController = TextEditingController(text:  name ?? '');
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

 void _createNew() async {
  String? res = await _showFileNameDialog(name: 'untitled.dart');
  if (res != null) {
    String ext = path.extension(res).toLowerCase(); // Get file extension

    Mode language = EditorTab.detectLanguage(ext);

    setState(() {
      _tabs.add(EditorTab.createEmpty(name: res, language: language));
    });
  }
}

void _addNew(EditorTab tab) {
    setState(() {
      _tabs.add(tab);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _openFile,
            tooltip: 'Open File',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: ()=>{},
            tooltip: 'Save File',
          ),
        ],
      ),
      body: Row(
        children: [
          // File Explorer Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isExplorerExpanded ? _drawerWidth : 48,
            child: Column(
              children: [
                // Explorer Header with toggle button
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  height: 36,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_isExplorerExpanded 
                          ? Icons.chevron_left 
                          : Icons.chevron_right,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExplorerExpanded = !_isExplorerExpanded;
                          });
                        },
                        tooltip: _isExplorerExpanded ? 'Collapse' : 'Expand',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18,
                      ),
                      if (_isExplorerExpanded) 
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'EXPLORER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Resizable Explorer Content
                Expanded(
                  child: _isExplorerExpanded 
                    ?  FileExplorer(
                      newTab: (p0) => _addNew(p0),
                    )
                    : Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder),
                            onPressed: () {
                              setState(() {
                                _isExplorerExpanded = true;
                              });
                            },
                            tooltip: 'Files',
                          ),
                          // Add more sidebar icons as needed
                        ],
                      ),
                ),
              ],
            ),
          ),
          // Resizer
          if (_isExplorerExpanded)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _drawerWidth += details.delta.dx;
                  if (_drawerWidth < _minDrawerWidth) {
                    _drawerWidth = _minDrawerWidth;
                  } else if (_drawerWidth > _maxDrawerWidth) {
                    _drawerWidth = _maxDrawerWidth;
                  }
                });
              },
              child: Container(
                width: 8,
                color: Colors.transparent,
                height: double.infinity,
                child: Center(
                  child: Container(
                    width: 1,
                    color: Colors.grey[700],
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          // Editor Content
          Expanded(
            child: MultiEditorPage(
              tab: _tabs,
              onClose: (p0) => _closeTab(p0),
              createNew: () => _createNew(),
            ),
          ),
        ],
      ),
    );
  }
}


