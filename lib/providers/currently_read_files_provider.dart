import 'package:pdf_reader/services/file_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String storageKey = "current_doc_list";

class CurrentlyReadFilesProvider extends StateNotifier<List<String>> {
  CurrentlyReadFilesProvider() : super([]) {
    _loadFromPrefs();
  }

  bool toggleStatus(String path) {
    final fileIsRead = state.contains(path);
    bool result = false;

    if (fileIsRead) {
      state = state.where((p) => p != path).toList();
      result = false;
    } else {
      state = [...state, path];
      result = true;
    }

    FileService.addPersistentData(
        storageKey,
        FileService.prepareListOfPathsFromListOfFiles(state)
    );

    return result;
  }

  void _loadFromPrefs() async {
    state = await FileService.getPersistentDataFiles(storageKey) ?? [];
  }
}

final currentlyReadFilesProvider =
StateNotifierProvider<CurrentlyReadFilesProvider, List<String>>((ref) {
  return CurrentlyReadFilesProvider();
});