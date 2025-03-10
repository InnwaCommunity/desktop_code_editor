import 'package:code_editor/models/editor_tab.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';

class EditorTabItem extends StatelessWidget {
  final EditorTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const EditorTabItem({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        margin: const EdgeInsets.only(left: 2, top: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[800] : Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          border: Border(
            bottom: BorderSide(
              color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File icon based on language
            _getLanguageIcon(),
            const SizedBox(width: 4),
            // File name
            Text(
              tab.name + (tab.isModified ? '*' : ''),
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            // Close button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLanguageIcon() {
    if (identical(tab.language, dart)) {
      return Image.asset(
        'assets/language_ic/flutter_ic.png',
        width: 16,
        height: 16,
      );
    } else if (identical(tab.language, python)) {
      return const Icon(Icons.code, size: 16, color: Colors.white70);
    } else if (identical(tab.language, javascript)) {
      return const Icon(Icons.javascript, size: 16, color: Colors.white70);
    } else {
      return const Icon(Icons.description, size: 16, color: Colors.white70);
    }
  }


//   Widget _getLanguageIcon() {
//   switch (tab.language) {
//     case dart:
//       return Image.asset(
//         'assets/language_ic/flutter_ic.png',
//         width: 16,
//         height: 16,
//       );
//     case python:
//       return const Icon(Icons.code, size: 16, color: Colors.white70);
//     case javascript:
//       return const Icon(Icons.javascript, size: 16, color: Colors.white70);
//     default:
//       return const Icon(Icons.description, size: 16, color: Colors.white70);
//   }
// }
}

