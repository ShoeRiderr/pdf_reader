import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/doc_list_item.dart';

class DocList extends StatefulWidget {
  const DocList({super.key});

  @override
  DocListState createState() => DocListState();
}

class DocListState extends State<DocList> {
  List<FileSystemEntity> allFiles = [];
  List<FileSystemEntity> filteredFiles = [];
  String? selectedExtension;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      // Get the application's document directory
      final directory = await getApplicationDocumentsDirectory();
      final sourceDir = Directory('${directory.path}/source');

      // Create a dummy source directory and files for demonstration
      if (!sourceDir.existsSync()) {
        sourceDir.createSync(recursive: true);
        File('${sourceDir.path}/example1.txt').writeAsStringSync('File content 1');
        File('${sourceDir.path}/example2.md').writeAsStringSync('File content 2');
        File('${sourceDir.path}/example3.txt').writeAsStringSync('File content 3');
      }

      // Get all files in the source directory
      final files = sourceDir.listSync();

      setState(() {
        allFiles = files.whereType<File>().toList();
        filteredFiles = List.from(allFiles);
      });
    } catch (e) {
      print('Error loading files: $e');
    }
  }

  void _filterFiles(String extension) {
    setState(() {
      selectedExtension = extension;
      filteredFiles = allFiles
          .where((file) => file.path.endsWith(extension))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document list"),
      ),
      body: ListView.builder(
        itemCount: filteredFiles.length,
        itemBuilder: (context, index) {
          return DocListItem(file: filteredFiles[index]);
        },
      ),
    );
  }

}