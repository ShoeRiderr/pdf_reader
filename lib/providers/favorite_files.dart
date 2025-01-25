import 'package:pdf_reader/services/file_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/types/drawer_screen_types.dart';

const String storageKey = favourites;

class FavoriteFilesNotifier extends StateNotifier<List<String>> {
  FavoriteFilesNotifier() : super([]) {
    _loadFromPrefs();
  }

  bool toggleStatus(String path) {
    final fileIsFavorite = state.contains(path);
    bool result = false;

    if (fileIsFavorite) {
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

final favoriteFilesProvider =
StateNotifierProvider<FavoriteFilesNotifier, List<String>>((ref) {
  return FavoriteFilesNotifier();
});