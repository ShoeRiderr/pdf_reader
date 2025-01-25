import 'package:flutter/material.dart';
import 'package:pdf_reader/widgets/doc_list.dart';

import 'package:pdf_reader/models/file.dart';

class DocListScreen extends StatefulWidget {
  const DocListScreen({super.key, required this.savedFiles, this.title = "Document List"});
  final List<FileModel> savedFiles;
  final String title;

  @override
  DocListScreenState createState() => DocListScreenState();
}

class DocListScreenState extends State<DocListScreen> {
  @override
  Widget build(BuildContext context) {
    return DocListWidget(savedFiles: widget.savedFiles);
  }
}