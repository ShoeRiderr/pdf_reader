import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/models/file.dart';
import 'package:pdf_reader/screens/doc_list.dart';
import 'package:pdf_reader/screens/pdf_reader_with_tts.dart';
import 'package:pdf_reader/screens/settings/search_settings.dart';
import 'package:pdf_reader/screens/settings.dart';
import 'package:pdf_reader/widgets/main_drawer.dart';
import 'package:pdf_reader/services/file_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdf_reader/services/file_model_service.dart';
import 'package:pdf_reader/model_managers/file_manager.dart';
import 'package:pdf_reader/types/drawer_screen_types.dart';

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
  final FileModelManager fileModelManager = FileModelManager();
  String activePage = currentDocList;
  String activeTitle = "Currently read list";

  void _onSelectFilters(Map<Filter, bool>? filters) {
    setState(() {
      _selectedFilters = filters ?? kInitialFilters;
    });
  }

  void _setScreen(String identifier) {
    Navigator.of(context).pop();
    switch (identifier) {
      case currentDocList:
        setState(() {
          activePage = currentDocList;
          activeTitle = "Currently read list";
        });
        break;
      case allDocList:
        setState(() {
          activePage = allDocList;
          activeTitle = "Document list";
        });
        break;
      case favourites:
        setState(() {
          activePage = favourites;
          activeTitle = "Favourites";
        });
        break;
      case wishDocList:
        setState(() {
          activePage = wishDocList;
          activeTitle = "Wish list";
        });
        break;
      case readDocList:
        setState(() {
          activePage = readDocList;
          activeTitle = "Read document list";
        });
        break;
      case 'settings':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => SettingsScreen(
                      selectedFilters: _selectedFilters,
                      onSelectFilters: _onSelectFilters,
                    )));
        break;
    }
  }

  Future<List<FileModel>> _filterDocList(
      List<FileModel> docList, String key) async {
    List<String> fav = await FileService.getPersistentDataFiles(key) ?? [];
    List<FileModel> result = [];

    for (var i = 0; i < docList.length; i++) {
      var file = docList[i];
      if (fav.contains(file.path)) {
        result.add(file);
      }
    }

    return result;
  }

  Future<List<FileModel>> getFiles() async {
    List<FileModel> allFileModels = await fileModelManager.getFileModels();

    switch (activePage) {
      case allDocList:
        return allFileModels;
      case favourites:
        return await _filterDocList(allFileModels, favourites);
      case wishDocList:
        return await _filterDocList(allFileModels, wishDocList);
      case currentDocList:
        return await _filterDocList(allFileModels, currentDocList);
      case readDocList:
        return await _filterDocList(allFileModels, readDocList);
      default:
        return allFileModels;
    }
  }

  void _openPdfView(FileModel fileModel) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PDFReaderWithTTS(file: fileModel),
    ));
  }

  void _onFileUpload(value) async {
    switch (value) {
      case 'open_single_file':
        File? file = await FileService.prepareFile();

        if (file != null) {
          await FileService.saveFile(file);
          var fileModel = FileModelService.createNewFromAFile(file);
          await fileModelManager.addFileModel(fileModel);
          await getFiles();
          _openPdfView(fileModel);
        }

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activeTitle),
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          PopupMenuButton<String>(
            onSelected: _onFileUpload,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                    value: 'open_single_file', child: Text('Open single file'))
              ];
            },
          )
        ],
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: FutureBuilder(
        future: getFiles(), // Your asynchronous function
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Display error message
          } else if (snapshot.hasData) {
            return DocListScreen(
                savedFiles: snapshot.data); // Display fetched data
          } else {
            return Container(); // Placeholder widget
          }
        },
      ),
    );
  }
}
