import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/services/file_service.dart';

final filesProvider = Provider((ref) {
  return FileService.getAllSavedFiles();
});