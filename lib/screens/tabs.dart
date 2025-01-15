import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/providers/favorite_files.dart';
import 'package:pdf_reader/providers/read_files_provider.dart';
import 'package:pdf_reader/providers/wish_files_provider.dart';
import 'package:pdf_reader/screens/doc_list.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/screens/search_settings.dart';
import 'package:pdf_reader/screens/settings.dart';
import 'package:pdf_reader/widgets/main_drawer.dart';
import 'package:pdf_reader/services/file_service.dart';
import 'package:pdf_reader/providers/files_provider.dart';
import 'package:pdf_reader/providers/currently_read_files_provider.dart';

const kInitialFilters = {
  Filter.autoStart: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  Map<Filter, bool> _selectedFilters = kInitialFilters;
  late Future<List<FileSystemEntity>> allFiles;
  late Future<List<FileSystemEntity>> currentlyReadFiles;
  late Future<List<FileSystemEntity>> favoriteFiles;
  late Future<List<FileSystemEntity>> wishFiles;
  late Future<List<FileSystemEntity>> readFiles;

  @override
  void initState() {
    if (_selectedFilters[Filter.autoStart]!) {
      FileService.getFileFromDownloads('test.pdf');
    }
    super.initState();
  }

  void _onSelectFilters(Map<Filter, bool>? filters) {
    setState(() {
      _selectedFilters = filters ?? kInitialFilters;
    });
  }

  void _setScreen(String identifier) {
    Navigator.of(context).pop();
    switch(identifier) {
      case 'current_doc_list':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocListScreen(savedFiles: currentlyReadFiles)));
        break;
      case 'all_doc_list':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocListScreen(savedFiles: allFiles)));
        break;
      case 'favorites':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocListScreen(savedFiles: favoriteFiles)));
        break;
      case 'wish_doc_lis':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocListScreen(savedFiles: wishFiles)));
        break;
      case 'read_doc_lis':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DocListScreen(savedFiles: readFiles)));
        break;
      case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => SettingsScreen(selectedFilters: _selectedFilters, onSelectFilters: _onSelectFilters,)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    allFiles = ref.watch(filesProvider);
    currentlyReadFiles = Future.value(ref.watch(currentlyReadFilesProvider));
    favoriteFiles = Future.value(ref.watch(favoriteFilesProvider));
    wishFiles = Future.value(ref.watch(wishFilesProvider));
    readFiles = Future.value(ref.watch(readFilesProvider));

    Widget activePage = DocListScreen(savedFiles: allFiles);
    String activeTitle = "Document list";

    return Scaffold(
      appBar: AppBar(
        title: Text(activeTitle),
        actions: [
          PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'open_single_file':
                    File? result = await FileService.prepareFile();

                    if (result != null) {
                      await FileService.saveFile(result);
                    }

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