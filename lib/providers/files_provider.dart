import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/model_managers/file_manager.dart';

FileModelManager fileModelManager = FileModelManager();


final fileModelsProvider = Provider((ref) async {
  return await fileModelManager.getFileModels();
});