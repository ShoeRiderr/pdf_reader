import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_reader/screens/doc_list.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/screens/search_settings.dart';
import 'package:pdf_reader/screens/settings.dart';
import 'package:pdf_reader/widgets/main_drawer.dart';
import 'package:pdf_reader/services/file_service.dart';

import 'downloads.dart';

const kInitialFilters = {
  Filter.autoStart: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  Widget activePage = DocList();
  String activeTitle = "Document list";

  Map<Filter, bool> _selectedFilters = kInitialFilters;

  @override
  void initState() {
    if (_selectedFilters[Filter.autoStart]!) {
      FileService.getFileFromDownloads('test.pdf');
    }
    super.initState();
  }

  void _onSelectFilters(Map<Filter, bool>? filters) {
    _selectedFilters = filters ?? kInitialFilters;
  }

  void _setScreen(String identifier) {
    Navigator.of(context).pop();
    switch(identifier) {
      case 'doc_list':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocList()));
        break;
      case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => SettingsScreen(selectedFilters: _selectedFilters, onSelectFilters: _onSelectFilters,)));
        break;
      case 'download':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DownloadsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activeTitle),
        actions: [
          PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'open_single_file':
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PDFReaderWithTTS(file: result),
                        )
                    );
                    break;
                }
            },
            itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                      value: 'open_single_file',
                      child: Text('Open single file')
                  )
                ];
            },
          )
        ],
      ),
      drawer: MainDrawer(onSelectScreen: _setScreen,),
      body: activePage,
    );
  }
}