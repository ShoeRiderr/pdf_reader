import 'package:pdf_reader/services/file_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/types/drawer_screen_types.dart';

const String storageKey = currentDocList;

class CurrentlyReadFilesProvider extends StateNotifier<List<String>> {
  CurrentlyReadFilesProvider() : super([]) {
    _loadFromPrefs();
  }

  bool setStatus(String path, bool status) {
    final fileIsCurrRead = state.contains(path);
    bool result = false;

    if (fileIsCurrRead && !status) {
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