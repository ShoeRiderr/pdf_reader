import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:pdf_reader/models/file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileModelService {
  static FileModel createNewFromAFile(File file) {
    return FileModel(name: file.uri.pathSegments.last, path: file.path);
  }

  static Future<void> addPersistentData(String key, List<FileModel> value) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> modelList = value.map<String>((v) => jsonEncode(value)).toList();

    prefs.setStringList(key, modelList);
  }

  static List<FileModel> prepareList(List<FileModel> fileModelList) {
    List<FileModel> result = [];

    for (var i = 0; i < fileModelList.length; i++) {
      result.add(fileModelList[i]);
    }

    return result;
  }

  static Future<List<FileModel>?> getPersistentDataFiles(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final modelList = prefs.getStringList(key);
debugPrint("dupa");
debugPrint(modelList.toString());
    return modelList?.map<FileModel>((v) {
      final fileModelData = jsonDecode(v);
      debugPrint(v);
      debugPrint(fileModelData['name']);
      var name = fileModelData['name'];
      var path = fileModelData['path'];
      // Parse record to String because otherwise throws an Error: type 'int' is not a subtype of type 'String'
      int sentenceIndex = int.tryParse(fileModelData['sentenceIndex'].toString()) ?? 0;
      int page = int.tryParse(fileModelData['page'].toString()) ?? 0;

      return FileModel(
          name: name,
          path: path,
          sentenceIndex: sentenceIndex,
          page: page
      );
    }).toList();
  }
}