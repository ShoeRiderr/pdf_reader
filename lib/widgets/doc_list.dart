import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/services/file_service.dart';
import 'package:pdf_reader/widgets/doc_list_item.dart';

class DocListWidget extends StatefulWidget {
  const DocListWidget({super.key, required this.savedFiles});
  final List<FileSystemEntity> savedFiles;

  @override
  DocListScreenState createState() => DocListScreenState();
}

class DocListScreenState extends State<DocListWidget> {
  String? selectedExtension;
  late List<FileSystemEntity> _savedFiles;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareSavedFiles();
  }

  @override
  void dispose() {
    _savedFiles = [];
    super.dispose();
  }

  void _prepareSavedFiles() async {
    final files = await widget.savedFiles;

    setState(() {
      _savedFiles = files;
      _isLoading = false;
    });
  }

  void _selectDoc(BuildContext context, File file) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => PDFReaderWithTTS(file: file)));
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _savedFiles.isEmpty
        ? Center(child: Text('The list is empty.'))
        : ListView.builder(
      itemCount: _savedFiles.length,
      itemBuilder: (context, index) {
        final File? file = FileService.getFileFromEntity(_savedFiles[index]);

        return DocListItem(file: _savedFiles[index], onSelectDoc: () {
          _selectDoc(context, file!);
        },
        );
      },
    );
  }
}