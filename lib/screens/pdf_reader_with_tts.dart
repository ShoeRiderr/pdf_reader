import 'package:flutter/material.dart';
import 'package:pdf_reader/models/file.dart';

import 'package:pdf_reader/widgets/pdf_screen.dart';

class PDFReaderWithTTS extends StatefulWidget {
  const PDFReaderWithTTS({super.key, required this.file});

  final FileModel file;
  @override
  PDFReaderWithTTSState createState() => PDFReaderWithTTSState();
}

class PDFReaderWithTTSState extends State<PDFReaderWithTTS> {
  // // Future<List<Rect>> _searchTextOnPage(String searchText, int pageNumber) async {
  // //   final page = _pdfPinchController;
  // //   final text = await page.getText();
  // //
  // //   // Find matches and calculate positions
  // //   List<Rect> highlights = [];
  // //   final matches = RegExp(searchText, caseSensitive: false).allMatches(text);
  // //
  // //   for (var match in matches) {
  // //     // Convert text match positions to approximate coordinates
  // //     // Assuming hardcoded positions as placeholders
  // //     // You need to calculate these based on the actual PDF rendering
  // //     highlights.add(Rect.fromLTWH(50, 100 + (match.start * 2), 200, 30));
  // //   }
  // //
  // //   return highlights;
  // // }
  //
  // // void _updateHighlights(String searchText) async {
  // //   final highlights = await _searchTextOnPage(searchText, _currentPage + 1);
  // //   setState(() {
  // //     _highlights = highlights;
  // //   });
  // // }
  //
  //
  // Future<void> _highlightSentence(String sentence) async {
  //
  // }
  //
  // void jumpToPage(int page) {
  //   _pdfPinchController.jumpToPage(page);
  // }

  @override
  Widget build(BuildContext context) {
    return PDFScreen(file: widget.file);
  }
}