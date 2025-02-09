import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_reader/model_managers/file_manager.dart';
import 'package:pdf_reader/models/file.dart';
import 'package:pdf_reader/widgets/pdf_screen/bottom_naw_bar.dart';
import 'package:pdf_reader/widgets/pdf_screen/bottom_speak_settings_nav_bar.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:pdf_reader/model_managers/file_content_manager.dart';
import 'package:pdf_reader/models/file_content.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFScreen extends StatefulWidget {
  final FileModel file;

  const PDFScreen({super.key, required this.file});

  @override
  PDFScreenState createState() => PDFScreenState();
}

class PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final FileModelManager fileModelManager = FileModelManager();
  final FileContentModelManager fileContentModelManager =
      FileContentModelManager();
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
  bool _isPaused = false;
  bool _isStopped = true;
  bool _switchSentence = false;
  bool _playMode = false;
  String _selectedLanguage = 'en-US';

  // Popup, if user wants to start from a new page
  bool _isFirstLoading = true;
  late FileModel _file;

  // Extract file variables
  bool _isLoading = false;

  // Highlight currently read out loud text
  late double pdfWidth; // A4 width
  late double pdfHeight; // A4 height
  final GlobalKey _pdfKey = GlobalKey();
  late Size pdfSize;
  List<Rect> _highlights = [];

  bool _isWholeScreen = true;

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
      _file = widget.file;
      currentPage = _file.page;
      _sentenceIndex = _file.sentenceIndex;
      _isLoading = true;
    });

    _loadFile().then((v) {
      _loadTextFromPage();
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  void getSizeAndPosition() {
    RenderBox? cardBox =
        _pdfKey.currentContext?.findRenderObject() as RenderBox?;
    final position = cardBox?.localToGlobal(Offset.zero);
    debugPrint("position of the pdfView: ${position!.dx}, ${position.dy}");
    pdfSize = cardBox!.size;
    setState(() {});
  }

  // For manual tests purpose to check if loaded data from cache is in good format
  void deleteAllContentModels() async {
    final fileContentModels =
        await fileContentModelManager.getFileContentModels();
    for (var fileContentModel in fileContentModels) {
      fileContentModelManager.removeFileContentModel(fileContentModel);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();

    fileModelManager.editFileModel(_file, currentPage!, _sentenceIndex);
    super.dispose();
  }

  /// Convert PDF coordinates to Flutter UI coordinates
  Rect convertPdfCoordinates(double x, double y, double width, double height) {
    double scaleX = MediaQuery.of(context).size.width / pdfWidth;
    double scaleY = MediaQuery.of(context).size.height / pdfHeight;

    return Rect.fromLTWH(
        x * scaleX, y * scaleY, width * scaleX, height * scaleY);
  }

  /// Extract text and compute bounding boxes for multi-line sentences
  Future<void> _extractTextPositions(String searchText) async {
    final PdfDocument document =
        PdfDocument(inputBytes: File(_file.path).readAsBytesSync());
    document.pageSettings.size = Size(pdfWidth, pdfHeight);
    searchText = searchText.trim();
    List<Rect> areas = [];
    // final PdfPage page = document.pages[currentPage!];
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final List<TextLine> lines = extractor.extractTextLines();

    // Reconstruct full text line-by-line
    String fullText = "";
    Map<int, List<TextWord>> wordsByLine = {};
    int lineIndex = 0;

    for (var line in lines) {
      fullText += line.text + "\n"; // Keep natural line breaks
      wordsByLine[lineIndex] = line.wordCollection;
      lineIndex++;
    }
    // Search for multi-line sentence
    List<String> words = searchText.split(" ");
    String firstWord = words.isNotEmpty ? words.first : '';
    int startIndex = fullText.indexOf(firstWord);
    // print("Start index of '$searchText': $startIndex");

    if (startIndex != -1) {
      // Find which words correspond to the match
      List<TextWord> matchedWords = [];
      int charCount = 0;

      for (var words in wordsByLine.values) {
        for (var word in words) {
          charCount += word.text.length + 1; // Include spaces
          if (charCount >= startIndex &&
              charCount <= startIndex + searchText.length) {
            matchedWords.add(word);
          }
        }
      }

      debugPrint(pdfSize.height.toString());

      // Create a bounding box that spans multiple words/lines
      if (matchedWords.isNotEmpty) {
        double left = matchedWords.first.bounds.left;
        debugPrint("duap");
        double top = matchedWords.first.bounds.top;
        double right = matchedWords.last.bounds.right;
        double bottom = matchedWords.last.bounds.bottom;
        debugPrint(
            'left: ${left.toString()}, right: ${right.toString()}, top: ${top.toString()}, bottom: ${bottom.toString()}');
        // Offset dx = Offset()
        areas.add(matchedWords.first.bounds);
      }
    }

    setState(() {
      _highlights = areas;
    });

    document.dispose();
  }

  Future<void> _loadFile() async {
    _sentences = await _getPDFTextPaginated();

    return;
  }

  Future<void> _loadTextFromPage() async {
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
      String path = _file.path;
      FileContentModel? fileContentModel =
          await fileContentModelManager.getFileContentModelByUniqueKey(path);
      if (fileContentModel != null) {
        textList = jsonDecode(fileContentModel.content)
            .map<String>((val) => val.toString())
            .toList();
      } else {
        textList = await ReadPdfText.getPDFtextPaginated(path);

        fileContentModelManager.addFileContentModel(
            FileContentModel(path: path, content: jsonEncode(textList)));
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

  void _onModalSubmit(bool status) async {
    if (!status) {
      // When we disagree to read out loud from the new page, it'll redirect us to the last page, where we finished.
      var controller = await _controller.future;
      setState(() {
        _file = widget.file;
        currentPage = _file.page;
        _sentenceIndex = _file.sentenceIndex;
      });
      controller.setPage(_file.page);
    }

    _speak(isCallFromModal: true);
    Navigator.of(context).pop();
  }

  Future _openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
                "Your read position was changed. Would you like to speak out loud from the new position?"),
            actions: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        _onModalSubmit(false);
                      },
                      child: Text("No")),
                  TextButton(
                      onPressed: () {
                        _onModalSubmit(true);
                      },
                      child: Text("Yes"))
                ],
              )
            ],
          ));

  Future<void> _speak({bool isCallFromModal = false}) async {
    // If current page not match with last saved page in file, then open an popup with question, if you really want to start listening from the current page
    // if (_file.page != currentPage && !isCallFromModal) {
    //   _openDialog();
    //   // return void, while we have to wait for the answer from the modal
    //   return;
    // }

    setState(() {
      _isStopped = false;
    });

    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);

    if (Platform.isIOS) {
      if (await _flutterTts.isLanguageAvailable(_selectedLanguage)) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
        );
      }
    }

    if (_currentPageSentences.isNotEmpty) {
      for (int i = _sentenceIndex; i < _currentPageSentences.length; i++) {
        // If stop button is clicked, then then _isPaused is set to true. Based on that we can break the loop.
        if (_isPaused) {
          setState(() {
            _isPaused = false;
          });
          break;
        }
        setState(() {
          _sentenceIndex = i;
        });
        final sentence = _currentPageSentences[i].toString();
        await _extractTextPositions(sentence);
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.speak(sentence);
      }

      if (_checkIfLastSentenceOnPage()) {
        _moveToTheNextPage();
        _speak();
      }
    }
  }

  // after last sentence, move to the next page and continue reading out loud
  bool _checkIfLastSentenceOnPage() {
    return _sentenceIndex == _currentPageSentences.length - 1 &&
        currentPage != null &&
        pages != null &&
        currentPage! < pages!;
  }

  Future<void> _moveToTheNextPage() async {
    var controller = await _controller.future;
    setState(() {
      currentPage = (currentPage! + 1);
    });

    controller.setPage(currentPage!);
  }

  Future<void> _moveToThePrevPage() async {
    var controller = await _controller.future;
    debugPrint("before: $currentPage");
    setState(() {
      currentPage = (currentPage! - 1);
    });

    controller.setPage(currentPage!);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPaused = true;
      _isStopped = true;
    });
    // edit model page and sentenceIndex on pause
    fileModelManager.editFileModel(_file, currentPage!, _sentenceIndex);
  }

  void _nextSentence() async {
    if (!_isStopped) {
      await _stop();
      // Flag for playing interactive text. When set to true then play the text again. Otherwise, let the speaker off
      setState(() {
        _switchSentence = true;
      });
    }

    setState(() {
      ++_sentenceIndex;
    });

    if (_checkIfLastSentenceOnPage()) {
      setState(() {
        _switchSentence = false;
      });
      return;
    }

    if (_switchSentence) {
      await _speak();
      setState(() {
        _switchSentence = false;
      });
    }
  }

  void _prevSentence() async {
    if (!_isStopped) {
      await _stop();
      // Flag for playing interactive text. When set to true then play the text again. Otherwise, let the speaker off
      setState(() {
        _switchSentence = true;
      });
    }

    if (_sentenceIndex > 0) {
      setState(() {
        --_sentenceIndex;
      });
    }

    if (_sentenceIndex == 0) {
      debugPrint("prev");
      await _moveToThePrevPage();

      _sentenceIndex = _currentPageSentences.length - 1;
      return;
    }

    if (_switchSentence) {
      await _speak();
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      // Positioned.fill(
      //   child: CustomPaint(
      //     painter: HighlightPainter(_highlights),
      //   ),
      // ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          pdfHeight = constraints.maxHeight;
          pdfWidth = constraints.maxWidth;
          print(
              "The height of the container is $pdfHeight and the width is $pdfWidth");
          return Stack(
            children: <Widget>[
              GestureDetector(
                child: PDFView(
                  key: _pdfKey,
                  nightMode: isDarkMode,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  filePath: _file.path,
                  enableSwipe: true,
                  // swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  // defaultPage: currentPage!,
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
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                  },
                  gestureRecognizers: Set()
                    ..add(Factory(() => TapGestureRecognizer()
                      ..onTapDown = (tap) {
                        setState(() {
                          // Toggle show whole screen onTap
                          _isWholeScreen = !_isWholeScreen;
                        });
                      })),
                  onViewCreated: (PDFViewController pdfViewController) async {
                    _controller.complete(pdfViewController);
                    var controller = await _controller.future;
                    controller.setPage(widget.file.page);
                  },
                  onPageChanged: (int? page, int? total) async {
                    setState(() {
                      currentPage = page;
                    });
                    await _loadTextFromPage();
                    // change sentence index after changing the page. But not on first load, while when, the file was already read, it'll try to change it.
                    // If _switchStatement is true, it means, that we clicked previous sentence at the beginning of the previous page
                    if (_file.page != currentPage && !_switchSentence) {
                      setState(() {
                        _sentenceIndex = 0;
                      });
                    }
                    if (_switchSentence) {
                      setState(() {
                        _switchSentence = false;
                      });
                    }

                    // Edit models current page and sentenceIndex after every page change but not on the first load
                    fileModelManager.editFileModel(
                        _file, currentPage!, _sentenceIndex);
                  },
                ),
                onTap: () {},
              ),
              ..._highlights.map((rect) {
                return Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: Container(
                    color: Colors.yellow.withOpacity(0.5),
                  ),
                );
              }),
              errorMessage.isEmpty
                  ? !isReady
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container()
                  : Center(
                      child: Text(errorMessage),
                    ),
              Visibility(
                visible: !_isWholeScreen,
                child: Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AppBar(
                    title: PreferredSize(
                      preferredSize: Size(0.0, 25.0),
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          _file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    iconTheme: Theme.of(context).iconTheme,
                    actions: <Widget>[
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (!_playMode) _speak();

                                setState(() {
                                  _playMode = true;
                                });
                              },
                        icon: Icon(Icons.volume_down),
                      ),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        items: _languages.entries
                            .map((entry) => DropdownMenuItem(
                                  value: entry.value,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          }
                        },
                        dropdownColor: Theme.of(context).primaryColor,
                        underline: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !_isWholeScreen,
                child: Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0,
                  child: Container(
                    // height: 120,
                    padding: EdgeInsets.only(
                      left: 5,
                      top: 5,
                      right: 5,
                    ),
                    child: _playMode
                        ? PdfScreenSpeakSettingsBottomNavBar(
                            onClose: (bool val) =>
                                setState(() => _playMode = val),
                            onNextSentence: _nextSentence,
                            onPrevSentence: _prevSentence,
                            isStopped: _isStopped,
                            toggleOnReadingOutLoud: _isStopped ? _speak : _stop,
                          )
                        : PdfScreenBottomNavBar(),
                  ),
                ),
              ),
            ],
          );
        },
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
