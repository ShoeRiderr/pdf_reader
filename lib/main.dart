import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Reader with Syncfusion',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PDFReaderWithTTS(),
    );
  }
}

class PDFReaderWithTTS extends StatefulWidget {
  const PDFReaderWithTTS({super.key});

  @override
  PDFReaderWithTTSState createState() => PDFReaderWithTTSState();
}

class PDFReaderWithTTSState extends State<PDFReaderWithTTS> {
  String _pdfText = '';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;
  String _selectedLanguage = 'en-US';

  final Map<String, String> _languages = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'German': 'de-DE',
  };

  Future<void> _pickAndLoadPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        File file = File(result.files.single.path!);
        Uint8List bytes = await file.readAsBytes();

        // Load the PDF document
        final PdfDocument document = PdfDocument(inputBytes: bytes);

        // Extract text
        String text = PdfTextExtractor(document).extractText();

        setState(() {
          _pdfText = text;
          _isLoading = false;
        });

        // Dispose of the document to free resources
        document.dispose();
      } catch (e) {
        setState(() {
          _pdfText = 'Error loading PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_pdfText);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Reader with Syncfusion'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            items: _languages.entries
                .map((entry) => DropdownMenuItem(
              value: entry.value,
              child: Text(entry.key),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
            dropdownColor: Colors.white,
            underline: SizedBox(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pdfText.isEmpty
          ? Center(
        child: Text(
          'Select a PDF file to start.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            _pdfText,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickAndLoadPDF,
            tooltip: 'Upload PDF',
            child: Icon(Icons.upload_file),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _speak,
            tooltip: 'Play',
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _stop,
            tooltip: 'Stop',
            child: Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
