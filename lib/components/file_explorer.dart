import 'package:flutter/material.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  ValueNotifier<bool> folder1 = ValueNotifier(false);
  ValueNotifier<bool> folder2 = ValueNotifier(false);
  ValueNotifier<bool> folder3 = ValueNotifier(false);
  ValueNotifier<bool> folder4 = ValueNotifier(false);
  ValueNotifier<bool> folder5 = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: ListView(
        children: [
          ValueListenableBuilder(
              valueListenable: folder1,
              builder: (context, show, child) {
                return FolderStructureDesign(
                  initalshow: show,
                  fileName: 'Folder 1',
                  onChange: () => folder1.value = !show,
                  subchild: InkWell(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/language_ic/flutter_ic.png',
                          width: 12,
                          height: 12,
                        ),
                        Text('File 1.dart', style: TextStyle(fontSize: 12,color: Colors.white)),
                      ],
                    ),
                  ),
                );
              }),
          ValueListenableBuilder(
              valueListenable: folder2,
              builder: (context, show, child) {
                return FolderStructureDesign(
                  initalshow: show,
                  fileName: 'Folder 2',
                  onChange: () => folder2.value = !show,
                  subchild: ValueListenableBuilder(
                      valueListenable: folder3,
                      builder: (context, show, child) {
                        return FolderStructureDesign(
                          initalshow: show,
                          fileName: 'Folder 3',
                          onChange: () => folder3.value = !show,
                          subchild: InkWell(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/language_ic/flutter_ic.png',
                                  width: 12,
                                  height: 12,
                                ),
                                Text('file 2.dart', style: TextStyle(fontSize: 12,color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }),
          ValueListenableBuilder(
              valueListenable: folder4,
              builder: (context, show, child) {
                return FolderStructureDesign(
                  initalshow: show,
                  fileName: 'Folder 4',
                  onChange: () => folder4.value = !show,
                  subchild: ValueListenableBuilder(
                      valueListenable: folder5,
                      builder: (context, show, child) {
                        return FolderStructureDesign(
                          initalshow: show,
                          fileName: 'Folder 4',
                          onChange: () => folder5.value = !show,
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}

class FolderStructureDesign extends StatelessWidget {
  const FolderStructureDesign({required this.fileName, required this.onChange, this.subchild, this.initalshow = false, super.key});
  final bool initalshow;
  final void Function()? onChange;
  final String fileName;
  final Widget? subchild;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onChange,
          child: Row(
            children: [
              Icon(initalshow ? Icons.arrow_drop_down : Icons.arrow_forward_ios, size: 12, color: Colors.white),
              Text(fileName, style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
        if (initalshow && subchild != null) Padding(
          padding: const EdgeInsets.only(left: 10),
          child: subchild!,
        ),
      ],
    );
  }
}

class FileStructureDesign extends StatelessWidget {
  const FileStructureDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
