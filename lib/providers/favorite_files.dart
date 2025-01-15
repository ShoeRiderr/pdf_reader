import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteFilesNotifier extends StateNotifier<List<FileSystemEntity>> {
  FavoriteFilesNotifier() : super([]);

  bool toggleFileFavoriteStatus(FileSystemEntity file) {
    final fileIsFavorite = state.contains(file);

    if (fileIsFavorite) {
      state = state.where((m) => m.path != file.path).toList();
      return false;
    } else {
      state = [...state, file];
      return true;
    }
  }
}

final favoriteFilesProvider =
StateNotifierProvider<FavoriteFilesNotifier, List<FileSystemEntity>>((ref) {
  return FavoriteFilesNotifier();
});