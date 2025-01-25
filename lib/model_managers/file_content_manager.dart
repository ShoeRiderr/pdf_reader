import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf_reader/models/file_content.dart';

class FileContentModelManager {
  static const _key = 'file_content_models';
  static const _uniqueKey = 'path';

  Future<void> addFileContentModel(FileContentModel fileContentModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileContentModels = prefs.getStringList(_key) ?? [];
    bool modelAlreadyExist = false;

    fileContentModels.map((fileContentModelJson) {
      final fileContentModelData = json.decode(fileContentModelJson);
      if (fileContentModelData['path'] == fileContentModel.path) {
        modelAlreadyExist = true;
      }

      modelAlreadyExist = false;
    });

    if (!modelAlreadyExist) {
      fileContentModels.add(json.encode(fileContentModel.toJson()));

      await prefs.setStringList(_key, fileContentModels);
    }
  }

  Future<void> editFileContentModel(
      FileContentModel fileContentModel, int page, int sentenceIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fileContentModels = prefs.getStringList(_key) ?? [];

    fileContentModels = fileContentModels.map((fileContentModelJson) {
      final fileContentModelData = json.decode(fileContentModelJson);
      if (fileContentModelData['path'] == fileContentModel.path) {
        fileContentModelData['content'] = fileContentModel.content;
        fileContentModelData['page'] = page.toString();

        return json.encode(fileContentModelData);
      }
      return fileContentModelJson;
    }).toList();

    await prefs.setStringList(_key, fileContentModels);
  }

  Future<void> removeFileContentModel(FileContentModel fileContentModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileContentModels = prefs.getStringList(_key) ?? [];

    fileContentModels.removeWhere((fileContentModelJson) {
      final fileContentModelData = json.decode(fileContentModelJson);
      return fileContentModelData['content'] == fileContentModel.content &&
          fileContentModelData['path'] == fileContentModel.path;
    });

    await prefs.setStringList(_key, fileContentModels);
  }

  Future<List<FileContentModel>> getFileContentModels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileContentModels = prefs.getStringList(_key) ?? [];

    return fileContentModels.map((fileContentModelJson) {
      final fileContentModelData = jsonDecode(fileContentModelJson);

      var path = fileContentModelData['path'];
      var content = fileContentModelData['content'];
      return FileContentModel(
        path: path,
        content: content,
      );
    }).toList();
  }

  Future<FileContentModel?> getFileContentModelByUniqueKey(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileContentModels = prefs.getStringList(_key) ?? [];
    if (fileContentModels.isEmpty) {
      return null;
    }
    try {
      String? result = fileContentModels.firstWhere((fileContentModelJson) {
        final fileContentModelData = jsonDecode(fileContentModelJson);

        return fileContentModelData[_uniqueKey] == uid;
      });

      final fileContentModelData = jsonDecode(result);

      var path = fileContentModelData['path'];
      var content = fileContentModelData['content'];

      if (path != null) {
        return FileContentModel(
          path: path,
          content: content,
        );
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
