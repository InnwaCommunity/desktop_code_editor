import 'package:code_editor/components/editor_tab_item.dart';
import 'package:code_editor/models/editor_tab.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';

class MultiEditorPage extends StatefulWidget {
  const MultiEditorPage({required this.tab, required this.onClose, required this.createNew, super.key});
  final List<EditorTab> tab;
  final void Function(int) onClose;
  final void Function() createNew;

  @override
  State<MultiEditorPage> createState() => _MultiEditorPageState();
}

class _MultiEditorPageState extends State<MultiEditorPage> {
  List<EditorTab> _tabs = [];
  int _activeTabIndex = 0;

  @override
  void initState() {
    _tabs = widget.tab;
    _activeTabIndex = _tabs.length-1;
    super.initState();
  }

  void _switchToTab(int index) {
    setState(() {
      _activeTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length + 1,
            itemBuilder: (context, index) {
              if (index == _tabs.length) {
                return FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      widget.createNew();
                    });
              }
              final tab = _tabs[index];
              final isActive = index == _activeTabIndex;
              return _buildTab(tab, index, isActive);
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: CodeField(
              controller: _tabs[_activeTabIndex].controller,
              wrap: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(EditorTab tab, int index, bool isActive) {
    return EditorTabItem(
      tab: tab,
      isActive: isActive,
      onTap: () => _switchToTab(index),
      onClose: () => widget.onClose(index),
    );
  }
}
