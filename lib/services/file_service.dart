import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  Future<File> getFileFromDownloads(String fileName) async {
    Directory? downloadsDir;

    // Android
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    }
    // iOS
    else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
      downloadsDir = Directory('${downloadsDir.path}/Downloads');
    }

    if (downloadsDir != null && await downloadsDir.exists()) {
      return File('${downloadsDir.path}/$fileName');
    } else {
      throw Exception("Downloads directory not found");
    }
  }
}