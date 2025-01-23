import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_reader/models/File.dart';
import 'package:pdf_text/pdf_text.dart';

class PDFReaderWithTTS extends StatefulWidget {
  const PDFReaderWithTTS({super.key, required this.file});

  final FileModel file;
  @override
  PDFReaderWithTTSState createState() => PDFReaderWithTTSState();
}

class PDFReaderWithTTSState extends State<PDFReaderWithTTS> {
  late List<Rect> _highlights = [];
  final int _currentPage = 1;
  late PDFDoc _pdfDoc;
  int _sentenceIndex = 0;
  late FileModel _file;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;
  String _selectedLanguage = 'en-US';
  List<String> _sentences = [];
  bool _isStopped = false;

  final Map<String, String> _languages = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Polish': 'pl-PL',
  };

  @override
  void initState() {
    _loadFile(widget.file);

    super.initState();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    setState(() {
      _isStopped = true;
    });

    super.dispose();
  }

  void _loadCurrentPageText(int currPage) async {
    try {
      // Extract text
      final page = _pdfDoc.pageAt(_file.page);
      String rawText = await page.text;
      String formattedText = _formatText(rawText);

      setState(() {
        // Split the string into an array
        _sentences = _stringToListByDelimiter(RegExp(r'[.!?]+'), formattedText);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Rect>> _searchTextOnPage(String searchText, int pageNumber) async {
    final page = _pdfDoc.pageAt(pageNumber);
    final text = await page.text;

    // Find matches and calculate positions
    List<Rect> highlights = [];
    final matches = RegExp(searchText, caseSensitive: false).allMatches(text);

    for (var match in matches) {
      // Convert text match positions to approximate coordinates
      // Assuming hardcoded positions as placeholders
      // You need to calculate these based on the actual PDF rendering
      highlights.add(Rect.fromLTWH(50, 100 + (match.start * 2), 200, 30));
    }

    return highlights;
  }

  void _updateHighlights(String searchText) async {
    final highlights = await _searchTextOnPage(searchText, _currentPage + 1);
    setState(() {
      _highlights = highlights;
    });
  }

  void _loadFile(FileModel result) async {
    setState(() {
      _file = result;
      _isLoading = true;
    });

    _pdfDoc = await PDFDoc.fromFile(File(_file.path));
    _loadCurrentPageText(_file.page);
  }

  String _formatText(String text) {
    final processedText = text.replaceAll(RegExp(r'\s+'), ' ');
    // Insert a space after each period, exclamation mark, or question mark
    return processedText.replaceAllMapped(
      RegExp(r'([.!?])'),
          (match) => '${match.group(1)} ', // Add the matched punctuation followed by a space
    ).trim();
  }

  List<String> _stringToListByDelimiter(RegExp delimiter, String text) {
    return text.split(delimiter);
  }

  void _nextSentence() {
    if (_sentenceIndex < _sentences.length - 1) {
      setState(() {
        _sentenceIndex++;
      });
      _readCurrentSentence();
    }
  }

  void _previousSentence() {
    if (_sentenceIndex > 0) {
      setState(() {
        _sentenceIndex--;
      });
      _readCurrentSentence();
    }
  }

  Future<void> _readCurrentSentence() async {
    if (_sentenceIndex < _sentences.length) {
      await _flutterTts.speak(_sentences[_sentenceIndex]);

      // Highlight sentence
      final sentence = _sentences[_sentenceIndex];
      _highlightSentence(sentence);
    }
  }

  Future<void> _highlightSentence(String sentence) async {

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
        final sentence = _sentences[i].toString();
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.speak(sentence);
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

  void _onPageChange(int? page, int? total) {
    if (page != null) {
      _loadCurrentPageText(page);
    }
    print('page change: $page/$total');
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
            )).toList(),
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
          : Stack(
          children: [
              PDFView(
                filePath: _file.path,
                onPageChanged: _onPageChange,
              ),
            Positioned.fill(
              child: CustomPaint(
                painter: HighlightPainter(_highlights),
              ),
            ),
            ],
          ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'previous',
            onPressed: _previousSentence,
            tooltip: 'Previous',
            child: Icon(Icons.arrow_left),
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
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'next',
            onPressed: _nextSentence,
            tooltip: 'Next',
            child: Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}

class HighlightPainter extends CustomPainter {
  final List<Rect> highlights;

  HighlightPainter(this.highlights);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withValues()
      ..style = PaintingStyle.fill;

    for (final rect in highlights) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HighlightPainter oldDelegate) =>
      oldDelegate.highlights != highlights;
}