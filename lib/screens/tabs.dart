import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/screens/doc_list.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/screens/search_settings.dart';
import 'package:pdf_reader/screens/settings.dart';
import 'package:pdf_reader/widgets/main_drawer.dart';
import 'package:pdf_reader/services/file_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  String activePage = "all_doc_list";
  String activeTitle = "Document list";

  void _onSelectFilters(Map<Filter, bool>? filters) {
    setState(() {
      _selectedFilters = filters ?? kInitialFilters;
    });
  }

  void _setScreen(String identifier) {
    Navigator.of(context).pop();
    switch(identifier) {
      case 'current_doc_list':
        setState(() {
          activePage = "current_doc_list";
          activeTitle = "Currently read list";
        });
        break;
      case 'all_doc_list':
        setState(() {
          activePage = "all_doc_list";
          activeTitle = "Document list";
        });
        break;
      case 'favorites':
        setState(() {
          activePage = "favorites";
          activeTitle = "Favourites";
        });
        break;
      case 'wish_doc_lis':
        setState(() {
          activePage = "wish_doc_lis";
          activeTitle = "Wish list";
        });
        break;
      case 'read_doc_lis':
        setState(() {
          activePage = "read_doc_lis";
          activeTitle = "Read document list";
        });
        break;
      case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => SettingsScreen(selectedFilters: _selectedFilters, onSelectFilters: _onSelectFilters,)));
        break;
    }
  }

  Future<List<FileSystemEntity>> _filterDocList(List<FileSystemEntity> docList, String key) async {
    List<String> fav = await FileService.getPersistentDataFiles(key) ?? [];
    List<FileSystemEntity> result = [];

    for (var i = 0; i < docList.length; i++) {
      var file = docList[i];
      if (fav.contains(file.path)) {
        result.add(file);
      }
    }

    return result;
  }

  Future<List<FileSystemEntity>> getFiles() async {
    final storageDir = await getApplicationDocumentsDirectory();
    var allDocs = storageDir.listSync().where((entity) {
      return entity is File && entity.path.endsWith('.pdf');
    }).toList();

    switch(activePage) {
      case 'all_doc_list':
        return allDocs;
      case 'favorites':
        return await _filterDocList(allDocs, 'favourites');
      case 'wish_doc_lis':
        return await _filterDocList(allDocs, 'wish_doc_lis');
      case 'current_doc_list':
        return await _filterDocList(allDocs, 'current_doc_list');
      case 'read_doc_lis':
        return await _filterDocList(allDocs, 'read_doc_lis');
      default:
        return allDocs;
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
      body: FutureBuilder(
        future: getFiles(), // Your asynchronous function
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Display error message
          } else if (snapshot.hasData) {
            return DocListScreen(savedFiles: snapshot.data); // Display fetched data
          } else {
            return Container(); // Placeholder widget
          }
        },
      ),
    );
  }
}