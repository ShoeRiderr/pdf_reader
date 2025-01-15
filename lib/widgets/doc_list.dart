import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/services/file_service.dart';
import 'package:pdf_reader/widgets/doc_list_item.dart';

class DocList extends StatefulWidget {
  const DocList({super.key});

  @override
  DocListState createState() => DocListState();
}

class DocListState extends State<DocList> {
  String? selectedExtension;
  late List<FileSystemEntity> _savedFiles;
  late Directory _appStorageDir;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _appStorageDir = await FileService.getStoragePath();
    _loadSavedFiles();
  }

  void _loadSavedFiles() {
    final files = _appStorageDir.listSync().where((entity) {
      return entity is File && entity.path.endsWith('.pdf');
    }).toList();
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
        ? Center(child: Text('No saved PDFs'))
        : ListView.builder(
      itemCount: _savedFiles.length,
      itemBuilder: (context, index) {
        final file = FileService.getFileFromEntity(_savedFiles[index]);
        return DocListItem(file: _savedFiles[index], onSelectDoc: () {
          _selectDoc(context, file!);
        },
        );
      },
    );
  }
}