import 'dart:io';
import 'package:pdf_reader/models/File.dart';

class FileModelService {
  static FileModel createNewFromAFile(File file) {
    return FileModel(name: file.uri.pathSegments.last, path: file.path);
  }
}