import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

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
    print(fileNames);
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

  static Future<Uint8List?> convertTextToImage(File file) async {
    try {
      // Load the text file
      final text = await file.readAsString();

      // Take the first page (e.g., the first 100 characters)
      final firstPageText = text.length > 100 ? text.substring(0, 100) : text;

      // Create an image with the text
      final img.Image image = img.Image(500, 300); // Set the dimensions
      img.fill(image, img.getColor(255, 255, 255)); // Set a white background

      // Draw the text
      img.drawString(image, img.arial_14, 10, 10, firstPageText, color: img.getColor(0, 0, 0));

      // Convert the image to bytes
      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}