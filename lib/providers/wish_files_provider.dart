import 'package:pdf_reader/services/file_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/types/drawer_screen_types.dart';

const String storageKey = wishDocList;

class WishFilesNotifier extends StateNotifier<List<String>> {
  WishFilesNotifier() : super([]) {
    _loadFromPrefs();
  }

  bool toggleStatus(String path) {
    final fileIsWish = state.contains(path);
    bool result = false;

    if (fileIsWish) {
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

final wishFilesProvider =
StateNotifierProvider<WishFilesNotifier, List<String>>((ref) {
  return WishFilesNotifier();
});