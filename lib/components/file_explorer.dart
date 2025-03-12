import 'package:code_editor/models/editor_tab.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/dart.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({required this.newTab, super.key});
  final Function(EditorTab) newTab;

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  // Sample folder structure - in a real app, this would be populated dynamically
  Map<String, dynamic> _fileStructure = {
    'lib': {
      'components': {
        'editor_tab_item.dart': 'dart',
        'file_explorer.dart': 'dart',
        'terminal.dart': 'dart',
      },
      'models': {
        'editor_tab.dart': 'dart',
      },
      'screens': {
        'editor_page.dart': 'dart',
        'multi_editor_page.dart': 'dart',
      },
      'utils': {
        'file_utils.dart': 'dart',
        'support_languages.dart': 'dart',
      },
      'main.dart': 'dart',
    },
    'assets': {
      'images': {
        'logo.png': 'image',
      },
      'language_ic': {
        'flutter_ic.png': 'image',
        'python_ic.png': 'image',
        'javascript_ic.png': 'image',
      },
    },
    'build': {},
    'ios': {},
    'linux': {},
    'flutter': {},
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildFileTree(_fileStructure),
            ),
          ),
        ],
      ),
    );
  }
  void _showCreateFolderDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: 'Enter folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty && !_fileStructure.containsKey(folderName)) {
                  setState(() {
                    _fileStructure[folderName] = {};
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  void _showCreateFileDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New File'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: 'Enter file name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty && !_fileStructure.containsKey(folderName)) {
                  setState(() {
                    _fileStructure[folderName] = 'dart';
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'FILES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.create_new_folder, size: 16),
                onPressed: () {
                  _showCreateFolderDialog(context);
                  // _pickFolder();
                  // Add new folder functionality
                },
                tooltip: 'New Folder',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(Icons.note_add, size: 16),
                onPressed: () {
                  _showCreateFileDialog(context);
                  // Add new file functionality
                },
                tooltip: 'New File',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: () {
                  // Refresh explorer
                  setState(() {});
                },
                tooltip: 'Refresh',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
 

 Future<void> _pickFolder() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );

  if (result != null) {
    for (var file in result.files) {
      if (file.name.contains('/')) {
        _addFileToStructure(file.name);
      } else {
        _fileStructure[file.name] = _getFileType(file.name);
      }
    }
  }
}

void _addFileToStructure(String fullFileName) {
  List<String> parts = fullFileName.split('/'); // Simulated folder structure
  _fileStructure = {};
  Map<String, dynamic> currentLevel = _fileStructure;

  for (int i = 0; i < parts.length; i++) {
    String part = parts[i];

    if (i == parts.length - 1) {
      // Last part, it's a file
      String fileType = _getFileType(part);
      currentLevel[part] = fileType;
    } else {
      // Folder
      if (!currentLevel.containsKey(part)) {
        currentLevel[part] = {};
      }
      currentLevel = currentLevel[part] as Map<String, dynamic>;
    }
  }
}

String _getFileType(String fileName) {
  if (fileName.endsWith('.dart')) return 'dart';
  if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) return 'image';
  return 'file';
}
List<Widget> _buildFileTree(Map<String, dynamic> structure, {String path = ''}) {
  List<Widget> items = [];

  final List<MapEntry<String, dynamic>> sortedEntries = structure.entries.toList()
    ..sort((a, b) {
      final aIsFolder = a.value is Map;
      final bIsFolder = b.value is Map;
      if (aIsFolder && !bIsFolder) return -1;
      if (!aIsFolder && bIsFolder) return 1;
      return a.key.compareTo(b.key);
    });

  for (var entry in sortedEntries) {
    final String name = entry.key;
    final dynamic content = entry.value;
    final String fullPath = path.isEmpty ? name : '$path/$name';

    if (content is Map) {
      items.add(
        FolderItem(
          name: name,
          path: fullPath,
          children: _buildFileTree(content.cast<String, dynamic>(), path: fullPath), // Explicit cast here
        ),
      );
    } else {
      items.add(
        FileItem(
          name: name,
          type: content,
          path: fullPath,
          onTap: () {
            CodeController  controller = CodeController(text: '',language:  dart);
            EditorTab newTab = EditorTab(name: name,filePath: fullPath, controller: controller);
            widget.newTab(newTab);
          },
        ),
      );
    }
  }

  return items;
}
}

class FolderItem extends StatefulWidget {
  final String name;
  final String path;
  final List<Widget> children;

  const FolderItem({
    required this.name,
    required this.path,
    required this.children,
    super.key,
  });

  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.folder_open : Icons.folder,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}

class FileItem extends StatelessWidget {
  final String name;
  final String type;
  final String path;
  final VoidCallback onTap;

  const FileItem({
    required this.name,
    required this.type,
    required this.path,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 18),
            _getFileIcon(),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon() {
    IconData iconData;
    Color color;
    
    switch (type) {
      case 'dart':
        iconData = Icons.code;
        color = Colors.lightBlue;
        break;
      case 'python':
        iconData = Icons.code;
        color = Colors.green;
        break;
      case 'javascript':
        iconData = Icons.javascript;
        color = Colors.yellow;
        break;
      case 'image':
        iconData = Icons.image;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = Colors.grey;
    }
    
    return Icon(
      iconData,
      size: 16,
      color: color,
    );
  }
}
