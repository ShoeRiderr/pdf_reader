import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/models/file.dart';
import 'package:pdf_reader/providers/currently_read_files_provider.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/widgets/doc_list_item.dart';

class DocListWidget extends ConsumerStatefulWidget {
  const DocListWidget({super.key, required this.savedFiles});

  final List<FileModel> savedFiles;

  @override
  DocListScreenState createState() => DocListScreenState();
}

class DocListScreenState extends ConsumerState<DocListWidget> {
  String? selectedExtension;
  late Future<List<FileModel>> _savedFiles;

  @override
  void initState() {
    _prepareSavedFiles();
    super.initState();
  }

  void _prepareSavedFiles() async {
    final files = widget.savedFiles;

    setState(() {
      _savedFiles = Future.value(files);
    });
  }

  void _selectDoc(BuildContext context, FileModel file) {
    ref.read(currentlyReadFilesProvider.notifier).setStatus(file.path, true);
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => PDFReaderWithTTS(file: file)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileModel>>(
        future: _savedFiles,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Display error message
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                var files = snapshot.data;
                return DocListItem(
                  file: files[index],
                  onSelectDoc: () {
                    _selectDoc(context, files[index]);
                  },
                );
              },
            );
          } else {
            return Container(); // Placeholder widget
          }
        });
  }
}
