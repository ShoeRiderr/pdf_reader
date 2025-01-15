import 'package:flutter/material.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';

import 'package:pdf_reader/services/file_service.dart';

class PDFReaderWithTTS extends StatefulWidget {
  const PDFReaderWithTTS({super.key, this.file});

  final File? file;
  @override
  PDFReaderWithTTSState createState() => PDFReaderWithTTSState();
}

class PDFReaderWithTTSState extends State<PDFReaderWithTTS> {
  int _sentenceIndex = 0;
  File? _file;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;
  String _selectedLanguage = 'en-US';
  List<String> _sentences = [];
  bool _isStopped = false;

  @override
  void initState() {
    if (widget.file != null) {
      _loadFile(widget.file!);
    }
    super.initState();
  }

  final Map<String, String> _languages = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Polish': 'pl-PL',
  };

  Future<void> _pickAndLoadPDF() async {
    File? result = await FileService.prepareFile();

    if (result != null) {
      _loadFile(result);
    }
  }

  void _loadFile(File result) async {
    setState(() {
      _file = result;
      _isLoading = true;
    });

    try {
      Uint8List? bytes = await _file?.readAsBytes();
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text
      String rawText = PdfTextExtractor(document).extractText();
      final processedText = rawText.replaceAll(RegExp(r'\s+'), ' ');
      String formattedText = _formatText(processedText);
      RegExp delimiter = RegExp(r'[.!?]+');

      setState(() {
        // Split the string into an array
        _sentences = formattedText.split(delimiter);
        _isLoading = false;
      });

      // Dispose of the document to free resources
      document.dispose();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatText(String text) {
    // Insert a space after each period, exclamation mark, or question mark
    return text.replaceAllMapped(
      RegExp(r'([.!?])'),
          (match) => '${match.group(1)} ', // Add the matched punctuation followed by a space
    ).trim();
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);

    if (_sentences.isNotEmpty) {
      for(int i = _sentenceIndex; i < _sentences.length; i++) {
        if (_isStopped) {
          setState(() {
            _isStopped = false;
          });
          break;
        }
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.speak(_sentences[i].toString());
        setState(() {
          _sentenceIndex = i;
        });
      }
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isStopped = true;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    setState(() {
      _isStopped = true;
    });
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
          : _sentences.isEmpty
          ? Center(
        child: Text(
          'Select a PDF file to start.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : SfPdfViewer.file(_file!),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'upload',
            onPressed: _pickAndLoadPDF,
            tooltip: 'Upload PDF',
            child: Icon(Icons.upload_file),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'speak',
            onPressed: _speak,
            tooltip: 'Play',
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'stop',
            onPressed: _stop,
            tooltip: 'Stop',
            child: Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}