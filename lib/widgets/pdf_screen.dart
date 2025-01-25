import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_reader/model_managers/file_manager.dart';

import 'package:pdf_reader/models/file.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

import 'package:pdf_reader/model_managers/file_content_manager.dart';

import '../models/file_content.dart';

class PDFScreen extends StatefulWidget {
  final FileModel file;

  const PDFScreen({super.key, required this.file});

  @override
  PDFScreenState createState() => PDFScreenState();
}

class PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final FileModelManager fileModelManager = FileModelManager();
  final FileContentModelManager fileContentModelManager = FileContentModelManager();
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  // TTS variables
  final FlutterTts _flutterTts = FlutterTts();
  late int _sentenceIndex;
  List<String> _sentences = [];
  List<String> _currentPageSentences = [];
  bool _isStopped = false;
  String _selectedLanguage = 'en-US';

  // Extract file variables
  bool _isLoading = false;

  // Highlight currently read out loud text
  List<Rect> _highlights = [];

  final Map<String, String> _languages = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Polish': 'pl-PL',
  };

  @override
  void initState() {
    // deleteAllContentModels();
    super.initState();
    setState(() {
      currentPage = widget.file.page;
      _sentenceIndex = widget.file.sentenceIndex;
      _isLoading = true;
    });

    _loadFile().then((v) {
      _loadTextFromPage();
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }
  // For manual tests purpose to check if loaded data from cache is in good format
  void deleteAllContentModels() async {
    final fileContentModels = await fileContentModelManager.getFileContentModels();
    for (var fileContentModel in fileContentModels) {
      fileContentModelManager.removeFileContentModel(fileContentModel);
    }
  }
  @override
  void dispose() {
    _flutterTts.stop();

    super.dispose();
  }

//   Future<List<Rect>> searchTextOnPage(String searchText, ) async {
//     PdfDocument document =
//     PdfDocument(inputBytes: File(widget.file.path).readAsBytesSync());
// //Find the text and get matched items.
//     List<MatchedItem> textCollection =
//     PdfTextExtractor(document).findText([searchText]);
// //Get the matched item in the collection using index.
//     MatchedItem matchedText = textCollection[0];
// //Get the text bounds.
//     Rect textBounds = matchedText.bounds;
//     // Find matches and calculate positions
//     List<Rect> highlights = [];
//     final matches = RegExp(searchText, caseSensitive: false).allMatches(_currentPageSentences.join(' '));
//
//     for (var match in matches) {
//       // Convert text match positions to approximate coordinates
//       // Assuming hardcoded positions as placeholders
//       // You need to calculate these based on the actual PDF rendering
//       highlights.add(Rect.fromLTWH(50, 100 + (match.start * 2), 200, 30));
//     }
//
//     return highlights;
//   }
  //
  // void _updateHighlights() async {
  //   final highlights = await searchTextOnPage();
  //   setState(() {
  //     _highlights = highlights;
  //   });
  // }

  Future<void> _loadFile() async {
    _sentences = await _getPDFTextPaginated();

    return;
  }

  void _loadTextFromPage() {
    var pageText = _formatText(_sentences.elementAt(currentPage!));

    setState(() {
      _currentPageSentences =
          _stringToListByDelimiter(RegExp(r'[.!?]+'), pageText);
    });
  }

  Future<List<String>> _getPDFTextPaginated() async {
    List<String> textList = [];
    try {
      // If FileContent model exists then try to fetch the data from there while it's less time consuming
      String path = widget.file.path;
      FileContentModel? fileContentModel = await fileContentModelManager.getFileContentModelByUniqueKey(path);
      if (fileContentModel != null) {
        textList = jsonDecode(fileContentModel.content).map<String>((val) => val.toString()).toList();
      } else {
        textList = await ReadPdfText.getPDFtextPaginated(path);

        fileContentModelManager.addFileContentModel(FileContentModel(path: path, content: jsonEncode(textList)));
      }
    } on PlatformException {
      print('Failed to get PDF text.');
    }
    return textList;
  }

  // Text formater
  String _formatText(String text) {
    final processedText = text.replaceAll(RegExp(r'\s+'), ' ');
    // Insert a space after each period, exclamation mark, or question mark
    return processedText
        .replaceAllMapped(
          RegExp(r'([.!?])'),
          (match) =>
              '${match.group(1)} ', // Add the matched punctuation followed by a space
        )
        .trim();
  }

  List<String> _stringToListByDelimiter(RegExp delimiter, String text) {
    return text.split(delimiter);
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);

    if (_currentPageSentences.isNotEmpty) {
      for (int i = _sentenceIndex; i < _currentPageSentences.length; i++) {
        if (_isStopped) {
          setState(() {
            _isStopped = false;
          });
          break;
        }
        final sentence = _currentPageSentences[i].toString();
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.speak(sentence);
        setState(() {
          _sentenceIndex = i;
        });
      }

      // after last sentence, move to the next page and continue reading out loud
      if (_sentenceIndex == _currentPageSentences.length - 1 &&
          currentPage != null &&
          pages != null &&
          currentPage! < pages!) {
        var controller = await _controller.future;
        setState(() {
          currentPage = (currentPage! + 1);
        });

        controller.setPage(currentPage!);
        _speak();
      }
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    // edit model page and sentenceIndex on pause
    fileModelManager.editFileModel(widget.file, currentPage!, _sentenceIndex);
    setState(() {
      _isStopped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: <Widget>[
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
      body: Stack(
        children: <Widget>[
          // Positioned.fill(
          //   child: CustomPaint(
          //     painter: HighlightPainter(_highlights),
          //   ),
          // ),
          PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            // swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            // if set to true the link is handled in flutter
            // backgroundColor: Colors.black,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: ${page ?? 0 + 1}/$total');
              setState(() {
                currentPage = page;
                // change sentence index after changing the page. But not on first load
                if (widget.file.page != currentPage) {
                  _sentenceIndex = 0;
                }
                // Edit models current page and sentenceIndex after every page change
                fileModelManager.editFileModel(
                    widget.file, currentPage!, _sentenceIndex);
              });
              _loadTextFromPage();
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: Row(children: [
        SizedBox(width: 10),
        Visibility(
          visible: !_isLoading,
          child: FloatingActionButton(
            heroTag: 'speak',
            onPressed: _isLoading ? null : _speak,
            tooltip: 'Play',
            child: Icon(Icons.play_arrow),
          ),
        ),
        SizedBox(width: 10),
        Visibility(
          visible: !_isLoading,
          child: FloatingActionButton(
            heroTag: 'stop',
            onPressed: _isLoading ? null : _stop,
            tooltip: 'Play',
            child: Icon(Icons.stop),
          ),
        ),
      ]),
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
