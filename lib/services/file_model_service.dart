import 'dart:io';
import 'package:pdf_reader/models/File.dart';

class FileModelService {
  static FileModel createNewFromAFile(File file) {
    return FileModel(path: file.path, yCoor: 0, xCoor: 0, page: 1);
  }

  bool overrideModel(FileModel oldModel, FileModel newModel) {
    return false;
  }
}