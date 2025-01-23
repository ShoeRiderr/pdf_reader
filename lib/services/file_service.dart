import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileService {
  static Future<File> getFileFromDownloads(String fileName) async {
    Directory? downloadsDir;

    // Android
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    }
    // iOS
    else if (Platform.isIOS) {
      downloadsDir = await getStoragePath();
      downloadsDir = Directory('${downloadsDir.path}/Downloads');
    }
    final files = downloadsDir?.listSync();
    final fileNames = files?.map((e) => e.path).toList();

    if (downloadsDir != null && await downloadsDir.exists()) {
      return File('${downloadsDir.path}/$fileName');
    } else {
      throw Exception("Downloads directory not found");
    }
  }

  static Future<Directory> getStoragePath() async {
    return await getApplicationDocumentsDirectory();
}

static Future<List<FileSystemEntity>> getAllSavedFiles() async {
    final storageDir = await getApplicationDocumentsDirectory();
    return storageDir.listSync().where((entity) {
      return entity is File && entity.path.endsWith('.pdf');
    }).toList();
}

  static Future<File?> prepareFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    String? pdfPath = result?.files.single.path!;
    if (pdfPath != null) {
      return File(pdfPath);
    }

    return null;
  }

  static File? getFileFromEntity(FileSystemEntity entity) {
    if (entity is File) {
      return entity;
    }
    return null; // Return null if the entity is not a File
  }

  static Future<bool> saveFile(File file) async {
    String fileName = file.uri.pathSegments.last;
    final appStorageDir = await getStoragePath();
    File savedFile = File('${appStorageDir.path}/$fileName');

    if (!await savedFile.exists()) {
      await file.copy(savedFile.path);
      return true;
    }

    return false;
  }

  static Future<void> addPersistentData(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  static List<String> prepareListOfPathsFromListOfFiles(List<String> filePathList) {
    List<String> result = [];

    for (var i = 0; i < filePathList.length; i++) {
      result.add(filePathList[i]);
    }

    return result;
  }

  static Future<List<String>?> getPersistentDataFiles(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }
}