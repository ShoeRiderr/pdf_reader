import 'dart:convert';
import 'package:pdf_reader/models/file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileModelManager {
  static const _key = 'file_models';

  Future<void> addFileModel(FileModel fileModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileModels = prefs.getStringList(_key) ?? [];
    bool modelAlreadyExist = false;

    fileModels.map((fileModelJson) {
      final fileModelData = json.decode(fileModelJson);
      if (fileModelData['path'] == fileModel.path) {
        modelAlreadyExist = true;
      }

      modelAlreadyExist = false;
    });

    if (!modelAlreadyExist) {
      fileModels.add(json.encode(fileModel.toJson()));

      await prefs.setStringList(_key, fileModels);
    }
  }

  Future<void> editFileModel(
      FileModel fileModel, int page, int sentenceIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fileModels = prefs.getStringList(_key) ?? [];

    fileModels = fileModels.map((fileModelJson) {
      final fileModelData = json.decode(fileModelJson);
      if (fileModelData['path'] == fileModel.path) {
        fileModelData['name'] = fileModel.name;
        fileModelData['page'] = page.toString();
        fileModelData['sentenceIndex'] = sentenceIndex.toString();

        return json.encode(fileModelData);
      }
      return fileModelJson;
    }).toList();

    await prefs.setStringList(_key, fileModels);
  }

  Future<void> removeFileModel(FileModel fileModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileModels = prefs.getStringList(_key) ?? [];

    fileModels.removeWhere((fileModelJson) {
      final fileModelData = json.decode(fileModelJson);
      return fileModelData['name'] == fileModel.name &&
          fileModelData['path'] == fileModel.path &&
          fileModelData['sentenceIndex'] == fileModel.sentenceIndex &&
          fileModelData['page'] == fileModel.page;
    });

    await prefs.setStringList(_key, fileModels);
  }

  Future<List<FileModel>> getFileModels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> fileModels = prefs.getStringList(_key) ?? [];

    return fileModels.map((fileModelJson) {
      final fileModelData = jsonDecode(fileModelJson);

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
